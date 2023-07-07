unit uRESTDWParams;

{$I ..\..\Source\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

Uses
  {$IFDEF RESTDWLAZARUS} LConvEncoding, {$ENDIF}
  SysUtils, Classes, Db, Variants,
  uRESTDWConsts, uRESTDWBasicTypes, uRESTDWProtoTypes, uRESTDWTools,
  uRESTDWResponseTranslator;

Type
  TRESTDWHeaders = Class(TObject)
    Input, Output: TStringList;
    Constructor Create;
    Destructor Destroy; Override;
  End;

Type
  TDWParamExpType = (tdwpxt_All, tdwpxt_IN, tdwpxt_OUT, tdwpxt_INOUT);
  TProcedureEvent = Procedure Of Object;
  TNewDataField = Procedure(FieldDefinition: TFieldDefinition) Of Object;
  TFieldExist = Function(Const Dataset: TDataset; Value: String)
    : TField Of Object;
  TSetInitDataset = Procedure(Const Value: Boolean) Of Object;
  TSetRecordCount = Procedure(aJsonCount, aRecordCount: Integer) Of Object;
  TSetnotrepage = Procedure(Value: Boolean) Of Object;
  TFieldListCount = Function: Integer Of Object;
  TGetInDesignEvents = Function: Boolean Of Object;
  TPrepareDetails = Procedure(ActiveMode: Boolean) Of Object;

Type
  TJSONValue = Class
  Private
    vFieldExist: TFieldExist;
    vCreateDataset, vNewFieldList: TProcedureEvent;
    vNewDataField: TNewDataField;
    vSetInitDataset: TSetInitDataset;
    vDataType: Boolean; // Tiago Istuque - Por Nemi Vieira - 29/01/2019
    vFieldDefinition: TFieldDefinition;
    vSetRecordCount: TSetRecordCount;
    vSetnotrepage: TSetnotrepage;
    vFieldListCount: TFieldListCount;
    vGetInDesignEvents: TGetInDesignEvents;
    vSetInactive, vSetInBlockEvents, vSetInDesignEvents: TSetInitDataset;
    vPrepareDetailsNew: TProcedureEvent;
    vPrepareDetails: TPrepareDetails;
    vDataMode: TDataMode;
    vInBlockEvents, vInactive, vNullValue, vBinary, vUtf8SpecialChars,
      vEncoded: Boolean;
    vFloatDecimalFormat, vtagName: String;
    vTypeObject: TTypeObject;
    vObjectDirection: TObjectDirection;
    vObjectValue: TObjectValue;
    aValue: TRESTDWBytes;
    vEncoding: TEncodeSelect;
    vFieldsList: TFieldsList;
    {$IFDEF RESTDWLAZARUS}
    vEncodingLazarus: TEncoding;
    vDatabaseCharSet: TDatabaseCharSet;
    {$ENDIF}
    vOnWriterProcess: TOnWriterProcess;
    Function GetValue(CanConvert: Boolean = True): Variant;
    Procedure WriteValue(bValue: TStream); Overload;
    Procedure WriteValue(bValue: Variant); Overload;
    Function FormatValue(bValue: String): String;
    Function GetValueJSON(bValue: String): String;
    Function DatasetValues(bValue: TDataset; DateTimeFormat: String = '';
      DataModeD: TDataMode = dmDataware; FloatDecimalFormat: String = '';
      HeaderLowercase: Boolean = False; VirtualValue: String = '';
      DWJSONType: TRESTDWJSONType = TRESTDWJSONArrayType;
      bDetail: TDataset = Nil): String;
    Function EncodedString: String;
    Procedure SetEncoding(bValue: TEncodeSelect);
    // Desacoplamento Iniciado
    Function GetNewFieldList: TProcedureEvent;
    Procedure aNewFieldList;
    Function GetNewDataField: TNewDataField;
    Procedure aNewDataField(FieldDefinition: TFieldDefinition);
    Function GetFieldExist: TFieldExist;
    Function aFieldExist(Const Dataset: TDataset; Value: String): TField;
    Function GetCreateDataSet: TProcedureEvent;
    Procedure aCreateDataSet;
    Procedure aSetInitDataset(Const Value: Boolean);
    Function GetSetInitDataset: TSetInitDataset;
    Procedure aSetRecordCount(aJsonCount, aRecordCount: Integer);
    Function GetSetRecordCount: TSetRecordCount;
    Procedure aSetnotrepage(Value: Boolean);
    Function GetSetnotrepage: TSetnotrepage;
    Procedure aSetInDesignEvents(Const Value: Boolean);
    Function GetSetInDesignEvents: TSetInitDataset;
    Procedure aSetInBlockEvents(Const Value: Boolean);
    Function GetSetInBlockEvents: TSetInitDataset;
    Procedure aSetInactive(Const Value: Boolean);
    Function GetSetInactive: TSetInitDataset;
    Function aFieldListCount: Integer;
    Function GetFieldListCount: TFieldListCount;
    Class Function FieldDefExist(Const Dataset: TDataset; Value: String)
      : TFieldDef;
    Function aGetInDesignEvents: Boolean;
    Function GetGetInDesignEvents: TGetInDesignEvents;
    Procedure aPrepareDetailsNew;
    Function GetPrepareDetailsNew: TProcedureEvent;
    Procedure aPrepareDetails(ActiveMode: Boolean);
    Function GetPrepareDetails: TPrepareDetails;
    Procedure ExecSetInactive(Value: Boolean);
    // Desacoplamento Finalizado
    Procedure SetFieldsList(Value: TFieldsList);
    Procedure ClearFieldList;
    Function GetBytes: TRESTDWBytes;
    Procedure WriteBytes(bValue: TRESTDWBytes);
  Public
    Procedure BeginBytes(DataSize: DWInt64);
    Function AsString: String;
    Procedure Clear;
    Procedure ToStream(Var bValue: TMemoryStream);
    Procedure LoadFromDataset(TableName: String; bValue: TDataset;
      EncodedValue: Boolean = True; DataModeD: TDataMode = dmDataware;
      DateTimeFormat: String = ''; DelimiterFormat: String = '';
      {$IFDEF RESTDWLAZARUS}
      CharSet: TDatabaseCharSet = csUndefined;
      {$ENDIF}
      DataType: Boolean = False; HeaderLowercase: Boolean = False); Overload;
    Procedure LoadFromDataset(TableName: String; bValue, bDetail: TDataset;
      DetailType: TRESTDWJSONType = TRESTDWJSONArrayType;
      DetailElementName: String = 'detail'; EncodedValue: Boolean = True;
      DataModeD: TDataMode = dmDataware; DateTimeFormat: String = '';
      DelimiterFormat: String = '';
      {$IFDEF RESTDWLAZARUS}
      CharSet: TDatabaseCharSet = csUndefined;
      {$ENDIF}
      DataType: Boolean = False; HeaderLowercase: Boolean = False); Overload;
    Procedure WriteToFieldDefs(JSONValue: String;
      Const ResponseTranslator: TRESTDWResponseTranslator);
    procedure WriteToDataset2(JSONValue: String; DestDS: TDataset);
    Procedure WriteToDataset(JSONValue: String;
      Const DestDS: TDataset); Overload;
    Procedure WriteToDataset(JSONValue: String; Const DestDS: TDataset;
      ResponseTranslator: TRESTDWResponseTranslator;
      RequestMode: TRequestMode); Overload;
    Procedure WriteToDataset(DatasetType: TDatasetType; JSONValue: String;
      Const DestDS: TDataset; Var JsonCount: Integer; Datapacks: Integer = -1;
      ActualRec: Integer = 0;
      ClearDataset: Boolean = False{$IFDEF RESTDWLAZARUS};
      CharSet: TDatabaseCharSet = csUndefined{$ENDIF}); Overload;
    Procedure WriteToDataset(DatasetType: TDatasetType; JSONValue: String;
      Const DestDS: TDataset;
      ClearDataset: Boolean = False{$IFDEF RESTDWLAZARUS};
      CharSet: TDatabaseCharSet = csUndefined{$ENDIF}); Overload;
    Procedure LoadFromJSON(bValue: String); Overload;
    Procedure LoadFromJSON(bValue: String; DataModeD: TDataMode); Overload;
    Procedure LoadFromStream(Stream: TStream);
    Procedure SaveToStream(Const Stream: TStream);
    Procedure SaveToFile(FileName: String);
    Procedure ToBytes(Value: String; Encode: Boolean = False);
    Function ToJSON: String;
    Procedure SetValue(Value: Variant; Encode: Boolean = True);
    Function Value: Variant;
    Constructor Create;
    Destructor Destroy; Override;
    Function IsNull: Boolean;
    Property ServerFieldList: TFieldsList Read vFieldsList Write SetFieldsList;
    Property NewFieldList: TProcedureEvent Read GetNewFieldList
      Write vNewFieldList;
    Property FieldExist: TFieldExist Read GetFieldExist Write vFieldExist;
    Property CreateDataset: TProcedureEvent Read GetCreateDataSet
      Write vCreateDataset;
    Property NewDataField: TNewDataField Read GetNewDataField
      Write vNewDataField;
    Property SetInitDataset: TSetInitDataset Read GetSetInitDataset
      Write vSetInitDataset;
    Property SetRecordCount: TSetRecordCount Read GetSetRecordCount
      Write vSetRecordCount;
    Property Setnotrepage: TSetnotrepage Read GetSetnotrepage
      Write vSetnotrepage;
    Property SetInDesignEvents: TSetInitDataset Read GetSetInDesignEvents
      Write vSetInDesignEvents;
    Property SetInBlockEvents: TSetInitDataset Read GetSetInBlockEvents
      Write vSetInBlockEvents;
    Property SetInactive: TSetInitDataset Read GetSetInactive
      Write vSetInactive;
    Property FieldListCount: TFieldListCount Read GetFieldListCount
      Write vFieldListCount;
    Property GetInDesignEvents: TGetInDesignEvents Read GetGetInDesignEvents
      Write vGetInDesignEvents;
    Property PrepareDetailsNew: TProcedureEvent Read GetPrepareDetailsNew
      Write vPrepareDetailsNew;
    Property PrepareDetails: TPrepareDetails Read GetPrepareDetails
      Write vPrepareDetails;
    Property TypeObject: TTypeObject Read vTypeObject Write vTypeObject;
    Property ObjectDirection: TObjectDirection Read vObjectDirection
      Write vObjectDirection;
    Property ObjectValue: TObjectValue Read vObjectValue Write vObjectValue;
    Property Binary: Boolean Read vBinary Write vBinary;
    Property Utf8SpecialChars: Boolean Read vUtf8SpecialChars
      Write vUtf8SpecialChars;
    Property Encoding: TEncodeSelect Read vEncoding Write SetEncoding;
    Property Tagname: String Read vtagName Write vtagName;
    Property Encoded: Boolean Read vEncoded Write vEncoded;
    Property DataMode: TDataMode Read vDataMode Write vDataMode;
    Property FloatDecimalFormat: String Read vFloatDecimalFormat
      Write vFloatDecimalFormat;
    Property AsBytes: TRESTDWBytes Read GetBytes Write WriteBytes;
    {$IFDEF RESTDWLAZARUS}
    Property DatabaseCharSet: TDatabaseCharSet Read vDatabaseCharSet
      Write vDatabaseCharSet;
    {$ENDIF}
    Property OnWriterProcess: TOnWriterProcess Read vOnWriterProcess
      Write vOnWriterProcess;
    Property Inactive: Boolean Read vInactive Write ExecSetInactive;
  End;

Type
  TRESTDWParamMethod = Class;
  PDWParamMethod = ^TRESTDWParamMethod;

  TRESTDWParamMethod = Class(TCollectionItem)
  Private
    vTypeObject: TTypeObject;
    vObjectDirection: TObjectDirection;
    vObjectValue: TObjectValue;
    vAlias, vDefaultValue, vParamName: String;
    vEncoded: Boolean;
  Public
    Function GetDisplayName: String; Override;
    Procedure SetDisplayName(Const Value: String); Override;
    Constructor Create(aCollection: TCollection); Override;
  Published
    Property TypeObject: TTypeObject Read vTypeObject Write vTypeObject;
    Property ObjectDirection: TObjectDirection Read vObjectDirection
      Write vObjectDirection;
    Property ObjectValue: TObjectValue Read vObjectValue Write vObjectValue;
    Property Alias: String Read vAlias Write vAlias;
    Property ParamName: String Read GetDisplayName Write SetDisplayName;
    Property Encoded: Boolean Read vEncoded Write vEncoded;
    Property DefaultValue: String Read vDefaultValue Write vDefaultValue;
  End;

Type
  TRESTDWParamsMethods = Class;

  TRESTDWParamsMethods = Class(TOwnedCollection)
  Private
    fOwner: TPersistent;
    Function GetRec(Index: Integer): TRESTDWParamMethod; Overload;
    Procedure PutRec(Index: Integer; Item: TRESTDWParamMethod); Overload;
    Function GetRecName(Index: String): TRESTDWParamMethod; Overload;
    Procedure PutRecName(Index: String; Item: TRESTDWParamMethod); Overload;
  Public
    Procedure ClearList;
    Constructor Create(AOwner: TPersistent; aItemClass: TCollectionItemClass);
    Destructor Destroy; Override;
    Procedure Delete(Index: Integer); Overload;
    Property Items[Index: Integer]: TRESTDWParamMethod Read GetRec
      Write PutRec; Default;
    Property ParamByName[Index: String]: TRESTDWParamMethod Read GetRecName
      Write PutRecName;
  End;

Type
  PJSONParam = ^TJSONParam;

  TJSONParam = Class(TObject)
  Private
    vJSONValue: TJSONValue;
    vDataMode: TDataMode;
    vEncoding: TEncodeSelect;
    vTypeObject: TTypeObject;
    vObjectDirection: TObjectDirection;
    vObjectValue: TObjectValue;
    vCripto: TCripto;
    vAlias, vFloatDecimalFormat, vParamName, vParamFileName,
      vParamContentType: String;
    vDefaultValue: Variant;
    vNullValue, vBinary, vEncoded: Boolean;
    {$IFDEF RESTDWLAZARUS}
    vEncodingLazarus: TEncoding;
    vDatabaseCharSet: TDatabaseCharSet;
    {$ENDIF}
    Procedure WriteValue(bValue: Variant); Overload;
    Procedure WriteValue(bValue: TStream); Overload;
    Procedure SetParamName(bValue: String);
    Procedure SetParamFileName(bValue: String);
    Function GetAsString: String;
    Procedure SetAsString(Value: String);
    {$IF Defined(RESTDWLAZARUS) and not Defined(RESTDWLINUX)}
    Function GetAsWideString: WideString;
    Procedure SetAsWideString(Value: WideString);
    Function GetAsAnsiString: AnsiString;
    Procedure SetAsAnsiString(Value: AnsiString);
    {$IFEND}
    Function GetAsBCD: Currency;
    Procedure SetAsBCD(Value: Currency);
    Function GetAsFMTBCD: Currency;
    Procedure SetAsFMTBCD(Value: Currency);
    Function GetAsCurrency: Currency;
    Procedure SetAsCurrency(Value: Currency);
    Function GetAsBoolean: Boolean;
    Procedure SetAsBoolean(Value: Boolean);
    Function GetAsDateTime: TDateTime;
    Procedure SetAsDateTime(Value: TDateTime);
    Procedure SetAsDate(Value: TDateTime);
    Procedure SetAsTime(Value: TDateTime);
    Function GetAsSingle: Single;
    Procedure SetAsSingle(Value: Single);
    Function GetAsFloat: Double;
    Procedure SetAsFloat(Value: Double);
    Function GetAsInteger: Integer;
    Procedure SetAsInteger(Value: Integer);
    Function GetAsWord: Word;
    Procedure SetAsWord(Value: Word);
    Procedure SetAsSmallInt(Value: Integer);
    Procedure SetAsShortInt(Value: Integer);
    Function GetAsLongWord: LongWord;
    Procedure SetAsLongWord(Value: LongWord);
    Function GetAsLargeInt: LargeInt;
    Procedure SetAsLargeInt(Value: LargeInt);
    Procedure SetObjectValue(Value: TObjectValue);
    Procedure SetObjectDirection(Value: TObjectDirection);
    Function GetByteString: String;
    Procedure SetAsObject(Value: String);
    Procedure SetEncoded(Value: Boolean);
    Procedure SetParamContentType(Const bValue: String);
    {$IFDEF RESTDWLAZARUS}
    Procedure SetDatabaseCharSet(Value: TDatabaseCharSet);
    {$ENDIF}
    Function TestNilParam: Boolean;
  Public
    Procedure Clear;
    Constructor Create(Encoding: TEncodeSelect);
    Procedure Assign(Source: TObject);
    Destructor Destroy; Override;
    Function IsEmpty: Boolean;
    Function IsNull: Boolean;
    Procedure FromJSON(json: String);
    Function ToJSON: String;
    Procedure SaveToFile(FileName: String);
    Procedure CopyFrom(JSONParam: TJSONParam); Overload;
    Procedure CopyFrom(JSONParam: TRESTDWParamMethod); Overload;
    Procedure SetVariantValue(Value: Variant);
    Procedure SetDataValue(Value: Variant; DataType: TObjectValue);
    Function GetVariantValue: Variant;
    Function GetNullValue(Value: TObjectValue): Variant;
    Function GetValue(Value: TObjectValue): Variant;
    Procedure SetValue(aValue: String; Encode: Boolean = True); Overload;
    Procedure SetValue(aValue: TStream); Overload;
    Procedure LoadFromStream(Stream: TStringStream); Overload;
    Procedure LoadFromStream(Stream: TMemoryStream); Overload;
    Procedure LoadFromStream(Stream: TStream); Overload;
    Procedure CopyFromStream(Stream: TStream; Count: DWInt64);
    Procedure ToBytes(Value: String; Encode: Boolean = False);
    Procedure SaveToStream(Var Stream: TStream); Overload;
    Procedure SaveToStream(Var Stream: TStringStream); Overload;
    Procedure SaveToStream(Var Stream: TMemoryStream); Overload;
    Procedure LoadFromParam(Param: TParam);
    Procedure SaveFromParam(Param: TParam);
    Property CriptOptions: TCripto Read vCripto Write vCripto;
    {$IFDEF RESTDWLAZARUS}
    Property DatabaseCharSet: TDatabaseCharSet Read vDatabaseCharSet
      Write SetDatabaseCharSet;
    {$ENDIF}
    Property ObjectDirection: TObjectDirection Read vObjectDirection
      Write SetObjectDirection;
    Property ObjectValue: TObjectValue Read vObjectValue Write SetObjectValue;
    Property Alias: String Read vAlias Write vAlias;
    Property ParamName: String Read vParamName Write SetParamName;
    Property ParamFileName: String Read vParamFileName Write SetParamFileName;
    Property ParamContentType: String Read vParamContentType
      Write SetParamContentType;
    Property Encoded: Boolean Read vEncoded Write SetEncoded;
    Property Binary: Boolean Read vBinary;
    Property DataMode: TDataMode Read vDataMode Write vDataMode;
    Property FloatDecimalFormat: String Read vFloatDecimalFormat
      Write vFloatDecimalFormat;
    // Propriedades Novas
    Property Value: Variant Read GetVariantValue Write SetVariantValue;
    Property DefaultValue: Variant Read vDefaultValue Write vDefaultValue;
    // Novas definições por tipo
    Property AsBCD: Currency Read GetAsBCD Write SetAsBCD;
    Property AsFMTBCD: Currency Read GetAsFMTBCD Write SetAsFMTBCD;
    Property AsBoolean: Boolean Read GetAsBoolean Write SetAsBoolean;
    Property AsCurrency: Currency Read GetAsCurrency Write SetAsCurrency;
    Property AsExtended: Currency Read GetAsCurrency Write SetAsCurrency;
    Property AsDate: TDateTime Read GetAsDateTime Write SetAsDate;
    Property AsTime: TDateTime Read GetAsDateTime Write SetAsTime;
    Property AsDateTime: TDateTime Read GetAsDateTime Write SetAsDateTime;
    Property AsSingle: Single Read GetAsSingle Write SetAsSingle;
    Property AsFloat: Double Read GetAsFloat Write SetAsFloat;
    Property AsInteger: Integer Read GetAsInteger Write SetAsInteger;
    Property AsSmallInt: Integer Read GetAsInteger Write SetAsSmallInt;
    Property AsShortInt: Integer Read GetAsInteger Write SetAsShortInt;
    Property AsWord: Word Read GetAsWord Write SetAsWord;
    Property AsLongWord: LongWord Read GetAsLongWord Write SetAsLongWord;
    Property AsLargeInt: LargeInt Read GetAsLargeInt Write SetAsLargeInt;
    Property AsString: String Read GetAsString Write SetAsString;
    Property AsObject: String Read GetAsString Write SetAsObject;
    Property AsByteString: String Read GetByteString;
    {$IF Defined(RESTDWLAZARUS) and not Defined(RESTDWLINUX)}
    Property AsWideString: WideString Read GetAsWideString
      Write SetAsWideString;
    Property AsAnsiString: AnsiString Read GetAsAnsiString
      Write SetAsAnsiString;
    {$IFEND}
    Property AsMemo: String Read GetAsString Write SetAsString;
  End;

Type
  TRESTDWParams = Class(TList)
  Private
    vDataMode: TDataMode;
    vEncoding: TEncodeSelect;
    vCripto: TCripto;
    vHeaders: TRESTDWHeaders;
    vUrl_Redirect: String;
    {$IFDEF RESTDWLAZARUS}
    vEncodingLazarus: TEncoding;
    vDatabaseCharSet: TDatabaseCharSet;
    {$ENDIF}
    Procedure Assign(Source: TList);
    Function GetRec(Index: Integer): TJSONParam; Overload;
    Procedure PutRec(Index: Integer; Item: TJSONParam); Overload;
    Function GetRecName(Index: String): TJSONParam; Overload;
    Function GetRawBody: TJSONParam;
    Procedure PutRecName(Index: String; Item: TJSONParam); Overload;
    Procedure PutRawBody(Item: TJSONParam);
    Procedure ClearList;
  Public
    // Procedure   Clear;Override;
    Constructor Create;
    Procedure CreateParam(ParamName: String; Value: String = '');
    Destructor Destroy; Override;
    Procedure Clear; Override;
    Function ParamsReturn: Boolean;
    Function CountOutParams: Integer;
    Function CountInParams: Integer;
    Function ToJSON: String;
    Procedure SaveToFile(FileName: String);
    Procedure FromJSON(json: String; BinaryRequest: Boolean = False);
    Procedure CopyFrom(DWParams: TRESTDWParams);
    Procedure Delete(Index: Integer); Overload;
    Procedure Delete(Param: TJSONParam); Overload;
    Function Add(Item: TJSONParam): Integer; Overload;
    Procedure SaveToStream(Var Stream: TStream;
      Output: TDWParamExpType = tdwpxt_All);
    Procedure LoadFromStream(Stream: TStream; ValidateHeader: Boolean = False;
      Input: TDWParamExpType = tdwpxt_All);
    Procedure LoadFromParams(Params: TParams);
    Procedure SetCriptOptions(Use: Boolean; Key: String);
    Property Items[Index: Integer]: TJSONParam Read GetRec
      Write PutRec; Default;
    Property ItemsString[Index: String]: TJSONParam Read GetRecName
      Write PutRecName;
    Property RawBody: TJSONParam Read GetRawBody Write PutRawBody;
    Property DataMode: TDataMode Read vDataMode Write vDataMode;
    Property Encoding: TEncodeSelect Read vEncoding Write vEncoding;
    Property CriptOptions: TCripto Read vCripto Write vCripto;
    Property RequestHeaders: TRESTDWHeaders Read vHeaders Write vHeaders;
    Property Url_Redirect: String Read vUrl_Redirect Write vUrl_Redirect;
    {$IFDEF RESTDWLAZARUS}
    Property DatabaseCharSet: TDatabaseCharSet Read vDatabaseCharSet
      Write vDatabaseCharSet;
    {$ENDIF}
  End;

implementation

Uses uRESTDWJSONInterface, uRESTDWDataUtils, uRESTDWPropertyPersist;

Function CopyValue(Var bValue: String): String;
Var
  vOldString, vStringBase, vTempString: String;
  A, vLengthString: Integer;
Begin
  If bValue = '' Then
    Exit;
  vOldString := bValue;
  vStringBase := '"ValueType":"';
  vLengthString := Length(vStringBase);
  vTempString := Copy(bValue, Pos(vStringBase, bValue) + vLengthString,
    Length(bValue));
  A := Pos(':', vTempString);
  vTempString := Copy(vTempString, A, Length(vTempString));
  If vTempString <> '' Then
  Begin
    If vTempString[InitStrPos] = ':' Then
      Delete(vTempString, 1, 1);
    If vTempString[InitStrPos] = '"' Then
      Delete(vTempString, 1, 1);
  End;
  If vTempString = '}' Then
    vTempString := '';
  If vTempString <> '' Then
  Begin
    For A := Length(vTempString) - FinalStrPos Downto InitStrPos Do
    Begin
      If vTempString[A] <> '}' Then
        Delete(vTempString, Length(vTempString), 1)
      Else
      Begin
        Delete(vTempString, Length(vTempString), 1);
        Break;
      End;
    End;
    If vTempString[Length(vTempString) - FinalStrPos] = '"' Then
      Delete(vTempString, Length(vTempString), 1);
  End;
  Result := vTempString;
  bValue := StringReplace(bValue, Result, '', [rfReplaceAll]);
End;

Procedure SetValueA(Field: TField; Value: String);
Var
  vTempValue: String;
Begin
  Case Field.DataType Of
    ftUnknown, ftString, ftFixedChar, ftWideString:
      Field.AsString := Value;
    ftAutoInc, ftSmallint, ftInteger, ftLargeint, ftWord,
    {$IFDEF DELPHIXEUP} // Delphi 2010 pra cima
    ftShortint, ftByte, ftLongWord,
    {$ENDIF}
    ftBoolean:
      Begin
        Value := Trim(Value);
        If Value <> '' Then
        Begin
          If Field.DataType = ftBoolean Then
          Begin
            If (Value = '0') Or (Value = '1') Then
              Field.AsBoolean := StrToInt(Value) = 1
            Else
              Field.AsBoolean := Lowercase(Value) = 'true';
          End
          Else
          Begin
            If Field.DataType = ftLargeint Then
            Begin
              {$IFDEF DELPHIXEUP}
              Field.AsLargeInt := StrToInt64(Value);
              {$ELSE}
              Field.AsInteger := StrToInt64(Value);
              {$ENDIF}
            End
            Else
              Field.AsInteger := StrToInt(Value);
          End;
        End;
      End;
    ftFloat, ftCurrency, ftBCD,
    {$IFDEF DELPHIXEUP}ftExtended, ftSingle, {$ENDIF}
    ftFMTBcd:
      Begin
        Value := Trim(Value);
        vTempValue := BuildFloatString(Value);
        If vTempValue <> '' Then
        Begin
          Case Field.DataType Of
            ftFloat:
              Field.AsFloat := StrToFloat(vTempValue);
            ftCurrency, ftBCD,
            {$IFDEF DELPHIXEUP}ftExtended, ftSingle, {$ENDIF}
            ftFMTBcd:
              Begin
                If Field.DataType in [ftBCD, ftFMTBcd] Then
                  {$IFDEF DELPHIXEUP}
                  Field.AsBCD := StrToFloat(vTempValue)
                  {$ELSE}
                  Field.AsFloat := StrToFloat(vTempValue)
                  {$ENDIF}
                Else
                  Field.AsFloat := StrToFloat(vTempValue);
              End;
          End;
        End;
      End;
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      Begin
        vTempValue := Value;
        If vTempValue <> '' Then
        Begin
          If (Pos('.', vTempValue) > 0) Or (Pos(':', vTempValue) > 0) Or
            (Pos('/', vTempValue) > 0) Or (Pos('\', vTempValue) > 0) Or
            (Pos('-', vTempValue) > 0) Then
            Field.AsDateTime := StrToDateTime(vTempValue)
          Else If StrToInt64(vTempValue) > 0 Then
            Field.AsDateTime := UnixToDateTime(StrToInt64(vTempValue));
        End;
      End;
  End;
End;

Function StringToJsonString(OriginalString: String): String;
Var
  I: Integer;
  Function NewChar(OldChar: String): String;
  Begin
    Result := '';
    If Length(OldChar) > 0 Then
    Begin
      Case OldChar[1] Of
        '\':
          Result := '\\';
        '"':
          Result := '\"';
        '/':
          Result := '\/';
        #8:
          Result := '\b';
        #9:
          Result := '\t';
        #10:
          Result := '\n';
        #12:
          Result := '\f';
        #13:
          Result := '\r';
      End;
    End;
  End;

Begin
  Result := OriginalString;
  For I := 0 To Length(TSpecialChars) - 1 Do
    Result := StringReplace(Result, TSpecialChars[I], NewChar(TSpecialChars[I]),
      [rfReplaceAll]);
End;

Constructor TRESTDWParamMethod.Create(aCollection: TCollection);
Begin
  Inherited;
  vTypeObject := toParam;
  vObjectDirection := odINOUT;
  vObjectValue := ovString;
  vParamName := 'dwparam' + IntToStr(aCollection.Count);
  vEncoded := True;
  vDefaultValue := '';
  vAlias := '';
End;

function TRESTDWParamMethod.GetDisplayName: String;
begin
  Result := vParamName;
end;

procedure TRESTDWParamMethod.SetDisplayName(const Value: String);
begin
  If Trim(Value) = '' Then
    Raise Exception.Create(cInvalidParamName)
  Else
  Begin
    vParamName := Trim(Value);
    Inherited;
  End;
end;

procedure TRESTDWParamsMethods.ClearList;
Var
  I: Integer;
Begin
  For I := Count - 1 Downto 0 Do
    Delete(I);
  Self.Clear;
End;

constructor TRESTDWParamsMethods.Create(AOwner: TPersistent;
  aItemClass: TCollectionItemClass);
begin
  Inherited Create(AOwner, TRESTDWParamMethod);
  Self.fOwner := AOwner;
end;

procedure TRESTDWParamsMethods.Delete(Index: Integer);
begin
  If (Index < Self.Count) And (Index > -1) Then
    TOwnedCollection(Self).Delete(Index);
end;

destructor TRESTDWParamsMethods.Destroy;
begin
  ClearList;
  Inherited;
end;

Function TRESTDWParamsMethods.GetRec(Index: Integer): TRESTDWParamMethod;
Begin
  Result := TRESTDWParamMethod(inherited GetItem(Index));
End;

function TRESTDWParamsMethods.GetRecName(Index: String): TRESTDWParamMethod;
Var
  I: Integer;
Begin
  Result := Nil;
  If Lowercase(Index) <> '' Then
  Begin
    For I := 0 To Self.Count - 1 Do
    Begin
      If (Lowercase(Index) = Lowercase(Self.Items[I].vParamName)) Or
        (Lowercase(Index) = Lowercase(Self.Items[I].vAlias)) Then
      Begin
        Result := TRESTDWParamMethod(Self.Items[I]);
        Break;
      End;
    End;
  End;
End;

procedure TRESTDWParamsMethods.PutRec(Index: Integer; Item: TRESTDWParamMethod);
begin
  If (Index < Self.Count) And (Index > -1) Then
    SetItem(Index, Item);
end;

procedure TRESTDWParamsMethods.PutRecName(Index: String;
  Item: TRESTDWParamMethod);
Var
  I: Integer;
Begin
  If Lowercase(Index) <> '' Then
  Begin
    For I := 0 To Self.Count - 1 Do
    Begin
      If (Uppercase(Index) = Uppercase(Self.Items[I].vParamName)) Or
        (Lowercase(Index) = Lowercase(Self.Items[I].vAlias)) Then
      Begin
        Self.Items[I] := Item;
        Break;
      End;
    End;
  End;
End;

Constructor TRESTDWHeaders.Create;
Begin
  Inherited;
  Input := TStringList.Create;
  Output := TStringList.Create;
End;

Destructor TRESTDWHeaders.Destroy;
Begin
  FreeAndNil(Input);
  FreeAndNil(Output);
  Inherited;
End;

// Aqui vai ler os Parametros, tem que estar syncronizado com o escrita dos parametros
// Alterado por ABrito
Function TJSONValue.GetValue(CanConvert: Boolean = True): Variant;
Var
  vTempString: String;
Begin
  Result := '';
  If IsNull Then
  Begin
    Result := Null;
    Exit;
  End;
  If restdwLength(aValue) = 0 Then
    Exit;
  vTempString := BytesToString(aValue);
  If Length(vTempString) > 0 Then
  Begin
    If vTempString[InitStrPos] = '"' Then
      Delete(vTempString, 1, 1);
    If vTempString[Length(vTempString) - FinalStrPos] = '"' Then
      Delete(vTempString, Length(vTempString), 1);
    vTempString := Trim(vTempString);
  End;
  If vEncoded Then
  Begin
    If (vObjectValue In [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic,
      ovOraBlob, ovOraClob]) And (vBinary) Then
      vTempString := vTempString
    Else
    Begin // TODO
      If Length(vTempString) > 0 Then
      Begin
        vTempString := TEncoding.UTF8.Getstring
          (TBytes(stringTobytes(DecodeStrings(vTempString{$IFDEF RESTDWLAZARUS},
          csUndefined{$ENDIF}))));
        If (vObjectValue In [ovWideString, ovWidememo, ovMemo]) then
        Begin
          vTempString := DecodeStrings(vTempString{$IFDEF RESTDWLAZARUS},
            csUndefined{$ENDIF});
          {$IFDEF RESTDWLINUX}
          vTempString := TEncoding.UTF8.Getstring(stringTobytes(vTempString));
          {$ELSE}
          vTempString := utf8tostring(vTempString);
          {$ENDIF}
        end;
      End;
    End;
  End
  Else
  Begin
    If Length(vTempString) = 0 Then
      vTempString := BytesToString(aValue);
  End;
  If vObjectValue = ovString Then
  Begin
    If vTempString <> '' Then
      If vTempString[InitStrPos] = '"' Then
      Begin
        Delete(vTempString, 1, 1);
        If vTempString[Length(vTempString) - FinalStrPos] = '"' Then
          Delete(vTempString, Length(vTempString), 1);
      End;
    Result := vTempString;
  End
  Else
    Result := vTempString;
  If Not CanConvert Then
  Begin
    If vObjectValue In [ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd,
      ovExtended] Then
      If (vTempString <> '') And (Lowercase(vTempString) <> 'null') Then
        Result := BuildStringFloat(vTempString, vDataMode)
      Else
        Result := 0;
    Exit;
  End;
  vTempString := '';
  If vObjectValue In [ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd,
    ovExtended] Then
  Begin
    If (Result <> '') And (Lowercase(Result) <> 'null') Then
      Result := StrToFloat(BuildFloatString(Result))
    Else
      Result := 0;
  End;
  If vObjectValue In [ovDate, ovTime, ovDateTime, ovTimeStamp, ovOraTimeStamp,
    ovTimeStampOffset] Then
  Begin
    If (Result <> '') And (Lowercase(Result) <> 'null') Then
    Begin
      If (Pos('/', Result) = 0) And (Pos('-', Result) <= 1) Then
        Result := StrToFloat(Result);
    End
    Else
      Result := 0;
  End;
  If vObjectValue In [ovLargeInt, ovLongWord, ovShortInt, ovSmallInt, ovInteger,
    ovWord, ovBoolean, ovAutoInc, ovOraInterval] Then
  Begin
    If (Result <> '') And (Lowercase(Result) <> 'null') Then
    Begin
      If vObjectValue = ovBoolean Then
        Result := (Result = '1') Or (Lowercase(Result) = 'true')
      Else If (Trim(Result) <> '') And (Trim(Result) <> 'null') Then
      Begin
        If vObjectValue in [ovLargeInt, ovLongWord] Then
          Result := StrToInt64(Result)
        Else
          Result := StrToInt(Result);
      End;
    End;
  End;
End;

Procedure TJSONValue.WriteValue(bValue: TStream);
Begin
  vNullValue := False;
  If bValue.Size = 0 Then
  Begin
    vNullValue := True;
    Exit;
  End
  Else
    aValue := StreamToBytes(bValue);
End;

Procedure TJSONValue.WriteValue(bValue: Variant);
{$IFNDEF DELPHIXEUP}
Var
  vValueAnsi: AnsiString;
  {$ENDIF}
Begin
  vNullValue := False;
  SetLength(aValue, 0);
  If VarIsNull(bValue) Then
  Begin
    vNullValue := True;
    Exit;
  End
  Else
  Begin
    If ((bValue = '') or (bValue = 'null')) Then
    Begin
      If Not vNullValue Then
        vNullValue := Not(vObjectValue in [ovString, ovGuid, ovMemo, ovWidememo,
          ovFmtMemo]);
      Exit;
    End
    Else
      vNullValue := False;
    If vObjectValue in [ovString, ovGuid, ovMemo, ovWidememo, ovFmtMemo,
      ovObject, ovDataset] Then
    Begin
      {$IFDEF RESTDWLAZARUS}
      If vEncodingLazarus = Nil Then
        SetEncoding(vEncoding);
      If vEncoded Then
      Begin
        If vEncoding = esUtf8 Then
          aValue := TRESTDWBytes
            (vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
        Else
          aValue := stringTobytes(Format(TJsonStringValue, [bValue]))
      End
      Else
      Begin
        If ((DataMode = dmDataware) And (vEncoded)) Or
          Not(vObjectValue = ovObject) Then
        Begin
          If vEncoding = esUtf8 Then
            aValue := TRESTDWBytes
              (vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
          Else
            aValue := stringTobytes(Format(TJsonStringValue, [bValue]));
        End
        Else
        Begin
          If vEncoding = esUtf8 Then
            aValue := TRESTDWBytes(vEncodingLazarus.GetBytes(bValue))
          Else
            aValue := stringTobytes(String(bValue));
        End;
      End;
      {$ELSE}
      If vEncoded Then
        aValue := stringTobytes(Format(TJsonStringValue, [bValue]))
      Else
      Begin
        If ((DataMode = dmDataware) And (vEncoded)) Or
          Not(vObjectValue = ovObject) Then
          aValue := stringTobytes(Format(TJsonStringValue, [bValue]))
        Else
          aValue := stringTobytes(String(bValue));
      End;
      {$ENDIF}
    End
    Else If vObjectValue in [ovDate, ovTime, ovDateTime, ovTimeStamp,
      ovOraTimeStamp, ovTimeStampOffset] Then
    Begin
      {$IFDEF RESTDWLAZARUS}
      If vEncoding = esUtf8 Then
        aValue := TRESTDWBytes
          (vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
      Else
        aValue := stringTobytes(Format(TJsonStringValue, [bValue]));
      {$ELSE}
      aValue := stringTobytes(Format(TJsonStringValue, [bValue]));
      {$ENDIF}
    End
    Else If vObjectValue in [ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd,
      ovExtended] Then
    Begin
      {$IFDEF RESTDWLAZARUS}
      If vEncoding = esUtf8 Then
        aValue := TRESTDWBytes
          (vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
      Else
        aValue := stringTobytes(Format(TJsonStringValue, [bValue]));
      {$ELSE}
      aValue := stringTobytes(Format(TJsonStringValue, [bValue]));
      {$ENDIF}
    End
    Else
    Begin
      If bValue <> 'null' Then
      Begin
        {$IFDEF RESTDWLAZARUS}
        If vEncoding = esUtf8 Then
          aValue := TRESTDWBytes(vEncodingLazarus.GetBytes(bValue))
        Else
          aValue := stringTobytes(String(bValue));
        {$ELSE}
        {$IFDEF DELPHIXEUP} // Delphi 2010 pra cima
        aValue := stringTobytes(String(bValue));
        {$ELSE} // Delphi 2010 pra cima
        vValueAnsi := bValue;
        SetLength(aValue, Length(vValueAnsi));
        move(vValueAnsi[InitStrPos], pByteArray(aValue)^, Length(aValue));
        {$ENDIF}
        {$ENDIF}
      End;
    End;
  End;
End;

Function TJSONValue.FormatValue(bValue: String): String;
Var
  aResult, aPattern: String;
  vInsertTag: Boolean;
Begin
  aResult := bValue;
  vInsertTag := vObjectValue In [ovDate, ovTime, ovDateTime, ovTimeStamp];
  If Trim(aResult) <> '' Then
  Begin
    If (aResult[InitStrPos] = '"') And
      (aResult[Length(aResult) - FinalStrPos] = '"') Then
    Begin
      Delete(aResult, 1, 1);
      Delete(aResult, Length(aResult), 1);
    End;
  End;
  If Not vEncoded Then
  Begin
    If Trim(aResult) <> '' Then
      If Not(((Pos('{', aResult) > 0) And (Pos('}', aResult) > 0)) Or
        ((Pos('[', aResult) > 0) And (Pos(']', aResult) > 0))) Then
        If Not(vObjectValue In [ovStream, ovBlob, ovGraphic, ovOraBlob,
          ovOraClob]) Then
          aResult := StringToJsonString(aResult);
  End;
  If vNullValue Then
    aResult := cNullvalue
  Else If ((Trim(aResult) = '') or (Trim(bValue) = cNullvalueTag)) And
    vInsertTag Then
    aResult := cBlankStringJSON;
  If DataMode = dmDataware Then
  Begin
    If (vTypeObject = toDataset) Then
      Result := Format(TValueFormatJSON,
        ['ObjectType', GetObjectName(vTypeObject), 'Direction',
        GetDirectionName(vObjectDirection), 'Encoded', EncodedString,
        'ValueType', GetValueType(vObjectValue), vtagName,
        GetValueJSON(aResult)])
    Else If (vObjectValue = ovObject) And (vEncoded) Then
      Result := Format(TValueFormatJSONValueS,
        ['ObjectType', GetObjectName(vTypeObject), 'Direction',
        GetDirectionName(vObjectDirection), 'Encoded', EncodedString,
        'ValueType', GetValueType(vObjectValue), vtagName, GetValueJSON(aResult)
        ]) // TValueFormatJSON
    Else If (vObjectValue = ovObject) Then
      Result := Format(TValueFormatJSONValue,
        ['ObjectType', GetObjectName(vTypeObject), 'Direction',
        GetDirectionName(vObjectDirection), 'Encoded', EncodedString,
        'ValueType', GetValueType(vObjectValue), vtagName, GetValueJSON(aResult)
        ]) // TValueFormatJSON
    Else
    Begin
      If vNullValue Then
        Result := Format(TValueFormatJSONValue,
          ['ObjectType', GetObjectName(vTypeObject), 'Direction',
          GetDirectionName(vObjectDirection), 'Encoded', EncodedString,
          'ValueType', GetValueType(vObjectValue), vtagName,
          GetValueJSON(aResult)])
      Else If (vObjectValue in [ovString, ovGuid, ovWideString, ovMemo,
        ovWidememo, ovFmtMemo, ovFixedChar]) Or (vInsertTag) Then
        Result := Format(TValueFormatJSONValueS,
          ['ObjectType', GetObjectName(vTypeObject), 'Direction',
          GetDirectionName(vObjectDirection), 'Encoded', EncodedString,
          'ValueType', GetValueType(vObjectValue), vtagName,
          GetValueJSON(aResult)])
      Else If (vObjectValue In [ovFloat, ovCurrency, ovBCD, ovFMTBcd,
        ovExtended]) Then
      Begin
        Result := Format(TValueFormatJSONValueS,
          ['ObjectType', GetObjectName(vTypeObject), 'Direction',
          GetDirectionName(vObjectDirection), 'Encoded', EncodedString,
          'ValueType', GetValueType(vObjectValue), vtagName,
          GetValueJSON(BuildStringFloat(aResult, DataMode,
          vFloatDecimalFormat))]);
      End
      Else
      Begin
        If (vObjectValue In [ovBlob, ovStream, ovGraphic, ovOraBlob,
          ovOraClob]) Then
        Begin
          If aResult <> '' Then
          Begin
            If (((((aResult <> cBlankStringJSON) And
              Not((aResult[InitStrPos] = '"') And (aResult[Length(aResult) -
              FinalStrPos] = '"')))) And (vEncoded)) Or
              (Not(vEncoded) And (aResult = ''))) Or
              (Pos('"', aResult) = 0) Then
              aResult := '"' + aResult + '"'
            Else If (aResult = '') Then
              aResult := cBlankStringJSON;
          End
          Else
            aResult := cBlankStringJSON;
        End;
        If (Trim(bValue) = cNullvalueTag) Then
          Result := Format(TValueFormatJSONValue,
            ['ObjectType', GetObjectName(vTypeObject), 'Direction',
            GetDirectionName(vObjectDirection), 'Encoded', EncodedString,
            'ValueType', GetValueType(vObjectValue), vtagName,
            GetValueJSON(Trim(bValue))])
        Else
          Result := Format(TValueFormatJSONValue,
            ['ObjectType', GetObjectName(vTypeObject), 'Direction',
            GetDirectionName(vObjectDirection), 'Encoded', EncodedString,
            'ValueType', GetValueType(vObjectValue), vtagName,
            GetValueJSON(aResult)]);
      End;
    End;
  End
  Else
    Result := aResult;
End;

Function TJSONValue.GetValueJSON(bValue: String): String;
Begin
  Result := bValue;
  If ((bValue = '') or (bValue = '""')) And (vNullValue) Then
    Result := 'null'
  Else If (bValue = '') Then
    bValue := '""';
End;

Function TJSONValue.DatasetValues(bValue: TDataset; DateTimeFormat: String = '';
  DataModeD: TDataMode = dmDataware; FloatDecimalFormat: String = '';
  HeaderLowercase: Boolean = False; VirtualValue: String = '';
  DWJSONType: TRESTDWJSONType = TRESTDWJSONArrayType;
  bDetail: TDataset = Nil): String;
Var
  vLines, vFieldName, vFormatMask, vValueMask, vBuildSide: String;
  A, vRecNo: Integer; // pr-19/08/2020
  Function GenerateHeader: String;
  Var
    I{$IFDEF RESTDWLAZARUS}, vSize{$ENDIF} : Integer;
    vPrimary, vRequired, vReadOnly, vGenerateLine, vAutoinc: string;
  Begin
    For I := 0 To bValue.Fields.Count - 1 Do
    Begin
      vPrimary := 'N';
      vAutoinc := 'N';
      vReadOnly := 'N';
      If pfInKey in bValue.Fields[I].ProviderFlags Then
        vPrimary := 'S';
      vRequired := 'N';
      If bValue.Fields[I].Required Then
        vRequired := 'S';
      If Not(bValue.Fields[I].CanModify) Then
        vReadOnly := 'S';
      {$IFDEF DELPHIXEUP}
      If bValue.Fields[I].AutoGenerateValue = arAutoInc Then
        vAutoinc := 'S';
      {$ELSE}
      vAutoinc := 'N';
      {$ENDIF}
      vFieldName := bValue.Fields[I].FieldName;
      // If vLowercaseFieldNames Then
      // vFieldName := Lowercase(bValue.Fields[i].FieldName);
      If bValue.Fields[I].DataType In [{$IFDEF DELPHIXEUP}ftExtended, ftSingle,
      {$ENDIF}
      ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
      Begin
        If bValue.Fields[I].DataType In [ftFMTBcd, ftBCD] then
        Begin
          {$IFNDEF RESTDWLAZARUS}
          vGenerateLine := Format(TJsonDatasetHeader,
            [vFieldName, GetFieldType(bValue.Fields[I].DataType), vPrimary,
            vRequired, TBCDField(bValue.Fields[I]).Precision,
            TBCDField(bValue.Fields[I]).Size, vReadOnly, vAutoinc])
          {$ELSE}
          vSize := TBCDField(bValue.Fields[I]).Size;
          If vSize > 0 Then
            vSize := TBCDField(bValue.Fields[I]).Precision
          Else
            vSize := Sizeof(Double) * 2;
          vGenerateLine := Format(TJsonDatasetHeader,
            [vFieldName, GetFieldType(bValue.Fields[I].DataType), vPrimary,
            vRequired, vSize, LazDigitsSize, vReadOnly, vAutoinc]);
          {$ENDIF}
        End
        Else
        Begin
          {$IFDEF RESTDWLAZARUS}
          vSize := TFloatField(bValue.Fields[I]).Size;
          If vSize > 0 Then
            vSize := TFloatField(bValue.Fields[I]).Precision
          Else
            vSize := (Sizeof(Double) * 2) - 1;
          {$ENDIF}
          vGenerateLine := Format(TJsonDatasetHeader,
            [vFieldName, GetFieldType(bValue.Fields[I].DataType), vPrimary,
            vRequired,
            {$IFDEF RESTDWLAZARUS}vSize{$ELSE}TFloatField(bValue.Fields[I])
            .Precision{$ENDIF},
            {$IFDEF RESTDWLAZARUS}LazDigitsSize{$ELSE}TFloatField(bValue.Fields
            [I]).Size{$ENDIF}, vReadOnly, vAutoinc]);
        End;
      End
      Else
        vGenerateLine := Format(TJsonDatasetHeader,
          [vFieldName, GetFieldType(bValue.Fields[I].DataType), vPrimary,
          vRequired, bValue.Fields[I].Size, 0, vReadOnly, vAutoinc]);
      If I = 0 Then
        Result := vGenerateLine
      Else
        Result := Result + ', ' + vGenerateLine;
    End;
    If VirtualValue <> '' Then
      Result := Result + ', ' + Format(TJsonDatasetHeader,
        [cRDWDetailField, GetFieldType(ftMemo), False, False, 0, 0,
        False, False]);
    If HeaderLowercase Then
      Result := Lowercase(Result)
  End;
  Function GenerateLine: String;
  Var
    I: Integer;
    vTempField, vTempValue: String;
    bStream: TStream;
    vStringStream: TStringStream;
    Function RemoveTrashTime(Value: String): String;
    Var
      I, A, X: Integer;
      Function CountTime(Value: String): Integer;
      Var
        I: Integer;
      Begin
        Result := 0;
        For I := Length(Value) - FinalStrPos DownTo InitStrPos Do
        Begin
          If Value[I] = ' ' Then
            Break;
          If Lowercase(Value[I]) = 'm' Then
            Inc(Result)
          Else If Result > 0 Then
            Break;
        End;
      End;

    Begin
      If (Pos(':', Value) > 0) or (Pos(' ', Value) > 0) or (Pos('s', Value) > 0)
        or (Pos('h', Value) > 0) Then
      Begin
        X := CountTime(Value);
        Result := StringReplace(Value, 'h', '', [rfReplaceAll, rfIgnoreCase]);
        Result := StringReplace(Result, 's', '', [rfReplaceAll, rfIgnoreCase]);
        Result := StringReplace(Result, ':', '', [rfReplaceAll, rfIgnoreCase]);
        Result := StringReplace(Result, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        A := 0;
        If X > 0 Then
          For I := Length(Result) - FinalStrPos DownTo InitStrPos Do
          Begin
            If (Lowercase(Result[I]) = 'm') And (A < X) Then
            Begin
              Delete(Result, I, 1);
              Inc(A);
            End;
          End;
      End
      Else
        Result := Trim(Value);
    End;
    Function RemoveTrashDate(Value: String): String;
    Var
      I, A, X: Integer;
      Function CountMonth(Value: String): Integer;
      Var
        I: Integer;
      Begin
        Result := 0;
        For I := InitStrPos To Length(Value) - FinalStrPos Do
        Begin
          If Value[I] = ' ' Then
            Break;
          If Lowercase(Value[I]) = 'm' Then
            Inc(Result)
          Else If Result > 0 Then
            Break;
        End;
      End;

    Begin
      If (Pos('/', Value) > 0) or (Pos('-', Value) > 0) or (Pos(' ', Value) > 0)
        or (Pos('d', Value) > 0) or (Pos('y', Value) > 0) Then
      Begin
        A := 0;
        I := InitStrPos;
        X := CountMonth(Value);
        Result := StringReplace(Value, 'd', '', [rfReplaceAll, rfIgnoreCase]);
        Result := StringReplace(Result, 'y', '', [rfReplaceAll, rfIgnoreCase]);
        Result := StringReplace(Result, '/', '', [rfReplaceAll, rfIgnoreCase]);
        Result := StringReplace(Result, '-', '', [rfReplaceAll, rfIgnoreCase]);
        Result := StringReplace(Result, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        If X > 0 Then
          While I <= (Length(Result) - FinalStrPos) Do
          Begin
            If (Lowercase(Result[I]) = 'm') And (A < X) Then
            Begin
              Delete(Result, I, 1);
              Inc(A);
              Continue;
            End;
            Inc(I);
          End;
      End
      Else
        Result := Trim(Value);
    End;

  Begin
    For I := 0 To bValue.Fields.Count - 1 Do
    Begin
      Case DataModeD Of
        dmDataware:
          Begin
          End;
        dmRaw:
          Begin
            If HeaderLowercase Then
              vTempField := Format('"%s": ',
                [Lowercase(bValue.Fields[I].FieldName)])
            Else
              vTempField := Format('"%s": ', [bValue.Fields[I].FieldName]);
          End;
      End;
      If Not bValue.Fields[I].IsNull then
      Begin
        If bValue.Fields[I].DataType In [{$IFDEF DELPHIXEUP}ftShortint, {$ENDIF}
        ftSmallint, ftInteger, ftLargeint, ftAutoInc] Then
        Begin
          If bValue.Fields[I].DataType In [{$IFDEF DELPHIXEUP}ftShortint,
          {$ENDIF}ftSmallint] Then
          Begin
            If bValue.Fields[I].IsNull Then
              vTempValue := Format('%s%s', [vTempField, cNullvalue])
            Else
              vTempValue :=
                Format('%s%s',
                [vTempField, IntToStr(bValue.Fields[I].AsInteger)]);
          End
          Else
          Begin
            If bValue.Fields[I].IsNull Then
              vTempValue := Format('%s%s', [vTempField, cNullvalue])
            Else
              {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
              vTempValue :=
                Format('%s%s',
                [vTempField, IntToStr(bValue.Fields[I].AsLargeInt)]);
              {$ELSE}
              vTempValue :=
                Format('%s%s',
                [vTempField, IntToStr(bValue.Fields[I].AsInteger)]);
            {$IFEND}
          End;
        End
        Else If bValue.Fields[I].DataType In [{$IFDEF DELPHIXEUP}ftExtended,
          ftSingle, {$ENDIF}ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
        Begin
          vValueMask := BuildStringFloat(FloatToStr(bValue.Fields[I].AsFloat),
            DataModeD, '.');
          If ((FloatDecimalFormat <> '') And (FloatDecimalFormat <> '.')) Then
            vValueMask := BuildStringFloat(FloatToStr(bValue.Fields[I].AsFloat),
              DataModeD, FloatDecimalFormat);
          If vDataType or ((FloatDecimalFormat = '') or
            (FloatDecimalFormat = '.')) Then
            vFormatMask := '%s%s'
          Else
            vFormatMask := '%s"%s"';
          If bValue.Fields[I].IsNull Then
            vTempValue := Format('%s%s', [vTempField, cNullvalue])
          Else if DataModeD = dmDataware then
            vTempValue := Format('%s"%s"',
              [vTempField,
              BuildStringFloat(FloatToStr(bValue.Fields[I].AsFloat), DataModeD,
              FloatDecimalFormat)])
          Else
            vTempValue := Format(vFormatMask, [vTempField, vValueMask]);
        End
        Else If bValue.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob,
          ftGraphic, ftOraBlob, ftOraClob] Then
        Begin
          If bValue.Fields[I].IsNull Then
            vTempValue := Format('%s%s', [vTempField, cNullvalue])
          Else
          Begin
            vStringStream := TStringStream.Create('');
            bStream := bValue.CreateBlobStream
              (TBlobField(bValue.Fields[I]), bmRead);
            Try
              bStream.Position := 0;
              {$IF Defined(RESTDWLAZARUS) or not(Defined(DELPHIXEUP))}
              vStringStream.CopyFrom(bStream, bStream.Size);
              {$ELSE}
              vStringStream.LoadFromStream(bStream);
              {$IFEND}
              vTempValue := Format('%s"%s"',
                [vTempField, EncodeStream(vStringStream)]);
              // StreamToHex(vStringStream)]);
            Finally
              vStringStream.Free;
              bStream.Free;
            End;
          End;
        End
        Else
        Begin
          If bValue.Fields[I].DataType in [ftString, ftWideString, ftMemo,
          {$IFDEF DELPHIXEUP}ftWideMemo, {$ENDIF}
          ftFmtMemo, ftFixedChar] Then
          Begin
            If bValue.Fields[I].IsNull Then
              vTempValue := Format('%s%s', [vTempField, cNullvalue])
            Else
            Begin
              If (vEncoded) Or (bValue.Fields[I].DataType in [ftMemo,
                {$IFDEF DELPHIXEUP}ftWideMemo, {$ENDIF}
                ftFmtMemo]) Then
              Begin
                If DataModeD = dmRaw Then
                Begin
                  If (vEncoded) Then
                  Begin
                    {$IFDEF RESTDWLAZARUS}
                    vTempValue :=
                      Format('%s"%s"',
                      [vTempField,
                      EncodeStrings(StringToJsonString(bValue.Fields[I]
                      .AsString), vDatabaseCharSet)]);
                    {$ELSE}
                    vTempValue :=
                      Format('%s"%s"',
                      [vTempField,
                      EncodeStrings(StringToJsonString(bValue.Fields[I]
                      .AsString))]);
                    {$ENDIF}
                  End
                  Else
                  Begin
                    If vUtf8SpecialChars Then
                      vTempValue :=
                        Format('%s"%s"',
                        [vTempField, escape_chars(bValue.Fields[I].AsString)])
                    Else
                      vTempValue :=
                        Format('%s"%s"',
                        [vTempField,
                        StringToJsonString(bValue.Fields[I].AsString)]);
                  End;
                End
                Else
                Begin
                  {$IFDEF RESTDWLAZARUS}
                  vTempValue :=
                    Format('%s"%s"',
                    [vTempField, EncodeStrings(bValue.Fields[I].AsString,
                    vDatabaseCharSet)]);
                  {$ELSE}
                  vTempValue := bValue.Fields[I].AsString;
                  {$IFNDEF DELPHI2007UP}
                  If vEncoding = esUtf8 Then
                    Result := UTF8Decode(vTempValue);
                  {$ENDIF}
                  vTempValue :=
                    Format('%s"%s"', [vTempField, EncodeStrings(vTempValue)]);
                  {$ENDIF}
                End;
              End
              Else
              Begin
                {$IFDEF RESTDWLAZARUS}
                Case DatabaseCharSet Of
                  csWin1250:
                    vTempValue := CP1250ToUTF8(bValue.Fields[I].AsString);
                  csWin1251:
                    vTempValue := CP1251ToUTF8(bValue.Fields[I].AsString);
                  csWin1252:
                    vTempValue := CP1252ToUTF8(bValue.Fields[I].AsString);
                  csWin1253:
                    vTempValue := CP1253ToUTF8(bValue.Fields[I].AsString);
                  csWin1254:
                    vTempValue := CP1254ToUTF8(bValue.Fields[I].AsString);
                  csWin1255:
                    vTempValue := CP1255ToUTF8(bValue.Fields[I].AsString);
                  csWin1256:
                    vTempValue := CP1256ToUTF8(bValue.Fields[I].AsString);
                  csWin1257:
                    vTempValue := CP1257ToUTF8(bValue.Fields[I].AsString);
                  csWin1258:
                    vTempValue := CP1258ToUTF8(bValue.Fields[I].AsString);
                  csUTF8:
                    vTempValue := UTF8ToUTF8BOM(bValue.Fields[I].AsString);
                  csISO_8859_1:
                    vTempValue := ISO_8859_1ToUTF8(bValue.Fields[I].AsString);
                  csISO_8859_2:
                    vTempValue := ISO_8859_2ToUTF8(bValue.Fields[I].AsString);
                Else
                  vTempValue := bValue.Fields[I].AsString;
                End;
                If vUtf8SpecialChars Then
                  vTempValue := escape_chars(bValue.Fields[I].AsString)
                Else
                  vTempValue := StringToJsonString(bValue.Fields[I].AsString);
                vTempValue := Format('%s"%s"', [vTempField, vTempValue]);
                {$ELSE}
                If vUtf8SpecialChars Then
                  vTempValue := escape_chars(bValue.Fields[I].AsString)
                Else
                  vTempValue := StringToJsonString(bValue.Fields[I].AsString);
                vTempValue := Format('%s"%s"', [vTempField, vTempValue]);
                {$ENDIF}
              End;
            End;
          End
          Else If bValue.Fields[I].DataType in [ftDate, ftTime, ftDateTime,
            ftTimeStamp] Then
          Begin
            If bValue.Fields[I].IsNull Then
              vTempValue := Format('%s%s', [vTempField, cNullvalue])
            Else If (bValue.Fields[I].DataType = ftTime) and
              (RemoveTrashDate(DateTimeFormat) <> '') Then
              vTempValue := Format('%s"%s"',
                [vTempField, FormatDateTime(RemoveTrashDate(DateTimeFormat),
                bValue.Fields[I].AsDateTime)])
            Else
            Begin
              If (bValue.Fields[I].DataType in [ftDateTime, ftTimeStamp]) and
                (DateTimeFormat <> '') Then
                vTempValue :=
                  Format('%s"%s"', [vTempField, FormatDateTime(DateTimeFormat,
                  bValue.Fields[I].AsDateTime)])
              Else If (bValue.Fields[I].DataType = ftDate) and
                (RemoveTrashTime(DateTimeFormat) <> '') Then
                vTempValue :=
                  Format('%s"%s"',
                  [vTempField, FormatDateTime(RemoveTrashTime(DateTimeFormat),
                  bValue.Fields[I].AsDateTime)])
              Else
                vTempValue :=
                  Format('%s"%s"',
                  [vTempField,
                  IntToStr(DateTimeToUnix(bValue.Fields[I].AsDateTime))]);
            End;
          End
          Else If bValue.Fields[I].DataType in [ftBoolean] Then
            vTempValue := Format('%s%s',
              [vTempField,
              Lowercase(BoolToStr(bValue.Fields[I].AsBoolean, True))])
          Else
            vTempValue := Format('%s"%s"',
              [vTempField, bValue.Fields[I].AsString]); // asstring
        End;
      End
      Else
        vTempValue := Format('%s%s', [vTempField, cNullvalue]);
      If I = 0 Then
        Result := vTempValue
      Else
        Result := Result + ', ' + vTempValue;
    End;
    If (VirtualValue <> '') And (bDetail <> Nil) Then
    Begin
      If Trim(Result) <> '' Then
        Result := Result + ', ';
      If bDetail.Active Then
      Begin
        If bDetail.Eof Then
          Result := Result + VirtualValue + '[]'
        Else
          Result := Result + VirtualValue + DatasetValues(bDetail,
            DateTimeFormat, DataModeD, FloatDecimalFormat, HeaderLowercase, '',
            DWJSONType);
      End
      Else
        Result := Result + VirtualValue + '[]';
    End;
  End;

Begin
  bValue.DisableControls;
  Try
    If Not bValue.Active Then
      bValue.Open;

    if not bValue.IsUniDirectional then
      bValue.First;

    {$IFDEF RESTDWLAZARUS}
    vBuildSide := 'L';
    {$ELSE}
    vBuildSide := 'D';
    {$ENDIF}
    Case DataModeD Of
      dmDataware:
        Result := '{"fields":[' + GenerateHeader + '], "buildside":"' +
          vBuildSide + '"}, {"lines":[%s]}';
      dmRaw:
        Begin
        End;
    End;
    A := 0;
    vRecNo := 1; // pr-19/08/2020
    {$IFDEF RESTDWLINUX}  // aqui para linux tem que ser diferente o rastrwio da query
    For A := 0 To bValue.Recordcount - 1 Do
    Begin
      Case DataModeD Of
        dmDataware:
          Begin
            If vRecNo = 1 Then // pr-19/08/2020
              vLines := Format('{"line%d":[%s]}', [A, GenerateLine])
            Else
              vLines := vLines + Format(', {"line%d":[%s]}', [A, GenerateLine]);
          End;
        dmRaw:
          Begin
            If vRecNo = 1 Then // pr-19/08/2020
              vLines := Format('{%s}', [GenerateLine])
            Else
              vLines := vLines + Format(', {%s}', [GenerateLine]);
          End;
      End;
      If DWJSONType <> TRESTDWJSONArrayType Then // Roniery-04/09/2022
        Break;
      bValue.Next;
      Inc(vRecNo); // pr-19/08/2020
    End;
    {$ELSE}
    While Not bValue.Eof Do
    Begin
      Case DataModeD Of
        dmDataware:
          Begin
            If vRecNo = 1 Then // pr-19/08/2020
              vLines := Format('{"line%d":[%s]}', [A, GenerateLine])
            Else
              vLines := vLines + Format(', {"line%d":[%s]}', [A, GenerateLine]);
          End;
        dmRaw:
          Begin
            If vRecNo = 1 Then // pr-19/08/2020
              vLines := Format('{%s}', [GenerateLine])
            Else
              vLines := vLines + Format(', {%s}', [GenerateLine]);
          End;
      End;
      If DWJSONType <> TRESTDWJSONArrayType Then
        Break;
      bValue.Next;
      Inc(A);
      Inc(vRecNo); // pr-19/08/2020
    End;
    {$ENDIF}
    Case DataModeD Of
      dmDataware:
        Begin
          If vEncoding = esUtf8 Then
            Result := Format(Result, [vLines])
          Else
            {$IFDEF RESTDWFMX}
            Result := Format(Result, [vLines]);
            {$ELSE}
            Result := Format(Result, [AnsiString(vLines)]);
          {$ENDIF}
        End;
      dmRaw:
        Begin
          If vtagName <> '' Then
            Result := Format('{"%s": [%s]}', [vtagName, vLines])
          Else
            Result := Format('[%s]', [vLines]);
        End;
    End;
    if not bValue.IsUniDirectional then
      bValue.First;
  Finally
    bValue.EnableControls;
  End;
End;

Function TJSONValue.EncodedString: String;
Begin
  If vEncoded Then
    Result := 'true'
  Else
    Result := 'false';
End;

Procedure TJSONValue.SetEncoding(bValue: TEncodeSelect);
Begin
  vEncoding := bValue;
  {$IFDEF RESTDWLAZARUS}
  Case vEncoding Of
    esASCII:
      vEncodingLazarus := TEncoding.ANSI;
    esUtf8:
      vEncodingLazarus := TEncoding.UTF8;
  End;
  {$ENDIF}
End;

Procedure TJSONValue.aNewFieldList;
Begin

End;

Function TJSONValue.GetNewFieldList: TProcedureEvent;
Begin
  Result := Nil;
  If Assigned(vNewFieldList) Then
    Result := vNewFieldList
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aNewFieldList;
    {$ELSE}
    Result := aNewFieldList;
    {$ENDIF}
  End;
End;

Function TJSONValue.GetNewDataField: TNewDataField;
Begin
  Result := Nil;
  If Assigned(vNewDataField) Then
    Result := vNewDataField
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aNewDataField;
    {$ELSE}
    Result := aNewDataField;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.aNewDataField(FieldDefinition: TFieldDefinition);
Begin

End;

Function TJSONValue.GetFieldExist: TFieldExist;
Begin
  Result := Nil;
  If Assigned(vFieldExist) Then
    Result := vFieldExist
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aFieldExist;
    {$ELSE}
    Result := aFieldExist;
    {$ENDIF}
  End;
End;

Function TJSONValue.aFieldExist(Const Dataset: TDataset; Value: String): TField;
Var
  I: Integer;
Begin
  Result := Nil;
  For I := 0 To Dataset.Fields.Count - 1 Do
  Begin
    If Uppercase(Value) = Uppercase(Dataset.Fields[I].FieldName) Then
    Begin
      Result := Dataset.Fields[I];
      Break;
    End;
  End;
End;

Function TJSONValue.GetCreateDataSet: TProcedureEvent;
Begin
  Result := Nil;
  If Assigned(vCreateDataset) Then
    Result := vCreateDataset
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aCreateDataSet;
    {$ELSE}
    Result := aCreateDataSet;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.aCreateDataSet;
Begin

End;

Procedure TJSONValue.aSetInitDataset(Const Value: Boolean);
Begin

End;

Function TJSONValue.GetSetInitDataset: TSetInitDataset;
Begin
  Result := Nil;
  If Assigned(vSetInitDataset) Then
    Result := vSetInitDataset
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aSetInitDataset;
    {$ELSE}
    Result := aSetInitDataset;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetRecordCount(aJsonCount, aRecordCount: Integer);
Begin

End;

Function TJSONValue.GetSetRecordCount: TSetRecordCount;
Begin
  Result := Nil;
  If Assigned(vSetRecordCount) Then
    Result := vSetRecordCount
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aSetRecordCount;
    {$ELSE}
    Result := aSetRecordCount;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetnotrepage(Value: Boolean);
Begin

End;

Function TJSONValue.GetSetnotrepage: TSetnotrepage;
Begin
  Result := Nil;
  If Assigned(vSetnotrepage) Then
    Result := vSetnotrepage
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aSetnotrepage;
    {$ELSE}
    Result := aSetnotrepage;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetInDesignEvents(Const Value: Boolean);
Begin

End;

Function TJSONValue.GetSetInDesignEvents: TSetInitDataset;
Begin
  Result := Nil;
  If Assigned(vSetInDesignEvents) Then
    Result := vSetInDesignEvents
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aSetInDesignEvents;
    {$ELSE}
    Result := aSetInDesignEvents;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetInBlockEvents(Const Value: Boolean);
Begin
  vInBlockEvents := Value;
End;

Function TJSONValue.GetSetInBlockEvents: TSetInitDataset;
Begin
  Result := Nil;
  If Assigned(vSetInBlockEvents) Then
    Result := vSetInBlockEvents
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aSetInBlockEvents;
    {$ELSE}
    Result := aSetInBlockEvents;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.aSetInactive(Const Value: Boolean);
Begin
  vInactive := Value;
End;

Function TJSONValue.GetSetInactive: TSetInitDataset;
Begin
  Result := Nil;
  If Assigned(vSetInactive) Then
    Result := vSetInactive
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aSetInactive;
    {$ELSE}
    Result := aSetInactive;
    {$ENDIF}
  End;
End;

Function TJSONValue.aFieldListCount: Integer;
Begin
  Result := 0;
End;

Function TJSONValue.GetFieldListCount: TFieldListCount;
Begin
  Result := Nil;
  If Assigned(vFieldListCount) Then
    Result := vFieldListCount
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aFieldListCount;
    {$ELSE}
    Result := aFieldListCount;
    {$ENDIF}
  End;
End;

Class Function TJSONValue.FieldDefExist(Const Dataset: TDataset; Value: String)
  : TFieldDef;
Var
  I: Integer;
Begin
  Result := Nil;
  For I := 0 to Dataset.FieldDefs.Count - 1 Do
  Begin
    If Uppercase(Dataset.FieldDefs[I].Name) = Uppercase(Value) Then
    Begin
      Result := Dataset.FieldDefs[I];
      Break;
    End;
  End;
End;

Function TJSONValue.aGetInDesignEvents: Boolean;
Begin
  Result := False;
End;

Function TJSONValue.GetGetInDesignEvents: TGetInDesignEvents;
Begin
  Result := Nil;
  If Assigned(vGetInDesignEvents) Then
    Result := vGetInDesignEvents
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aGetInDesignEvents;
    {$ELSE}
    Result := aGetInDesignEvents;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.aPrepareDetailsNew;
Begin

End;

Function TJSONValue.GetPrepareDetailsNew: TProcedureEvent;
Begin
  Result := Nil;
  If Assigned(vPrepareDetailsNew) Then
    Result := vPrepareDetailsNew
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aPrepareDetailsNew;
    {$ELSE}
    Result := aPrepareDetailsNew;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.aPrepareDetails(ActiveMode: Boolean);
Begin

End;

Function TJSONValue.GetPrepareDetails: TPrepareDetails;
Begin
  Result := Nil;
  If Assigned(vPrepareDetails) Then
    Result := vPrepareDetails
  Else
  Begin
    {$IFDEF RESTDWLAZARUS}
    Result := @aPrepareDetails;
    {$ELSE}
    Result := aPrepareDetails;
    {$ENDIF}
  End;
End;

Procedure TJSONValue.ExecSetInactive(Value: Boolean);
Var
  vLocSetInactive: TSetInitDataset;
Begin
  vLocSetInactive := SetInactive;
  vLocSetInactive(Value);
End;

Procedure TJSONValue.SetFieldsList(Value: TFieldsList);
Var
  I: Integer;
Begin
  ClearFieldList;
  SetLength(vFieldsList, Length(Value));
  For I := 0 To Length(Value) - 1 Do
  Begin
    vFieldsList[I] := TFieldDefinition.Create;
    vFieldsList[I].FieldName := Value[I].FieldName;
    vFieldsList[I].DataType := Value[I].DataType;
    vFieldsList[I].Size := Value[I].Size;
    vFieldsList[I].Precision := Value[I].Precision;
    vFieldsList[I].Required := Value[I].Required;
  End;
End;

Procedure TJSONValue.ClearFieldList;
Var
  I: Integer;
Begin
  For I := 0 To Length(vFieldsList) - 1 Do
  Begin
    If Assigned(vFieldsList[I]) Then
      FreeAndNil(vFieldsList[I]);
  End;
  SetLength(vFieldsList, 0);
End;

Function TJSONValue.AsString: String;
Begin
  Result := GetValue(False);
  If VarIsNull(Result) Then
    Exit;
  {$IF Defined(RESTDWLAZARUS)}
  Result := GetStringDecode(Result, vDatabaseCharSet);
  {$ELSEIF not Defined(DELPHI2009UP)}
  Result := UTF8Decode(Result);
  If vEncoding = esUtf8 Then
    Result := UTF8Decode(Result);
  {$IFEND}
End;

Procedure TJSONValue.Clear;
Begin
  vNullValue := True;
  SetValue('');
  ClearFieldList;
End;

Procedure TJSONValue.ToStream(Var bValue: TMemoryStream);
Begin
  If Length(aValue) > 0 Then
  Begin
    bValue := TMemoryStream.Create;
    bValue.Write(aValue[0], -1);
  End
  Else
    bValue := Nil;
End;

Procedure TJSONValue.LoadFromDataset(TableName: String; bValue: TDataset;
  EncodedValue: Boolean = True; DataModeD: TDataMode = dmDataware;
  DateTimeFormat: String = ''; DelimiterFormat: String = '';
  {$IFDEF RESTDWLAZARUS}
  CharSet: TDatabaseCharSet = csUndefined;
  {$ENDIF}
  DataType: Boolean = False; HeaderLowercase: Boolean = False);
Var
  vTagGeral: String;
  {$IFNDEF DELPHIXEUP}
  vSizeChar: Integer;
  {$ENDIF}
Begin
  // Recebe o parametro "DataType" para fazer a tipagem na função que gera a linha "GenerateLine"
  // Tiago Istuque - Por Nemi Vieira - 29/01/2019
  vDataType := DataType;
  vTypeObject := toDataset;
  vObjectDirection := odINOUT;
  vObjectValue := ovDataset;
  vEncoded := EncodedValue;
  If (DataModeD = dmDataware) And (Trim(TableName) = '') Then
    TableName := 'rdwtable';
  vtagName := Lowercase(TableName);
  {$IFDEF RESTDWLAZARUS}
  If CharSet <> csUndefined Then
    DatabaseCharSet := CharSet;
  {$ENDIF}
  vTagGeral := DatasetValues(bValue, DateTimeFormat, DataModeD, DelimiterFormat,
    HeaderLowercase);
  {$IFDEF RESTDWLAZARUS}
  If vEncodingLazarus = Nil Then
    SetEncoding(vEncoding);
  If vEncoding = esUtf8 Then
    aValue := TRESTDWBytes(vEncodingLazarus.GetBytes(vTagGeral))
  Else
    aValue := stringTobytes(vTagGeral);
  {$ELSE}
  {$IFDEF DELPHIXEUP}
  aValue := stringTobytes(vTagGeral);
  {$ELSE}
  vSizeChar := 1;
  If vEncoding = esUtf8 Then
    vSizeChar := 2;
  SetLength(aValue, Length(vTagGeral) * vSizeChar);
  move(AnsiString(vTagGeral)[InitStrPos], pByteArray(aValue)^,
    Length(vTagGeral) * vSizeChar);
  {$ENDIF}
  {$ENDIF}
  vDataMode := DataModeD;
  vNullValue := Length(aValue) = 0;
End;

Procedure TJSONValue.LoadFromDataset(TableName: String;
  bValue, bDetail: TDataset; DetailType: TRESTDWJSONType = TRESTDWJSONArrayType;
  DetailElementName: String = 'detail'; EncodedValue: Boolean = True;
  DataModeD: TDataMode = dmDataware; DateTimeFormat: String = '';
  DelimiterFormat: String = '';
  {$IFDEF RESTDWLAZARUS}
  CharSet: TDatabaseCharSet = csUndefined;
  {$ENDIF}
  DataType: Boolean = False; HeaderLowercase: Boolean = False);
Var
  vTagGeral, vVirtualValue: String;
  {$IFNDEF DELPHIXEUP}
  vSizeChar: Integer;
  {$ENDIF}
Begin
  // Recebe o parametro "DataType" para fazer a tipagem na função que gera a linha "GenerateLine"
  // Tiago Istuque - Por Nemi Vieira - 29/01/2019
  vDataType := DataType;
  vTypeObject := toDataset;
  vObjectDirection := odINOUT;
  vObjectValue := ovDataset;
  vEncoded := EncodedValue;
  If (DataModeD = dmDataware) And (Trim(TableName) = '') Then
    TableName := 'rdwtable';
  vtagName := Lowercase(TableName);
  {$IFDEF RESTDWLAZARUS}
  If CharSet <> csUndefined Then
    DatabaseCharSet := CharSet;
  {$ENDIF}
  If DetailType = TRESTDWJSONArrayType Then
    vVirtualValue := Format('"%s":', [DetailElementName])
  Else
    vVirtualValue := Format('"%s":', [DetailElementName]);
  vTagGeral := DatasetValues(bValue, DateTimeFormat, DataModeD, DelimiterFormat,
    HeaderLowercase, vVirtualValue, DetailType, bDetail);
  {$IFDEF RESTDWLAZARUS}
  If vEncodingLazarus = Nil Then
    SetEncoding(vEncoding);
  If vEncoding = esUtf8 Then
    aValue := TRESTDWBytes(vEncodingLazarus.GetBytes(vTagGeral))
  Else
    aValue := stringTobytes(vTagGeral);
  {$ELSE}
  {$IFDEF DELPHIXEUP}
  aValue := stringTobytes(vTagGeral);
  {$ELSE}
  vSizeChar := 1;
  If vEncoding = esUtf8 Then
  Begin
    vSizeChar := 2;
    SetLength(aValue, Length(vTagGeral) * vSizeChar);
    move(vTagGeral[InitStrPos], pByteArray(aValue)^, Length(aValue));
  End
  Else
  Begin
    SetLength(aValue, Length(vTagGeral) * vSizeChar);
    move(AnsiString(vTagGeral)[InitStrPos], pByteArray(aValue)^,
      Length(vTagGeral) * vSizeChar);
  End;
  {$ENDIF}
  {$ENDIF}
  vDataMode := DataModeD;
  vNullValue := Length(aValue) = 0;
End;

Procedure TJSONValue.WriteToFieldDefs(JSONValue: String;
  Const ResponseTranslator: TRESTDWResponseTranslator);
  Function ReadFieldDefs(JSONObject, ElementRoot: String;
    ElementRootIndex: Integer): String;
  Var
    bJsonValueB, bJsonValue: TRESTDWJSONInterfaceObject;
    A: Integer;
    vDWFieldDef: TRESTDWFieldDef;
    vStringData, vStringDataB: String;
  Begin
    Result := '';
    bJsonValue := TRESTDWJSONInterfaceObject.Create(JSONObject);
    Try
      If bJsonValue.PairCount > 0 Then
      Begin
        Result := JSONObject;
        If ResponseTranslator.FieldDefs.Count = 0 Then
        Begin
          For A := 0 To bJsonValue.PairCount - 1 Do
          Begin
            If (ElementRoot <> '') or (JSONObject[InitStrPos] = '[') Then
            Begin
              If (Uppercase(ElementRoot) = Uppercase(bJsonValue.pairs[A].Name))
                or (JSONObject[InitStrPos] = '[') Then
              Begin
                vStringData := bJsonValue.pairs[A].Value;
                bJsonValueB := TRESTDWJSONInterfaceObject.Create(vStringData);
                If (JSONObject[InitStrPos] <> '[') Then
                  vStringDataB := vStringData
                Else
                  vStringDataB := JSONObject;
                While bJsonValueB.ClassType = TRESTDWJSONInterfaceArray Do
                Begin
                  vStringData := bJsonValueB.pairs[0].Value;
                  bJsonValueB.Free;
                  bJsonValueB := TRESTDWJSONInterfaceObject.Create(vStringData);
                  If bJsonValueB.ClassType = TRESTDWJSONInterfaceArray Then
                    vStringDataB := vStringData;
                End;
                bJsonValueB.Free;
                Result := vStringDataB;
                ReadFieldDefs(vStringData, '', -1);
                Exit;
              End;
            End
            Else
            Begin
              If ResponseTranslator.FieldDefs.FieldDefByName
                [bJsonValue.pairs[A].Name] = Nil Then
              Begin
                vDWFieldDef :=
                  TRESTDWFieldDef(ResponseTranslator.FieldDefs.Add);
                vDWFieldDef.ElementName := bJsonValue.pairs[A].Name;
                vDWFieldDef.ElementIndex := A;
                vDWFieldDef.FieldName := vDWFieldDef.ElementName;
                vDWFieldDef.FieldSize := Length(bJsonValue.pairs[A].Value);
                vDWFieldDef.DataType := ovString;
              End;
            End;
          End;
        End;
      End;
    Finally
      bJsonValue.Free;
    End;
  End;

Var
  bJsonValue: TRESTDWJSONInterfaceObject;
Begin
  bJsonValue := TRESTDWJSONInterfaceObject.Create(JSONValue);
  Try
    If bJsonValue.PairCount > 0 Then
      ReadFieldDefs(JSONValue, ResponseTranslator.ElementRootBaseName,
        ResponseTranslator.ElementRootBaseIndex);
  Finally
    FreeAndNil(bJsonValue);
  End;
End;

procedure TJSONValue.WriteToDataset2(JSONValue: String; DestDS: TDataset);
Var
  FieldsValidate: Array of TFieldNotifyEvent;
  FieldsChange: Array of TFieldNotifyEvent;
  FieldsReadOnly: Array of Boolean;
  bJsonOBJB, bJsonOBJ, FieldJson: TRESTDWJSONInterfaceBase;
  bJsonValue: TRESTDWJSONInterfaceObject;
  bJsonOBJTemp, DataSetJson, FieldsJson, LinesJson: TRESTDWJSONInterfaceArray;
  J, I: Integer;
  FieldDef: TFieldDef;
  vBlobStream: TMemoryStream;
  vTempValue: String;
  sFieldName: string;
  // vFieldDefinition: TFieldDefinition;
  AbortProcess: Boolean;
Begin
  vFieldDefinition := Nil;
  bJsonOBJB := Nil;
  bJsonOBJ := Nil;
  FieldJson := Nil;
  bJsonValue := Nil;
  bJsonOBJTemp := Nil;
  DataSetJson := Nil;
  FieldsJson := Nil;
  LinesJson := Nil;
  vBlobStream := Nil;
  AbortProcess := False;
  If JSONValue = '' Then
    Exit;
  Try
    If Pos('[', JSONValue) = 0 Then
      Exit;
    bJsonValue := TRESTDWJSONInterfaceObject.Create(JSONValue);
    If bJsonValue.PairCount > 0 Then
    Begin
      vTypeObject := GetObjectName(bJsonValue.pairs[0].Value);
      vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
      vEncoded := GetBooleanFromString(bJsonValue.pairs[2].Value);
      vObjectValue := GetValueType(bJsonValue.pairs[3].Value);
      vtagName := Lowercase(bJsonValue.pairs[4].Name);
      DestDS.DisableControls;
      If DestDS.Active Then
        DestDS.Close;
      DataSetJson := TRESTDWJSONInterfaceArray
        (bJsonValue.openArray(bJsonValue.pairs[4].Name));
      bJsonOBJ := DataSetJson.GetObject(0);
      FieldsJson := TRESTDWJSONInterfaceObject(bJsonOBJ)
        .openArray(TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[0].Name);
      FreeAndNil(bJsonOBJ);
      vFieldDefinition := TFieldDefinition.Create;
      If DestDS.Fields.Count = 0 Then
        DestDS.FieldDefs.Clear;
      For J := 0 To DestDS.Fields.Count - 1 Do
        DestDS.Fields[J].Required := False;
      DestDS.FieldDefs.BeginUpdate;
      if (not DestDS.Active) and (DestDS.FieldCount = 0) then
      begin
        For J := 0 To FieldsJson.ElementCount - 1 Do
        Begin
          FieldJson := FieldsJson.GetObject(J);
          Try
            sFieldName := Trim(TRESTDWJSONInterfaceObject(FieldJson)
              .pairs[0].Value);
            If Trim(sFieldName) <> '' Then
            Begin
              FieldDef := DestDS.FieldDefs.AddFieldDef;
              // FieldDef.Name := sFieldName;
              If vEncoding = esUtf8 Then
              Begin
                {$IFDEF RESTDWLAZARUS}
                FieldDef.Name := PWidechar(UTF8Decode(sFieldName));
                {$ELSE}
                FieldDef.Name := UTF8Decode(sFieldName);
                {$ENDIF}
              End
              Else
                FieldDef.Name := vTempValue;
              FieldDef.DataType :=
                GetFieldType(TRESTDWJSONInterfaceObject(FieldJson)
                .pairs[1].Value);
              If Not(FieldDef.DataType in [ftFloat, ftCurrency
                {$IFDEF DELPHIXEUP}, ftExtended, ftSingle
                {$ENDIF}]) Then
                FieldDef.Size := StrToInt(TRESTDWJSONInterfaceObject(FieldJson)
                  .pairs[4].Value)
              Else
                FieldDef.Size := 0;
              If (FieldDef.DataType In [ftCurrency, ftBCD,
                {$IFDEF DELPHIXEUP}ftExtended, ftSingle,
                {$ENDIF} ftFMTBcd]) Then
                FieldDef.Precision :=
                  StrToInt(TRESTDWJSONInterfaceObject(FieldJson).pairs[5].Value)
              Else If (FieldDef.DataType = ftFloat) Then
                FieldDef.Precision :=
                  StrToInt(TRESTDWJSONInterfaceObject(FieldJson)
                  .pairs[5].Value);
              FieldDef.Required := TRESTDWJSONInterfaceObject(FieldJson)
                .pairs[3].Value = 'S';
            End;
          Finally
            FreeAndNil(FieldJson);
          End;
        End;
        if Assigned(vFieldDefinition) then
          FreeAndNil(vFieldDefinition);
        DestDS.FieldDefs.EndUpdate;
      end;

      If Not DestDS.Active Then
        DestDS.Open;
      If Not DestDS.Active Then
      Begin
        bJsonValue.Free;
        Raise Exception.Create(cErrorParsingJSON);
        Exit;
      End;

      { Reservando as propriedades ReadOnly, OnValidate e OnChange de cada TField }
      for I := 0 to DestDS.FieldCount - 1 do
      begin
        SetLength(FieldsValidate, Length(FieldsValidate) + 1);
        FieldsValidate[High(FieldsValidate)] := DestDS.Fields[I].OnValidate;
        DestDS.Fields[I].OnValidate := nil;

        SetLength(FieldsChange, Length(FieldsChange) + 1);
        FieldsValidate[High(FieldsChange)] := DestDS.Fields[I].OnChange;
        DestDS.Fields[I].OnChange := nil;

        SetLength(FieldsReadOnly, Length(FieldsReadOnly) + 1);
        FieldsReadOnly[High(FieldsReadOnly)] := DestDS.Fields[I].ReadOnly;
        DestDS.Fields[I].ReadOnly := False;
      end;

      { Loop no dataset }
      FreeAndNil(bJsonOBJ);
      bJsonOBJ := DataSetJson.GetObject(0);
      FreeAndNil(FieldsJson);
      FieldsJson := TRESTDWJSONInterfaceObject(bJsonOBJ)
        .openArray(TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[0].Name);

      FreeAndNil(bJsonOBJ);
      bJsonOBJ := FieldsJson.GetObject(0);
      FreeAndNil(LinesJson);
      bJsonOBJ := DataSetJson.GetObject(1);
      LinesJson := TRESTDWJSONInterfaceArray(TRESTDWJSONInterfaceArray(bJsonOBJ)
        .GetObject(0));

      For J := 0 To LinesJson.ElementCount - 1 Do
      Begin
        bJsonOBJB := TRESTDWJSONInterfaceArray(LinesJson).GetObject(J);
        bJsonOBJTemp := TRESTDWJSONInterfaceObject(bJsonOBJB)
          .openArray(TRESTDWJSONInterfaceObject(bJsonOBJB).pairs[0].Name);
        DestDS.Append;
        Try
          For I := 0 To FieldsJson.ElementCount - 1 Do
          Begin
            FieldJson := FieldsJson.GetObject(I);
            sFieldName := Trim(TRESTDWJSONInterfaceObject(FieldJson)
              .pairs[0].Value);
            If Assigned(bJsonOBJB) Then
              FreeAndNil(bJsonOBJB);
            bJsonOBJB := bJsonOBJTemp.GetObject(I);
            if TRESTDWJSONInterfaceObject(bJsonOBJB).pairs[0].IsNull then
            Begin
              FreeAndNil(bJsonOBJB);
              Continue;
            End;
            vTempValue := TRESTDWJSONInterfaceObject(bJsonOBJB).pairs[0].Value;
            If DestDS.FieldByName(sFieldName).DataType
              In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
              ftDataSet, ftBlob, ftOraBlob, ftOraClob
            {$IFDEF DELPHIXEUP}, ftParams, ftStream{$ENDIF}] Then
            Begin
              If (vTempValue <> 'null') And (vTempValue <> '') Then
              Begin
                // HexStringToStream(vTempValue, vBlobStream);
                vBlobStream := DecodeStream(vTempValue);
                Try
                  vBlobStream.Position := 0;
                  TBlobField(DestDS.FieldByName(sFieldName))
                    .LoadFromStream(vBlobStream);
                Finally
                  {$IFDEF DELPHIXEUP}
                  vBlobStream.Clear;
                  {$ENDIF}
                  FreeAndNil(vBlobStream);
                End;
              End;
            End
            Else
            Begin
              If (Lowercase(vTempValue) <> 'null') Then
              Begin
                If DestDS.FieldByName(sFieldName).DataType
                  in [ftString, ftWideString,
                {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                {$IFEND}{$ELSE}ftWideMemo,
                {$ENDIF}ftMemo, ftFmtMemo, ftFixedChar, ftGuid] Then
                Begin
                  If vTempValue = '' Then
                    DestDS.FieldByName(sFieldName).Value := ''
                  Else
                  Begin
                    If vEncoded Then
                      DestDS.FieldByName(sFieldName).Value :=
                        DecodeStrings(vTempValue{$IFDEF RESTDWLAZARUS},
                        vDatabaseCharSet{$ENDIF})
                    Else
                      DestDS.FieldByName(sFieldName).Value := vTempValue;
                  End;
                End
                Else If (vTempValue <> '') then
                  SetValueA(DestDS.FieldByName(sFieldName), vTempValue);
              End;
            End;
            FreeAndNil(bJsonOBJB);
          End;
        Finally
          vTempValue := '';
        End;
        FreeAndNil(bJsonOBJTemp);
        FreeAndNil(bJsonOBJB);
        DestDS.Post;
        If Assigned(vOnWriterProcess) Then
          vOnWriterProcess(DestDS, J + 1, LinesJson.ElementCount, AbortProcess);
        If AbortProcess Then
          Break;
      End;
      { Devolvendo as propriedades ReadOnly, OnValidate e OnChange de cada TField }
      for I := 0 to DestDS.FieldCount - 1 do
      begin
        DestDS.Fields[I].OnValidate := FieldsValidate[I];
        DestDS.Fields[I].OnChange := FieldsChange[I];
        DestDS.Fields[I].ReadOnly := FieldsReadOnly[I];
      end;
    End
    Else
    Begin
      DestDS.Close;
      Raise Exception.Create(cErrorInvalidJSONData);
    End;
  Finally
    FreeAndNil(bJsonOBJ);
    FreeAndNil(FieldsJson);
    FreeAndNil(DataSetJson);
    FreeAndNil(bJsonValue);
    If DestDS.Active Then
      DestDS.First;
    DestDS.EnableControls;
  End;
End;

procedure TJSONValue.WriteToDataset(JSONValue: String; const DestDS: TDataset);
Var
  FieldValidate: TFieldNotifyEvent;
  bJsonValue, bJsonValueB, bJsonValueC: TRESTDWJSONInterfaceObject;
  bJsonArrayB: TRESTDWJSONInterfaceArray;
  ListFields: TStringList;
  A, J, I, Z: Integer;
  vBlobStream: TMemoryStream;
  vTempValueJSONB, vTempValueJSON, vTempValue: String;
  AbortProcess, vOldReadOnly, vFindFlag: Boolean;
  bJsonOBJB, bJsonOBJ: TRESTDWJSONInterfaceBase;
Begin
  vFieldDefinition := Nil;
  bJsonValue := Nil;
  bJsonValueB := Nil;
  bJsonValueC := Nil;
  bJsonArrayB := Nil;
  bJsonOBJB := Nil;
  bJsonOBJ := Nil;
  vBlobStream := Nil;
  AbortProcess := False;
  If (Trim(JSONValue) = '') or (Trim(JSONValue) = '{}') or
    (Trim(JSONValue) = '[]') Then // Ico Menezes - Tratar Erros de JsonVazio
    Exit;
  ListFields := TStringList.Create;
  bJsonValueB := Nil;
  bJsonValue := TRESTDWJSONInterfaceObject.Create(JSONValue);
  Try
    If bJsonValue.PairCount > 0 Then
    Begin
      DestDS.DisableControls;
      If DestDS.Active Then
        DestDS.Close;
      vTempValueJSON := JSONValue;
      Try
        Inactive := True;
        If Not DestDS.Active Then
          DestDS.Open;
        If Not DestDS.Active Then
        Begin
          FreeAndNil(bJsonValue);
          FreeAndNil(ListFields);
          Raise Exception.Create(cErrorParsingJSON);
          Exit;
        End;
        bJsonValueB := TRESTDWJSONInterfaceObject.Create(vTempValueJSON);
        For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
        Begin
          vFindFlag := False;
          If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
            If DestDS.FindField(DestDS.Fields[A].FieldName)
              .FieldKind = fkData Then
            Begin
              If bJsonValueB.ClassType = TRESTDWJSONInterfaceObject Then
              Begin
                For J := 0 To bJsonValueB.PairCount - 1 Do
                Begin
                  vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name))
                    = Uppercase(DestDS.Fields[A].FieldName);
                  If vFindFlag Then
                  Begin
                    ListFields.Add(IntToStr(J));
                    Break;
                  End;
                  // FreeAndNil(bJsonOBJ);
                End;
              End
              Else If bJsonValueB.ClassType = TRESTDWJSONInterfaceArray Then
              // Enviado poir Rylan (Genesys Sistemas)
              Begin
                bJsonValueC := Nil;
                For Z := 0 to TRESTDWJSONInterfaceObject(bJsonValueB)
                  .PairCount - 1 do
                Begin
                  vTempValueJSONB := TRESTDWJSONInterfaceObject(bJsonValueB)
                    .pairs[Z].Value;
                  If (vTempValueJSONB[InitStrPos] = '{') Or
                    (vTempValueJSONB[InitStrPos] = '[') Then
                    bJsonValueC := TRESTDWJSONInterfaceObject.Create
                      (vTempValueJSONB);
                  If Assigned(bJsonValueC) Then
                    If bJsonValueC.PairCount = DestDS.Fields.Count Then
                      Break;
                  vTempValueJSONB := EmptyStr;
                End;
                If Assigned(bJsonValueC) Then
                  FreeAndNil(bJsonValueC);
                If vTempValueJSONB = EmptyStr then
                  vTempValueJSONB := TRESTDWJSONInterfaceObject(bJsonValueB)
                    .pairs[0].Value;
                If (vTempValueJSONB[InitStrPos] = '{') Or
                  (vTempValueJSONB[InitStrPos] = '[') Then
                Begin
                  bJsonValueB.Free;
                  bJsonValueB := TRESTDWJSONInterfaceObject.Create
                    (vTempValueJSONB);
                End;
                For J := 0 To bJsonValueB.PairCount - 1 Do
                Begin
                  If Trim(bJsonValueB.pairs[J].Name) <> '' Then
                  Begin
                    vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name))
                      = Uppercase(DestDS.Fields[A].FieldName);
                    If vFindFlag Then
                    Begin
                      ListFields.Add(IntToStr(J));
                      Break;
                    End;
                  End;
                  FreeAndNil(bJsonOBJ);
                End;
              End;
            End;
          If Not vFindFlag Then
            ListFields.Add('-1');
        End;
        bJsonValueB.Free;
        bJsonValueB := TRESTDWJSONInterfaceObject.Create(vTempValueJSON);
        If bJsonValueB.ClassType = TRESTDWJSONInterfaceObject Then
        Begin
          DestDS.Append;
          Try
            For I := 0 To DestDS.Fields.Count - 1 Do
            Begin
              vOldReadOnly := DestDS.Fields[I].ReadOnly;
              FieldValidate := DestDS.Fields[I].OnValidate;
              DestDS.Fields[I].OnValidate := Nil;
              DestDS.Fields[I].ReadOnly := False;
              If DestDS.Fields[I].FieldKind = fkLookup Then
              Begin
                DestDS.Fields[I].ReadOnly := vOldReadOnly;
                DestDS.Fields[I].OnValidate := FieldValidate;
                Continue;
              End;
              If (I >= ListFields.Count) Then
              Begin
                DestDS.Fields[I].ReadOnly := vOldReadOnly;
                DestDS.Fields[I].OnValidate := FieldValidate;
                Continue;
              End;
              If (StrToInt(ListFields[I]) = -1) Or
                Not(DestDS.Fields[I].FieldKind = fkData) Or
                (StrToInt(ListFields[I]) = -1) Then
              Begin
                DestDS.Fields[I].ReadOnly := vOldReadOnly;
                DestDS.Fields[I].OnValidate := FieldValidate;
                Continue;
              End;
              // FreeAndNil(bJsonOBJB);
              vTempValue := bJsonValueB.pairs[StrToInt(ListFields[I])].Value;
              If DestDS.Fields[I].DataType In [ftGraphic, ftParadoxOle,
                ftDBaseOle, ftTypedBinary, ftCursor, ftDataSet, ftBlob,
                ftOraBlob, ftOraClob
              {$IFDEF DELPXEUP}, ftParams, ftStream{$ENDIF}] Then
              Begin
                If (vTempValue <> 'null') And (vTempValue <> '') Then
                Begin
                  // HexStringToStream(vTempValue, vBlobStream);
                  vBlobStream := DecodeStream(vTempValue);
                  Try
                    vBlobStream.Position := 0;
                    TBlobField(DestDS.Fields[I]).LoadFromStream(vBlobStream);
                  Finally
                    {$IFDEF DELPXEUP}
                    vBlobStream.Clear;
                    {$ENDIF}
                    FreeAndNil(vBlobStream);
                  End;
                End;
              End
              Else
              Begin
                If (Lowercase(vTempValue) <> 'null') Then
                Begin
                  If DestDS.Fields[I].DataType in [ftString, ftWideString,
                  {$IFDEF DELPXEUP}ftWideMemo, {$ENDIF}
                  ftMemo, ftFmtMemo, ftFixedChar] Then
                  Begin
                    If vTempValue = '' Then
                      DestDS.Fields[I].AsString := ''
                    Else
                    Begin
                      // If vEncoded Then
                      // DestDS.Fields[i].AsString := DecodeStrings(vTempValue{$IFDEF RESTDWLAZARUS}, vDatabaseCharSet{$ENDIF})
                      // Else
                      If vUtf8SpecialChars Then
                        vTempValue := Unescape_chars(vTempValue);
                      {$IFDEF RESTDWLAZARUS}
                      vTempValue := GetStringDecode(vTempValue,
                        vDatabaseCharSet);
                      {$ENDIF}
                      DestDS.Fields[I].AsString := vTempValue;
                    End;
                  End
                  Else If (vTempValue <> '') then
                    SetValueA(DestDS.Fields[I], vTempValue);
                End;
              End;
              DestDS.Fields[I].ReadOnly := vOldReadOnly;
              DestDS.Fields[I].OnValidate := FieldValidate;
            End;
          Finally
            vTempValue := '';
          End;
          DestDS.Post;
          If Assigned(vOnWriterProcess) Then
            vOnWriterProcess(DestDS, 1, 1, AbortProcess);
          If AbortProcess Then
            Exit;
        End
        Else
        Begin
          bJsonArrayB := TRESTDWJSONInterfaceArray(bJsonValueB);
          For J := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
            bJsonOBJB := TRESTDWJSONInterfaceArray(bJsonArrayB).GetObject(J);
            DestDS.Append;
            Try
              For I := 0 To DestDS.Fields.Count - 1 Do
              Begin
                vOldReadOnly := DestDS.Fields[I].ReadOnly;
                FieldValidate := DestDS.Fields[I].OnValidate;
                DestDS.Fields[I].OnValidate := Nil;
                DestDS.Fields[I].ReadOnly := False;
                If DestDS.Fields[I].FieldKind = fkLookup Then
                Begin
                  DestDS.Fields[I].ReadOnly := vOldReadOnly;
                  DestDS.Fields[I].OnValidate := FieldValidate;
                  Continue;
                End;
                If (I >= ListFields.Count) Then
                Begin
                  DestDS.Fields[I].ReadOnly := vOldReadOnly;
                  DestDS.Fields[I].OnValidate := FieldValidate;
                  Continue;
                End;
                If (StrToInt(ListFields[I]) = -1) Or
                  Not(DestDS.Fields[I].FieldKind = fkData) Or
                  (StrToInt(ListFields[I]) = -1) Then
                Begin
                  DestDS.Fields[I].ReadOnly := vOldReadOnly;
                  DestDS.Fields[I].OnValidate := FieldValidate;
                  Continue;
                End;
                // FreeAndNil(bJsonOBJB);
                If Not TRESTDWJSONInterfaceObject(bJsonOBJB)
                  .pairs[StrToInt(ListFields[I])].IsNull Then
                  vTempValue := TRESTDWJSONInterfaceObject(bJsonOBJB)
                    .pairs[StrToInt(ListFields[I])].Value
                  // bJsonOBJTemp.get().ToString;
                Else
                  Continue;
                If DestDS.Fields[I].DataType In [ftGraphic, ftParadoxOle,
                  ftDBaseOle, ftTypedBinary, ftCursor, ftDataSet, ftBlob,
                  ftOraBlob, ftOraClob
                {$IFDEF DELPHIXEUP}, ftParams, ftStream{$ENDIF}] Then
                Begin
                  If (vTempValue <> 'null') And (vTempValue <> '') Then
                  Begin
                    // HexStringToStream(vTempValue, vBlobStream);
                    vBlobStream := DecodeStream(vTempValue);
                    Try
                      vBlobStream.Position := 0;
                      TBlobField(DestDS.Fields[I]).LoadFromStream(vBlobStream);
                    Finally
                      {$IFDEF DELPHIXEUP}
                      vBlobStream.Clear;
                      {$ENDIF}
                      FreeAndNil(vBlobStream);
                    End;
                  End;
                End
                Else
                Begin
                  If (Lowercase(vTempValue) <> 'null') Then
                  Begin
                    If DestDS.Fields[I].DataType in [ftString, ftWideString,
                    {$IFDEF DELPHIXEUP}ftWideMemo, {$ENDIF}
                    ftMemo, ftFmtMemo, ftFixedChar] Then
                    Begin
                      If vTempValue = '' Then
                        DestDS.Fields[I].AsString := ''
                      Else
                      Begin
                        if vEncoded then
                          DestDS.Fields[I].AsString :=
                            DecodeStrings(vTempValue{$IFDEF RESTDWLAZARUS},
                            vDatabaseCharSet{$ENDIF})
                        Else
                        Begin
                          If vUtf8SpecialChars Then
                            vTempValue := Unescape_chars(vTempValue);
                          {$IFDEF RESTDWLAZARUS}
                          vTempValue := GetStringDecode(vTempValue,
                            vDatabaseCharSet);
                          {$ENDIF}
                          DestDS.Fields[I].AsString := vTempValue;
                        End;
                      End;
                    End
                    Else If DestDS.Fields[I].DataType
                      in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                    Begin
                      If DestDS.Fields[I].DataType = ftDate Then
                        SetValueA(DestDS.Fields[I],
                          IntToStr(DateTimeToUnix(StrToDateTime(vTempValue))))
                      Else if DestDS.Fields[I].DataType = ftTime then
                        SetValueA(DestDS.Fields[I],
                          IntToStr(DateTimeToUnix(StrToDateTime(vTempValue))))
                      Else
                        SetValueA(DestDS.Fields[I],
                          IntToStr(DateTimeToUnix(StrToDateTime(vTempValue))));
                    End
                    Else If (vTempValue <> '') then
                      SetValueA(DestDS.Fields[I], vTempValue);
                  End;
                End;
                DestDS.Fields[I].ReadOnly := vOldReadOnly;
                DestDS.Fields[I].OnValidate := FieldValidate;
              End;
            Finally
              vTempValue := '';
            End;
            FreeAndNil(bJsonOBJB);
            DestDS.Post;
            If Assigned(vOnWriterProcess) Then
              vOnWriterProcess(DestDS, J + 1, bJsonArrayB.ElementCount,
                AbortProcess);
            If AbortProcess Then
              Break;
          End;
        End;
      Except
      End;
    End;
  Finally
    If Assigned(ListFields) Then
      FreeAndNil(ListFields);
    If DestDS.Active Then
      DestDS.First;
    DestDS.EnableControls;
    If Assigned(bJsonValue) Then
      FreeAndNil(bJsonValue);
    If Assigned(bJsonValueB) Then
      FreeAndNil(bJsonValueB);
  End;
End;

Procedure TJSONValue.WriteToDataset(JSONValue: String; Const DestDS: TDataset;
  ResponseTranslator: TRESTDWResponseTranslator; RequestMode: TRequestMode);
Var
  FieldValidate: TFieldNotifyEvent;
  // vFieldDefinition : TFieldDefinition;
  bJsonValue, bJsonValueB, bJsonValueC: TRESTDWJSONInterfaceObject;
  bJsonArrayB: TRESTDWJSONInterfaceArray;
  ListFields: TStringList;
  A, J, I, Z: Integer;
  vBlobStream: TMemoryStream;
  vTempValueJSONB, vTempValueJSON, vTempValue: String;
  FieldDef: TFieldDef;
  Field: TField;
  AbortProcess, vOldReadOnly, vFindFlag: Boolean;
  bJsonOBJB, bJsonOBJ: TRESTDWJSONInterfaceBase;
  vLocSetInBlockEvents: TSetInitDataset;
  vLocNewDataField: TNewDataField;
  vLocFieldExist: TFieldExist;
  vLocSetRecordCount: TSetRecordCount;
  vLocSetInitDataset: TSetInitDataset;
  vLocNewFieldList, vLocCreateDataset: TProcedureEvent;
  vLocFieldListCount: TFieldListCount;
  Function ReadFieldDefs(Var vResult: String; JSONObject, ElementRoot: String;
    ElementRootIndex: Integer; InLoop: Boolean = False;
    IgnoreRules: Boolean = False): Boolean;
  Var
    bJsonValueB, bJsonValue: TRESTDWJSONInterfaceObject;
    A, I: Integer;
    vFieldDefsCreate, vFindIndex: Boolean;
    vDWFieldDef: TRESTDWFieldDef;
    vStringData, vStringDataB, vStringDataTemp: String;
  Begin
    bJsonValueB := Nil;
    bJsonValue := Nil;
    Result := False;
    If JSONObject <> '' Then
    Begin
      bJsonValue := TRESTDWJSONInterfaceObject.Create(JSONObject);
      vFindIndex := False;
      Try
        If bJsonValue.PairCount > 0 Then
        Begin
          // vResult          := JSONObject;
          vFieldDefsCreate := ResponseTranslator.FieldDefs.Count = 0;
          If Not vFieldDefsCreate Then
            vFieldDefsCreate := InLoop;
          For A := 0 To bJsonValue.PairCount - 1 Do
          Begin
            If (((ElementRoot <> '') or (JSONObject[InitStrPos] = '[')) And
              Not(IgnoreRules)) or (Not(vFieldDefsCreate)) Then
            Begin
              vResult := '';
              If (Uppercase(ElementRoot) = Uppercase(bJsonValue.pairs[A].Name))
                or (JSONObject[InitStrPos] = '[') Then
              Begin
                vFindIndex := Uppercase(ElementRoot)
                  = Uppercase(bJsonValue.pairs[A].Name);
                vStringData := bJsonValue.pairs[A].Value;
                If (JSONObject[InitStrPos] <> '[') Then
                  vStringDataB := vStringData
                Else
                  vStringDataB := JSONObject;
                If (vStringData = 'null') Or (vStringData = '') Then
                Begin
                  vStringData := '';
                  If (vStringDataB = 'null') Or (vStringDataB = '') Then
                    vStringDataB := '';
                  vResult := vStringDataB;
                End
                Else
                Begin
                  vStringDataTemp := vStringDataB;
                  bJsonValueB := TRESTDWJSONInterfaceObject.Create
                    (vStringDataTemp);
                  I := 0;
                  While (bJsonValueB <> Nil) And
                    (bJsonValueB.ClassType = TRESTDWJSONInterfaceArray) And
                    ((bJsonValueB.PairCount > 0) And
                    (I <= bJsonValueB.PairCount)) Do
                  Begin
                    vStringData := bJsonValueB.pairs[I].Value;
                    FreeAndNil(bJsonValueB);
                    If (vStringData[InitStrPos] = '{') Or
                      (vStringData[InitStrPos] = '[') Then
                      bJsonValueB := TRESTDWJSONInterfaceObject.Create
                        (vStringData)
                    Else
                    Begin
                      vStringData := vStringDataTemp;
                      IgnoreRules := True;
                      Break;
                    End;
                    Inc(I);
                  End;
                  If Assigned(bJsonValueB) Then
                    bJsonValueB.Free;
                  vResult := vStringDataTemp;
                End;
                // vResult := vStringDataB;
                If Not Result Then
                Begin
                  If vFindIndex Then
                  Begin
                    vResult := vStringDataTemp;
                    Result := ReadFieldDefs(vResult, vStringData, '', -1,
                      vFindIndex, IgnoreRules);
                  End
                  Else
                  Begin
                    Result := ReadFieldDefs(vResult, vStringData, ElementRoot,
                      -1, vFindIndex, IgnoreRules);
                    // vResult := vStringDataTemp;
                  End;
                End;
                Exit;
              End;
            End
            Else If vFieldDefsCreate Then
            Begin
              Result := True;
              vFindIndex := True;
              If ResponseTranslator.FieldDefs.FieldDefByName
                [bJsonValue.pairs[A].Name] = Nil Then
              Begin
                vDWFieldDef :=
                  TRESTDWFieldDef(ResponseTranslator.FieldDefs.Add);
                vDWFieldDef.ElementName := bJsonValue.pairs[A].Name;
                vDWFieldDef.ElementIndex := A;
                vDWFieldDef.FieldName := vDWFieldDef.ElementName;
                vDWFieldDef.FieldSize := Length(bJsonValue.pairs[A].Value);
                If vDWFieldDef.FieldSize = 0 Then
                  vDWFieldDef.FieldSize := 10;
                vDWFieldDef.DataType := ovString;
              End;
            End;
          End;
          If (ElementRoot <> '') Then
            If Not(vFindIndex) Then
            Begin
              For A := 0 To bJsonValue.PairCount - 1 Do
              Begin
                vStringDataTemp := bJsonValue.pairs[A].Value;
                Result := ReadFieldDefs(vResult, vStringDataTemp,
                  ElementRoot, -1);
                If Result Then
                  Break;
              End;
            End;
        End;
      Finally
        bJsonValue.Free;
        If Not Result Then
          If vResult = '' Then
            vResult := JSONValue;
      End;
    End;
  End;

Begin
  vFieldDefinition := Nil;
  bJsonValue := Nil;
  bJsonValueB := Nil;
  bJsonValueC := Nil;
  bJsonArrayB := Nil;
  bJsonOBJB := Nil;
  bJsonOBJ := Nil;
  vBlobStream := Nil;
  AbortProcess := False;
  vLocSetInBlockEvents := SetInBlockEvents;
  vLocNewDataField := NewDataField;
  vLocFieldExist := FieldExist;
  vLocFieldListCount := FieldListCount;
  vLocNewFieldList := NewFieldList;
  vLocCreateDataset := CreateDataset;
  vLocSetRecordCount := SetRecordCount;
  vLocSetInitDataset := SetInitDataset;
  If (Trim(JSONValue) = '') or (Trim(JSONValue) = '{}') or
    (Trim(JSONValue) = '[]') Then // Ico Menezes - Tratar Erros de JsonVazio
    Exit;
  ListFields := TStringList.Create;
  bJsonValueB := Nil;
  bJsonValue := TRESTDWJSONInterfaceObject.Create(JSONValue);
  Try
    If bJsonValue.PairCount > 0 Then
    Begin
      vLocSetInBlockEvents(True);
      DestDS.DisableControls;
      If DestDS.Active Then
        DestDS.Close;
      vTempValueJSON := JSONValue;
      If (RequestMode = rtOnlyFields) Or
        (((ResponseTranslator.ElementAutoReadRootIndex) Or
        (ResponseTranslator.ElementRootBaseName <> '') Or
        (ResponseTranslator.ElementRootBaseIndex > -1))) Then
        ReadFieldDefs(vTempValueJSON, JSONValue,
          ResponseTranslator.ElementRootBaseName,
          ResponseTranslator.ElementRootBaseIndex);
      vLocNewFieldList;
      vFieldDefinition := TFieldDefinition.Create;
      If DestDS.Fields.Count = 0 Then
        DestDS.FieldDefs.Clear;
      // Removendo campos inválidos
      For J := DestDS.Fields.Count - 1 DownTo 0 Do
      Begin
        If DestDS.Fields[J].FieldKind = fkData Then
          If ResponseTranslator.FieldDefs.FieldDefByName
            [DestDS.Fields[J].FieldName] = Nil Then
            DestDS.Fields.Remove(DestDS.Fields[J]);
      End;
      For J := 0 To DestDS.Fields.Count - 1 Do
      Begin
        vFieldDefinition.FieldName := DestDS.Fields[J].FieldName;
        vFieldDefinition.DataType := DestDS.Fields[J].DataType;
        If (vFieldDefinition.DataType <> ftFloat) Then
          vFieldDefinition.Size := DestDS.Fields[J].Size
        Else
          vFieldDefinition.Size := 0;
        If (vFieldDefinition.DataType In [ftCurrency, ftBCD,
          {$IFDEF DELPHIXEUP}ftExtended, ftSingle, {$ENDIF}
          ftFMTBcd]) Then
          vFieldDefinition.Precision := TBCDField(DestDS.Fields[J]).Precision
        Else If (vFieldDefinition.DataType = ftFloat) Then
          vFieldDefinition.Precision := TFloatField(DestDS.Fields[J]).Precision;
        vFieldDefinition.Required := DestDS.Fields[J].Required;
        vLocNewDataField(vFieldDefinition);
      End;
      For J := 0 To ResponseTranslator.FieldDefs.Count - 1 Do
      Begin
        vTempValue := Trim(ResponseTranslator.FieldDefs[J].FieldName);
        If Trim(vTempValue) <> '' Then
        Begin
          FieldDef := FieldDefExist(DestDS, vTempValue);
          If (FieldDef = Nil) Then
          Begin
            If (vLocFieldExist(DestDS, vTempValue) = Nil) Then
            Begin
              vFieldDefinition.FieldName := vTempValue;
              vFieldDefinition.DataType :=
                ObjectValueToFieldType(ResponseTranslator.FieldDefs[J]
                .DataType);
              If (vFieldDefinition.DataType <> ftFloat) Then
                vFieldDefinition.Size := ResponseTranslator.FieldDefs[J]
                  .FieldSize
              Else
                vFieldDefinition.Size := 0;
              If (vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD,
                {$IFDEF DELPHIXEUP}ftExtended, ftSingle, {$ENDIF}
                ftFMTBcd]) Then
                vFieldDefinition.Precision := ResponseTranslator.FieldDefs[J]
                  .Precision
              Else If (vFieldDefinition.DataType = ftFloat) Then
                vFieldDefinition.Precision := ResponseTranslator.FieldDefs[J]
                  .Precision;
              vFieldDefinition.Required := ResponseTranslator.FieldDefs
                [J].Required;
              vLocNewDataField(vFieldDefinition);
            End;
            FieldDef := DestDS.FieldDefs.AddFieldDef;
            If vEncoding = esUtf8 Then
            Begin
              {$IFDEF RESTDWLAZARUS}
              FieldDef.Name := vTempValue;
              {$ELSE}
              FieldDef.Name := UTF8Encode(vTempValue);
              {$ENDIF}
            End
            Else
              FieldDef.Name := vTempValue;
            // FieldDef.Name     := vTempValue;
            FieldDef.DataType := ObjectValueToFieldType
              (ResponseTranslator.FieldDefs[J].DataType);
            If FieldDef.DataType in [ftString, ftWideString] Then
              FieldDef.Size := 255;
            If Not(FieldDef.DataType in [ftFloat, ftCurrency
              {$IFDEF DELPHIXEUP}, ftExtended, ftSingle{$ENDIF}]) Then
            Begin
              If (FieldDef.Size > ResponseTranslator.FieldDefs[J].FieldSize)
              then // ajuste em 20/12/2018 Thiago Pedro
                ResponseTranslator.FieldDefs[J].FieldSize := FieldDef.Size
              Else
                FieldDef.Size := ResponseTranslator.FieldDefs[J].FieldSize;
              If FieldDef.DataType in [ftString, ftWideString] Then
                If FieldDef.Size > 4000 Then
                Begin
                  ResponseTranslator.FieldDefs[J].DataType := ovMemo;
                  FieldDef.DataType := ObjectValueToFieldType
                    (ResponseTranslator.FieldDefs[J].DataType);
                End;
            End;
            If (FieldDef.DataType In [ftFloat, ftCurrency, ftBCD,
              {$IFDEF DELPHIXEUP}ftExtended, ftSingle, {$ENDIF}
              ftFMTBcd]) Then
              FieldDef.Precision := ResponseTranslator.FieldDefs[J].Precision;
          End;
        End;
      End;
      if Assigned(vFieldDefinition) then
        FreeAndNil(vFieldDefinition);
      DestDS.FieldDefs.EndUpdate;
      Try
        vLocSetInBlockEvents(True);
        Inactive := True;
        If Assigned(vLocCreateDataset) Then
          vLocCreateDataset();
        If Not DestDS.Active Then
          DestDS.Open;
        If Not DestDS.Active Then
        Begin
          FreeAndNil(bJsonValue);
          FreeAndNil(ListFields);
          Raise Exception.Create(cErrorParsingJSON);
          Exit;
        End;
        // Add Set PK Fields
        For J := 0 To ResponseTranslator.FieldDefs.Count - 1 Do
        Begin
          If ResponseTranslator.FieldDefs[J].Required Then
          Begin
            Field := DestDS.FindField(ResponseTranslator.FieldDefs[J]
              .FieldName);
            If Field <> Nil Then
            Begin
              If Field.FieldKind = fkData Then
                Field.ProviderFlags := [pfInUpdate, pfInWhere, pfInKey]
              Else
                Field.ProviderFlags := [];
            End;
          End;
        End;
        bJsonValueB := TRESTDWJSONInterfaceObject.Create(vTempValueJSON);
        For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
        Begin
          vFindFlag := False;
          If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
            If DestDS.FindField(DestDS.Fields[A].FieldName)
              .FieldKind = fkData Then
            Begin
              If bJsonValueB.ClassType = TRESTDWJSONInterfaceObject Then
              Begin
                For J := 0 To bJsonValueB.PairCount - 1 Do
                Begin
                  vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name))
                    = Uppercase(DestDS.Fields[A].FieldName);
                  If vFindFlag Then
                  Begin
                    ListFields.Add(IntToStr(J));
                    Break;
                  End;
                  // FreeAndNil(bJsonOBJ);
                End;
              End
              Else If bJsonValueB.ClassType = TRESTDWJSONInterfaceArray Then
              // Enviado poir Rylan (Genesys Sistemas)
              Begin
                bJsonValueC := Nil;
                For Z := 0 to TRESTDWJSONInterfaceObject(bJsonValueB)
                  .PairCount - 1 do
                Begin
                  vTempValueJSONB := TRESTDWJSONInterfaceObject(bJsonValueB)
                    .pairs[Z].Value;
                  If (vTempValueJSONB[InitStrPos] = '{') Or
                    (vTempValueJSONB[InitStrPos] = '[') Then
                    bJsonValueC := TRESTDWJSONInterfaceObject.Create
                      (vTempValueJSONB);
                  If Assigned(bJsonValueC) Then
                    If bJsonValueC.PairCount = DestDS.Fields.Count Then
                      Break;
                  vTempValueJSONB := EmptyStr;
                End;
                If Assigned(bJsonValueC) Then
                  FreeAndNil(bJsonValueC);
                If vTempValueJSONB = EmptyStr then
                  vTempValueJSONB := TRESTDWJSONInterfaceObject(bJsonValueB)
                    .pairs[0].Value;
                If (vTempValueJSONB[InitStrPos] = '{') Or
                  (vTempValueJSONB[InitStrPos] = '[') Then
                Begin
                  bJsonValueB.Free;
                  bJsonValueB := TRESTDWJSONInterfaceObject.Create
                    (vTempValueJSONB);
                End;
                For J := 0 To bJsonValueB.PairCount - 1 Do
                Begin
                  If Trim(bJsonValueB.pairs[J].Name) <> '' Then
                  Begin
                    vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name))
                      = Uppercase(DestDS.Fields[A].FieldName);
                    If vFindFlag Then
                    Begin
                      ListFields.Add(IntToStr(J));
                      Break;
                    End;
                  End;
                  FreeAndNil(bJsonOBJ);
                End;
              End;
            End;
          If Not vFindFlag Then
            ListFields.Add('-1');
        End;
        bJsonValueB.Free;
        bJsonValueB := TRESTDWJSONInterfaceObject.Create(vTempValueJSON);
        If bJsonValueB.ClassType = TRESTDWJSONInterfaceObject Then
        Begin
          vLocSetInBlockEvents(True);
          vLocSetRecordCount(1, 1);
          DestDS.Append;
          Try
            For I := 0 To DestDS.Fields.Count - 1 Do
            Begin
              vOldReadOnly := DestDS.Fields[I].ReadOnly;
              FieldValidate := DestDS.Fields[I].OnValidate;
              DestDS.Fields[I].OnValidate := Nil;
              DestDS.Fields[I].ReadOnly := False;
              If DestDS.Fields[I].FieldKind = fkLookup Then
              Begin
                DestDS.Fields[I].ReadOnly := vOldReadOnly;
                DestDS.Fields[I].OnValidate := FieldValidate;
                Continue;
              End;
              If (I >= ListFields.Count) Then
              Begin
                DestDS.Fields[I].ReadOnly := vOldReadOnly;
                DestDS.Fields[I].OnValidate := FieldValidate;
                Continue;
              End;
              If (StrToInt(ListFields[I]) = -1) Or
                Not(DestDS.Fields[I].FieldKind = fkData) Or
                (StrToInt(ListFields[I]) = -1) Then
              Begin
                DestDS.Fields[I].ReadOnly := vOldReadOnly;
                DestDS.Fields[I].OnValidate := FieldValidate;
                Continue;
              End;
              // FreeAndNil(bJsonOBJB);
              vTempValue := bJsonValueB.pairs[StrToInt(ListFields[I])].Value;
              If DestDS.Fields[I].DataType In [ftGraphic, ftParadoxOle,
                ftDBaseOle, ftTypedBinary, ftCursor, ftDataSet, ftBlob,
                ftOraBlob, ftOraClob
              {$IFDEF DELPHIXEUP}, ftParams, ftStream{$ENDIF}] Then
              Begin
                If (vTempValue <> 'null') And (vTempValue <> '') Then
                Begin
                  // HexStringToStream(vTempValue, vBlobStream);
                  vBlobStream := DecodeStream(vTempValue);
                  Try
                    vBlobStream.Position := 0;
                    TBlobField(DestDS.Fields[I]).LoadFromStream(vBlobStream);
                  Finally
                    {$IFDEF DELPHIXEUP}
                    vBlobStream.Clear;
                    {$ENDIF}
                    FreeAndNil(vBlobStream);
                  End;
                End;
              End
              Else
              Begin
                If (Lowercase(vTempValue) <> 'null') Then
                Begin
                  If DestDS.Fields[I].DataType in [ftString, ftWideString,
                  {$IFDEF DELPHIXEUP}ftWideMemo, {$ENDIF}
                  ftMemo, ftFmtMemo, ftFixedChar] Then
                  Begin
                    If vTempValue = '' Then
                      DestDS.Fields[I].AsString := ''
                    Else
                    Begin
                      // If vEncoded Then
                      // DestDS.Fields[i].AsString := DecodeStrings(vTempValue{$IFDEF RESTDWLAZARUS}, vDatabaseCharSet{$ENDIF})
                      // Else
                      If vUtf8SpecialChars Then
                        vTempValue := Unescape_chars(vTempValue);
                      {$IFDEF RESTDWLAZARUS}
                      vTempValue := GetStringDecode(vTempValue,
                        vDatabaseCharSet);
                      {$ENDIF}
                      DestDS.Fields[I].AsString := vTempValue;
                    End;
                  End
                  Else If (vTempValue <> '') then
                    SetValueA(DestDS.Fields[I], vTempValue);
                End;
              End;
              DestDS.Fields[I].ReadOnly := vOldReadOnly;
              DestDS.Fields[I].OnValidate := FieldValidate;
            End;
          Finally
            vTempValue := '';
          End;
          DestDS.Post;
          If Assigned(vOnWriterProcess) Then
            vOnWriterProcess(DestDS, 1, 1, AbortProcess);
          If AbortProcess Then
            Exit;
        End
        Else
        Begin
          bJsonArrayB := TRESTDWJSONInterfaceArray(bJsonValueB);
          vLocSetInBlockEvents(True);
          vLocSetRecordCount(bJsonArrayB.ElementCount,
            bJsonArrayB.ElementCount);
          For J := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
            bJsonOBJB := TRESTDWJSONInterfaceArray(bJsonArrayB).GetObject(J);
            DestDS.Append;
            Try
              For I := 0 To DestDS.Fields.Count - 1 Do
              Begin
                vOldReadOnly := DestDS.Fields[I].ReadOnly;
                FieldValidate := DestDS.Fields[I].OnValidate;
                DestDS.Fields[I].OnValidate := Nil;
                DestDS.Fields[I].ReadOnly := False;
                If DestDS.Fields[I].FieldKind = fkLookup Then
                Begin
                  DestDS.Fields[I].ReadOnly := vOldReadOnly;
                  DestDS.Fields[I].OnValidate := FieldValidate;
                  Continue;
                End;
                If (I >= ListFields.Count) Then
                Begin
                  DestDS.Fields[I].ReadOnly := vOldReadOnly;
                  DestDS.Fields[I].OnValidate := FieldValidate;
                  Continue;
                End;
                If (StrToInt(ListFields[I]) = -1) Or
                  Not(DestDS.Fields[I].FieldKind = fkData) Or
                  (StrToInt(ListFields[I]) = -1) Then
                Begin
                  DestDS.Fields[I].ReadOnly := vOldReadOnly;
                  DestDS.Fields[I].OnValidate := FieldValidate;
                  Continue;
                End;
                // FreeAndNil(bJsonOBJB);
                If Not TRESTDWJSONInterfaceObject(bJsonOBJB)
                  .pairs[StrToInt(ListFields[I])].IsNull Then
                  vTempValue := TRESTDWJSONInterfaceObject(bJsonOBJB)
                    .pairs[StrToInt(ListFields[I])].Value
                  // bJsonOBJTemp.get().ToString;
                Else
                  Continue;
                If DestDS.Fields[I].DataType In [ftGraphic, ftParadoxOle,
                  ftDBaseOle, ftTypedBinary, ftCursor, ftDataSet, ftBlob,
                  ftOraBlob, ftOraClob
                {$IFDEF DELPHIXEUP}, ftParams, ftStream{$ENDIF}] Then
                Begin
                  If (vTempValue <> 'null') And (vTempValue <> '') Then
                  Begin
                    // HexStringToStream(vTempValue, vBlobStream);
                    vBlobStream := DecodeStream(vTempValue);
                    Try
                      vBlobStream.Position := 0;
                      TBlobField(DestDS.Fields[I]).LoadFromStream(vBlobStream);
                    Finally
                      {$IFDEF DELPHIXEUP}
                      vBlobStream.Clear;
                      {$ENDIF}
                      FreeAndNil(vBlobStream);
                    End;
                  End;
                End
                Else
                Begin
                  If (Lowercase(vTempValue) <> 'null') Then
                  Begin
                    If DestDS.Fields[I].DataType in [ftString, ftWideString,
                    {$IFDEF DELPHIXEUP}ftWideMemo, {$ENDIF}
                    ftMemo, ftFmtMemo, ftFixedChar] Then
                    Begin
                      If vTempValue = '' Then
                        DestDS.Fields[I].AsString := ''
                      Else
                      Begin
                        if vEncoded then
                          DestDS.Fields[I].AsString :=
                            DecodeStrings(vTempValue{$IFDEF RESTDWLAZARUS},
                            vDatabaseCharSet{$ENDIF})
                        Else
                        Begin
                          If vUtf8SpecialChars Then
                            vTempValue := Unescape_chars(vTempValue);
                          {$IFDEF RESTDWLAZARUS}
                          vTempValue := GetStringDecode(vTempValue,
                            vDatabaseCharSet);
                          {$ENDIF}
                          DestDS.Fields[I].AsString := vTempValue;
                        End;
                      End;
                    End
                    Else If (vTempValue <> '') then
                      SetValueA(DestDS.Fields[I], vTempValue);
                  End;
                End;
                DestDS.Fields[I].ReadOnly := vOldReadOnly;
                DestDS.Fields[I].OnValidate := FieldValidate;
              End;
            Finally
              vTempValue := '';
            End;
            FreeAndNil(bJsonOBJB);
            DestDS.Post;
            If Assigned(vOnWriterProcess) Then
              vOnWriterProcess(DestDS, J + 1, bJsonArrayB.ElementCount,
                AbortProcess);
            If AbortProcess Then
              Break;
          End;
        End;
      Except
      End;
    End;
  Finally
    If Assigned(ListFields) Then
      FreeAndNil(ListFields);
    If DestDS.Active Then
      DestDS.First;
    DestDS.EnableControls;
    If Assigned(bJsonValue) Then
      FreeAndNil(bJsonValue);
    If Assigned(bJsonValueB) Then
      FreeAndNil(bJsonValueB);
  End;
End;

Procedure TJSONValue.WriteToDataset(DatasetType: TDatasetType;
  JSONValue: String; Const DestDS: TDataset; Var JsonCount: Integer;
  Datapacks: Integer = -1; ActualRec: Integer = 0; ClearDataset: Boolean = False
  {$IFDEF RESTDWLAZARUS}; CharSet: TDatabaseCharSet = csUndefined
  {$ENDIF});
Var
  FieldValidate: TFieldNotifyEvent;
  bJsonOBJB, bJsonOBJ: TRESTDWJSONInterfaceBase;
  bJsonValue: TRESTDWJSONInterfaceObject;
  bJsonOBJTemp, bJsonArray, bJsonArrayB: TRESTDWJSONInterfaceArray;
  A, J, I, vPageCount: Integer;
  FieldDef: TFieldDef;
  Field: TField;
  AbortProcess, vOldReadOnly, vFindFlag: Boolean;
  vBlobStream: TMemoryStream;
  ListFields: TStringList;
  vBuildSide, vTempValue: String;
  // vFieldDefinition : TFieldDefinition;
  vActualBookmark: TBookmark;
  vFieldDataType: TFieldType;
  vLocSetInBlockEvents: TSetInitDataset;
  vLocNewDataField: TNewDataField;
  vLocFieldExist: TFieldExist;
  vLocSetRecordCount: TSetRecordCount;
  vLocSetInitDataset: TSetInitDataset;
  vLocNewFieldList, vLocCreateDataset: TProcedureEvent;
  vLocFieldListCount: TFieldListCount;
  vLocGetInDesignEvents: TGetInDesignEvents;
  Function FieldIndex(FieldName: String): Integer;
  Var
    I: Integer;
  Begin
    Result := -1;
    For I := 0 To ListFields.Count - 1 Do
    Begin
      If Uppercase(ListFields[I]) = Uppercase(FieldName) Then
      Begin
        Result := I;
        Break;
      End;
    End;
  End;

Begin
  vFieldDefinition := Nil;
  bJsonOBJB := Nil;
  bJsonOBJ := Nil;
  bJsonValue := Nil;
  bJsonOBJTemp := Nil;
  bJsonArray := Nil;
  bJsonArrayB := Nil;
  vBlobStream := Nil;
  AbortProcess := False;
  vLocSetInBlockEvents := SetInBlockEvents;
  vLocNewDataField := NewDataField;
  vLocFieldExist := FieldExist;
  vLocFieldListCount := FieldListCount;
  vLocNewFieldList := NewFieldList;
  vLocCreateDataset := CreateDataset;
  vLocSetRecordCount := SetRecordCount;
  vLocSetInitDataset := SetInitDataset;
  vLocGetInDesignEvents := GetInDesignEvents;
  If JSONValue = '' Then
    Exit;
  vPageCount := 0;
  ListFields := TStringList.Create;
  Try
    If Pos('[', JSONValue) = 0 Then
    Begin
      FreeAndNil(ListFields);
      Exit;
    End;
    bJsonValue := TRESTDWJSONInterfaceObject.Create(JSONValue);
    If bJsonValue.PairCount > 0 Then
    Begin
      bJsonArray := TRESTDWJSONInterfaceArray
        (bJsonValue.openArray(bJsonValue.pairs[4].Name));
      bJsonOBJ := bJsonArray.GetObject(0);
      bJsonArrayB := TRESTDWJSONInterfaceObject(bJsonOBJ)
        .openArray(TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[0].Name);
      vBuildSide := TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[1].Value;
      if Assigned(bJsonOBJ) then
        FreeAndNil(bJsonOBJ);
    End
    Else
    Begin
      DestDS.Close;
      Raise Exception.Create(cErrorInvalidJSONData);
    End;
    If ActualRec = 0 Then
    Begin
      vTypeObject := GetObjectName(bJsonValue.pairs[0].Value);
      vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
      vEncoded := GetBooleanFromString(bJsonValue.pairs[2].Value);
      vObjectValue := GetValueType(bJsonValue.pairs[3].Value);
      vtagName := Lowercase(bJsonValue.pairs[4].Name);
      vLocSetInBlockEvents(True);
      DestDS.DisableControls;
      If DestDS.Active Then
        DestDS.Close;
      DestDS.FieldDefs.BeginUpdate;
      vLocNewFieldList;
      vFieldDefinition := TFieldDefinition.Create;
      DestDS.FieldDefs.Clear;
      If (DestDS.Fields.Count = 0) And (DestDS.FieldDefs.Count > 0) Then
        DestDS.FieldDefs.Clear
      Else
      Begin
        For J := 0 To DestDS.Fields.Count - 1 Do
        Begin
          vFieldDefinition.FieldName := DestDS.Fields[J].FieldName;
          vFieldDefinition.DataType := DestDS.Fields[J].DataType;
          If (vFieldDefinition.DataType <> ftFloat) Then
            vFieldDefinition.Size := DestDS.Fields[J].Size
          Else
            vFieldDefinition.Size := 0;
          If (vFieldDefinition.DataType In [ftCurrency, ftBCD,
            {$IFDEF DELPHIXEUP}ftExtended, ftSingle, {$ENDIF}
            ftFMTBcd]) Then
            vFieldDefinition.Precision := TBCDField(DestDS.Fields[J]).Precision
          Else If (vFieldDefinition.DataType = ftFloat) Then
            vFieldDefinition.Precision := TFloatField(DestDS.Fields[J])
              .Precision;
          vFieldDefinition.Required := DestDS.Fields[J].Required;
          vLocNewDataField(vFieldDefinition);
        End;
      End;
      For J := 0 To bJsonArrayB.ElementCount - 1 Do
      Begin
        bJsonOBJ := bJsonArrayB.GetObject(J);
        Try
          vTempValue := Trim(TRESTDWJSONInterfaceObject(bJsonOBJ)
            .pairs[0].Value);
          If Trim(vTempValue) <> '' Then
          Begin
            FieldDef := FieldDefExist(DestDS, vTempValue);
            If (FieldDef = Nil) Then
            Begin
              If (vLocFieldExist(DestDS, vTempValue) = Nil) Then
              Begin
                vFieldDefinition.FieldName := vTempValue;
                vFieldDefinition.DataType :=
                  GetFieldType(TRESTDWJSONInterfaceObject(bJsonOBJ)
                  .pairs[1].Value);
                If (Not(vFieldDefinition.DataType in [ftFloat, ftCurrency,
                  ftBCD, ftFMTBcd
                  {$IFDEF DELPHIXEUP}, ftSingle{$ENDIF}])) Then
                  vFieldDefinition.Size :=
                    StrToInt(TRESTDWJSONInterfaceObject(bJsonOBJ)
                    .pairs[4].Value)
                Else
                  vFieldDefinition.Size := 0;
                If (vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD,
                  {$IFDEF DELPHIXEUP}ftExtended, ftSingle, {$ENDIF}
                  ftFMTBcd]) Then
                  vFieldDefinition.Precision :=
                    StrToInt(TRESTDWJSONInterfaceObject(bJsonOBJ)
                    .pairs[4].Value);
                vFieldDefinition.Required :=
                  Uppercase(TRESTDWJSONInterfaceObject(bJsonOBJ)
                  .pairs[3].Value) = 'S';
                vLocNewDataField(vFieldDefinition);
              End;
              FieldDef := DestDS.FieldDefs.AddFieldDef;
              If vEncoding = esUtf8 Then
              Begin
                {$IFDEF RESTDWLAZARUS}
                FieldDef.Name := vTempValue;
                {$ELSE}
                FieldDef.Name := UTF8Encode(vTempValue);
                {$ENDIF}
              End
              Else
                FieldDef.Name := vTempValue;
              FieldDef.DataType :=
                GetFieldType(TRESTDWJSONInterfaceObject(bJsonOBJ)
                .pairs[1].Value);
              If not(FieldDef.DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd
                {$IFDEF DELPHIXEUP}, ftSingle{$ENDIF}]) Then
                FieldDef.Size := StrToInt(TRESTDWJSONInterfaceObject(bJsonOBJ)
                  .pairs[4].Value)
              Else
                FieldDef.Precision :=
                  StrToInt(TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[4].Value);
              {$IFDEF RESTDWLAZARUS}
              If (FieldDef.DataType In [ftFloat, ftCurrency, ftBCD,
                ftFMTBcd]) Then
              Begin
                FieldDef.Size := StrToInt(TRESTDWJSONInterfaceObject(bJsonOBJ)
                  .pairs[4].Value);
                FieldDef.Precision :=
                  StrToInt(TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[5].Value);
              End;
              {$ENDIF}
            End;
          End;
        Finally
          If Assigned(bJsonOBJ) Then
            FreeAndNil(bJsonOBJ);
        End;
      End;
      If Assigned(vFieldDefinition) Then
        FreeAndNil(vFieldDefinition);
      DestDS.FieldDefs.EndUpdate;
      Try
        vLocSetInBlockEvents(True);
        Inactive := True;
        If Assigned(vLocCreateDataset) Then
          vLocCreateDataset();
        If Not DestDS.Active Then
          DestDS.Open;
        If Not DestDS.Active Then
        Begin
          If Assigned(bJsonValue) Then
            FreeAndNil(bJsonValue);
          FreeAndNil(ListFields);
          Raise Exception.Create(cErrorParsingJSON);
          Exit;
        End;
      Except
        On E: Exception Do
          Raise Exception.Create(E.Message);
      End;
      If csDesigning in DestDS.ComponentState Then
      Begin
        // Clean Invalid Fields
        For A := DestDS.Fields.Count - 1 DownTo 0 Do
        Begin
          If DestDS.Fields[A].FieldKind = fkData Then
          Begin
            vFindFlag := False;
            For J := 0 To bJsonArrayB.ElementCount - 1 Do
            Begin
              bJsonOBJ := bJsonArrayB.GetObject(J);
              Try
                If Trim(TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[0].Value)
                  <> '' Then
                Begin
                  vFindFlag := Lowercase(TRESTDWJSONInterfaceObject(bJsonOBJ)
                    .pairs[0].Value) = Lowercase(DestDS.Fields[A].FieldName);
                  If vFindFlag Then
                    Break;
                End;
              Finally
                If Assigned(bJsonOBJ) Then
                  FreeAndNil(bJsonOBJ);
              End;
            End;
            If Not vFindFlag Then
              DestDS.Fields.Remove(DestDS.Fields[A]);
          End;
        End;
      End;
      // Add Set PK Fields
      For J := 0 To bJsonArrayB.ElementCount - 1 Do
      Begin
        bJsonOBJ := bJsonArrayB.GetObject(J);
        Try
          If Uppercase(Trim(TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[2].Value)
            ) = 'S' Then
          Begin
            Field := DestDS.FindField(TRESTDWJSONInterfaceObject(bJsonOBJ)
              .pairs[0].Value);
            If Field <> Nil Then
            Begin
              If Field.FieldKind = fkData Then
                Field.ProviderFlags := [pfInUpdate, pfInWhere, pfInKey]
              Else
                Field.ProviderFlags := [];
              {$IFDEF DELPHIXEUP}
              If bJsonOBJ.PairCount > 6 Then
              Begin
                If (Uppercase(Trim(TRESTDWJSONInterfaceObject(bJsonOBJ)
                  .pairs[7].Value)) = 'S') Then
                  Field.AutoGenerateValue := arAutoInc;
              End;
              {$ENDIF}
            End;
          End;
        Finally
          If Assigned(bJsonOBJ) then
            FreeAndNil(bJsonOBJ);
        End;
      End;
      For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
      Begin
        vFindFlag := False;
        If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
          If DestDS.FindField(DestDS.Fields[A].FieldName)
            .FieldKind = fkData Then
          Begin
            For J := 0 To bJsonArrayB.ElementCount - 1 Do
            Begin
              bJsonOBJ := bJsonArrayB.GetObject(J);
              If Trim(TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[0].Value)
                <> '' Then
              Begin
                vFindFlag :=
                  Uppercase(Trim(TRESTDWJSONInterfaceObject(bJsonOBJ)
                  .pairs[0].Value)) = Uppercase(DestDS.Fields[A].FieldName);
                If vFindFlag Then
                Begin
                  ListFields.Add(IntToStr(J));
                  If Assigned(bJsonOBJ) Then
                    FreeAndNil(bJsonOBJ);
                  Break;
                End;
              End;
              If Assigned(bJsonOBJ) then
                FreeAndNil(bJsonOBJ);
            End;
          End;
        If Not vFindFlag Then
          ListFields.Add('-1');
      End;
      // If Assigned(ListFields) then
      // FreeAndNil(ListFields);
      If vLocGetInDesignEvents() Then
      Begin
        vSetInDesignEvents := SetInDesignEvents;
        vSetInDesignEvents(False);
        Exit;
      End;
    End
    Else
    Begin
      For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
      Begin
        vFindFlag := False;
        If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
          If DestDS.FindField(DestDS.Fields[A].FieldName)
            .FieldKind = fkData Then
          Begin
            For J := 0 To bJsonArrayB.ElementCount - 1 Do
            Begin
              bJsonOBJ := bJsonArrayB.GetObject(J);
              If Trim(TRESTDWJSONInterfaceObject(bJsonOBJ).pairs[0].Value)
                <> '' Then
              Begin
                vFindFlag :=
                  Uppercase(Trim(TRESTDWJSONInterfaceObject(bJsonOBJ)
                  .pairs[0].Value)) = Uppercase(DestDS.Fields[A].FieldName);
                If vFindFlag Then
                Begin
                  ListFields.Add(IntToStr(J));
                  If Assigned(bJsonOBJ) then
                    FreeAndNil(bJsonOBJ);
                  Break;
                End;
              End;
              If Assigned(bJsonOBJ) Then
                FreeAndNil(bJsonOBJ);
            End;
          End;
        If Not vFindFlag Then
          ListFields.Add('-1');
      End;
      vActualBookmark := DestDS.GetBookmark;
    End;
    If Assigned(bJsonArrayB) then
      FreeAndNil(bJsonArrayB);
    bJsonOBJ := bJsonArray.GetObject(1);
    bJsonArrayB := TRESTDWJSONInterfaceArray(TRESTDWJSONInterfaceArray(bJsonOBJ)
      .GetObject(0));
    vLocSetInBlockEvents(True);
    JsonCount := bJsonArrayB.ElementCount;
    If ((ActualRec + Datapacks) > (bJsonArrayB.ElementCount - 1)) Or
      (Datapacks = -1) Then
      vPageCount := bJsonArrayB.ElementCount - 1
    Else
      vPageCount := (ActualRec + Datapacks - 1);
    For J := ActualRec To vPageCount Do
    Begin
      bJsonOBJB := TRESTDWJSONInterfaceArray(bJsonArrayB).GetObject(J);
      bJsonOBJTemp := TRESTDWJSONInterfaceObject(bJsonOBJB)
        .openArray(TRESTDWJSONInterfaceObject(bJsonOBJB).pairs[0].Name);
      DestDS.Append;
      Try
        For I := 0 To DestDS.Fields.Count - 1 Do
        Begin
          vOldReadOnly := DestDS.Fields[I].ReadOnly;
          FieldValidate := DestDS.Fields[I].OnValidate;
          DestDS.Fields[I].OnValidate := Nil;
          DestDS.Fields[I].ReadOnly := False;
          If DestDS.Fields[I].FieldKind = fkLookup Then
          Begin
            DestDS.Fields[I].ReadOnly := vOldReadOnly;
            DestDS.Fields[I].OnValidate := FieldValidate;
            Continue;
          End;
          If (I >= ListFields.Count) Then
          Begin
            DestDS.Fields[I].ReadOnly := vOldReadOnly;
            DestDS.Fields[I].OnValidate := FieldValidate;
            Continue;
          End;
          If (StrToInt(ListFields[I]) = -1) Or
            Not(DestDS.Fields[I].FieldKind = fkData) Or
            (StrToInt(ListFields[I]) = -1) Then
          Begin
            DestDS.Fields[I].ReadOnly := vOldReadOnly;
            DestDS.Fields[I].OnValidate := FieldValidate;
            Continue;
          End;
          If Assigned(bJsonOBJB) Then
            FreeAndNil(bJsonOBJB);
          bJsonOBJB := bJsonOBJTemp.GetObject(StrToInt(ListFields[I]));
          If TRESTDWJSONInterfaceObject(bJsonOBJB).pairs[0].IsNull Then
            Continue;
          vTempValue := TRESTDWJSONInterfaceObject(bJsonOBJB).pairs[0].Value;
          If DestDS.Fields[I].DataType In [ftGraphic, ftParadoxOle, ftDBaseOle,
            ftTypedBinary, ftCursor, ftDataSet, ftBlob, ftOraBlob, ftOraClob
          {$IFDEF DELPHIXEUP}, ftParams, ftStream{$ENDIF}] Then
          Begin
            If (vTempValue <> 'null') And (vTempValue <> '') Then
            Begin
              // HexStringToStream(vTempValue, vBlobStream);
              vBlobStream := DecodeStream(vTempValue);
              Try
                vBlobStream.Position := 0;
                TBlobField(DestDS.Fields[I]).LoadFromStream(vBlobStream);
              Finally
                {$IFDEF DELPHIXEUP}
                vBlobStream.Clear;
                {$ENDIF}
                FreeAndNil(vBlobStream);
              End;
            End;
          End
          Else
          Begin
            If (Lowercase(vTempValue) <> 'null') Then
            Begin
              If DestDS.Fields[I].DataType in [ftString, ftWideString,
              {$IFDEF DELPHIXEUP}ftWideMemo, {$ENDIF}
              ftMemo, ftFmtMemo, ftFixedChar, ftGuid] Then
              Begin
                If vTempValue = '' Then
                  DestDS.Fields[I].AsString := ''
                Else
                Begin
                  If ((vEncoded) or (DestDS.Fields[I].DataType
                    in [{$IFDEF DELPHIXEUP}ftWideMemo, {$ENDIF}
                    ftMemo, ftFmtMemo])) And
                    (Not(DestDS.Fields[I].DataType = ftGuid)) Then
                  Begin
                    vTempValue :=
                      DecodeStrings(vTempValue{$IFDEF RESTDWLAZARUS},
                      vDatabaseCharSet{$ENDIF});
                    {$IFNDEF DELPHI2007UP}
                    If vEncoding = esUtf8 Then
                      vTempValue := UTF8Decode(vTempValue);
                    {$ENDIF}
                    DestDS.Fields[I].AsString := vTempValue;
                  End
                  Else
                  Begin
                    If vUtf8SpecialChars Then
                      vTempValue := Unescape_chars(vTempValue);
                    {$IFDEF RESTDWLAZARUS}
                    DestDS.Fields[I].AsString :=
                      GetStringDecode(vTempValue, DatabaseCharSet);
                    {$ELSE}
                    DestDS.Fields[I].AsString := vTempValue;
                    {$ENDIF}
                  End;
                End;
              End
              Else If (vTempValue <> '') then
                SetValueA(DestDS.Fields[I], vTempValue);
            End;
          End;
          DestDS.Fields[I].ReadOnly := vOldReadOnly;
          DestDS.Fields[I].OnValidate := FieldValidate;
          If Assigned(bJsonOBJB) Then
            FreeAndNil(bJsonOBJB);
        End;
      Finally
        vTempValue := '';
      End;
      DestDS.Post;
      If Assigned(vOnWriterProcess) Then
        vOnWriterProcess(DestDS, J + 1, vPageCount, AbortProcess);
      If Assigned(bJsonOBJTemp) Then
        FreeAndNil(bJsonOBJTemp);
      If Assigned(bJsonOBJB) Then
        FreeAndNil(bJsonOBJB);
      If AbortProcess Then
        Break;
    End;
    If (Length(ServerFieldList) > 0) Then
    Begin
      For J := 0 To Length(ServerFieldList) - 1 Do
      Begin
        If Assigned(ServerFieldList[J]) Then
          If Not(vLocFieldExist(DestDS, ServerFieldList[J].FieldName)
            = Nil) Then
            DestDS.FindField(ServerFieldList[J].FieldName).Required :=
              ServerFieldList[J].Required;
      End;
    End;
  Finally
    If Assigned(bJsonOBJTemp) Then
      FreeAndNil(bJsonOBJTemp);
    {$IFNDEF FPC}
    If Assigned(bJsonOBJB) Then
      FreeAndNil(bJsonOBJB);
    {$ENDIF}
    If Assigned(bJsonArrayB) Then
      FreeAndNil(bJsonArrayB);
    If Assigned(bJsonArray) Then
      FreeAndNil(bJsonArray);
    If Assigned(bJsonValue) Then
      FreeAndNil(bJsonValue);
    If Assigned(bJsonOBJ) Then // Tem que ser o Ultimo a ser destruido
      FreeAndNil(bJsonOBJ);
    Try
      vLocSetInBlockEvents(False);
      vLocSetInitDataset(True);
      If (DestDS.Active) And (ActualRec = 0) Then
      Begin
        If Datapacks = -1 Then
          vLocSetRecordCount(vPageCount + 1, vPageCount + 1)
        Else
          vLocSetRecordCount(JsonCount, vPageCount + 1);
        DestDS.First;
      End
      Else
      Begin
        vSetnotrepage := Setnotrepage;
        vSetnotrepage(True);
        DestDS.GotoBookmark(vActualBookmark);
      End;
      vPrepareDetails := PrepareDetails;
      vPrepareDetailsNew := PrepareDetailsNew;
      If DestDS.State = dsBrowse Then
      Begin
        If DestDS.Recordcount = 0 Then
          vPrepareDetailsNew
        Else
          vPrepareDetails(True);
      End;
      vLocSetInitDataset(False);
    Finally
      If Assigned(ListFields) Then
        ListFields.Free;
    End;
    DestDS.EnableControls;
  End;
