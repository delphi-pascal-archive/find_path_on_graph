unit main;
//Из Project-Options удален пакет <<Intraweb_50_70;>>
interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL, StdCtrls, Buttons, ExtCtrls, ComCtrls, List_Func, Classes_Graph, Thread;


type
 WND = record
    Wind:array[0..2] of HWND;
    count: Integer;
 end;
 TfrmGL = class(TForm)
    Panel1: TPanel;
    PointButton: TSpeedButton;
    WeightButton: TSpeedButton;
    ClearButton: TSpeedButton;
    DeleteButton: TSpeedButton;
    CloseButton: TSpeedButton;
    Edit1: TEdit;
    LE_min_weight: TLabeledEdit;
    SBRandom: TSpeedButton;
    SBHelp: TSpeedButton;
    PBProgress: TProgressBar;
    STPB: TStaticText;
    GBTimer: TGroupBox;
    LTimer: TLabel;
    LClose: TLabel;
    tmPanel: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function GetWeight: ShortInt;
    procedure SetWeight(w: ShortInt);
    procedure SetDeleteLink(D: boolean);
    procedure PointButtonClick(Sender: TObject);
    procedure WeightButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SBRandomClick(Sender: TObject);
    procedure Panel1DblClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure tmPanelTimer(Sender: TObject);
 
  protected
   procedure MesR_Down (var MyMessage : TWMMouse); message WM_RBUTTONDOWN;
   procedure MesR_Up (var MyMessage : TWMMouse); message WM_RBUTTONUP;
   procedure MesDblClick (var MyMessage : TWMMouse); message WM_LButtonDblClk;
   procedure WMClose (var M : TWMClose); message WM_CLOSE;
  private

    DC : HDC;
    hrc: HGLRC;
    dcrHelp: WND;
  end;

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

var
  frmGL: TfrmGL;
  LMouseDownPressed: boolean = false;
  EndPoint: pGraphPoint = nil;
  LineWidth: GLFloat;

      
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

const 
    koord_random        : array[0..31] of Integer =
    ({} 25, 95,{} 145, 160,{} 275, 125,{} 400, 145,{} 525, 125,{} 25, 350,{} 150, 390,{} 275, 400,
    {}400, 370,{} 525, 330,{} 65, 220,{} 485, 220,{} 140, 220,{} 340, 220,{} 140, 460,{} 400, 460 );

implementation

uses DGlut, Enter, UStart, ShellAPI;

var
   vError : Integer;
   Vis : Boolean;
   MoveEvent : Boolean;

{$R *.DFM}
 
{====================================================================
  Визуализацие и сокрытие кнопок на панели.
====================================================================}
procedure ButtonsVisPanel(Panel: TPanel; b:boolean);
var i: Integer;
begin
  for i:=0 to Panel.Owner.ComponentCount-1 do
  begin
    if Panel.Owner.Components[i] is TControl then
    if(Panel.Owner.Components[i] as TControl).Parent.Name=Panel.Name then
        (Panel.Owner.Components[i] as TControl).Visible := b
  end
end;

{====================================================================
  Движение панельки.
====================================================================}
procedure PanelMove(Panel: TPanel; Open: boolean);
var i: Integer;
begin
  if Open then
   begin
     if Panel.Height <> 114 then Panel.Height := Panel.Height + 1;for i:=-Rep*15000 to Rep*15000 do;
     if Panel.Height = 114 then ButtonsVisPanel(Panel, true)
   end
  else
   begin
     if Panel.Height = 114 then ButtonsVisPanel(Panel, false);for i:=-Rep*15000 to Rep*15000 do;
     if Panel.Height <> 10 then Panel.Height := Panel.Height - 1
   end
end;

{=====================================================================
Функция перерисовки формы.
Очищает окно OpenGL, потом заполняет её информацией из буфера(TList).
=====================================================================}
procedure TfrmGL.FormPaint(Sender: TObject);
var
  i: Integer;
