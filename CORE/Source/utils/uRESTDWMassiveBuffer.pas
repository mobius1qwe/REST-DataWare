unit uRESTDWMassiveBuffer;

{$I ..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

uses
  SysUtils, Classes, Variants, DB,
  uRESTDWParams, uRESTDWConsts, uRESTDWBasicTypes, uRESTDWProtoTypes, uRESTDWJSONInterface,
  uRESTDWJSONObject, uRESTDWBufferBase, uRESTDWAbout;

Const
 cJSONValue = '{"MassiveSQLMode":"%s", "SQL":"%s", "Params":"%s", "Bookmark":"%s", ' +
               '"BinaryRequest":"%s", "FetchRowSQL":"%s", "LockSQL":"%s", "UnlockSQL":"%s"}';

Type
  TMassiveDataset  = Class
End;

 TMassiveType = (mtMassiveCache, mtMassiveObject);

 TMassiveValue = Class(TObject)
 Private
  vIsNull,
  vModified,
  vBinary     : Boolean;
  vJSONValue  : TJSONValue;
  {$IFDEF RESTDWLAZARUS}
   vDatabaseCharSet : TDatabaseCharSet;
  {$ENDIF}
  vValueName   : String;
  vObjectValue : TObjectValue;
  vEncoding    : TEncodeSelect;
  vOldValue    : Variant;
  Function    GetValue       : Variant;
  Procedure   SetValue(Value : Variant);
  Procedure   SetEncoding   (bValue : TEncodeSelect);
  Procedure   SetModified(Value : Boolean);
  Function    GetNullValue(Value : TObjectValue) : Variant;
  Procedure   SetObjectValue(Value : TObjectValue);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Function    IsNull : Boolean;
  Function    AsString : String;
  Procedure   CopyValue     (aValue : TMassiveValue);
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Const Stream : TMemoryStream);
  Property    ValueName   : String       Read vValueName   Write vValueName;
  Property    ObjectValue : TObjectValue Read vObjectValue write SetObjectValue;
  Property    OldValue    : Variant      Read vOldValue    Write vOldValue;
  Property    Value       : Variant      Read GetValue     Write SetValue;
  Property    Binary      : Boolean      Read vBinary      Write vBinary;
  Property    Modified    : Boolean      Read vModified;
  {$IFDEF RESTDWLAZARUS}
  Property DatabaseCharSet : TDatabaseCharSet Read vDatabaseCharSet Write vDatabaseCharSet;
  {$ENDIF}
  Property Encoding          : TEncodeSelect  Read vEncoding        Write SetEncoding;
End;

 PMassiveValue  = ^TMassiveValue;
 TMassiveValues = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveValue;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveValue); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Function   Add   (Item  : TMassiveValue) : Integer;          Overload;
  Property   Items[Index  : Integer]       : TMassiveValue Read GetRec Write PutRec; Default;
End;

 TMassiveField = Class(TObject)
 Private
  vMassiveFields : TList;
  vOldValue      : Variant;
  vIsNull,
  vReadOnly,
  vAutoGenerateValue,
  vRequired,
  vKeyField   : Boolean;
  vFieldName  : String;
  vFieldType  : TObjectValue;
  vFieldIndex,
  vSize,
  vPrecision  : Integer;
  Function    GetValue       : Variant;
  Function    GetOldValue    : Variant;
  Procedure   SetValue(Value : Variant);
  Function    GetModified    : Boolean;
  Procedure   SetFieldType(Value : TObjectValue);
 Protected
 Public
  Constructor Create(MassiveFields : TList; FieldIndex : Integer);
  Destructor  Destroy;Override;
  Function    IsNull : Boolean;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (var Stream : TMemoryStream);
  Property    Required          : Boolean      Read vRequired          Write vRequired;
  Property    AutoGenerateValue : Boolean      Read vAutoGenerateValue Write vAutoGenerateValue;
  Property    KeyField          : Boolean      Read vKeyField          Write vKeyField;
  Property    ReadOnly          : Boolean      Read vReadOnly          Write vReadOnly;
  Property    FieldType         : TObjectValue Read vFieldType         Write SetFieldType;
  Property    FieldName         : String       Read vFieldName         Write vFieldName;
  Property    Size              : Integer      Read vSize              Write vSize;
  Property    Precision         : Integer      Read vPrecision         Write vPrecision;
  Property    OldValue          : Variant      Read GetOldValue        Write vOldValue;
  Property    Value             : Variant      Read GetValue           Write SetValue;
  Property    Modified          : Boolean      Read GetModified;
End;

 PMassiveField  = ^TMassiveField;
 TMassiveFields = Class(TList)
 Private
  vMassiveDataset : TMassiveDataset;
  Function   GetRec(Index : Integer)       : TMassiveField;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveField); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Constructor Create(MassiveDataset : TMassiveDataset);
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Procedure  Delete(FieldName : String);                       Overload;
  Function   Add   (Item  : TMassiveField) : Integer;          Overload;
  Function   FieldByName(FieldName : String) : TMassiveField;
  Property   Items[Index  : Integer]       : TMassiveField Read GetRec Write PutRec; Default;
End;

 TMassiveLine          = Class(TObject)
 Private
  vMassiveValues  : TMassiveValues;
  vPrimaryValues  : TMassiveValues;
  vMassiveMode    : TMassiveMode;
  vDataExec,
  vChanges        : TStringList;
  vMassiveType    : TMassiveType;
  vDWParams       : TRESTDWParams;
  Function   GetRec  (Index : Integer)        : TMassiveValue;
  Procedure  PutRec  (Index : Integer;  Item  : TMassiveValue);
  Function   GetRecPK(Index : Integer)        : TMassiveValue;
  Procedure  PutRecPK(Index : Integer;  Item  : TMassiveValue);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   ClearAll;
  Procedure   LoadFromStream      (Source     : TStream);
  Procedure   SaveToStream        (Var Dest      : TStream;
                                   MassiveBuffer : TObject = Nil);
  Property    Changes                         : TStringList    Read vChanges;
  Property    MassiveMode                     : TMassiveMode   Read vMassiveMode Write vMassiveMode;
  Property    UpdateFieldChanges              : TStringList    Read vChanges     Write vChanges;
  Property    MassiveType                     : TMassiveType   Read vMassiveType Write vMassiveType;
  Property    Params                          : TRESTDWParams  Read vDWParams    Write vDWParams;
  Property    DataExec                        : TStringList    Read vDataExec    Write vDataExec;
  Property    Values       [Index  : Integer] : TMassiveValue  Read GetRec       Write PutRec;
  Property    PrimaryValues[Index  : Integer] : TMassiveValue  Read GetRecPK     Write PutRecPK;
End;

 PMassiveLine   = ^TMassiveLine;
 TMassiveBuffer = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveLine;    Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveLine);   Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                         Overload;
  Function   Add   (Item  : TMassiveLine)  : Integer;         Overload;
  Property   Items[Index  : Integer]       : TMassiveLine Read GetRec Write PutRec; Default;
End;

//Massive reply queue
 PMassiveReplyValue = ^TMassiveReplyValue;
 TMassiveReplyValue = Class(TObject)
 Private
  vOldNewValue,
  vOldValue     : Variant;
  vValueName    : String;
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Property    NewValue  : Variant Read vOldNewValue Write vOldNewValue;
  Property    OldValue  : Variant Read vOldValue    Write vOldValue;
  Property    ValueName : String  Read vValueName   Write vValueName;
End;

 PMassiveReplyCache = ^TMassiveReplyCache;
 TMassiveReplyCache = Class(TList)
 Private
  vBuffername : String;
  Function   GetRec (Index  : Integer) : TMassiveReplyValue; Overload;
  Procedure  PutRec (Index  : Integer;
                     Item   : TMassiveReplyValue);           Overload;
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   Delete(Index  : Integer); Overload;
  Procedure   ClearAll;
  Function    ItemByValue(ValueName : String; OldValue : Variant) : TMassiveReplyValue;
  Function    Add   (Item   : TMassiveReplyValue) : Integer; Overload;
  Property    Buffername    : String                         Read vBuffername  Write vBuffername;
  Property    Values[Index  : Integer] : TMassiveReplyValue  Read GetRec       Write PutRec;
End;

 PMassiveReply = ^TMassiveReply;
 TMassiveReply = Class(TList)
 Private
  Function   GetRec(Index : Integer) : TMassiveReplyCache; Overload;
  Procedure  PutRec(Index : Integer;
                    Item  : TMassiveReplyCache);           Overload;
  Procedure  ClearAll;
  Function  GetRecName(Index : String)  : TMassiveReplyCache; Overload;
  Procedure PutRecName(Index : String;
                       Item  : TMassiveReplyCache); Overload;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                      Overload;
  Function   Add   (Item  : TMassiveReplyCache) : Integer; Overload;
  Procedure  AddBufferValue(Buffername,
                            ValueName           : String;
                            OldValue,
                            NewValue            : Variant);
  Procedure  UpdateBufferValue(Buffername,
                               ValueName        : String;
                               OldValue,
                               NewValue         : Variant);
  Function   GetReplyValue (Buffername,
                            ValueName           : String;
                            MyValue             : Variant) : TMassiveReplyValue;
  Property   Items      [Index  : Integer]      : TMassiveReplyCache Read GetRec Write PutRec;
  Property   ItemsString[Index  : String]       : TMassiveReplyCache Read GetRecName Write PutRecName;
End;

 TMassiveDatasetBuffer = Class(TMassiveDataset)
 Protected
  vLastOpen        : Integer;
  vDataset         : TRESTDWClientSQLBase;
  vRecNo           : Integer;
  vMassiveBuffer   : TMassiveBuffer;
  vMassiveLine     : TMassiveLine;
  vMassiveFields   : TMassiveFields;
  vMassiveMode     : TMassiveMode;
  vCreateBuffer,
  vOnLoad          : Boolean;
  vMyCompTag,
  vMasterCompTag,
  vMasterCompFields,
  vSequenceName,
  vSequenceField,
  vTableName       : String;
  {$IFDEF RESTDWLAZARUS}
  vDatabaseCharSet : TDatabaseCharSet;
  {$ENDIF}
  vEncoding        : TEncodeSelect;
  vReflectChanges  : Boolean;
  vMassiveReply    : TMassiveReply;
  vMassiveType     : TMassiveType;
  vDataexec        : TStringList;
  vDWParams        : TRESTDWParams;
 Private
  vMasterFields,
  vDetailFields    : TStringList;
  Procedure ReadStatus;
  Procedure NewLineBuffer(Var MassiveLineBuff : TMassiveLine;
                          MassiveModeData     : TMassiveMode;
                          ExecTag             : Boolean = False);
  Procedure SetEncoding          (bValue      : TEncodeSelect);
  Procedure BuildCompFields(MasterCompFields  : String);
  Procedure MassiveCheck(Dataset : TRESTDWClientSQLBase);
 Public
  Constructor Create(Dataset : TRESTDWClientSQLBase);
  Destructor  Destroy;Override;
  Function  RecNo       : Integer;
  Function  RecordCount : Integer;
  Procedure First;
  Procedure Prior;
  Procedure Next;
  Procedure Last;
  Property  TempBuffer  : TMassiveLine     Read vMassiveLine;
  Function  PrimaryKeys : TStringList;
  Function  AtualRec    : TMassiveLine;
  Procedure NewBuffer   (Dataset              : TRESTDWClientSQLBase;
                         MassiveModeData      : TMassiveMode;
                         ExecTag              : Boolean = False); Overload;
  Procedure NewBuffer   (Var MassiveLineBuff  : TMassiveLine;
                         MassiveModeData      : TMassiveMode;
                         ExecTag              : Boolean = False); Overload;
  Procedure NewBuffer   (MassiveModeData      : TMassiveMode;
                         ExecTag              : Boolean = False); Overload;
  Procedure BuildDataset(Dataset              : TRESTDWClientSQLBase;
                         UpdateTableName      : String);                 //Constroi o Dataset Massivo
  Procedure BuildLine   (Dataset              : TRESTDWClientSQLBase;
                         MassiveModeBuff      : TMassiveMode;
                         Var MassiveLineBuff  : TMassiveLine;
                         UpdateTag            : Boolean = False;
                         ExecTag              : Boolean = False);
  Procedure BuildBuffer (Dataset              : TRESTDWClientSQLBase;    //Cria um Valor Massivo Baseado nos Dados de Um Dataset
                         MassiveMode          : TMassiveMode;
                         UpdateTag            : Boolean = False;
                         ExecTag              : Boolean = False);
  Procedure SaveBuffer  (Dataset              : TRESTDWClientSQLBase;
                         ExecTag              : Boolean = False);   //Salva Um Buffer Massivo na Lista de Massivos
  Procedure ClearBuffer;                                                //Limpa o Buffer Massivo Atual
  Procedure ClearDataset;                                               //Limpa Todo o Dataset Massivo
  Procedure ClearLine;                                                  //Limpa o Buffer Temporario
  Function  ToJSON          : String;                                   //Gera o JSON do Dataset Massivo
  Procedure FromJSON             (Value    : String);                   //Carrega o Dataset Massivo a partir de um JSON
  Procedure LoadFromStream       (Source   : TStream);
  Procedure SaveToStream         (Var Dest      : TStream;
                                  MassiveBuffer : TObject = Nil);
  Function  MasterFieldFromDetail(Field    : String) : String;
  Property  MassiveMode     : TMassiveMode         Read vMassiveMode     Write vMassiveMode;   //Modo Massivo do Buffer Atual
  Property  MassiveType     : TMassiveType         Read vMassiveType     Write vMassiveType;
  Property  Fields          : TMassiveFields       Read vMassiveFields   Write vMassiveFields;
  Property  Dataexec        : TStringList          Read vDataexec        Write vDataexec;
  Property  Params          : TRESTDWParams        Read vDWParams        Write vDWParams;
  Property  TableName       : String               Read vTableName;
  Property  OnLoad          : Boolean              Read vOnLoad;
  {$IFDEF RESTDWLAZARUS}
  Property DatabaseCharSet  : TDatabaseCharSet     Read vDatabaseCharSet Write vDatabaseCharSet;
  {$ENDIF}
  Property Encoding         : TEncodeSelect        Read vEncoding        Write SetEncoding;
  Property SequenceName     : String               Read vSequenceName    Write vSequenceName;
  Property SequenceField    : String               Read vSequenceField   Write vSequenceField;
  Property ReflectChanges   : Boolean              Read vReflectChanges  Write vReflectChanges;
  Property LastOpen         : Integer              Read vLastOpen        Write vLastOpen;
  Property MassiveReply     : TMassiveReply        Read vMassiveReply    Write vMassiveReply;
  Property MyCompTag        : String               Read vMyCompTag;
  Property MasterCompTag    : String               Read vMasterCompTag;
  Property MasterCompFields : String               Read vMasterCompFields;
  Property Dataset          : TRESTDWClientSQLBase Read vDataset;
 End;

 TRESTDWMassiveCacheValue = TStream;

 PMassiveCacheValue  = ^TRESTDWMassiveCacheValue;
 TRESTDWMassiveCacheList = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TRESTDWMassiveCacheValue;     Overload;
  Procedure  PutRec(Index : Integer; Item  : TRESTDWMassiveCacheValue);    Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                                  Overload;
  Function   Add   (Item  : TRESTDWMassiveCacheValue) : Integer;           Overload;
  Property   Items[Index  : Integer]            : TRESTDWMassiveCacheValue Read GetRec Write PutRec; Default;
End;

 TMassiveCacheDataset  = TDataset;
 PMassiveCacheDataset  = ^TMassiveCacheDataset;
 TRESTDWMassiveCacheDatasetList = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveCacheDataset;       Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveCacheDataset);      Overload;
  Procedure  ClearAll;
  Function   DatasetExists(Value : TMassiveCacheDataset) : Integer;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                                    Overload;
  Function   Add   (Item  : TMassiveCacheDataset) : Integer;             Overload;
  Function   GetDataset(Dataset : String)         : TMassiveCacheDataset;
  Property   Items      [Index  : Integer]  : TMassiveCacheDataset Read GetRec       Write PutRec; Default;