End;

Procedure TJSONValue.WriteToDataset(DatasetType: TDatasetType;
  JSONValue: String; Const DestDS: TDataset; ClearDataset: Boolean = False
  {$IFDEF RESTDWLAZARUS}; CharSet: TDatabaseCharSet = csUndefined
  {$ENDIF});
Var
  JsonCount: Integer;
Begin
  JsonCount := 0;
  JSONValue := StringReplace(JSONValue, #239#187#191, '', [rfReplaceAll]);
  JSONValue := StringReplace(JSONValue, sLineBreak, '', [rfReplaceAll]);
  WriteToDataset(DatasetType, JSONValue, DestDS, JsonCount, -1, 0,
    ClearDataset{$IFDEF RESTDWLAZARUS}, CharSet{$ENDIF});
End;

Procedure TJSONValue.LoadFromJSON(bValue: String);
Var
  bJsonValue: TRESTDWJSONInterfaceObject;
  vTempValue: String;
  vStringStream: TMemoryStream;
Begin
  vStringStream := Nil;
  vTempValue := StringReplace(bValue, sLineBreak, '', [rfReplaceAll]);
  bJsonValue := TRESTDWJSONInterfaceObject.Create(vTempValue);
  // {$IF DEFINED(iOS) or DEFINED(ANDROID)}
  // SaveLog(vTempValue, 'json2.txt');
  // {$ENDIF}
  Try
    If bJsonValue.PairCount > 0 Then
    Begin
      vNullValue := False;
      vTempValue := CopyValue(bValue);
      vTypeObject := GetObjectName(bJsonValue.pairs[0].Value);
      vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
      vObjectValue := GetValueType(bJsonValue.pairs[3].Value);
      vtagName := Lowercase(bJsonValue.pairs[4].Name);
      If vTypeObject = toDataset Then
      Begin
        If vTempValue[InitStrPos] = '[' Then
          Delete(vTempValue, 1, 1);
        If vTempValue[Length(vTempValue) - FinalStrPos] = ']' Then
          Delete(vTempValue, Length(vTempValue), 1);
      End;
      If vEncoded Then
      Begin
        If vObjectValue In [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic,
          ovOraBlob, ovOraClob] Then
        Begin
          // vStringStream := TMemoryStream.Create;
          Try
            vStringStream := DecodeStream(vTempValue);
            // HexToStream(vTempValue, vStringStream);
            aValue := TRESTDWBytes(StreamToBytes(vStringStream));
          Finally
            vStringStream.Free;
          End;
        End
        Else
          vTempValue := DecodeStrings(vTempValue{$IFDEF RESTDWLAZARUS},
            vDatabaseCharSet{$ENDIF});
      End;
      If Not(vObjectValue In [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic,
        ovOraBlob, ovOraClob]) Then
        SetValue(vTempValue, vEncoded)
      Else
      Begin
        // vStringStream := TMemoryStream.Create;
        Try
          vStringStream := DecodeStream(vTempValue);
          // HexToStream(vTempValue, vStringStream);
          aValue := TRESTDWBytes(StreamToBytes(vStringStream));
        Finally
          FreeAndNil(vStringStream);
        End;
      End;
    End;
  Finally
    bJsonValue.Free;
  End;
End;

Procedure TJSONValue.LoadFromJSON(bValue: String; DataModeD: TDataMode);
Var
  bJsonValue: TRESTDWJSONInterfaceObject;
Begin
  bJsonValue := TRESTDWJSONInterfaceObject.Create
    (StringReplace(bValue, sLineBreak, '', [rfReplaceAll]));
  Try
    If bJsonValue.PairCount > 0 Then
    Begin
      vTypeObject := toObject;
      vObjectDirection := odINOUT;
      vObjectValue := ovString;
      vtagName := 'jsonpure';
      // fernando
      // vNullValue       := ((bValue = '') or (bValue= 'null'));
      vNullValue := bValue = 'null';
      SetValue(bValue, vEncoded);
    End;
  Finally
    bJsonValue.Free;
  End;
End;

Procedure TJSONValue.LoadFromStream(Stream: TStream);
Begin
  ObjectValue := ovBlob;
  vBinary := True;
  vNullValue := True;
  If (Stream <> Nil) Then
  Begin
    Stream.Position := 0;
    If Stream.Size > 0 Then
    Begin
      Try
        SetLength(aValue, Stream.Size);
        Stream.Read(aValue[0], Stream.Size);
        vNullValue := False;
      Except

      End;
    End;
  End;
End;

Procedure TJSONValue.SaveToStream(Const Stream: TStream);
Begin
  Try
    If Length(aValue) > 0 Then
      Stream.Write(aValue[0], Length(aValue));
  Finally
    If Assigned(Stream) Then
      Stream.Position := 0;
  End;
End;

Procedure TJSONValue.SaveToFile(FileName: String);
Var
  vStringStream: TStringStream;
  vFileStream: TFileStream;
Begin
  vStringStream := TStringStream.Create(ToJSON);
  Try
    {$IFDEF RESTDWLAZARUS}
    vStringStream.Position := 0;
    vFileStream := TFileStream.Create(FileName, fmCreate);
    Try
      vFileStream.CopyFrom(vStringStream, vStringStream.Size);
    Finally
      vFileStream.Free;
    End;
    {$ELSE}
    {$IFDEF DELPHIXEUP} // Delphi XE pra cima
    vStringStream.Position := 0;
    vStringStream.SaveToFile(FileName);
    {$ELSE}
    vStringStream.Position := 0;
    vFileStream := TFileStream.Create(FileName, fmCreate);
    Try
      vFileStream.CopyFrom(vStringStream, vStringStream.Size);
    Finally
      vFileStream.Free;
    End;
    {$ENDIF}
    {$ENDIF}
  Finally
    vStringStream.Free;
  End;
End;

Procedure TJSONValue.ToBytes(Value: String; Encode: Boolean = False);
Var
  Stream: TStringStream;
Begin
  If Value <> '' Then
  Begin
    ObjectValue := ovBlob;
    vBinary := True;
    vEncoded := Encode;
    Stream := TStringStream.Create(Value);
    Try
      Stream.Position := 0;
      SetValue(EncodeStream(Stream), Encode); // StreamToHex(Stream), Encode);
    Finally
      Stream.Free;
    End;
  End;
End;

Function TJSONValue.ToJSON: String;
Var
  {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
  vTempValue: String;
  {$ELSE}
  vTempValue: AnsiString;
  SizeOfString: Integer;
  {$IFEND}
Begin
  Result := '';
  vTempValue := '';
  {$IFDEF RESTDWLAZARUS}
  If vEncodingLazarus = Nil Then
    SetEncoding(vEncoding);
  If vEncoding = esUtf8 Then
    vTempValue := vEncodingLazarus.Getstring(aValue)
  Else
    vTempValue := BytesToString(aValue);
  If vTempValue = '' Then
  Begin
    If vNullValue Then
      vTempValue := FormatValue('null')
    Else
    Begin
      If Not(vObjectValue in [ovString, ovFixedChar, ovWideString,
        ovFixedWideChar, ovBlob, ovStream, ovGraphic, ovOraBlob, ovOraClob,
        ovMemo, ovWidememo, ovGuid, ovFmtMemo]) Then
        vTempValue := FormatValue('null')
      Else
        vTempValue := FormatValue('');
    End;
  End
  Else
    vTempValue := FormatValue(vTempValue);
  {$ELSE}
  If vTempValue = '' Then
    vTempValue := DecodeStrings(BytesToString(aValue));
  If vTempValue = '' Then
  Begin
    If vNullValue Then
      vTempValue := FormatValue('null')
    Else
    Begin
      If Not(vObjectValue in [ovString, ovFixedChar, ovWideString,
        ovFixedWideChar, ovBlob, ovStream, ovGuid, ovGraphic, ovOraBlob,
        ovOraClob, ovMemo, ovWidememo, ovFmtMemo]) Then
        vTempValue := FormatValue('null')
      Else
        vTempValue := FormatValue('');
    End;
  End
  Else
  Begin
    {$IFDEF DELPHI2010UP}
    vTempValue := FormatValue(vTempValue);
    {$ELSE} // Delphi 2010 pra baixo
    SizeOfString := Length(aValue);
    vTempValue := '';
    SetString(vTempValue, PChar(@aValue[0]), SizeOfString);
    { //Comentado deleção de nulos
      While pos(#0, vTempValue) > 0 Do
      Delete(vTempValue, pos(#0, vTempValue), 1);
    }
    vTempValue := FormatValue(vTempValue);
    If vEncoding = esUtf8 Then
      vTempValue := UTF8Decode(vTempValue);
    {$ENDIF}
  End;
  {$ENDIF}
  If Not(Pos('"TAGJSON":}', vTempValue) > 0) Then
    Result := vTempValue;
End;

Procedure TJSONValue.SetValue(Value: Variant; Encode: Boolean);
Begin
  vEncoded := Encode;
  vNullValue := VarIsNull(Value);
  If vObjectValue in [ovDate, ovTime, ovDateTime, ovTimeStamp] then
  // ajuste massive
  Begin
    If VarIsStr(Value) Then
    Begin
      If (Value = '') Then
      Begin
        WriteValue(Null);
        Value := Null;
      End
      Else
      Begin
        If (Pos(',', Value) > 0) Or (Pos('.', Value) > 0) Then
          Value := StrToFloat(Value)
        Else
          Value := StrToDateTime(Value);
      End;
    End;
    If (Not(vNullValue)) Then
      Value := IntToStr(DateTimeToUnix(Value))
  End;
  If Encode Then
  Begin
    If Not vNullValue Then
    Begin
      If vObjectValue in [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic,
        ovOraBlob, ovOraClob] Then
      Begin
        vBinary := True;
        WriteValue(Value);
      End
      Else
      Begin
        vBinary := False;
        WriteValue(EncodeStrings(Value{$IFDEF RESTDWLAZARUS},
          vDatabaseCharSet{$ENDIF}))
      End;
    End
    Else
      WriteValue(Null);
  End
  Else
  Begin
    If Not vNullValue Then
    Begin
      If vObjectValue in [ovBytes, ovVarBytes, ovStream, ovBlob, ovGraphic,
        ovOraBlob, ovOraClob] Then
      Begin
        vBinary := True;
        WriteValue(Value);
      End
      Else
      Begin
        vBinary := False;
        WriteValue(Value);
      End;
    End
    Else
      WriteValue(Null);
  End;
End;

Procedure TJSONValue.BeginBytes(DataSize: DWInt64);
Begin
  vNullValue := True;
  If Length(aValue) > 0 Then
    SetLength(aValue, 0);
  If DataSize > 0 Then
  Begin
    vNullValue := False;
    SetLength(aValue, DataSize);
  End;
End;

Procedure TJSONValue.WriteBytes(bValue: TRESTDWBytes);
Begin
  aValue := bValue;
End;

Function TJSONValue.GetBytes: TRESTDWBytes;
Begin
  Result := aValue;
End;

Function TJSONValue.Value: Variant;
Begin
  Result := GetValue;
  If VarIsNull(Result) Then
    Exit;
  {$IFNDEF RESTDWLAZARUS}
  {$IFNDEF DELPHI2009UP}
  Result := UTF8Decode(Result);
  {$IFDEF DELPHI8UP}
  If vEncoding = esUtf8 Then
    Result := UTF8Decode(Result);
  {$ENDIF}
  {$ENDIF}
  {$ELSE}
  Result := GetStringDecode(Result, vDatabaseCharSet);
  {$ENDIF}
End;

Constructor TJSONValue.Create;
Begin
  Inherited;
  {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
  vEncoding := esUtf8;
  {$ELSE}
  vEncoding := esASCII;
  {$IFEND}
  {$IFDEF RESTDWLAZARUS}
  vDatabaseCharSet := csUndefined;
  {$ENDIF}
  vFieldExist := Nil;
  vNewDataField := Nil;
  vCreateDataset := Nil;
  vTypeObject := toObject;
  ObjectDirection := odINOUT;
  vObjectValue := ovString;
  vtagName := 'TAGJSON';
  vBinary := True;
  vUtf8SpecialChars := True; // Adicionado por padrão para special Chars
  vNullValue := vBinary;
  vDataMode := dmDataware;
  vOnWriterProcess := Nil;
  vInactive := False;
  vInBlockEvents := False;
  vNewFieldList := Nil;
  vSetInitDataset := Nil;
  vSetInitDataset := Nil;
  vSetRecordCount := Nil;
  vSetnotrepage := Nil;
  vSetInDesignEvents := Nil;
  vSetInBlockEvents := Nil;
  vSetInactive := Nil;
  vGetInDesignEvents := Nil;
  vPrepareDetails := Nil;
  SetLength(vFieldsList, 0);
End;

Destructor TJSONValue.Destroy;
Begin
  SetLength(aValue, 0);
  Clear;
  Inherited;
End;

Function TJSONValue.IsNull: Boolean;
Begin
  Result := vNullValue;
End;

Procedure TJSONParam.WriteValue(bValue: TStream);
Begin
  If TestNilParam Then
    Exit;
  vJSONValue.Encoding := vEncoding;
  vJSONValue.vtagName := vParamName;
  vJSONValue.vTypeObject := vTypeObject;
  vJSONValue.vObjectDirection := vObjectDirection;
  vJSONValue.vObjectValue := vObjectValue;
  vJSONValue.vEncoded := False;
  vJSONValue.WriteValue(bValue);
  vNullValue := vJSONValue.vNullValue;
End;

Procedure TJSONParam.WriteValue(bValue: Variant);
Begin
  If TestNilParam Then
    Exit;
  vJSONValue.Encoding := vEncoding;
  vJSONValue.vtagName := vParamName;
  vJSONValue.vTypeObject := vTypeObject;
  vJSONValue.vObjectDirection := vObjectDirection;
  vJSONValue.vObjectValue := vObjectValue;
  vJSONValue.vEncoded := vEncoded;
  vJSONValue.WriteValue(bValue);
  vNullValue := vJSONValue.vNullValue;
End;

Procedure TJSONParam.SetParamName(bValue: String);
Begin
  If TestNilParam Then
    Exit;
  vParamName := Uppercase(bValue);
  vJSONValue.vtagName := vParamName;
End;

Procedure TJSONParam.SetParamFileName(bValue: String);
Begin
  If TestNilParam Then
    Exit;
  vParamFileName := bValue;
End;

Function TJSONParam.GetAsString: String;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovString);
End;

Procedure TJSONParam.SetAsString(Value: String);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovString);
End;

{$IF Defined(RESTDWLAZARUS) and not Defined(RESTDWLINUX)}

Function TJSONParam.GetAsWideString: WideString;
Begin
  Result := GetValue(ovWideString);
End;

Procedure TJSONParam.SetAsWideString(Value: WideString);
Begin
  SetDataValue(Value, ovWideString);
End;

Function TJSONParam.GetAsAnsiString: AnsiString;
Begin
  {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
  Result := GetValue(ovString);
  {$ELSE}
  Result := Utf8ToAnsi(GetValue(ovString));
  {$IFEND}
End;

Procedure TJSONParam.SetAsAnsiString(Value: AnsiString);
Begin
  {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
  SetDataValue(Value, ovString);
  {$ELSE}
  SetDataValue(Utf8ToAnsi(Value), ovString);
  {$IFEND}
End;
{$IFEND}

Function TJSONParam.GetAsBCD: Currency;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovBCD);
End;

Procedure TJSONParam.SetAsBCD(Value: Currency);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovBCD);
End;

Function TJSONParam.GetAsFMTBCD: Currency;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovFMTBcd);
End;

Procedure TJSONParam.SetAsFMTBCD(Value: Currency);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovFMTBcd);
End;

Function TJSONParam.GetAsCurrency: Currency;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovCurrency);
End;

Procedure TJSONParam.SetAsCurrency(Value: Currency);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovCurrency);
End;

