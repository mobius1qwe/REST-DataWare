unit uRESTDWZeosDriver;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}
{$IFNDEF FPC}{$I ZComponent.inc}{$ENDIF}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

interface

uses
  {$IFDEF FPC}
    LResources,
  {$ENDIF}

  {$IFDEF ZMEMTABLE_ENABLE_STREAM_EXPORT_IMPORT}
    ZMemTable,
  {$ELSE}
    uRESTDWMemoryDataset,
  {$ENDIF}
  Classes, SysUtils, DB,
  ZConnection, ZDataset, ZSequence, ZDbcIntfs, ZAbstractRODataset,
  ZAbstractDataset, ZStoredProcedure, ZEncoding, ZDatasetUtils,
  uRESTDWDriverBase, uRESTDWBasicTypes, uRESTDWProtoTypes
  {$IFNDEF FPC}
//  , uRESTDWZeosPhysLink
  {$ENDIF}
  ;

const
  rdwZeosProtocols : array[0..16] of string = (('ado'),('asa'),('asa_capi'),
                    ('firebird'),('interbase'),('mssql'),('mysql'),('odbc_a'),
                    ('odbc_w'),('oledb'),('oracle'),('pooled'),('postgresql'),
                    ('sqlite'),('sybase'),('webserviceproxy'),('mariadb'));

  rdwZeosDbType : array[0..16] of TRESTDWDatabaseType = ((dbtAdo),(dbtUndefined),
                 (dbtUndefined),(dbtFirebird),(dbtInterbase),(dbtMsSQL),(dbtMySQL),
                 (dbtODBC),(dbtODBC),(dbtUndefined),(dbtOracle),(dbtUndefined),
                 (dbtPostgreSQL),(dbtSQLLite),(dbtUndefined),(dbtUndefined),
                 (dbtMySQL));

type
  { TRESTDWZeosStoreProc }

  TRESTDWZeosStoreProc = class(TRESTDWDrvStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  TRESTDWZeosTable = class(TRESTDWDrvTable)
  public
    procedure SaveToStream(stream : TStream); override;
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
    procedure FetchAll; override;
  end;

  { TRESTDWZeosQuery }

  TRESTDWZeosQuery = class(TRESTDWDrvQuery)
  private
    FSequence : TZSequence;
  protected
    procedure createSequencedField(seqname, field : string); override;
  public
    procedure SaveToStream(stream : TStream); override;
    procedure ExecSQL; override;
    procedure Prepare; override;
    procedure FetchAll; override;

    destructor Destroy; override;

    function  RowsAffected : Int64; override;
    function  ParamCount : Integer; override;

    function  getParamDataType(IParam : integer) : TFieldType; override;
    function  getParamName(IParam : integer) : string; override;
    function  getParamSize(IParam : integer) : integer; override;
    function  getParamValue(IParam : integer) : variant; override;

    procedure setParamDataType(IParam : integer; AValue : TFieldType); override;
    procedure setParamValue(IParam : integer; AValue : variant); override;

    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
  end;

  { TRESTDWZeosDriver }

  TRESTDWZeosDriver = class(TRESTDWDriverBase)
  private
  protected
    procedure setConnection(AValue: TComponent); override;

    function getConectionType : TRESTDWDatabaseType; override;
    Function compConnIsValid(comp : TComponent) : boolean; override;
    Procedure zAfterPost(DataSet: TDataSet);
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    function getQuery : TRESTDWDrvQuery; override;
    function getTable : TRESTDWDrvTable; override;
    function getStoreProc : TRESTDWDrvStoreProc; override;

    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;
    function connInTransaction : boolean; override;
    procedure connStartTransaction; override;
    procedure connRollback; override;
    procedure connCommit; override;

    class procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                     var AConnection : TComponent); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWZeosDriver]);
  {$IFNDEF FPC}
//  RegisterComponents('REST Dataware - PhysLink', [TRESTDWZeosPhysLink]);
  {$ENDIF}
end;

{ TRESTDWZeosStoreProc }

procedure TRESTDWZeosStoreProc.ExecProc;
var
  qry : TZStoredProc;
begin
  qry := TZStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWZeosStoreProc.Prepare;
var
  qry : TZStoredProc;