End;

 TRESTDWMassiveCache = Class(TComponent)
 Private
  MassiveCacheList        : TRESTDWMassiveCacheList;
  MassiveCacheDatasetList : TRESTDWMassiveCacheDatasetList;
  vMassiveType            : TMassiveType;
 Public
  Function    MassiveCount      : Integer;
  Procedure   SaveToStream(Var aStream : TStream);
  Procedure   Add(Value         : TStream;
                  Const Dataset : TDataset);
  Procedure   ProcessChanges(Value : String);
  Procedure   Clear;
  Constructor Create(AOwner     : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
 Published
  Property    MassiveType       : TMassiveType Read vMassiveType    Write vMassiveType;
End;

 TRESTDWMassiveCacheSQLValue = Class(TCollectionItem)
 Private
  vMassiveSQLMode : TMassiveSQLMode;
  vFetchRowSQL,
  vLockSQL,
  vUnlockSQL,
  vSQL            : TStringList;
  vBookmark       : String;
  vParams         : TParams;
  vParamCount     : Integer;
  vBinaryRequest  : Boolean;
  FMemDS          : TMemoryStream;
  Procedure CreateParams;
  Procedure SetSQL       (Value   : TStringList);
  Procedure OnChangingSQL(Sender  : TObject);
  Procedure SetMemDS (Const Value : TMemoryStream);
 Public
  Constructor Create (aCollection : TCollection);Override;
  Destructor  Destroy;Override;
  Function    ParamByName  (Value : String) : TParam;    //Retorna o Parametro de Acordo com seu nome
  Property  ParamCount            : Integer           Read vParamCount;
  Property  MemDS                 : TMemoryStream     Read FMemDS          Write SetMemDS;
 Published
  Property MassiveSQLMode         : TMassiveSQLMode   Read vMassiveSQLMode Write vMassiveSQLMode;
  Property SQL                    : TStringList       Read vSQL            Write SetSQL;                  //SQL a ser Executado
  Property FetchRowSQL            : TStringList       Read vFetchRowSQL    Write vFetchRowSQL;            //SQL a ser Executado
  Property LockSQL                : TStringList       Read vLockSQL        Write vLockSQL;                //SQL a ser Executado
  Property UnlockSQL              : TStringList       Read vUnlockSQL      Write vUnlockSQL;              //SQL a ser Executado
  Property Bookmark               : String            Read vBookmark       Write vBookmark;
  Property BinaryRequest          : Boolean           Read vBinaryRequest  Write vBinaryRequest;
  Property Params                 : TParams           Read vParams         Write vParams;
End;

 PMassiveCacheSQLValue  = ^TRESTDWMassiveCacheSQLValue;
 TRESTDWMassiveCacheSQLList = Class(TRESTDWOwnedCollection)
 Private
  fOwner                  : TPersistent;
  vEncoding               : TEncodeSelect;
  Function   GetOwner     : TPersistent; override;
  Function   GetRec(Index : Integer)       : TRESTDWMassiveCacheSQLValue;     Overload;
  Procedure  PutRec(Index : Integer; Item  : TRESTDWMassiveCacheSQLValue);    Overload;
  Procedure  ClearAll;
 Protected
 Public
  Constructor Create     (AOwner      : TPersistent;
                          aItemClass  : TCollectionItemClass);
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                                     Overload;
  Function   ToJSON       : String;
  Function   Add                     : TCollectionItem;
  Property   Encoding     : TEncodeSelect                      Read vEncoding Write vEncoding;
  Property   Items[Index  : Integer] : TRESTDWMassiveCacheSQLValue Read GetRec    Write PutRec; Default;
End;

 TRESTDWMassiveSQLCache = Class(TRESTDWComponent)
 Private
  vEncoding            : TEncodeSelect;
  vMassiveCacheSQLList : TRESTDWMassiveCacheSQLList;
  Procedure   SetEncoding(Value : TEncodeSelect);
 Public
  Function    MassiveCount   : Integer;
  Function    ToJSON         : String;
  Function    ParamsToBin(Params              : TParams) : String;
  Procedure   Clear;
  Procedure   Store     (MassiveCacheSQLValue : TRESTDWMassiveCacheSQLValue);Overload;
  Procedure   Store     (SQL                  : String; Dataset              : TDataset);               Overload;
  procedure   Store     (MemDS                : TMemoryStream); OverLoad;
  Constructor Create    (AOwner               : TComponent);             Override;//Cria o Componente
  Destructor  Destroy;Override;                                                   //Destroy a Classe
 Published
  Property Encoding   : TEncodeSelect          Read vEncoding            Write SetEncoding;
  Property CachedList : TRESTDWMassiveCacheSQLList Read vMassiveCacheSQLList Write vMassiveCacheSQLList;
End;

 TMassiveProcess     = Procedure(Var MassiveDataset : TMassiveDatasetBuffer;
                                 Var Ignore         : Boolean) Of Object;
 TMassiveEvent       = Procedure(Var MassiveDataset : TMassiveDatasetBuffer) Of Object;
 TMassiveLineProcess = Procedure(Var MassiveDataset : TMassiveDatasetBuffer;
                                 Dataset            : TDataset) Of Object;

Function  MassiveSQLMode(aValue : TMassiveSQLMode) : String; overload;
Function  MassiveSQLMode(aValue : String) : TMassiveSQLMode; overload;

implementation

Uses uRESTDWBasicDB, uRESTDWPoolermethod, uRESTDWPropertyPersist, uRESTDWTools;

Function removestr(Astr: string; Asubstr: string):string;
Begin
 result:= stringreplace(Astr,Asubstr,'',[rfReplaceAll, rfIgnoreCase]);
End;

{ TMassiveField }

Function    TMassiveField.IsNull : Boolean;
Begin
 Result := (vIsNull) and varIsNull(Value);
End;

Constructor TMassiveField.Create(MassiveFields : TList; FieldIndex : Integer);
Begin
 vRequired          := False;
 vAutoGenerateValue := False;
 vReadOnly          := False;
 vIsNull            := True;
 vKeyField          := vRequired;
 vFieldType         := ovUnknown;
 vFieldName         := '';
 vOldValue          := Null;
 vMassiveFields     := MassiveFields;
 vFieldIndex        := FieldIndex;
End;

Destructor TMassiveField.Destroy;
Begin
 Inherited;
End;

Procedure TMassiveField.LoadFromStream(Stream: TMemoryStream);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].LoadFromStream(Stream);
  End;
End;

Procedure TMassiveField.SaveToStream(var Stream: TMemoryStream);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].SaveToStream(Stream);
  End;
End;

Procedure TMassiveField.SetValue(Value: Variant);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].ValueName      := vFieldName;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].ObjectValue    := vFieldType;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].vJSONValue.ObjectValue := vFieldType;
   If Not TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].isnull Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].OldValue      := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value
   Else
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].OldValue      := Null;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value          := Value;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].SetModified(True);
   vIsNull := VarIsNull(Value);
  End;
End;

Procedure TMassiveField.SetFieldType(Value : TObjectValue);
Var
 vRecNo : Integer;
Begin
 vFieldType := Value;
 vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
 If vRecNo <= 0 Then
  TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
 vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
 TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].vJSONValue.Encoded := False;
End;

Function TMassiveField.GetModified : Boolean;
Var
 vRecNo : Integer;
Begin
 Result := False;
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   Result := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Modified;
  End;
End;

Function TMassiveField.GetOldValue    : Variant;
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].vJSONValue.ObjectValue := vFieldType;
   If Not TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].isNull Then
    Result := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].OldValue
   Else
    Result := Null;
  End;
End;

Function TMassiveField.GetValue : Variant;
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].vJSONValue.ObjectValue := vFieldType;
   If Not TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].isNull Then
    Result := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value
   Else
    Result := Null;
  End;
End;

{ TMassiveFields }

Function TMassiveFields.Add(Item: TMassiveField): Integer;
Var
 vItem : ^TMassiveField;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveFields.Delete(FieldName : String);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count -1 Do
  Begin
   If Uppercase(Self.Items[I].vFieldName) =
      Uppercase(FieldName) Then
    Begin
     Self.Delete(I);
     Break;
    End;
  End;
End;

Procedure TMassiveFields.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveField(TList(Self).Items[Index]^)) Then
     Begin
       {$IF Defined(RESTDWLAZARUS) OR not Defined(DELPHI10_4UP)}
       FreeAndNil(TList(Self).Items[Index]^);
       {$ELSE}
       FreeAndNil(TMassiveField(TList(Self).Items[Index]^));
       {$IFEND}
     End;
     {$IFDEF RESTDWLAZARUS}
      Dispose(PMassiveField(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Procedure TMassiveFields.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Delete(I);
 Self.Clear;
End;

Constructor TMassiveFields.Create(MassiveDataset: TMassiveDataset);
Begin
 Inherited Create;
 vMassiveDataset := MassiveDataset;
End;

Destructor TMassiveFields.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveFields.FieldByName(FieldName : String): TMassiveField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count -1 Do
  Begin
   If LowerCase(TMassiveField(TList(Self).Items[I]^).vFieldName) =
      LowerCase(FieldName) Then
    Begin
     Result := TMassiveField(TList(Self).Items[I]^);
     Break;
    End;
  End;
End;

Function TMassiveFields.GetRec(Index : Integer) : TMassiveField;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveField(TList(Self).Items[Index]^);
End;

Procedure TMassiveFields.PutRec(Index : Integer; Item : TMassiveField);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveField(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveValue }

Procedure TMassiveValue.CopyValue(aValue : TMassiveValue);
Begin
 vJSONValue.Encoded := aValue.vJSONValue.Encoded;
 Value              := aValue.vJSONValue.Value;
End;

Constructor TMassiveValue.Create;
Begin
 vBinary    := False;
 vIsNull    := True;
 vModified  := False;
 vOldValue  := Null;
 vJSONValue := TJSONValue.Create;
End;

Function   TMassiveValue.AsString : String;
Begin
 Result := vJSONValue.AsString;
End;

Function   TMassiveValue.IsNull : Boolean;
Begin
 Result := vIsNull;
End;

Destructor TMassiveValue.Destroy;
Begin
 If Assigned(vJSONValue) Then
  FreeAndNil(vJSONValue);
 Inherited;
End;

Procedure TMassiveValue.SetObjectValue(Value : TObjectValue);
Begin
 vObjectValue           := Value;
 vJSONValue.ObjectValue := vObjectValue;
End;

Function TMassiveValue.GetNullValue(Value : TObjectValue) : Variant;
Begin
 Case Value Of
  ovVariant,
  ovUnknown         : Result := Null;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo         : Result := '';
  ovLargeInt,
  ovLongWord,
  ovShortInt,
  ovSmallInt,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval     : Result := 0;
  ovSingle,
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Result := 0;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Result := 0;
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Result := Null;
 End;
End;

Function TMassiveValue.GetValue: Variant;
Begin
 Result := vJSONValue.Value;
 If VarIsNull(Result) Then
  Result := GetNullValue(vJSONValue.ObjectValue);
End;

Procedure TMassiveValue.LoadFromStream(Stream: TMemoryStream);
Begin
 vBinary := True;
 vJSONValue.Encoding := vEncoding;
 If vJSONValue <> Nil Then
  Begin
   vJSONValue.Binary  := vBinary;
   {$IFDEF RESTDWLAZARUS}
   vJSONValue.DatabaseCharSet := csUndefined;
   {$ENDIF}
   vJSONValue.LoadFromStream(Stream);
  End;
 vIsNull := vJSONValue.IsNull;
End;

Procedure TMassiveValue.SaveToStream(Const Stream: TMemoryStream);
Begin
 vJSONValue.SaveToStream(Stream);
 Stream.Position := 0;
End;

Procedure TMassiveValue.SetModified(Value : Boolean);
Begin
 vModified := Value;
End;

Procedure TMassiveValue.SetEncoding(bValue: TEncodeSelect);
Begin
 vEncoding := bValue;
End;

Procedure TMassiveValue.SetValue(Value: Variant);
Begin
 vJSONValue.Encoding := vEncoding;
 vIsNull             := varIsNull(Value);
 If vJSONValue <> Nil Then
  Begin
   vJSONValue.Binary  := vBinary;
   {$IFDEF RESTDWLAZARUS}
   vJSONValue.DatabaseCharSet := csUndefined;
   {$ENDIF}
   If vJSONValue.Binary Then
    Begin
     vJSONValue.ObjectValue := ovBlob;
     vJSONValue.SetValue(Value, False);
     vJSONValue.Encoded := True;
    End
   Else
    vJSONValue.SetValue(Value, False);
  End;
 vIsNull := vJSONValue.IsNull;
End;

{ TMassiveValues }

Function TMassiveValues.Add(Item: TMassiveValue): Integer;
Var
 vItem : ^TMassiveValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveValues.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

Procedure TMassiveValues.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   {$IFDEF RESTDWLAZARUS}
   If Assigned(PMassiveValue(TList(Self).Items[Index])) Then
    Begin
     If Assigned(PMassiveValue(TList(Self).Items[Index])^) Then
      Begin
       Try
        FreeAndNil(TList(Self).Items[Index]^);
//        PMassiveValue(TList(Self).Items[Index])^.Free;
        Dispose(PMassiveValue(TList(Self).Items[Index]));
       Except
       End;
      End;
    End;
   {$ELSE}
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveValue(TList(Self).Items[Index]^)) Then
      Begin
       Try
        TMassiveValue(TList(Self).Items[Index]^).Free;
        Dispose(TList(Self).Items[Index]);
       Except
       End;
      End;
    End;
   {$ENDIF}
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveValues.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveValues.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(Self).Items[Index]^);
End;

Procedure TMassiveValues.PutRec(Index: Integer; Item: TMassiveValue);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveValue(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveLine }

Constructor TMassiveLine.Create;
Begin
 vMassiveValues  := TMassiveValues.Create;
 vMassiveMode    := mmBrowse;
 vChanges        := TStringList.Create;
 vDataExec       := TStringList.Create;
 vMassiveType    := mtMassiveCache;
 vDWParams       := TRESTDWParams.Create;
End;

Destructor TMassiveLine.Destroy;
Begin
 If Assigned(vMassiveValues) Then
  FreeAndNil(vMassiveValues);
 If Assigned(vChanges) Then
  FreeAndNil(vChanges);
 If Assigned(vPrimaryValues) Then
  FreeAndNil(vPrimaryValues);
 If Assigned(vDataExec) Then
  FreeAndNil(vDataExec);
 If Assigned(vDWParams) Then
  FreeAndNil(vDWParams);
 Inherited;
End;

Function TMassiveLine.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(vMassiveValues).Items[Index]^);
End;

Function TMassiveLine.GetRecPK(Index : Integer) : TMassiveValue;
Begin
 Result := Nil;
 If vPrimaryValues <> Nil Then
  If (Index < vPrimaryValues.Count) And (Index > -1) Then
   Result := TMassiveValue(TList(vPrimaryValues).Items[Index]^);
End;

Procedure TMassiveLine.ClearAll;
Begin
 vMassiveValues.ClearAll;
 If Assigned(vPrimaryValues) Then
  vPrimaryValues.ClearAll;
 If Assigned(vChanges)       Then
  If vChanges.Count > 0      Then
   vChanges.Clear;
End;

Procedure TMassiveLine.PutRec(Index: Integer;   Item : TMassiveValue);
Begin
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  Begin
   TMassiveValue(TList(vMassiveValues).Items[Index]^) := Item;
   TMassiveValue(TList(vMassiveValues).Items[Index]^).SetModified(True);
  End;
End;

Procedure TMassiveLine.PutRecPK(Index: Integer; Item : TMassiveValue);
Begin
 If (Index < vPrimaryValues.Count) And (Index > -1) Then
  TMassiveValue(TList(vPrimaryValues).Items[Index]^) := Item;
End;

Procedure TMassiveLine.LoadFromStream(Source     : TStream);
Var
 BufferStream : TRESTDWBufferBase; //Pacote de Entrada
 aMassiveMode : TMassiveMode;
 vInData,
 vOutParams   : TStream;
 vIsNull      : Boolean;
 MassiveValue : TMassiveValue;
Begin
 BufferStream := TRESTDWBufferBase.Create;
 Try
  BufferStream.LoadToStream(Source);
  If BufferStream.Size > 0 Then
   Begin
    aMassiveMode := TMassiveMode(BytesToVar(BufferStream.ReadBytes, varInteger));
    vMassiveMode := aMassiveMode;
   End;
  While Not BufferStream.Eof Do
   Begin
    If MassiveMode = mmExec Then
     Begin
      DataExec.Text := BytesToVar(BufferStream.ReadBytes, varString);
      vOutParams   := BufferStream.ReadStream;
      If Assigned(vOutParams) Then
       Begin
        Try
         Params.LoadFromStream(vOutParams);
        Finally
         FreeAndNil(vOutParams);
        End;
       End;
     End
    Else
     Begin
      While Not BufferStream.Eof Do
       Begin
        vIsNull      := BytesToVar(BufferStream.ReadBytes, varBoolean);
        MassiveValue := TMassiveValue.Create;
        If Not vIsNull Then
         Begin
          vInData := BufferStream.ReadStream;
          Try
           MassiveValue.LoadFromStream(TMemoryStream(vInData));
          Finally
           FreeAndNil(vInData);
          End;
         End;
        vMassiveValues.Add(MassiveValue);
       End;
     End;
   End;
 Finally
  FreeAndNil(BufferStream);
 End;
End;

Procedure TMassiveLine.SaveToStream  (Var Dest      : TStream;
                                      MassiveBuffer : TObject = Nil);
Var
 BufferStream : TRESTDWBufferBase; //Pacote de Saida
 vOutParams   : TStream;
 I, A         : Integer;
 aMassiveMode : TMassiveMode;
 vNoChange    : Boolean;
Begin
 BufferStream       := TRESTDWBufferBase.Create; //Pacote de Saida
 Try
  BufferStream.InputBytes(VarToBytes(MassiveMode, varInteger));
  If MassiveMode = mmExec Then
   Begin
    BufferStream.InputBytes(VarToBytes(DataExec.Text, varString));
    vOutParams   := TMemoryStream.Create;
    Try
     Params.SaveToStream(vOutParams);
     BufferStream.InputStream(vOutParams);
    Finally
     FreeAndNil(vOutParams);
    End;
   End
  Else
   Begin
    BufferStream.InputBytes(VarToBytes(Changes.Count > 0, varBoolean));
    If Changes.Count > 0 Then
     BufferStream.InputBytes(VarToBytes(EncodeStrings(Changes.Text{$IFDEF RESTDWLAZARUS}, TDatabaseCharSet.csUTF8{$ENDIF}), varString));
    If vPrimaryValues = Nil Then
     BufferStream.InputBytes(VarToBytes(False, varBoolean))
    Else
     Begin
      BufferStream.InputBytes(VarToBytes(True, varBoolean));
      BufferStream.InputBytes(VarToBytes(vPrimaryValues.Count, varInteger));
      For I := 0 To vPrimaryValues.Count - 1 Do
       Begin
        If vPrimaryValues.Items[I].vJSONValue.IsNull Then
         Begin
          BufferStream.InputBytes(VarToBytes(True, varBoolean));
          BufferStream.InputBytes(VarToBytes(vPrimaryValues.Items[I].ObjectValue, varInteger));
         End
        Else
         Begin
          BufferStream.InputBytes(VarToBytes(False, varBoolean));
          BufferStream.InputBytes(VarToBytes(vPrimaryValues.Items[I].ObjectValue,         varInteger));
          BufferStream.InputBytes(VarToBytes(vPrimaryValues.Items[I].vJSONValue.AsString, varString));
         End;
       End;
     End;
    BufferStream.InputBytes(VarToBytes(vMassiveValues.Count, varInteger));
    If assigned(MassiveBuffer) then
    For I := 1 To vMassiveValues.Count - 1 Do
     Begin
      If MassiveMode = mmUpdate Then
       Begin
        If Changes.Count = 0 Then
         Continue;
        vNoChange := True;
        For A := 0 To Changes.Count -1 Do
         Begin
          If assigned(MassiveBuffer) then
           Begin
            If TMassiveDatasetBuffer(MassiveBuffer).Dataset <> Nil Then
             Begin
              If TMassiveDatasetBuffer(MassiveBuffer).vMassiveFields.Count <= (I-1) Then
               Continue;
              If (TMassiveDatasetBuffer(MassiveBuffer).Dataset.FindField(TMassiveDatasetBuffer(MassiveBuffer).vMassiveFields.Items[I-1].vFieldName) <> Nil) Then
               Begin
                If TMassiveDatasetBuffer(MassiveBuffer).Dataset.FieldByName(TMassiveDatasetBuffer(MassiveBuffer).vMassiveFields.Items[I-1].vFieldName).ReadOnly Then
                 Continue;
               End
              Else
               vNoChange := Not TMassiveDatasetBuffer(MassiveBuffer).vReflectChanges;
              If Not((TMassiveDatasetBuffer(MassiveBuffer).Dataset.FindField(TMassiveDatasetBuffer(MassiveBuffer).vMassiveFields.Items[I-1].vFieldName) = Nil)) Then
               vNoChange := Lowercase(TMassiveDatasetBuffer(MassiveBuffer).vMassiveFields.Items[I-1].vFieldName) <> Lowercase(Changes[A]);
             End
            Else
             vNoChange := Lowercase(TMassiveDatasetBuffer(MassiveBuffer).vMassiveFields.Items[I-1].vFieldName) <> Lowercase(Changes[A]);
           End;

          If Not (vNoChange) Then
           Break;
         End;
        If vNoChange Then
         Continue;
       End;
     If TMassiveDatasetBuffer(MassiveBuffer).Dataset <> Nil Then
       Begin
        If TMassiveDatasetBuffer(MassiveBuffer).vMassiveFields.Count <= (I-1) then
         Continue;
       End;
      If vMassiveValues.Items[I].vJSONValue.IsNull Then
       BufferStream.InputBytes(VarToBytes(True, varBoolean)) //Valor Padrao para Null
      Else
       Begin
        BufferStream.InputBytes(VarToBytes(False, varBoolean)); //Valor Padrao para Not Null
        vOutParams   := TMemoryStream.Create;
        Try
         vMassiveValues.Items[I].SaveToStream(TMemoryStream(vOutParams));
         BufferStream.InputStream(vOutParams);
        Finally
         FreeAndNil(vOutParams);
        End;
       End;
     End;
   End;
 Finally
  BufferStream.SaveToStream(Dest);
  Dest.Position := 0;
  FreeAndNil(BufferStream);
 End;