Function TJSONParam.GetAsBoolean: Boolean;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovBoolean);
End;

Procedure TJSONParam.SetAsBoolean(Value: Boolean);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovBoolean);
End;

Function TJSONParam.GetAsDateTime: TDateTime;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovDateTime);
End;

Procedure TJSONParam.SetAsDateTime(Value: TDateTime);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovDateTime);
End;

Procedure TJSONParam.SetAsDate(Value: TDateTime);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovDate);
End;

Procedure TJSONParam.SetAsTime(Value: TDateTime);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovTime);
End;

Function TJSONParam.GetAsSingle: Single;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovSmallInt);
End;

Procedure TJSONParam.SetAsSingle(Value: Single);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovSmallInt);
End;

Function TJSONParam.GetAsFloat: Double;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovFloat);
End;

Procedure TJSONParam.SetAsFloat(Value: Double);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovFloat);
End;

Function TJSONParam.GetAsInteger: Integer;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovInteger);
End;

Procedure TJSONParam.SetAsInteger(Value: Integer);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovInteger);
End;

Function TJSONParam.GetAsWord: Word;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovWord);
End;

Procedure TJSONParam.SetAsWord(Value: Word);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovWord);
End;

Procedure TJSONParam.SetAsSmallInt(Value: Integer);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovSmallInt);
End;

