unit uRESTDWDriverBase;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

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

Interface

Uses
  Classes, SysUtils, TypInfo, DB, Variants, StrUtils,
  uRESTDWMemoryDataset, uRESTDWParams, uRESTDWAbout, uRESTDWComponentEvents,
  uRESTDWJSONInterface, uRESTDWBufferBase, uRESTDWConsts, uRESTDWDataModule,
  uRESTDWBasicTypes, uRESTDWProtoTypes, uRESTDWTools, uRESTDWStorageBin,
  uRESTDWMassiveBuffer;

Type
  TRESTDWDatabaseInfo = Record
   rdwDatabaseName          : String;
   rdwDatabaseMajorVersion,
   rdwDatabaseMinorVersion,
   rdwDatabaseSubVersion    : Integer
 End;

 TRESTDWDrvDataset      = Class;

 TRDWDrvParam = class(TObject)
 private
   FIdxParam : integer;
   FDrvDataset : TRESTDWDrvDataset;
   function getAsLargeInt: int64;
   function getAsInteger: integer;
   function getAsSmallint: smallInt;
   function geAsInteger: integer;
   function getAsDateTime: TDateTime;
   function getAsFloat: Double;
   function getAsString: string;
   procedure setAsDate(const AValue: TDateTime);
   procedure setAsDateTime(const AValue: TDateTime);
   procedure setAsFloat(const AValue: Double);
   procedure setAsTime(const AValue: TDateTime);
   procedure setAsLargeInt(const AValue: int64);
   procedure setAsInteger(const AValue: integer);
   procedure setAsSmallint(const AValue: smallInt);
   procedure setAsString(const AValue: string);
 protected
   function getDataType: TFieldType;
   function getName: string;
   function getValue: Variant;
   function getSize: integer;
   procedure setDataType(const AValue: TFieldType);
   procedure setValue(const AValue: Variant);
 public
   procedure Clear;
   procedure LoadFromFile(const AFileName: String; ABlobType: TFieldType);
   procedure LoadFromStream(AStream: TStream; ABlobType: TFieldType);

   function  IsNull : boolean;
   function  RESTDWDataTypeParam : Byte;
 published
   property DataType : TFieldType read getDataType write setDataType;
   property Name     : string     read getName;
   property Value    : Variant    read getValue write setValue;
   property Size     : integer    read getSize;

   property AsLargeint : int64     read getAsLargeInt write setAsLargeInt;
   property AsSmallint : smallInt  read getAsSmallint write setAsSmallint;
   property AsInteger  : integer   read getAsInteger  write setAsInteger;
   property AsFloat    : Double    read getAsFloat    write setAsFloat;
   property AsDate     : TDateTime read getAsDateTime write setAsDate;
   property AsTime     : TDateTime read getAsDateTime write setAsTime;
   property AsDateTime : TDateTime read getAsDateTime write setAsDateTime;
   property AsString   : string    read getAsString   write setAsString;

   property IdxParam : integer read FIdxParam write FIdxParam;
   property DrvDataset : TRESTDWDrvDataset read FDrvDataset write FDrvDataset;
 end;

 TRESTDWDrvDataset      = Class(TComponent)
 private
  FParamsList : TStringList;
  FStorageDataType : TRESTDWStorageBase;
  function getRDWDrvParam(idx: integer): TRDWDrvParam;
 Protected
  Function  getFields                     : TFields; Virtual;
  Procedure CreateSequencedField(seqname,
                                 field    : String); Virtual;
 Public
  constructor Create(AOwner : TComponent); override;
  destructor Destroy; override;

  Procedure Close;    Virtual;
  Procedure Open;     Virtual;
  Procedure Insert;   Virtual;
  Procedure Edit;     Virtual;
  Procedure Post;     Virtual;
  Procedure Delete;   Virtual;
  Procedure Next;     Virtual;
  Procedure Prepare;  Virtual;
  Procedure ExecSQL;  Virtual;
  Procedure ExecProc; Virtual;
  Procedure FetchAll; Virtual;
  Procedure SaveToStream(stream : TStream); Virtual;
  Procedure SaveToStreamCompatibleMode(stream : TStream); Virtual;
  Procedure ImportParams(DWParams : TRESTDWParams);
  Function  Eof         : Boolean; Virtual;
  Function  RecNo       : Int64;   Virtual;
  Function  RecordCount : Int64;   Virtual;
  Function  ParamCount  : Integer; Virtual;
  Function  ParamByName(param : String) : TRDWDrvParam; Virtual;
  Function  FieldByName(field : String) : TField; Virtual;
  Function  FindField  (field : String) : TField; Virtual;
  Function  RESTDWDataTypeFieldName(field  : String) : Byte;    Virtual;
  Function  RESTDWDataTypeParamName(param  : String) : Byte;    Virtual;
  function  RESTDWDataTypeField(idx : integer) : Byte; virtual;
  function  RESTDWDataTypeParam(idx : integer) : Byte; virtual;
  Function  GetParamIndex(param  : String) : integer; Virtual;
  Function  RowsAffected : Int64;    Virtual;
  Function  GetInsertID  : int64;    Virtual;

  function getParamDataType(IParam : integer) : TFieldType; virtual;
  function getParamName(IParam : integer) : string; virtual;
  function getParamSize(IParam : integer) : integer; virtual;
  function getParamValue(IParam : integer) : variant; virtual;

  procedure setParamDataType(IParam : integer; AValue : TFieldType); virtual;
  procedure setParamValue(IParam : integer; AValue : variant); virtual;

  Procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); virtual;

  Property Params[idx : integer] : TRDWDrvParam read getRDWDrvParam;
  property StorageDataType : TRESTDWStorageBase read FStorageDataType write FStorageDataType;
 Published
  Property Fields : TFields Read getFields;
 End;
 { TRESTDWDrvStoreProc }
  TRESTDWDrvStoreProc = Class(TRESTDWDrvDataset)
 Protected
  Function  getStoredProcName        : String;
  Procedure setStoredProcName(AValue : String);
 Published
  Property StoredProcName : String Read getStoredProcName Write setStoredProcName;
 End;

 { TRESTDWDrvTable }
  TRESTDWDrvTable = Class(TRESTDWDrvDataset)
 Private
  Function getFilter            : String;   Virtual;
  Function getFiltered          : Boolean;  Virtual;
  Function getTableName         : String;   Virtual;
  Procedure setFilter   (AValue : String);  Virtual;
  Procedure setFiltered (AValue : Boolean); Virtual;
  Procedure setTableName(AValue : String);  Virtual;
 Public
 Published
  Property Filter    : String  Read getFilter    Write setFilter;
  Property Filtered  : Boolean Read getFiltered  Write setFiltered;
  Property TableName : String  Read getTableName Write setTableName;
 End;

  TRESTDWDrvQuery = Class(TRESTDWDrvDataset)
 Private
  Function getSQL       : TStrings; Virtual;
 Public
  Function  GetInsertID  : int64;    Virtual;
 Published
  Property SQL          : TStrings  Read getSQL;
 End;
  { TRESTDWDriverBase }
  TRESTDWDriverBase = Class(TRESTDWComponent)
 Private
  FConnection : TComponent;
  FServerMethod : TServerMethodDataModule;
  FStorageDataType : TRESTDWStorageBase;
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vEncodeStrings,
  vCompression         : Boolean;
  vEncoding            : TEncodeSelect;
  vCommitRecords       : Integer;
  {$IFDEF FPC}
   vDatabaseCharSet    : TDatabaseCharSet;
  {$ENDIF}
  vParamCreate         : Boolean;
  vOnPrepareConnection : TOnPrepareConnection;
  vOnTableBeforeOpen   : TOnTableBeforeOpen;
  vOnQueryBeforeOpen   : TOnQueryBeforeOpen;
  vOnQueryException    : TOnQueryException;
 Protected
  Procedure setConnection(AValue : TComponent); Virtual;
  Function  isConnected          : Boolean;     Virtual;
  Function  connInTransaction    : Boolean;     Virtual;
  Procedure connStartTransaction; Virtual;
  Procedure connRollback;         Virtual;
  Procedure connCommit;           Virtual;
  procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                   MassiveDataset        : TMassiveDatasetBuffer;
                                   Query                 : TDataset;
                                   MassiveCache : Boolean);
  procedure PrepareDataQuery(var Query: TRESTDWDrvQuery;
                             MassiveDataset: TMassiveDatasetBuffer;
                             Params : TRESTDWParams;
                             aMassiveCache        : boolean;
                             var ReflectionChanges : string;
                             var Error: boolean;
                             var MessageError: string);
  procedure SetUpdateBuffer(var Query : TRESTDWDrvQuery;
                            MassiveDataset : TMassiveDatasetBuffer;
                            IParam : integer; All: boolean = False);
  procedure PrepareDataTable(var Query: TRESTDWDrvTable;
                             MassiveDataset: TMassiveDatasetBuffer;
                             Params : TRESTDWParams;
                             aMassiveCache         : Boolean;
                             var ReflectionChanges : String;
                             var Error: boolean;
                             var MessageError: string);
  Function ApplyUpdates      (MassiveDataset        : TMassiveDatasetBuffer;
                              SQL                   : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var RowsAffected      : Integer)   : TJSONValue;Overload;Virtual;
  Function isMinimumVersion(major,
                            minor,
                            sub    : Integer) : Boolean; Overload;
  Function isMinimumVersion(major,
                            minor  : Integer) : Boolean; Overload;

  Function ApplyUpdates_MassiveCache  (MassiveDataset: TMassiveDatasetBuffer;
                                       Var Error        : Boolean;
                                       Var MessageError : String): String;Overload;
 Public
  constructor Create(AOwner : TComponent); override;
  destructor Destroy; override;

  Function compConnIsValid(comp : TComponent) : boolean; virtual;
  Function  getConectionType : TRESTDWDatabaseType; Virtual;
  Function  getDatabaseInfo  : TRESTDWDatabaseInfo; Virtual;
  Function  getQuery         : TRESTDWDrvQuery;   Virtual;
  Function  getTable         : TRESTDWDrvTable;   Virtual;
  Function  getStoreProc     : TRESTDWDrvStoreProc;   Virtual;
  Procedure Connect;                                Virtual;
  Procedure Disconect;                              Virtual;
  Function ConnectionSet    : Boolean;              Virtual;
  Function GetGenID          (Query                 : TRESTDWDrvQuery;
                              GenName               : String;
                              valor                 : Integer = 1) : Integer;Overload;Virtual;
  Function GetGenID          (GenName               : String;
                              valor                 : Integer = 1) : Integer;Overload;Virtual;
  Function ApplyUpdates      (MassiveStream         : TStream;
                              SQL                   : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var RowsAffected      : Integer)   : TJSONValue;Overload;Virtual;
  Function ApplyUpdates      (Massive,
                              SQL                   : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var RowsAffected      : Integer)   : TJSONValue;Overload;Virtual;
  Function ApplyUpdatesTB    (MassiveStream         : TStream;
                              SQL                   : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var RowsAffected      : Integer)   : TJSONValue;Overload;Virtual;
  Function ApplyUpdatesTB    (Massive               : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var RowsAffected      : Integer)   : TJSONValue;Overload;Virtual;
  Function ApplyUpdates_MassiveCache  (MassiveStream         : TStream;
                                       Var Error             : Boolean;
                                       Var MessageError      : String) : TJSONValue;Overload;Virtual;
  Function ApplyUpdates_MassiveCache  (MassiveCache          : String;
                                       Var Error             : Boolean;
                                       Var MessageError      : String) : TJSONValue;Overload;Virtual;
  Function ApplyUpdates_MassiveCacheTB(MassiveStream         : TStream;
                                       Var Error             : Boolean;
                                       Var MessageError      : String) : TJSONValue;Overload;Virtual;
  Function ApplyUpdates_MassiveCacheTB(MassiveCache          : String;
                                       Var Error             : Boolean;
                                       Var MessageError      : String) : TJSONValue;Overload;Virtual;
  Function ExecuteCommand     (SQL                   : String;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               Var RowsAffected      : Integer;
                               Execute               : Boolean = False;
                               BinaryEvent           : Boolean = False;
                               MetaData              : Boolean = False;
                               BinaryCompatibleMode  : Boolean = False) : String;Overload;Virtual;
  Function ExecuteCommand     (SQL                   : String;
                               Params                : TRESTDWParams;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               Var RowsAffected      : Integer;
                               Execute               : Boolean = False;
                               BinaryEvent           : Boolean = False;
                               MetaData              : Boolean = False;
                               BinaryCompatibleMode  : Boolean = False) : String;Overload;Virtual;
  Function ExecuteCommandTB   (Tablename             : String;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               Var RowsAffected      : Integer;
                               BinaryEvent           : Boolean = False;
                               MetaData              : Boolean = False;
                               BinaryCompatibleMode  : Boolean = False) : String; Overload;Virtual;
  Function ExecuteCommandTB   (Tablename             : String;
                               Params                : TRESTDWParams;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               Var RowsAffected      : Integer;
                               BinaryEvent           : Boolean = False;
                               MetaData              : Boolean = False;
                               BinaryCompatibleMode  : Boolean = False) : String; Overload;Virtual;
  Procedure ExecuteProcedure  (ProcName              : String;
                               Params                : TRESTDWParams;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure ExecuteProcedurePure(ProcName            : String;
                                 Var Error           : Boolean;
                                 Var MessageError    : String); Virtual;
  Procedure GetTableNames     (Var TableNames        : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure GetFieldNames     (TableName             : String;
                               Var FieldNames        : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure GetKeyFieldNames  (TableName             : String;
                               Var FieldNames        : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure GetProcNames      (Var ProcNames         : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure GetProcParams     (ProcName              : String;
                               Var ParamNames        : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Function InsertMySQLReturnID(SQL                   : String;
                               Var Error             : Boolean;
                               Var MessageError      : String)          : Integer;    Overload;Virtual;
  Function InsertMySQLReturnID(SQL                   : String;
                               Params                : TRESTDWParams;
                               Var Error             : Boolean;
                               Var MessageError      : String)          : Integer;    Overload;Virtual;
  Function OpenDatasets       (DatasetsLine          : String;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream)   : TJSONValue; Overload;Virtual;
  Function OpenDatasets       (DatapackStream        : TStream;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               aBinaryEvent          : Boolean = False;
                               aBinaryCompatibleMode : Boolean = False) : TStream; Overload;Virtual;
  Class Procedure CreateConnection(Const AConnectionDefs  : TConnectionDefs;
                                   Var AConnection        : TComponent);     Virtual;
  Procedure PrepareConnection     (Var AConnectionDefs    : TConnectionDefs);Virtual;
  Function  ProcessMassiveSQLCache(MassiveSQLCache        : String;
                                   Var Error              : Boolean;
                                   Var MessageError       : String)     : TJSONValue; Virtual;
  Procedure BuildDatasetLine      (Var Query              : TRESTDWDrvDataset;
                                   Massivedataset         : TMassivedatasetBuffer;
                                   MassiveCache           : Boolean = False);

  property ServerMethod  : TServerMethodDataModule read FServerMethod;
  property StorageDataType     : TRESTDWStorageBase   Read FStorageDataType       Write FStorageDataType;
 Published
  Property Connection          : TComponent           read FConnection            write setConnection;

  Property StrsTrim            : Boolean              Read vStrsTrim              Write vStrsTrim;
  Property StrsEmpty2Null      : Boolean              Read vStrsEmpty2Null        Write vStrsEmpty2Null;
  Property StrsTrim2Len        : Boolean              Read vStrsTrim2Len          Write vStrsTrim2Len;
  Property Compression         : Boolean              Read vCompression           Write vCompression;
  Property EncodeStringsJSON   : Boolean              Read vEncodeStrings         Write vEncodeStrings;
  Property Encoding            : TEncodeSelect        Read vEncoding              Write vEncoding;
  Property ParamCreate         : Boolean              Read vParamCreate           Write vParamCreate;
  {$IFDEF FPC}
  Property DatabaseCharSet     : TDatabaseCharSet     Read vDatabaseCharSet       Write vDatabaseCharSet;
  {$ENDIF}
  Property CommitRecords       : Integer              Read vCommitRecords         Write vCommitRecords;
  Property OnPrepareConnection : TOnPrepareConnection Read vOnPrepareConnection   Write vOnPrepareConnection;
  Property OnTableBeforeOpen   : TOnTableBeforeOpen   Read vOnTableBeforeOpen     Write vOnTableBeforeOpen;
  Property OnQueryBeforeOpen   : TOnQueryBeforeOpen   Read vOnQueryBeforeOpen     Write vOnQueryBeforeOpen;
  Property OnQueryException    : TOnQueryException    Read vOnQueryException      Write vOnQueryException;
 End;

Implementation

Uses
  uRESTDWBasicDB;

{ TRESTDWDrvStoreProc }

Function TRESTDWDrvStoreProc.getStoredProcName : String;
Begin
 Try
  Result := GetStrProp(Self.Owner, 'StoredProcName');
 Except
  Result := '';
 End;
End;

Procedure TRESTDWDrvStoreProc.setStoredProcName(AValue : String);
Begin
 Try
  SetStrProp(Self.Owner, 'Filter', AValue);
 Except
 End;
End;

{ TRESTDWDrvDataset }

Function TRESTDWDrvDataset.getFields : TFields;
Begin
 Result := TDataSet(Self.Owner).Fields;
End;

function TRESTDWDrvDataset.getParamName(IParam: integer): string;
begin

end;

function TRESTDWDrvDataset.getParamSize(IParam: integer): integer;
begin

end;

function TRESTDWDrvDataset.getParamValue(IParam: integer): variant;
begin

end;

function TRESTDWDrvDataset.getRDWDrvParam(idx: integer): TRDWDrvParam;
var
  p : integer;
begin
  Result := nil;
  if (idx >= 0) and (idx < ParamCount) then begin
    p := FParamsList.IndexOf(IntToStr(idx));
    if p < 0 then begin
      Result := TRDWDrvParam.Create;
      Result.IdxParam := idx;
      Result.DrvDataset := Self;
      FParamsList.AddObject(IntToStr(idx),Result);
    end
    else begin
      Result := TRDWDrvParam(FParamsList.Objects[p]);
    end;
  end;
end;

constructor TRESTDWDrvDataset.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParamsList := TStringList.Create;
  FParamsList.Sorted := True;
  FStorageDataType := nil;
end;

Procedure TRESTDWDrvDataset.createSequencedField(seqname,
                                                 field    : String);
Begin

End;

Procedure TRESTDWDrvDataset.Close;
Begin
 TDataSet(Self.Owner).Close;
End;

Procedure TRESTDWDrvDataset.Open;
Begin
  TDataSet(Self.Owner).Open;
End;

procedure TRESTDWDrvDataset.ImportParams(DWParams: TRESTDWParams);
var
  I : integer;
  vParamName : string;
  vStringStream : TMemoryStream;
  vParam : TRDWDrvParam;
begin
  if DWParams = nil then
    Exit;

{
  // firebird funciona
  // mssql nao funciona
  try
    Self.Prepare;
  except

  end;
}

  for I := 0 To DWParams.Count -1 do begin
    if Self.ParamCount > I then begin
      vParamName := Copy(StringReplace(DWParams[I].ParamName, ',', '', []), 1, Length(DWParams[I].ParamName));
      vParam := Self.ParamByName(vParamName);
      if vParam <> nil then begin
        if vParam.RESTDWDataTypeParam in [dwftFixedChar,dwftFixedWideChar,dwftString,dwftWideString,
                                          dwftMemo,dwftFmtMemo,dwftWideMemo] then begin
          if (not DWParams[I].IsNull) then begin
            if vParam.RESTDWDataTypeParam in [dwftMemo, dwftFmtMemo, dwftWideMemo] then
              vParam.Value := DWParams[I].Value
            else begin
              if vParam.Size > 0 Then
                vParam.Value := Copy(DWParams[I].Value, 1, vParam.Size)
              else
                vParam.Value := DWParams[I].Value;
            end;
          end
          else
            vParam.Clear;
        end
        else begin
          if vParam.DataType in [ftUnknown] then begin
            if not (ObjectValueToFieldType(DWParams[I].ObjectValue) in [ftUnknown]) then
              vParam.DataType := ObjectValueToFieldType(DWParams[I].ObjectValue)
            else
              vParam.DataType := ftString;
          end;

          if vParam.RESTDWDataTypeParam in [dwftInteger, dwftSmallInt, dwftWord, dwftLongWord, dwftLargeint] then begin
            if (Trim(DWParams[I].Value) <> '') and (not DWParams[I].IsNull) then begin
              if vParam.RESTDWDataTypeParam in [dwftLongWord, dwftLargeint] then
                vParam.Value := StrToInt64(DWParams[I].Value)
              else If vParam.DataType = ftSmallInt Then
                vParam.Value := StrToInt(DWParams[I].Value)
              else
                vParam.Value  := StrToInt(DWParams[I].Value);
            end
            else
              vParam.Clear;
          end
          else if vParam.RESTDWDataTypeParam in [dwftFloat,dwftBCD,dwftFMTBcd,dwftSingle,dwftExtended] then begin
            if (Trim(DWParams[I].Value) <> '') and (not DWParams[I].IsNull) then
              vParam.Value  := StrToFloat(BuildFloatString(DWParams[I].Value))
            else
              vParam.Clear;
          end
          else if vParam.RESTDWDataTypeParam in [dwftCurrency] then begin
            if (Trim(DWParams[I].Value) <> '') and (not DWParams[I].IsNull) then
              vParam.Value  := StrToCurr(BuildFloatString(DWParams[I].Value))
            else
              vParam.Clear;
          end
          else If vParam.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then begin
            if (Trim(DWParams[I].Value) <> '') and (not DWParams[I].IsNull) then begin
              if vParam.DataType = ftDate then
                vParam.Value := DWParams[I].AsDate
              else If vParam.DataType = ftTime then
                vParam.Value := DWParams[I].AsTime
              else
                vParam.Value := DWParams[I].AsDateTime;
            end
            else
              vParam.Clear;
          end
          //Tratar Blobs de Parametros...
          else if vParam.DataType in [ftBytes, ftVarBytes, ftBlob,ftGraphic, ftOraBlob, ftOraClob] then begin
            vStringStream  := TMemoryStream.Create;
            try
              DWParams[I].SaveToStream(TStream(vStringStream));
              vStringStream.Position := 0;
              if vStringStream.Size > 0 then
                vParam.LoadFromStream(vStringStream, ftBlob);
            finally
              FreeAndNil(vStringStream);
            end;
          end
          else if vParam.RESTDWDataTypeParam in [dwftFixedChar, dwftFixedWideChar,
                  dwftString, dwftWideString, dwftMemo, dwftFmtMemo, dwftWideMemo] then begin
              if (not DWParams[I].IsNull) then
               vParam.Value := DWParams[I].AsString
              Else
               vParam.Clear;
          end
          else If vParam.DataType in [ftGuid] Then begin
            if (not (DWParams[I].IsNull)) Then
                vParam.Value := DWParams[I].AsString
              Else
                vParam.Clear;
          end
          else
            vParam.Value := DWParams[I].Value;
        end;
      end;
    end
  end;
end;

Procedure TRESTDWDrvDataset.Insert;
Begin
 TDataSet(Self.Owner).Insert;
End;

procedure TRESTDWDrvDataset.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
begin

end;

Procedure TRESTDWDrvDataset.Edit;
Begin
 TDataSet(Self.Owner).Edit;
End;

Procedure TRESTDWDrvDataset.Post;
Begin
 TDataSet(Self.Owner).Post;
End;

Procedure TRESTDWDrvDataset.Delete;
Begin
 TDataSet(Self.Owner).Delete;
End;

destructor TRESTDWDrvDataset.Destroy;
var
  obj : TRDWDrvParam;
begin
  while FParamsList.Count > 0 do begin
    obj := TRDWDrvParam(FParamsList.Objects[0]);
    FreeAndNil(obj);
    FParamsList.Delete(0);
  end;
  FreeAndNil(FParamsList);
  inherited;
end;

Procedure TRESTDWDrvDataset.Next;
Begin
 TDataSet(Self.Owner).Next;
End;

Procedure TRESTDWDrvDataset.Prepare;
Begin

End;

procedure TRESTDWDrvDataset.ExecProc;
begin

end;

Procedure TRESTDWDrvDataset.ExecSQL;
Begin

End;

Procedure TRESTDWDrvDataset.FetchAll;
Begin

End;

Procedure TRESTDWDrvDataset.SaveToStream(stream: TStream);
Begin

End;

procedure TRESTDWDrvDataset.SaveToStreamCompatibleMode(stream: TStream);
var
  qry : TDataSet;
  stor : TRESTDWStorageBinRDW;
begin
  qry := TDataSet(Self.Owner);
  if FStorageDataType = nil then begin
    stor := TRESTDWStorageBinRDW.Create(nil);
    try
      stor.EncodeStrs := False;
      stor.SaveToStream(qry, stream);
    finally
      stor.Free;
    end;
  end
  else
    FStorageDataType.SaveToStream(qry,stream);
end;

procedure TRESTDWDrvDataset.setParamDataType(IParam: integer;
                                             AValue: TFieldType);
begin

end;

procedure TRESTDWDrvDataset.setParamValue(IParam: integer;
                                          AValue: variant);
begin

end;

Function TRESTDWDrvDataset.Eof: boolean;
Begin
 Result := TDataSet(Self.Owner).EOF;
End;

Function TRESTDWDrvDataset.RecNo: int64;
Begin
 Result := TDataSet(Self.Owner).RecNo;
End;

Function TRESTDWDrvDataset.RecordCount: int64;
Begin
 Result := TDataSet(Self.Owner).RecordCount;
End;

function TRESTDWDrvDataset.RowsAffected: Int64;
begin
 Result := -1;
end;

Function TRESTDWDrvDataset.ParamCount: integer;
Begin
 Result := -1;
End;

Function TRESTDWDrvDataset.ParamByName(param: String): TRDWDrvParam;
var
  idx : integer;
Begin
  Try
    idx := GetParamIndex(param);
    Result := Params[idx];
  Except
    Result := nil;
  End;
End;

Function TRESTDWDrvDataset.FieldByName(field: String): TField;
Begin
 Result := TDataSet(Self.Owner).FieldByName(field);
End;

Function TRESTDWDrvDataset.FindField(field: String): TField;
Begin
 Result := TDataSet(Self.Owner).FindField(field);
End;

function TRESTDWDrvDataset.RESTDWDataTypeField(idx: integer): Byte;
var
  vDType : TFieldType;
begin
  vDType := Fields[idx].DataType;
  Result := FieldTypeToDWFieldType(vDType);
end;

Function TRESTDWDrvDataset.RESTDWDataTypeFieldName(field : String) : Byte;
Var
 vDType : TFieldType;
Begin
 vDType := FieldByName(field).DataType;
 Result := FieldTypeToDWFieldType(vDType);
End;

function TRESTDWDrvDataset.RESTDWDataTypeParam(idx: integer): Byte;
var
  vDType : TFieldType;
begin
  vDType := Params[idx].DataType;
  Result := FieldTypeToDWFieldType(vDType);
end;

Function TRESTDWDrvDataset.RESTDWDataTypeParamName(param : String) : Byte;
Var
 vDType : TFieldType;
Begin
 Try
  vDType := TRDWDrvParam(ParamByName(param)).DataType;
 Except
  vDType := ftUnknown;
 End;
 Result := FieldTypeToDWFieldType(vDType);
End;

function TRESTDWDrvDataset.GetInsertID: int64;
begin

end;

function TRESTDWDrvDataset.getParamDataType(IParam: integer): TFieldType;
begin

end;

Function TRESTDWDrvDataset.GetParamIndex(param : String): integer;
var
  I: Integer;
  prm : string;
begin
  Result := -1;
  for I := 0 to ParamCount - 1 do begin
    prm := Params[I].Name;
    if SameText(prm,param) then begin
      Result := i;
      Break;
    end;
  end;
End;

{ TRESTDWDrvTable }

Function TRESTDWDrvTable.getFilter : String;
Begin
 Try
  Result := GetStrProp(Self.Owner,'Filter');
 Except
  Result := '';
 End;
End;

Function TRESTDWDrvTable.getFiltered: boolean;
Begin
 Try
  Result := Boolean(GetPropValue(Self.Owner,'Filtered'));
 Except
  Result := False;
 End;
End;

Function TRESTDWDrvTable.getTableName : String;
Begin
 Try
  Result := GetStrProp(Self.Owner,'TableName');
 Except
  Result := '';
 End;
End;

Procedure TRESTDWDrvTable.setFilter(AValue : String);
Begin
 Try
  SetStrProp(Self.Owner,'Filter',AValue);
 Except

 End;
End;

Procedure TRESTDWDrvTable.setFiltered(AValue: boolean);
Begin
 Try
  SetPropValue(Self.Owner,'Filtered',AValue);
 Except

 End;
End;

Procedure TRESTDWDrvTable.setTableName(AValue : String);
Begin

End;

{ TRESTDWDrvQuery }

Function TRESTDWDrvQuery.getSQL: TStrings;
Begin
 Try
  Result := TStrings(GetObjectProp(Self.Owner,'SQL'));
 Except
  Result := nil;
 End;
End;

Function TRESTDWDrvQuery.GetInsertID : Int64;
Var
 drv : TRESTDWDriverBase;
Begin
 Result := -1;
 drv    := TRESTDWDriverBase(Self.Owner);
 Try
  If drv.getConectionType = dbtMySQL Then
   Begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT LAST_INSERT_ID() ID');
    Open;
    {$IF NOT DEFINED(FPC) AND (CompilerVersion < 22)}
      Result := Fields[0].AsInteger;
    {$ELSE}
      Result := Fields[0].AsLargeInt;
    {$IFEND}
   End;
 Except
  Result := -1;
 End;
End;

{ TRESTDWDriverBase }

Function TRESTDWDriverBase.getConectionType : TRESTDWDatabaseType;
Begin
 Result := dbtUndefined;
End;

Function TRESTDWDriverBase.getDatabaseInfo  : TRESTDWDatabaseInfo;
Var
 connType : TRESTDWDatabaseType;
 qry      : TRESTDWDrvQuery;
 iAux1    : Integer;
 sAux1,
 sVersion : String;
 lst      : TStringList;
Begin
 Result.rdwDatabaseName         := '';
 Result.rdwDatabaseMajorVersion := 0;
 Result.rdwDatabaseMinorVersion := 0;
 Result.rdwDatabaseSubVersion   := 0;
 // rdwDatabaseName foi definido para possiveis subversoes
 // ex: no MySQL temos o MariaDB
 // ex: no Firebird temos a versao HQBird
 sVersion := '';
 connType := getConectionType;
 lst := TStringList.Create;
 qry := getQuery;
 Try
  Case connType Of
   dbtFirebird    : Begin
                     Result.rdwDatabaseName         := 'firebird';
                     Result.rdwDatabaseMajorVersion := 1;
                     Result.rdwDatabaseMinorVersion := 5;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('select rdb$get_context(''SYSTEM'',''ENGINE_VERSION'')');
                      qry.SQL.Add('from rdb$database');
                      qry.Open;
                      sVersion := qry.Fields[0].AsString;
                     Except
                     End;
                    End;
   dbtInterbase   : Begin
                     Result.rdwDatabaseName         := 'interbase';
                     Result.rdwDatabaseMajorVersion := 6;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('select rdb$get_context(''SYSTEM'',''ENGINE_VERSION'')');
                      qry.SQL.Add('from rdb$database');
                      qry.Open;
                      sVersion := qry.Fields[0].AsString;
                     Except

                     End;
                    End;
    dbtMySQL      : Begin
                     Result.rdwDatabaseName         := 'mysql';
                     Result.rdwDatabaseMajorVersion := 3;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('SHOW VARIABLES LIKE ''%version%''');
                      qry.Open;
                      While Not qry.Eof Do
                       Begin
                        sAux1 := qry.FieldByName('variable_name').AsString;
                        If SameText(sAux1, 'innodb_version') Then
                         sVersion := qry.FieldByName('value').AsString
                        Else If SameText(sAux1,'version')    Then
                         Begin
                          sAux1 := qry.FieldByName('value').AsString;
                          If Pos('mariadb',LowerCase(sAux1)) > 0 Then
                           Result.rdwDatabaseName := 'mariadb';
                          iAux1 := 1;
                          While iAux1 <= Length(sAux1) Do
                           Begin
                            If Not (sAux1[iAux1] In ['0'..'9', '.']) Then
                             Delete(sAux1,iAux1,1)
                            Else
                             iAux1 := iAux1 + 1;
                           End;
                          sVersion := sAux1;
                         End
                        Else If SameText(sAux1,'version_comment') Then
                         Begin
                          sAux1 := qry.FieldByName('value').AsString;
                          If Pos('mariadb',LowerCase(sAux1)) > 0 Then
                           Result.rdwDatabaseName := 'mariadb';
                         End;
                        qry.Next;
                       End;
                     Except

                     End;
                    End;
    dbtPostgreSQL : Begin
                     Result.rdwDatabaseName := 'postgresql';
                     Result.rdwDatabaseMajorVersion := 7;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('SELECT version()');
                      qry.Open;
                      sAux1 := qry.Fields[0].AsString;
                      iAux1 := Pos('.',sAux1);
                      While (iAux1 > 0)           And
                            (sAux1[iAux1] <> ' ') Do
                       iAux1 := iAux1 - 1;
                      If iAux1 > 0 then
                       Delete(sAux1,1,iAux1);
                      sAux1 := Trim(sAux1);
                      iAux1 := 1;
                      While (iAux1        <= Length(sAux1))  And
                            (sAux1[iAux1] In ['0'..'9','.']) Do
                       Begin
                        sVersion := sVersion + sAux1[iAux1];
                        iAux1 := iAux1 + 1;
                       End;
                     Except

                     End;
                     If sVersion = '' Then
                      Begin
                       Try
                        qry.SQL.Add('SHOW server_version');
                        qry.Open;
                        sVersion := qry.Fields[0].AsString;
                       Except
                       End;
                      End;
                    End;
    dbtSQLLite    : Begin
                     Result.rdwDatabaseName         := 'sqlite';
                     Result.rdwDatabaseMajorVersion := 1;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('select sqlite_version()');
                      qry.Open;
                      sVersion := qry.Fields[0].AsString;
                     Except

                     End;
                    End;
    dbtOracle     : Begin
                     Result.rdwDatabaseName         := 'oracle';
                     Result.rdwDatabaseMajorVersion := 0;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('SELECT * FROM v$version');
                      qry.SQL.Add('WHERE banner LIKE ''Oracle%''');
                      qry.Open;
                      sAux1 := qry.Fields[0].AsString;
                      Repeat
                       iAux1 := Pos(' ',sAux1);
                       If iAux1 > 0 Then
                        Begin
                         If Pos('.',Copy(sAux1,1,iAux1-1)) > 0 Then
                          Begin
                           sVersion := Copy(sAux1,1,iAux1-1);
                           Break;
                          End;
                         Delete(sVersion,1,iAux1);
                        End;
                      Until iAux1 = 0;
                     Except
                     End;
                    End;
    dbtMsSQL      : Begin
                     Result.rdwDatabaseName         := 'mssql';
                     Result.rdwDatabaseMajorVersion := 0;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('select @@VERSION');
                      qry.Open;
                      sAux1 := qry.Fields[0].AsString;
                      Repeat
                       iAux1 := Pos(' ',sAux1);
                       If iAux1 > 0 Then
                        Begin
                         If Pos('.',Copy(sAux1,1,iAux1-1)) > 0 Then
                          Begin
                           sVersion := Copy(sAux1,1,iAux1-1);
                           Break;
                          End;
                         Delete(sVersion,1,iAux1);
                        End;
                      Until iAux1 = 0;
                     Except
                     End;
                    End;
  End;
  If sVersion <> '' Then
   Begin
    sVersion := Trim(sVersion) + '.';
    Repeat
     iAux1 := Pos('.',sVersion);
     If iAux1 > 0 Then Begin
       lst.Add(Copy(sVersion,1,iAux1-1));
       Delete(sVersion,1,iAux1);
     End;
    Until iAux1 = 0;
    If lst.Count > 0 Then
     Result.rdwDatabaseMajorVersion := StrToInt(lst.Strings[0]);
    If lst.Count > 1 Then
     Result.rdwDatabaseMinorVersion := StrToInt(lst.Strings[1]);
    If lst.Count > 2 Then
     Result.rdwDatabaseSubVersion := StrToInt(lst.Strings[2]);
   End;
 Finally
  FreeAndNil(qry);
  FreeAndNil(lst);
 End;
End;

Function TRESTDWDriverBase.getQuery: TRESTDWDrvQuery;
Begin
 Result := Nil;
End;

Function TRESTDWDriverBase.getTable: TRESTDWDrvTable;
Begin
 Result := Nil;
End;

Function TRESTDWDriverBase.getStoreProc : TRESTDWDrvStoreProc;
Begin
 Result := Nil;
End;

Function TRESTDWDriverBase.isConnected: boolean;
Begin
 Result := False;
End;

Function TRESTDWDriverBase.connInTransaction: boolean;
Begin
 Result := False;
End;

Procedure TRESTDWDriverBase.connStartTransaction;
Begin

End;

Procedure TRESTDWDriverBase.connRollback;
Begin

End;

function TRESTDWDriverBase.compConnIsValid(comp: TComponent): boolean;
begin
  Result := False;
end;

Procedure TRESTDWDriverBase.connCommit;
Begin

End;

Function TRESTDWDriverBase.isMinimumVersion(major, minor, sub: integer): boolean;
Var
 info : TRESTDWDatabaseInfo;
Begin
 info := getDatabaseInfo;
 Result := (info.rdwDatabaseMajorVersion >= major) And
           (info.rdwDatabaseMinorVersion >= minor) And
           (info.rdwDatabaseMinorVersion >= sub);
End;

Function TRESTDWDriverBase.isMinimumVersion(major, minor: integer): boolean;
Begin
 Result := isMinimumVersion(major, minor, 0);
End;

Procedure TRESTDWDriverBase.setConnection(AValue: TComponent);
Begin
 If FConnection = AValue Then
  Exit;
 If isConnected Then
  Disconect;
 FConnection := AValue;
End;

procedure TRESTDWDriverBase.SetUpdateBuffer(var Query: TRESTDWDrvQuery;
                                            MassiveDataset: TMassiveDatasetBuffer;
                                            IParam: integer; All: boolean);
var
  X : integer;
  MassiveReplyCache: TMassiveReplyCache;
  MassiveReplyValue: TMassiveReplyValue;
  vTempValue: string;
  bPrimaryKeys : TStringList;
  vStringStream : TMemoryStream;
  vParam : TRDWDrvParam;
begin
  vStringStream := nil;
  if (IParam = 0) or (All) then begin
    bPrimaryKeys := MassiveDataset.PrimaryKeys;
    try
      for X := 0 to bPrimaryKeys.Count - 1 do begin
        vParam := Query.ParamByName('DWKEY_' + bPrimaryKeys[X]);
        if vParam.RESTDWDataTypeParam in [
          dwftFixedChar,
          dwftFixedWideChar,
          dwftString,
          dwftWideString,
          dwftMemo, dwftFmtMemo,
          dwftWideMemo] then begin
          if vParam.Size > 0 then
            vParam.Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1,vParam.Size)
          else
            vParam.Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
        end
        else begin
          if vParam.DataType in [ftUnknown] then begin
            if not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) then
              vParam.DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
            else
              vParam.DataType := ftString;
          end;

          if vParam.RESTDWDataTypeParam in [dwftInteger, dwftSmallInt, dwftWord, dwftLongWord, dwftLargeint] then begin
            if MassiveDataset.MasterCompTag <> '' then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
            else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
            MassiveReplyValue := nil;

            if MassiveReplyCache <> nil then begin
              MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X],
                                   MassiveDataset.AtualRec.PrimaryValues[X].OldValue);

              if MassiveReplyValue = nil then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);

              if MassiveReplyValue <> nil then  begin
                if vParam.RESTDWDataTypeParam in [dwftLongWord,dwftLargeint] then
                  {$IFNDEF FPC}
                    {$IF CompilerVersion >= 21}
                      vParam.AsLargeInt := StrToInt64(MassiveReplyValue.NewValue)
                    {$ELSE}
                      vParam.AsInteger := StrToInt64(MassiveReplyValue.NewValue)
                    {$IFEND}
                  {$ELSE}
                    vParam.AsLargeInt := StrToInt64(MassiveReplyValue.NewValue)
                  {$ENDIF}
                else if vParam.DataType = ftSmallInt then
                  vParam.AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                else
                  vParam.AsInteger := StrToInt(MassiveReplyValue.NewValue);
              end;
            end;

            if (MassiveReplyValue = nil) and
               (not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) then begin
              if vParam.RESTDWDataTypeParam in [dwftLongWord,dwftLargeint] then
                vParam.AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
              else if vParam.DataType = ftSmallInt then
                vParam.AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
              else
                vParam.AsInteger := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
            end;
          end
          else if vParam.RESTDWDataTypeParam in [dwftFloat, dwftCurrency, dwftBCD, dwftFMTBcd, dwftSingle] then begin
            if (not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) then
              vParam.AsFloat := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
          end
          else if vParam.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then begin
            if (not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) then
              vParam.AsDateTime := MassiveDataset.AtualRec.PrimaryValues[X].Value
            else
              vParam.Clear;
          end
          //Tratar Blobs de Parametros...
          else if vParam.DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] then begin
            vStringStream := TMemoryStream.Create;
            try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              vParam.LoadFromStream(vStringStream, ftBlob);
            finally
              FreeAndNil(vStringStream);
            end;
          end
          else
            vParam.Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
        end;
      end;
    finally
      FreeAndNil(bPrimaryKeys);
    end;
  end;

  if not (All) then begin
    vParam := Query.Params[IParam];
    if vParam.RESTDWDataTypeParam in [
      dwftFixedChar, dwftFixedWideChar,
      dwftString, dwftWideString,
      dwftMemo, dwftFmtMemo,
      dwftWideMemo] then begin
      if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then begin
        if vParam.Size > 0 then
          vParam.Value := Copy(MassiveDataset.Fields.FieldByName(vParam.Name).Value, 1, vParam.Size)
        else
          vParam.Value := MassiveDataset.Fields.FieldByName(vParam.Name).Value;
      end;
    end
    else begin
      if vParam.DataType in [ftUnknown] then begin
        if not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(vParam.Name).FieldType) in [ftUnknown]) then
          vParam.DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(vParam.Name).FieldType)
        else
          vParam.DataType := ftString;
      end;

      if vParam.DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] then begin
        if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then
          vParam.Value := MassiveDataset.Fields.FieldByName(vParam.Name).Value
        else
          vParam.Clear;
      end
      else if vParam.RESTDWDataTypeParam in [dwftInteger, dwftSmallInt, dwftWord, dwftLongWord,dwftLargeint] then begin
        if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then begin
          if vParam.RESTDWDataTypeParam in [dwftLongWord,dwftLargeint] then
            vParam.AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(vParam.Name).Value)
          else if vParam.DataType = ftSmallInt then
            vParam.AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(vParam.Name).Value)
          else
            vParam.AsInteger := StrToInt(MassiveDataset.Fields.FieldByName(vParam.Name).Value);
        end
        else
          vParam.Clear;
      end
      else if vParam.RESTDWDataTypeParam in [dwftFloat, dwftCurrency, dwftBCD, dwftFMTBcd, dwftSingle] then begin
        if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then
          vParam.AsFloat := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(vParam.Name).Value))
        else
          vParam.Clear;
      end
      else if vParam.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then begin
        if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then
          vParam.AsDateTime := MassiveDataset.Fields.FieldByName(vParam.Name).Value
        else
          vParam.Clear;
      end
      //Tratar Blobs de Parametros...
      else if vParam.DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] then begin
        if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then begin
          vStringStream := TMemoryStream.Create;
          try
            MassiveDataset.Fields.FieldByName(vParam.Name).SaveToStream(vStringStream);
            if vStringStream <> nil then begin
              vStringStream.Position := 0;
              vParam.LoadFromStream(vStringStream, ftBlob);
            end
            else
              vParam.Clear;
          finally
            FreeAndNil(vStringStream);
          end;
        end
        else
          vParam.Clear;
      end
      else
        vParam.Value := MassiveDataset.Fields.FieldByName(vParam.Name).Value;
    end;
  end;
