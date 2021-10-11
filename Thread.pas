unit Thread;

interface

uses
  Classes, Windows, Classes_Graph;

type
  TFind = class(TThread)
  private
    Select : pGraphPoint;
    PathList : TList;
    procedure SetName;
  protected
    procedure Execute; override;
  public
    procedure Init(SelectPoint1: PGraphPoint);
    procedure Destrict;
  end;

implementation

type
  TThreadNameInfo = record
    FType: LongWord;
    FName: PChar;
    FThreadID: LongWord;
    FFlags: LongWord;
  end;

procedure TFind.SetName;
var
  ThreadNameInfo: TThreadNameInfo;
begin
  ThreadNameInfo.FType := $1023;
  ThreadNameInfo.FName := 'MinPath';
  ThreadNameInfo.FThreadID := $FFFFFFFF;
  ThreadNameInfo.FFlags := 0;

  try
    RaiseException( $406D1388, 0, sizeof(ThreadNameInfo) div sizeof(LongWord), @ThreadNameInfo );
  except
  end
end;

procedure TFind.Init(SelectPoint1: PGraphPoint);
begin
  PathList := TList.Create;
  Select := pGraphPoint(SelectPoint1);
  Self.Execute
end;

procedure TFind.Destrict;
begin
   PathList.Free;
   Self.Free
end;

procedure TFind.Execute;
begin
  SetName;
  Select.OptimalRout(PathList);
  FindOptimalRout
end;

end.
 