unit UStart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, main, Mask, Classes_Graph, ComCtrls;

type
  TStartForm = class(TForm)
    pointCB: TComboBox;
    linkCB: TComboBox;
    ST1: TStaticText;
    ST2: TStaticText;
    OkButton: TButton;
    ExitButton: TButton;
    cbRandom: TCheckBox;
    CBMemory: TCheckBox;
    ST3: TStaticText;
    METime: TMaskEdit;
    TB: TTrackBar;
    procedure ExitButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure cbRandomClick(Sender: TObject);
    procedure CBMemoryClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StartForm: TStartForm;
  Rep: Integer;

implementation

{$R *.dfm}

procedure TStartForm.ExitButtonClick(Sender: TObject);
begin
halt
end;

procedure TStartForm.FormCreate(Sender: TObject);
begin
QuanPoints:=10;
QuanLinks:=4;
end;

procedure TStartForm.OkButtonClick(Sender: TObject);
var Temp: Integer;
begin
Rep:=TB.Position;
if (METime.Text='  ')AND(METime.Visible) then
begin
 ShowMessage('No input data of Time of process!');
 exit
end;
if(pointCB.Text<>'Default(10)')then
Val(pointCB.Text,QuanPoints,Temp)
else QuanPoints:=10;
if(linkCB.Text<>'Default(4)')then
Val(linkCB.Text,QuanLinks,Temp)
else QuanLinks:=4;
cRandom:=CBRandom.Checked;
cMemory:=CBMemory.Checked;
if METime.Visible then Val(METime.Text,time_of_operation,Temp);
if METime.Text='' then
 begin
   METime.EditText:='111';
   time_of_operation:=111
 end;
Self.Hide;
frmGL.Visible:=true
end;

procedure TStartForm.cbRandomClick(Sender: TObject);
begin
  linkCB.Enabled:=CBRandom.Checked;
  if CBRandom.Checked then CBRandom.Font.Color:=clLime
  else CBRandom.Font.Color:=clWindowText
end;

procedure TStartForm.CBMemoryClick(Sender: TObject);
begin
  OkButton.Enabled:=false;
  Sleep(500);
  METime.Visible:=CBMemory.Checked;
  ST3.Visible:=CBMemory.Checked;
  if CBMemory.Checked then CBMemory.Font.Color:=clRed
  else CBMemory.Font.Color:=clWindowText;
  OkButton.Enabled:=true
end;

end.
