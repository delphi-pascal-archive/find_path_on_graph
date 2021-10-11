unit List_Func;

interface
uses Classes, OpenGL;
procedure   MyInit;
procedure OutText (Litera : PChar);
procedure MaterialNormal;
procedure MaterialSelect;
procedure MaterialMoveSelect;
procedure MaterialOptima;
procedure MaterialOptimaLink;
procedure MaterialSelectLink;
procedure ListCopy(var SourceList, ResList: TList);
const
    no_mat              : array[0..3] of GLfloat = ( 0.0, 0.0, 0.0, 1.0 );
    mat_ambient         : array[0..3] of GLfloat = ( 0.7, 0.7, 0.7, 1.0 );
    mat_ambient_color   : array[0..3] of GLfloat = ( 0.8, 0.8, 0.2, 1.0 );
    mat_diffuse         : array[0..3] of GLfloat = ( 0.5, 0.5, 0.8, 1.0 );
    mat_specular        : array[0..3] of GLfloat = ( 1.0, 0.0, 1.0, 1.0 );
    no_shininess        : GLfloat =  0.0;
    low_shininess       : GLfloat =  5.0;
    high_shininess      : GLfloat =  100.0;
    mat_emission        : array[0..3] of GLfloat = ( 0.3, 0.2, 0.2, 0.0 );

    GLF_START_LIST = 10000;

implementation
uses DGlut;

{=====================================================================
  Инициализация OpenGL окна.
=====================================================================}
procedure   MyInit;
const
    position        : array[0..3] of GLfloat = ( 0.0, 3.0, 20.0, 0.0 );
    lmodel_ambient  : array[0..3] of GLfloat = ( 0.3, 0.3, 0.3, 1.0 );
begin
    glEnable(GL_DEPTH_TEST);

    glLightfv(GL_LIGHT0, GL_POSITION, @position);
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient);

    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);

    glClearColor(0.5, 0.5, 0.5, 0.0);
end;

{=====================================================================
  Вывод текста в OpenGL окне.
=====================================================================}
procedure OutText (Litera : PChar);
begin
  glListBase(GLF_START_LIST);
  glCallLists(Length(Litera), GL_UNSIGNED_BYTE, Litera);
end;

procedure MaterialNormal;
begin
   glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient_color);
   glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
   glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
   glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
   glMaterialfv(GL_FRONT, GL_EMISSION, @mat_emission);
end;

procedure MaterialSelect;
begin
   glMaterialfv(GL_FRONT, GL_AMBIENT, @no_mat);
   glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
   glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
   glMaterialfv(GL_FRONT, GL_SHININESS, @low_shininess);
   glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
end;

procedure MaterialMoveSelect;
begin
  glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient_color);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
  glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
  glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat)
end;

procedure MaterialOptima;
begin
  glMaterialfv(GL_FRONT, GL_AMBIENT, @no_mat);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
  glMaterialfv(GL_FRONT, GL_SHININESS, @high_shininess);
  glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat)
end;

procedure MaterialOptimaLink;
const
 color: array[0..3] of GLfloat = ( 1.0, 0.0, 0.0, 1.0 );
begin
  glMaterialfv(GL_FRONT, GL_AMBIENT, @color);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
  glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
  glMaterialfv(GL_FRONT, GL_EMISSION, @mat_emission)
end;

procedure MaterialSelectLink;
const
 color: array[0..3] of GLfloat = ( 0.0, 1.0, 0.0, 1.0 );
begin
  glMaterialfv(GL_FRONT, GL_AMBIENT, @color);
  glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
  glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
  glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
  glMaterialfv(GL_FRONT, GL_EMISSION, @mat_emission)
end;

{=====================================================================
  Копирование списка поэлементно.
=====================================================================}
procedure ListCopy(var SourceList, ResList: TList);
var
i: Integer;
begin
 ResList.Free;
 ResList:=TList.Create;
  for i:=0 to SourceList.Count-1 do
    ResList.Add(SourceList[i])
end;


end.
 