End;

{ TMassiveBuffer }

Function TMassiveBuffer.Add(Item : TMassiveLine): Integer;
Var
 vItem : ^TMassiveLine;
Begin
 New(vItem);
 vItem^ := Item;
 Result := Inherited Add(vItem);
End;

Procedure TMassiveBuffer.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Inherited Clear;
End;

Procedure TMassiveBuffer.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   {$IFDEF RESTDWLAZARUS}
   If (Index <= Self.Count -1) Then
   {$ENDIF}
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     Try
      If Assigned(TMassiveLine(TList(Self).Items[Index]^)) Then
       FreeAndNil(PMassiveLine(TList(Self).Items[Index])^);
      {$IFDEF RESTDWLAZARUS}
       Dispose(PMassiveLine(TList(Self).Items[Index]));
      {$ELSE}
       Dispose(TList(Self).Items[Index]);
      {$ENDIF}
     Except
     End;
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveBuffer.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveBuffer.GetRec(Index: Integer): TMassiveLine;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveLine(TList(Self).Items[Index]^);
End;

Procedure TMassiveBuffer.PutRec(Index: Integer; Item: TMassiveLine);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveLine(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveDatasetBuffer }

Procedure TMassiveDatasetBuffer.NewLineBuffer(Var MassiveLineBuff : TMassiveLine;
                                              MassiveModeData     : TMassiveMode;
                                              ExecTag             : Boolean = False);
Var
 I            : Integer;
 MassiveValue : TMassiveValue;
Begin
 MassiveLineBuff.vMassiveMode := MassiveModeData;
 If ExecTag Then
  MassiveLineBuff.MassiveType := mtMassiveObject;
 If ExecTag Then
  Begin
   MassiveLineBuff.vDataExec.Text := vDataexec.Text;
   MassiveLineBuff.Params.Clear;
   MassiveLineBuff.Params.CopyFrom(vDWParams);
  End
 Else
  Begin
   For I := 0 To vMassiveFields.Count Do
    Begin
     MassiveValue          := TMassiveValue.Create;
     MassiveValue.Encoding := vEncoding;
     If (vMassiveFields.Count > I) And (I > 0) Then
      Begin
       MassiveValue.ValueName              := vMassiveFields.Items[I -1].FieldName;
       MassiveValue.ObjectValue            := vMassiveFields.Items[I -1].vFieldType;
       MassiveValue.vJSONValue.ObjectValue := MassiveValue.ObjectValue;
      End;
     {$IFDEF RESTDWLAZARUS}
     MassiveValue.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
     If I = 0 Then
      MassiveValue.Value := MassiveModeToString(MassiveModeData);
     MassiveLineBuff.vMassiveValues.Add(MassiveValue);
    End;
  End;
End;

