unit ZDbcRESTDW;

interface

{$I ZDbc.inc}

{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit
uses
  {$IFDEF MSEgui}mclasses,{$ENDIF}
  Classes, SysUtils,
  ZDbcIntfs, ZDbcLogging, ZTokenizer, ZPlainDriver, ZGenericSqlAnalyser,
  ZCompatibility, ZPlainRESTDWDriver, ZDbcConnection, ZURL,
  uRESTDWBasicDB;

type
  TZRESTDWDriver = class(TZAbstractDriver)
  private
    FDatabase : TRESTDWDatabasebaseBase;
  public
    constructor Create; override;
    function Connect(const Url: TZURL): IZConnection; override;
    function GetMajorVersion: Integer; override;
    function GetMinorVersion: Integer; override;

    function GetTokenizer: IZTokenizer; override;
    function GetStatementAnalyser: IZStatementAnalyser; override;

    property Database : TRESTDWDatabasebaseBase read FDatabase write FDatabase;
  end;

  IZRESTDWConnection = interface (IZConnection)
    ['{A4B797A9-7CF7-4DE9-A5BB-693DD32D07D3}']
    function GetPlainDriver: IZPlainDriver;
  end;

  TZRESTDWConnection = class(TZAbstractSingleTxnConnection, IZConnection,
       IZRESTDWConnection, IZTransaction)
  private
    FCatalog: string;
    FPlainDriver: TZRESTDWPlainDriver;
    FDatabase : TRESTDWDatabasebaseBase;
  protected
    procedure InternalClose; override;
  public
    function GetPlainDriver: IZPlainDriver;

    procedure Commit;
    procedure Rollback;
    function StartTransaction: Integer;

    function CreateStatementWithParams(Info: TStrings): IZStatement;
    function PrepareStatementWithParams(const SQL: string; Info: TStrings):
      IZPreparedStatement;
    function PrepareCallWithParams(const Name: String; Params: TStrings):
      IZCallableStatement;

    function GetTokenizer: IZTokenizer;
    function GetStatementAnalyser: IZStatementAnalyser;

    function GetServerProvider: TZServerProvider; override;
    procedure AfterConstruction; override;

    procedure Open; override;
  end;

var
  RDWDriver: IZDriver;

{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit
implementation
{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit

uses
  ZSysUtils, ZFastCode, ZEncoding, ZMessages, ZDbcRESTDWStatement,
  ZRESTDWToken, ZRESTDWAnalyser, ZExceptions, ZDbcRESTDWMetadata
  {$IFDEF WITH_UNITANSISTRINGS}, AnsiStrings{$ENDIF};

{ TZRESTDWDriver }

constructor TZRESTDWDriver.Create;
begin
  inherited Create;
  AddSupportedProtocol(AddPlainDriverToCache(TZRESTDWPlainDriver.Create, 'restdw'));
end;

function TZRESTDWDriver.GetMajorVersion: Integer;
begin
  Result := 1;
end;

function TZRESTDWDriver.GetMinorVersion: Integer;
begin
  Result := 0;
end;

function TZRESTDWDriver.GetStatementAnalyser: IZStatementAnalyser;
begin
  Result := TZRESTDWStatementAnalyser.Create;
end;

function TZRESTDWDriver.GetTokenizer: IZTokenizer;
begin
  Result := TZRESTDWTokenizer.Create;
end;

function TZRESTDWDriver.Connect(const Url: TZURL): IZConnection;
begin
  Result := TZRESTDWConnection.Create(Url);
end;

{ TZRESTDWConnection }

procedure TZRESTDWConnection.AfterConstruction;
begin
  FPlainDriver := PlainDriver.GetInstance as TZRESTDWPlainDriver;
  FMetadata := TZRESTDWDatabaseMetadata.Create(Self, Url);
  inherited AfterConstruction;
end;

procedure TZRESTDWConnection.Commit;
begin

end;

function TZRESTDWConnection.CreateStatementWithParams(Info: TStrings): IZStatement;
begin
  if IsClosed then
    Open;

  Result := TZRESTDWStatement.Create(Self, Info);
end;

function TZRESTDWConnection.GetPlainDriver: IZPlainDriver;
begin
  Result := FPlainDriver;
end;

function TZRESTDWConnection.GetServerProvider: TZServerProvider;
begin
  Result := spUnknown;
end;

function TZRESTDWConnection.GetStatementAnalyser: IZStatementAnalyser;
begin
  Result := TZRESTDWStatementAnalyser.Create;
end;

function TZRESTDWConnection.GetTokenizer: IZTokenizer;
begin
  Result := TZRESTDWTokenizer.Create;
end;

procedure TZRESTDWConnection.InternalClose;
begin
  if FDatabase <> nil then
    FDatabase.Close;
  FDatabase := nil;
  inherited;
end;

procedure TZRESTDWConnection.Open;
begin
  FDatabase := TZRESTDWDriver(GetDriver).Database;
  if FDatabase = nil then
    raise Exception.Create('Error Message');

  FDatabase.Open;
  inherited;
end;

function TZRESTDWConnection.PrepareCallWithParams(const Name: String;
  Params: TStrings): IZCallableStatement;
begin
  Raise EZUnsupportedException.Create(SUnsupportedOperation);
end;

function TZRESTDWConnection.PrepareStatementWithParams(const SQL: string;
  Info: TStrings): IZPreparedStatement;
begin
  if IsClosed then
    Open;
  Result := TZRESTDWPreparedStatement.Create(Self, SQL, Info);
end;

procedure TZRESTDWConnection.Rollback;
begin

end;

function TZRESTDWConnection.StartTransaction: Integer;
begin

end;

initialization
  RDWDriver := TZRESTDWDriver.Create;
  DriverManager.RegisterDriver(RDWDriver);

finalization
  if DriverManager <> nil then
    DriverManager.DeregisterDriver(RDWDriver);
  RDWDriver := nil;

{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit

end.