Procedure TJSONParam.SetAsShortInt(Value: Integer);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovShortInt);
End;

Function TJSONParam.GetAsLongWord: LongWord;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovLongWord);
End;

Procedure TJSONParam.SetAsLongWord(Value: LongWord);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovLongWord);
End;

Function TJSONParam.GetAsLargeInt: LargeInt;
Begin
  If TestNilParam Then
    Exit;
  Result := GetValue(ovLargeInt);
End;

Procedure TJSONParam.SetAsLargeInt(Value: LargeInt);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovLargeInt);
End;

Procedure TJSONParam.SetObjectValue(Value: TObjectValue);
Begin
  If TestNilParam Then
    Exit;
  vObjectValue := Value;
  vBinary := vObjectValue In [ovStream, ovBlob, ovGraphic, ovOraBlob,
    ovOraClob];
End;

procedure TJSONParam.SetObjectDirection(Value: TObjectDirection);
begin
  If TestNilParam Then
    Exit;
  vObjectDirection := Value;
  vJSONValue.vObjectDirection := vObjectDirection;
end;

Function TJSONParam.GetByteString: String;
Var
  Stream: TStringStream;
  Streamb: TMemoryStream;
Begin
  If TestNilParam Then
    Exit;
  Streamb := Nil;
  Stream := TStringStream.Create('');
  Try
    Streamb := DecodeStream(GetValue(ovString));
    // HexToStream(GetValue(ovString), Stream);
    Streamb.Position := 0;
    Stream.CopyFrom(Streamb, Streamb.Size);
    Stream.Position := 0;
    Result := Stream.DataString;
  Finally
    Streamb.Free;
    Stream.Free;
  End;