Procedure TMassiveDatasetBuffer.BuildLine(Dataset             : TRESTDWClientSQLBase;
                                          MassiveModeBuff     : TMassiveMode;
                                          Var MassiveLineBuff : TMassiveLine;
                                          UpdateTag           : Boolean = False;
                                          ExecTag             : Boolean = False);
 Procedure CopyValue(MassiveModeBuff : TMassiveMode);
 Var
  I, A          : Integer;
  vFieldList    : TStringList;
  Field         : TField;
  vStringStreamB,
  vStringStream : TMemoryStream;
  vUpdateCase   : Boolean;
  MassiveValue  : TMassiveValue;
  vBookmark,
  vTagkey       : String;
  Function MasssiveFieldsCount : Integer;
  Var
   I : Integer;
  Begin
   Result := 0;
   vFieldList.Clear;
   For I := 0 To vMassiveFields.Count -1 Do
    Begin
     Field := Dataset.FindField(vMassiveFields.Items[I].vFieldName);
     If Field <> Nil Then
      Begin
       If Field.FieldKind = fkData Then
        Begin
         vFieldList.Add(vMassiveFields.Items[I].vFieldName);
         Result := Result + 1;
        End;
      End;
    End;
  End;
 Begin
  vStringStream := Nil;
  vUpdateCase   := False;
  vFieldList    := TStringList.Create;
  //KeyValues to Update
  If MassiveModeBuff = mmUpdate Then
   vUpdateCase := MassiveLineBuff.vPrimaryValues = Nil;
  If MassiveLineBuff.vPrimaryValues <> Nil Then
   vUpdateCase := MassiveLineBuff.vPrimaryValues.Count = 0;
  A   := MasssiveFieldsCount;
  Try
  If MassiveLineBuff.vMassiveValues.Count > 1 Then
   Begin
    MassiveLineBuff.vChanges.Clear;
    For I := 0 To vFieldList.Count -1 Do
     Begin
      Field := Dataset.FindField(vFieldList[I]);
      If Field <> Nil Then
       Begin
        If (Field.ProviderFlags = []) Then //Or (Field.ReadOnly) Then
         Continue;
        MassiveLineBuff.vMassiveValues.Items[I + 1].vJSONValue.ObjectValue := FieldTypeToObjectValue(Field.DataType);
        If MassiveModeBuff = mmDelete Then
         If Not(pfInKey in Field.ProviderFlags) Then
          Continue;
        //KeyValues to Update
        If (MassiveModeBuff = mmUpdate)      And
           (vUpdateCase)                     Then
         If (pfInKey in Field.ProviderFlags) Then
          Begin
           If MassiveLineBuff.vPrimaryValues = Nil Then
            MassiveLineBuff.vPrimaryValues := TMassiveValues.Create;
           If vUpdateCase Then
            Begin
             MassiveValue  := TMassiveValue.Create;
             MassiveValue.ObjectValue := FieldTypeToObjectValue(Field.DataType);
             MassiveValue.Encoding := Encoding;
             If Field.DataType in [ftBytes, ftVarBytes,
                                   ftBlob, ftGraphic,
                                   ftOraBlob, ftOraClob] Then
              Begin
               vStringStream := TMemoryStream.Create;
               Try
                If Not Field.IsNull Then
                 Begin
                  TBlobField(Field).SaveToStream(vStringStream);
                  vStringStream.Position := 0;
                  MassiveValue.LoadFromStream(vStringStream);
                  MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                 End
                Else
                 MassiveValue.Value := Null;
               Finally
                If Assigned(vStringStream) Then
                 FreeAndNil(vStringStream);
               End;
              End
             Else if Field.DataType in [ftDate, ftTime,ftDateTime, ftTimeStamp] then     // ajuste massive
              MassiveValue.Value := Field.AsDateTime
             Else if Trim(Field.AsString) <> '' Then
              MassiveValue.Value := Field.AsString;
             MassiveValue.ValueName   := Field.FieldName;
             MassiveLineBuff.vPrimaryValues.Add(MassiveValue);
            End;
          End;
        Case Field.DataType Of
         {$IFDEF DELPHIXEUP}ftFixedChar, ftFixedWideChar,{$ENDIF}
         {$IF Defined(RESTDWLAZARUS) OR Defined(DELPHIXEUP)}ftWideMemo,{$IFEND}
         ftString, ftWideString,
         ftMemo: Begin
                  If Not UpdateTag Then
                   Begin
                    If Field.IsNull Then
                     MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null
                    Else If Field.Size > 0 Then
                     MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Copy(Field.AsString, 1, Field.Size)
                    Else
                     MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
                   End
                  Else
                   Begin
                    If (MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value)   Then
                     Begin
                      MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.Value;
                      MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                     End;
                   End;
                 End;
         {$IFDEF DELPHIXEUP}ftLongWord,{$ENDIF}
         ftInteger, ftSmallInt, ftWord,
         ftLargeint: Begin
                      If Not UpdateTag Then
                       Begin
                        If Field.IsNull Then
                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null
                        Else If Trim(Field.AsString) <> '' Then
                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Trim(Field.AsString)
                        Else
                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                       End
                      Else
                       Begin
                        If Field.IsNull Then
                         Begin
                          MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                          MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName)); // ELOY - Add to BufferChanges
                         End
                        Else
                         Begin
                          If ((MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value)    Or
                              (MassiveLineBuff.vMassiveValues.Items[I + 1].isnull <> Field.IsNull)) Then
                           Begin
                            MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Trim(Field.AsString);
                            MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                           End;
                         End;
                       End;
                     End;
        {$IFDEF DELPHIXEUP}ftSingle, ftFMTBcd,{$ENDIF}
         ftFloat, ftCurrency,
         ftBCD : Begin
                  If Not UpdateTag Then
                   Begin
                    If Field.IsNull Then
                     MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null
                    Else If Trim(Field.AsString) <> '' Then
                     MassiveLineBuff.vMassiveValues.Items[I + 1].Value := BuildStringFloat(Field.AsString)
                    Else
                     MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                   End
                  Else
                   Begin
                    If Field.IsNull Then
                     Begin
                      MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                      MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName)); // ELOY - Add to BufferChanges
                     End
                    Else
                     Begin
                      If ((MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value)    Or
                          (MassiveLineBuff.vMassiveValues.Items[I + 1].isnull <> Field.IsNull)) Then
                       Begin
                        If Trim(Field.AsString) <> '' Then
                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := BuildStringFloat(Field.AsString)
                        Else
                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                        MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                       End;
                     End;
                   End;
                 End;
         ftDate, ftTime, ftDateTime,
         ftTimeStamp: Begin
                        If Not UpdateTag Then
                         Begin
                          If Field.IsNull Then
                           MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null
                          Else If Trim(Field.AsString) <> '' Then
                           MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsDateTime
                          Else
                           MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                         End
                        Else
                         Begin
                          If Field.IsNull Then
                           Begin
                            If Not MassiveLineBuff.vMassiveValues.Items[I + 1].IsNull  then
                             Begin
                              MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                              MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName)); // ELOY - Add to BufferChanges
                             End
                            Else
                             MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                           End
                          Else
                           Begin
                            If  ((MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value)   Or
                                (MassiveLineBuff.vMassiveValues.Items[I + 1].isnull <> Field.IsNull)) Then
                             Begin
                              If Trim(Field.AsString) <> '' Then
                               MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsDateTime
                              Else
                               MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                              MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                             End;
                           End;
                         End;
                      End;
         ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob,
         ftOraClob: Begin
                      vStringStream := TMemoryStream.Create;
                      Try
                       If Not Field.IsNull Then
                        Begin
                         MassiveLineBuff.vMassiveValues.Items[I + 1].Binary := True;
                         TBlobField(Field).SaveToStream(vStringStream);
                         vStringStream.Position := 0;
                         If Not UpdateTag Then
                          MassiveLineBuff.vMassiveValues.Items[I + 1].LoadFromStream(vStringStream) //StreamToHex(vStringStream)
                         Else
                          Begin
                           vStringStreamB := TMemoryStream.Create;
                           MassiveLineBuff.vMassiveValues.Items[I + 1].SaveToStream(vStringStreamB);
                           Try
                            If EncodeStream(vStringStreamB) <> EncodeStream(vStringStream) Then //StreamToHex(vStringStream) Then
                             Begin
                              MassiveLineBuff.vMassiveValues.Items[I + 1].LoadFromStream(vStringStream); //StreamToHex(vStringStream);
                              MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                             End;
                           Finally
                            FreeAndNil(vStringStreamB);
                           End;
                          End;
                        End
                       Else
                        Begin
                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                         MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                        End;
                      Finally
                       If Assigned(vStringStream) Then
                        FreeAndNil(vStringStream);
                      End;
                    End;
         Else
          Begin
           If Not UpdateTag Then
            MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.Value
           Else
            Begin
             If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value Then
              Begin
               MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.Value;
               MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
              End;
            End;
          End;
        End;
       End;
     End;
   End;
  Finally
   If MassiveLineBuff.vMassiveValues.Count > 1 Then
   If vReflectChanges Then
    Begin
     If Dataset is TRESTDWClientSQL Then
      Begin
       If TRESTDWClientSQL(Dataset).RecNo > 0 Then
        Begin
         Try
          vBookmark := BookmarkToHex(TRESTDWBytes(TRESTDWClientSQL(Dataset).Bookmark));
         Except
         End;
         vTagkey := IntToStr(vLastOpen) + '|' + EncodeStrings(vBookmark{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
         MassiveLineBuff.vMassiveValues.Items[MassiveLineBuff.vMassiveValues.Count -1].Value := EncodeStrings(vTagKey{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        End;
      End
     Else If Dataset is TRESTDWTable Then
      Begin
       If TRESTDWTable(Dataset).RecNo > 0 Then
        Begin
         Try
          vBookmark := BookmarkToHex(TRESTDWBytes(TRESTDWTable(Dataset).Bookmark));
         Except
         End;
         vTagkey := IntToStr(vLastOpen) + '|' + EncodeStrings(vBookmark{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
         MassiveLineBuff.vMassiveValues.Items[MassiveLineBuff.vMassiveValues.Count -1].Value := EncodeStrings(vTagKey{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        End;
      End;
    End;
   vFieldList.Free;
  End;
 End;
Begin
 MassiveLineBuff.vMassiveMode := MassiveModeBuff;
 Case MassiveModeBuff Of
  mmInsert : CopyValue(MassiveModeBuff);
  mmUpdate : CopyValue(MassiveModeBuff);
  mmDelete : Begin
              NewBuffer(MassiveModeBuff, ExecTag);
              CopyValue(MassiveModeBuff);
             End;
  mmExec   : NewBuffer(MassiveModeBuff, ExecTag);
 End;
End;

Function TMassiveDatasetBuffer.AtualRec : TMassiveLine;
Begin
 Result := Nil;
 If RecordCount > 0 Then
  Result := vMassiveBuffer.Items[vRecNo -1];
End;

Procedure TMassiveDatasetBuffer.MassiveCheck(Dataset : TRESTDWClientSQLBase);
Var
 I : Integer;
 MassiveField : TMassiveField;
Begin
 vMasterCompTag    := '';
 vMyCompTag        := Dataset.Componenttag;
 If Dataset is TRESTDWClientSQL Then
  Begin
   If TRESTDWClientSQL(Dataset).MasterDataSet <> Nil Then
    vMasterCompTag   := TRESTDWClientSQL(Dataset).MasterDataSet.Componenttag;
   vMasterCompFields := TRESTDWClientSQL(Dataset).RelationFields.Text;
  End
 Else If Dataset is TRESTDWTable Then
  Begin
   If TRESTDWTable(Dataset).MasterDataSet <> Nil Then
    vMasterCompTag   := TRESTDWTable(Dataset).MasterDataSet.Componenttag;
   vMasterCompFields := TRESTDWTable(Dataset).RelationFields.Text;
  End;
 vSequenceName     := Dataset.SequenceName;
 vSequenceField    := Dataset.SequenceField;
 For I := 0 To Dataset.Fields.Count -1 Do
  Begin
   If ((Dataset.Fields[I].FieldKind = fkData)             And
       ((pfInUpdate in Dataset.Fields[I].ProviderFlags)   Or
        (pfInWhere  in Dataset.Fields[I].ProviderFlags)   Or
        (pfInKey    in Dataset.Fields[I].ProviderFlags))) Or
      (vReflectChanges And ((Dataset.Fields[I].ReadOnly)  Or
       (Not(Dataset.Fields[I].ProviderFlags = []))))      Then
    Begin
     MassiveField                    := vMassiveFields.FieldByName(Dataset.Fields[I].FieldName);
     If MassiveField = Nil Then
      Begin
       MassiveField                   := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
       vMassiveFields.Add(MassiveField);
      End;
     MassiveField.vReadOnly          := Dataset.Fields[I].ReadOnly;
     MassiveField.vRequired          := Dataset.Fields[I].Required;
     MassiveField.vKeyField          := pfInKey in Dataset.Fields[I].ProviderFlags;
     MassiveField.vFieldName         := Dataset.Fields[I].FieldName;
     MassiveField.vFieldType         := FieldTypeToObjectValue(Dataset.Fields[I].DataType);
     MassiveField.vSize              := Dataset.Fields[I].DataSize;
     {$IFDEF DELPHIXEUP}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].AutoGenerateValue = arAutoInc) Or
                                           (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));

     If Not (MassiveField.vAutoGenerateValue) Then
       MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                            (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$ELSE}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                         (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$ENDIF}
    End
   Else
    Begin
     If (Not(vReflectChanges) And
        ((Dataset.Fields[I].ReadOnly) Or (Dataset.Fields[I].ProviderFlags = []))) Or
        (vReflectChanges And (Dataset.Fields[I].ProviderFlags = [])) Then
      Begin
       If vMassiveFields.FieldByName(Dataset.Fields[I].FieldName) <> Nil Then
        Begin
         If Dataset is TRESTDWClientSQL Then
          TRESTDWClientSQL(Dataset).RebuildMassiveDataset
         Else If Dataset is TRESTDWTable Then
          TRESTDWTable(Dataset).RebuildMassiveDataset;
         Exit;
         //vMassiveFields.Delete(Dataset.Fields[I].FieldName);
        End;
      End;
    End;
  End;
 If vReflectChanges Then
  Begin
   If vMassiveFields.Count > 0 Then
    Begin
     vMassiveLine.vMassiveMode       := mmBrowse;
     MassiveField                    := vMassiveFields.FieldByName(RESTDWFieldBookmark);
     If MassiveField = Nil Then
      Begin
       MassiveField                  := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
       vMassiveFields.Add(MassiveField);
      End;
     MassiveField.vRequired          := False;
     MassiveField.vKeyField          := False;
     MassiveField.vFieldName         := RESTDWFieldBookmark;
     MassiveField.vFieldType         := ovString;
     MassiveField.vSize              := 60;
     MassiveField.vAutoGenerateValue := True;
    End;
  End;
 If Dataset      Is TRESTDWClientSQL Then
  vTableName    := TRESTDWClientSQL(Dataset).UpdateTableName
 Else If Dataset Is TRESTDWTable Then
  vTableName    := TRESTDWTable(Dataset).TableName;
 vSequenceName  := Dataset.SequenceName;
End;

Procedure TMassiveDatasetBuffer.BuildBuffer(Dataset     : TRESTDWClientSQLBase;
                                            MassiveMode : TMassiveMode;
                                            UpdateTag   : Boolean = False;
                                            ExecTag     : Boolean = False);
Begin
 MassiveCheck(Dataset);
 Case MassiveMode Of
  mmInactive : Begin
                vMassiveBuffer.ClearAll;
                vMassiveLine.ClearAll;
                vMassiveFields.ClearAll;
               End;
  mmBrowse   : vMassiveLine.ClearAll;
  mmExec     : Begin
                vMassiveLine.ClearAll;
                BuildLine(Dataset, MassiveMode, vMassiveLine, UpdateTag, ExecTag);
               End;
  Else
   BuildLine(Dataset, MassiveMode, vMassiveLine, UpdateTag, ExecTag);
 End;
End;

Function TMassiveDatasetBuffer.MasterFieldFromDetail(Field : String) : String;
Var
 I : Integer;
Begin
 Result := '';
 I := vDetailFields.IndexOf(Field);
 If I > -1 Then
  Result := vMasterFields[I];
End;

Procedure TMassiveDatasetBuffer.BuildCompFields(MasterCompFields : String);
Var
 I        : Integer;
 vTempValue,
 vFieldA,
 vFieldD  : String;
 vFields  : TStringList;
Begin
 vFields  := TStringList.Create;
 Try
  vFields.Text := MasterCompFields;
  For I := 0 To vFields.Count -1 Do
   Begin
    vTempValue := vFields[I];
    vFieldA    := Copy(vTempValue, InitStrPos, (Pos('=', vTempValue) -1) - FinalStrPos);
    vFieldD    := Copy(vTempValue, (Pos('=', vTempValue) - FinalStrPos) + 1, Length(vTempValue));
    vMasterFields.Add(vFieldA);
    vDetailFields.Add(vFieldD);
   End;
 Finally
  FreeAndNil(vFields);
 End;
End;

Procedure TMassiveDatasetBuffer.BuildDataset(Dataset         : TRESTDWClientSQLBase;
                                             UpdateTableName : String);
Var
 I : Integer;
 MassiveField : TMassiveField;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
 vMasterCompTag    := '';
 vMyCompTag        := Dataset.Componenttag;
 If Dataset Is TRESTDWClientSQL Then
  Begin
   If TRESTDWClientSQL(Dataset).MasterDataSet <> Nil Then
    vMasterCompTag   := TRESTDWClientSQL(Dataset).MasterDataSet.Componenttag;
   vMasterCompFields := TRESTDWClientSQL(Dataset).RelationFields.Text;
  End
 Else If Dataset Is TRESTDWTable Then
  Begin
   If TRESTDWTable(Dataset).MasterDataSet <> Nil Then
    vMasterCompTag   := TRESTDWTable(Dataset).MasterDataSet.Componenttag;
   vMasterCompFields := TRESTDWTable(Dataset).RelationFields.Text;
  End;
 vSequenceName     := Dataset.SequenceName;
 vSequenceField    := Dataset.SequenceField;
 For I := 0 To Dataset.Fields.Count -1 Do
  Begin
   If ((Dataset.Fields[I].FieldKind = fkData)             And
       ((pfInUpdate in Dataset.Fields[I].ProviderFlags)   Or
        (pfInWhere  in Dataset.Fields[I].ProviderFlags)   Or
        (pfInKey    in Dataset.Fields[I].ProviderFlags))) Or
      (vReflectChanges And ((Dataset.Fields[I].ReadOnly)  Or
       (Not(Dataset.Fields[I].ProviderFlags = []))))      Then
    Begin
     MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
     MassiveField.vReadOnly          := Dataset.Fields[I].ReadOnly;
     MassiveField.vRequired          := Dataset.Fields[I].Required;
     MassiveField.vKeyField          := pfInKey in Dataset.Fields[I].ProviderFlags;
     MassiveField.vFieldName         := Dataset.Fields[I].FieldName;
     MassiveField.vFieldType         := FieldTypeToObjectValue(Dataset.Fields[I].DataType);
     MassiveField.vSize              := Dataset.Fields[I].DataSize;
     {$IFDEF DELPHIXEUP}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].AutoGenerateValue = arAutoInc) Or
                                         (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     If Not (MassiveField.vAutoGenerateValue) Then
      MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                          (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$ELSE}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                         (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$ENDIF}
     vMassiveFields.Add(MassiveField);
    End
   Else
    Begin
     If (Not(vReflectChanges) And (Dataset.Fields[I].ReadOnly)) Or
        (vReflectChanges And (Dataset.Fields[I].ProviderFlags = [])) Then
      Begin
       If vMassiveFields.FieldByName(Dataset.Fields[I].FieldName) <> Nil Then
        vMassiveFields.Delete(Dataset.Fields[I].FieldName);
      End;
    End;
  End;
 If vReflectChanges Then
  Begin
   If vMassiveFields.Count > 0 Then
    Begin
     vMassiveLine.vMassiveMode       := mmBrowse;
     MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
     MassiveField.vRequired          := False;
     MassiveField.vKeyField          := False;
     MassiveField.vFieldName         := RESTDWFieldBookmark;
     MassiveField.vFieldType         := ovString;
     MassiveField.vSize              := 60;
     MassiveField.vAutoGenerateValue := True;
     vMassiveFields.Add(MassiveField);
    End;
  End;
 vTableName    := UpdateTableName;
 vSequenceName := Dataset.SequenceName;
End;

Procedure TMassiveDatasetBuffer.ClearBuffer;
Begin
 vMassiveBuffer.ClearAll;
End;

Procedure TMassiveDatasetBuffer.ClearLine;
Begin
 vMassiveLine.ClearAll;
End;

Procedure TMassiveDatasetBuffer.ClearDataset;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
End;

Constructor TMassiveDatasetBuffer.Create(Dataset : TRESTDWClientSQLBase);
Begin
 vDataset        := Dataset;
 vRecNo          := -1;
 vMassiveBuffer  := TMassiveBuffer.Create;
 vMassiveLine    := TMassiveLine.Create;
 vMassiveFields  := TMassiveFields.Create(Self);
 vMassiveReply   := TMassiveReply.Create;
 vDataexec       := TStringList.Create;
 vDWParams       := TRESTDWParams.Create;
 vMassiveMode    := mmInactive;
 vMassiveType    := mtMassiveCache;
 vTableName      := '';
 vSequenceName   := '';
 vSequenceField  := '';
 vReflectChanges := True;
 vMasterFields   := TStringList.Create;
 vDetailFields   := TStringList.Create;
 vOnLoad         := False;
 vCreateBuffer   := True;
End;

Destructor TMassiveDatasetBuffer.Destroy;
Begin
 FreeAndNil(vMassiveBuffer);
 FreeAndNil(vMassiveLine);
 FreeAndNil(vMassiveFields);
 FreeAndNil(vMassiveReply);
 FreeAndNil(vMasterFields);
 FreeAndNil(vDetailFields);
 FreeAndNil(vDataexec);
 FreeAndNil(vDWParams);
 Inherited;
End;

Procedure TMassiveDatasetBuffer.First;
Begin
 If RecordCount > 0 Then
  Begin
   vRecNo := 1;
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.Last;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo <> RecordCount Then
    vRecNo := RecordCount;
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.NewBuffer(Var MassiveLineBuff : TMassiveLine;
                                          MassiveModeData     : TMassiveMode;
                                          ExecTag             : Boolean = False);
Begin
 MassiveLineBuff.ClearAll;
 MassiveLineBuff.vMassiveMode := MassiveModeData;
 NewLineBuffer(MassiveLineBuff, MassiveModeData, ExecTag); //Sempre se assume mmInsert como padrão
End;

Procedure TMassiveDatasetBuffer.NewBuffer(Dataset         : TRESTDWClientSQLBase;
                                          MassiveModeData : TMassiveMode;
                                          ExecTag         : Boolean = False);
Begin
 vMassiveLine.ClearAll;
 vMassiveLine.vMassiveMode := MassiveModeData;
 MassiveCheck(Dataset);
 NewLineBuffer(vMassiveLine, MassiveModeData, ExecTag); //Sempre se assume mmInsert como padrão
 //BuildLine(Dataset, MassiveModeData, vMassiveLine);//Sempre se assume mmInsert como padrão
End;

Procedure TMassiveDatasetBuffer.NewBuffer(MassiveModeData     : TMassiveMode;
                                          ExecTag             : Boolean = False);
Begin
 vMassiveLine.ClearAll;
 vMassiveLine.vMassiveMode := MassiveModeData;
 NewLineBuffer(vMassiveLine, MassiveModeData, ExecTag); //Sempre se assume mmInsert como padrão
End;

Procedure TMassiveDatasetBuffer.Next;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo < RecordCount Then
    Inc(vRecNo);
   ReadStatus;
  End;
End;

Function TMassiveDatasetBuffer.PrimaryKeys : TStringList;
Var
 I : Integer;
Begin
 Result := TStringList.Create;
 If vMassiveFields <> Nil Then
  Begin
   For I := 0 To vMassiveFields.Count -1 Do
    Begin
     If vMassiveFields.Items[I].vKeyField Then
      Result.Add(vMassiveFields.Items[I].vFieldName);
    End;
  End;
End;

Procedure TMassiveDatasetBuffer.Prior;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo > 1 Then
    Dec(vRecNo);
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.ReadStatus;
Begin
 If (RecordCount > 0) Then
  Begin
   vCreateBuffer := False;
   If vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Count > 0 Then
    vMassiveMode  := StringToMassiveMode(vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[0].Value)
   Else
    vMassiveMode  := vMassiveBuffer.Items[vRecNo -1].vMassiveMode;
   vDataexec.Text := vMassiveBuffer.Items[vRecNo -1].vDataExec.Text;
   vDWParams.CopyFrom(vMassiveBuffer.Items[vRecNo -1].vDWParams);
  End
 Else
  vMassiveMode := mmInactive;
End;

Function TMassiveDatasetBuffer.RecNo : Integer;
Begin
 Result := vRecNo;
End;

Function TMassiveDatasetBuffer.RecordCount : Integer;
Begin
 Result := 0;
 If vMassiveBuffer <> Nil Then
  Result := vMassiveBuffer.Count;
End;

Procedure TMassiveDatasetBuffer.SaveBuffer(Dataset : TRESTDWClientSQLBase;
                                           ExecTag : Boolean = False);
Var
 I, A          : Integer;
 Field         : TField;
 vStringStream : TMemoryStream;
 MassiveLine   : TMassiveLine;
 MassiveValue  : TMassiveValue;
 Function GetFieldIndex(FieldName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If LowerCase(vMassiveFields.Items[I].FieldName) = LowerCase(FieldName) Then
     Result := I;
    If Result <> -1 Then
     Break;
   End;
 End;
Begin
 vStringStream           := Nil;
 MassiveLine             := TMassiveLine.Create;
 MassiveLine.MassiveMode := vMassiveLine.MassiveMode;
 MassiveLine.MassiveType := vMassiveLine.MassiveType;
 NewBuffer(MassiveLine, vMassiveLine.vMassiveMode, ExecTag);
 Try
  If ExecTag Then
   Begin
    MassiveLine.vDataExec.Text := vMassiveLine.DataExec.Text;
    MassiveLine.Params.Clear;
    MassiveLine.Params.CopyFrom(vMassiveLine.Params);
   End
  Else
   Begin
    If vMassiveLine.vMassiveValues.Count > 1 Then
    If vMassiveLine.vMassiveMode = mmUpdate Then
     Begin
      For I := 0 To vMassiveLine.vChanges.Count -1 Do
       Begin
        Field := Dataset.FindField(vMassiveLine.vChanges[I]);
        If Field <> Nil Then
         Begin
          MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].ValueName              := vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].ValueName;
          MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].ObjectValue            := vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].ObjectValue;
          MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].vJSONValue.ObjectValue := vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].vJSONValue.ObjectValue;
          If Field.DataType  In [ftBytes, ftVarBytes,
                                 ftBlob, ftGraphic,
                                 ftOraBlob, ftOraClob] Then
           Begin
            Try
             vStringStream := TMemoryStream.Create;
             vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].SaveToStream(vStringStream);
             vStringStream.Position := 0;
             If vStringStream.Size > 0 Then
              MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].LoadFromStream(vStringStream);
            Finally
             If Assigned(vStringStream) Then
              FreeAndNil(vStringStream);
            End;
           End
          Else
           Begin
            If vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].isnull Then
             MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].Value := Null
            Else
             MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].Value := vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].Value;
           End;
         End;
       End;
      If vReflectChanges Then
       Begin
        If vMassiveLine.vChanges.IndexOf(RESTDWFieldBookmark) = -1 Then
         vMassiveLine.vChanges.Add(RESTDWFieldBookmark);
        MassiveLine.vMassiveValues.Items[GetFieldIndex(RESTDWFieldBookmark) +1].Value := vMassiveLine.vMassiveValues.Items[GetFieldIndex(RESTDWFieldBookmark) +1].Value;
       End;
     End
    Else
     Begin
      For I := 0 To vMassiveFields.Count -1 Do
       Begin
        If I = 0 Then
         MassiveLine.vMassiveValues.Items[I].Value := vMassiveLine.vMassiveValues.Items[I].Value;
        Field := Dataset.FindField(vMassiveFields.Items[I].vFieldName);
        If Field <> Nil Then
         Begin
          If vMassiveLine.vMassiveMode = mmDelete Then
           If Not(pfInKey in Field.ProviderFlags) Then
            Continue;
          MassiveLine.vMassiveValues.Items[I +1].vJSONValue.ObjectValue := vMassiveLine.vMassiveValues.Items[I +1].vJSONValue.ObjectValue;
          If Field.DataType  In [ftBytes, ftVarBytes,
                                 ftBlob, ftGraphic,
                                 ftOraBlob, ftOraClob] Then
           Begin
            vStringStream := TMemoryStream.Create;
            Try
             vMassiveLine.vMassiveValues.Items[I +1].SaveToStream(vStringStream);
             vStringStream.Position := 0;
             If vStringStream.Size > 0 Then
              MassiveLine.vMassiveValues.Items[I +1].LoadFromStream(vStringStream);
            Finally
             If Assigned(vStringStream) Then
              FreeAndNil(vStringStream);
            End;
           End
          Else
           Begin
            If Not vMassiveLine.vMassiveValues.Items[I +1].isNull Then
             MassiveLine.vMassiveValues.Items[I +1].Value := vMassiveLine.vMassiveValues.Items[I +1].Value;
           End;
         End
        Else
         Begin
          If vReflectChanges Then
           Begin
            If (vMassiveLine.vMassiveValues.Items[I +1].Value <> '')               And
               (Lowercase(vMassiveFields.Items[I].vFieldName) = Lowercase(RESTDWFieldBookmark)) Then
             MassiveLine.vMassiveValues.Items[I +1].Value := vMassiveLine.vMassiveValues.Items[I +1].Value;
           End;
         End;
       End;
     End;
   End;
 Finally
  //Update Changes
  If ExecTag Then
   Begin
    vMassiveBuffer.Add(MassiveLine);
    vMassiveLine.ClearAll;
   End
  Else
   Begin
    If vMassiveLine.vMassiveValues.Count > 1 Then
     Begin
      For A := 0 To vMassiveLine.vChanges.Count -1 do
       MassiveLine.vChanges.Add(vMassiveLine.vChanges[A]);
      //KeyValues to Update
      If vMassiveLine.vPrimaryValues <> Nil Then
       Begin
        If vMassiveLine.vPrimaryValues.Count > 0 Then
         Begin
          If MassiveLine.vPrimaryValues = Nil Then
           MassiveLine.vPrimaryValues := TMassiveValues.Create;
          For A := 0 To vMassiveLine.vPrimaryValues.Count -1 do
           Begin
            MassiveValue             := TMassiveValue.Create;
            MassiveValue.ObjectValue := vMassiveLine.vPrimaryValues.Items[A].ObjectValue;
            MassiveValue.ValueName   := vMassiveLine.vPrimaryValues.Items[A].ValueName;
            MassiveValue.CopyValue(vMassiveLine.vPrimaryValues.Items[A]);
            MassiveLine.vPrimaryValues.Add(MassiveValue);
           End;
         End;
       End;
      vMassiveBuffer.Add(MassiveLine);
      vMassiveLine.ClearAll;
     End;
   End;
 End;
End;

