unit Classes_Graph;

interface
uses OpenGL, Classes, Forms, ComCtrls, StdCtrls;
type
GraphPoint = class;
pGraphPoint = ^GraphPoint;
pTList = ^Tlist;
Link = class;
pLink = ^Link;
{=====================================================================
 Тип объекта - вершина графа.
 Имеет:
   - Координаты местоположения
   - Радиус при отображении
   - Список исхдящих дуг, как объектов
   - Различные внешние виды
=====================================================================}
GraphPoint = class
 public
   X, Y, radius: GLfloat;
   links_list: Tlist;
   state: (NORMAL, SELECT1, OPTIMA, MOVE_SELECT);

   procedure Draw();
   procedure DrawLinks;
   function Select(koord_X, koord_Y: GLFloat): boolean;
   procedure Moving(koord_X, koord_Y: GLFloat);
   procedure AddLink(point: pGraphPoint; weight: ShortInt);
   procedure OptimalRout(var PathList: TList);
   function Control(PathList: TList; point: pGraphPoint): boolean;
   procedure NormalReset;
   function  SelectLink(mouseX, mouseY: GLFloat; thisPoint: pGraphPoint): boolean;
   function CheckSelectLink(mouseX, mouseY, C, K: GLFloat): boolean;

   constructor Create(koord_X, koord_Y: GLfloat;  Form: TForm);
 protected
   frmGL: TForm;
end;

{=====================================================================
 Тип объекта - дуга графа.
 Имеет:
   - Вершину начала
   - Вес
   - Различные внешние виды
=====================================================================}
Link = class
public
  point: pGraphPoint;
  weight: ShortInt;
  state: (LINK_NORM, LINK_SEL, LINK_OPT);

  constructor Create(p: pGraphPoint; w: ShortInt);
  procedure Draw(X, Y: GLFloat);
end;

const
 Point  = 0;
 Weight = 1;

var
    RMouseDownPressed: boolean = false;
    BeginPoint: pGraphPoint = nil;
    MouseX: GLFloat = 0;
    MouseY: GlFloat = 0;
    current_weight: SmallInt;
    delete_link: boolean;
    SelectPoint1: pGraphPoint = nil;
    SelectPoint2: pGraphPoint = nil;
    Selected: pGraphPoint = nil;
    QuanPoints, QuanLinks: Integer;
    alg, count : ShortInt;
    min_link_weight : ShortInt;
    time_of_operation: Integer;
    MegaList: Tlist;
    cRandom, cMemory: Boolean;
    RoutsList: TList;
    prevSelectPoint1: pGraphPoint = nil;
    prevSelectPoint2: pGraphPoint = nil;
    OptimalList_Point: TList;
    OptimalList_Weight: TList;
    global_min_weight : SmallInt = 0;
    procedure DrawOptimalRoutPoint;
    procedure DrawOptimalRoutWeight;
    procedure ListNormalReset;
    procedure DrawLine;
    function SumWeight(L: pTList): SmallInt;
    procedure OptimaLinkFix;
    procedure FindOptimalRout;
    function SelectLink(X, Y: GLFloat): boolean;
    procedure DeletePointLinks;
    procedure DeleteCurrentPoint;

implementation
uses DGlut, Windows, Enter, SysUtils, Dialogs, List_Func, Messages;
var
  Cnt : ShortInt = 0;
  min_weight, min_point : SmallInt;
  TimeL : SYSTEMTIME;
  Local_Error : Word;
   s, p, l: Integer;

function Min(A, B: Single):Single;
begin
  if A<=B then result:=A
          else result:=B;
end;

{=====================================================================
  Визуализация(отображение) дуги.
=====================================================================}
procedure DrawLine;
begin
  if(RMouseDownPressed = true)AND(BeginPoint<>nil)then
  begin
     glPushMatrix;
        glBegin(GL_LINES);

              glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient_color);
              glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
              glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
              glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
              glMaterialfv(GL_FRONT, GL_EMISSION, @mat_emission);
                glVertex2f(BeginPoint.X, BeginPoint.Y);
                glVertex2f(MouseX, MouseY);
        glEnd;
     glPopMatrix;
  end;
end;

{=====================================================================
 В конструкторе - задание полей объекта.
=====================================================================}
constructor GraphPoint.Create(koord_X, koord_Y: GLfloat; Form: TForm);
begin
 frmGL:= Form;
 X := koord_X;
 Y := koord_Y;
 radius := 0.6;
 state := NORMAL;

 links_list := Tlist.Create
end;