begin
  qry := TZStoredProc(Self.Owner);
  qry.Prepare;
end;

{ TRESTDWZeosDriver }

procedure TRESTDWZeosDriver.setConnection(AValue: TComponent);
begin
  inherited setConnection(AValue);
end;

function TRESTDWZeosDriver.getConectionType: TRESTDWDatabaseType;
var
  prot : string;
  i : integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  prot := LowerCase(TZConnection(Connection).Protocol);

  i := 0;
  while i < Length(rdwZeosProtocols) do begin
    if Pos(rdwZeosProtocols[i],prot) > 0 then begin
      Result := rdwZeosDbType[i];
      Break;
    end;
    i := i + 1;
  end;
end;

destructor TRESTDWZeosDriver.Destroy;
begin
  inherited Destroy;
end;

Procedure TRESTDWZeosDriver.zAfterPost(DataSet: TDataSet);
Begin
// TZQuery(DataSet).RefreshCurrentRow(True);
End;

function TRESTDWZeosDriver.getQuery: TRESTDWDrvQuery;
var
  qry : TZQuery;
begin
  qry := TZQuery.Create(Self);
  qry.Connection := TZConnection(Connection);
  {$IFNDEF FPC}
   qry.AfterPost := zAfterPost;
  {$ELSE}
   qry.AfterPost := @zAfterPost;
  {$ENDIF}
  Result := TRESTDWZeosQuery.Create(qry);
end;

function TRESTDWZeosDriver.getTable : TRESTDWDrvTable;
var
  qry : TZTable;
begin
  qry := TZTable.Create(Self);
  qry.Connection := TZConnection(Connection);
  Result := TRESTDWZeosTable.Create(qry);
end;

function TRESTDWZeosDriver.getStoreProc : TRESTDWDrvStoreProc;
var
  qry : TZStoredProc;
begin
  qry := TZStoredProc.Create(Self);
  qry.Connection := TZConnection(Connection);
  Result := TRESTDWZeosStoreProc.Create(qry);
end;

procedure TRESTDWZeosDriver.Connect;
begin
  if Assigned(Connection) and (not TZConnection(Connection).Connected) then
   TZConnection(Connection).Connected := True;
  inherited Connect;
end;

procedure TRESTDWZeosDriver.Disconect;
begin
  if Assigned(Connection) and (TZConnection(Connection).Connected) then
    TZConnection(Connection).Connected := False;
  inherited Disconect;
end;

function TRESTDWZeosDriver.isConnected: boolean;
begin
  Result := inherited isConnected;
  if Assigned(Connection) then
    Result := TZConnection(Connection).Connected;
end;

function TRESTDWZeosDriver.connInTransaction: boolean;
begin
  Result := inherited connInTransaction;
  if Assigned(Connection) and (not TZConnection(Connection).AutoCommit) then
    Result := TZConnection(Connection).InTransaction;
end;

procedure TRESTDWZeosDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) and (not TZConnection(Connection).AutoCommit) then
    TZConnection(Connection).StartTransaction;
end;

procedure TRESTDWZeosDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) and (not TZConnection(Connection).AutoCommit) then
    TZConnection(Connection).Rollback;
end;

function TRESTDWZeosDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TZConnection)
end;

procedure TRESTDWZeosDriver.connCommit;
begin
  if TZConnection(Connection).AutoCommit then
    TZConnection(Connection).Commit;
end;

constructor TRESTDWZeosDriver.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