Procedure TMassiveDatasetBuffer.LoadFromStream(Source     : TStream);
Var
 BufferBase        : TRESTDWBufferBase; //Pacote de Entrada
 aHeaderStream,
 aBodyStream       : TStream;
 aMassiveValue     : TMassiveValue;
 aMassiveField     : TMassiveField;
 aBytesDefs,
 aBytesBody        : TRESTDWBytes;
 aMasterCompFields,
 aTableName,
 aTagFields,
 aSequenceName,
 aSequenceField,
 aMyCompTag,
 aMasterCompTag,
 aTagLinkFields    : String;
 aMassiveType      : TTypeObject;
 aObjectDirection  : TObjectDirection;
 aTempBool,
 aReflectChanges   : Boolean;
 aObjectValue      : TObjectValue;
 vTempValue        : String;
 aValue            : DWInteger;
 Function GetFieldIndex(FieldName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If LowerCase(vMassiveFields.Items[I].FieldName) = LowerCase(FieldName) Then
     Result := I;
    If Result <> -1 Then
     Break;
   End;
 End;
 Function GetFieldIndexChanges(Changes   : TStrings;
                               FieldName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Changes.Count -1 Do
   Begin
    If LowerCase(Changes[I]) = LowerCase(FieldName) Then
     Result := I;
    If Result <> -1 Then
     Break;
   End;
 End;
 Procedure LoadHeader;
 Var
  BufferHeader : TRESTDWBufferBase;
  MassiveField : TMassiveField;
 Begin
  If Assigned(aHeaderStream)  Then
   Begin
    BufferHeader := TRESTDWBufferBase.Create;
    Try
     BufferHeader.LoadToStream(aHeaderStream);
     FreeAndNil(aHeaderStream);
     While Not BufferHeader.Eof Do
      Begin
       MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
       MassiveField.vFieldName         := BytesToVar(BufferHeader.ReadBytes, varString);
       MassiveField.vFieldType         := TObjectValue(BytesToVar(BufferHeader.ReadBytes, varInteger));
       MassiveField.vKeyField          := BytesToVar(BufferHeader.ReadBytes, varString) = 'S';
       MassiveField.vRequired          := BytesToVar(BufferHeader.ReadBytes, varString) = 'S';
       MassiveField.vSize              := BytesToVar(BufferHeader.ReadBytes, varInteger);
       MassiveField.vPrecision         := BytesToVar(BufferHeader.ReadBytes, varInteger);
       MassiveField.vReadOnly          := BytesToVar(BufferHeader.ReadBytes, varString) = 'S';
       MassiveField.vAutoGenerateValue := BytesToVar(BufferHeader.ReadBytes, varString) = 'S';
       vMassiveFields.Add(MassiveField);
      End;
    Finally
     FreeAndNil(BufferHeader);
    End;
   End;
 End;
 Procedure LoadBodyData;
 Var
  BufferStream,
  BufferBody   : TRESTDWBufferBase;
  aValueStream,
  aStream      : TStream;
  MassiveLine  : TMassiveLine;
  MassiveValue : TMassiveValue;
  aBool        : Boolean;
  vValuesCount,
  A, X, C, I   : Integer;
 Begin
  If Assigned(aBodyStream)  Then
   Begin
    BufferBody := TRESTDWBufferBase.Create;
    BufferBody.LoadToStream(aBodyStream);
    FreeAndNil(aBodyStream);
    vMassiveMode := mmInactive;
    Try
     While Not BufferBody.Eof Do
      Begin
       aStream      := BufferBody.ReadStream;
       MassiveLine  := TMassiveLine.Create;
       BufferStream := TRESTDWBufferBase.Create;
       Try
        BufferStream.LoadToStream(aStream);
        FreeAndNil(aStream);
        If BufferStream.Size > 0 Then
         vMassiveMode := TMassiveMode(BytesToVar(BufferStream.ReadBytes, varInteger));
        NewLineBuffer(MassiveLine, vMassiveMode, vMassiveMode = mmExec);
        If vMassiveMode = mmExec Then
         Begin
          vDataexec.Text := BytesToVar(BufferStream.ReadBytes, varString);
          aStream        := BufferStream.ReadStream;
          If Assigned(aStream) Then
           Begin
            Try
             vDWParams.LoadFromStream(aStream);
            Finally
             FreeAndNil(aStream);
            End;
           End;
         End;
        aBool := BytesToVar(BufferStream.ReadBytes, varBoolean);
        If aBool Then
         MassiveLine.vChanges.Text := DecodeStrings(BytesToVar(BufferStream.ReadBytes, varString){$IFDEF RESTDWLAZARUS}, TDatabaseCharSet.csUTF8{$ENDIF});
        aBool := BytesToVar(BufferStream.ReadBytes, varBoolean);
        If aBool Then
         Begin
          For I := 0 To BytesToVar(BufferStream.ReadBytes, varInteger) -1 Do
           Begin
            MassiveValue             := TMassiveValue.Create;
            aBool                    := BytesToVar(BufferStream.ReadBytes, varBoolean);
            MassiveValue.ObjectValue := TObjectValue(BytesToVar(BufferStream.ReadBytes, varInteger));
            If Not aBool Then
             Begin
              vTempValue := BytesToVar(BufferStream.ReadBytes, varString);
              If MassiveValue.ObjectValue in [ovString, ovWideString, ovMemo,
                                              ovWideMemo, ovFixedChar, ovFixedWideChar] Then
               MassiveValue.Value := vTempValue
              Else If MassiveValue.vJSONValue.ObjectValue in [ovDate, ovTime, ovDateTime, ovTimeStamp] then     // ajuste massive
               MassiveValue.Value := UnixToDateTime(StrToInt64(vTempValue))
              Else
               MassiveValue.Value := vTempValue;
             End;
            MassiveValue.SetModified(Not (vOnLoad));
            If Not Assigned(MassiveLine.vPrimaryValues) Then
             MassiveLine.vPrimaryValues := TMassiveValues.Create;
            MassiveLine.vPrimaryValues.Add(MassiveValue);
           End;
         End;
       Finally
        FreeAndNil(aStream);
       End;
       vValuesCount := BytesToVar(BufferStream.ReadBytes, varInteger);
       Try
        For C := 1 To vValuesCount -1 Do
         Begin
          If vMassiveMode = mmUpdate Then
           Begin
            A := GetFieldIndexChanges(MassiveLine.vChanges, vMassiveFields.Items[C -1].FieldName);
            If A > -1 Then
             Begin
              X := GetFieldIndex(MassiveLine.vChanges[A]) +1;
              MassiveLine.Values[X].vJSONValue.ObjectValue := vMassiveFields.Items[X -1].vFieldType;
              aBool := BytesToVar(BufferStream.ReadBytes, varBoolean);
              If Not aBool Then
               Begin
                aValueStream := BufferStream.ReadStream;
                Try
                 If Assigned(aValueStream) Then
                  MassiveLine.Values[X].LoadFromStream(TMemoryStream(aValueStream));
                Finally
                 If Assigned(aValueStream) Then
                  FreeAndNil(aValueStream);
                End;
               End;
             End;
           End
          Else If vMassiveMode <> mmExec Then
           Begin
            MassiveLine.Values[C].vJSONValue.ObjectValue := vMassiveFields.Items[C -1].vFieldType;
            aBool := BytesToVar(BufferStream.ReadBytes, varBoolean);
            If Not aBool Then
             Begin
              aValueStream := BufferStream.ReadStream;
              Try
               If Assigned(aValueStream) Then
                MassiveLine.Values[C].LoadFromStream(TMemoryStream(aValueStream));
              Finally
               If Assigned(aValueStream) Then
                FreeAndNil(aValueStream);
              End;
             End;
           End;
         End;
        vMassiveBuffer.Add(MassiveLine);
       Finally
        FreeAndNil(BufferStream);
       End;
      End;
    Finally
     FreeAndNil(BufferBody);
    End;
   End;
 End;
Begin
 BufferBase           := TRESTDWBufferBase.Create;
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
 Try
  BufferBase.LoadToStream(Source);
  If BufferBase.Size > 0 Then
   Begin
    aHeaderStream      := BufferBase.ReadStream;
    LoadHeader;
    aTempBool          := BytesToVar(BufferBase.ReadBytes, varBoolean);
    If aTempBool Then
     aMasterCompFields := BytesToVar(BufferBase.ReadBytes, varString);
    vMasterCompFields  := aMasterCompFields;
    aMassiveType       := TTypeObject     (BytesToVar(BufferBase.ReadBytes, varInteger));
    aObjectDirection   := TObjectDirection(BytesToVar(BufferBase.ReadBytes, varInteger));
    aTempBool          := BytesToVar(BufferBase.ReadBytes, varBoolean);
    aObjectValue       := TObjectValue    (BytesToVar(BufferBase.ReadBytes, varInteger));
    vTableName         := BytesToVar(BufferBase.ReadBytes, varString);
    aTagFields         := BytesToVar(BufferBase.ReadBytes, varString);
    vReflectChanges    := BytesToVar(BufferBase.ReadBytes, varBoolean);
    vMasterCompTag     := '';
    vSequenceName      := BytesToVar(BufferBase.ReadBytes, varString);
    vSequenceField     := BytesToVar(BufferBase.ReadBytes, varString);
    vmycomptag         := BytesToVar(BufferBase.ReadBytes, varString);
    vMasterCompTag     := BytesToVar(BufferBase.ReadBytes, varString);
    aTagLinkFields     := BytesToVar(BufferBase.ReadBytes, varString);
    If Trim(aTagLinkFields) <> '' Then
     Begin
      vMasterCompFields := DecodeStrings(aTagLinkFields{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
      BuildCompFields(vMasterCompFields);
     End;
    //Carregando Body
    aBodyStream      := BufferBase.ReadStream;
    LoadBodyData;
   End;
 Finally
  FreeAndNil(BufferBase);
 End;
End;

Procedure TMassiveDatasetBuffer.SaveToStream  (Var Dest      : TStream;
                                               MassiveBuffer : TObject = Nil);
Var
 BufferStream,
 BufferHeader,
 BufferBase       : TRESTDWBufferBase; //Pacote de Saida
 vHeaderStream,
 vBufferStream,
 vLineStream      : TStream;
 vInfoBytes       : TRESTDWBytes;
 vValueData,
 vSizeData        : DWInteger;
 vTagFields,
 vTagLinkFields   : String;
 vLineString      : DWString;
 A                : Integer;
 vHasMasterFields : Boolean;
 Procedure GenerateHeader;
 Var
  vPrecision,
  I              : Integer;
  vPrimary,
  vRequired,
  vReadOnly,
  vGenerateLine,
  vAutoinc       : string;
 Begin
  For I := 0 To vMassiveFields.Count - 1 Do
   Begin
    If vDataset <> Nil Then
     Begin
      If (vDataset.FindField(vMassiveFields.Items[I].vFieldName) <> Nil) Then
       Begin
        If Not(Self.vReflectChanges) And
           (vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).ReadOnly) And
           ((Not vMassiveFields.Items[I].vKeyField) And (Not vMassiveFields.Items[I].vAutoGenerateValue)) Then
         Continue;
        {$IFDEF DELPHIXEUP}
        vMassiveFields.Items[I].vReadOnly          := vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).ReadOnly;
        vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).AutoGenerateValue = arAutoInc) Or
                                                       (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        If Not (vMassiveFields.Items[I].vAutoGenerateValue) Then
         vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc) Or
                                                        (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        {$ELSE}
        vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc) Or
                                                        (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        {$ENDIF}
       End;
     End;
    vPrimary  := 'N';
    vAutoinc  := 'N';
    vReadOnly := 'N';
    If vMassiveFields.Items[I].vKeyField Then
     vPrimary := 'S';
    vRequired := 'N';
    If vMassiveFields.Items[I].vRequired Then
     vRequired := 'S';
    If vMassiveFields.Items[I].vReadOnly Then
     vReadOnly := 'S';
    If (vMassiveFields.Items[I].vAutoGenerateValue) Or
       (vMassiveFields.Items[I].FieldType = ovAutoInc) Then
     vAutoinc := 'S';
    vPrecision := 0;
    If vMassiveFields.Items[I].FieldType In [{$IFDEF DELPHIXEUP}
                                             ovExtended,{$ENDIF}
                                             ovFloat, ovCurrency, ovFMTBcd,
                                             ovSingle, ovBCD] Then
     vPrecision := vMassiveFields.Items[I].Precision;
    BufferHeader.InputBytes(VarToBytes(vMassiveFields.Items[I].vFieldName, varString));
    BufferHeader.InputBytes(VarToBytes(vMassiveFields.Items[I].FieldType,  varInteger));
    BufferHeader.InputBytes(VarToBytes(vPrimary,                           varString));
    BufferHeader.InputBytes(VarToBytes(vRequired,                          varString));
    BufferHeader.InputBytes(VarToBytes(vMassiveFields.Items[I].Size,       varInteger));
    BufferHeader.InputBytes(VarToBytes(vPrecision,                         varInteger));
    BufferHeader.InputBytes(VarToBytes(vReadOnly,                          varString));
    BufferHeader.InputBytes(VarToBytes(vAutoinc,                           varString));
   End;
 End;
Begin
 BufferStream := TRESTDWBufferBase.Create;
 BufferHeader := TRESTDWBufferBase.Create;
 BufferBase   := TRESTDWBufferBase.Create;
 Try
  GenerateHeader;
  For A := 0 To vMassiveBuffer.Count -1 Do
   Begin
    vLineStream := TMemoryStream.Create;
    Try
     vMassiveBuffer.Items[A].SaveToStream(vLineStream, MassiveBuffer);
     BufferStream.InputStream(vLineStream);
    Finally
     FreeAndNil(vLineStream);
    End;
   End;
  //Input do Buffer de Header
  vHeaderStream := TMemoryStream.Create;
  Try
   BufferHeader.SaveToStream(vHeaderStream);
   vHeaderStream.Position := 0;
   BufferBase.InputStream(vHeaderStream);
  Finally
   FreeAndNil(vHeaderStream);
  End;
  //Input dos dados do Pacote
  vHasMasterFields := Trim(vMasterCompFields) <> '';
  BufferBase.InputBytes(VarToBytes(vHasMasterFields,   varBoolean));
  If (Trim(vMasterCompFields) <> '') Then
   BufferBase.InputBytes(VarToBytes(vMasterCompFields, varString));
  vValueData := Integer(toMassive);
  BufferBase.InputBytes(VarToBytes(vValueData,         varInteger));
  vValueData := Integer(odINOUT);
  BufferBase.InputBytes(VarToBytes(vValueData,         varInteger));
  BufferBase.InputBytes(VarToBytes(False,              varBoolean));
  vValueData := Integer(ovObject);
  BufferBase.InputBytes(VarToBytes(vValueData,         varInteger));
  BufferBase.InputBytes(VarToBytes(vTableName,         varString));
  BufferBase.InputBytes(VarToBytes(vTagFields,         varString));
  BufferBase.InputBytes(VarToBytes(vReflectChanges,    varBoolean));
  BufferBase.InputBytes(VarToBytes(vSequenceName,      varString));
  BufferBase.InputBytes(VarToBytes(vSequenceField,     varString));
  BufferBase.InputBytes(VarToBytes(vMyCompTag,         varString));
  BufferBase.InputBytes(VarToBytes(vMasterCompTag,     varString));
  BufferBase.InputBytes(VarToBytes(vTagLinkFields,     varString));
  //Input das Linhas de Dados
  vBufferStream := TMemoryStream.Create;
  Try
   BufferStream.SaveToStream(vBufferStream);
   vBufferStream.Position := 0;
   BufferBase.InputStream(vBufferStream);
  Finally
   FreeAndNil(vBufferStream);
  End;
  BufferBase.SaveToStream(Dest);
 Finally
  If Assigned(BufferStream) Then
   FreeAndNil(BufferStream);
  If Assigned(BufferBase) Then
   FreeAndNil(BufferBase);
  If Assigned(BufferHeader) Then
   FreeAndNil(BufferHeader);
 End;
End;

Procedure TMassiveDatasetBuffer.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonValueB,
 bJsonValueC,
 bJsonValueD : TRESTDWJSONInterfaceBase;
 bJsonOBJC,
 bJsonValue  : TRESTDWJSONInterfaceObject;
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC,
 bJsonArrayD,
 bJsonArrayE  : TRESTDWJSONInterfaceArray;
 MassiveValue : TMassiveValue;
 A, C,
 D, E, I, X   : Integer;
 MassiveField : TMassiveField;
 MassiveLine  : TMassiveLine;
 vTempValue   : String;
 Function GetFieldIndex(FieldName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If LowerCase(vMassiveFields.Items[I].FieldName) = LowerCase(FieldName) Then
     Result := I;
    If Result <> -1 Then
     Break;
   End;
 End;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
 bJsonValue  := TRESTDWJSONInterfaceObject.Create(Value);
 bJsonArray  := Nil;
 bJsonArrayB := Nil;
 vOnLoad     := True;
 If bJsonValue.PairCount > 0 Then
  Begin
   Try
    vTableName        := bJsonValue.pairs[4].Value;
    vReflectChanges   := False;
    vMasterCompFields := '';
    vMasterCompTag    := '';
    If bJsonValue.PairCount > 5 Then
     Begin
      vReflectChanges   := StringToBoolean(bJsonValue.pairs[6].Value);
      vSequenceName     := bJsonValue.pairs[7].Value;
      vSequenceField    := bJsonValue.pairs[8].Value;
      vmycomptag        := bJsonValue.pairs[9].Value;
      vMasterCompTag    := bJsonValue.pairs[10].Value;
      If Not (bJsonValue.pairs[11].IsNull) Then
       Begin
        vMasterCompFields := DecodeStrings(bJsonValue.pairs[11].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        BuildCompFields(vMasterCompFields);
       End;
     End;
    bJsonArray  := bJsonValue.openArray(bJsonValue.pairs[5].Name);
    If bJsonArray.ElementCount > 0 Then
    For A := 0 To 1 Do
     Begin
      bJsonOBJ     := bJsonArray.GetObject(A);
      If A = 0 Then //Fields
       Begin
        Try
         bJsonArrayB := TRESTDWJSONInterfaceObject(bJsonOBJ).openArray('fields');
         For I := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
           bJsonOBJb :=  bJsonArrayB.GetObject(I);
           Try
            MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
            MassiveField.vRequired          := TRESTDWJSONInterfaceObject(bJsonOBJb).Pairs[3].Value      = 'S';
            MassiveField.vKeyField          := TRESTDWJSONInterfaceObject(bJsonOBJb).Pairs[2].Value      = 'S';
            MassiveField.vFieldName         := TRESTDWJSONInterfaceObject(bJsonOBJb).Pairs[0].Value;
            MassiveField.vFieldType         := GetValueType(TRESTDWJSONInterfaceObject(bJsonOBJb).Pairs[1].Value);
            MassiveField.vSize              := StrToInt(TRESTDWJSONInterfaceObject(bJsonOBJb).Pairs[4].Value);
            MassiveField.vAutoGenerateValue := TRESTDWJSONInterfaceObject(bJsonOBJb).Pairs[7].Value = 'S';
            MassiveField.vReadOnly          := TRESTDWJSONInterfaceObject(bJsonOBJb).Pairs[6].Value = 'S';
            vMassiveFields.Add(MassiveField);
           Finally
            FreeAndNil(bJsonOBJb);
           End;
          End;
        Finally
         FreeAndNil(bJsonArrayB);
        End;
       End
      Else //Data
       Begin
        bJsonArrayB := TRESTDWJSONInterfaceObject(bJsonOBJ).OpenArray('lines');
        For E := 0 to bJsonArrayB.ElementCount -1  Do
         Begin
          bJsonValueC := bJsonArrayB.GetObject(E);
          bJsonArrayC := TRESTDWJSONInterfaceArray(bJsonValueC);
          Try
           bJsonValueD  := bJsonArrayC.GetObject(0);
           bJsonArrayD  := TRESTDWJSONInterfaceArray(bJsonValueD);
           bJsonOBJC    := TRESTDWJSONInterfaceObject(bJsonArrayD.GetObject(0));
           vMassiveMode := StringToMassiveMode(bJsonOBJC.Pairs[0].Value);
           If vMassiveMode = mmExec Then
            Begin
             FreeAndNil(bJsonOBJC);
             bJsonOBJC    := TRESTDWJSONInterfaceObject(bJsonArrayD.GetObject(1));
             vDataexec.Text := DecodeStrings(bJsonOBJC.Pairs[0].Value{$IFDEF RESTDWLAZARUS}, vDatabaseCharSet{$ENDIF});
             FreeAndNil(bJsonOBJC);
             bJsonOBJC    := TRESTDWJSONInterfaceObject(bJsonArrayD.GetObject(2));
             vDWParams.FromJSON(DecodeStrings(bJsonOBJC.Pairs[0].Value{$IFDEF RESTDWLAZARUS}, vDatabaseCharSet{$ENDIF}));
            End;
           FreeAndNil(bJsonOBJC);
           MassiveLine  := TMassiveLine.Create;
           NewLineBuffer(MassiveLine, vMassiveMode, vMassiveMode = mmExec); //Sempre se assume MassiveMode vindo na String
           vDWParams.Clear;
           If vMassiveMode = mmUpdate Then
            Begin
             If bJsonArrayD.ElementCount > 1 Then
              Begin
               bJsonArrayE  := TRESTDWJSONInterfaceArray(bJsonArrayC.GetObject(2));
               If bJsonArrayE.JSONObject <> Nil Then
                Begin
                 For D := 0 To bJsonArrayE.ElementCount -1 Do //Valores
                  Begin
                   bJsonValueB  := bJsonArrayE.GetObject(D);
                   MassiveLine.vChanges.Add(TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value);
                   FreeAndNil(bJsonValueB);
                  End;
                End;
               bJsonArrayE.Free;
               bJsonArrayE  := TRESTDWJSONInterfaceArray(bJsonArrayC.GetObject(1));
               If bJsonArrayE.JSONObject <> Nil Then
                Begin
                 For D := 0 To bJsonArrayE.ElementCount -1 Do //Valores
                  Begin
                   MassiveValue        := TMassiveValue.Create;
                   bJsonValueB         := bJsonArrayE.GetObject(D);
                   vTempValue          := TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value;
                   MassiveValue.ObjectValue := GetValueType(Copy(vTempValue, InitStrPos, (Pos('|', vTempValue) - FinalStrPos) -1));
                   DeleteStr(vTempValue, InitStrPos, (Pos('|', vTempValue) - FinalStrPos));
                   If (vTempValue = cNullvalue) or
                      (vTempValue = '') Then
                    vTempValue := '';
                   If MassiveValue.ObjectValue in [ovString, ovWideString, ovMemo,
                                                   ovWideMemo, ovFixedChar, ovFixedWideChar] Then
                    MassiveValue.Value := vTempValue
                   Else If MassiveValue.vJSONValue.ObjectValue in [ovDate, ovTime, ovDateTime, ovTimeStamp] then     // ajuste massive
                    Begin
                     If Not TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].isnull Then
                      MassiveValue.Value := UnixToDateTime(StrToInt64(vTempValue));
                    End
                   Else
                    MassiveValue.Value := vTempValue;
                   MassiveValue.SetModified(Not (vOnLoad));
                   If Not Assigned(MassiveLine.vPrimaryValues) Then
                    MassiveLine.vPrimaryValues := TMassiveValues.Create;
                   MassiveLine.vPrimaryValues.Add(MassiveValue);
                   FreeAndNil(bJsonValueB);
                  End;
                End;
               bJsonArrayE.Free;
               If MassiveLine.vChanges.count > 0 Then
               For C := 1 To bJsonArrayD.ElementCount -1 Do //Valores
                Begin
                 bJsonValueB := bJsonArrayD.GetObject(C);
                 MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].vJSONValue.ObjectValue := vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType;
                 If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovString, ovMemo, ovWideString, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
                  Begin
                   If (Not (TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].isnull))        And
                      (TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value <> cNullValue) Then
                    Begin
                     vTempValue := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
                     MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := vTempValue;
                     {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHI2009UP)}
                       If vEncoding = esASCII Then
                        Begin
                         vTempValue := UTF8Decode(vTempValue);
                         MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := vTempValue;
                        End;
                      {$IFEND}
                    End
                   Else
                    MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].SetValue(Null);