end;

Procedure TRESTDWDriverBase.Connect;
Begin

End;

destructor TRESTDWDriverBase.Destroy;
begin
  FConnection := nil;
  inherited;
end;

Procedure TRESTDWDriverBase.Disconect;
Begin

End;

Function TRESTDWDriverBase.ConnectionSet: Boolean;
Begin
 Result := Assigned(FConnection);
End;

Function TRESTDWDriverBase.GetGenID(Query   : TRESTDWDrvQuery;
                                    GenName : String;
                                    valor   : Integer) : Integer;
Var
 connType : TRESTDWDatabaseType;
Begin
 Result := -1;
 connType := getConectionType;
 With Query Do
  Begin
   Close;
   SQL.Clear;
   Case connType Of
    dbtFirebird   : Begin
                     SQL.Add('select gen_id('+GenName+','+IntToStr(valor)+')');
                     SQL.Add('from rdb$database');
                     Open;
                     Result := Query.Fields[0].AsInteger;
                    End;
    dbtMySQL      : Begin
                     SQL.Add('show table status where name = '+QuotedStr(GenName));
                     Open;
                     Result := valor + Query.FieldByName('auto_increment').AsInteger;
                     If valor <> 0 Then
                      Begin
                       SQL.Clear;
                       SQL.Add('alter table '+GenName+' auto_increment='+IntToStr(Result));
                       ExecSQL;
                      End;
                    End;
    dbtSQLLite    : Begin
                     SQL.Add('create table if not exist sqlite_sequence(name,seq)');
                     ExecSQL;
                     SQL.Clear;
                     SQL.Add('select seq from sqlite_sequence');
                     SQL.Add('where name = '+QuotedStr(GenName));
                     Open;
                     Result := valor + Query.Fields[0].AsInteger;
                     If valor <> 0 Then
                      Begin
                       SQL.Clear;
                       SQL.Add('insert or replace into sqlite_sequence(name,seq)');
                       SQL.Add('values('+QuotedStr(GenName)+','+IntToStr(Result)+')');
                       ExecSQL;
                      End;
                    End;
    dbtPostgreSQL : Begin
                     SQL.Add('select currval('+QuotedStr(GenName)+')');
                     Open;
                     Try
                      If valor <> 0 Then
                       Begin
                        SQL.Clear;
                        SQL.Add('select nextval('+QuotedStr(GenName)+')');
                        Open;
                       End;
                     Except
                      SQL.Clear;
                      SQL.Add('select nextval('+QuotedStr(GenName)+')');
                      Open;
                     End;
                     Result := Query.Fields[0].AsInteger;
                    End;
   End;
  End;