{=====================================================================
 В конструкторе - задание полей объекта.
=====================================================================}
constructor Link.Create(p: pGraphPoint; w: ShortInt);
begin
  point := p;
  weight := w;
  state := LINK_NORM;
end;

{=====================================================================
 Добавление новой дуги.
=====================================================================}
procedure GraphPoint.AddLink(point: pGraphPoint; weight: ShortInt);
var
 L: pLink;
begin
  new(L);

  L^ := Link.Create(point, weight);

  links_list.Add(L);
end;

{=====================================================================
 Обновление дуг графа, т.е. перевод их из активного в пассивное
 отображение.
=====================================================================}
procedure Graphpoint.NormalReset;
var
 i: Integer;
begin
  state := NORMAL;

 for i:=0 to Links_list.Count-1 do
 begin
   pLink(Links_list[i]).state := LINK_NORM;
 end;
end;

{=====================================================================
  Визуализация(отображение) вершины.
=====================================================================}
procedure GraphPoint.Draw();
begin
    glPushMatrix;
    glTranslatef (X, Y, 0.0);
      case state of
       NORMAL: MaterialNormal;
       SELECT1: MaterialSelect;
       OPTIMA: MaterialOptima;
       MOVE_SELECT: MaterialMoveSelect;
      end;
    glutSolidSphere(radius*0.5, 32, 32);
    glPopMatrix;

    DrawLinks;

end;

{=====================================================================
 Визуализация(отображение) всех дуг.
=====================================================================}
procedure GraphPoint.DrawLinks;
var
 i: Integer;
begin
    for i:=0 to links_list.Count-1 do
    begin
       pLink(links_list[i]).Draw(X, Y);
    end;
end;

{=====================================================================
 Выделение и переход к опция дуги.
=====================================================================}
function GraphPoint.SelectLink(mouseX, mouseY: GLFloat; thisPoint: pGraphPoint): boolean;
var
 i, j: ShortInt;
 x1, y1, x2, y2, K, C, H, W, minX, minY, maxX, maxY: GLFloat;
begin
  x1 := X;
  y1 := Y;
  result := false;
    for i:=0 to links_list.Count-1 do
    begin
        x2 := pLink(Links_list[i]).point.X;
        y2 := pLink(Links_list[i]).point.Y;
        W := x1 - x2;
        H := y1 - y2;
         K := H/W;
         if W=0 then K:=-1;
         C := y1 - K*x1;
        minX := Min(x1, x2);
        maxX := x1+x2-minX;
        minY := Min(y1, y2);
        maxY := y1+y2-minY;

        if((mouseX >= (minX-0.1))AND(mouseX <= (maxX+0.1)))AND
                       ((mouseY >= (minY-0.1))AND(mouseY <= (maxY+0.1)))then
         begin  
             if CheckSelectLink(mouseX, mouseY, C, K)then
               begin
                  pLink(Links_list[i]).state := LINK_SEL;
                  InvalidateRect(frmGL.Handle, nil, False);
                  current_weight := pLink(Links_list[i]).weight;
                  FormEnter.ShowModal;

                  pLink(Links_list[i]).weight := current_weight;

      for j:=0 to pGraphPoint(pLink(Links_list[i]).point).links_list.count-1 do
      begin
       if thisPoint =  pLink(pGraphPoint(pLink(Links_list[i]).point).links_list[j]).point then
       begin
         pLink(pGraphPoint(pLink(Links_list[i]).point).links_list[j]).weight := current_weight;
         if delete_link then
         begin
           pGraphPoint(pLink(Links_list[i]).point).links_list.Delete(j);
           links_list.Delete(i);
           break
         end;
       end;
      end;

     result := true;
     break;
   end;
  end;

  end;

  NormalReset;
  SelectPoint1:=nil;
  SelectPoint2:=nil;
  Selected:=nil

end;

{=====================================================================
  Первое приближение при выделении дуги. |_|
=====================================================================}
function GraphPoint.CheckSelectLink(mouseX, mouseY, C, K: GLFloat): boolean;
var
  X, Y: GLFloat;
begin
     Y := C + mouseX*K;
     X := (mouseY-C)/K;
result := (mouseY <= (Y + 0.1))AND(mouseY >= (Y - 0.1))OR(mouseX <= (X + 0.1))AND(mouseX >= (X - 0.1));
if K=-1 then result:=true;
end;

{=====================================================================
  Выделение точки(круглая область).
=====================================================================}
function GraphPoint.Select(koord_X, koord_Y: GLFloat): boolean;
begin
result:=(X-koord_X)*(X-koord_X)+(Y-koord_Y)*(Y-koord_Y)<radius*radius
end;