//                    MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value;
                  End
                 Else
                  Begin
                   If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovBytes, ovVarBytes, ovStream, ovBlob,
                                                                                                    ovGraphic, ovOraBlob, ovOraClob] Then
                    Begin
                     MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Binary := True;
                     If TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].isnull Then
                      MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].SetValue(Null)
                     Else
                      MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value  := TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value;
                    End
                   Else If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovDate, ovTime, ovDateTime, ovTimeStamp] then     // ajuste massive
                    Begin
                     If Not TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].isnull Then
                      MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := UnixToDateTime(StrToInt64(TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value));
                    End
                   Else If Not TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].isnull Then
                    MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value
                   Else
                    MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := Null;
                  End;
                 MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].SetModified(Not (vOnLoad));
                 bJsonValueB.Free;
                End;
              End;
            End
           Else If vMassiveMode <> mmExec Then
            Begin
             For C := 1 To bJsonArrayD.ElementCount -1 Do //Valores
              Begin
               bJsonValueB := bJsonArrayD.GetObject(C);
               If (vMassiveFields.Items[C-1] <> Nil) Then
                Begin
                 MassiveLine.Values[C].vJSONValue.ObjectValue := vMassiveFields.Items[C-1].vFieldType;
                 If TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].isnull Then
                  MassiveLine.Values[C].Value := Null
                 Else
                  Begin
                   If vMassiveFields.Items[C-1].vFieldType in [ovString, ovWideString, ovMemo, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
                    Begin
                     If lowercase(TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value) <> cNullvalue then
                      MassiveLine.Values[C].Value := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value{$IFDEF RESTDWLAZARUS}, vDatabaseCharSet{$ENDIF})
                     Else
                      MassiveLine.Values[C].Value := TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value;
                    End
                   Else
                    Begin
                     If vMassiveFields.Items[C-1].vFieldType in [ovBytes, ovVarBytes, ovStream, ovBlob,
                                                                 ovGraphic, ovOraBlob, ovOraClob] Then
                      Begin
                       MassiveLine.Values[C].Binary := True;
                       If TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].isnull Then
                        MassiveLine.Values[C].SetValue(Null)
                       Else
                        MassiveLine.Values[C].Value  := TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value;
                      End
                     Else If vMassiveFields.Items[C-1].vFieldType in [ovDate, ovTime, ovDateTime, ovTimeStamp] then     // ajuste massive
                      Begin
                       If Not TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].isnull Then
                        MassiveLine.Values[C].Value := UnixToDateTime(StrToInt64(TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value));
                      End
                     Else If Not TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].isnull Then
                      MassiveLine.Values[C].Value := TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value
                     Else
                      MassiveLine.Values[C].Value := Null;
                    End;
                  End;
                End;
               MassiveLine.Values[C].SetModified(Not (vOnLoad));
               FreeAndNil(bJsonValueB);
              End;
            End;
          Finally
           FreeAndNil(bJsonValueD);
           FreeAndNil(bJsonValueC);
           vMassiveBuffer.Add(MassiveLine);
          End;
         End;
       End;
      FreeAndNil(bJsonOBJ);
     End;
   Finally
    vOnLoad := False;
    If Assigned(bJsonArrayB) Then
     FreeAndNil(bJsonArrayB);
    If Assigned(bJsonArray)  Then
     FreeAndNil(bJsonArray);
    FreeAndNil(bJsonValue);
   End;
  End;
End;

Function TMassiveDatasetBuffer.ToJSON : String;
Var
 A              : Integer;
 vLines,
 vTagFields,
 vTagLinkFields : String;
 Function GenerateHeader: String;
 Var
  I              : Integer;
  vPrimary,
  vRequired,
  vReadOnly,
  vGenerateLine,
  vAutoinc       : string;
 Begin
  For I := 0 To vMassiveFields.Count - 1 Do
   Begin
    If vDataset <> Nil Then
     Begin
      If (vDataset.FindField(vMassiveFields.Items[I].vFieldName) <> Nil) Then
       Begin
        If Not(Self.vReflectChanges) And
           (vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).ReadOnly) And
           ((Not vMassiveFields.Items[I].vKeyField) And (Not vMassiveFields.Items[I].vAutoGenerateValue)) Then
         Continue;
        {$IFDEF DELPHIXEUP}
        vMassiveFields.Items[I].vReadOnly          := vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).ReadOnly;
        vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).AutoGenerateValue = arAutoInc) Or
                                                       (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        If Not (vMassiveFields.Items[I].vAutoGenerateValue) Then
         vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc) Or
                                                        (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        {$ELSE}
        vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc) Or
                                                        (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        {$ENDIF}
       End;
     End;
    vPrimary  := 'N';
    vAutoinc  := 'N';
    vReadOnly := 'N';
    If vMassiveFields.Items[I].vKeyField Then
     vPrimary := 'S';
    vRequired := 'N';
    If vMassiveFields.Items[I].vRequired Then
     vRequired := 'S';
    If vMassiveFields.Items[I].vReadOnly Then
     vReadOnly := 'S';
    If (vMassiveFields.Items[I].vAutoGenerateValue) Or
       (vMassiveFields.Items[I].FieldType = ovAutoInc) Then
     vAutoinc := 'S';
    If vMassiveFields.Items[I].FieldType In [{$IFDEF DELPHIXEUP}
                                             ovExtended,{$ENDIF}
                                             ovFloat, ovCurrency, ovFMTBcd,
                                             ovSingle, ovBCD] Then
     vGenerateLine := Format(TJsonDatasetHeader, [vMassiveFields.Items[I].vFieldName,
                                                  GetValueType(vMassiveFields.Items[I].FieldType),
                                                  vPrimary, vRequired, vMassiveFields.Items[I].Size,
                                                  vMassiveFields.Items[I].Precision, vReadOnly, vAutoinc])
    Else
     vGenerateLine := Format(TJsonDatasetHeader, [vMassiveFields.Items[I].vFieldName,
                                                  GetValueType(vMassiveFields.Items[I].FieldType),
                                                  vPrimary, vRequired, vMassiveFields.Items[I].Size, 0, vReadOnly, vAutoinc]);
    If I = 0 Then
     Result := vGenerateLine
    Else
     Result := Result + ', ' + vGenerateLine;
   End;
 End;
 Function GenerateLine(MassiveLineBuff : TMassiveLine) : String;
 Var
  A, I          : Integer;
  vTempLine,
  vTempComp,
  vTempKeys,
  vTempValue    : String;
  vMassiveMode  : TMassiveMode;
  vNoChange     : Boolean;
 Begin
  vMassiveMode := mmInactive;
  If MassiveLineBuff.MassiveMode = mmExec Then
   Begin
    vMassiveMode := MassiveLineBuff.MassiveMode;
    vTempLine    := Format('["%s", "%s", "%s"]', [MassiveModeToString(vMassiveMode),
                                                  EncodeStrings(MassiveLineBuff.DataExec.Text{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                                                  EncodeStrings(MassiveLineBuff.Params.ToJSON{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})]);
   End
  Else
   Begin
    For I := 0 To MassiveLineBuff.vMassiveValues.Count - 1 Do
     Begin
      If I = 0 Then
       vMassiveMode  := StringToMassiveMode(MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value)
      Else
       Begin
        If vMassiveMode = mmUpdate Then
         Begin
          If MassiveLineBuff.vChanges.Count = 0 Then
           Continue;
          vNoChange := True;
          For A := 0 To MassiveLineBuff.vChanges.Count -1 Do
           Begin
            If vDataset <> Nil Then
             Begin
              If vMassiveFields.Count <= (I-1) Then
               Continue;
              If (vDataset.FindField(vMassiveFields.Items[I-1].vFieldName) <> Nil) Then
               Begin
                If vDataset.FieldByName(vMassiveFields.Items[I-1].vFieldName).ReadOnly Then
                 Continue;
               End
              Else
               vNoChange := Not vReflectChanges;
             End;
            If Not((vDataset.FindField(vMassiveFields.Items[I-1].vFieldName) = Nil)) Then
             vNoChange := Lowercase(vMassiveFields.Items[I-1].vFieldName) <>
                          Lowercase(MassiveLineBuff.vChanges[A]);
            If Not (vNoChange) Then
             Break;
           End;
          If vNoChange Then
           Continue;
         End;
        If vDataset <> Nil Then
         Begin
          If vMassiveFields.Count <= (I-1) then
           Continue;
         End;
       End;
      If MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.IsNull Then
       vTempValue := Format('%s', [cNullvalue])
      Else
       Begin
        If vTempLine = '' Then
         vTempValue    := Format('"%s"', [MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.AsString])    //asstring
        Else
         Begin
          If vMassiveFields.Items[I-1].vFieldType in [ovString, ovWideString, ovMemo, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
           Begin
            vTempValue    := Format('"%s"', [EncodeStrings(MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})])
           End
          Else If vMassiveFields.Items[I-1].vFieldType in [ovDate, ovTime, ovDateTime, ovTimeStamp] Then
           Begin
             vTempValue    := Format('"%d"', [DateTimeToUnix(StrToDateTime(MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.AsString))])
           End
          Else
           vTempValue    := Format('"%s"', [MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.AsString])
         End;
       End;
      If I = 0 Then
       vTempLine := vTempValue
      Else
       vTempLine := vTempLine + ', ' + vTempValue;
     End;
    vTempLine := '[' + vTempLine + ']';
    If MassiveLineBuff.vChanges.Count > 0 Then
     Begin
      For A := 0 To MassiveLineBuff.vChanges.Count -1 Do
       Begin
        vTempValue := Format('"%s"', [MassiveLineBuff.vChanges[A]]);    //asstring
        If A = 0 Then
         vTempKeys := vTempValue
        Else
         vTempKeys := vTempKeys + ', ' + vTempValue;
       End;
      vTempKeys := '[' + vTempKeys + ']';
     End;
    If MassiveLineBuff.vPrimaryValues <> Nil Then
     Begin
      For I := 0 To MassiveLineBuff.vPrimaryValues.Count - 1 Do
       Begin
        If MassiveLineBuff.vPrimaryValues.Items[I].vJSONValue.IsNull Then
         vTempValue := Format('"%s|%s"', [GetValueType(MassiveLineBuff.vPrimaryValues.Items[I].ObjectValue),
                                          cNullvalue])
        Else
         vTempValue    := Format('"%s|%s"', [GetValueType(MassiveLineBuff.vPrimaryValues.Items[I].ObjectValue),
                                             MassiveLineBuff.vPrimaryValues.Items[I].vJSONValue.AsString]);    //asstring
        If I = 0 Then
         vTempComp := vTempValue
        Else
         vTempComp := vTempComp + ', ' + vTempValue;
       End;
      If MassiveLineBuff.vPrimaryValues.Count > 0 Then
       vTempComp := '[' + vTempComp + ']';
     End;
   End;
  If (vTempComp <> '') And (vTempKeys <> '') Then
   Result := Format('%s,%s,%s', [vTempLine, vTempComp, vTempKeys])
  Else
   Result := vTempLine;
 End;
Begin
 vTagFields  := '{"fields":[' + GenerateHeader + ']}';
 For A := 0 To vMassiveBuffer.Count -1 Do
  Begin
   If A = 0 Then
    vLines := Format('[%s]', [GenerateLine(vMassiveBuffer.Items[A])])
   Else
    vLines := vLines + Format(', [%s]', [GenerateLine(vMassiveBuffer.Items[A])]);
  End;
 vTagFields := vTagFields + Format(', {"lines":[%s]}', [vLines]);
 vTagLinkFields := '';
 If Trim(vMasterCompFields) <> '' Then
  vTagLinkFields := EncodeStrings(vMasterCompFields{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
 Result := Format(TMassiveFormatJSON, ['ObjectType',   GetObjectName(toMassive),
                                       'Direction',    GetDirectionName(odINOUT),
                                       'Encoded',      'true',
                                       'ValueType',    GetValueType(ovObject),
                                       'TableName',    vTableName,
                                       'MassiveValue', vTagFields,
                                       BooleanToString(vReflectChanges),
                                       vSequenceName,
                                       vSequenceField,
                                       vMyCompTag,
                                       vMasterCompTag,
                                       vTagLinkFields]);
End;

Procedure TMassiveDatasetBuffer.SetEncoding(bValue: TEncodeSelect);
Begin
 vEncoding := bValue;
End;

{ TRESTDWMassiveCacheList }

function TRESTDWMassiveCacheList.Add(Item: TRESTDWMassiveCacheValue): Integer;
Var
 vItem : ^TRESTDWMassiveCacheValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

procedure TRESTDWMassiveCacheList.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

procedure TRESTDWMassiveCacheList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TRESTDWMassiveCacheValue(TList(Self).Items[Index]^)) Then
      TRESTDWMassiveCacheValue(TList(Self).Items[Index]^).Free;
     {$IFDEF RESTDWLAZARUS}
      Dispose(PMassiveCacheValue(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
end;

destructor TRESTDWMassiveCacheList.Destroy;
begin
 ClearAll;
 Inherited;
end;

function TRESTDWMassiveCacheList.GetRec(Index: Integer): TRESTDWMassiveCacheValue;
begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TRESTDWMassiveCacheValue(TList(Self).Items[Index]^);
end;

procedure TRESTDWMassiveCacheList.PutRec(Index: Integer; Item: TRESTDWMassiveCacheValue);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TRESTDWMassiveCacheValue(TList(Self).Items[Index]^) := Item;
end;

{ TRESTDWMassiveCache }

Constructor TRESTDWMassiveCache.Create(AOwner: TComponent);
Begin
  inherited;
 MassiveCacheList        := TRESTDWMassiveCacheList.Create;
 vMassiveType            := mtMassiveCache;
 MassiveCacheDatasetList := TRESTDWMassiveCacheDatasetList.Create;
End;

Function TRESTDWMassiveCache.MassiveCount : Integer;
Begin
 Result := MassiveCacheList.Count;
End;

Procedure TRESTDWMassiveCache.ProcessChanges(Value : String);
Var
 X, I             : Integer;
 bJsonValueX,
 bJsonValue       : TRESTDWJSONInterfaceObject;
 bJsonArrayX,
 bJsonArray       : TRESTDWJSONInterfaceArray;
 bJsonValueY,
 bJsonValueB      : TRESTDWJSONInterfaceBase;
 vValue,
 vComponentTag,
 vJSONItems,
 vLastTimeB,
 vBookmark        : String;
 Dataset          : TDataset;
 vActualRecB      : Integer;
 aBookmark        : TBookmark;
 vBookmarkD       : String;
 vOldReadOnly     : Boolean;
 vStringStream    : TMemoryStream;
 Function DecodeREC(BookmarkSTR  : String;
                    Var LastTime : String) : Integer;
 Begin
  Result := -1;
  If Pos('|', BookmarkSTR) > 0 Then
   Begin
    Result := StrToInt(Copy(BookmarkSTR, InitStrPos, (Pos('|', BookmarkSTR) - FinalStrPos) -1));
    DeleteStr(BookmarkSTR, InitStrPos, (Pos('|', BookmarkSTR) - FinalStrPos));
    LastTime := DecodeStrings(BookmarkSTR{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
   End;
 End;
Begin
 vStringStream  := Nil;
 bJsonValue     := TRESTDWJSONInterfaceObject.Create(StringReplace(Value, #$FEFF, '', [rfReplaceAll]));
 bJsonArray     := TRESTDWJSONInterfaceArray(bJsonValue);
 Dataset        := Nil;
 Try
  For I := 0 To bJsonArray.ElementCount -1 Do //For I := 0 To MassiveCacheDatasetList.Count -1 Do
   Begin
    bJsonValueB := bJsonArray.GetObject(I);
    Try
     vBookmark     := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     vComponentTag := TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[2].Value;
     vJSONItems    := TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[1].Value;
     Dataset       := MassiveCacheDatasetList.GetDataset(vComponentTag);
     vActualRecB   := DecodeREC(vBookmark, vLastTimeB);
     If Dataset <> Nil Then
      Begin
       aBookmark := Dataset.GetBookmark;
       If (vActualRecB > -1) Then
        Begin
         If Dataset Is TRESTDWClientSQL Then
          Begin
           TRESTDWClientSQL(Dataset).SetInBlockEvents(True);
           If Not TRESTDWClientSQL(Dataset).BookmarkValid(TBookmark(HexToBookmark(vLastTimeB))) Then
            Continue;
           TRESTDWClientSQL(Dataset).GotoBookmark(TBookmark(HexToBookmark(vLastTimeB)));
           TRESTDWClientSQL(Dataset).Edit;
          End
         Else If Dataset Is TRESTDWTable Then
          Begin
           TRESTDWTable(Dataset).SetInBlockEvents(True);
           If Not TRESTDWTable(Dataset).BookmarkValid(TBookmark(HexToBookmark(vLastTimeB))) Then
            Continue;
           TRESTDWTable(Dataset).GotoBookmark(TBookmark(HexToBookmark(vLastTimeB)));
           TRESTDWTable(Dataset).Edit;
          End;
         Try
          bJsonValueX     := TRESTDWJSONInterfaceObject.Create(vJSONItems);
          bJsonArrayX     := TRESTDWJSONInterfaceArray(bJsonValueX);
          For X := 0 To bJsonArrayX.ElementCount -1 Do //For I := 0 To MassiveCacheDatasetList.Count -1 Do
           Begin
            bJsonValueY := bJsonArrayX.GetObject(X);
            Try
             If Dataset Is TRESTDWClientSQL Then
              Begin
               If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name) <> Nil Then
                Begin
                 vValue := TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Value;
                 vOldReadOnly := TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly;
                 TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly := False;
                 If (TRESTDWClientSQL(Dataset).State in [dsBrowse]) Then
                  TRESTDWClientSQL(Dataset).Edit;
                 If (vValue = cNullvalue) Or
                    (TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly) Then
                  Begin
                   If Not (TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly) Then
                    TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                   Continue;
                  End;
                 If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY)
                   .Pairs[0].Name).DataType in [{$IFDEF DELPHIXEUP}
                                                ftFixedChar, ftFixedWideChar,{$ENDIF}
                                                {$IF Defined(RESTDWLAZARUS) OR Defined(DELPHIXEUP)}
                                                ftWideMemo,
                                                {$IFEND}
                                                ftString, ftWideString, ftMemo]
                                                Then
                  Begin
                   If (vValue <> Null) And (Trim(vValue) <> cNullvalue) and (Trim(vValue) <> '') Then
                    Begin
                     vValue := DecodeStrings(vValue{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
                     {$IF not Defined(LAZARUS) AND not Defined(DELPHI2009UP)}
                     vValue := utf8Decode(vValue);
                     {$IFEND}
                     If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Size > 0 Then
                      TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsString := Copy(vValue, 1, TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Size)
                     Else
                      TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsString := vValue;
                    End
                   Else
                    TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                  End
                 Else
                  Begin
                   If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftInteger, ftSmallInt, ftAutoinc, ftWord, {$IFDEF DELPHIXEUP}ftLongWord,{$ENDIF} ftLargeint] Then
                    Begin
                     If (Trim(vValue) <> '') And (Trim(vValue) <> cNullvalue) Then
                      Begin
                       If vValue <> Null Then
                        Begin
                         vValue := DecodeStrings(vValue{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
                         If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [{$IFDEF DELPHIXEUP}ftLongWord,{$ENDIF}ftLargeint] Then
                          Begin
                            {$IF Defined(RESTDWLAZARUS) OR Defined(DELPHIXEUP)}
                            TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY)
                              .Pairs[0].Name).AsLargeInt := StrToInt64(vValue);
                            {$ELSE}
                            TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY)
                              .Pairs[0].Name).AsInteger := StrToInt64(vValue);
                            {$IFEND}
                          End
                         Else
                          TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsInteger  := StrToInt(vValue);
                        End;
                      End
                     Else
                      TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                    End
                   Else If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFDEF DELPHIXEUP}, ftSingle{$ENDIF}] Then
                    Begin
                     If (vValue <> Null) And
                        (Trim(vValue) <> cNullvalue) and
                        (Trim(vValue) <> '') Then
                      TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsFloat  := StrToFloat(BuildFloatString(vValue))
                     Else
                      TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                    End
                   Else If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                    Begin
                     If (vValue       <> Null)   And
                        (Trim(vValue) <> cNullvalue) And
                        (Trim(vValue) <> '')     And
                        (Trim(vValue) <> '0')    Then
                      TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsDateTime  := UnixToDateTime(StrToInt64(vValue))
                     Else
                      TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                    End  //Tratar Blobs de Parametros...
                   Else If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                                  ftGraphic, ftOraBlob, ftOraClob] Then
                    Begin
                     vStringStream := TMemoryStream.Create;
                     Try
                      If (vValue <> cNullvalue) And
                         (vValue <> '') Then
                       Begin
                        vStringStream := DecodeStream(vValue);
  //                      HexToStream(vValue, vStringStream);
                        vStringStream.Position := 0;
                        TBlobfield(TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name)).LoadFromStream(vStringStream); //, ftBlob);
                       End
                      Else
                       TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                     Finally
                      FreeAndNil(vStringStream);
                     End;
                    End
                   Else If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
                    Begin
                     If TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType = ftBoolean Then
                      TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Value := StringToBoolean(vValue)
                     Else
                      Begin
                       If vValue <> '' Then
                        TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsString := DecodeStrings(vValue{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})
                       Else
                        TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                      End;
                    End
                   Else If (vValue <> Null) And
                           (Trim(vValue) <> cNullvalue) Then
                    TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Value := vValue
                   Else
                    TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                  End;
                 If vOldReadOnly Then
                  TRESTDWClientSQL(Dataset).Post;
                 TRESTDWClientSQL(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly := vOldReadOnly;
                End;
              End
             Else If Dataset Is TRESTDWTable Then
              Begin
               If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name) <> Nil Then
                Begin
                 vValue := TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Value;
                 vOldReadOnly := TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly;
                 TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly := False;
                 If (TRESTDWTable(Dataset).State in [dsBrowse]) Then
                  TRESTDWTable(Dataset).Edit;
                 If (vValue = cNullvalue) Or
                    (TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly) Then
                  Begin
                   If Not (TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly) Then
                    TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                   Continue;
                  End;
                 If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY)
                      .Pairs[0].Name).DataType in [{$IFDEF DELPHIXEUP}
                                                   ftFixedChar, ftFixedWideChar,{$ENDIF}
                                                   {$IF Defined(RESTDWLAZARUS) OR Defined(DELPHIXEUP)}
                                                   ftWideMemo,{$IFEND}
                                                   ftString, ftWideString, ftMemo]
                                                   Then
                  Begin
                   If (vValue <> Null) And (Trim(vValue) <> cNullvalue) and (Trim(vValue) <> '') Then
                    Begin
                     vValue := DecodeStrings(vValue{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
                     {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHI2009UP)}}
                     vValue := utf8Decode(vValue);
                     {$IFEND}
                     If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Size > 0 Then
                      TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsString := Copy(vValue, 1, TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Size)
                     Else
                      TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsString := vValue;
                    End
                   Else
                    TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                  End
                 Else
                  Begin
                   If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftInteger, ftSmallInt, ftAutoinc, ftWord, {$IFDEF DELPHIXEUP}ftLongWord,{$ENDIF} ftLargeint] Then
                    Begin
                     If (Trim(vValue) <> '') And (Trim(vValue) <> cNullvalue) Then
                      Begin
                       If vValue <> Null Then
                        Begin
                         vValue := DecodeStrings(vValue{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
                         If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY)
                              .Pairs[0].Name).DataType in [{$IFDEF DELPHIXEUP}ftLongWord,{$ENDIF}
                                                           ftLargeint] Then
                          Begin
                            {$IF Defined(RESTDWLAZARUS) OR Defined(DELPHIXEUP)}
                            TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY)
                              .Pairs[0].Name).AsLargeInt := StrToInt64(vValue);
                            {$ELSE}
                            TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY)
                              .Pairs[0].Name).AsInteger := StrToInt64(vValue);
                            {$IFEND}
                          End
                         Else
                          TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsInteger  := StrToInt(vValue);
                        End;
                      End
                     Else
                      TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                    End
                   Else If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
                    Begin
                     If (vValue <> Null) And
                        (Trim(vValue) <> cNullvalue) and
                        (Trim(vValue) <> '') Then
                      TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsFloat  := StrToFloat(BuildFloatString(vValue))
                     Else
                      TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                    End
                   Else If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                    Begin
                     If (vValue       <> Null)   And
                        (Trim(vValue) <> cNullvalue) And
                        (Trim(vValue) <> '')     And
                        (Trim(vValue) <> '0')    Then
                      TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsDateTime  := UnixToDateTime(StrToInt64(vValue))
                     Else
                      TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                    End  //Tratar Blobs de Parametros...
                   Else If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                                  ftGraphic, ftOraBlob, ftOraClob] Then
                    Begin
                     vStringStream := TMemoryStream.Create;
                     Try
                      If (vValue <> cNullvalue) And
                         (vValue <> '') Then
                       Begin
                        vStringStream := DecodeStream(vValue);
  //                      HexToStream(vValue, vStringStream);
                        vStringStream.Position := 0;
                        TBlobfield(TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name)).LoadFromStream(vStringStream); //, ftBlob);
                       End
                      Else
                       TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                     Finally
                      FreeAndNil(vStringStream);
                     End;
                    End
                   Else If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
                    Begin
                     If TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).DataType = ftBoolean Then
                      TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Value := StringToBoolean(vValue)
                     Else
                      Begin
                       If vValue <> '' Then
                        TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).AsString := DecodeStrings(vValue{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})
                       Else
                        TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                      End;
                    End
                   Else If (vValue <> Null) And
                           (Trim(vValue) <> cNullvalue) Then
                    TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Value := vValue
                   Else
                    TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).Clear;
                  End;
                 If vOldReadOnly Then
                  TRESTDWTable(Dataset).Post;
                 TRESTDWTable(Dataset).FindField(TRESTDWJSONInterfaceObject(bJsonValueY).Pairs[0].Name).ReadOnly := vOldReadOnly;
                End;
              End;
            Finally
             FreeAndNil(bJsonValueY);
            End;
           End;
         Finally
          If Dataset Is TRESTDWClientSQL Then
           Begin
            If TRESTDWClientSQL(Dataset).State in [dsEdit, dsInsert] Then
             TRESTDWClientSQL(Dataset).Post;
            TRESTDWClientSQL(Dataset).GotoBookmark(TBookmark(vBookmarkD));
            TRESTDWClientSQL(Dataset).SetInBlockEvents(False);
           End
          Else If Dataset Is TRESTDWTable Then
           Begin
            If TRESTDWTable(Dataset).State in [dsEdit, dsInsert] Then
             TRESTDWTable(Dataset).Post;
            TRESTDWTable(Dataset).GotoBookmark(TBookmark(vBookmarkD));
            TRESTDWTable(Dataset).SetInBlockEvents(False);
           End;
          FreeAndNil(bJsonValueX);
         End;
        End;
       Dataset.GotoBookmark(aBookmark);
      End;
    Finally
     FreeAndNil(bJsonValueB);
    End;
   End;
 Finally
  MassiveCacheDatasetList.ClearAll;
  FreeAndNil(bJsonArray);
 End;