End;

Function TRESTDWDriverBase.GetGenID(GenName : String;
                                    valor   : Integer) : Integer;
Var
 qry : TRESTDWDrvQuery;
Begin
 qry := getQuery;
 Try
  Result := GetGenID(qry,GenName,valor);
 Finally
  FreeAndNil(qry);
 End;
End;

Function TRESTDWDriverBase.ApplyUpdates(MassiveStream    : TStream;
                                        SQL              : String;
                                        Params           : TRESTDWParams;
                                        var Error        : Boolean;
                                        var MessageError : String;
                                        var RowsAffected : Integer) : TJSONValue;
Var
 MassiveDataset : TMassiveDatasetBuffer;
Begin
 MassiveDataset := TMassiveDatasetBuffer.Create(nil);
 Try
  MassiveDataset.LoadFromStream(MassiveStream);
  Result := ApplyUpdates(MassiveDataset, SQL, Params, Error, MessageError, RowsAffected);
 Finally
  FreeAndNil(MassiveDataset);
 End;
End;


Function TRESTDWDriverBase.ApplyUpdates(Massive,
                                        SQL              : String;
                                        Params           : TRESTDWParams;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Var RowsAffected : Integer): TJSONValue;
Var
 MassiveDataset : TMassiveDatasetBuffer;
Begin
 MassiveDataset := TMassiveDatasetBuffer.Create(nil);
 Try
  MassiveDataset.FromJSON(Massive);
  Result := ApplyUpdates(MassiveDataset, SQL, Params, Error, MessageError, RowsAffected);
 Finally
  FreeAndNil(MassiveDataset);
 End;
End;

Function TRESTDWDriverBase.ApplyUpdatesTB(MassiveStream    : TStream;
                                          SQL              : String;
                                          Params           : TRESTDWParams;
                                          Var Error        : Boolean;
                                          Var MessageError : String;
                                          Var RowsAffected : Integer): TJSONValue;
Var
  vTempQuery         : TRESTDWDrvTable;
  vResultReflection  : String;
  vMassiveLine       : Boolean;
  vValueKeys         : TRESTDWValueKeys;
  vDataSet           : TDataSet;

  function LoadMassive(var Query: TRESTDWDrvTable): boolean;
  var
    MassiveDataset: TMassiveDatasetBuffer;
    A, B: integer;
  begin
    MassiveDataset := TMassiveDatasetBuffer.Create(nil);
    Result := False;
    try
      MassiveStream.Position := 0;
      MassiveDataset.LoadFromStream(MassiveStream);
      MassiveDataset.First;
      if Assigned(FServerMethod) then begin
        if Assigned(FServerMethod.OnMassiveBegin) then
          FServerMethod.OnMassiveBegin(MassiveDataset);
      end;
      B := 1;
      Result := True;
      for A := 1 to MassiveDataset.RecordCount do begin
        if not connInTransaction then begin
          connStartTransaction;
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterStartTransaction) then
              FServerMethod.OnMassiveAfterStartTransaction(MassiveDataset);
          end;
        end;
        Query.Close;
        Query.Filter := '';
        Query.Filtered := False;
        if Assigned(FServerMethod) then begin
          vMassiveLine := False;
          if Assigned(FServerMethod.OnMassiveProcess) then begin
            FServerMethod.OnMassiveProcess(MassiveDataset, vMassiveLine);
            if vMassiveLine then begin
              MassiveDataset.Next;
              Continue;
            end;
          end;
        end;
        PrepareDataTable(Query, MassiveDataset, Params, False, vResultReflection, Error, MessageError);
        try
          if (not (MassiveDataset.ReflectChanges)) or
             ((MassiveDataset.ReflectChanges) and
             (MassiveDataset.MassiveMode in [mmExec])) then
            Query.ExecSQL;
        except
          On E: Exception do begin
            Error := True;
            Result := False;
            MessageError := E.Message;
            if connInTransaction then
              connRollback;
            Exit;
          end;
        end;

        if B >= CommitRecords then begin
          try
            if connInTransaction then begin
              if Assigned(FServerMethod) then begin
                if Assigned(FServerMethod.OnMassiveAfterBeforeCommit) then
                  FServerMethod.OnMassiveAfterBeforeCommit(MassiveDataset);
              end;
              connCommit;
              if Assigned(FServerMethod) then begin
                if Assigned(FServerMethod.OnMassiveAfterAfterCommit) then
                  FServerMethod.OnMassiveAfterAfterCommit(MassiveDataset);
              end;
            end;
          except
            On E: Exception do begin
              Error := True;
              Result := False;
              MessageError := E.Message;
              if connInTransaction then
                connRollback;
              Break;
            end;
          end;
          B := 1;
        end
        else
          Inc(B);
        MassiveDataset.Next;
      end;
      try
        if connInTransaction then begin
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterBeforeCommit) then
              FServerMethod.OnMassiveAfterBeforeCommit(MassiveDataset);
          end;
          connCommit;
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterAfterCommit) then
              FServerMethod.OnMassiveAfterAfterCommit(MassiveDataset);
          end;
        end;
      except
        On E: Exception do begin
          Error := True;
          Result := False;
          MessageError := E.Message;
          if connInTransaction then
            connRollback;
        end;
      end;
    finally
      if Assigned(FServerMethod) then
      begin
        if Assigned(FServerMethod.OnMassiveEnd) then
          FServerMethod.OnMassiveEnd(MassiveDataset);
      end;
      FreeAndNil(MassiveDataset);
      Query.Filter := '';
      Query.Filtered := False;
    end;
  end;
Begin
  {$IFNDEF FPC} Inherited; {$ENDIF}
  Try
    Result := Nil;
    Error := False;
    vResultReflection := '';

    vTempQuery := getTable;
    vTempQuery.Filter := '';

    vDataSet := TDataSet(vTempQuery.Owner);

    vValueKeys := TRESTDWValueKeys.Create;
    If Not isConnected Then
      Connect;

    if LoadMassive(vTempQuery) Then Begin
      If (vResultReflection = '') Then Begin
        Try
          vTempQuery.Filter := '';
          vTempQuery.Filtered := False;
          vTempQuery.ImportParams(Params);
          vTempQuery.Open;
          vTempQuery.FetchAll;
          If Result = Nil Then
            Result := TJSONValue.Create;
          Result.Encoding := Encoding;
          Result.Encoded := EncodeStringsJSON;
          {$IFDEF FPC}
          Result.DatabaseCharSet := DatabaseCharSet;
          {$ENDIF}
          Result.Utf8SpecialChars := True;
          Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner),EncodeStringsJSON);
          Error := False;
        Except
          On E: Exception do Begin
            Try
              Error := True;
              MessageError := E.Message;
              If Result = Nil Then
                Result := TJSONValue.Create;
              Result.Encoded := True;
              {$IFDEF FPC}
              Result.DatabaseCharSet := DatabaseCharSet;
              {$ENDIF}
              Result.SetValue(GetPairJSONStr('NOK', MessageError));
              connRollback;
            except
            end;
          end;
        end;
      end
      else If (vResultReflection <> '') Then Begin
        If Result = Nil Then
          Result := TJSONValue.Create;
        Result.Encoding := Encoding;
        Result.Encoded := EncodeStringsJSON;
        {$IFDEF FPC}
          Result.DatabaseCharSet := DatabaseCharSet;
        {$ENDIF}
        Result.SetValue('[' + vResultReflection + ']');
        Error := False;
      end;
    end;
  finally
    RowsAffected := vTempQuery.RecordCount;
    vTempQuery.Close;
    FreeAndNil(vTempQuery);
    FreeAndNil(vValueKeys);
  end;
End;

function TRESTDWDriverBase.ApplyUpdates(MassiveDataset: TMassiveDatasetBuffer;
                                        SQL: String;
                                        Params: TRESTDWParams;
                                        var Error: Boolean;
                                        var MessageError: String;
                                        var RowsAffected: Integer): TJSONValue;
var
  vTempQuery: TRESTDWDrvQuery;
  vResultReflection: string;
  vStateResource, vMassiveLine: boolean;

  function LoadMassive(var Query: TRESTDWDrvQuery): boolean;
  var
    A, B: integer;
  begin
    Result := False;
    try
      MassiveDataset.First;
      if Assigned(FServerMethod) then begin
        if Assigned(FServerMethod.OnMassiveBegin) then
          FServerMethod.OnMassiveBegin(MassiveDataset);
      end;
      B := 1;
      Result := True;
      for A := 1 to MassiveDataset.RecordCount do begin
        if not connInTransaction then begin
          connStartTransaction;
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterStartTransaction) then
              FServerMethod.OnMassiveAfterStartTransaction(MassiveDataset);
          end;
        end;
        Query.SQL.Clear;
        if Assigned(FServerMethod) then begin
          vMassiveLine := False;
          if Assigned(FServerMethod.OnMassiveProcess) then begin
            FServerMethod.OnMassiveProcess(MassiveDataset,vMassiveLine);
            if vMassiveLine then begin
              MassiveDataset.Next;
              Continue;
            end;
          end;
        end;
        PrepareDataQuery(Query, MassiveDataset, Params, MassiveDataset.ReflectChanges, vResultReflection, Error, MessageError);
        try
          if (not (MassiveDataset.ReflectChanges)) or
             ((MassiveDataset.ReflectChanges) and
             (MassiveDataset.MassiveMode in [mmExec, mmDelete])) then
            Query.ExecSQL;
        except
          On E: Exception do begin
            Error := True;
            Result := False;
            MessageError := E.Message;
            if connInTransaction then
              connRollback;
            Exit;
          end;
        end;

        if B >= CommitRecords then begin
          try
            if connInTransaction then begin
              if Assigned(FServerMethod) then begin
                if Assigned(FServerMethod.OnMassiveAfterBeforeCommit) then
                  FServerMethod.OnMassiveAfterBeforeCommit(MassiveDataset);
              end;
              connCommit;
              if Assigned(FServerMethod) then begin
                if Assigned(FServerMethod.OnMassiveAfterAfterCommit) then
                  FServerMethod.OnMassiveAfterAfterCommit(MassiveDataset);
              end;
            end;
          except
            On E: Exception do begin
              Error := True;
              Result := False;
              MessageError := E.Message;
              if connInTransaction then
                connRollback;
              Break;
            end;
          end;
          B := 1;
        end
        else
          Inc(B);
        MassiveDataset.Next;
      end;
      try
        if connInTransaction then begin
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterBeforeCommit) then
              FServerMethod.OnMassiveAfterBeforeCommit(MassiveDataset);
          end;
          connCommit;
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterAfterCommit) then
              FServerMethod.OnMassiveAfterAfterCommit(MassiveDataset);
          end;
        end;
      except
        On E: Exception do begin
          Error := True;
          Result := False;
          MessageError := E.Message;
          if connInTransaction then
            connRollback;
        end;
      end;
    finally
      if Assigned(FServerMethod) then begin
        if Assigned(FServerMethod.OnMassiveEnd) then
          FServerMethod.OnMassiveEnd(MassiveDataset);
      end;
      Query.SQL.Clear;
    end;
  end;
begin
 {$IFNDEF FPC}inherited;{$ENDIF}
  try
    Result := nil;
    Error := False;
    vTempQuery := getQuery;

    vStateResource := isConnected;
    if not vStateResource then
      Connect;

    vTempQuery.SQL.Clear;
    vResultReflection := '';
    if LoadMassive(vTempQuery) then begin
      if (SQL <> '') and (vResultReflection = '') then begin
        try
          vTempQuery.SQL.Clear;
          vTempQuery.SQL.Add(SQL);
          vTempQuery.ImportParams(Params);
          vTempQuery.Open;

          if Result = nil then
            Result := TJSONValue.Create;
          Result.Encoding := Encoding;
          Result.Encoded := EncodeStringsJSON;
          Result.Utf8SpecialChars := True;
          Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner),EncodeStringsJSON);
          Error := False;
          if not vStateResource then
            Disconect;
        except
          On E: Exception do begin
            try
              Error := True;
              MessageError := E.Message;
              if Result = nil then
                Result := TJSONValue.Create;
              Result.Encoded := True;
              Result.SetValue(GetPairJSONStr('NOK', MessageError));
              if connInTransaction then
                connRollback;
            except

            end;
            Disconect;
          end;
        end;
      end
      else if (vResultReflection <> '') then begin
        if Result = nil then
          Result := TJSONValue.Create;
        Result.Encoding := Encoding;
        Result.Encoded := EncodeStringsJSON;
        Result.SetValue('[' + vResultReflection + ']');
        Error := False;
      end;
    end;
  finally
    FreeAndNil(BufferBase);
    RowsAffected := vTempQuery.RowsAffected;
    vTempQuery.Close;
    FreeAndNil(vTempQuery);
  end;
end;

Function TRESTDWDriverBase.ApplyUpdatesTB(Massive          : String;
                                          Params           : TRESTDWParams;
                                          var Error        : Boolean;
                                          var MessageError : String;
                                          var RowsAffected : Integer): TJSONValue;