{=====================================================================
 Переназначение координат точки при перемещении.
=====================================================================}
procedure GraphPoint.Moving(koord_X, koord_Y: GLFloat);
begin
 X := koord_X;
 Y := koord_Y;
end;

{=====================================================================
 Нахождение суммы весов дуг в списке дуг(в пути).
=====================================================================}
function SumWeight(L: pTList): SmallInt;
var
  i: Integer;
begin

 result:=0;

     for i:=0 to L.Count-1 do
      begin
         result := result + pLink(L.Items[i]).weight;
      end;
end;

{=====================================================================
 Определение минимального пути с возможностью контроля времени.
=====================================================================}
procedure GraphPoint.OptimalRout(var PathList: TList);
var
  i: ShortInt;
  NextPathList: Tlist;
  NewList: pTList;
  j, temp:Integer;
  label NotEqual;
begin
inc(Cnt);
if Cnt=1 then
 begin
 frmGL.Enabled := false;
                GetSystemTime(TimeL);
                Local_Error:=TimeL.wSecond+TimeL.wMinute*60;
   min_point:=QuanPoints-1;
   min_weight:=(count-1)*100;
   for s:=0 to frmGL.ComponentCount do if (frmGL.Components[s] is TStaticText) then break;
   for p:=0 to frmGL.ComponentCount do if (frmGL.Components[p] is TProgressBar) then break;
   for l:=1 to frmGL.ComponentCount do if (frmGL.Components[l] is TLabel)then break;
   (frmGL.Components[s] as TStaticText).Caption:='Отбор путей...';
   (frmGL.Components[s] as TStaticText).Refresh;
   (frmGL.Components[l] as TLabel).Caption:='     ';
   (frmGL.Components[l] as TLabel).Repaint
 end;
if count>1 then (frmGL.Components[p] as TProgressBar).Max:=count-2;
if(PathList.Count=0)OR( pLink(PathList[PathList.Count-1]).point<>SelectPoint2)then
begin
    NextPathList := Tlist.Create;
    ListCopy(PathList, NextPathList);
    temp:=TimeL.wSecond;
   for i:=0 to Links_list.Count-1 do
   begin
           if cMemory then
            begin
              GetSystemTime(TimeL);
              if temp=TimeL.wSecond then
               goto NotEqual;
               if Cnt < 2 then frmGL.Refresh;
              Val((frmGL.Components[l] as TLabel).Caption,temp,j);
              temp:=TimeL.wSecond;
              j:=TimeL.wSecond+TimeL.wMinute*60-Local_Error;
     if(j >= 0)then
     (frmGL.Components[l] as TLabel).Caption:=IntToStr(j)
     else
     (frmGL.Components[l] as TLabel).Caption:=IntToStr(j+3600);
     (frmGL.Components[l] as TLabel).Refresh;
              if(j>=time_of_operation)OR(j>=time_of_operation-3600)AND(j<0)then
               begin
                 MessageDlg('Ошибка в приложении: Долгие вычисления.', mtError, [mbAbort], 0);
                 halt
              end
            end;
NotEqual:   if(Cnt=1)then (frmGL.Components[p] as TProgressBar).Position:=i;
     if Control(PathList,pLink(Links_list[i]).point)AND(pLink(Links_list[i]).point<>SelectPoint1)then
           begin
              if (min_link_weight*(count-Cnt-1)+
                     pLink(Links_list[i]).weight+Sumweight(@NextPathList)>min_weight)AND
                            (NextPathList.Count>=min_point)AND(min_link_weight <= 0)then
                               continue;

              NextPathList.Add(pLink(Links_list[i]));
              pLink(Links_list[i]).point.OptimalRout(NextPathList)
           end;
          NextPathList.Free;
          NextPathList:=TList.Create;
       ListCopy(PathList, NextPathList);
      if i=Links_list.Count-1 then NextPathList.Free
   end

end else
  begin
     if(min_weight>Sumweight(@PathList))OR(min_point>PathList.Count)then
     begin
       new(NewList);
       NewList^ := TList.Create;
       NewList.Clear;
       ListCopy(PathList, NewList^);
       if(min_weight>Sumweight(@PathList))then min_weight:=Sumweight(@PathList);
       if(min_point>PathList.Count)then min_point:=PathList.Count;
       RoutsList.Add(NewList)
     end
  end;
  if Cnt = 1 then frmGL.Enabled := true;
  dec(Cnt)
end;

{=====================================================================
 Метод определяет, входит ли точка-объект(Self) в список дуг(путь).
=====================================================================}
function GraphPoint.Control(PathList: TList; point: pGraphPoint): boolean;
var
 i: Integer;