End;

Procedure TRESTDWMassiveCache.Add(Value         : TStream;
                                  Const Dataset : TDataset);
Begin
 MassiveCacheList.Add(Value);
 If Dataset is TRESTDWClientSQLBase Then
  MassiveCacheDatasetList.Add(Dataset);
End;

Procedure TRESTDWMassiveCache.Clear;
Begin
 MassiveCacheList.ClearAll;
End;

Procedure TRESTDWMassiveCache.SaveToStream(Var aStream : TStream);
Var
 I            : Integer;
 BufferStream : TRESTDWBufferBase; //Pacote de Entrada
Begin
 If Not Assigned(aStream) Then
  Exit;
 aStream.Position := 0;
 BufferStream := TRESTDWBufferBase.Create;
 Try
  For I := 0 To MassiveCacheList.Count -1 Do
   Begin
    If Assigned(MassiveCacheList.Items[I]) Then
     BufferStream.InputStream(MassiveCacheList.Items[I]);
   End;
 Finally
  BufferStream.SaveToStream(aStream);
  FreeAndNil(BufferStream);
 End;
End;

Destructor TRESTDWMassiveCache.Destroy;
Begin
 FreeAndNil(MassiveCacheList);
 FreeAndNil(MassiveCacheDatasetList);
 Inherited;
End;

Procedure TRESTDWMassiveSQLCache.Store(SQL                  : String;
                                   Dataset              : TDataset);
Var
 I                     : Integer;
 vMassiveCacheSQLValue : TRESTDWMassiveCacheSQLValue;
Begin
 If Not Dataset.IsEmpty Then
  Begin
   vMassiveCacheSQLValue := TRESTDWMassiveCacheSQLValue(vMassiveCacheSQLList.Add);
   vMassiveCacheSQLValue.SQL.Text := SQL;
   For I := 0 To vMassiveCacheSQLValue.Params.Count -1 Do
    Begin
     If Dataset Is TRESTDWClientSQL Then
      Begin
       If TRESTDWClientSQL(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name) <> Nil Then
        vMassiveCacheSQLValue.Params[I].AssignField(TRESTDWClientSQL(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name)); // .AssignValues(TRESTDWClientSQL(Dataset).Params);
      End
     Else If Dataset Is TRESTDWTable Then
      Begin
       If TRESTDWTable(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name) <> Nil Then
        vMassiveCacheSQLValue.Params[I].AssignField(TRESTDWTable(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name));
      End;
    End;
  End;
End;

Procedure TRESTDWMassiveSQLCache.Store(MassiveCacheSQLValue : TRESTDWMassiveCacheSQLValue);
Var
 vMassiveCacheSQLValue : TRESTDWMassiveCacheSQLValue;
Begin
 vMassiveCacheSQLValue := TRESTDWMassiveCacheSQLValue(vMassiveCacheSQLList.Add);
 vMassiveCacheSQLValue.SQL.Text := MassiveCacheSQLValue.SQL.Text;
 vMassiveCacheSQLValue.Params.AssignValues(MassiveCacheSQLValue.Params);
End;

Destructor TRESTDWMassiveCacheSQLValue.Destroy;
Begin
 FreeAndNil(vSQL);
 FreeAndNil(vFetchRowSQL);
 FreeAndNil(vLockSQL);
 FreeAndNil(vUnlockSQL);
 FreeAndNil(vParams);
 FreeAndNil(FMemDS);
 Inherited;
End;