End;

Procedure TJSONParam.SetAsObject(Value: String);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, ovObject);
End;

Procedure TJSONParam.SetEncoded(Value: Boolean);
Begin
  If TestNilParam Then
    Exit;
  vEncoded := Value;
  vJSONValue.Encoded := vEncoded;
End;

procedure TJSONParam.SetParamContentType(const bValue: String);
begin
  If TestNilParam Then
    Exit;
  vParamContentType := bValue;
end;

{$IFDEF RESTDWLAZARUS}

Procedure TJSONParam.SetDatabaseCharSet(Value: TDatabaseCharSet);
Begin
  vJSONValue.DatabaseCharSet := Value;
  vDatabaseCharSet := vJSONValue.DatabaseCharSet;
End;
{$ENDIF}

Function TJSONParam.TestNilParam: Boolean;
Begin
  Result := False;
  If Not Assigned(Self) Then
  Begin
    Result := True;
    Raise Exception.Create(cInvalidDWParam);
    Exit;
  End;
End;

Procedure TJSONParam.Clear;
Begin
  vNullValue := True;
  If vJSONValue <> Nil Then
  Begin
    vJSONValue.vNullValue := vNullValue;
    SetValue('');
  End;
End;

Constructor TJSONParam.Create(Encoding: TEncodeSelect);
Begin
  vJSONValue := TJSONValue.Create;
  vCripto := TCripto.Create;
  vDataMode := dmDataware;
  vEncoding := Encoding;
  vTypeObject := toParam;
  ObjectDirection := odINOUT;
  vObjectValue := ovString;
  vBinary := False;
  vJSONValue.vBinary := vBinary;
  vNullValue := Not vBinary;
  vEncoded := True;
  vAlias := '';
  vFloatDecimalFormat := '';
  vParamName := '';
  vParamFileName := '';
  vParamContentType := '';
  // vDefaultValue    : Variant;
  {$IFDEF RESTDWLAZARUS}
  vDatabaseCharSet := csUndefined;
  {$ENDIF}