var
  vTempQuery: TRESTDWDrvTable;
  vResultReflection : string;
  vMassiveLine: boolean;
  vValueKeys: TRESTDWValueKeys;
  vDataSet: TDataSet;

  function LoadMassive(var Query: TRESTDWDrvTable): boolean;
  var
    MassiveDataset: TMassiveDatasetBuffer;
    A, B: integer;
  begin
    MassiveDataset := TMassiveDatasetBuffer.Create(nil);
    Result := False;
    try
      MassiveDataset.FromJSON(Massive);
      MassiveDataset.First;
      if Assigned(FServerMethod) then begin
        if Assigned(FServerMethod.OnMassiveBegin) then
          FServerMethod.OnMassiveBegin(MassiveDataset);
      end;
      B := 1;
      Result := True;
      for A := 1 to MassiveDataset.RecordCount do begin
        if not connInTransaction then begin
          connStartTransaction;
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterStartTransaction) then
              FServerMethod.OnMassiveAfterStartTransaction(MassiveDataset);
          end;
        end;
        Query.Close;
        Query.Filter := '';
        Query.Filtered := False;
        if Assigned(FServerMethod) then begin
          vMassiveLine := False;
          if Assigned(FServerMethod.OnMassiveProcess) then begin
            FServerMethod.OnMassiveProcess(MassiveDataset,vMassiveLine);
            if vMassiveLine then begin
              MassiveDataset.Next;
              Continue;
            end;
          end;
        end;
        PrepareDataTable(Query, MassiveDataset, Params, True, vResultReflection, Error, MessageError);
        try
          if (not (MassiveDataset.ReflectChanges)) or
             ((MassiveDataset.ReflectChanges) and
             (MassiveDataset.MassiveMode in [mmExec])) then
            Query.ExecSQL;
        except
          On E: Exception do begin
            Error := True;
            Result := False;
            if connInTransaction then
              connRollback;
            MessageError := E.Message;
            Exit;
          end;
        end;
        if B >= CommitRecords then begin
          try
            if connInTransaction then begin
              if Assigned(FServerMethod) then begin
                if Assigned(FServerMethod.OnMassiveAfterBeforeCommit) then
                  FServerMethod.OnMassiveAfterBeforeCommit(MassiveDataset);
              end;
              connCommit;
              if Assigned(FServerMethod) then begin
                if Assigned(FServerMethod.OnMassiveAfterAfterCommit) then
                  FServerMethod.OnMassiveAfterAfterCommit(MassiveDataset);
              end;
            end;
          except
            On E: Exception do begin
              Error := True;
              Result := False;
              MessageError := E.Message;
              if connInTransaction then
                connRollback;
              Break;
            end;
          end;
          B := 1;
        end
        else
          Inc(B);
        MassiveDataset.Next;
      end;

      try
        if connInTransaction then
        begin
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterBeforeCommit) then
              FServerMethod.OnMassiveAfterBeforeCommit(MassiveDataset);
          end;
          connCommit;
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterAfterCommit) then
              FServerMethod.OnMassiveAfterAfterCommit(MassiveDataset);
          end;
        end;
      except
        On E: Exception do begin
          Error := True;
          Result := False;
          MessageError := E.Message;
          if connInTransaction then
            connRollback;
        end;
      end;
    finally
      if Assigned(FServerMethod) then begin
        if Assigned(FServerMethod.OnMassiveEnd) then
          FServerMethod.OnMassiveEnd(MassiveDataset);
      end;
      FreeAndNil(MassiveDataset);
      Query.Filter := '';
      Query.Filtered := False;
    end;
  end;
begin
  {$IFNDEF FPC}inherited;{$ENDIF}
  try
    Result := nil;
    Error := False;
    vTempQuery := getTable;
    vDataSet := TDataSet(vTempQuery.Owner);
    vValueKeys := TRESTDWValueKeys.Create;
    if not isConnected then
      Connect;
    vTempQuery.Filter := '';
    vResultReflection := '';
    if LoadMassive(vTempQuery) then begin
      if (vResultReflection = '') then begin
        try
          vTempQuery.Filter := '';
          vTempQuery.Filtered := False;
          vTempQuery.ImportParams(Params);
          vTempQuery.Open;
          vTempQuery.FetchAll;
          if Result = nil then
            Result := TJSONValue.Create;
          Result.Encoding := Encoding;
          Result.Encoded := EncodeStringsJSON;
          {$IFDEF FPC}
            Result.DatabaseCharSet := DatabaseCharSet;
          {$ENDIF}
          Result.Utf8SpecialChars := True;
          Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner),EncodeStringsJSON);
          Error := False;
        except
          On E: Exception do  begin
            try
              Error := True;
              MessageError := E.Message;
              if Result = nil then
                Result := TJSONValue.Create;
              Result.Encoded := True;
              {$IFDEF FPC}
                Result.DatabaseCharSet := DatabaseCharSet;
              {$ENDIF}
              Result.SetValue(GetPairJSONStr('NOK', MessageError));
              connRollback;
            except
            end;
          end;
        end;
      end
      else if (vResultReflection <> '') then begin
        if Result = nil then
          Result := TJSONValue.Create;
        Result.Encoding := Encoding;
        Result.Encoded := EncodeStringsJSON;
        {$IFDEF FPC}
          Result.DatabaseCharSet := DatabaseCharSet;
        {$ENDIF}
        Result.SetValue('[' + vResultReflection + ']');
        Error := False;
      end;
    end;
  finally
    RowsAffected := vTempQuery.RecordCount;
    vTempQuery.Close;
    FreeAndNil(vTempQuery);
    FreeAndNil(vValueKeys);
  end;
end;

Function TRESTDWDriverBase.ApplyUpdates_MassiveCache  (MassiveStream         : TStream;
                                                       Var Error             : Boolean;
                                                       Var MessageError      : String) : TJSONValue;
Var
 MassiveDataset : TMassiveDatasetBuffer;
 aMassive       : TStream;
 BufferStream   : TRESTDWBufferBase; //Pacote de Entrada
 vLineString    : String;
Begin
 aMassive       := Nil;
 MassiveDataset := Nil;
 vLineString    := '';
 Result         := Nil;
 BufferStream   := TRESTDWBufferBase.Create;
 Try
  BufferStream.LoadToStream(MassiveStream);
  Try
   If Not isConnected Then
    Connect;
   If not connInTransaction Then
    connStartTransaction;
   If Assigned(FServerMethod) Then
    Begin
     If Assigned(FServerMethod.OnMassiveAfterStartTransaction) Then
      FServerMethod.OnMassiveAfterStartTransaction(MassiveDataset);
    End;
    While Not BufferStream.Eof Do
     Begin
      Try
       aMassive       := BufferStream.ReadStream;
       If aMassive <> Nil Then
        Begin
         MassiveDataset := TMassiveDatasetBuffer.Create(nil);
         MassiveDataset.LoadFromStream(aMassive);
         If vLineString = '' Then
          vLineString := ApplyUpdates_MassiveCache(MassiveDataset, Error, MessageError)
         Else
          vLineString := vLineString + ', ' + ApplyUpdates_MassiveCache(MassiveDataset, Error, MessageError);
         If Error Then
          Break;
        End;
      Finally
       If Assigned(MassiveDataset) Then
        FreeAndNil(MassiveDataset);
       If Assigned(aMassive) Then
        FreeAndNil(aMassive);
      End;
     End;
  Finally
   If connInTransaction Then
    Begin
     If Assigned(FServerMethod) Then
      Begin
       If Assigned(FServerMethod.OnMassiveAfterBeforeCommit) Then
        FServerMethod.OnMassiveAfterBeforeCommit(MassiveDataset);
      End;
     connCommit;
     If Assigned(FServerMethod) Then
      If Assigned(FServerMethod.OnMassiveAfterAfterCommit) Then
       FServerMethod.OnMassiveAfterAfterCommit(MassiveDataset);
    End;
  End;
 Finally
  Result := TJSONValue.Create;
  If (vLineString <> '') Then
   Begin
    Result.Encoding := Encoding;
    Result.Encoded := EncodeStringsJSON;
    Result.SetValue('[' + vLineString + ']');
    Error := False;
   End
  Else
   Result.SetValue('[]');
  FreeAndNil(BufferStream);
 End;
End;

Function TRESTDWDriverBase.ApplyUpdates_MassiveCache  (MassiveDataset   : TMassiveDatasetBuffer;
                                                       Var Error        : Boolean;
                                                       Var MessageError : String): String;
var
 vTempQuery        : TRESTDWDrvQuery;
 vStateResource,
 vMassiveLine      : boolean;
 vResultReflection : string;
 Function LoadMassive(Var Query : TRESTDWDrvQuery) : Boolean;
 Var
  A : integer;
 Begin
  Result := False;
  Try
   MassiveDataset.First;
   If Assigned(FServerMethod) Then
    Begin
     If Assigned(FServerMethod.OnMassiveBegin) Then
      FServerMethod.OnMassiveBegin(MassiveDataset);
    End;
   For A := 1 to MassiveDataset.RecordCount Do
    Begin
     Query.SQL.Clear;
     If Assigned(FServerMethod) Then
      Begin
       vMassiveLine := False;
       If Assigned(FServerMethod.OnMassiveProcess) Then
        Begin
         FServerMethod.OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End;
      PrepareDataQuery(Query, MassiveDataset, nil, True, vResultReflection,  Error, MessageError);
      Try
       If (Not (MassiveDataset.ReflectChanges)) Or
          ((MassiveDataset.ReflectChanges)      And
          (MassiveDataset.MassiveMode In [mmExec, mmDelete])) Then
        Begin
         Query.ExecSQL;
         // Inclusão do método de after massive line process
         If Assigned(FServerMethod) Then
          Begin
           If Assigned(FServerMethod.OnAfterMassiveLineProcess) then
            FServerMethod.OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query.Owner));
          End;
        End;
      Except
       On E: Exception Do
        Begin
         Error := True;
         Result := False;
         MessageError := E.Message;
         If connInTransaction Then
          connRollback;
         Exit;
        End;
      End;
     MassiveDataset.Next;
    End;
  Finally
   If Not Error Then
    Begin
     Try
      Result := True;
     Except
      On E: Exception Do
       Begin
        Error := True;
        Result := False;
        MessageError := E.Message;
        If connInTransaction then
         connRollback;
       End;
     End;
    End;
   If Assigned(FServerMethod) Then
    If Assigned(FServerMethod.OnMassiveEnd) Then
     FServerMethod.OnMassiveEnd(MassiveDataset);
  End;
 End;
Begin
 {$IFNDEF FPC}inherited;{$ENDIF}
  vResultReflection := '';
  Result := '';
  try
    Error := False;
    vTempQuery := getQuery;
    vStateResource := isConnected;
    if not vStateResource then
      Connect;
    vTempQuery.SQL.Clear;
    LoadMassive(vTempQuery);
    if (vResultReflection <> '') Then
     Begin
      Result := vResultReflection;
      Error := False;
     End
    Else
     Result := '';
    If Not vStateResource Then
     Disconect;
  Finally
   vTempQuery.Close;
   vTempQuery.Free;
  End;
end;

Function TRESTDWDriverBase.ApplyUpdates_MassiveCache  (MassiveCache     : String;
                                                       Var Error        : Boolean;
                                                       Var MessageError : String): TJSONValue;
var
  vTempQuery: TRESTDWDrvQuery;
  vStateResource, vMassiveLine: boolean;
  vResultReflection: string;
  function LoadMassive(var Query: TRESTDWDrvQuery): boolean;
  var
    MassiveDataset: TMassiveDatasetBuffer;
    A, X: integer;
    bJsonValueB: TRESTDWJSONInterfaceBase;
    bJsonValue: TRESTDWJSONInterfaceObject;
    bJsonArray: TRESTDWJSONInterfaceArray;
  begin
    MassiveDataset := TMassiveDatasetBuffer.Create(nil);
    bJsonValue := TRESTDWJSONInterfaceObject.Create(MassiveCache);
    bJsonArray := TRESTDWJSONInterfaceArray(bJsonValue);
    Result := False;
    try
      for x := 0 to bJsonArray.ElementCount - 1 do begin
        bJsonValueB := bJsonArray.GetObject(X);
        if not connInTransaction then begin
          connStartTransaction;
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveAfterStartTransaction) then
              FServerMethod.OnMassiveAfterStartTransaction(MassiveDataset);
          end;
        end;
        try
          MassiveDataset.FromJSON(TRESTDWJSONInterfaceObject(bJsonValueB).ToJSON);
          MassiveDataset.First;
          if Assigned(FServerMethod) then begin
            if Assigned(FServerMethod.OnMassiveBegin) then
              FServerMethod.OnMassiveBegin(MassiveDataset);
          end;
          for A := 1 to MassiveDataset.RecordCount do begin
            Query.SQL.Clear;
            if Assigned(FServerMethod) then begin
              vMassiveLine := False;
              if Assigned(FServerMethod.OnMassiveProcess) then  begin
                FServerMethod.OnMassiveProcess(MassiveDataset, vMassiveLine);
                if vMassiveLine then begin
                  MassiveDataset.Next;
                  Continue;
                end;
              end;
            end;
            PrepareDataQuery(Query, MassiveDataset, nil, MassiveDataset.ReflectChanges, vResultReflection,  Error, MessageError);
            try
              if (not (MassiveDataset.ReflectChanges)) or
                ((MassiveDataset.ReflectChanges) and
                (MassiveDataset.MassiveMode in [mmExec, mmDelete])) then
              begin
                Query.ExecSQL;

                // Inclusão do método de after massive line process
                if Assigned(FServerMethod) then begin
                  if Assigned(FServerMethod.OnAfterMassiveLineProcess) then
                    FServerMethod.OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query.Owner));
                end;
              end;
            except
              On E: Exception do begin
                Error := True;
                Result := False;
                MessageError := E.Message;
                if connInTransaction then
                  connRollback;
                Exit;
              end;
            end;
            MassiveDataset.Next;
          end;
        finally
          Query.SQL.Clear;
          FreeAndNil(bJsonValueB);
        end;
      end;
      if not Error then begin
        try
          Result := True;
          if connInTransaction then begin
            if Assigned(FServerMethod) then begin
              if Assigned(FServerMethod.OnMassiveAfterBeforeCommit) then
                FServerMethod.OnMassiveAfterBeforeCommit(MassiveDataset);
            end;
            connCommit;
            if Assigned(FServerMethod) then begin
              if Assigned(FServerMethod.OnMassiveAfterAfterCommit) then
                FServerMethod.OnMassiveAfterAfterCommit(MassiveDataset);
            end;
          end;
        except
          On E: Exception do
          begin
            Error := True;
            Result := False;
            MessageError := E.Message;
            if connInTransaction then
              connRollback;
          end;
        end;
      end;
      if Assigned(FServerMethod) then begin
        if Assigned(FServerMethod.OnMassiveEnd) then
          FServerMethod.OnMassiveEnd(MassiveDataset);
      end;
    finally
      FreeAndNil(bJsonValue);
      FreeAndNil(MassiveDataset);
    end;
  end;

begin
 {$IFNDEF FPC}inherited;{$ENDIF}
  vResultReflection := '';
  Result := nil;
  try
    Error := False;
    vTempQuery := getQuery;
    vStateResource := isConnected;
    if not vStateResource then
      Connect;
    vTempQuery.SQL.Clear;

    LoadMassive(vTempQuery);

    Result := TJSONValue.Create;
    if (vResultReflection <> '') then begin
      Result.Encoding := Encoding;
      Result.Encoded := EncodeStringsJSON;
      Result.SetValue('[' + vResultReflection + ']');
      Error := False;
    end
    else
      Result.SetValue('[]');

    if not vStateResource then
      Disconect;
  finally
    vTempQuery.Close;
    vTempQuery.Free;
  end;
end;

Function TRESTDWDriverBase.ApplyUpdates_MassiveCacheTB(MassiveStream         : TStream;
                                                       Var Error             : Boolean;
                                                       Var MessageError      : String) : TJSONValue;
Begin

End;

Function TRESTDWDriverBase.ApplyUpdates_MassiveCacheTB(MassiveCache     : String;
                                                       Var Error        : Boolean;
                                                       Var MessageError : String): TJSONValue;
Begin

End;

Function TRESTDWDriverBase.ProcessMassiveSQLCache(MassiveSQLCache: String;
                                                  var Error: Boolean;
                                                  var MessageError: String): TJSONValue;
Var
 vTempQuery        : TRESTDWDrvQuery;
 vStateResource    : Boolean;
 vResultReflection : String;

 Function LoadMassive(Var Query : TRESTDWDrvQuery) : Boolean;
 Var
  X        : Integer;
  vMassiveSQLMode : TMassiveSQLMode;
  vSQL,
  vParamsString,
  vBookmark,
  vParamName      : String;
  vBinaryRequest  : Boolean;
  vDWParams       : TRESTDWParams;
  bJsonValueB     : TRESTDWJSONInterfaceBase;
  bJsonValue      : TRESTDWJSONInterfaceObject;
  bJsonArray      : TRESTDWJSONInterfaceArray;
 Begin
  bJsonValue     := TRESTDWJSONInterfaceObject.Create(MassiveSQLCache);
  bJsonArray     := TRESTDWJSONInterfaceArray(bJsonValue);
  Result         := False;
  Try
   For X := 0 To bJsonArray.ElementCount -1 Do Begin
     bJsonValueB := bJsonArray.GetObject(X);
     If Not connInTransaction Then
       connStartTransaction;
     vDWParams          := TRESTDWParams.Create;
     vDWParams.Encoding := Encoding;
     Try
      vMassiveSQLMode := MassiveSQLMode(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[0].Value);
      vSQL            := StringReplace(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF}), #$B, ' ', [rfReplaceAll]);
      vParamsString   := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[2].Value{$IFDEF FPC}, csUndefined{$ENDIF});
      vBookmark       := TRESTDWJSONInterfaceObject(bJsonValueB).pairs[3].Value;
      vBinaryRequest  := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[4].Value);

      vDWParams.FromJSON(vParamsString, vBinaryRequest);
      Query.Close;
      Case vMassiveSQLMode Of
       msqlQuery    :; //TODO
       msqlExecute  : Begin
                       Query.SQL.Text := vSQL;
                       Query.ImportParams(vDWParams);
                       Query.ExecSQL;
                      End;
      end;
     Finally
      Query.SQL.Clear;
      FreeAndNil(bJsonValueB);
      FreeAndNil(vDWParams);
     End;
    End;
   If Not Error Then
    Begin
     Try
      Result := True;
      If connInTransaction Then
        connCommit;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
         connRollback;
        MessageError := E.Message;
       End;
     End;
    End;
  Finally
   FreeAndNil(bJsonValue);
  End;
 End;
Begin
  {$IFNDEF FPC}Inherited;{$ENDIF}
  vResultReflection := '';
  Result     := Nil;
  Try
    Error      := False;
    vTempQuery := getQuery;
    vStateResource := isConnected;
    If Not vStateResource Then
      Connect;
    vTempQuery.SQL.Clear;
    LoadMassive(vTempQuery);
    If Result = Nil Then
      Result := TJSONValue.Create;
    If (vResultReflection <> '') Then Begin
      Result.Encoding := Encoding;
      Result.Encoded  := EncodeStringsJSON;
      Result.SetValue('[' + vResultReflection + ']');
      Error         := False;
    End
    Else
     Result.SetValue('[]');
    If Not vStateResource Then
      Disconect;
  Finally
    vTempQuery.Close;
    vTempQuery.Free;
  End;
end;

Function TRESTDWDriverBase.ExecuteCommand(SQL                   : String;
                                          Var Error             : Boolean;
                                          Var MessageError      : String;
                                          Var BinaryBlob        : TMemoryStream;
                                          Var RowsAffected      : Integer;
                                          Execute               : Boolean = False;
                                          BinaryEvent           : Boolean = False;
                                          MetaData              : Boolean = False;
                                          BinaryCompatibleMode  : Boolean = False) : String;
Begin
 Result := ExecuteCommand(SQL, Nil, Error, MessageError, BinaryBlob, RowsAffected,
                          Execute, BinaryEvent, MetaData, BinaryCompatibleMode);
End;

Function TRESTDWDriverBase.ExecuteCommand(SQL                   : String;
                                          Params                : TRESTDWParams;
                                          Var Error             : Boolean;
                                          Var MessageError      : String;
                                          Var BinaryBlob        : TMemoryStream;
                                          Var RowsAffected      : Integer;
                                          Execute               : Boolean = False;
                                          BinaryEvent           : Boolean = False;
                                          MetaData              : Boolean = False;
                                          BinaryCompatibleMode  : Boolean = False): String;