begin
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    LineWidth := 5;
    glLinewidth(LineWidth);

    DrawLine;

    for i:=0 to MegaList.Count-1 do
        pGraphPoint(MegaList[i]).Draw;          

  SwapBuffers(DC);
end;

{=====================================================================
 Формат пикселя.
 Обычный алгоритм определения допустимого формата пикселей и
  его установка.
=====================================================================}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);

  With pfd do
  begin
    dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
    cDepthBits:= 32;
  end;

 pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 MoveEvent := true;
 min_link_weight := 100;
 vError:=0;
 count:=1;
 Panel1.Height:=10;
 alg:=Point;
 dcrHelp.count:=0;
 PointButton.Font.Color:=clRed;
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);

 MyInit;

   wglUseFontBitmaps (Canvas.Handle, 0, 255, GLF_START_LIST)
end;

{=======================================================================}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hRC);
 ReleaseDC (Handle, DC);
 DeleteDC (DC)
end;

{=======================================================================}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;

 If Key = VK_DELETE then
 begin
  DeleteButtonClick(Sender)
 end
end;

{=======================================================================}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 if ClientWidth <= (ClientHeight SHL 1)then
     glOrtho (-6.0, 6.0, -6.0*ClientHeight/ClientWidth, 6.0*ClientHeight/ClientWidth, -10.0, 10.0)
  else
     glOrtho (-3.0*ClientWidth/ClientHeight, 3.0*ClientWidth/ClientHeight, -3.0, 3.0, -10.0, 10.0);
 glMatrixMode(GL_MODELVIEW);

 InvalidateRect(Handle, nil, False)
end;

{=====================================================================
Помимо всего прочего(стандартного), функция создает одну вершину графа.
=====================================================================}
procedure TfrmGL.FormActivate(Sender: TObject);
var
point: pGraphPoint;
begin
       delete_link := false;
        new(point);
        point^ := GraphPoint.Create(0.1, 2, Self);
        MegaList := TList.Create;
        MegaList.Add(point);
        tmPanel.Enabled := true

end;