End;

Destructor TJSONParam.Destroy;
Begin
  Clear;
  If vJSONValue <> Nil Then
    FreeAndNil(vJSONValue);
  If vCripto <> Nil Then
    FreeAndNil(vCripto);
  Inherited;
End;

Function TJSONParam.IsEmpty: Boolean;
Begin
  If TestNilParam Then
    Exit;
  Result := IsNull;
End;

Function TJSONParam.IsNull: Boolean;
Begin
  If TestNilParam Then
    Exit;
  Result := vNullValue;
End;

Procedure TJSONParam.FromJSON(json: String);
Var
  bJsonValue: TRESTDWJSONInterfaceObject;
  vValue: String;
Begin
  If TestNilParam Then
    Exit;
  vValue := StringReplace(json, '=', '', [rfReplaceAll]);
  If Pos(sLineBreak, vValue) > 0 Then
    vValue := StringReplace(vValue, sLineBreak, '', [rfReplaceAll])
  Else
    vValue := json;
  {$IFDEF RESTDWLAZARUS}
  If vEncoding = esUtf8 Then
    bJsonValue := TRESTDWJSONInterfaceObject.Create
      (PWidechar(UTF8Decode(vValue)))
  Else
    bJsonValue := TRESTDWJSONInterfaceObject.Create(vValue);
  {$ELSE}
  bJsonValue := TRESTDWJSONInterfaceObject.Create(vValue);
  {$ENDIF}
  Try
    vValue := CopyValue(vValue);
    If bJsonValue.PairCount > 0 Then
    Begin
      vTypeObject := GetObjectName(bJsonValue.pairs[0].Value);
      vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
      vEncoded := GetBooleanFromString(bJsonValue.pairs[2].Value);
      vObjectValue := GetValueType(bJsonValue.pairs[3].Value);
      vParamName := Lowercase(bJsonValue.pairs[4].Name);
      If vObjectValue = ovGuid Then
        vValue := DecodeStrings(vValue{$IFDEF RESTDWLAZARUS},
          csUndefined{$ENDIF});
      WriteValue(vValue);
      vBinary := vObjectValue in [ovBytes, ovVarBytes, ovStream, ovBlob,
        ovGraphic, ovOraBlob, ovOraClob];
      vJSONValue.vBinary := vBinary;
    End;
  Finally
    bJsonValue.Free;
  End;