var
  vTempQuery: TRESTDWDrvQuery;
  vDataSet: TDataSet;
  vStateResource: boolean;
  aResult: TJSONValue;
begin
 {$IFNDEF FPC}inherited;{$ENDIF}
  Error := False;
  Result := '';
  aResult := TJSONValue.Create;
  vTempQuery := getQuery;
  vDataSet := TDataSet(vTempQuery.Owner);
  try
    vStateResource := isConnected;
    if not vStateResource then
      Connect;

    if not connInTransaction then
      connStartTransaction;

    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Text := SQL;
    vTempQuery.ImportParams(Params);
    if not Execute then begin
      if Assigned(Self.OnQueryBeforeOpen) then
        Self.OnQueryBeforeOpen(vDataSet, Params);
       vTempQuery.Open;
       vTempQuery.FetchAll;
      if connInTransaction then
        connCommit;
      if aResult = nil then
        aResult := TJSONValue.Create;
      aResult.Encoding := Encoding;
      try

        if not BinaryEvent then  begin
          aResult.Utf8SpecialChars := True;
          aResult.LoadFromDataset('RESULTDATA', vDataSet, EncodeStringsJSON);
          Result := aResult.ToJSON;
        end
        else if not BinaryCompatibleMode then begin
          if not Assigned(BinaryBlob) then
            BinaryBlob := TMemoryStream.Create;
          try
            vTempQuery.SaveToStream(BinaryBlob);
            BinaryBlob.Position := 0;
          finally
          end;
        end
        else begin
          if not Assigned(BinaryBlob) then
            BinaryBlob := TMemoryStream.Create;

          try
            vTempQuery.FStorageDataType := FStorageDataType;
            vTempQuery.SaveToStreamCompatibleMode(BinaryBlob);
            BinaryBlob.Position := 0;
          finally

          end;
        end;
      finally
      end;
    end
    else begin
      if Assigned(Self.OnQueryBeforeOpen) then
        Self.OnQueryBeforeOpen(vDataSet, Params);
      vTempQuery.ExecSQL;
      if aResult = nil then
        aResult := TJSONValue.Create;
      if connInTransaction then
        connCommit;
      aResult.SetValue('COMMANDOK');
      Result := aResult.ToJSON;
    end;

    if not vStateResource then
      Disconect
  except
    On E: Exception do begin
      try
        Error := True;
        MessageError := E.Message;

        if aResult = nil then
          aResult := TJSONValue.Create;
        aResult.Encoded := True;
        aResult.SetValue(GetPairJSONStr('NOK', MessageError));
        Result := aResult.ToJSON;

        if connInTransaction then
          connRollback;

        if Assigned(Self.OnQueryException) then
          Self.OnQueryException(vDataSet, Params, E.Message);
      except

      end;
      Disconect;
    end;
  end;
  FreeAndNil(aResult);
  RowsAffected := vTempQuery.RowsAffected;
  vTempQuery.Close;
  vDataSet := nil;
  FreeAndNil(vTempQuery);
end;

Function TRESTDWDriverBase.ExecuteCommandTB(Tablename: String;
                                            var Error: Boolean;
                                            var MessageError: String;
                                            var BinaryBlob: TMemoryStream;
                                            var RowsAffected: Integer;
                                            BinaryEvent: Boolean;
                                            MetaData: Boolean;
                                            BinaryCompatibleMode: Boolean): String;
begin
  ExecuteCommandTB(Tablename,nil,Error,MessageError,BinaryBlob,RowsAffected,
                   BinaryEvent,MetaData,BinaryCompatibleMode);
end;

Function TRESTDWDriverBase.ExecuteCommandTB(Tablename: String;
                                            Params: TRESTDWParams;
                                            var Error: Boolean;
                                            var MessageError: String;
                                            var BinaryBlob: TMemoryStream;
                                            var RowsAffected: Integer;
                                            BinaryEvent: Boolean; MetaData: Boolean;
                                            BinaryCompatibleMode: Boolean): String;
var
  vTempQuery     : TRESTDWDrvTable;
  vDataset       : TDataset;
  aResult        : TJSONValue;
  vStateResource : Boolean;