class procedure TRESTDWZeosDriver.CreateConnection(
  const AConnectionDefs: TConnectionDefs; var AConnection: TComponent);
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  if Assigned(AConnectionDefs) then begin
    case AConnectionDefs.DriverType Of
      dbtUndefined  : TZConnection(AConnection).Protocol := '';
      dbtAccess     : TZConnection(AConnection).Protocol := '';
      dbtDbase      : TZConnection(AConnection).Protocol := '';
      dbtParadox    : TZConnection(AConnection).Protocol := '';
      dbtFirebird   : TZConnection(AConnection).Protocol := 'firebird';
      dbtInterbase  : TZConnection(AConnection).Protocol := 'interbase';
      dbtMySQL      : TZConnection(AConnection).Protocol := 'mysql';
      dbtSQLLite    : TZConnection(AConnection).Protocol := 'sqlite';
      dbtOracle     : TZConnection(AConnection).Protocol := 'oracle';
      dbtMsSQL      : TZConnection(AConnection).Protocol := 'mssql';
      dbtODBC       : TZConnection(AConnection).Protocol := 'odbc_a';
      dbtPostgreSQL : TZConnection(AConnection).Protocol := 'postgresql';
      dbtAdo        : TZConnection(AConnection).Protocol := 'ado';
    end;
  end;

  with TZConnection(AConnection) do begin
    HostName := AConnectionDefs.HostName;
    Database := AConnectionDefs.DatabaseName;
    User     := AConnectionDefs.Username;
    Password := AConnectionDefs.Password;
    Port     := AConnectionDefs.DBPort;
  end;
end;

{ TRESTDWZeosQuery }

procedure TRESTDWZeosQuery.createSequencedField(seqname, field : string);
var
  qry : TZQuery;
begin
  if Trim(seqname) = '' then
    Exit;

  if FSequence = nil then
    FSequence := TZSequence.Create(Self);

  qry := TZQuery(Self.Owner);

  FSequence.SequenceName := seqname;

  qry.Sequence := FSequence;
  qry.SequenceField := field;
end;

procedure TRESTDWZeosQuery.ExecSQL;
var
  qry : TZQuery;
begin
  qry := TZQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWZeosQuery.FetchAll;
var
  qry : TZTable;
begin
  qry := TZTable(Self.Owner);
  qry.FetchAll;
end;

procedure TRESTDWZeosQuery.LoadFromStreamParam(IParam: integer; stream: TStream;
  blobtype: TBlobType);
var
  qry : TZQuery;
  {$IFDEF ZEOS80UP}
    cp : Word;
  {$ENDIF}
begin
  qry := TZQuery(Self.Owner);
  {$IFDEF ZEOS80UP}
    if BlobType in [ftWideString{$IFDEF WITH_WIDEMEMO}, ftFixedWideChar, ftWideMemo{$ENDIF}] then
      qry.Params[IParam].LoadTextFromStream(Stream, zCP_UTF16)
    else if BlobType in [ftBlob, ftGraphic, ftTypedBinary, ftOraBlob] then
      qry.Params[IParam].LoadBinaryFromStream(Stream)
    else if BlobType in [ftMemo, ftParadoxOle, ftDBaseOle, ftOraClob] then begin
      cp := qry.Connection.RawCharacterTransliterateOptions.GetRawTransliterateCodePage(ttParam);
      qry.Params[IParam].LoadTextFromStream(Stream, cp);
    end;
  {$ELSE}
    qry.Params[IParam].LoadFromStream(stream,blobtype);
  {$ENDIF}
end;

procedure TRESTDWZeosQuery.Prepare;
var
  qry : TZQuery;
begin
  inherited Prepare;
  qry := TZQuery(Self.Owner);
  qry.Prepare;
end;

destructor TRESTDWZeosQuery.Destroy;
begin
  if FSequence <> nil then
    FreeAndNil(FSequence);
  inherited Destroy;
end;

function TRESTDWZeosQuery.RowsAffected: Int64;
var
  qry : TZQuery;
begin
  qry := TZQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

function TRESTDWZeosQuery.ParamCount : Integer;
var
  qry : TZQuery;
begin
  qry := TZQuery(Self.Owner);
  Result := qry.Params.Count;
end;

function TRESTDWZeosQuery.getParamDataType(IParam : integer) : TFieldType;
var
  qry : TZQuery;
begin
  qry := TZQuery(Self.Owner);
  Result := qry.Params[IParam].DataType;
end;

function TRESTDWZeosQuery.getParamName(IParam : integer) : string;
var
  qry : TZQuery;
begin
  qry := TZQuery(Self.Owner);
  Result := qry.Params[IParam].Name;
end;

function TRESTDWZeosQuery.getParamSize(IParam : integer) : integer;
var
  qry : TZQuery;
begin
  qry := TZQuery(Self.Owner);
  Result := qry.Params[IParam].Size;
end;

function TRESTDWZeosQuery.getParamValue(IParam : integer) : variant;
var
  qry : TZQuery;