End;

Procedure TJSONParam.Assign(Source: TObject);
Var
  Src: TJSONParam;
  aStream: TStream;
Begin
  If Source Is TJSONParam Then
  Begin
    Src := TJSONParam(Source);
    vDataMode := Src.DataMode;
    vEncoded := Src.Encoded;
    vJSONValue.DataMode := Src.vDataMode;
    vJSONValue.vEncoded := Src.vEncoded;
    vBinary := Src.vObjectValue in [ovStream, ovBlob, ovGraphic, ovOraBlob,
      ovOraClob];
    vJSONValue.ObjectValue := Src.vObjectValue;
    If vJSONValue.ObjectValue in [ovBlob, ovStream, ovBytes] Then
    Begin
      aStream := TMemoryStream.Create;
      Try
        Src.SaveToStream(aStream);
        aStream.Position := 0;
        LoadFromStream(aStream);
      Finally
        FreeAndNil(aStream);
      End;
    End
    Else
      Value := Src.Value;
  End
  Else
    Raise Exception.Create(cInvalidDWParam);
End;

Function TJSONParam.ToJSON: String;
Begin
  If TestNilParam Then
    Exit;
  vJSONValue.Encoded := vEncoded;
  vJSONValue.DataMode := vDataMode;
  vJSONValue.TypeObject := vTypeObject;
  vJSONValue.vtagName := vParamName;
  vJSONValue.vObjectValue := vObjectValue;
  Result := vJSONValue.ToJSON;
  If vDataMode = dmRaw Then
  Begin
    If Not(((Pos('{', Result) > 0) And (Pos('}', Result) > 0)) Or
      ((Pos('[', Result) > 0) And (Pos(']', Result) > 0))) Then
      Result := Format('"%s" : "%s"', [vParamName, vJSONValue.ToJSON]);
  End;
End;

Procedure TJSONParam.SaveToFile(FileName: String);
Var
  vStringStream: TStream;
  vFileStream: TFileStream;
Begin
  vStringStream := Nil;
  If TestNilParam Then
    Exit;
  SaveToStream(vStringStream);
  vStringStream.Position := 0;
  Try
    {$IFDEF RESTDWLAZARUS}
    vStringStream.Position := 0;
    vFileStream := TFileStream.Create(FileName, fmCreate);
    Try
      vFileStream.CopyFrom(vStringStream, vStringStream.Size);
    Finally
      vFileStream.Free;
    End;
    {$ELSE}
    {$IFDEF DELPHIXEUP} // Delphi 2010 pra cima
    vStringStream.Position := 0;
    TMemoryStream(vStringStream).SaveToFile(FileName);
    {$ELSE}
    vStringStream.Position := 0;
    vFileStream := TFileStream.Create(FileName, fmCreate);
    Try
      vFileStream.CopyFrom(vStringStream, vStringStream.Size);
    Finally
      vFileStream.Free;
    End;
    {$ENDIF}
    {$ENDIF}
  Finally
    vStringStream.Free;
  End;
End;

Procedure TJSONParam.CopyFrom(JSONParam: TRESTDWParamMethod);
Begin
  If TestNilParam Then
    Exit;
  Try
    Self.vTypeObject := JSONParam.vTypeObject;
    Self.vObjectDirection := JSONParam.vObjectDirection;
    Self.vEncoded := JSONParam.vEncoded;
    Self.vObjectValue := JSONParam.vObjectValue;
    Self.vAlias := JSONParam.vAlias;
    Self.vParamName := JSONParam.vParamName;
  Finally
  End;
End;

Procedure TJSONParam.CopyFrom(JSONParam: TJSONParam);
Var
  vValue: String;
  vStream: TStream;
Begin
  If TestNilParam Then
    Exit;
  Try
    Self.vTypeObject := JSONParam.vTypeObject;
    Self.vObjectDirection := JSONParam.vObjectDirection;
    Self.vEncoded := JSONParam.vEncoded;
    Self.vObjectValue := JSONParam.vObjectValue;
    Self.vParamName := JSONParam.vParamName;
    Self.vAlias := JSONParam.vAlias;
    If JSONParam.ObjectValue in [ovBytes, ovVarBytes, ovStream, ovBlob,
      ovGraphic, ovOraBlob, ovOraClob] Then
    Begin
      vStream := TMemoryStream.Create;
      Try
        JSONParam.SaveToStream(vStream);
        vStream.Position := 0;
        LoadFromStream(vStream);
      Finally
        FreeAndNil(vStream);
      End;
    End
    Else
    Begin
      vValue := JSONParam.Value;
      Self.SetValue(vValue, Self.vEncoded);
    End;
  Finally
  End;
End;

Procedure TJSONParam.SetVariantValue(Value: Variant);
Begin
  If TestNilParam Then
    Exit;
  SetDataValue(Value, vObjectValue);
End;

Procedure TJSONParam.SetDataValue(Value: Variant; DataType: TObjectValue);
Var
  ms: TMemoryStream;
  p: Pointer;
  vDateTime: TDateTime;