Function ScanParams(SQL : string) : TStringList;
Var
 FCurrentPos : PChar;
 vParamName  : String;
 bEscape1,
 bEscape2,
 bParam     : boolean;
 vOldChar   : Char;
 Const
  endParam : set of Char = [';', '=','>','<',' ',',','(',')','-','+','/','*','!',
                            '''','"','|',#0..#31,#127..#255];
 procedure AddParamSQL;
 Begin
  vParamName := Trim(vParamName);
  If vParamName <> '' Then
   Begin
    If Result.IndexOf(vParamName) < 0 Then
     Result.Add(vParamName);
   End;
  bParam := False;
  vParamName := '';
 End;
Begin
 Result := TStringList.Create;
 FCurrentPos := PChar(SQL);
 bEscape1 := False;
 bEscape2 := False;
 bParam := False;
 While Not (FCurrentPos^ = #0) Do
  Begin
   If (FCurrentPos^ = '''')   And
      (Not bEscape2)          And
      (Not (bEscape1          And
           (vOldChar = '\'))) Then
    Begin
     AddParamSQL;
     bEscape1 := not bEscape1;
    End
   Else If (FCurrentPos^ = '"')    And
           (Not bEscape1)          And
           (Not (bEscape2          And
                (vOldChar = '\'))) Then
    Begin
     AddParamSQL;
     bEscape2 := not bEscape2;
    End
   Else If (FCurrentPos^ = ':')    And
           (Not bEscape1)          And
           (Not bEscape2)          Then
    Begin
     AddParamSQL;
     bParam := vOldChar in endParam;
    End
   Else If (bParam) Then
    Begin
     If (Not (FCurrentPos^ In endParam)) Then
      vParamName := vParamName + FCurrentPos^
     Else
      AddParamSQL;
    End;
   vOldChar := FCurrentPos^;
   Inc(FCurrentPos);
  End;
 AddParamSQL;
End;

Function ReturnParams(SQL : String) : TStringList;
Begin
 Result := ScanParams(SQL);
End;

Function ReturnParamsAtual(ParamsList : TParams) : TStringList;
Var
 I : Integer;
Begin
 Result := Nil;
 If ParamsList.Count > 0 Then
  Begin
   Result := TStringList.Create;
   For I := 0 To ParamsList.Count -1 Do
    Result.Add(ParamsList[I].Name);
  End;
End;

Procedure TRESTDWMassiveCacheSQLValue.CreateParams;
Var
 I         : Integer;
 ParamsListAtual,
 ParamList : TStringList;
 Procedure CreateParam(Value : String);
  Function ParamSeek (Name : String) : Boolean;
  Var
   I : Integer;
  Begin
   Result := False;
   For I := 0 To vParams.Count -1 Do
    Begin
     Result := LowerCase(vParams.items[i].Name) = LowerCase(Name);
     If Result Then
      Break;
    End;
  End;
 Begin
  If Not(ParamSeek(Value)) Then
   vParams.CreateParam(ftString, Value, ptInput);
 End;
 Function CompareParams(A, B : TStringList) : Boolean;
 Var
  I, X : Integer;
 Begin
  Result := (A <> Nil) And (B <> Nil);
  If Result Then
   Begin
    For I := 0 To A.Count -1 Do
     Begin
      For X := 0 To B.Count -1 Do
       Begin
        Result := lowercase(A[I]) = lowercase(B[X]);
        If Result Then
         Break;
       End;
      If Not Result Then
       Break;
     End;
   End;
  If Result Then
   Result := B.Count > 0;
 End;
Begin
 ParamList       := ReturnParams(vSQL.Text);
 ParamsListAtual := ReturnParamsAtual(vParams);
 vParamCount     := 0;
 If Not CompareParams(ParamsListAtual, ParamList) Then
  vParams.Clear;
 If ParamList <> Nil Then
 For I := 0 to ParamList.Count -1 Do
  CreateParam(ParamList[I]);
 If ParamList.Count > 0 Then
  vParamCount := vParams.Count;
 ParamList.Free;
 If Assigned(ParamsListAtual) then
  FreeAndNil(ParamsListAtual);
End;

Procedure TRESTDWMassiveCacheSQLValue.SetSQL(Value: TStringList);
Var
 I : Integer;
Begin
 vSQL.Clear;
 For I := 0 To Value.Count -1 do
  vSQL.Add(Value[I]);
End;

Procedure TRESTDWMassiveCacheSQLValue.OnChangingSQL(Sender: TObject);
Begin
 CreateParams;
End;

Function    TRESTDWMassiveCacheSQLValue.ParamByName  (Value : String) : TParam;
Var
 I : Integer;
 vParamName,
 vTempParam : String;
 Function CompareValue(Value1, Value2 : String) : Boolean;
 Begin
   Result := Value1 = Value2;
 End;
Begin
 Result := Nil;
 For I := 0 to vParams.Count -1 do
  Begin
   vParamName := UpperCase(vParams[I].Name);
   vTempParam := UpperCase(Trim(Value));
   if CompareValue(vTempParam, vParamName) then
    Begin
     Result := vParams[I];
     Break;
    End;
  End;
End;

Constructor TRESTDWMassiveCacheSQLValue.Create (aCollection : TCollection);
Begin
 Inherited;
 vSQL            := TStringList.Create;
 vFetchRowSQL    := TStringList.Create;
 vLockSQL        := TStringList.Create;
 vUnlockSQL      := TStringList.Create;
 vParams         := TParams.Create(Self);
 FMemDS          := TMemoryStream.Create;
 vParamCount     := 0;
 vBinaryRequest  := False;
 vMassiveSQLMode := msqlExecute;
 {$IFDEF RESTDWLAZARUS}
  vSQL.OnChange := @OnChangingSQL;
 {$ELSE}
  vSQL.OnChange := OnChangingSQL;
 {$ENDIF}
End;

Procedure TRESTDWMassiveSQLCache.SetEncoding(Value : TEncodeSelect);
Begin
 vEncoding := Value;
 vMassiveCacheSQLList.vEncoding := vEncoding;
End;

procedure TRESTDWMassiveSQLCache.Clear;
begin
 vMassiveCacheSQLList.Clear;
end;

constructor TRESTDWMassiveSQLCache.Create(AOwner: TComponent);
begin
  inherited;
  {$IF Defined(RESTDWLAZARUS) OR Defined(DELPHIXEUP)}
  vEncoding := esUtf8;
  {$ELSE}
  vEncoding := esAscii;
  {$IFEND}
  vMassiveCacheSQLList           := TRESTDWMassiveCacheSQLList.Create(Self, TRESTDWMassiveCacheSQLValue);
  vMassiveCacheSQLList.vEncoding := vEncoding;
end;

destructor TRESTDWMassiveSQLCache.Destroy;
begin
  FreeAndNil(vMassiveCacheSQLList);
  inherited;
end;

function TRESTDWMassiveSQLCache.MassiveCount: Integer;
begin
  Result := vMassiveCacheSQLList.Count;
end;

Function TRESTDWMassiveSQLCache.ParamsToBin(Params : TParams) : String;
Var
 I             : Integer;
 vTempLine,
 vLineParams   : String;
 vStringStream : TStringStream;
Begin
 Result      := '[%s]';
 vLineParams := '';
 For I := 0 To Params.Count -1 Do
  Begin
   vStringStream := TStringStream.Create('');
   Try
    TRESTDWPropertyPersist(Params[I]).SaveToStream(vStringStream);
    vTempLine := EncodeStrings(vStringStream.DataString{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
   Finally
    vStringStream.Free;
   End;
   If I = 0 Then
    vLineParams := Format('"%s"', [vTempLine])
   Else
    vLineParams := vLineParams + Format(', "%s"', [vTempLine]);
  End;
 Result := Format(Result, [vLineParams]);
End;

Function TRESTDWMassiveSQLCache.ToJSON      : String;
Var
 vStringStream : TStringStream;
 vJSONValue,
 vTempJSON,
 vParamsString : String;
 A, I          : Integer;
 vDWParams     : TRESTDWParams;
Begin
 vJSONValue := '';
 Result     := '';
 vDWParams  := Nil;
 For A := 0 To vMassiveCacheSQLList.Count -1 Do
  Begin
   vParamsString := '';
   If Not vMassiveCacheSQLList[A].BinaryRequest Then
    Begin
     vDWParams     := GeTRESTDWParams(vMassiveCacheSQLList[A].vParams, vEncoding);
     If Assigned(vDWParams) Then
      vParamsString := EncodeStrings(vDWParams.ToJSON{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    End
   Else
    vParamsString := EncodeStream(vMassiveCacheSQLList[A].MemDS);
   vTempJSON  := Format(cJSONValue, [MassiveSQLMode(vMassiveCacheSQLList[A].vMassiveSQLMode),
                                     EncodeStrings(vMassiveCacheSQLList[A].vSQL.Text{$IFDEF RESTDWLAZARUS},         csUndefined{$ENDIF}),
                                     vParamsString,
                                     EncodeStrings(vMassiveCacheSQLList[A].vBookmark{$IFDEF RESTDWLAZARUS},         csUndefined{$ENDIF}),
                                     BooleanToString(vMassiveCacheSQLList[A].vBinaryRequest),
                                     EncodeStrings(vMassiveCacheSQLList[A].vFetchRowSQL.Text{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                                     EncodeStrings(vMassiveCacheSQLList[A].vLockSQL.Text{$IFDEF RESTDWLAZARUS},     csUndefined{$ENDIF}),
                                     EncodeStrings(vMassiveCacheSQLList[A].vUnlockSQL.Text{$IFDEF RESTDWLAZARUS},   csUndefined{$ENDIF})]);
   If vJSONValue = '' Then
    vJSONValue := vTempJSON
   Else
    vJSONValue := vJSONValue + ', ' + vTempJSON;
   If Assigned(vDWParams) Then
    FreeAndNil(vDWParams);
  End;
 If vJSONValue <> '' Then
  Result       := Format('[%s]', [vJSONValue]);
End;

Function TRESTDWMassiveCacheSQLList.Add : TCollectionItem;
Begin
 Result := TRESTDWMassiveCacheSQLValue(Inherited Add);
End;

procedure TRESTDWMassiveCacheSQLList.ClearAll;
Var
 I      : Integer;
Begin
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
 End;
End;

Function TRESTDWMassiveCacheSQLList.ToJSON      : String;
Var
 vStringStream : TStringStream;
 vJSONValue,
 vTempJSON,
 vParamsString : String;
 A, I          : Integer;
 vDWParams     : TRESTDWParams;
Begin
 vJSONValue := '';
 Result     := '';
 vDWParams  := Nil;
 For A := 0 To Count -1 Do
  Begin
   vParamsString := '';
   If Not Items[A].BinaryRequest Then
    Begin
     vDWParams     := GeTRESTDWParams(Items[A].vParams, vEncoding);
     If Assigned(vDWParams) Then
      vParamsString := EncodeStrings(vDWParams.ToJSON{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    End
   Else
    vParamsString := EncodeStream(Items[A].MemDS);
   vTempJSON  := Format(cJSONValue, [MassiveSQLMode(Items[A].vMassiveSQLMode),
                                     EncodeStrings(Items[A].vSQL.Text{$IFDEF RESTDWLAZARUS},         csUndefined{$ENDIF}),
                                     vParamsString,
                                     EncodeStrings(Items[A].vBookmark{$IFDEF RESTDWLAZARUS},         csUndefined{$ENDIF}),
                                     BooleanToString(Items[A].vBinaryRequest),
                                     EncodeStrings(Items[A].vFetchRowSQL.Text{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                                     EncodeStrings(Items[A].vLockSQL.Text{$IFDEF RESTDWLAZARUS},     csUndefined{$ENDIF}),
                                     EncodeStrings(Items[A].vUnlockSQL.Text{$IFDEF RESTDWLAZARUS},   csUndefined{$ENDIF})]);
   If vJSONValue = '' Then
    vJSONValue := vTempJSON
   Else
    vJSONValue := vJSONValue + ', ' + vTempJSON;
  End;
 If vJSONValue <> '' Then
  Result       := Format('[%s]', [vJSONValue]);
End;

procedure TRESTDWMassiveCacheSQLList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

Constructor TRESTDWMassiveCacheSQLList.Create(AOwner      : TPersistent;
                                          aItemClass  : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWMassiveCacheSQLValue);
 fOwner  := AOwner;
End;

Destructor TRESTDWMassiveCacheSQLList.Destroy;
begin
 ClearAll;
 inherited;
end;

Function TRESTDWMassiveCacheSQLList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TRESTDWMassiveCacheSQLList.GetRec(Index: Integer): TRESTDWMassiveCacheSQLValue;
begin
 Result := TRESTDWMassiveCacheSQLValue(Inherited GetItem(Index));
end;

Procedure TRESTDWMassiveCacheSQLList.PutRec(Index: Integer;
  Item: TRESTDWMassiveCacheSQLValue);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
End;

Constructor TMassiveReplyValue.Create;
Begin
 vOldNewValue := Null;
 vOldValue    := Null;
 vValueName   := '';
End;

Destructor TMassiveReplyValue.Destroy;
Begin
 vOldNewValue := Null;
 vOldValue    := Null;
 vValueName   := '';
 Inherited;
End;

Function TMassiveReplyCache.Add(Item : TMassiveReplyValue) : Integer;
Var
 vItem : ^TMassiveReplyValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveReplyCache.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

Constructor TMassiveReplyCache.Create;
Begin
 Inherited Create;
 vBuffername := '';
End;

Procedure TMassiveReplyCache.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveReplyValue(TList(Self).Items[Index]^)) Then
      Begin
        {$IFDEF DELPHI10_4UP}
        FreeAndNil(TMassiveReplyValue(TList(Self).Items[Index]^));
        {$ELSE}
        FreeAndNil(TList(Self).Items[Index]^);
        {$ENDIF}
      End;
     {$IFDEF RESTDWLAZARUS}
      Dispose(PMassiveReplyValue(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveReplyCache.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveReplyCache.GetRec(Index : Integer) : TMassiveReplyValue;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveReplyValue(TList(Self).Items[Index]^);
end;

Function TMassiveReplyCache.ItemByValue(ValueName : String; OldValue : Variant) : TMassiveReplyValue;
Var
 I : Integer;
Begin
 Result := Nil;
 If Assigned(Self) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(ValueName) = Uppercase(Values[I].ValueName)) And
        (Values[I].OldValue   = OldValue)                       Then
      Begin
       Result := Values[I];
       Break;
      End;
    End;
  End;
End;

Procedure TMassiveReplyCache.PutRec(Index: Integer; Item: TMassiveReplyValue);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveReplyValue(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveReply }

Procedure TMassiveReply.PutRecName(Index : String;
                                   Item  : TMassiveReplyCache);
Var
 I : Integer;
Begin
 If Assigned(Self) Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TMassiveReplyCache(TList(Self).Items[i]^).Buffername)) Then
      Begin
       TMassiveReplyCache(TList(Self).Items[i]^) := Item;
       Break;
      End;
    End;
  End;
End;

Procedure TMassiveReply.UpdateBufferValue(Buffername, ValueName : String; OldValue, NewValue : Variant);
Var
 MassiveReplyCache : TMassiveReplyCache;
 MassiveReplyValue : TMassiveReplyValue;
Begin
 MassiveReplyCache := ItemsString[Buffername];
 If MassiveReplyCache <> Nil Then
  Begin
   MassiveReplyValue := MassiveReplyCache.ItemByValue(ValueName, OldValue);
   If MassiveReplyValue <> Nil Then
    MassiveReplyValue.NewValue  := NewValue;
  End;
End;

Function TMassiveReply.GetRecName(Index : String) : TMassiveReplyCache;
Var
 I : Integer;
Begin
 Result := Nil;
 If Assigned(Self) Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TMassiveReplyCache(TList(Self).Items[i]^).Buffername)) Then
      Begin
       Result := TMassiveReplyCache(TList(Self).Items[i]^);
       Break;
      End;
    End;
  End;
End;

Function TMassiveReply.Add(Item: TMassiveReplyCache): Integer;
Var
 vItem : ^TMassiveReplyCache;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveReply.AddBufferValue(Buffername, ValueName : String; OldValue, NewValue : Variant);
Var
 MassiveReplyCache : TMassiveReplyCache;
 MassiveReplyValue : TMassiveReplyValue;
Begin
 MassiveReplyCache := ItemsString[Buffername];
 If MassiveReplyCache = Nil Then
  Begin
   MassiveReplyCache            := TMassiveReplyCache.Create;
   MassiveReplyValue            := TMassiveReplyValue.Create;
   MassiveReplyCache.Buffername := Buffername;
   MassiveReplyValue.ValueName  := ValueName;
   MassiveReplyValue.OldValue   := OldValue;
   If VarIsNull(NewValue) Then
    MassiveReplyValue.NewValue  := OldValue
   Else
    MassiveReplyValue.NewValue  := NewValue;
   MassiveReplyCache.Add(MassiveReplyValue);
   Add(MassiveReplyCache);
  End
 Else
  Begin
   MassiveReplyValue := MassiveReplyCache.ItemByValue(ValueName, OldValue);
   If MassiveReplyValue = Nil Then
    Begin
     MassiveReplyValue := TMassiveReplyValue.Create;
     MassiveReplyValue.ValueName := ValueName;
     MassiveReplyValue.OldValue  := OldValue;
     MassiveReplyValue.NewValue  := NewValue;
     MassiveReplyCache.Add(MassiveReplyValue);
    End;
  End;
End;

procedure TMassiveReply.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

Procedure TMassiveReply.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveReplyCache(TList(Self).Items[Index]^)) Then
      Begin
        {$IFDEF DELPHI10_4UP}
        FreeAndNil(TMassiveReplyCache(TList(Self).Items[Index]^));
        {$ELSE}
        FreeAndNil(TList(Self).Items[Index]^);
        {$ENDIF}
      End;
     {$IFDEF RESTDWLAZARUS}
      Dispose(PMassiveReplyCache(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveReply.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveReply.GetRec(Index : Integer) : TMassiveReplyCache;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveReplyCache(TList(Self).Items[Index]^);
End;

Function TMassiveReply.GetReplyValue(Buffername,
                                     ValueName  : String;
                                     MyValue    : Variant) : TMassiveReplyValue;
Var
 I, X : Integer;
Begin
 Result := Nil;
 For I := 0 To Count -1 Do
  Begin
   If Lowercase(Items[I].Buffername) = Lowercase(Buffername) Then
    Begin
     For X := 0 To Items[I].Count -1 Do
      Begin
       If (Lowercase(Items[I].Values[X].ValueName) =
           Lowercase(ValueName)) And
          (Items[I].Values[X].OldValue = MyValue) Then
        Begin
         Result := Items[I].Values[X];
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TMassiveReply.PutRec      (Index       : Integer;
                                     Item        : TMassiveReplyCache);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveReplyCache(TList(Self).Items[Index]^) := Item;
End;

{ TRESTDWMassiveCacheDatasetList }

Function TRESTDWMassiveCacheDatasetList.Add(Item : TMassiveCacheDataset) : Integer;
Var
 vItem : ^TMassiveCacheDataset;
 vItemsIndex : Integer;
Begin
 vItemsIndex := DatasetExists(Item);
 If vItemsIndex = -1 Then
  Begin
   New(vItem);
   vItem^ := Item;
   Result := TList(Self).Add(vItem);
  End
 Else
  Result := vItemsIndex;
End;

procedure TRESTDWMassiveCacheDatasetList.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

Function TRESTDWMassiveCacheDatasetList.DatasetExists(Value : TMassiveCacheDataset) : Integer;
Var
 I : Integer;
Begin
 Result := -1;
 For I := 0 To Count -1 Do
  Begin
   If Items[I] = Value Then
    Begin
     Result := I;
     Break;
    End;
  End;
End;

Procedure TRESTDWMassiveCacheDatasetList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     {$IFDEF RESTDWLAZARUS}
      Dispose(PMassiveCacheDataset(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
end;

Destructor TRESTDWMassiveCacheDatasetList.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TRESTDWMassiveCacheDatasetList.GetDataset(Dataset : String) : TMassiveCacheDataset;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Count -1 Do
  Begin
   If TMassiveCacheDataset(TList(Self).Items[I]^) Is TRESTDWClientSQLBase Then
    Begin
     If Lowercase(TRESTDWClientSQLBase(TMassiveCacheDataset(TList(Self).Items[I]^)).Componenttag) =
        Lowercase(Dataset) Then
      Begin
       Result := TMassiveCacheDataset(TList(Self).Items[I]^);
       Break;
      End;
    End;
  End;
End;

Function TRESTDWMassiveCacheDatasetList.GetRec(Index : Integer): TMassiveCacheDataset;
begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveCacheDataset(TList(Self).Items[Index]^);
end;

procedure TRESTDWMassiveCacheDatasetList.PutRec(Index : Integer;
                                            Item  : TMassiveCacheDataset);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveCacheDataset(TList(Self).Items[Index]^) := Item;
end;

Procedure TRESTDWMassiveCacheSQLValue.SetMemDS(const Value: TMemoryStream);
Begin
 FMemDS := Value;
End;

Procedure TRESTDWMassiveSQLCache.Store(MemDS: TMemoryStream);
Var
 vMassiveCacheSQLValue : TRESTDWMassiveCacheSQLValue;
Begin
 vMassiveCacheSQLValue                := TRESTDWMassiveCacheSQLValue(vMassiveCacheSQLList.Add);
 vMassiveCacheSQLValue.BinaryRequest  := True;
 vMassiveCacheSQLValue.MemDS.LoadFromStream(MemDS);
End;

{ Global Functions }

Function  MassiveSQLMode(aValue : TMassiveSQLMode) : String;
Begin
 Result := 'msUnknow';
 Case aValue Of
  msqlQuery   : Result := 'msqlQuery';
  msqlExecute : Result := 'msqlExecute';
 End;
End;

Function  MassiveSQLMode(aValue : String) : TMassiveSQLMode;
Var
 aData : String;
Begin
 aData := lowercase(aValue);
 If aData = lowercase('msqlQuery') Then
  Result := msqlQuery
 Else If aData = lowercase('msqlExecute') Then
  Result := msqlExecute;
End;

End.