begin
  {$IFNDEF FPC}Inherited;{$ENDIF}
  Error  := False;
  aResult := TJSONValue.Create;
  vTempQuery := getTable;
  vDataset := TDataset(vTempQuery.Owner);
  try
    vStateResource := isConnected;
    if not vStateResource then
      Connect;

    vTempQuery.TableName    := TableName;
    if Assigned(Self.OnTableBeforeOpen) then
      Self.OnTableBeforeOpen(vDataset, Params, TableName);

    vTempQuery.Open;

    if aResult = nil Then
      aResult := TJSONValue.Create;

    aResult.Encoded         := EncodeStringsJSON;
    aResult.Encoding        := Encoding;
    {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
    {$ENDIF}
    try
      if Not BinaryEvent then begin
        aResult.Utf8SpecialChars := True;
        aResult.LoadFromDataset('RESULTDATA', TDataset(vTempQuery.Owner), EncodeStringsJSON);
        Result := aResult.ToJson;
      end
      else if not BinaryCompatibleMode then begin
        if not Assigned(BinaryBlob) then
          BinaryBlob := TMemoryStream.Create;
        try
          vTempQuery.SaveToStream(BinaryBlob);
          BinaryBlob.Position := 0;
        finally

        end;
      end
      else begin
        if not Assigned(BinaryBlob) then
          BinaryBlob := TMemoryStream.Create;
        try
          vTempQuery.FStorageDataType := FStorageDataType;
          vTempQuery.SaveToStreamCompatibleMode(BinaryBlob);
          BinaryBlob.Position := 0;
        finally

        end;
      end;

      if not vStateResource then
        Connect;

      if not vStateResource then
        Disconect;
    finally
      FreeAndNil(aResult);
    end;
  except
    on E : Exception do begin
      try
        Error                   := True;
        MessageError            := E.Message;
        if aResult = Nil then
          aResult := TJSONValue.Create;

        aResult.Encoded         := True;
        aResult.Encoding        := Encoding;
        {$IFDEF FPC}
          aResult.DatabaseCharSet := DatabaseCharSet;
        {$ENDIF}
        aResult.SetValue(GetPairJSONStr('NOK', MessageError));
        Result := aResult.ToJson;

        FreeAndNil(aResult);
        connRollback;
        Disconect;
      except

      end;
   end;
 end;

 vTempQuery.Close;
 vTempQuery.Free;
end;

Procedure TRESTDWDriverBase.ExecuteProcedure(ProcName         : String;
                                             Params           : TRESTDWParams;
                                             Var Error        : Boolean;
                                             Var MessageError : String);
Var
 vStateResource  : Boolean;
 vTempStoredProc : TRESTDWDrvStoreProc;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
  Error  := False;

  vStateResource := isConnected;
  if not vStateResource Then
    Connect;

  if not connInTransaction then
    connStartTransaction;

  vTempStoredProc := getStoreProc;
  try
    try
      vTempStoredProc.StoredProcName := ProcName;
      vTempStoredProc.ImportParams(Params);
      vTempStoredProc.ExecProc;

      if not connInTransaction then
        connCommit;

      if not vStateResource Then
        Disconect;
    except
      on E : Exception do begin
        try
          if connInTransaction Then
            connRollback;
        except

        end;
        Error := True;
        MessageError := E.Message;
        Disconect;
     end;
   end;
  finally
    vTempStoredProc.Free;
  end;
end;

Procedure TRESTDWDriverBase.ExecuteProcedurePure(ProcName         : String;
                                                 Var Error        : Boolean;
                                                 Var MessageError : String);
Begin
 ExecuteProcedure(ProcName, nil, Error, MessageError);
End;

Procedure TRESTDWDriverBase.GetTableNames(Var TableNames   : TStringList;
                                          Var Error        : Boolean;
                                          Var MessageError : String);
Var
 vStateResource : Boolean;
 connType : TRESTDWDatabaseType;
 qry : TRESTDWDrvQuery;
 vSchema, vTable, vCatalog : String;
 fdPos : integer;
Begin
 If Not Assigned(TableNames) Then
  TableNames := TStringList.Create;

 TableNames.Sorted := True;
 vSchema := '';
{
  if Pos('.', vTable) > 0 then begin
    vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
    Delete(vTable, InitStrPos, Pos('.', vTable));
  end;
}
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  fdPos := 0;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird : Begin
                   qry.SQL.Add('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS');
                   qry.SQL.Add('ORDER BY RDB$RELATION_NAME');
                   qry.Open;
                  End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS');
                    qry.SQL.Add('ORDER BY RDB$RELATION_NAME');
                    qry.Open;
                   End;
    dbtMySQL     : Begin
                    qry.Close;
                    qry.SQL.Clear;
                    qry.SQL.Add('SHOW TABLES');
                    qry.Open;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('SELECT N.NSPNAME || ''.'' || C.RELNAME');
                     qry.SQL.Add('FROM PG_CATALOG.PG_CLASS C');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = C.RELNAMESPACE');
                     qry.SQL.Add('WHERE C.RELKIND = ''r'' and N.NSPNAME <> ''information_schema'' and ');
                     qry.SQL.Add('      N.NSPNAME <> ''pg_catalog'' and N.NSPNAME <> ''dbo'' and ');
                     qry.SQL.Add('      N.NSPNAME <> ''sys'' and SUBSTR(C.RELNAME, 1, 3) <> ''pg_'' ');
                     If vSchema <> '' Then
                      qry.SQL.Add(' and lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
                     qry.Open;
                    End;
    dbtSQLLite    : Begin
                     qry.SQL.Add('SELECT name FROM sqlite_master');
                     qry.SQL.Add('WHERE type=''table''');
                     qry.Open;
                    End;
    dbtMsSQL      : Begin
                     qry.SQL.Add('select concat(user_name(uid),''.'',name)');
                     qry.SQL.Add('from sysobjects');
                     qry.SQL.Add('where type in (''U'',''V'')');
                     qry.Open;
                    End;
    dbtOracle     : Begin
                     qry.SQL.Add('SELECT sys_context(''userenv'',''current_schema'') || ''.'' || table_name');
                     qry.SQL.Add('FROM USER_CATALOG');
                     qry.SQL.Add('WHERE TABLE_TYPE <> ''SEQUENCE''');
                     qry.Open;
                    End;

   End;
   While Not qry.Eof Do
    Begin
     vTable := Trim(qry.Fields[fdPos].AsString);
     vTable := AnsiReplaceStr(vTable,'"','');
     TableNames.Add(vTable);
     qry.Next;
    End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
End;

Procedure TRESTDWDriverBase.GetFieldNames(TableName        : String;
                                          Var FieldNames   : TStringList;
                                          Var Error        : Boolean;
                                          Var MessageError : String);
Var
 vStateResource : Boolean;
 connType       : TRESTDWDatabaseType;
 qry            : TRESTDWDrvQuery;
 vTable, sFields,
 vSchema        : String;
 fPos           : Integer;
Begin
 If Not Assigned(FieldNames) Then
  FieldNames := TStringList.Create;
 vSchema := '';
 vTable := TableName;
 If Pos('.', vTable) > 0 Then
  Begin
   vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
   Delete(vTable, InitStrPos, Pos('.', vTable));
  End;
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  fPos := 0;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird  : Begin
                    qry.SQL.Add('SELECT RDB$FIELD_NAME FROM RDB$RELATION_FIELDS ');
                    qry.SQL.Add('WHERE RDB$RELATION_NAME='+QuotedStr(UpperCase(vTable)));
                    qry.Open;
                   End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT RDB$FIELD_NAME FROM RDB$RELATION_FIELDS ');
                    qry.SQL.Add('WHERE RDB$RELATION_NAME='+QuotedStr(UpperCase(vTable)));
                    qry.Open;
                   End;
    dbtMySQL     : Begin
                    qry.SQL.Add('SHOW COLUMNS FROM '+vTable);
                    qry.Open;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('SELECT A.ATTNAME');
                     qry.SQL.Add('FROM PG_CATALOG.PG_CLASS C');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = C.RELNAMESPACE');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_ATTRIBUTE A ON A.ATTRELID = C.OID');
                     qry.SQL.Add('WHERE A.ATTNUM > 0 AND NOT A.ATTISDROPPED AND');
                     qry.SQL.Add('      lower(C.RELNAME) = '+QuotedStr(LowerCase(vTable)));
                     If vSchema <> '' Then
                      qry.SQL.Add('    and lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
                     qry.Open;
                    End;
    dbtSQLLite    : Begin
                     fPos := 1;
                     qry.SQL.Add('PRAGMA table_info('+vTable+')');
                     qry.Open;
                    End;
    dbtMsSQL      : Begin
                     qry.SQL.Add('select c.name');
                     qry.SQL.Add('from syscolumns c');
                     qry.SQL.Add('join sysobjects o on c.id=o.id');
                     qry.SQL.Add('where c.id=object_id('+QuotedStr(vTable)+')');
                     If vSchema <> '' Then
                      qry.SQL.Add('      and user_name(o.uid) = '+QuotedStr(vSchema));
                     qry.Open;
                    End;
    dbtOracle     : Begin
                     qry.SQL.Add('SELECT COLUMN_NAME');
                     qry.SQL.Add('FROM ALL_TAB_COLUMNS');
                     qry.SQL.Add('WHERE upper(TABLE_NAME) = '+QuotedStr(UpperCase(vTable)));
                     If vSchema <> '' Then
                      qry.SQL.Add('      and upper(OWNER) = '+QuotedStr(UpperCase(vSchema)));
                     qry.Open;
                    End;
   End;
   While Not qry.Eof Do
    Begin
     sFields := Trim(qry.Fields[fPos].AsString);
     sFields := AnsiReplaceStr(sFields,'"','');

     FieldNames.Add(sFields);
     qry.Next;
    End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
end;

Procedure TRESTDWDriverBase.GetKeyFieldNames(TableName        : String;
                                             Var FieldNames   : TStringList;
                                             Var Error        : Boolean;
                                             Var MessageError : String);
Var
 vStateResource : Boolean;
 connType       : TRESTDWDatabaseType;
 qry            : TRESTDWDrvQuery;
 vTable, sFields,
 vSchema        : String;
Begin
 If Not Assigned(FieldNames) Then
  FieldNames := TStringList.Create;
 vSchema := '';
 vTable := TableName;
 If Pos('.', vTable) > 0     Then
  Begin
   vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
   Delete(vTable, InitStrPos, Pos('.', vTable));
  End;
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird  : Begin
                    qry.SQL.Add('SELECT S.RDB$FIELD_NAME');
                    qry.SQL.Add('FROM RDB$RELATION_CONSTRAINTS C, RDB$INDEX_SEGMENTS S');
                    qry.SQL.Add('WHERE C.RDB$RELATION_NAME = '+QuotedStr(AnsiUpperCase(vTable))+' AND');
                    qry.SQL.Add('      C.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' AND');
                    qry.SQL.Add('      S.RDB$INDEX_NAME = C.RDB$INDEX_NAME');
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      sFields := Trim(qry.FieldByName('RDB$FIELD_NAME').AsString);
                      sFields := AnsiReplaceStr(sFields,'"','');
                      FieldNames.Add(sFields);
                      qry.Next;
                     End;
                   End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT S.RDB$FIELD_NAME');
                    qry.SQL.Add('FROM RDB$RELATION_CONSTRAINTS C, RDB$INDEX_SEGMENTS S');
                    qry.SQL.Add('WHERE C.RDB$RELATION_NAME = '+QuotedStr(AnsiUpperCase(vTable))+' AND');
                    qry.SQL.Add('      C.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' AND');
                    qry.SQL.Add('      S.RDB$INDEX_NAME = C.RDB$INDEX_NAME');
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      sFields := Trim(qry.FieldByName('RDB$FIELD_NAME').AsString);
                      sFields := AnsiReplaceStr(sFields,'"','');
                      FieldNames.Add(sFields);
                      qry.Next;
                     End;
                   End;
    dbtMySQL     : Begin
                    qry.SQL.Add('SHOW INDEX FROM '+vTable);
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      If (Pos('PRIMARY', UpperCase(qry.FieldByName('KEY_NAME').AsString)) > 0) Then Begin
                        sFields := Trim(qry.FieldByName('COLUMN_NAME').AsString);
                        sFields := AnsiReplaceStr(sFields,'"','');
                       FieldNames.Add(sFields);
                      End;
                      qry.Next;
                     End;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('SELECT A.ATTNAME');
                     qry.SQL.Add('FROM PG_CATALOG.PG_INDEX I');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_CLASS TC ON TC.OID = I.INDRELID');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_CLASS IC ON IC.OID = I.INDEXRELID');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_ATTRIBUTE A ON A.ATTRELID = I.INDRELID AND');
                     qry.SQL.Add('           A.ATTNUM = ANY(I.INDKEY)');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = TC.RELNAMESPACE');
                     qry.SQL.Add('WHERE lower(TC.RELNAME) = '+QuotedStr(LowerCase(vTable))+' and ');
                     qry.SQL.Add('      I.INDISPRIMARY ');
                     If vSchema <> '' Then
                      qry.SQL.Add('  AND lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
                     qry.Open;
                     While Not qry.Eof Do
                      Begin
                       sFields := Trim(qry.FieldByName('ATTNAME').AsString);
                       sFields := AnsiReplaceStr(sFields,'"','');
                       FieldNames.Add(sFields);
                       qry.Next;
                      End;
                    End;
    dbtSQLLite    : Begin
                     qry.SQL.Add('PRAGMA table_info('+vTable+')');
                     qry.Open;
                     While Not qry.Eof Do
                      Begin
                       If qry.FieldByName('pk').AsInteger > 0 Then Begin
                        sFields := Trim(qry.FieldByName('name').AsString);
                        sFields := AnsiReplaceStr(sFields,'"','');
                        FieldNames.Add(sFields);
                       End;
                       qry.Next;
                      End;
                    End;
    dbtMsSQL      : begin
                      qry.SQL.Add('select col.name');
                      qry.SQL.Add('from sys.tables tab');
                      qry.SQL.Add('inner join sys.indexes pk on');
                      qry.SQL.Add('      tab.object_id = pk.object_id and ');
                      qry.SQL.Add('      pk.is_primary_key = 1');
                      qry.SQL.Add('inner join sys.index_columns ic on');
                      qry.SQL.Add('      ic.object_id = tab.object_id and ');
                      qry.SQL.Add('      ic.index_id = pk.index_id');
                      qry.SQL.Add('inner join sys.columns col on');
                      qry.SQL.Add('      ic.object_id = col.object_id');
                      qry.SQL.Add('      and ic.column_id = col.column_id');
                      qry.SQL.Add('where tab.name = '+QuotedStr(LowerCase(vTable)));
                      If vSchema <> '' Then
                        qry.SQL.Add('  and schema_name(tab.schema_id) = '+QuotedStr(LowerCase(vSchema)));
                      qry.Open;
                      While Not qry.Eof Do
                       Begin
                        sFields := Trim(qry.FieldByName('name').AsString);
                        sFields := AnsiReplaceStr(sFields,'"','');
                        FieldNames.Add(sFields);
                        qry.Next;
                       End;
    end;
    dbtOracle     : begin
                      qry.SQL.Add('select cc.column_name,');
                      qry.SQL.Add('from all_constraints c');
                      qry.SQL.Add('inner join all_cons_columns cc on');
                      qry.SQL.Add('      c.constraint_name = cc.constraint_name and');
                      qry.SQL.Add('	  c.owner = cc.owner');
                      qry.SQL.Add('where c.constraint_type = ''P'' and');
                      qry.SQL.Add('      cc.table_name = '+QuotedStr(LowerCase(vSchema)));
                      If vSchema <> '' Then
                        qry.SQL.Add('   and cc.owner = '+QuotedStr(LowerCase(vSchema)));
                      qry.Open;
                      While Not qry.Eof Do
                       Begin
                        sFields := Trim(qry.FieldByName('column_name').AsString);
                        sFields := AnsiReplaceStr(sFields,'"','');
                        FieldNames.Add(sFields);
                        qry.Next;
                       End;
    end;
   End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
End;

Procedure TRESTDWDriverBase.GetProcNames(Var ProcNames    : TStringList;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Var
 vStateResource : Boolean;
 connType       : TRESTDWDatabaseType;
 qry            : TRESTDWDrvQuery;
 vSchema,sProcs : String;
 fPos           : integer;
Begin
 If Not Assigned(ProcNames) Then
  ProcNames := TStringList.Create;
 vSchema := '';
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  fPos := 0;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird  : Begin
                    qry.SQL.Add('SELECT RDB$Procedure_NAME FROM RDB$ProcedureS');
                    qry.Open;
                   End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT RDB$Procedure_NAME FROM RDB$ProcedureS');
                    qry.Open;
                   End;
    dbtMySQL     : Begin
                    fPos := 1; // coluna name
                    qry.SQL.Add('SHOW Procedure STATUS');
                    qry.SQL.Add('WHERE db = DATABASE() AND type = ''Procedure''');
                    qry.Open;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('SELECT N.NSPNAME || ''.'' || P.PRONAME FROM PG_CATALOG.PG_PROC P');
                     qry.SQL.ADD('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = P.PRONAMESPACE');
                     qry.SQL.Add('WHERE P.PROARGNAMES IS NOT NULL');
                     If vSchema <> '' Then
                      qry.SQL.Add('    and lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
                     qry.Open;
                    End;
    dbtSQLLite    : Begin
                     // nao existe Procedures
                    End;
    dbtMsSQL      : Begin
                     qry.SQL.Add('select concat(user_name(uid),''.'',name)');
                     qry.SQL.Add('from sysobjects');
                     qry.SQL.Add('where type in (''P'',''FN'',''IF'',''TF'')');
                     qry.Open;
                    End;
    dbtOracle     : Begin
                     qry.SQL.Add('SELECT case ');
                     qry.SQL.Add('         when Procedure_NAME is null then OBJECT_NAME');
                     qry.SQL.Add('              ELSE OBJECT_NAME || ''.'' || Procedure_NAME');
                     qry.SQL.Add('       end AS Procedure_name');
                     qry.SQL.Add('FROM USER_ProcedureS');
                     qry.Open;
                    End;
   End;
   While Not qry.Eof Do
    Begin
     sProcs := Trim(qry.Fields[fPos].AsString);
     sProcs := AnsiReplaceStr(sProcs,'"','');
     ProcNames.Add(sProcs);
     qry.Next;
    End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
End;

Procedure TRESTDWDriverBase.GetProcParams(ProcName         : String;
                                          Var ParamNames   : TStringList;
                                          Var Error        : Boolean;
                                          Var MessageError : String);
Var
 vStateResource : Boolean;
 connType       : TRESTDWDatabaseType;
 qry            : TRESTDWDrvQuery;
 vProc,
 vSchema, sParam,
 vFieldType     : String;
 vSize,
 vPrecision     : Integer;
 Procedure convertFB_IBTypes;
 Begin
  vFieldType := 'ftUnknown';
  vSize := 0;
  vPrecision := 0;
  Case qry.FieldByName('rdb$field_type').AsInteger Of
   007 : Begin
          vFieldType := 'ftSmallint';
          If qry.FieldByName('rdb$field_sub_type').AsInteger > 0 Then
           vFieldType := 'ftFloat';
         End;
   008 : Begin
          vFieldType := 'ftInteger';
          If qry.FieldByName('rdb$field_sub_type').AsInteger > 0 Then
           vFieldType := 'ftFloat';
         End;
   009 : vFieldType := 'ftLargeint';
   010 : vFieldType := 'ftFloat';
   011 : vFieldType := 'ftFloat';
   012 : vFieldType := 'ftDateTime';
   013 : vFieldType := 'ftTime';
   014 : vFieldType := 'ftFixedChar';
   016 : Begin
          vFieldType := 'ftLargeint';
          If qry.FieldByName('rdb$field_sub_type').AsInteger > 0 Then
           vFieldType := 'ftFloat';
         End;
   027 : vFieldType := 'ftFloat';
   035 : vFieldType := 'ftTimeStamp';
   037 : vFieldType := 'ftString';
   040 : vFieldType := 'ftString';
   261 : Begin
          vFieldType := 'ftBlob';
          If qry.FieldByName('rdb$field_sub_type').AsInteger = 1   Then
           vFieldType := 'ftMemo';
         End;
  End;
  If qry.FieldByName('rdb$field_type').AsInteger in [14,37,40]     Then
   Begin
    vSize := qry.FieldByName('rdb$field_length').AsInteger;
      // field com charset e colation
    If (qry.FieldByName('rdb$character_length').AsInteger > 0)     And
       (qry.FieldByName('rdb$character_length').AsInteger < vSize) Then
        vSize := qry.FieldByName('rdb$character_length').AsInteger;
   End
  Else If qry.FieldByName('rdb$field_type').AsInteger = 27         Then
   Begin
    vSize := qry.FieldByName('rdb$field_precision').AsInteger;
    If (qry.FieldByName('rdb$field_scale').AsInteger < 0) Then
     Begin
      vSize := 15;
      If (qry.FieldByName('rdb$field_precision').AsInteger > 0) Then
       vSize := qry.FieldByName('rdb$field_precision').AsInteger;
      vPrecision := Abs(qry.FieldByName('rdb$field_scale').AsInteger);
     End;
   End
  Else If (qry.FieldByName('rdb$field_type').AsInteger    in [7,8,16]) And
          (qry.FieldByName('rdb$field_sub_type').AsInteger > 0)        Then
   Begin
    vSize := qry.FieldByName('rdb$field_precision').AsInteger;
    If (qry.FieldByName('rdb$field_scale').AsInteger < 0) Then
     Begin
      vSize := 15;
      If (qry.FieldByName('rdb$field_precision').AsInteger > 0) Then
       vSize := qry.FieldByName('rdb$field_precision').AsInteger;
      vPrecision := Abs(qry.FieldByName('rdb$field_scale').AsInteger);
     End;
   End;
 End;
 Procedure convertMySQLTypes;
 Var
  sAux1 : String;
 Begin
  vFieldType := 'ftUnknown';
  vSize      := 0;
  vPrecision := 0;
  sAux1      := LowerCase(qry.FieldByName('data_type').AsString);
  If SameText(sAux1, 'integer')        Or
     SameText(sAux1, 'int')            Then
   vFieldType := 'ftInteger'
  Else If SameText(sAux1, 'smallint')  Or
          SameText(sAux1, 'tinyint')   Or
          SameText(sAux1, 'mediumint') Or
          SameText(sAux1, 'bit')       Then
   vFieldType := 'ftSmallint'
  Else If SameText(sAux1, 'longint')   Or
          SameText(sAux1, 'bigint')    Then
   vFieldType := 'ftLargeint'
  Else If SameText(sAux1, 'real')      Or
          SameText(sAux1, 'decimal')   Or
          SameText(sAux1, 'numeric')   Or
          SameText(sAux1, 'float')     Or
          SameText(sAux1, 'double')    Or
          SameText(sAux1, 'double precision') Then
    Begin
     vFieldType := 'ftFloat';
     vSize      := qry.FieldByName('numeric_precision').AsInteger;
     vPrecision := qry.FieldByName('numeric_scale').AsInteger;
    End
   Else If SameText(sAux1, 'varchar') Then
    Begin
     vFieldType := 'ftString';
     vSize := qry.FieldByName('character_maximum_length').AsInteger;
     If vSize >= 32767 Then
      Begin
       vFieldType := 'ftMemo';
       vSize := 0;
      end;
    End
   Else If SameText(sAux1, 'char') Then
    Begin
     vFieldType := 'ftFixedChar';
     vSize := qry.FieldByName('character_maximum_length').AsInteger;
    End
   Else If SameText(sAux1, 'timestamp')  Then
    vFieldType := 'ftTimeStamp'
   Else if SameText(sAux1, 'time')       Then
    vFieldType := 'ftTime'
   Else If SameText(sAux1, 'datetime')   Then
    vFieldType := 'ftDateTime'
   Else If SameText(sAux1, 'date')       Then
    vFieldType := 'ftDate'
   Else If SameText(sAux1, 'year')       Then
    vFieldType := 'ftSmallint'
   Else If SameText(sAux1, 'blob')       Or
           SameText(sAux1, 'binary')     Or
           SameText(sAux1, 'tinyblob')   Or
           SameText(sAux1,'mediumblob')  Or
           SameText(sAux1,'longblob')    Then
    vFieldType := 'ftBlob'
   Else If SameText(sAux1,  'text')       Or
           SameText(sAux1,  'tinytext')   Or
           SameText(sAux1,  'mediumtext') Or
           SameText(sAux1,  'longtext')   Or
            SameText(sAux1, 'json')       Then
    vFieldType := 'ftMemo';
 End;
 Procedure convertPostgresTypes;
 Var
  sAux1 : String;
 Begin
  vFieldType := 'ftUnknown';
  vSize      := 0;
  vPrecision := 0;
  sAux1      := LowerCase(qry.FieldByName('data_type').AsString);
  If SameText(sAux1, 'integer') Or
     SameText(sAux1, 'int')     Or
    (Pos('int[',sAux1) > 0)     Then
   vFieldType := 'ftInteger'
  Else If SameText(sAux1, 'smallint')  Or
          SameText(sAux1, 'tinyint')   Or
          SameText(sAux1, 'mediumint') Or
          SameText(sAux1, 'bit')       Then
   vFieldType := 'ftSmallint'
  Else If (Pos('bigint', sAux1) > 0)   Then
   vFieldType := 'ftLargeint'
  Else If SameText(sAux1, 'real')    Or
          SameText(sAux1, 'decimal') Or
          SameText(sAux1, 'numeric') Or
          SameText(sAux1, 'float')   Or
          SameText(sAux1, 'double')  Or
          SameText(sAux1, 'double precision') Then
   Begin
    vFieldType := 'ftFloat';
    vSize := 15;
    vPrecision := 6;
   End
  Else If SameText(sAux1, 'varchar')           Or
         (Pos('character varying', sAux1) > 0) Then
   Begin
    vFieldType := 'ftString';
    vSize := 255;
   End
  Else If SameText(sAux1, 'character') Or
         (Pos('character[',sAux1) > 0) Then
   Begin
    vFieldType := 'ftFixedChar';
    vSize := 255;
   End
  Else If (Pos('timestamp', sAux1) > 0) Then
   vFieldType := 'ftTimeStamp'
  Else If SameText(sAux1, 'time')       Or
         (Pos('time with', sAux1) > 0)  Then
   vFieldType := 'ftTime'
  Else If SameText(sAux1, 'date')       Then
   vFieldType := 'ftDate'
  Else If (Pos(sAux1,'bytea') > 0) Then
   vFieldType := 'ftBlob'
  Else If (Pos(sAux1, 'text') > 0)  Or
          (Pos(sAux1, 'json') > 0)  Or
          (Pos(sAux1, 'xml')  > 0)  Then
   vFieldType := 'ftMemo';
 End;
Begin
 // nesta funcão pode ser usado as funcoes
 // getDatabaseInfo ou isMinimumVersion
 // para trazer informacao de versao de cada banco
 If Not Assigned(ParamNames) Then
  ParamNames := TStringList.Create;
 vSchema := '';
 vProc := ProcName;
 If Pos('.', vProc) > 0 Then
  Begin
   vSchema := Copy(vProc, InitStrPos, Pos('.', vProc)-1);
   Delete(vProc, InitStrPos, Pos('.', vProc));
  End;
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird  : Begin
                    qry.SQL.Add('SELECT PP.RDB$PARAMETER_NAME, F.RDB$FIELD_LENGTH,');
                    qry.SQL.Add('       F.RDB$FIELD_TYPE, F.RDB$FIELD_SUB_TYPE,');
                    qry.SQL.Add('       F.RDB$CHARACTER_LENGTH, F.RDB$NULL_FLAG,');
                    qry.SQL.Add('       F.RDB$DEFAULT_SOURCE, CS.RDB$CHARACTER_SET_NAME,');
                    qry.SQL.Add('       CL.RDB$COLLATION_NAME, FD.RDB$LOWER_BOUND, FD.RDB$UPPER_BOUND');
                    qry.SQL.Add('FROM RDB$Procedure_PARAMETERS PP ');
                    qry.SQL.Add('INNER JOIN RDB$FIELDS F ON F.RDB$FIELD_NAME = PP.RDB$FIELD_SOURCE');
                    qry.SQL.Add('LEFT JOIN RDB$CHARACTER_SETS CS ON CS.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID');
                    qry.SQL.Add('LEFT JOIN RDB$COLLATIONS CL ON CL.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID AND');
                    qry.SQL.Add('     CL.RDB$COLLATION_ID = coalesce(F.RDB$COLLATION_ID,RF.RDB$COLLATION_ID)');
                    qry.SQL.Add('LEFT JOIN RDB$FIELD_DIMENSIONS FD ON FD.RDB$FIELD_NAME = F.RDB$FIELD_NAME');
                    qry.SQL.Add('WHERE PP.RDB$Procedure_NAME = '+QuotedStr(UpperCase(vProc))+' AND');
                    qry.SQL.Add('      PP.RDB$PARAMETER_TYPE = 0');
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      convertFB_IBTypes;
                      sParam := Trim(qry.Fields[0].AsString);
                      sParam := AnsiReplaceStr(sParam,'"','');
                      ParamNames.Add(Format(cParamDetails, [sParam,vFieldType,vSize,vPrecision]));
                      qry.Next;
                     End;
                   End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT PP.RDB$PARAMETER_NAME, F.RDB$FIELD_LENGTH,');
                    qry.SQL.Add('       F.RDB$FIELD_TYPE, F.RDB$FIELD_SUB_TYPE,');
                    qry.SQL.Add('       F.RDB$CHARACTER_LENGTH, F.RDB$NULL_FLAG,');
                    qry.SQL.Add('       F.RDB$DEFAULT_SOURCE, CS.RDB$CHARACTER_SET_NAME,');
                    qry.SQL.Add('       CL.RDB$COLLATION_NAME, FD.RDB$LOWER_BOUND, FD.RDB$UPPER_BOUND');
                    qry.SQL.Add('FROM RDB$Procedure_PARAMETERS PP ');
                    qry.SQL.Add('INNER JOIN RDB$FIELDS F ON F.RDB$FIELD_NAME = PP.RDB$FIELD_SOURCE');
                    qry.SQL.Add('LEFT JOIN RDB$CHARACTER_SETS CS ON CS.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID');
                    qry.SQL.Add('LEFT JOIN RDB$COLLATIONS CL ON CL.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID AND');
                    qry.SQL.Add('     CL.RDB$COLLATION_ID = coalesce(F.RDB$COLLATION_ID,RF.RDB$COLLATION_ID)');
                    qry.SQL.Add('LEFT JOIN RDB$FIELD_DIMENSIONS FD ON FD.RDB$FIELD_NAME = F.RDB$FIELD_NAME');
                    qry.SQL.Add('WHERE PP.RDB$Procedure_NAME = '+QuotedStr(UpperCase(vProc))+' AND');
                    qry.SQL.Add('      PP.RDB$PARAMETER_TYPE = 0');
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      convertFB_IBTypes;
                      sParam := Trim(qry.Fields[0].AsString);
                      sParam := AnsiReplaceStr(sParam,'"','');
                      ParamNames.Add(Format(cParamDetails, [sParam,vFieldType,vSize,vPrecision]));
                      qry.Next;
                     End;
                   End;
    dbtMySQL     : Begin
                    // somente mysql maior que 5
                    qry.SQL.Add('SELECT parameter_name, data_type, character_maximum_length,');
                    qry.SQL.Add('       character_octet_length,numeric_precision,numeric_scale,');
                    qry.SQL.Add('       dtd_identifier');
                    qry.SQL.Add('FROM information_schema.parameters');
                    qry.SQL.Add('WHERE SPECIFIC_NAME = '+QuotedStr(vProc)+' AND');
                    qry.SQL.Add('      SPECIFIC_SCHEMA = DATABASE() and');
                    qry.SQL.Add('      ROUTINE_TYPE = ''Procedure'' and');
                    qry.SQL.Add('      PARAMETER_MODE = ''IN''');
                    Try
                     qry.Open;
                     While Not qry.Eof Do
                      Begin
                       convertMySQLTypes;
                       sParam := Trim(qry.Fields[0].AsString);
                       sParam := AnsiReplaceStr(sParam,'"','');
                       ParamNames.Add(Format(cParamDetails, [sParam,vFieldType,vSize,vPrecision]));

                       qry.Next;
                      End;
                    Except

                    End;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('select a.parameter_name, a.data_type');
                     qry.SQL.Add('from information_schema.routines p');
                     qry.SQL.Add('left join information_schema.parameters a on');
                     qry.SQL.Add('          p.specific_schema = a.specific_schema and');
                     qry.SQL.Add('          p.specific_name = a.specific_name');
                     qry.SQL.Add('where p.routine_schema not in (''pg_catalog'', ''information_schema'') and');
                     qry.SQL.Add('      p.routine_type = ''Procedure'' and');
                     qry.SQL.Add('      p.routine_name = '+QuotedStr(vProc)+' and');
                     qry.SQL.Add('      a.parameter_name is not null and');
                     qry.SQL.Add('      a.parameter_mode like ''IN%''');
                     If vSchema <> '' Then
                      qry.SQL.Add('    and p.specific_schema = '+QuotedStr(vSchema));
                     qry.SQL.Add('order by p.specific_schema, p.specific_name, p.routine_name,');
                     qry.SQL.Add('         a.ordinal_position');
                     Try
                      qry.Open;
                      While Not qry.Eof Do
                       Begin
                        convertPostgresTypes;
                        sParam := Trim(qry.Fields[0].AsString);
                        sParam := AnsiReplaceStr(sParam,'"','');
                        ParamNames.Add(Format(cParamDetails, [sParam,vFieldType,vSize,vPrecision]));

                        qry.Next;
                       End;
                     Except

                     End;
                    End;
    dbtSQLLite    : Begin
                     // sqlite nao tem Procedures
                    End;
   End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
End;

Function TRESTDWDriverBase.InsertMySQLReturnID(SQL              : String;
                                               Var Error        : Boolean;
                                               Var MessageError : String) : Integer;
Begin
 Result := InsertMySQLReturnID(SQL, Nil, Error, MessageError);
End;

Function TRESTDWDriverBase.InsertMySQLReturnID(SQL              : String;
                                               Params           : TRESTDWParams;
                                               var Error        : Boolean;
                                               var MessageError : String) : Integer;
Var
 vTempQuery     : TRESTDWDrvQuery;
 vStateResource : Boolean;
Begin
 Result := -1;
 Error  := False;
 If Not Assigned(FConnection) Then
  Exit;
 vTempQuery := getQuery;
 vStateResource := isConnected;
 If Not vStateResource Then
  Connect;
 If Not connInTransaction Then
  connStartTransaction;
 vTempQuery.SQL.Clear;
 vTempQuery.SQL.Add(SQL);
 vTempQuery.ImportParams(Params);
 Result := -1;
 Error  := False;
 Try
  Try
   vTempQuery.ExecSQL;
   Result := vTempQuery.GetInsertID;
   Error := False;
   If connInTransaction Then
    connCommit;
  Finally
  End;
  If Not vStateResource Then
   Disconect
 Except
  On E : Exception Do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result       := -1;
     connRollback;
     Disconect;
    Except
    End;
   End;
 End;
 vTempQuery.Close;
 FreeAndNil(vTempQuery);
End;

Function TRESTDWDriverBase.OpenDatasets(DatasetsLine     : String;
                                        var Error        : Boolean;
                                        var MessageError : String;
                                        var BinaryBlob   : TMemoryStream): TJSONValue;
Var
 vTempQuery      : TRESTDWDrvQuery;
 vTempJSON       : TJSONValue;
 vJSONLine       : String;
 I               : Integer;
 vMetaData,
 vBinaryEvent,
 vStateResource,
 vCompatibleMode : Boolean;
 DWParams        : TRESTDWParams;
 bJsonArray      : TRESTDWJSONInterfaceArray;
 bJsonValue      : TRESTDWJSONInterfaceObject;
 vStream         : TMemoryStream;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error           := False;
 vBinaryEvent    := False;
 vMetaData       := False;
 vCompatibleMode := False;
 bJsonArray      := Nil;
 vTempQuery      := getQuery;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  If Not connInTransaction Then
    connStartTransaction;
  bJsonValue  := TRESTDWJSONInterfaceObject.Create(DatasetsLine);
  For I := 0 To bJsonValue.PairCount - 1 Do
   Begin
    bJsonArray  := bJsonValue.OpenArray(I);
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
    vBinaryEvent    := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[2].Value);
    vMetaData       := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[3].Value);
    vCompatibleMode := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[4].Value);
    If bJsonArray.ElementCount > 1 Then
     Begin
      DWParams := TRESTDWParams.Create;
      Try
       DWParams.FromJSON(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
       vTempQuery.ImportParams(DWParams);
      Finally
       DWParams.Free;
      End;
     End;
    vTempQuery.Open;
    vTempJSON  := TJSONValue.Create;
    vTempJSON.Encoding := Encoding;
    vTempJSON.Utf8SpecialChars := True;
    If Not vBinaryEvent Then
     Begin
      vTempJSON.Utf8SpecialChars := True;
      vTempJSON.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
     End
    Else If vCompatibleMode Then begin
      vStream := TMemoryStream.Create;
      Try
       vTempQuery.FStorageDataType := FStorageDataType;
       vTempQuery.SaveToStreamCompatibleMode(vStream);
       vStream.Position := 0;
      Finally
      End;
    end
    Else
     Begin
      vStream := TMemoryStream.Create;
      Try
       vTempQuery.SaveToStream(vStream);
       vStream.Position := 0;
      Finally
      End;
     End;
    Try
     If Not vBinaryEvent Then
      Begin
       If Length(vJSONLine) = 0 Then
        vJSONLine := Format('%s', [vTempJSON.ToJSON])
       Else
        vJSONLine := vJSONLine + Format(', %s', [vTempJSON.ToJSON]);
      End
     Else
      Begin
       If Length(vJSONLine) = 0 Then
        vJSONLine := Format('{"BinaryRequest":"%s"}', [EncodeStream(vStream)])
       Else
        vJSONLine := vJSONLine + Format(', {"BinaryRequest":"%s"}', [EncodeStream(vStream)]);
       If Assigned(vStream) Then
        FreeAndNil(vStream);
      End;
    Finally
     vTempJSON.Free;
    End;
    FreeAndNil(bJsonArray);
   End;
  If connInTransaction Then
   connCommit;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception do
   Begin
    Disconect;
    Try
     Error          := True;
     MessageError   := E.Message;
     vJSONLine      := GetPairJSONStr('NOK', MessageError);
    Except
    End;
   End;
 End;
 Result             := TJSONValue.Create;
 Result.Encoding    := Encoding;
 Result.ObjectValue := ovString;
 Try
  vJSONLine         := Format('[%s]', [vJSONLine]);
  Result.SetValue(vJSONLine, EncodeStringsJSON);
 Finally

 End;
 vTempQuery.Close;
 vTempQuery.Free;
 If bJsonValue <> Nil Then
  FreeAndNil(bJsonValue);
End;

Function TRESTDWDriverBase.OpenDatasets(DatapackStream        : TStream;
                                        Var Error             : Boolean;
                                        Var MessageError      : String;
                                        Var BinaryBlob        : TMemoryStream;
                                        aBinaryEvent          : Boolean;
                                        aBinaryCompatibleMode : Boolean): TStream;
Var
 X               : Integer;
 vTempQuery      : TRESTDWDrvQuery;
 vStateResource  : Boolean;
 DWParams        : TRESTDWParams;
 BufferOutStream,
 BufferStream,
 BufferInStream  : TRESTDWBufferBase;
 vStream         : TMemoryStream;
 vSqlStream      : TRESTDWBytes;
 vBufferStream,
 vParamsStream   : TStream;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Result          := Nil;
 Error           := False;
 BufferInStream  := TRESTDWBufferBase.Create;
 BufferOutStream := TRESTDWBufferBase.Create;
 vTempQuery      := getQuery;
 Try
  BufferInStream.LoadToStream(DatapackStream);
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  If Not connInTransaction Then
   connStartTransaction;
  While Not BufferInStream.Eof Do
   Begin
    BufferStream  := Nil;
    vBufferStream := BufferInStream.ReadStream;
    Try
     If Not Assigned(vBufferStream) Then
      Continue;
     BufferStream := TRESTDWBufferBase.Create;
     BufferStream.LoadToStream(vBufferStream);
     vSqlStream    := BufferStream.ReadBytes;
     vParamsStream := TMemoryStream(BufferStream.ReadStream);
    Finally
     If Assigned(BufferStream)  Then
      FreeAndNil(BufferStream);
     If Assigned(vBufferStream) Then
      FreeAndNil(vBufferStream);
    End;
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(StringReplace(BytesToString(vSqlStream), sLineBreak, ' ', [rfReplaceAll]));
    SetLength(vSqlStream, 0);
    DWParams := TRESTDWParams.Create;
    Try
     DWParams.LoadFromStream(vParamsStream);
     vTempQuery.ImportParams(DWParams);
    Finally
     DWParams.Free;
     If Assigned(vParamsStream) Then
      FreeAndNil(vParamsStream);
    End;
    vTempQuery.Open;
    vStream := TMemoryStream.Create;
    Try
     vTempQuery.SaveToStreamCompatibleMode(vStream);
     vStream.Position := 0;
     BufferOutStream.InputStream(vStream);
    Finally
    If Assigned(vStream) Then
     FreeAndNil(vStream);
    End;
   End;
  If connInTransaction Then
   connCommit;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception do
   Begin
    Disconect;
    Try
     Error          := True;
     MessageError   := E.Message;
    Except
    End;
   End;
 End;
 FreeAndNil(BufferInStream);
 BufferOutStream.SaveToStream(Result);
 FreeAndNil(BufferOutStream);
 vTempQuery.Close;
 vTempQuery.Free;
end;

constructor TRESTDWDriverBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  vEncodeStrings       := True;
  {$IFDEF FPC}
    vDatabaseCharSet   := csUndefined;
  {$ENDIF}
  vCommitRecords       := 100;
  vOnTableBeforeOpen   := Nil;
  vOnPrepareConnection := Nil;
  vParamCreate         := False;
  vStrsTrim            := vParamCreate;
  vStrsEmpty2Null      := vParamCreate;
  vStrsTrim2Len        := vParamCreate;
  vEncodeStrings       := vParamCreate;
  vCompression         := vParamCreate;

  // fernando banhos 25/10/2022
  // algumas rotinas de paramscreate foram retiradas devido
  // incompatibilidade com outros drivers
  // compatibilidade somente com firedac
  vParamCreate         := True;
  FConnection := nil;
  FServerMethod := nil;
  if Self.Owner.InheritsFrom(TServerMethodDataModule) then
    FServerMethod := TServerMethodDataModule(Self.Owner);
end;

Class Procedure TRESTDWDriverBase.CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                                   Var AConnection       : TComponent);
Begin
 If (Not Assigned(AConnection))     Or
    (Not Assigned(AConnectionDefs)) Then
  Exit;
End;

Procedure TRESTDWDriverBase.PrepareConnection(Var AConnectionDefs : TConnectionDefs);
Begin
 If Assigned(OnPrepareConnection) Then
  OnPrepareConnection(AConnectionDefs);
 If (Not Assigned(FConnection))     Or
    (Not Assigned(AConnectionDefs)) Then
  Exit;
 CreateConnection(AConnectionDefs,FConnection);
End;

procedure TRESTDWDriverBase.PrepareDataQuery(var Query: TRESTDWDrvQuery;
                                             MassiveDataset: TMassiveDatasetBuffer;
                                             Params: TRESTDWParams;
                                             aMassiveCache        : boolean;
                                             var ReflectionChanges: string;
                                             var Error: boolean;
                                             var MessageError: string);
var
  vResultReflectionLine,
  vLineSQL, vFields,
  vParamsSQL: string;
  I : integer;
  bPrimaryKeys  : TStringList;
  vFieldType    : TFieldType;
  vStringStream : TMemoryStream;
  vParam        : TRDWDrvParam;
begin
  Query.Close;
  Query.SQL.Clear;

  vFields := '';
  vParamsSQL := vFields;
  vStringStream := nil;

  case MassiveDataset.MassiveMode of
    mmInsert: begin
      vParamsSQL := '';
      if MassiveDataset.ReflectChanges then
        vLineSQL := Format('Select %s ',['%s From ' + MassiveDataset.TableName + ' Where %s'])
      else
        vLineSQL := Format('INSERT INTO %s ',[MassiveDataset.TableName + ' (%s) VALUES (%s)']);
      for I := 0 to MassiveDataset.Fields.Count - 1 do begin
        if ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) and
           (MassiveDataset.AtualRec.MassiveMode = mmInsert) and
           (MassiveDataset.Fields.Items[I].ReadOnly)) or
           (MassiveDataset.Fields.Items[I].ReadOnly)) and
           (not (MassiveDataset.ReflectChanges))) or
           ((MassiveDataset.ReflectChanges) and
           (((MassiveDataset.Fields.Items[I].ReadOnly) and
           (not MassiveDataset.Fields.Items[I].AutoGenerateValue)) or
           (Lowercase(MassiveDataset.Fields.Items[I].FieldName) =  Lowercase(RESTDWFieldBookmark)))) then
          Continue;
        if vFields = '' then begin
          vFields := MassiveDataset.Fields.Items[I].FieldName;
          if not MassiveDataset.ReflectChanges then
            vParamsSQL := ':' + MassiveDataset.Fields.Items[I].FieldName;
        end
        else begin
          vFields := vFields + ', ' + MassiveDataset.Fields.Items[I].FieldName;
          if not MassiveDataset.ReflectChanges then
            vParamsSQL := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
        end;
        if MassiveDataset.ReflectChanges then begin
          if MassiveDataset.Fields.Items[I].KeyField then
            if vParamsSQL = '' then
              vParamsSQL := MassiveDataset.Fields.Items[I].FieldName + ' is null '
            else
              vParamsSQL := vParamsSQL + ' and ' + MassiveDataset.Fields.Items[I].FieldName + ' is null ';
        end;
      end;

      if MassiveDataset.ReflectChanges then begin
        if (vParamsSQL = '') and
          (MassiveDataset.AtualRec.MassiveMode <> mmInsert) then begin
          raise Exception.Create(
            PChar(Format('Invalid insert, table %s no have keys defined to use in Reflect Changes...', [MassiveDataset.TableName])));
          Exit;
        end;
      end;
      vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
    end;
    mmUpdate: begin
      vFields := '';
      vParamsSQL := '';
      if MassiveDataset.ReflectChanges then
        vLineSQL := Format('Select %s ',['%s From ' + MassiveDataset.TableName + ' %s'])
      else
        vLineSQL := Format('UPDATE %s ',[MassiveDataset.TableName + ' SET %s %s']);
      if not MassiveDataset.ReflectChanges then  begin
        for I := 0 to MassiveDataset.AtualRec.UpdateFieldChanges.Count - 1 do begin
          if Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) then begin
            if vFields = '' then
              vFields := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
            else
              vFields := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
          end;
        end;
      end
      else begin
        for I := 0 to MassiveDataset.Fields.Count - 1 do begin
          if Lowercase(MassiveDataset.Fields.Items[I].FieldName) <> Lowercase(RESTDWFieldBookmark) then begin
            if ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) and
               (MassiveDataset.AtualRec.MassiveMode = mmInsert) and
               (MassiveDataset.Fields.Items[I].ReadOnly)) or
               (MassiveDataset.Fields.Items[I].ReadOnly)) and
               (not (MassiveDataset.ReflectChanges))) or
               ((MassiveDataset.ReflectChanges) and
               (((MassiveDataset.Fields.Items[I].ReadOnly) and
               (not MassiveDataset.Fields.Items[I].AutoGenerateValue)) or
               (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) then
              Continue;
            if vFields = '' then
              vFields := MassiveDataset.Fields.Items[I].FieldName
            else
              vFields := vFields + ', ' + MassiveDataset.Fields.Items[I].FieldName;
          end;
        end;
      end;
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      try
        for I := 0 to bPrimaryKeys.Count - 1 do begin
          if I = 0 then
            vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
          else
            vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I];
        end;
      finally
        FreeAndNil(bPrimaryKeys);
      end;
      vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
    end;
    mmDelete: begin
      vLineSQL := Format('DELETE FROM %s ', [MassiveDataset.TableName + ' %s ']);
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      try
        for I := 0 to bPrimaryKeys.Count - 1 do begin
          if I = 0 then
            vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
          else
            vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I];
        end;
      finally
        FreeAndNil(bPrimaryKeys);
      end;
      vLineSQL := Format(vLineSQL, [vParamsSQL]);
    end;
    mmExec: vLineSQL := MassiveDataset.Dataexec.Text;
  end;
  Query.SQL.Add(vLineSQL);

  //Params
  if (MassiveDataset.ReflectChanges) and
     (not (MassiveDataset.MassiveMode in [mmDelete, mmExec])) then  begin
    if MassiveDataset.MassiveMode = mmUpdate then
      SetUpdateBuffer(Query,MassiveDataset,I,True);
    Query.Open;
    for I := 0 to MassiveDataset.Fields.Count - 1 do begin
      if (MassiveDataset.Fields.Items[I].KeyField) and
         (MassiveDataset.Fields.Items[I].AutoGenerateValue) then begin
        Query.createSequencedField(MassiveDataset.SequenceName,MassiveDataset.Fields.Items[I].FieldName);
      end;
    end;

    try
      case MassiveDataset.MassiveMode of
        mmInsert: Query.Insert;
        mmUpdate: begin
          if Query.RecNo > 0 then
            Query.Edit
          else
            raise Exception.Create(PChar('Record not found to update...'));
        end;
      end;
      BuildDatasetLine(TRESTDWDrvDataset(Query), MassiveDataset, aMassiveCache);
    finally
      case MassiveDataset.MassiveMode of
        mmInsert, mmUpdate: Query.Post;
      end;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query.Owner), aMassiveCache);
      if ReflectionChanges = '' then
        ReflectionChanges := vResultReflectionLine
      else
        ReflectionChanges := ReflectionChanges + ', ' + vResultReflectionLine;
      if Assigned(FServerMethod) then begin
        if Assigned(FServerMethod.OnAfterMassiveLineProcess) then
          FServerMethod.OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query.Owner));
      end;
      Query.Close;
    end;
  end
  else
  begin
    for I := 0 to Query.ParamCount - 1 do begin
      vParam := Query.Params[I];
      if MassiveDataset.MassiveMode = mmExec then begin
        if MassiveDataset.Params.ItemsString[vParam.Name] <> nil then begin
          vFieldType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[vParam.Name].ObjectValue);
          if MassiveDataset.Params.ItemsString[vParam.Name].IsNull then begin
            if vFieldType = ftUnknown then
              vParam.DataType := ftString
            else
              vParam.DataType := vFieldType;
            vParam.Clear;
          end;

          if MassiveDataset.MassiveMode <> mmUpdate then begin
            if vParam.RESTDWDataTypeParam in [dwftFixedChar,dwftFixedWideChar,dwftString,dwftWideString,dwftMemo,dwftFmtMemo,dwftWideMemo] then begin
              if (not (MassiveDataset.Params.ItemsString[vParam.Name].IsNull)) then begin
                if vParam.Size > 0 then
                  vParam.Value := Copy(MassiveDataset.Params.ItemsString[vParam.Name].Value, 1, vParam.Size)
                else
                  vParam.Value := MassiveDataset.Params.ItemsString[vParam.Name].Value;
              end
              else
                vParam.Clear;
            end
            else begin
              if vParam.DataType in [ftUnknown] then begin
                if not (ObjectValueToFieldType( MassiveDataset.Params.ItemsString[vParam.Name].ObjectValue) in [ftUnknown]) then
                  vParam.DataType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[vParam.Name].ObjectValue)
                else
                  vParam.DataType := ftString;
              end;
              if vParam.RESTDWDataTypeParam in [dwftInteger, dwftSmallInt, dwftWord, dwftLongWord, dwftLargeint] then begin
                if (not (MassiveDataset.Params.ItemsString[vParam.Name].IsNull)) then begin
                  if vParam.RESTDWDataTypeParam in [dwftLongWord,dwftLargeint] then
                    vParam.AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[vParam.Name].Value)
                  else if vParam.DataType = ftSmallInt then
                    vParam.AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[vParam.Name].Value)
                  else
                    vParam.AsInteger := StrToInt(MassiveDataset.Params.ItemsString[vParam.Name].Value);
                end
                else
                  vParam.Clear;
              end
              else if vParam.RESTDWDataTypeParam in [dwftFloat, dwftCurrency, dwftBCD, dwftFMTBcd,dwftSingle] then begin
                if (not (MassiveDataset.Params.ItemsString[vParam.Name].IsNull)) then
                  vParam.AsFloat := StrToFloat(BuildFloatString(MassiveDataset.Params.ItemsString[vParam.Name].Value))
                else
                  vParam.Clear;
              end
              else if vParam.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
              begin
                if (not (MassiveDataset.Params.ItemsString[vParam.Name].IsNull)) then
                  vParam.AsDateTime := MassiveDataset.Params.ItemsString[vParam.Name].Value
                else
                  vParam.Clear;
              end
              //Tratar Blobs de Parametros...
              else if vParam.DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] then begin
                vStringStream := TMemoryStream.Create;
                try
                  if (not (MassiveDataset.Params.ItemsString[vParam.Name].IsNull)) then begin
                    MassiveDataset.Params.ItemsString[vParam.Name].SaveToStream(TStream(vStringStream));
                    if vStringStream <> nil then begin
                      vStringStream.Position := 0;
                      vParam.LoadFromStream(vStringStream, ftBlob);
                    end
                    else
                      vParam.Clear;
                  end
                  else
                    vParam.Clear;
                finally
                  FreeAndNil(vStringStream);
                end;
              end
              else if (not (MassiveDataset.Params.ItemsString[vParam.Name].IsNull)) then
                vParam.Value := MassiveDataset.Params.ItemsString[vParam.Name].Value
              else
                vParam.Clear;
            end;
          end
          else begin //Update
            SetUpdateBuffer(Query,MassiveDataset,I);
          end;
        end;
      end
      else begin
        if (MassiveDataset.Fields.FieldByName(vParam.Name) <> nil) then begin
          vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(vParam.Name).FieldType);
          if not MassiveDataset.Fields.FieldByName(vParam.Name).IsNull Then begin
            if vFieldType = ftUnknown then
              vParam.DataType := ftString;
            vParam.Clear;
          end;

          if MassiveDataset.MassiveMode <> mmUpdate then begin
            if vParam.RESTDWDataTypeParam in [dwftFixedChar, dwftFixedWideChar, dwftString, dwftWideString, dwftMemo, dwftFmtMemo, dwftWideMemo] then begin
              if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then begin
                if vParam.Size > 0 then
                  vParam.Value := Copy(MassiveDataset.Fields.FieldByName(vParam.Name).Value, 1, vParam.Size)
                else
                  vParam.Value := MassiveDataset.Fields.FieldByName(vParam.Name).Value;
              end
              else
                vParam.Clear;
            end
            else begin
              if vParam.DataType in [ftUnknown] then begin
                if not (ObjectValueToFieldType(
                  MassiveDataset.Fields.FieldByName(vParam.Name).FieldType) in [ftUnknown]) then
                  vParam.DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(vParam.Name).FieldType)
                else
                  vParam.DataType := ftString;
              end;
              if vParam.DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] then begin
                if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then
                  vParam.Value := MassiveDataset.Fields.FieldByName(vParam.Name).Value
                else
                  vParam.Clear;
              end
              else if vParam.RESTDWDataTypeParam in [dwftInteger, dwftSmallInt, dwftWord, dwftLongWord, dwftLargeint] then begin
                if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then begin
                  if vParam.RESTDWDataTypeParam in [dwftLongWord,dwftLargeint] then
                    vParam.AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(vParam.Name).Value)
                  else if vParam.DataType = ftSmallInt then
                    vParam.AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(vParam.Name).Value)
                  else
                    vParam.AsInteger := StrToInt(MassiveDataset.Fields.FieldByName(vParam.Name).Value);
                end
                else
                  vParam.Clear;
              end
              else if vParam.RESTDWDataTypeParam in [dwftFloat, dwftCurrency, dwftBCD, dwftFMTBcd, dwftSingle] then begin
                if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then
                  vParam.AsFloat := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(vParam.Name).Value))
                else
                  vParam.Clear;
              end
              else if vParam.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then begin
                if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then
                begin
                  if MassiveDataset.Fields.FieldByName(vParam.Name).Value <> 0 then
                    vParam.AsDateTime := MassiveDataset.Fields.FieldByName(vParam.Name).Value
                  else
                    vParam.Clear;
                end
                else
                  vParam.Clear;
              end  //Tratar Blobs de Parametros...
              else if vParam.DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] then begin
                vStringStream := TMemoryStream.Create;
                try
                  if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then begin
                    MassiveDataset.Fields.FieldByName(vParam.Name).SaveToStream(vStringStream);
                    if vStringStream <> nil then begin
                      vStringStream.Position := 0;
                      vParam.LoadFromStream(vStringStream, ftBlob);
                    end
                    else
                      vParam.Clear;
                  end
                  else
                    vParam.Clear;
                finally
                  FreeAndNil(vStringStream);
                end;
              end
              else if (not (MassiveDataset.Fields.FieldByName(vParam.Name).IsNull)) then
                vParam.Value := MassiveDataset.Fields.FieldByName(vParam.Name).Value
              else
                vParam.Clear;
            end;
          end
          else begin //Update
            SetUpdateBuffer(Query,MassiveDataset,I);
          end;
        end
        else begin
          if I = 0 then
            SetUpdateBuffer(Query,MassiveDataset,I);
        end;
      end;
    end;
  end;