begin

 result := true;

     for i:=0 to PathList.Count-1 do
      begin
      try
        if pLink(PathList[i]).point = point then
          begin
             result := false;
          end;
      except
        result := false
        end
      end;

end;

{=====================================================================
 Постройка дуги, отображения веса и визуализация их.
=====================================================================}
procedure Link.Draw(X, Y: GLFloat);
var
 w_X, w_Y: GLFloat;
const
 color1: array[0..3] of GLfloat = ( 0.0, 0.0, 1.0, 1.0 );
 color2: array[0..3] of GLfloat = ( 0.0, 1.0, 0.0, 1.0 );
 color3: array[0..3] of GLfloat = ( 1.0, 0.0, 0.0, 1.0 );
begin

 w_X := (X + point.X)/2;
 w_Y := (Y + point.Y)/2;

 glPushMatrix;
   glBegin(GL_LINES);

      case state of
       LINK_NORM: MaterialNormal;
       LINK_SEL: MaterialSelectLink;
       LINK_OPT: MaterialOptimaLink;
      end;

       glVertex2f(X, Y);
       glVertex2f(point.X, point.Y);
   glEnd;

        MaterialOptima;
       case state of
        LINK_NORM: glMaterialfv(GL_FRONT, GL_AMBIENT, @color1);
        LINK_SEL:  glMaterialfv(GL_FRONT, GL_AMBIENT, @color2);
        LINK_OPT:  glMaterialfv(GL_FRONT, GL_AMBIENT, @color3);
       end;
       glRasterPos3f (w_X, w_Y, 0.1);

       OutText (pChar(IntToStr(weight)));
   glPopMatrix
end;

{=====================================================================
  Визуализация(модернизация) дуг минимального пути.
=====================================================================}
procedure OptimaLinkFix;
var
  i, j, t: ShortInt;
begin
 for i:=0 to MegaList.Count-1 do
 begin
    for j:=0 to pGraphPoint(MegaList[i]).links_list.Count-1  do
    begin
       if pLink(pGraphPoint(MegaList[i]).links_list[j]).state = LINK_OPT then
       begin
         for t:=0 to pLink(pGraphPoint(MegaList[i]).links_list[j]).point.links_list.Count-1 do
         begin
if pLink(pLink(pGraphPoint(MegaList[i]).links_list[j]).point.links_list[t]).point
                                                           = pGraphPoint(MegaList[i])then
   pLink(pLink(pGraphPoint(MegaList[i]).links_list[j]).point.links_list[t]).state := LINK_OPT;
         end;
       end;
    end;
  end;
end;

{=====================================================================
  Перерисовывает вершины и дуги.
=====================================================================}
procedure ListNormalReset;
var
  i: Integer;
begin
    for i:=0 to MegaList.Count-1 do
    begin
       pGraphPoint(MegaList[i]).NormalReset;
    end;

  InvalidateRect(pGraphPoint(MegaList[0]).frmGL.Handle, nil, False);
end;

{=====================================================================
  Визуализация минимального пути по вершинам.
=====================================================================}
procedure DrawOptimalRoutPoint;
var
 i: Integer;
begin

  ListNormalReset;

  if prevSelectPoint1 <> nil then
   prevSelectPoint1.state := SELECT1;

  if prevSelectPoint2 <> nil then
   prevSelectPoint2.state := SELECT1;

     for i:=0 to OptimalList_Point.Count-1 do
      begin
         if i <> (OptimalList_Point.Count-1)then
          pLink(OptimalList_Point[i]).point.state := OPTIMA;

          pLink(OptimalList_Point[i]).state := LINK_OPT;
      end;
       OptimaLinkFix;

       InvalidateRect(pLink(OptimalList_Point[0]).point.frmGL.Handle, nil, False);
end;

{=====================================================================
  Визуализация минимального пути по дугам.
=====================================================================}
procedure DrawOptimalRoutWeight;
var
 i: Integer;
begin

  ListNormalReset;

  if prevSelectPoint1 <> nil then
   prevSelectPoint1.state := SELECT1;

  if prevSelectPoint2 <> nil then
   prevSelectPoint2.state := SELECT1;

     for i:=0 to OptimalList_Weight.Count-1 do
      begin
         if(i <> (OptimalList_Weight.Count-1))then
          pLink(OptimalList_Weight[i]).point.state := OPTIMA;

          pLink(OptimalList_Weight[i]).state := LINK_OPT;
      end;
       OptimaLinkFix;

       InvalidateRect(pLink(OptimalList_Weight[0]).point.frmGL.Handle, nil, False);
end;

