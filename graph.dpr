program graph;
//Из Project-Options удалены пакеты <<Intraweb_50_70;>>,<<IntrawebDB_50_70;>>,<<vclshlctrls;>>,
//<<vclactnband;>>,<<inetdbxpress;>>,<<indy;>>,<<inet;xmlrtl;>>,<<inetdbbde;>>,<<dbrtl;>>,
//<<vclx;vclie;dsnap;dsnapcon;vcldb;soaprtl;VclSmp;dbexpress;dbxcds;inetdb;bdertl;vcldbx;>>,
//<<webdsnap;websnap;adortl;ibxpress;teeui;teedb;tee;dss;visualclx;visualdbclx;>>,<<rtl;>>

uses
  Forms,
  main in 'main.pas' {frmGL},
  Enter in 'Enter.pas' {FormEnter},
  UStart in 'UStart.pas' {StartForm},
  List_Func in 'List_Func.pas',
  Classes_Graph in 'Classes_Graph.pas',
  Thread in 'Thread.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGL, frmGL);
  Application.CreateForm(TStartForm, StartForm);
  Application.CreateForm(TFormEnter, FormEnter);
  StartForm.ShowModal;
  Application.Run;
end.

