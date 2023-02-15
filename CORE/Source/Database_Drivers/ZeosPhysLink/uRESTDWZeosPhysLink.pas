unit uRESTDWZeosPhysLink;

interface

uses
  Classes, SysUtils, ZConnection, uRESTDWAbout, uRESTDWBasicDB,
  ZDbcRESTDW;

type
  TRESTDWZeosPhysLink = class(TRESTDWComponent)
  private
    FZConnection : TZConnection;
    FDatabase : TRESTDWDatabasebaseBase;
    FOldZeosBeforeConnect : TNotifyEvent;
    procedure setZConnection(const Value: TZConnection);
  protected
    procedure OnRESTDWZeosBeforeConnect(Sender : TObject);
  published
    property ZConnection : TZConnection read FZConnection write setZConnection;
    property Database : TRESTDWDatabasebaseBase read FDatabase write FDatabase;
  end;

implementation

{ TRESTDWZeosPhysLink }

procedure TRESTDWZeosPhysLink.OnRESTDWZeosBeforeConnect(Sender: TObject);
begin
  if Assigned(FOldZeosBeforeConnect) then
    FOldZeosBeforeConnect(FZConnection);
  TZRESTDWDriver(FZConnection.DbcDriver).Database := FDatabase;
end;

procedure TRESTDWZeosPhysLink.setZConnection(const Value: TZConnection);
begin
  FZConnection := Value;
  if FZConnection <> nil then begin
    FOldZeosBeforeConnect := FZConnection.BeforeConnect;
    FZConnection.BeforeConnect := OnRESTDWZeosBeforeConnect;
  end;
end;

end.