begin
  qry := TZQuery(Self.Owner);
  Result := qry.Params[IParam].Value;
end;

procedure TRESTDWZeosQuery.setParamDataType(IParam : integer; AValue : TFieldType);
var
  qry : TZQuery;
begin
  qry := TZQuery(Self.Owner);
  qry.Params[IParam].DataType := AValue;
end;

procedure TRESTDWZeosQuery.setParamValue(IParam : integer; AValue : variant);
var
  qry : TZQuery;
begin
  qry := TZQuery(Self.Owner);
  qry.Params[IParam].Value := AValue;
end;

procedure TRESTDWZeosQuery.SaveToStream(stream: TStream);
var
  qry : TZQuery;
  {$IFDEF ZMEMTABLE_ENABLE_STREAM_EXPORT_IMPORT}
    memtable : TZMemTable;
  {$ELSE}
    memtable : TRESTDWMemtable;
  {$ENDIF}
begin
  qry := TZQuery(Self.Owner);
  {$IFDEF ZMEMTABLE_ENABLE_STREAM_EXPORT_IMPORT}
    memtable := TZMemTable.Create(nil);
  {$ELSE}
    memtable := TRESTDWMemtable.Create(nil);
  {$ENDIF}
  try
    {$IFDEF ZMEMTABLE_ENABLE_STREAM_EXPORT_IMPORT}
      memtable.AssignDataFrom(qry);
    {$ELSE}
      memtable.Assign(qry);
    {$ENDIF}
    // TODO -oXyberX -cMemTable: Função SaveToStream não existe no TRESTDWMemtable
//    memtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(memtable);
  end;
end;

{ TRESTDWZeosTable }

procedure TRESTDWZeosTable.FetchAll;
var
  qry : TZTable;
begin
  qry := TZTable(Self.Owner);
  qry.FetchAll;
end;

procedure TRESTDWZeosTable.LoadFromStreamParam(IParam: integer; stream: TStream;
  blobtype: TBlobType);
var
  qry : TZTable;
  pname : string;
  cp : Word;
begin
  pname := Self.Params[IParam].Name;
  qry := TZTable(Self.Owner);
  {$IFDEF ZEOS80UP}
    if BlobType in [ftWideString{$IFDEF WITH_WIDEMEMO}, ftFixedWideChar, ftWideMemo{$ENDIF}] then
      qry.ParamByName(pname).LoadTextFromStream(Stream, zCP_UTF16)
    else if BlobType in [ftBlob, ftGraphic, ftTypedBinary, ftOraBlob] then
      qry.ParamByName(pname).LoadBinaryFromStream(Stream)
    else if BlobType in [ftMemo, ftParadoxOle, ftDBaseOle, ftOraClob] then begin
      cp := qry.Connection.RawCharacterTransliterateOptions.GetRawTransliterateCodePage(ttParam);
      qry.ParamByName(pname).LoadTextFromStream(Stream, cp);
    end;
  {$ELSE}
    qry.ParamByName(pname).LoadFromStream(stream,blobtype);
  {$ENDIF}
end;

procedure TRESTDWZeosTable.SaveToStream(stream: TStream);
var
  qry : TZTable;
  {$IFDEF ZMEMTABLE_ENABLE_STREAM_EXPORT_IMPORT}
    memtable : TZMemTable;
  {$ELSE}
    memtable : TRESTDWMemtable;
  {$ENDIF}
begin
  qry := TZTable(Self.Owner);
  {$IFDEF ZMEMTABLE_ENABLE_STREAM_EXPORT_IMPORT}
    memtable := TZMemTable.Create(nil);
  {$ELSE}
    memtable := TRESTDWMemtable.Create(nil);
  {$ENDIF}
  try
    {$IFDEF ZMEMTABLE_ENABLE_STREAM_EXPORT_IMPORT}
      memtable.AssignDataFrom(qry);
    {$ELSE}
      memtable.Assign(qry);
    {$ENDIF}
    // TODO -oXyberX -cMemTable: Função SaveToStream não existe no TRESTDWMemtable
//    memtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(memtable);
  end;
end;

{$IFDEF FPC}
initialization
{$I ..\RESTDWLazarusDrivers.lrs}
{$ENDIF}

end.