end;

procedure TRESTDWDriverBase.PrepareDataTable(var Query: TRESTDWDrvTable;
                                             MassiveDataset: TMassiveDatasetBuffer;
                                             Params: TRESTDWParams;
                                             aMassiveCache : Boolean;
                                             var ReflectionChanges: String;
                                             var Error: boolean;
                                             var MessageError: string);
var
  vResultReflectionLine,
  vLocate: string;
  I: integer;
  bPrimaryKeys : TStringList;
  vDataSet : TDataSet;
begin
  vDataSet := TDataSet(Query.Owner);

  Query.Close;
  Query.Filter := '';
  Query.Filtered := False;
  Query.TableName := MassiveDataset.TableName;
  vLocate := '';

  case MassiveDataset.MassiveMode of
    mmInsert: begin
      vLocate := '1=0';
    end;
    mmUpdate,
    mmDelete: begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      try
        for I := 0 to bPrimaryKeys.Count - 1 do begin
          if MassiveDataset.MassiveMode = mmUpdate then
          begin
            if I = 0 then
              vLocate := Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value])
            else
              vLocate := vLocate + ' and ' + Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value]);
          end
          else begin
            if I = 0 then
              vLocate := Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.Values[I + 1].Value])
            else
              vLocate := vLocate + ' and ' + Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.Values[I + 1].Value]);
          end;
        end;
      finally
        FreeAndNil(bPrimaryKeys);
      end;
    end;
  end;
  Query.Filter := vLocate;
  Query.Filtered := True;
  //Params
  if (MassiveDataset.MassiveMode <> mmDelete) then begin
    if Assigned(Self.OnTableBeforeOpen) then
      Self.OnTableBeforeOpen(vDataSet, Params, MassiveDataset.TableName);
    Query.Open;
    Query.FetchAll;
    for I := 0 to MassiveDataset.Fields.Count - 1 do begin
      if (MassiveDataset.Fields.Items[I].KeyField) and
         (MassiveDataset.Fields.Items[I].AutoGenerateValue) then begin
        if Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> nil then begin
          Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
        end;
      end;
    end;
    try
      case MassiveDataset.MassiveMode of
        mmInsert: Query.Insert;
        mmUpdate: begin
          if Query.RecNo > 0 then
            Query.Edit
          else
            raise Exception.Create(PChar('Record not found to update...'));
        end;
      end;
      BuildDatasetLine(TRESTDWDrvDataset(Query), MassiveDataset, aMassiveCache);
    finally
      case MassiveDataset.MassiveMode of
        mmInsert, mmUpdate: begin
          Query.Post;
          // Query.RefreshCurrentRow(true);
          // Query.Resync([rmExact, rmCenter]);
        end;
      end;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query), aMassiveCache);
      if ReflectionChanges = '' then
        ReflectionChanges := vResultReflectionLine
      else
        ReflectionChanges := ReflectionChanges + ', ' + vResultReflectionLine;
      if Assigned(FServerMethod) then begin
        if Assigned(FServerMethod.OnAfterMassiveLineProcess) then
          FServerMethod.OnAfterMassiveLineProcess(MassiveDataset, vDataSet);
      end;
      Query.Close;
    end;
  end
  else begin
    Query.Open;
    Query.Delete;
  end;
