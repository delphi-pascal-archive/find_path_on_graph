unit Enter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, main;

type
  TFormEnter = class(TForm)
    bOK: TButton;
    bDel: TButton;
    MEweight: TMaskEdit;
    procedure bOKClick(Sender: TObject);
    procedure bDelClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure MEweightKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEnter: TFormEnter;

implementation

{$R *.dfm}

procedure TFormEnter.bOKClick(Sender: TObject);
var
 Weight : ShortInt;
 E : Integer;
begin
  Val(MEweight.Text, Weight, E);
  if(E <> 0)OR(abs(Weight)>100) then
  begin
  MessageBox(0,'Weight of arc is wrong set!'+#13+
                'Weight must be an integer, mattering on the module not more than 100!',
                                                                     'Error',MB_ICONERROR);
  exit
  end;
  frmGL.SetWeight(Weight);
  frmGL.SetDeleteLink(false);
  Close;
end;

procedure TFormEnter.bDelClick(Sender: TObject);
begin
 frmGL.SetDeleteLink(true);
 Close;
end;

procedure TFormEnter.FormActivate(Sender: TObject);
begin
 FormEnter.MEweight.Text := IntToStr(frmGL.GetWeight);
end;

procedure TFormEnter.MEweightKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 If Key = VK_RETURN then
   FormEnter.bOkClick(Sender)
end;

end.