{=====================================================================
Функция определяет, на каком объекте была нажата MouseButton
Если на пустом поле - добавляем вершину, на вершине - выделяем её,
на дуге - обращаемся к опциям дуги.
=====================================================================}
procedure TfrmGL.FormMouseDown(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
var
point: pGraphPoint;
koord_X, koord_Y: GLfloat;
i: Integer;
begin
Vis:=true;

   koord_X := 12*X/ClientWidth-6;
   koord_Y := (6*ClientHeight - 12*Y)/ClientWidth;

    for i:=0 to MegaList.Count-1 do
    begin
        if(pGraphPoint(MegaList[i]).Select(koord_X, koord_Y))then
        begin
            LMouseDownPressed := true;
            ListNormalReset;
            Selected := pGraphPoint(MegaList[i]);
            Selected.state := MOVE_SELECT;
            break;
        end;
    end;

  if  (LMouseDownPressed = false) AND (SelectLink(koord_X, koord_Y) = false) then
  begin
    if count < QuanPoints then
    begin
      new(point);
      point^ := GraphPoint.Create(koord_X, koord_Y, Self);
      MegaList.Add(point);
      inc(count)
    end;
  end;

 InvalidateRect(Handle, nil, False);
end;
{=====================================================================
   Шуточная обработка события.
=====================================================================}
procedure TfrmGL.WMClose(var M : TWMClose);
begin
  LClose.Visible := true;
  if MessageDlg('Меня хотят закрыть. Согласны?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
  Close
  else
   begin
   LClose.Caption := 'Не закроюсь!        ';
   LClose.Refresh;
   Sleep(2000);
   LClose.Visible := false;
   LClose.Caption := 'Караул! Закрывают!'
  end;
  M.Result := 0
end;
{=====================================================================
При движении курсора мыши на форме перерисовываются информационные
компоненты, на которых обновляется возможно измененная информация,
а именно: количество вершин, минимальный путь, раскрывающаяся панель.
Также функция позволяет связывать конкретные вершины графа дугами.
=====================================================================}
procedure TfrmGL.FormMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
var
koord_X, koord_Y: GLfloat;
i: Integer;
begin
Vis:=false;
tmPanelTimer(Sender);
if not MoveEvent then exit;
if count = 1 then
 Edit1.Text:=IntToStr(count)+' vertex'
else if (count > 1)AND(count < 5) then
 Edit1.Text:=IntToStr(count)+' vertices'
else
 Edit1.Text:=IntToStr(count)+' vertices';
if abs(Global_min_weight) < 10000 then
 LE_min_weight.Text:=IntToStr(Global_min_weight)
else
 LE_min_weight.Text:='INF';
 LE_min_weight.Refresh;
 Edit1.Refresh;
  koord_X := 12*X/ClientWidth-6;
  koord_Y := (6*ClientHeight - 12*Y)/ClientWidth;

  if(LMouseDownPressed = true)then
   begin
     Selected.Moving(koord_X, koord_Y);
   end;

  if (RMouseDownPressed = true) AND (BeginPoint <> nil) then
   begin
     MouseX := koord_X;
     MouseY := koord_Y;
  end;

   MoveEvent := false;
InvalidateRect(Handle, nil, False)
end;
{=======================================================================}
procedure TfrmGL.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 MoveEvent := true;
    LMouseDownPressed := false;
    InvalidateRect(Handle, nil, False);
end;
{=====================================================================
 При нажатии мыши на вершине правой кнопкой от вершины ведется дуга.
=====================================================================}
procedure TfrmGL.MesR_Down (var MyMessage : TWMMouse);
var
  X, Y : Integer;
  i : Integer;
  koord_X, koord_Y : GLfloat;
begin
 MoveEvent := true;
  X := MyMessage.XPos;
  Y := MyMessage.YPos;

   koord_X := 12*X/ClientWidth-6;
   koord_Y := (6*ClientHeight - 12*Y)/ClientWidth;

    for i:=0 to MegaList.Count-1 do
    begin
        if pGraphPoint(MegaList[i]).Select(koord_X, koord_Y) then
        begin  
            RMouseDownPressed := true;
            BeginPoint := pGraphPoint(MegaList[i]);
            break;
        end;
    end;

    InvalidateRect(Handle, nil, False);
end;

{=====================================================================
 При отпускании правой кнопки мыши дуга связывает вторую вершину
 с первой.
=====================================================================}
procedure TfrmGL.MesR_Up (var MyMessage : TWMMouse);
var
  X, Y : Integer;
  i : Integer;
  koord_X, koord_Y: GLfloat;
begin
 MoveEvent := true;
  X := MyMessage.XPos;
  Y := MyMessage.YPos;

  koord_X := 12*X/ClientWidth-6;
  koord_Y := (6*ClientHeight - 12*Y)/ClientWidth;


    RMouseDownPressed := false;

    for i:=0 to MegaList.Count-1 do
    begin
        if pGraphPoint(MegaList[i]).Select(koord_X, koord_Y) then
        begin
            RMouseDownPressed := true;
            EndPoint := pGraphPoint(MegaList[i]);
            break;
        end;
    end;


   if (BeginPoint <> nil) AND (EndPoint <> nil) AND (BeginPoint <> EndPoint) then
    begin
      BeginPoint.AddLink(EndPoint, 1);
      EndPoint.AddLink(BeginPoint, 1);
    end;

    EndPoint:=nil;
    BeginPoint:=nil;
    
    InvalidateRect(Handle, nil, False);
end;

{=====================================================================
 При первом двойном щелчке мыши на вершине вершина становится
 начальной в пути, при втором двойном щелчке мыши на вершине вершина
 становится конечной в пути.
=====================================================================}
procedure TfrmGL.MesDblClick (var MyMessage : TWMMouse);
var
  X, Y : Integer;
  i : Integer;
  koord_X, koord_Y: GLfloat;
  Find : TFind;
begin
// MoveEvent := true;
  PBProgress.Visible := true;
  STPB.Visible := true;
  LE_min_weight.Visible := false;
  GBTimer.Visible := true;
  X := MyMessage.XPos;
  Y := MyMessage.YPos;
  RoutsList.Free;
  RoutsList:=TList.Create;

  koord_X := 12*X/ClientWidth-6;
  koord_Y := (6*ClientHeight - 12*Y)/ClientWidth;
  PBProgress.Position:=0;
  for i:=0 to MegaList.Count-1 do
  begin
      if pGraphPoint(MegaList[i]).Select(koord_X, koord_Y) then
        begin
             if SelectPoint1 = nil then
             begin
                vError:=0;
                ListNormalReset;
                SelectPoint1 := pGraphPoint(MegaList[i]);
                SelectPoint1.state := SELECT1;
                Selected:=nil
             end
             else
               begin
                 if SelectPoint1 <> pGraphPoint(MegaList[i]) then//Разные вершины начала и конца пути
                  begin
                    vError:=1;
                    SelectPoint2 := pGraphPoint(MegaList[i]);
                    SelectPoint2.state := SELECT1;

                    RoutsList.Free;
                    RoutsList:=TList.Create;
                    prevSelectPoint1 := SelectPoint1;
                    prevSelectPoint2 := SelectPoint2;

                    Find := TFind.Create(false);
                    Find.Init(SelectPoint1);
                    Find.Destrict;
                    PBProgress.Position:=0;
                    STPB.Caption:='';
                      SelectPoint1:=nil;
                      SelectPoint2:=nil
                  end
                 else
                  begin
                   SelectPoint1.state := NORMAL;
                   SelectPoint1:=nil
                  end
             end;
            break;
        end;
    end;
InvalidateRect(Handle, nil, False);
GBTimer.Visible := false;
LE_min_weight.Visible := true;
STPB.Visible := false;
PBProgress.Visible := false;
Hint := 'Last time is ' + LTimer.Caption + 'sek.';
end;

{=======================================================================}
function TfrmGL.GetWeight: ShortInt;
begin
  result := current_weight;
end;

{=======================================================================}
procedure TfrmGL.SetWeight(w: ShortInt);
begin
  current_weight := w;
end;

{=======================================================================}
procedure TfrmGL.SetDeleteLink(D: boolean);
begin
  delete_link := D;
end;

{=======================================================================}
procedure TfrmGL.PointButtonClick(Sender: TObject);
var Str:string;
begin
  if vError=0 then
  begin
    Str:='Cancel для отмены,Ok для продолжения';
    if not InputQuery('Внимание','Не выбраны концевые вершины!',Str) then
    exit
  end;
  alg:=Point;
  PointButton.Font.Color:=clRed;
  WeightButton.Font.Color:=clBlack;
  FindOptimalRout;
  PBProgress.Position:=0;
  STPB.Caption:=''
end;

{=======================================================================}
procedure TfrmGL.WeightButtonClick(Sender: TObject);
var Str:string;
begin
    if vError=0 then
  begin
    Str:='Cancel для отмены,Ok для продолжения';
    if not InputQuery('Внимание','Не выбраны концевые вершины!',Str) then
    exit
  end;
  alg:=Weight;
  WeightButton.Font.Color:=clRed;
  PointButton.Font.Color:=clBlack;
  FindOptimalRout;
  PBProgress.Position:=0;
  STPB.Caption:=''
end;

{=======================================================================}
procedure TfrmGL.ClearButtonClick(Sender: TObject);
begin
  min_link_weight := 100;
  vError:=0;
  SelectPoint1:=nil;
  SelectPoint2:=nil;
  Selected:=nil;
  RoutsList.Free;
  RoutsList:=TList.Create;
  MegaList.Free;
  MegaList:=TList.Create;
  OptimalList_Point.Free;
  OptimalList_Weight.Free;
  OptimalList_Point:=TList.Create;
  OptimalList_Weight:=TList.Create;

  count:=0;
  SelectPoint1:=nil;
  SelectPoint2:=nil;
  Selected:=nil;
  
  InvalidateRect(Handle, nil, False)
end;

{=======================================================================}
procedure TfrmGL.DeleteButtonClick(Sender: TObject);
begin
 min_link_weight := 100;
 vError:=0;
 DeleteCurrentPoint;
 SelectPoint1:=nil;
 SelectPoint2:=nil;
 Selected:=nil 
end;

{=======================================================================}
procedure TfrmGL.CloseButtonClick(Sender: TObject);
var i:integer;
begin
  for i:=0 to dcrHelp.count+1 do
  PostMessage(dcrHelp.Wind[i],WM_ClOSE,0,0);
  PostMessage(Handle, WM_CLOSE, 0, 0);
  PostMessage(StartForm.Handle, WM_CLOSE, 0, 0)
end;

{=======================================================================}
procedure TfrmGL.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
i : Integer;
begin
Vis:=true;
PanelMove(Panel1, true)
end;

{=====================================================================
 Генерация случайного графа с заданными параметрами.
=====================================================================}
procedure TfrmGL.SBRandomClick(Sender: TObject);
var
i_max, i, j, k : ShortInt;
sum:Integer;
begin
sum:=0;
vError:=0;
Enabled:=false;
Randomize;
if cRandom then
  i_max:=random(QuanPoints)
else
  begin
    i_max:=QuanPoints-1;
    QuanLinks:=QuanPoints
  end;
ClearButtonClick(Sender);
for i:=0 to i_max do
begin
Self.FormMouseDown(Sender,mbLeft,[ssLeft],koord_random[2*i],koord_random[2*i+1]);
Self.FormMouseUp(Sender,mbLeft,[ssLeft],koord_random[2*i],koord_random[2*i+1])
end;
 for i:=0 to i_max do
   for j:=i+1 to i_max do
    begin
     if (random(2)=1)OR(random(3)=2)OR(not cRandom) then
      begin
       BeginPoint := pGraphPoint(MegaList[j]);
       EndPoint := pGraphPoint(MegaList[i]);
       k:=random(101);
       if random(k div 10 +1)=1 then k:=-k;;
       if (BeginPoint.links_list.Count<=QuanLinks)AND
                           (EndPoint.links_list.Count<QuanLinks)then
       begin
       BeginPoint.AddLink(EndPoint, k);
       EndPoint.AddLink(BeginPoint, k);
       inc(Sum,k);
       if k<min_link_weight then min_link_weight := k
       end
      end
    end;
    ShowMessage(IntToStr(min_link_weight));
    Enabled:=true
end;

{=====================================================================
 Установка параметров графа.
=====================================================================}
procedure TfrmGL.Panel1DblClick(Sender: TObject);
begin
Self.Visible:=false;
 StartForm.Show;
end;

{=====================================================================
 Справка по программе.
=====================================================================}
procedure TfrmGL.SBHelpClick(Sender: TObject);
begin
 if Self.dcrHelp.count = 2 then
 begin
   Self.dcrHelp.Wind[0]:=Self.dcrHelp.Wind[Self.dcrHelp.count-1];
   Self.dcrHelp.count:=1
 end;
 if CloseWindow(Self.dcrHelp.Wind[Self.dcrHelp.count-1])<>false then exit;
 ShellExecute(Self.Handle,nil,'Help.mht',nil,nil,SW_SHOWNORMAL);
 Self.dcrHelp.Wind[Self.dcrHelp.count]:=GetForegroundWindow;
 inc(Self.dcrHelp.count);
end;

procedure TfrmGL.tmPanelTimer(Sender: TObject);
begin
 if not Vis then PanelMove(Panel1, false)
end;

end.