end;

Procedure TRESTDWDriverBase.BuildDatasetLine(var Query: TRESTDWDrvDataset;
                                             Massivedataset: TMassivedatasetBuffer;
                                             MassiveCache: Boolean);
Var
 I, A              : Integer;
 vMasterField,
 vTempValue        : String;
 vDados,
 vStringStream     : TMemoryStream;
 MassiveField      : TMassiveField;
 MassiveReplyValue : TMassiveReplyValue;
 MassiveReplyCache : TMassiveReplyCache;
Begin
 vTempValue    := '';
 vStringStream := Nil;
 If Massivedataset.MassiveMode = mmUpdate Then
  Begin
   For I := 0 To Massivedataset.AtualRec.UpdateFieldChanges.Count -1 Do
    Begin
     MassiveField  := MassiveDataset.Fields.FieldByName(Massivedataset.AtualRec.UpdateFieldChanges[I]);
     If (Lowercase(MassiveField.FieldName) = Lowercase(RESTDWFieldBookmark)) then
      Continue;
     If (MassiveField <> Nil) Then
      Begin
       If MassiveField.IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveField.Value;
       If MassiveCache Then
        Begin
         If (MassiveField.KeyField) And (Not (MassiveField.ReadOnly)) Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveField.IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, MassiveField.OldValue, MassiveField.Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, Null, MassiveField.OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, Null);
              End;
             If Not MassiveField.IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              vTempValue                   := MassiveReplyValue.OldValue;
            End
           Else
            Begin
             If Not MassiveField.IsNull Then
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue)
             Else
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveField.FieldName;
               If Not MassiveField.IsNull Then
                MassiveReplyValue.OldValue := MassiveField.Value
               Else
                MassiveReplyValue.OldValue := MassiveField.OldValue;
               MassiveReplyValue.NewValue  := Null;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End
             Else
              Begin
               MassiveField.Value := MassiveReplyValue.NewValue;
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveField.IsNull Then
            vTempValue := MassiveField.Value;
          End;
        End;
       If ((vTempValue = 'null')  Or
           (Query.FieldByName(MassiveField.FieldName).ReadOnly) Or
           (MassiveField.IsNull)) Then
        Begin
         If Not (Query.FieldByName(MassiveField.FieldName).ReadOnly) Then
          Query.FieldByName(MassiveField.FieldName).Clear;
         Continue;
        End;
       If MassiveField.IsNull Then
        Continue;
       If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                 ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                 ftString,    ftWideString,
                                                                 ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                         {$IF CompilerVersion > 21}
                                                                                 , ftWideMemo
                                                                          {$IFEND}
                                                                         {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And (vTempValue <> '') And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.FieldByName(MassiveField.FieldName).Size > 0 Then
            Query.FieldByName(MassiveField.FieldName).AsString := Copy(vTempValue, 1, Query.FieldByName(MassiveField.FieldName).Size)
           Else
            Query.FieldByName(MassiveField.FieldName).AsString := vTempValue;
          End
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End
       Else
        Begin
         If Query.FieldByName(MassiveField.FieldName).DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).Value := vTempValue
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.FieldByName(MassiveField.FieldName).FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}
                    Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                  {$ELSE}
                    Query.FieldByName(MassiveField.FieldName).AsInteger := StrToInt64(vTempValue);
                  {$IFEND}
                 {$ELSE}
                   Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.FieldByName(MassiveField.FieldName).AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsFloat  := StrToFloat(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                        ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := DecodeStream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.FieldByName(MassiveField.FieldName)).LoadFromStream(vStringStream);
             End
            Else
             Query.FieldByName(MassiveField.FieldName).Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Query.FieldByName(MassiveField.FieldName).Value := vTempValue
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End;
      End;
    End;
  End
 Else
  Begin
   For I := 0 To Query.Fields.Count -1 Do
    Begin
     If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName) <> Nil) Then
      Begin
       If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
        Begin
         A := -1;
         If (MassiveDataset.SequenceName <> '') Then
          A := GetGenID(MassiveDataset.SequenceName)
         Else
          Query.Fields[I].Required := False;
         If A > -1 Then
          Query.Fields[I].Value := A;
         If Not MassiveDataset.ReflectChanges Then
          Continue;
//         Else
//          Begin
//           MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value := A;
//           MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldType := ovInteger;
//          End;
        End
       Else If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).isNull) Or
               (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly) Then
        Begin
         If ((Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly)) And
             (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue))) Then
          Query.Fields[I].Clear;
         Continue;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
       If MassiveCache Then
        Begin
         If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).KeyField Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          Null,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              Null);
              End;
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              if (MassiveReplyValue.OldValue = null) then begin
                vTempValue                   := '';
              end
              else begin
                vTempValue                   := MassiveReplyValue.OldValue;
              end;
            End
           Else
            Begin
             MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                                                                                            MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName;
               MassiveReplyValue.OldValue  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
               MassiveReplyValue.NewValue  := MassiveReplyValue.OldValue;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               vTempValue                  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
              End;
            End;
           vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
           If vMasterField <> '' Then
            Begin
             MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue <> Nil Then
              vTempValue := MassiveReplyValue.NewValue;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
               If vMasterField = '' Then
                vMasterField := Query.Fields[I].FieldName;
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
            vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
          End;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        Continue;
       If Query.Fields[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                             ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                             ftString,    ftWideString,
                             ftMemo, ftFmtMemo {$IFNDEF FPC}
                                     {$IF CompilerVersion > 21}
                                      , ftWideMemo
                                     {$IFEND}
                                    {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.Fields[I].Size > 0 Then
            Query.Fields[I].AsString := Copy(vTempValue, 1, Query.Fields[I].Size)
           Else
            Query.Fields[I].AsString := vTempValue;
          End
         Else
          Query.Fields[I].Clear;
        End
       Else
        Begin
         If Query.Fields[I].DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.Fields[I].Value := vTempValue
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.Fields[I].FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.Fields[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}Query.Fields[I].AsLargeInt := StrToInt64(vTempValue)
                  {$ELSE} Query.Fields[I].AsInteger                    := StrToInt64(vTempValue)
                  {$IFEND}
                 {$ELSE}
                  Query.Fields[I].AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.Fields[I].AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle, ftExtended{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsFloat := StrToFloat(BuildFloatString(vTempValue))
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.Fields[I].Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                              ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := TMemoryStream.Create;
              MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).SaveToStream(vStringStream);
//              vStringStream := DecodeStream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.Fields[I]).LoadFromStream(vStringStream);
             End
            Else
             Query.Fields[I].Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Value := vTempValue;
          End
         Else
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Clear;
          End;
        End;
      End;
    End;
  End;
End;

procedure TRESTDWDriverBase.BuildReflectionChanges(var ReflectionChanges: String;
                                                   MassiveDataset: TMassiveDatasetBuffer;
                                                   Query: TDataset;
                                                   MassiveCache : Boolean);
Var
  I: Integer;
  vTempValue, vStringFloat,
  vReflectionLine, vReflectionLines: String;
  vFieldType: TFieldType;
  MassiveField: TMassiveField;
  vFieldChanged: Boolean;
  vStringStream: TMemoryStream;
Begin
  ReflectionChanges := '%s';
  vReflectionLine := '';
  vFieldChanged := False;
  vStringStream := nil;
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    If Not MassiveCache then
     vReflectionLines := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value,', "reflectionlines":[%s]'])
    Else
     vReflectionLines := Format('{"dwbookmark":"%s"%s, "mycomptag":"%s"}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]', MassiveDataset.MyCompTag]);
    For I := 0 To Query.Fields.Count - 1 Do Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
          vFieldChanged := MassiveField.Modified
        Else Begin
          Case vFieldType Of
            ftDate, ftTime, ftDateTime, ftTimeStamp: Begin
                If (MassiveField.IsNull And Not(Query.Fields[I].IsNull)) Or
                   (Not(MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                  vFieldChanged := True
                Else Begin
                  If (Not MassiveField.IsNull) Then
                    vFieldChanged := (Query.Fields[I].AsDateTime <> MassiveField.Value)
                  Else
                    vFieldChanged := Not(Query.Fields[I].IsNull);
                End;
              End;
            ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob: Begin
                vStringStream := TMemoryStream.Create;
                Try
                  TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                  vStringStream.Position := 0;
                  vFieldChanged := EncodeStream(vStringStream) <>  MassiveField.Value;
                Finally
                  FreeAndNil(vStringStream);
                End;
              End;
          Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
        End;

        If vFieldChanged Then Begin
          Case vFieldType Of
            ftDate, ftTime, ftDateTime, ftTimeStamp: Begin
                If (Not MassiveField.IsNull) Then Begin
                  If (Query.Fields[I].AsDateTime <> MassiveField.Value) Or
                     (MassiveField.Modified) Then Begin
                    If (MassiveField.Modified) Then
                      vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                    Else
                      vTempValue := IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime));
                    If vReflectionLine = '' Then
                      vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,vTempValue])
                    Else
                      vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,vTempValue]);
                  End;
                End
                Else Begin
                  If vReflectionLine = '' Then
                    vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                       IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))])
                  Else
                    vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}',
                                      [MassiveField.FieldName, IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))]);
                End;
              End;
              {$IFNDEF FPC}
                {$IF CompilerVersion >= 21}
                  ftSingle, ftExtended,
                {$IFEND}
              {$ENDIF}
              ftFloat, ftCurrency, ftBCD, ftFMTBcd: Begin
                vStringFloat := Query.Fields[I].AsString;
                If (MassiveField.Modified) Then
                  vStringFloat := BuildStringFloat(MassiveField.Value)
                else If (Trim(vStringFloat) <> '') Then
                  vStringFloat := BuildStringFloat(vStringFloat)
                Else
                  vStringFloat := cNullvalue;

                If vReflectionLine = '' Then
                  vReflectionLine := Format('{"%s":"%s"}',[MassiveField.FieldName, vStringFloat])
                Else
                  vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}',[MassiveField.FieldName, vStringFloat]);
              End;
          Else
            Begin
              If Not(vFieldType In [ftBytes, ftVarBytes, ftBlob, ftGraphic,ftOraBlob, ftOraClob]) Then Begin
                vTempValue := Query.Fields[I].AsString;
                If (MassiveField.Modified) Then
                  If Not MassiveField.IsNull Then
                    vTempValue := MassiveField.Value
                  Else
                    vTempValue := cNullvalue;
                If vReflectionLine = '' Then
                  vReflectionLine := Format('{"%s":"%s"}',[MassiveField.FieldName,
                                     EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
                Else
                  vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}',
                                    [MassiveField.FieldName, EncodeStrings(vTempValue{$IFDEF FPC},csUndefined{$ENDIF})]);
              End
              Else Begin
                vStringStream := TMemoryStream.Create;
                Try
                  TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                  vStringStream.Position := 0;
                  If vStringStream.Size > 0 Then Begin
                    If vReflectionLine = '' Then
                      vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,  EncodeStream(vStringStream)])
                    Else
                      vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, EncodeStream(vStringStream)]);
                  End
                  Else Begin
                    If vReflectionLine = '' Then
                      vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                    Else
                      vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                  End;
                Finally
                  If Assigned(vStringStream) Then
                    FreeAndNil(vStringStream);
                End;
              End;
            End;
          End;
        End;
      End;
    End;
    If vReflectionLine <> '' Then
      ReflectionChanges := Format(ReflectionChanges,[Format(vReflectionLines, [vReflectionLine])])
    Else
      ReflectionChanges := '';
  End;
end;

{ TRDWDrvParam }

procedure TRDWDrvParam.Clear;
begin
  Value := null;
end;

function TRDWDrvParam.geAsInteger: integer;
begin
  Result := 0;
  if not IsNull then
    Result := Value
end;

function TRDWDrvParam.getAsDateTime: TDateTime;
begin
  Result := 0.0;
  if not IsNull then
    Result := VarToDateTime(Value);
end;

function TRDWDrvParam.getAsFloat: Double;
begin
  Result := 0.0;
  if not IsNull then
    Result := Value
end;

function TRDWDrvParam.getAsInteger: integer;
begin
  Result := 0;
  if not IsNull then
    Result := Value
end;

function TRDWDrvParam.getAsLargeInt: int64;
begin
  Result := 0;
  if not IsNull then
    Result := Value
end;

function TRDWDrvParam.getAsSmallint: smallInt;
begin
  Result := 0;
  if not IsNull then
    Result := Value
end;

function TRDWDrvParam.getAsString: string;
begin
  Result := '';
  if not IsNull then
    Result := VarToStr(Value);
end;

function TRDWDrvParam.getDataType: TFieldType;
begin
  Result := FDrvDataset.getParamDataType(FIdxParam);
end;

function TRDWDrvParam.getName: string;
begin
  Result := FDrvDataset.getParamName(FIdxParam);
end;

function TRDWDrvParam.getSize: integer;
begin
  Result := FDrvDataset.getParamSize(FIdxParam);
end;

function TRDWDrvParam.getValue: Variant;
begin
  Result := FDrvDataset.getParamValue(FIdxParam);
end;

function TRDWDrvParam.IsNull: boolean;
var
  pData: PVarData;
begin
  pData := FindVarData(Value);
  Result := (pData^.VType = varNull) or (pData^.VType = varEmpty);
end;

procedure TRDWDrvParam.LoadFromFile(const AFileName: String; ABlobType: TFieldType);
var
  stream: TStream;
begin
  stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(stream, ABlobType);
  finally
    stream.Free;
  end;
end;

procedure TRDWDrvParam.LoadFromStream(AStream: TStream; ABlobType: TFieldType);
begin
  FDrvDataset.LoadFromStreamParam(FIdxParam,AStream,ABlobType);
end;

function TRDWDrvParam.RESTDWDataTypeParam: Byte;
begin
  Result := FieldTypeToDWFieldType(DataType);
end;

procedure TRDWDrvParam.setAsDate(const AValue: TDateTime);
begin
  DataType := ftDate;
  Value := AValue;
end;

procedure TRDWDrvParam.setAsDateTime(const AValue: TDateTime);
begin
  DataType := ftDateTime;
  Value := AValue;
end;

procedure TRDWDrvParam.setAsFloat(const AValue: Double);
begin
  DataType := ftFloat;
  Value := AValue;
end;

procedure TRDWDrvParam.setAsInteger(const AValue: integer);
begin
  DataType := ftInteger;
  Value := AValue;
end;

procedure TRDWDrvParam.setAsLargeInt(const AValue: int64);
begin
  DataType := ftLargeint;
  Value := AValue;
end;

procedure TRDWDrvParam.setAsSmallint(const AValue: smallInt);
begin
  DataType := ftSmallint;
  Value := AValue;
end;

procedure TRDWDrvParam.setAsString(const AValue: string);
begin
  DataType := ftString;
  Value := AValue;
end;

procedure TRDWDrvParam.setAsTime(const AValue: TDateTime);
begin
  DataType := ftTime;
  Value := AValue;
end;

procedure TRDWDrvParam.setDataType(const AValue: TFieldType);
begin
  FDrvDataset.setParamDataType(FIdxParam,AValue);
end;

procedure TRDWDrvParam.setValue(const AValue: Variant);
begin
  FDrvDataset.setParamValue(FIdxParam,AValue);
end;

end.