Begin
  If TestNilParam Then
    Exit;
  ms := Nil;
  If (VarIsNull(Value)) Or (VarIsEmpty(Value)) Or
    (DataType in [ovBytes, ovVarBytes, ovStream, ovBlob, ovByte, ovGraphic,
    ovParadoxOle, ovDBaseOle, ovTypedBinary, ovOraBlob, ovOraClob]) Then
    Exit;
  vObjectValue := DataType;
  Case vObjectValue Of
    ovBytes, ovVarBytes, ovBlob, ovByte, ovGraphic, ovParadoxOle, ovDBaseOle,
      ovTypedBinary, ovOraBlob, ovOraClob, ovStream:
      Begin
        ms := TMemoryStream.Create;
        Try
          ms.Position := 0;
          p := VarArrayLock(Value);
          ms.Write(p^, VarArrayHighBound(Value, 1));
          VarArrayUnlock(Value);
          ms.Position := 0;
          If ms.Size > 0 Then
            LoadFromStream(ms);
        Finally
          ms.Free;
        End;
      End;
    ovVariant, ovUnknown:
      Begin
        vEncoded := True;
        vObjectValue := ovString;
        SetValue(Value, vEncoded);
      End;
    ovLargeInt, ovLongWord, ovShortInt, ovSmallInt, ovInteger, ovWord,
      ovBoolean, ovAutoInc, ovOraInterval:
      Begin
        vEncoded := False;
        If vObjectValue = ovBoolean Then
        Begin
          If Boolean(Value) then
            SetValue('true', vEncoded)
          Else
            SetValue('false', vEncoded);
        End
        Else
        Begin
          {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
          If vObjectValue <> ovInteger Then
            SetValue(IntToStr(Int64(Value)), vEncoded)
          Else
            SetValue(IntToStr(Value), vEncoded);
          {$ELSE}
          SetValue(IntToStr(Value), vEncoded);
          {$IFEND}
        End;
      End;
    ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended:
      Begin
        vEncoded := False;
        vObjectValue := ovFloat;
        SetValue(BuildStringFloat(FloatToStr(Value), DataMode,
          vFloatDecimalFormat), vEncoded);
      End;
    ovDate, ovTime, ovDateTime, ovTimeStamp, ovOraTimeStamp, ovTimeStampOffset:
      Begin
        vEncoded := False;
        vObjectValue := ovFloat;
        SetValue(BuildStringFloat(FloatToStr(Value), DataMode,
          vFloatDecimalFormat), vEncoded);
      End;
    ovString, ovFixedChar, ovWideString, ovWidememo, ovFixedWideChar, ovMemo,
      ovFmtMemo, ovObject:
      Begin
        If vObjectValue <> ovObject then
          vObjectValue := ovString
        Else
          vObjectValue := ovObject;
        SetValue(Value, vEncoded);
      End;
  End;
End;

Function TJSONParam.GetVariantValue: Variant;
Var
  ms: TMemoryStream;
  MyBuffer: Pointer;
Begin
  If TestNilParam Then
    Exit;
  ms := Nil;
  Case vObjectValue Of
    ovVariant, ovUnknown, ovObject:
      Result := vJSONValue.Value;
    ovGuid, ovString, ovFixedChar, ovWideString, ovWidememo, ovFixedWideChar,
      ovMemo, ovFmtMemo:
      Begin
        If IsNull Then
          Result := ''
        Else
        Begin
          If vCripto.Use Then
            Result := vCripto.Decrypt(vJSONValue.Value)
          Else
            Result := vJSONValue.Value;
        End;
      End;
    ovLargeInt, ovLongWord, ovShortInt, ovSmallInt, ovInteger, ovWord,
      ovBoolean, ovAutoInc, ovOraInterval:
      Begin
        If IsNull Then
          Result := 0
        Else
        Begin
          If vJSONValue.ObjectValue = ObjectValue then
            Result := vJSONValue.Value
          Else
          Begin
            If (vJSONValue.Value <> '') And
              (Lowercase(vJSONValue.Value) <> 'null') Then
            Begin
              If vObjectValue = ovBoolean Then
                Result := (vJSONValue.Value = '1') Or
                  (Lowercase(vJSONValue.Value) = 'true')
              Else If (Trim(vJSONValue.Value) <> '') And
                (Trim(vJSONValue.Value) <> 'null') Then
              Begin
                If vObjectValue in [ovLargeInt, ovLongWord] Then
                  Result := StrToInt64(vJSONValue.Value)
                Else
                  Result := StrToInt(vJSONValue.Value);
              End;
            End
            Else
              Result := Null;
          End;
        End;
      End;
    ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended:
      Begin
        If IsNull Then
          Result := 0
        Else
        Begin
          If vJSONValue.ObjectValue = ObjectValue then
            Result := vJSONValue.Value
          Else
          Begin
            If (vJSONValue.Value <> '') And
              (Lowercase(vJSONValue.Value) <> 'null') Then
              Result := StrToFloat(BuildFloatString(vJSONValue.Value))
            Else
              Result := Null;
          End;
        End;
      End;
    ovDate, ovTime, ovDateTime, ovTimeStamp, ovOraTimeStamp, ovTimeStampOffset:
      Begin
        If IsNull Then
          Result := Null
        Else
        Begin
          If vJSONValue.ObjectValue = ObjectValue then
            Result := vJSONValue.Value
          Else
          Begin
            If (vJSONValue.Value <> '') And
              (Lowercase(vJSONValue.Value) <> 'null') Then
              Result := StrToFloat(vJSONValue.Value)
            Else
              Result := Null;
          End;
        End;
      End;
    ovBytes, ovVarBytes, ovBlob, ovByte, ovGraphic, ovParadoxOle, ovDBaseOle,
      ovTypedBinary, ovOraBlob, ovOraClob, ovStream:
      Begin
        If IsNull Then
          Result := Null
        Else
        Begin
          ms := TMemoryStream.Create;
          Try
            vJSONValue.SaveToStream(ms);
            If ms.Size > 0 Then
            Begin
              ms.Position := 0;
              Result := VarArrayCreate([0, ms.Size - 1], VarByte);
              MyBuffer := VarArrayLock(Result);
              ms.ReadBuffer(MyBuffer^, ms.Size);
              VarArrayUnlock(Result);
            End
            Else
              Result := Null;
          Finally
            ms.Free;
          End;
        End;
      End;
  End;
End;

Function TJSONParam.GetNullValue(Value: TObjectValue): Variant;
Begin
  If TestNilParam Then
    Exit;
  Case Value Of
    ovVariant, ovUnknown:
      Result := Null;
    ovString, ovFixedChar, ovWideString, ovWidememo, ovFixedWideChar, ovMemo,
      ovFmtMemo:
      Result := '';
    ovLargeInt, ovLongWord, ovShortInt, ovSmallInt, ovInteger, ovWord,
      ovBoolean, ovAutoInc, ovOraInterval:
      Result := 0;
    ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended:
      Result := 0;
    ovDate, ovTime, ovDateTime, ovTimeStamp, ovOraTimeStamp, ovTimeStampOffset:
      Result := 0;
    ovBytes, ovVarBytes, ovBlob, ovByte, ovGraphic, ovParadoxOle, ovDBaseOle,
      ovTypedBinary, ovOraBlob, ovOraClob, ovStream:
      Result := Null;
  End;
End;

Function TJSONParam.GetValue(Value: TObjectValue): Variant;
Var
  ms: TMemoryStream;
  MyBuffer: Pointer;
Begin
  If TestNilParam Then
    Exit;
  ms := Nil;
  vJSONValue.TypeObject := vTypeObject;
  Case Value Of
    ovVariant, ovUnknown:
      Result := vJSONValue.Value;
    ovString, ovFixedChar, ovWideString, ovWidememo, ovFixedWideChar, ovMemo,
      ovFmtMemo:
      Begin
        Result := vJSONValue.Value;
        If VarIsNull(Result) Then
          Result := GetNullValue(Value)
        Else
        Begin
          If vJSONValue.ObjectValue in [ovString, ovFixedChar,
            ovWideString] Then
            If vCripto.Use Then
              Result := vCripto.Decrypt(Result);
        End;
      End;
    ovLargeInt, ovLongWord, ovShortInt, ovSmallInt, ovInteger, ovWord,
      ovBoolean, ovAutoInc, ovOraInterval:
      Begin
        If vJSONValue.ObjectValue = Value Then
        Begin
          Result := vJSONValue.Value;
          If VarIsNull(Result) Then
            Result := GetNullValue(Value);
        End
        Else
        Begin
          If (Not(vJSONValue.IsNull)) Then
          Begin
            If Value = ovBoolean Then
              Result := (vJSONValue.Value = '1') Or
                (Lowercase(vJSONValue.Value) = 'true')
            Else If (Trim(vJSONValue.Value) <> '') And
              (Trim(vJSONValue.Value) <> 'null') Then
            Begin
              If Value in [ovLargeInt, ovLongWord] Then
                Result := StrToInt64(vJSONValue.Value)
              Else
                Result := StrToInt(vJSONValue.Value);
            End
            Else
              Result := GetNullValue(Value);
          End
          Else
            Result := GetNullValue(Value);
        End;
      End;
    ovSingle, ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended:
      Begin
        If vJSONValue.ObjectValue = Value Then
        Begin
          Result := vJSONValue.Value;
          If VarIsNull(Result) Then
            Result := GetNullValue(Value);
        End
        Else
        Begin
          If (Not(vJSONValue.IsNull)) Then
          Begin
            If (Trim(vJSONValue.Value) <> '') And
              (Trim(vJSONValue.Value) <> 'null') Then
              Result := StrToFloat(BuildFloatString(vJSONValue.Value))
            Else
              Result := GetNullValue(Value);
          End
          Else
            Result := GetNullValue(Value);
        End;
      End;
    ovDate, ovTime, ovDateTime, ovTimeStamp, ovOraTimeStamp, ovTimeStampOffset:
      Begin
        If vJSONValue.ObjectValue = Value Then
        Begin
          Result := vJSONValue.Value;
          If VarIsNull(Result) Then
            Result := GetNullValue(Value);
        End
        Else
        Begin
          If (Not(vJSONValue.IsNull)) Then
          Begin
            If (Trim(vJSONValue.Value) <> '') And
              (Trim(vJSONValue.Value) <> 'null') Then
              Result := StrToFloat(BuildFloatString(vJSONValue.Value))
            Else
              Result := GetNullValue(Value);
          End
          Else
            Result := GetNullValue(Value);
        End;
      End;
    ovBytes, ovVarBytes, ovBlob, ovByte, ovGraphic, ovParadoxOle, ovDBaseOle,
      ovTypedBinary, ovOraBlob, ovOraClob, ovStream:
      Begin
        ms := TMemoryStream.Create;
        Try
          vJSONValue.SaveToStream(ms);
          If ms.Size > 0 Then
          Begin
            Result := VarArrayCreate([0, ms.Size - 1], VarByte);
            MyBuffer := VarArrayLock(Result);
            ms.ReadBuffer(MyBuffer^, ms.Size);
            VarArrayUnlock(Result);
          End
          Else
            Result := GetNullValue(Value);
        Finally
          ms.Free;
        End
      End;
  End;
End;

Procedure TJSONParam.SetValue(aValue: TStream);
Begin
  If TestNilParam Then
    Exit;
  vJSONValue.DataMode := vDataMode;
  vJSONValue.vEncoded := False;
  vBinary := vObjectValue in [ovStream, ovBlob, ovGraphic, ovOraBlob,
    ovOraClob];
  vJSONValue.ObjectValue := vObjectValue;
  If (vNullValue) And (aValue.Size = 0) Then
    WriteValue(Null)
  Else
    WriteValue(aValue);
  vJSONValue.vBinary := True;
End;

Procedure TJSONParam.SetValue(aValue: String; Encode: Boolean);
Begin
  If TestNilParam Then
    Exit;
  vEncoded := Encode;
  vJSONValue.DataMode := vDataMode;
  vJSONValue.vEncoded := vEncoded;
  vBinary := vObjectValue in [ovStream, ovBlob, ovGraphic, ovOraBlob,
    ovOraClob];
  vJSONValue.ObjectValue := vObjectValue;
  If (vNullValue) And ((aValue = '') Or (aValue = cNullvalue)) Then
    WriteValue(Null)
  Else
  Begin
    If (Encode) And Not(vBinary) Then
    Begin
      // If vEncoding = esUtf8 Then
      // WriteValue(EncodeStrings(aValue{$IFDEF RESTDWLAZARUS}, vDatabaseCharSet{$ENDIF}))
      // Else
      WriteValue(EncodeStrings(aValue{$IFDEF RESTDWLAZARUS},
        vDatabaseCharSet{$ENDIF}))
    End
    Else
      WriteValue(aValue);
  End;
  vJSONValue.vBinary := vBinary;
End;

Procedure TJSONParam.ToBytes(Value: String; Encode: Boolean);
Begin
  If TestNilParam Then
    Exit;
  vJSONValue.DataMode := vDataMode;
  vObjectValue := ovBlob;
  vBinary := vObjectValue in [ovStream, ovBlob, ovGraphic, ovOraBlob,
    ovOraClob];
  If vBinary Then
    vJSONValue.ToBytes(Value);
  vEncoded := Encoded;
  vJSONValue.vEncoded := vEncoded;
End;

Procedure TJSONParam.LoadFromStream(Stream: TMemoryStream);
Begin
  If TestNilParam Then
    Exit;
  ObjectValue := ovBlob;
  vEncoded := False;
  SetValue(Stream);
  vBinary := True;
  vJSONValue.Binary := vBinary;
End;

Procedure TJSONParam.LoadFromStream(Stream: TStringStream);
Begin
  If TestNilParam Then
    Exit;
  ObjectValue := ovBlob;
  vEncoded := False;
  SetValue(Stream);
  vBinary := True;
  vJSONValue.Binary := vBinary;
End;

Procedure TJSONParam.CopyFromStream(Stream: TStream; Count: DWInt64);
Begin
  If Stream.Size > 0 Then
  Begin
    vJSONValue.BeginBytes(Stream.Size);
    Stream.Read(Pointer(vJSONValue.AsBytes)^, Stream.Size);
  End;
End;

Procedure TJSONParam.LoadFromStream(Stream: TStream);
Begin
  If TestNilParam Then
    Exit;
  Try
    If Assigned(Stream) Then
      LoadFromStream(TMemoryStream(Stream));
  Finally
  End;
End;

Procedure TJSONParam.SaveToStream(Var Stream: TStream);
Var
  aValue: TRESTDWBytes;
Begin
  If TestNilParam Then
    Exit;
  aValue := vJSONValue.AsBytes;
  If Not Assigned(Stream) Then
    Stream := TMemoryStream.Create;
  Try
    If Length(aValue) > 0 Then
      Stream.Write(aValue[0], Length(aValue));
    Stream.Position := 0;
  Except

  End;
End;

Procedure TJSONParam.SaveToStream(Var Stream: TStringStream);
Begin
  If TestNilParam Then
    Exit;
  If Not Assigned(Stream) Then
    Stream := TStringStream.Create('');
  SaveToStream(TStream(Stream));
End;

Procedure TJSONParam.SaveToStream(Var Stream: TMemoryStream);
Begin
  If TestNilParam Then
    Exit;
  If Not Assigned(Stream) Then
    Stream := TMemoryStream.Create;
  SaveToStream(TStream(Stream));
End;

// Aqui Le os parametros tem que estar syncronizado com a escria dos parametros
// Alterado por Abrito
Procedure TJSONParam.LoadFromParam(Param: TParam);
Var
  MemoryStream: TMemoryStream;
  {$IFDEF DELPHIXEUP}
  MemoryStream2: TStream;
  {$ENDIF}
Begin
  If TestNilParam Then
    Exit;
  MemoryStream := Nil;
  If Param.IsNull Then
  Begin
    vNullValue := True;
    SetValue('');
  End
  Else If Param.DataType in [ftString, ftWideString, ftMemo, ftGuid,
  {$IFDEF DELPHIXEUP}ftWideMemo, {$ENDIF}
  ftFmtMemo, ftFixedChar] Then
  Begin
    // vEncoded := Not (Param.DataType in [{$IFDEF DELPHIXEUP}ftWideMemo,{$ENDIF}
    // ftMemo, ftFmtMemo]);
    if (Param.DataType in [{$IFDEF DELPHIXEUP}ftWideString{$ENDIF}]) then
      SetValue(EncodeStrings(Param.AsString{$IFDEF RESTDWLAZARUS},
        csUndefined{$ENDIF}))
    else
      SetValue(Param.AsString, vEncoded);
    vEncoded := True;
  End
  Else If Param.DataType in [{$IFDEF DELPHIXEUP}ftLongWord, ftExtended,
    ftSingle, ftShortint, {$ENDIF}
  ftAutoInc, ftInteger, ftSmallint, ftLargeint, ftFloat, ftCurrency, ftFMTBcd,
    ftBCD] Then
    SetValue(BuildStringFloat(Param.AsString, DataMode,
      vFloatDecimalFormat), False)
  Else If Param.DataType In [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob,
    ftOraClob] Then
  Begin
    MemoryStream := TMemoryStream.Create;
    Try
      {$IF Defined(RESTDWLAZARUS) or not(Defined(DELPHIXEUP))}
      Param.SetData(MemoryStream);
      {$ELSE}
      MemoryStream2 := Param.AsStream;
      MemoryStream.CopyFrom(MemoryStream2, -1);
      If Assigned(MemoryStream2) Then
        FreeAndNil(MemoryStream2);
      {$IFEND}
      LoadFromStream(MemoryStream);
      vEncoded := False;
    Finally
      MemoryStream.Free;
    End;
  End
  Else If Param.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
  Begin
    If Param.DataType = ftDate Then
      SetValue(FloatToStr(Param.AsDate), False)
    Else if Param.DataType = ftTime then
      SetValue(FloatToStr(Param.AsTime), False)
    Else
      SetValue(FloatToStr(Param.AsDateTime), False);
  End
  Else If Param.DataType in [ftBoolean] Then
    SetValue(GetStringFromBoolean(Param.AsBoolean), False);
  vObjectValue := FieldTypeToObjectValue(Param.DataType);
  vParamName := Param.Name;
  vEncoded := vObjectValue in [ovWidememo, ovString, ovGuid, ovWideString,
    ovBlob, ovStream, ovGraphic, ovOraBlob, ovOraClob];
  vJSONValue.vObjectValue := vObjectValue;
End;

Procedure TJSONParam.SaveFromParam(Param: TParam);
Var
  ms: TStream;
Begin
  If Not Assigned(Param) Then
    Exit;
  If IsNull Then
    Param.Clear;
  If vObjectValue in [ovBlob, ovStream, ovBytes] Then
  Begin
    ms := TMemoryStream.Create;
    Try
      SaveToStream(ms);
      ms.Position := 0;
      Param.LoadFromStream(ms, ftBlob);
    Finally
      ms.Free;
    End;
  End
  Else
    Param.Value := Value;
End;

Procedure TRESTDWParams.Assign(Source: TList);
Var
  Src: TRESTDWParams;
  I: Integer;
  vJSONParam: TJSONParam;
Begin
  If Source is TRESTDWParams Then
  Begin
    Src := TRESTDWParams(Source);
    For I := 0 To Src.Count - 1 Do
    Begin
      vJSONParam := ItemsString[Src[I].ParamName];
      If vJSONParam = Nil Then
      Begin
        vJSONParam := TJSONParam.Create(Encoding);
        vJSONParam.Assign(Src[I]);
        Add(vJSONParam);
      End
      Else
        vJSONParam.Assign(Src[I]);
    End;
  End
  Else
    Raise Exception.Create(cInvalidDWParams);
End;

Function TRESTDWParams.GetRec(Index: Integer): TJSONParam;
Begin
  Result := Nil;
  If (Index < Self.Count) And (Index > -1) Then
    Result := TJSONParam(TList(Self).Items[Index]^);
End;

Procedure TRESTDWParams.PutRec(Index: Integer; Item: TJSONParam);
Begin
  If (Index < Self.Count) And (Index > -1) Then
    TJSONParam(TList(Self).Items[Index]^) := Item;
End;

Function TRESTDWParams.GetRecName(Index: String): TJSONParam;
Var
  I: Integer;
Begin
  Result := Nil;
  If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
    For I := 0 To Self.Count - 1 Do
    Begin
      If (Uppercase(Index) = Uppercase(TJSONParam(TList(Self).Items[I]^)
        .vParamName)) Or
        (Lowercase(Index) = Lowercase(TJSONParam(TList(Self).Items[I]^)
        .vAlias)) Then
      Begin
        Result := TJSONParam(TList(Self).Items[I]^);
        Break;
      End;
    End;
  End;
End;

Function TRESTDWParams.GetRawBody: TJSONParam;
Var
  I: Integer;
Begin
  Result := Nil;
  If Assigned(Self) Then
    Result := ItemsString[cUndefined];
End;

Procedure TRESTDWParams.PutRecName(Index: String; Item: TJSONParam);
Var
  I: Integer;
  vNotFount: Boolean;
Begin
  vNotFount := True;
  If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
    For I := 0 To Self.Count - 1 Do
    Begin
      If (Lowercase(Index) = Lowercase(TJSONParam(TList(Self).Items[I]^)
        .vParamName)) Or
        (Lowercase(Index) = Lowercase(TJSONParam(TList(Self).Items[I]^)
        .vAlias)) Then
      Begin
        TJSONParam(TList(Self).Items[I]^) := Item;
        vNotFount := False;
        Break;
      End;
    End;
  End;
  If vNotFount Then
  Begin
    Item := TJSONParam.Create(Encoding);
    Item.ParamName := Index;
    Add(Item);
  End;
End;

Procedure TRESTDWParams.PutRawBody(Item: TJSONParam);
Var
  I: Integer;
  vNotFount: Boolean;
Begin
  vNotFount := True;
  If Assigned(Self) Then
  Begin
    For I := 0 To Self.Count - 1 Do
    Begin
      If (Lowercase(cUndefined) = Lowercase(TJSONParam(TList(Self).Items[I]^)
        .vParamName)) Or
        (Lowercase(cUndefined) = Lowercase(TJSONParam(TList(Self).Items[I]^)
        .vAlias)) Then
      Begin
        TJSONParam(TList(Self).Items[I]^) := Item;
        vNotFount := False;
        Break;
      End;
    End;
  End;
  If vNotFount Then
  Begin
    Item := TJSONParam.Create(Encoding);
    Item.ParamName := cUndefined;
    Add(Item);
  End;
End;

Procedure TRESTDWParams.Clear;
Begin
  ClearList;
  Inherited Clear;
End;

Procedure TRESTDWParams.ClearList;
Var
  I: Integer;
Begin
  For I := Count - 1 Downto 0 Do
    Delete(I);
End;

Destructor TRESTDWParams.Destroy;
Begin
  Clear;
  FreeAndNil(vCripto);
  FreeAndNil(vHeaders);
  Inherited;
End;

Constructor TRESTDWParams.Create;
Begin
  Inherited;
  vCripto := TCripto.Create;
  vDataMode := dmDataware;
  vHeaders := TRESTDWHeaders.Create;
  vUrl_Redirect := '';
  {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
  vEncoding := esUtf8;
  {$ELSE}
  vEncoding := esASCII;
  {$IFEND}
  {$IFDEF RESTDWLAZARUS}
  vDatabaseCharSet := csUndefined;
  {$ENDIF}
End;

Procedure TRESTDWParams.CreateParam(ParamName: String; Value: String = '');
Var
  vItem: TJSONParam;
Begin
  vItem := ItemsString[ParamName];
  If vItem = Nil Then
  Begin
    vItem := TJSONParam.Create(Encoding);
    vItem.ParamName := ParamName;
    If Value <> '' Then
      vItem.AsString := Value;
    Add(vItem);
  End
  Else
  Begin
    If Value <> '' Then
      vItem.AsString := Value;
  End;
End;

Function TRESTDWParams.ParamsReturn: Boolean;
Var
  I: Integer;
Begin
  Result := False;
  If Assigned(Self) Then
  Begin
    For I := 0 To Self.Count - 1 Do
    Begin
      Result := Items[I].vObjectDirection In [odOUT, odINOUT];
      If Result Then
        Break;
    End;
  End;
End;

Function TRESTDWParams.CountOutParams: Integer;
Var
  I: Integer;
Begin
  Result := 0;
  For I := 0 To Count - 1 Do
  Begin
    If TJSONParam(TList(Self).Items[I]^).ObjectDirection
      in [odOUT, odINOUT] Then
      Result := Result + 1;
  End;
End;

Function TRESTDWParams.CountInParams: Integer;
Var
  I: Integer;
Begin
  Result := 0;
  For I := 0 To Count - 1 Do
  Begin
    If TJSONParam(TList(Self).Items[I]^).ObjectDirection in [odIN, odINOUT] Then
      Result := Result + 1;
  End;
End;

Function TRESTDWParams.ToJSON: String;
Var
  I: Integer;
Begin
  Result := 'null';
  If Assigned(Self) Then
  Begin
    For I := 0 To Self.Count - 1 Do
    Begin
      If TJSONParam(TList(Self).Items[I]^).vObjectValue <> ovUnknown Then
      Begin
        TJSONParam(TList(Self).Items[I]^).DataMode := DataMode;
        If I = 0 Then
          Result := TJSONParam(TList(Self).Items[I]^).ToJSON
        Else
          Result := Result + ', ' + TJSONParam(TList(Self).Items[I]^).ToJSON;
      End;
    End;
    Result := Format('{%s}', [Result]);
  End;
End;

Procedure TRESTDWParams.SaveToFile(FileName: String);
Var
  vStringStream: TStream;
Begin
  SaveToStream(vStringStream);
  vStringStream.Position := 0;
  Try
    TMemoryStream(vStringStream).SaveToFile(FileName);
  Finally
    vStringStream.Free;
  End;
End;

Procedure TRESTDWParams.FromJSON(json: String; BinaryRequest: Boolean = False);
Var
  bJsonOBJ, bJsonValue: TRESTDWJSONInterfaceObject;
  bJsonArray: TRESTDWJSONInterfaceArray;
  JSONParam: TJSONParam;
  I: Integer;
  vTempString: String;
  // BinaryRequest
  vParam: TParam;
  vStringStream: TStringStream;
Begin
  ClearList;
  If (Lowercase(json) = cNullvalue) Or (json = '') Then
    Exit;
  If Not BinaryRequest Then
  Begin
    vTempString := Format('{"PARAMS":[%s]}', [json]);
    bJsonValue := TRESTDWJSONInterfaceObject.Create(vTempString);
    bJsonArray := bJsonValue.openArray(bJsonValue.pairs[0].Name);
  End
  Else
  Begin
    vParam := TParam.Create(Nil);
    bJsonValue := TRESTDWJSONInterfaceObject.Create(json);
    bJsonArray := TRESTDWJSONInterfaceArray(bJsonValue);
  End;
  Try
    For I := 0 To bJsonArray.ElementCount - 1 Do
    Begin
      bJsonOBJ := TRESTDWJSONInterfaceObject(bJsonArray.GetObject(I));
      CreateParam(Lowercase(bJsonOBJ.pairs[4].Name), '');
      JSONParam := ItemsString[Lowercase(bJsonOBJ.pairs[4].Name)];
      If Not BinaryRequest Then
      Begin
        Try
          JSONParam.ParamName := Lowercase(bJsonOBJ.pairs[4].Name);
          JSONParam.ObjectDirection :=
            GetDirectionName(bJsonOBJ.pairs[1].Value);
          JSONParam.ObjectValue := GetValueType(bJsonOBJ.pairs[3].Value);
          JSONParam.Encoded := GetBooleanFromString(bJsonOBJ.pairs[2].Value);
          If Not bJsonOBJ.pairs[4].IsNull Then
          Begin
            If (JSONParam.ObjectValue in [ovString, ovGuid, ovWideString]) And
              (JSONParam.Encoded) Then
            Begin
              JSONParam.SetValue
                (DecodeStrings(bJsonOBJ.pairs[4].Value{$IFDEF RESTDWLAZARUS},
                csUndefined{$ENDIF}));
            End
            Else
              JSONParam.SetValue(bJsonOBJ.pairs[4].Value, JSONParam.Encoded);
          End
          Else
            JSONParam.SetValue('null', JSONParam.Encoded);
        Finally
          bJsonOBJ.Free;
        End;
      End
      Else
      Begin
        vStringStream := TStringStream.Create
          (DecodeStrings(bJsonOBJ.pairs[0].Value{$IFDEF RESTDWLAZARUS},
          csUndefined{$ENDIF}));
        Try
          vStringStream.Position := 0;
          TRESTDWPropertyPersist(vParam).LoadFromStream(vStringStream);
          JSONParam.ParamName := vParam.Name;
          JSONParam.ObjectValue := FieldTypeToObjectValue(vParam.DataType);
          JSONParam.LoadFromParam(vParam);
          Add(JSONParam);
        Finally
          vStringStream.Free;
          bJsonOBJ.Free;
        End;
      End;
    End;
  Finally
    If Not BinaryRequest Then
      bJsonArray.Free;
    bJsonValue.Free;
    If BinaryRequest Then
      vParam.Free;
  End;
End;

Procedure TRESTDWParams.CopyFrom(DWParams: TRESTDWParams);
Var
  I: Integer;
  p, JSONParam: TJSONParam;
Begin
  ClearList;
  If Assigned(DWParams) Then
  Begin
    For I := 0 To DWParams.Count - 1 Do
    Begin
      p := DWParams.Items[I];
      JSONParam := TJSONParam.Create(DWParams.Encoding);
      JSONParam.CopyFrom(p);
      Add(JSONParam);
    End;
  End;
End;

Procedure TRESTDWParams.Delete(Index: Integer);
Begin
  If (Index < Self.Count) And (Index > -1) Then
  Begin
    Try
      If Assigned(TList(Self).Items[Index]) Then
      Begin
        {$IF Defined(RESTDWLAZARUS) or not(Defined(DELPHI10_4UP))}
        FreeAndNil(TList(Self).Items[Index]^);
        {$ELSE}
        FreeAndNil(TJSONParam(TList(Self).Items[Index]^));
        {$IFEND}
        Dispose(PJSONParam(TList(Self).Items[Index]));
      End;
    Except
    End;
    TList(Self).Delete(Index);
  End;
End;

Procedure TRESTDWParams.Delete(Param: TJSONParam);
Var
  I: Integer;
Begin
  For I := 0 To Count - 1 Do
  Begin
    If Items[I] = Param Then
    Begin
      Delete(I);
      Break;
    End;
  End;
End;

Function TRESTDWParams.Add(Item: TJSONParam): Integer;
Var
  vItem: PJSONParam;
Begin
  New(vItem);
  vItem^ := Item;
  vItem^.vEncoding := vEncoding;
  vItem^.DataMode := vDataMode;
  vItem^.CriptOptions.Use := vCripto.Use;
  vItem^.CriptOptions.Key := vCripto.Key;
  {$IFDEF RESTDWLAZARUS}
  vItem^.DatabaseCharSet := vDatabaseCharSet;
  {$ENDIF}
  Result := Inherited Add(vItem);
End;

Procedure TRESTDWParams.SaveToStream(Var Stream: TStream;
  Output: TDWParamExpType = tdwpxt_All);
Var
  ParamsHeader: TRESTDWParamsHeader;
  // vTempString  : String;
  {$IFNDEF DELPHIXEUP}
  aStream: TStringStream;
  {$ENDIF}
  aCount, I, Temp: Integer;
  EndPos, StartPos: Int64;
  Procedure SaveParamsToStream(Var Stream: TStream);
  Var
    vNull, I: Integer;
    J, L: DWInt64;
    {$IFDEF DELPHIXEUP}
    S, W: RawByteString;
    {$ELSE} // lazarus e delphi mofado
    S, W: AnsiString;
    {$ENDIF}
    Sing: Single;
    WordData: Word;
    B: Boolean;
    p: TStream;
    T: DWFieldTypeSize;
    D: TDateTime;
    aParam: TJSONParam;
    vBytesString: TRESTDWBytes;
  Begin
    For I := 0 To Count - 1 do
    Begin
      aParam := GetRec(I);
      // Define who go out
      If Output <> tdwpxt_All Then
      Begin
        If ((aParam.ObjectDirection = odIN) And (Output = tdwpxt_OUT)) Or
          ((aParam.ObjectDirection = odOUT) And (Output = tdwpxt_IN)) Then
          Continue;
      End;
      aCount := aCount + 1;
      // ParamName
      S := aParam.ParamName;
      L := Length(S);
      Stream.Write(L, Sizeof(DWInt64));
      {$IFNDEF RESTDWLAZARUS}
      If L <> 0 Then
        Stream.Write(S[InitStrPos], L);
      {$ELSE}
      If L <> 0 Then
        Stream.Write(UTF8Encode(S)[1], L);
      {$ENDIF}
      // ObjectDirection
      T := DWFieldTypeSize(aParam.ObjectDirection);
      Stream.Write(T, Sizeof(DWFieldTypeSize));
      // Encoded
      B := aParam.Encoded;
      Stream.Write(B, Sizeof(WordBool));
      // DataMode
      T := DWFieldTypeSize(aParam.DataMode);
      Stream.Write(T, Sizeof(DWFieldTypeSize));
      // TypeObject
      T := DWFieldTypeSize(aParam.vTypeObject);
      Stream.Write(T, Sizeof(DWFieldTypeSize));
      // DataType
      T := DWFieldTypeSize(aParam.ObjectValue);
      Stream.Write(T, Sizeof(DWFieldTypeSize));
      // GetValue from Datatype
      L := 0;
      vNull := 0;
      Case TObjectValue(T) Of
        ovFixedChar, ovWideString, ovString, ovObject:
          Begin
            SetLength(vBytesString, 0);
            If aParam.IsNull Then
            Begin
              L := vNull;
              Stream.Write(L, Sizeof(DWInt64));
            End
            Else
            Begin
              S := aParam.AsString;
              If S <> '' Then
                vBytesString := stringTobytes(S);
              L := Length(vBytesString);
              Stream.Write(L, Sizeof(DWInt64));
            End;
            If L <> 0 Then
              Stream.Write(vBytesString[0], L);
          End;
        ovSingle, ovInteger, ovAutoInc, ovSmallInt, ovLongWord, ovShortInt,
          ovLargeInt:
          Begin
            S := 'N';
            If (aParam.IsEmpty Or aParam.IsNull) Then
              S := TNullString;
            J := Length(S);
            Stream.Write(J, Sizeof(DWInteger));
            Stream.Write(S[InitStrPos], J);
            If S <> TNullString Then
            Begin
              If TObjectValue(T) = ovLargeInt Then
                J := aParam.AsLargeInt
              Else
                J := aParam.AsInteger;
              If TObjectValue(T) = ovLargeInt Then
                Stream.Write(J, Sizeof(DWInt64))
              Else
                Stream.Write(J, Sizeof(DWInt64));
            End;
          End;
        ovByte:
          Begin
            If aParam.IsNull Then
            Begin
              B := False;
              Stream.Write(B, Sizeof(Byte));
            End
            Else
            Begin
              B := aParam.AsBoolean;
              Stream.Write(B, Sizeof(Byte));
            End;
          End;
        ovBoolean:
          Begin
            If aParam.IsNull Then
            Begin
              B := False;
              Stream.Write(B, Sizeof(WordBool));
            End
            Else
            Begin
              B := aParam.AsBoolean;
              Stream.Write(B, Sizeof(WordBool));
            End;
          End;
        ovDate, ovTime, ovDateTime, ovTimeStamp, ovTimeStampOffset, ovCurrency,
          ovBCD, ovFMTBcd, ovFloat, ovExtended:
          Begin
            If (Not(aParam.IsEmpty) Or Not(aParam.IsNull)) Then
              S := BuildStringFloat(aParam.AsString)
            Else
              S := TNullString;
            J := Length(S);
            Stream.Write(J, Sizeof(DWInteger));
            Stream.Write(S[InitStrPos], J);
          End;
        ovWord:
          Begin
            If aParam.IsNull Then
            Begin
              WordData := vNull;
              Stream.Write(WordData, Sizeof(DWInteger));
            End
            Else
            Begin
              WordData := aParam.AsWord;
              Stream.Write(WordData, Sizeof(DWInteger));
            End;
          End;
        ovVariant:
          ;
        ovInterface:
          ;
        ovIDispatch:
          ;
        ovBlob, ovStream, ovBytes:
          Begin
            p := Nil;
            If Not aParam.IsNull Then
              aParam.SaveToStream(p);
            If Assigned(p) Then
            Begin
              L := p.Size;
              Stream.Write(L, Sizeof(DWInt64));
              p.Position := 0;
              If L <> 0 then
                Stream.CopyFrom(p, L);
              FreeAndNil(p);
            End
            Else
            Begin
              L := vNull;
              Stream.Write(L, Sizeof(DWInt64));
            End;
          End;
      End;
    End;
  End;

Begin
  aCount := 0;
  // vTempString := '';
  {$IF not(Defined(DELPHIXEUP)) and not(Defined(RESTDWLAZARUS))}
  If Not Assigned(Stream) Then
    Stream := TStringStream.Create('');
  aStream := TStringStream.Create('');
  Try
    // Write init Header
    StartPos := Stream.Position;
    With ParamsHeader Do
    Begin
      VersionNumber := RESTDWParamsHeaderVersion;
      DataSize := 0;
      Recordcount := 0;
      ParamsCount := Count;
    End;
    // Write dwParamsBinList
    SaveParamsToStream(TStream(aStream));
    // Remap Bin size
    EndPos := aStream.Size;
    ParamsHeader.DataSize := EndPos;
    ParamsHeader.ParamsCount := aCount;
    // Rewrite init Header
    Stream.Position := 0;
    aStream.Position := 0;
    Stream.Write(ParamsHeader, Sizeof(TRESTDWParamsHeader));
    Stream.CopyFrom(aStream, aStream.Size);
    Stream.Position := 0;
  Finally
    FreeAndNil(aStream);
  End;
  {$ELSEIF Defined(DELPHIXEUP)}
  If Not Assigned(Stream) Then
    Stream := TStringStream.Create('', TEncoding.UTF8);
  // Write init Header
  StartPos := Stream.Position;
  With ParamsHeader Do
  Begin
    VersionNumber := RESTDWParamsHeaderVersion;
    DataSize := 0;
    Recordcount := 0;
    ParamsCount := Count;
  End;
  Stream.Write(ParamsHeader, Sizeof(TRESTDWParamsHeader));
  // Write dwParamsBinList
  SaveParamsToStream(Stream);
  // Remap Bin size
  EndPos := Stream.Position;
  ParamsHeader.DataSize := EndPos - StartPos - Sizeof(TRESTDWParamsHeader);
  ParamsHeader.ParamsCount := aCount;
  // Rewrite init Header
  Stream.Position := StartPos;
  Stream.Write(ParamsHeader, Sizeof(TRESTDWParamsHeader));
  Stream.Position := 0;
  {$ELSE}
  If Not Assigned(Stream) Then
    Stream := TMemoryStream.Create;
  // Write init Header
  StartPos := Stream.Position;
  With ParamsHeader Do
  Begin
    VersionNumber := RESTDWParamsHeaderVersion;
    DataSize := 0;
    Recordcount := 0;
    ParamsCount := Count;
  End;
  Stream.Write(ParamsHeader, Sizeof(TRESTDWParamsHeader));
  // Write dwParamsBinList
  SaveParamsToStream(Stream);
  // Remap Bin size
  EndPos := Stream.Position;
  ParamsHeader.DataSize := EndPos - StartPos - Sizeof(TRESTDWParamsHeader);
  ParamsHeader.ParamsCount := aCount;
  // Rewrite init Header
  Stream.Position := StartPos;
  Stream.Write(ParamsHeader, Sizeof(TRESTDWParamsHeader));
  Stream.Position := 0;
  {$IFEND}
End;

Procedure TRESTDWParams.LoadFromStream(Stream: TStream;
  ValidateHeader: Boolean = False; Input: TDWParamExpType = tdwpxt_All);
Var
  ParamsHeader: TRESTDWParamsHeader;
  VersionNumber, ParamsCount, L: Integer;
  {$IF Defined(RESTDWLAZARUS) OR Not(Defined(DELPHIXEUP))}
  S: AnsiString;
  {$ELSE}
  S: RawByteString;
  {$IFEND}
  DataSize, aSize, StartPos: Int64;
  Procedure CreateDWParamsFromStream;
  Var
    I, T: Integer;
    J, L: DWInt64;
    B: Boolean;
    VE: Extended;
    VC: Currency;
    VF: DWFloat;
    vStringBytes: TRESTDWBytes;
    vItem: TJSONParam;
    vStream: TStream;
  Begin
    For I := 0 To ParamsCount - 1 Do
    Begin
      S := '';
      Stream.Read(L, Sizeof(DWInt64));
      SetLength(S, L);
      Try
        If L <> 0 Then
          Stream.Read(S[InitStrPos], L);
        {$IFDEF RESTDWLAZARUS}
        S := GetStringEncode(S, vDatabaseCharSet);
        {$ENDIF}
      Finally
        // StrDispose(Buffer);
      End;
      vItem := ItemsString[S];
      If Not Assigned(vItem) Then
      Begin
        vItem := TJSONParam.Create(Encoding);
        Add(vItem);
      End;
      // ParamName
      vItem.ParamName := S;
      // ObjectDirection
      Stream.Read(T, Sizeof(DWFieldTypeSize));
      vItem.ObjectDirection := TObjectDirection(T);
      // Encoded
      Stream.Read(B, Sizeof(WordBool));
      vItem.Encoded := B;
      // DataMode
      Stream.Read(T, Sizeof(DWFieldTypeSize));
      vItem.DataMode := TDataMode(T);
      // TypeObject
      Stream.Read(T, Sizeof(DWFieldTypeSize));
      vItem.vTypeObject := TTypeObject(T);
      // DataType
      Stream.Read(T, Sizeof(DWFieldTypeSize));
      vItem.ObjectValue := TObjectValue(T);
      // GetValue from Datatype
      S := '';
      L := 0;
      Case vItem.ObjectValue Of
        ovFixedChar, ovWideString, ovString, ovObject:
          Begin
            vItem.CriptOptions.Use := False;
            Stream.Read(L, Sizeof(DWInt64));
            If (L = 0) Or (L > high(Sizeof(DWInt64))) Then
              Continue;
            SetLength(vStringBytes, 0);
            SetLength(S, L);
            Try
              If L <> 0 Then
              Begin
                SetLength(vStringBytes, L);
                Stream.Read(vStringBytes[0], L);
                S := BytesToString(vStringBytes);
                {$IFDEF RESTDWLAZARUS}
                S := GetStringEncode(S, vDatabaseCharSet);
                {$ENDIF}
              End;
            Finally
            End;
            vItem.AsString := S;
            vItem.CriptOptions.Use := CriptOptions.Use;
            vItem.CriptOptions.Key := CriptOptions.Key;
          End;
        ovSingle, ovSmallInt, ovInteger, ovAutoInc, ovLongWord, ovShortInt,
          ovLargeInt:
          Begin
            Stream.Read(J, Sizeof(DWInteger));
            SetLength(S, J);
            If J <> 0 Then
            Begin
              Stream.Read(S[InitStrPos], J);
              If ((S = TDecimalChar) or (S = #0)) Then
                vItem.Clear
              Else
              Begin
                If vItem.ObjectValue = ovLargeInt Then
                Begin
                  Stream.Read(J, Sizeof(DWInt64));
                  vItem.AsLargeInt := J;
                End
                Else
                Begin
                  Stream.Read(J, Sizeof(DWInt64));
                  vItem.AsInteger := J;
                End;
              End;
            End
            Else
              vItem.Clear;
          End;
        ovWord:
          Begin
            Stream.Read(J, Sizeof(DWInteger));
            SetLength(S, J);
            If J <> 0 Then
            Begin
              Stream.Read(S[InitStrPos], J);
              If (S = TNullString) Then
                vItem.Clear
              Else
              Begin
                Stream.Read(J, Sizeof(Word));
                vItem.AsWord := J;
              End;
            End
            Else
              vItem.Clear;
          End;
        ovByte:
          Begin
            Stream.Read(B, Sizeof(Byte));
            vItem.AsBoolean := B;
          End;
        ovBoolean:
          Begin
            Stream.Read(B, Sizeof(WordBool));
            vItem.AsBoolean := B;
          End;
        ovDate, ovTime, ovDateTime, ovTimeStamp, ovTimeStampOffset, ovCurrency,
          ovBCD, ovFMTBcd, ovFloat, ovExtended:
          Begin
            Stream.Read(J, Sizeof(DWInteger));
            SetLength(S, J);
            If J <> 0 Then
            Begin
              Stream.Read(S[InitStrPos], J);
              If ((S = TDecimalChar) or (S = #0)) Then
                vItem.Clear
              Else
              Begin
                S := BuildFloatString(S);
                If vItem.ObjectValue = ovExtended Then
                Begin
                  VE := StrToFloat(S);
                  vItem.AsExtended := VE;
                End
                Else If vItem.ObjectValue In [ovCurrency, ovBCD, ovFMTBcd] Then
                Begin
                  VC := StrToFloat(S);
                  vItem.AsCurrency := VC;
                End
                Else If vItem.ObjectValue In [ovDate, ovTime, ovDateTime,
                  ovTimeStamp, ovTimeStampOffset] Then
                Begin
                  VF := StrToFloat(S);
                  vItem.AsDateTime := VF;
                End
                Else
                Begin
                  VF := StrToFloat(S);
                  vItem.AsFloat := VF;
                End;
              End;
            End
            Else
              vItem.Clear;
          End;
        ovVariant:
          ;
        ovInterface:
          ;
        ovIDispatch:
          ;
        ovBlob, ovStream, ovBytes:
          Begin
            Stream.Read(J, Sizeof(DWInt64));
            If J > 0 Then
            Begin
              vStream := TMemoryStream.Create;
              Try
                vStream.CopyFrom(Stream, J);
                vStream.Position := 0;
                Try
                  vItem.LoadFromStream(vStream);
                Except
                End;
              Finally
                vStream.Free;
              End;
            End;
          End;
      End;
      If Input <> tdwpxt_All Then
      Begin
        If ((vItem.ObjectDirection = odIN) And (Input = tdwpxt_OUT)) Or
          ((vItem.ObjectDirection = odOUT) And (Input = tdwpxt_IN)) Then
          Delete(vItem);
      End;
    End;
  End;

Begin
  If Not Assigned(Stream) Then
    Exit;
  Stream.Position := 0;
  ParamsHeader.VersionNumber := 0;
  ParamsHeader.Recordcount := 0;
  ParamsHeader.ParamsCount := 0;
  ParamsHeader.DataSize := 0;
  Stream.Read(ParamsHeader, Sizeof(TRESTDWParamsHeader));
  VersionNumber := ParamsHeader.VersionNumber;
  ParamsCount := ParamsHeader.ParamsCount;
  DataSize := ParamsHeader.DataSize;
  StartPos := Stream.Position;
  aSize := Stream.Size;
  If ValidateHeader Then
  Begin
    If DataSize <> aSize - StartPos Then
      Raise Exception.Create(cInvalidStream)
    Else
    Begin
      If ParamsCount > 0 Then
        CreateDWParamsFromStream;
    End;
  End
  Else
  Begin
    If ParamsCount > 0 Then
      CreateDWParamsFromStream;
  End;
End;

Procedure TRESTDWParams.LoadFromParams(Params: TParams);
Var
  I: Integer;
  vDwParam: TJSONParam;
Begin
  Clear;
  If Assigned(Params) Then
  Begin
    For I := 0 To Params.Count - 1 Do
    Begin
      vDwParam := TJSONParam.Create(Encoding);
      vDwParam.LoadFromParam(Params[I]);
      Add(vDwParam);
    End;
  End;
End;

Procedure TRESTDWParams.SetCriptOptions(Use: Boolean; Key: String);
Var
  I: Integer;
Begin
  For I := 0 To Count - 1 Do
  Begin
    Items[I].CriptOptions.Use := Use;
    Items[I].CriptOptions.Key := Key;
  End;
End;

end.