{=====================================================================
  Поиск минимального пути с использованием других функций и методов.
=====================================================================}
procedure FindOptimalRout;
var
 i, j, k : Integer;
 min_point, min_weight, dop_min_weight, dop_min_point: SmallInt;
begin
  min_point := 0;
  OptimalList_Point.Free;
  OptimalList_Point:=TList.Create();

  with pLink(pTList(RoutsList[0]).Items[0]).point.frmGL do
   begin
     for i:=0 to ComponentCount do
       if Components[i] is TStaticText then break;
     (Components[i] as TStaticText).Caption:='Выбор минимального пути...';
      (Components[i] as TStaticText).Repaint;
      min_weight := -10001;
     OptimalList_Weight.Free;
     OptimalList_Weight:=TList.Create();
     for k:=0 to ComponentCount do
       if Components[k] is TProgressBar then break;

  (Components[k] as TProgressBar).Position:=0;
  try
  if RoutsList.Count>1 then (Components[k] as TProgressBar).Max:=RoutsList.Count-1;
  except
   ShowMessage('Error in memory!');
   exit;
  end;

  for i:=0 to RoutsList.Count-1 do
  begin
  (Components[k] as TProgressBar).Position:=i;
    if(( pTList(RoutsList[i]).Count < min_point )OR(min_point = 0))OR
        ((pTList(RoutsList[i]).Count = min_point)AND
          (SumWeight(pTList(RoutsList[i])) < dop_min_weight))then
          begin
           OptimalList_Point.Free;
           OptimalList_Point:=TList.Create();
           min_point := pTList(RoutsList[i]).Count;
           dop_min_weight := SumWeight(pTList(RoutsList[i]));

           for j:=0 to pTList(RoutsList[i]).Count-1 do
           begin
             OptimalList_Point.Add( (pTList(RoutsList[i]).Items[j]) )
           end;
          end;

   if(( SumWeight(pTList(RoutsList[i])) < min_weight )OR(min_weight = -10001))OR
                             (( SumWeight(pTList(RoutsList[i])) = min_weight )AND
                                       (pTList(RoutsList[i]).Count < dop_min_point))then
   begin
      OptimalList_Weight.Free;
      OptimalList_Weight:=TList.Create();
      min_weight := SumWeight(pTList(RoutsList[i]));
      dop_min_point := pTList(RoutsList[i]).Count;
      for j:=0 to pTList(RoutsList[i]).Count-1 do
      begin
        OptimalList_Weight.Add( (pTList(RoutsList[i]).Items[j]) )
      end

    end
  end
  end;
  if alg = Point then
  begin
      DrawOptimalRoutPoint;
      Global_min_weight:=dop_min_weight
  end
  else
  begin
      DrawOptimalRoutWeight;
      Global_min_weight:=min_weight
  end
end;

{=====================================================================
 Перерисовка выбираемой дуги.
=====================================================================}
function SelectLink(X, Y: GLFloat): boolean;
var i: Integer;
begin
 result := false;
     for i:=0 to MegaList.Count-1 do
     begin
      if pGraphPoint(MegaList[i]).SelectLink(X, Y, pGraphPoint(MegaList[i]))then
      begin
         result := true;
         ListNormalReset;
         FreeMem(Selected, SizeOf(Selected));
         Selected:=nil;

         break;
      end;

     end;

  InvalidateRect(GetForegroundWindow, nil, False);
end;

{=====================================================================
  Удаление выходящих из удаляемой точки дуг.
=====================================================================}
procedure DeletePointLinks;
var
i, j: ShortInt;
P:Pointer;
begin
     for i:=0 to MegaList.Count-1 do
     begin
       for j:=0 to pGraphPoint(MegaList[i]).links_list.Count-1 do
       begin
         if pLink(pGraphPoint(MegaList[i]).links_list[j]).point = Selected then
         begin
           P:=pGraphPoint(MegaList[i]).links_list.Items[j];
           pGraphPoint(MegaList[i]).links_list.Delete(j);
           FreeMem(P,SizeOf(P));
           DeletePointLinks;
           break;
         end;
       end
     end;
end;

{=====================================================================
  Удаление самой вершины.
=====================================================================}
procedure DeleteCurrentPoint;
var
i: Integer;
P: Pointer;
Wind: HWND;
begin

     for i:=0 to MegaList.Count-1 do
      begin
         if(pGraphPoint(MegaList[i]) = Selected)then
          begin
           Wind:=pGraphPoint(MegaList[i]).frmGL.Handle;
           DeletePointLinks;
           P:=MegaList.Items[i];
           MegaList.Delete(i);
           FreeMem(P, SizeOf(P));
           dec(count);
           break
          end
      end;

  InvalidateRect(Wind, nil, False);
end;

end.
 