unit uRESTDWTools;

{$I ..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

Uses
  {$IFDEF RESTDWLAZARUS}
  LConvEncoding, lazutf8,
  {$ELSE}
  {$IFDEF RESTDWWINDOWS}Windows, {$ENDIF}
  {$IFDEF RESTDWFMX}IOUtils, {$ENDIF}
  {$IFDEF DELPHIXE6UP}NetEncoding, {$ENDIF}
  EncdDecd,
  {$ENDIF}
  Classes, SysUtils, DB,
  uRESTDWProtoTypes, uRESTDWConsts, DWDCPrijndael,
  DWDCPsha256;

Type
  TCripto = Class(TPersistent)
  Private
    vKeyString: String;
    vUseCripto: Boolean;
  Public
    Constructor Create; // Cria o Componente
    Destructor Destroy; Override; // Destroy a Classe
    Procedure Assign(Source: TPersistent); Override;
    Function Encrypt(Value: String): String;
    Function Decrypt(Value: String): String;
  Published
    Property Use: Boolean Read vUseCripto Write vUseCripto;
    Property Key: String Read vKeyString Write vKeyString;
  End;

Const
  B64Table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  QuoteSpecials: Array [TRESTDWHeaderQuotingType] Of String = ('',
    '()<>@,;:\"./', '()<>@,;:\"/[]?=', '()<>@,;:\"/[]?={} '#9);
  LF = #10;
  CR = #13;
  EOL = CR + LF;
  CHAR0 = #0;
  BACKSPACE = #8;
  TAB = #9;
  CHAR32 = #32;
  LWS = TAB + CHAR32;

Function EncryptSHA256(Key, Text: TRESTDWString; Encrypt: Boolean): String;
Function EncodeStrings(Value: String
  {$IFDEF RESTDWLAZARUS}
  ; DatabaseCharSet: TDatabaseCharSet
  {$ENDIF}): String;
Function DecodeStrings(Value: String
  {$IFDEF RESTDWLAZARUS}
  ; DatabaseCharSet: TDatabaseCharSet
  {$ENDIF}): String;
Function EncodeStream(Value: TStream): String;
Function DecodeStream(Value: String): TMemoryStream;
Function BytesToString(Const bin: TRESTDWBytes): String; Overload;
Function BytesToString(Const bin: TRESTDWBytes; aUnicode: Boolean)
  : String; Overload;
Function BytesToString(Const AValue: TRESTDWBytes; Const AStartIndex: Integer;
  Const ALength: Integer = -1): String; Overload;
Function BytesToStream(Const bin: TRESTDWBytes): TStream;
Function restdwLength(Const ABuffer: String; Const ALength: Integer = -1;
  Const AIndex: Integer = 1): Integer; Overload;
Function restdwLength(Const ABuffer: TRESTDWBytes; Const ALength: Integer = -1;
  Const AIndex: Integer = 0): Integer; Overload;
Function restdwLength(Const ABuffer: TStream;
  Const ALength: TRESTDWStreamSize = -1): TRESTDWStreamSize; Overload;
Function restdwMax(Const AValueOne, AValueTwo: Int64): Int64;
Function restdwMin(Const AValueOne, AValueTwo: Int64): Int64;
Function StringToBytes(AStr: String): TRESTDWBytes; Overload;
Function StringToBytes(AStr: String; aUnicode: Boolean): TRESTDWBytes; Overload;
Function StreamToBytes(Stream: TStream): TRESTDWBytes;
Function StringToFieldType(Const S: String): Integer;
Function Escape_chars(S: String): String;
Function Unescape_chars(S: String): String;
Function HexToBookmark(Value: String): TRESTDWBytes;
Function BookmarkToHex(Value: TRESTDWBytes): String;
Procedure CopyStringList(Const Source, Dest: TStringList);
Function RemoveBackslashCommands(Value: String): String;
Function RESTDWFileExists(sFile, BaseFilePath: String): Boolean;
Function TravertalPathFind(Value: String): Boolean;
Function GetEventName(Value: String): String;
Function ExtractHeaderSubItem(Const AHeaderLine, ASubItem: String;
  QuotingType: TRESTDWHeaderQuotingType): String;
Function ReadLnFromStream(AStream: TStream; Var VLine: String;
  AMaxLineLength: Integer = -1): Boolean; Overload;
Function ReadLnFromStream(AStream: TStream; AMaxLineLength: Integer = -1;
  AExceptionIfEOF: Boolean = False): String; Overload;
Function ValueFromIndex(AStrings: TStrings; Const AIndex: Integer): String;
Function restdwValueFromIndex(AStrings: TStrings;
  Const AIndex: Integer): String;
Function iif(ATest: Boolean; Const ATrue: Integer; Const AFalse: Integer)
  : Integer; {$IFDEF USE_INLINE}Inline; {$ENDIF}overload;
Function iif(ATest: Boolean; Const ATrue: String; Const AFalse: String): String;
{$IFDEF USE_INLINE}Inline; {$ENDIF}Overload;
Function iif(ATest: Boolean; Const ATrue: Boolean; Const AFalse: Boolean)
  : Boolean; {$IFDEF USE_INLINE}Inline; {$ENDIF}Overload;
Function CharRange(Const AMin, AMax: Char): String;
Function CharIsInSet(Const AString: String; Const ACharPos: Integer;
  Const ASet: String): Boolean; {$IFDEF USE_INLINE}Inline; {$ENDIF}
Function ExtractHeaderItem(Const AHeaderLine: String): String;
Function TextIsSame(Const A1, A2: String): Boolean; {$IFDEF USE_INLINE}Inline;
{$ENDIF}
Function WrapText(Const ALine, ABreakStr, ABreakChars: String;
  MaxCol: Integer): String;
Function Fetch(Var AInput: String; Const ADelim: String = '';
  Const ADelete: Boolean = True; Const ACaseSensitive: Boolean = True): String;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Function InternalAnsiPos(Const Substr, S: String): Integer;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Function PosInStrArray(Const SearchStr: String; Const Contents: Array Of String;
  Const CaseSensitive: Boolean = True): Integer;
Function ReplaceHeaderSubItem(Const AHeaderLine, ASubItem, AValue: String;
  AQuoteType: TRESTDWHeaderQuotingType): String; Overload;
Function ReplaceHeaderSubItem(Const AHeaderLine, ASubItem, AValue: String;
  Var VOld: String; AQuoteType: TRESTDWHeaderQuotingType): String; Overload;
Procedure SplitHeaderSubItems(AHeaderLine: String; AItems: TStrings;
  AQuoteType: TRESTDWHeaderQuotingType);
Function TextStartsWith(Const S, SubS: String): Boolean;
Function TextEndsWith(Const S, SubS: String): Boolean;
Function Max(Const AValueOne, AValueTwo: Int64): Int64;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Function Min(Const AValueOne, AValueTwo: Int64): Int64;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Function RawToBytes(Const AValue: String; Const ASize: Integer): TRESTDWBytes;
Procedure CopyBytes(Const ASource: TRESTDWBytes; Const ASourceIndex: Integer;
  Var VDest: TRESTDWBytes; Const ADestIndex: Integer; Const ALength: Integer);
Function ByteIsInSet(Const ABytes: TRESTDWBytes; Const AIndex: Integer;
  Const ASet: TRESTDWBytes): Boolean; {$IFDEF USE_INLINE}Inline; {$ENDIF}
Function ToBytes(Const AValue: String): TRESTDWBytes; Overload;
Function ToBytes(Const AValue: Char): TRESTDWBytes; Overload;
Function ToBytes(Const AValue: String; Const ALength: Integer;
  Const AIndex: Integer = 1): TRESTDWBytes; Overload;
Function ToBytes(Const AValue: TRESTDWBytes; Const ASize: Integer;
  Const AIndex: Integer = 0): TRESTDWBytes; Overload;
Function GetBytes(Const AChars: PDWWideChar; ACharCount: Integer)
  : TRESTDWBytes; Overload;
Function GetBytes(Const AChars: PDWWideChar; ACharCount: Integer; ABytes: PByte;
  AByteCount: Integer): Integer; Overload;
Function GetBytes(Const AChars: TRESTDWWideChars;
  ACharIndex, ACharCount: Integer; Var VBytes: TRESTDWBytes;
  AByteIndex: Integer): Integer; Overload;
Function GetBytes(Const AChars: PDWWideChar; ACharCount: Integer;
  Var VBytes: TRESTDWBytes; AByteIndex: Integer): Integer; Overload;
Function GetBytes(Const AChars: String): TRESTDWBytes;
{$IFDEF USE_INLINE}Inline; {$ENDIF}Overload;
Function GetChars(Const ABytes: TRESTDWBytes; AByteIndex, AByteCount: Integer)
  : TRESTDWWideChars; Overload;
Function GetChars(Const ABytes: TRESTDWBytes): TRESTDWWideChars; Overload;
Function GetChars(Const ABytes: PByte; AByteCount: Integer)
  : TRESTDWWideChars; Overload;
Function GetChars(Const ABytes: TRESTDWBytes; AByteIndex, AByteCount: Integer;
  Var VChars: TRESTDWWideChars; ACharIndex: Integer): Integer; Overload;
Function GetChars(Const ABytes: PByte; AByteCount: Integer;
  Var VChars: TRESTDWWideChars; ACharIndex: Integer): Integer; Overload;
Function GetChars(Const ABytes: PByte; AByteCount: Integer; AChars: PDWWideChar;
  ACharCount: Integer): Integer; Overload;
Function GetCharCount(Const ABytes: TRESTDWBytes;
  AByteIndex, AByteCount: Integer): Integer; Overload;
Function GetCharCount(Const ABytes: PByte; AByteCount: Integer)
  : Integer; Overload;
Function ValidateBytes(Const ABytes: TRESTDWBytes;
  AByteIndex, AByteCount, ANeeded: Integer): PByte; Overload;
Function ValidateBytes(Const ABytes: TRESTDWBytes;
  AByteIndex, AByteCount: Integer): PByte; Overload;
Function ReadBytesFromStream(Const AStream: TStream; Var ABytes: TRESTDWBytes;
  Const Count: TRESTDWStreamSize; Const AIndex: Integer = 0): TRESTDWStreamSize;
Procedure WriteBytesToStream(Const AStream: TStream; Const ABytes: TRESTDWBytes;
  Const ASize: Integer = -1; Const AIndex: Integer = 0);
Procedure StringToStream(AStream: TStream; Const AStr: String);
procedure WriteStringToStream(AStream: TStream; Const AStr: String;
  Const ALength: Integer = -1; Const AIndex: Integer = 1); Overload;
Function ReadStringFromStream(AStream: TStream; ASize: Integer = -1)
  : String; Overload;
Procedure AppendBytes(Var VBytes: TRESTDWBytes; Const AToAdd: TRESTDWBytes;
  Const AIndex: Integer = 0; Const ALength: Integer = -1);
Procedure InsertBytes(Var VBytes: TRESTDWBytes; Const ADestIndex: Integer;
  Const ASource: TRESTDWBytes; Const ASourceIndex: Integer = 0);
Procedure InsertByte(Var VBytes: TRESTDWBytes; Const AByte: Byte;
  Const AIndex: Integer);
Function ByteIndex(Const AByte: Byte; Const ABytes: TRESTDWBytes;
  Const AStartIndex: Integer = 0): Integer;
Function ByteToHex(Const AByte: Byte): String;
Procedure RemoveBytes(Var VBytes: TRESTDWBytes; Const ACount: Integer;
  Const AIndex: Integer = 0);
Procedure ExpandBytes(Var VBytes: TRESTDWBytes; Const AIndex: Integer;
  Const ACount: Integer; Const AFillByte: Byte = 0);
Procedure AppendByte(Var VBytes: TRESTDWBytes; Const AByte: Byte);
Function ByteIsInEOL(Const ABytes: TRESTDWBytes; Const AIndex: Integer)
  : Boolean;
Function GetByteCount(Const AChars: TRESTDWWideChars): Integer; Overload;
Function GetByteCount(Const AChars: TRESTDWWideChars;
  ACharIndex, ACharCount: Integer): Integer; Overload;
Function GetByteCount(Const AChars: PDWWideChar; ACharCount: Integer)
  : Integer; Overload;
Function IsHeaderMediaType(Const AHeaderLine, AMediaType: String): Boolean;
Function MediaTypeMatches(Const AValue, AMediaType: String): Boolean;
Function PosRDW(Const ASubStr, AStr: String; AStartPos: DWInt32): DWInt32;
Function RDWStrToInt(Const S: String; ADefault: Integer = 0): Integer;
{$IFDEF USE_INLINE}inline; {$ENDIF}
Procedure RDWDelete(Var S: String; AOffset, ACount: Integer);
Function FindFirstNotOf(Const AFind, AText: String; Const ALength: Integer = -1;
  Const AStartPos: Integer = 1): Integer;
Function FindFirstOf(Const AFind, AText: String; Const ALength: Integer = -1;
  Const AStartPos: Integer = 1): Integer;
Function BytesToStringRaw(Const AValue: TRESTDWBytes): String; Overload;
{$IFDEF USE_INLINE}inline; {$ENDIF}
Function BytesToStringRaw(Const AValue: TRESTDWBytes;
  Const AStartIndex: Integer; Const ALength: Integer = -1): String; Overload;
Function IsHeaderMediaTypes(Const AHeaderLine: String;
  Const AMediaTypes: Array Of String): Boolean;
Function IsHeaderValue(Const AHeaderLine: String; Const AValue: String)
  : Boolean;
Function GetUniqueFileName(Const APath, APrefix, AExt: String): String;
Function MakeTempFilename(Const APath: TFileName = ''): TFileName;
Function CopyFileTo(Const Source, Destination: TFileName): Boolean;
Function UTCOffsetToStr(Const AOffset: TDateTime;
  Const AUseGMTStr: Boolean = False): String;
Function RawStrInternetToDateTime(Var Value: String;
  Var VDateTime: TDateTime): Boolean;
Function IsNumeric(Const AChar: Char): Boolean; Overload;
Function IsNumeric(Const AString: String; Const ALength: Integer;
  Const AIndex: Integer = 1): Boolean; Overload;
Function restdwPos(Const Substr, S: String): Integer;
Function RemoveHeaderEntry(Const AHeader, AEntry: String;
  AQuoteType: TRESTDWHeaderQuotingType): String; Overload;
Function RemoveHeaderEntry(Const AHeader, AEntry: String; Var VOld: String;
  AQuoteType: TRESTDWHeaderQuotingType): String; overload;
Function BytesToInt16(Const AValue: TRESTDWBytes;
  Const AIndex: Integer = 0): DWInt32;
Function BytesToInt32(Const AValue: TRESTDWBytes;
  Const AIndex: Integer = 0): DWInt32;
Function BytesToInt64(Const AValue: TRESTDWBytes;
  Const AIndex: Integer = 0): DWInt64;
Procedure DeleteInvalidChar(Var Value: String);
Function BooleanToString(AValue: Boolean): String;
Function StringToBoolean(AValue: String): Boolean;
Procedure CopyRDWString(Const ASource: String; Var VDest: TRESTDWBytes;
  Const ADestIndex: Integer; Const ALength: Integer = -1); Overload;
Procedure CopyRDWString(Const ASource: String; Const ASourceIndex: Integer;
  Var VDest: TRESTDWBytes; Const ADestIndex: Integer;
  Const ALength: Integer = -1); Overload;
Function GetTokenString(Value: String): String;
Function GetBearerString(Value: String): String;
Function GetPairJSONStr(Status, MessageText: String;
  Encoding: TEncodeSelect = esUtf8): String;
Function GetPairJSONInt(Status: Integer; MessageText: String;
  Encoding: TEncodeSelect = esUtf8): String;
{$IFDEF RESTDWLAZARUS}
Function GetStringUnicode(Value: String): String;
Function GetStringEncode(Value: String;
  DatabaseCharSet: TDatabaseCharSet): String;
Function GetStringDecode(Value: String;
  DatabaseCharSet: TDatabaseCharSet): String;
{$ENDIF}
Function GetObjectName(TypeObject: TTypeObject): String; Overload;
Function GetDataModeName(TypeObject: TDataMode): String; Overload;
Function GetDataModeName(TypeObject: String): TDataMode; Overload;
Function GetObjectName(TypeObject: String): TTypeObject; Overload;
Function GetDirectionName(ObjectDirection: TObjectDirection): String; Overload;
Function GetDirectionName(ObjectDirection: String): TObjectDirection; Overload;
Function GetBooleanFromString(Value: String): Boolean;
Function GetStringFromBoolean(Value: Boolean): String;
Function GetValueType(ObjectValue: TObjectValue): String; Overload;
Function GetValueType(ObjectValue: String): TObjectValue; Overload;
// criando em 18/02/2020 - Ico Menezes
Function GetValueTypeTranslator(ObjectValue: String): TObjectValue;
Function GetFieldType(FieldType: TFieldType): String; Overload;
Function GetFieldType(FieldType: String): TFieldType; Overload;
Function FieldTypeToStr(FieldType: TFieldType): String; overload;
Function StrToFieldType(FieldType: String): TFieldType; overload;
// Function  StringToBoolean          (aValue             : String)                 : Boolean;
// Function  BooleanToString          (aValue             : Boolean)                : String;
Function StringFloat(AValue: String): String;
Function GenerateStringFromStream(Stream: TStream
  {$IFDEF DELPHIXEUP}; AEncoding: TEncoding
  {$ENDIF}): String; Overload;
Function FileToStr(Const FileName: String): String;
Procedure StrToFile(Const FileName, SourceString: String);
Function StreamToHex(Stream: TStream; QQuoted: Boolean = True): String;
Function PCharToHex(Data: PChar; Size: Integer;
  QQuoted: Boolean = True): String;
Procedure HexToPChar(HexString: String; Var Data: PChar);
Procedure HexToStream(Str: String; Stream: TStream);
// Function  StreamToBytes            (Stream             : TMemoryStream)          : tidBytes;
Procedure CopyStream(Const Source: TStream; Dest: TStream);
Function RemoveLineBreaks(AText: string): string;
Function ObjectValueToFieldType(TypeObject: TObjectValue): TFieldType;
Function FieldTypeToObjectValue(FieldType: TFieldType): TObjectValue;
Function FieldTypeToDWFieldType(FieldType: TFieldType): Byte;
Function DWFieldTypeToFieldType(DWFieldType: Byte): TFieldType;
Function DatasetStateToMassiveType(DatasetState: TDatasetState): TMassiveMode;
Function MassiveModeToString(MassiveMode: TMassiveMode): String;
Function StringToMassiveMode(Value: String): TMassiveMode;
Function DateTimeToUnix(ConvDate: TDateTime;
  AInputIsUTC: Boolean = True): Int64;
Function UnixToDateTime(USec: Int64; AInputIsUTC: Boolean = True): TDateTime;
Function BuildFloatString(Value: String): String;
Function BuildStringFloat(Value: String; DataModeD: TDataMode = dmDataware;
  FloatDecimalFormat: String = ''): String;

Function Scripttags(Value: String): Boolean;
// Function  RESTDWFileExists             (sFile,
// BaseFilePath       : String)                 : Boolean;
Function SystemProtectFiles(sFile: String): Boolean;
Function RequestTypeToRoute(RequestType: TRequestType): TRESTDWRoute;
Procedure DeleteStr(Var Value: String; InitPos, FinalPos: Integer);
Function RandomString(strLen: Integer): String;
Function StrDWLength(Value: String): Integer;
Function RequestTypeToString(RequestType: TRequestType): String;
Function VarIsNullEmpty(Const V: Variant): Boolean;
Function VarIsNullEmptyBlank(Const V: Variant): Boolean;
Procedure DynArrayToBinVariant(Var V: Variant; Const DynArray; Len: Integer);

Function RESTDWCharInSet(C: DWChar; Const CharSet: TCharSet): Boolean; Overload;
Function RESTDWCharInSet(C: DWWideChar; Const CharSet: TCharSet)
  : Boolean; Overload;
Procedure InitializeStrings;

Implementation

Uses
  DateUtils,
  uRESTDWBase64, uRESTDWException, Variants, uRESTDWBasicTypes;

Procedure DynArrayToBinVariant(var V: Variant; const DynArray; Len: Integer);
var
  {$IFDEF RESTDWLAZARUS}
  LVarBounds: Array of SizeInt;
  {$ELSE}
  {$IF Defined(DELPHIXE7UP)}
  LVarBounds: Array of Integer;
  {$ELSEIF Defined(DELPHIXE6UP) AND not Defined(DELPHIXE7UP)}
  LVarBounds: Array of NativeInt;
  {$ELSEIF Defined(DELPHIXE2UP)}
  LVarBounds: Array of Integer;
  {$IFEND}
  {$ENDIF}
  aVarData: PVarData;
begin
  LVarBounds := nil;
  { This resets the Variant to VT_EMPTY - flag which is used to determine whether the }
  { the cast to Variant succeeded or not }
  VarClear(V);
  { Get Variant-style Bounds (lo/hi pair) of Dynamic Array }
  SetLength(LVarBounds, 2);
  LVarBounds[0] := 0;
  LVarBounds[1] := Len - 1;
  { Create Variant of SAFEARRAY }
  V := VarArrayCreate(LVarBounds, varByte);
  Assert(VarArrayDimCount(V) = 1);
  { Keep the data around for a bit }
  VarArrayLock(V);
  Try
    aVarData := PVarData(@V);
    {$IFNDEF RESTDWLAZARUS}
    Move(Pointer(DynArray)^, aVarData^.VArray.Data^, Len);
    {$ELSE}
    Move(Pointer(DynArray)^, aVarData^.VArray, Len);
    {$ENDIF}
    { Let go of the data }
  Finally
    VarArrayUnlock(V);
  End;
End;

Function RESTDWCharInSet(C: DWChar; Const CharSet: TCharSet): Boolean;
Begin
  Result := C In CharSet;
End;

Function RESTDWCharInSet(C: DWWideChar; Const CharSet: TCharSet): Boolean;
Begin
  Result := DWChar(C) In CharSet;
End;

Function VarIsNullEmpty(const V: Variant): Boolean;
Begin
  Result := VarIsNull(V) or VarIsEmpty(V);
End;

Function VarIsNullEmptyBlank(const V: Variant): Boolean;
Begin
  Result := VarIsNull(V) or VarIsEmpty(V) or (VarToStr(V) = '');
End;

Function RemoveLineBreaks(AText: string): string; // Gledston 03/12/2022
begin // linha 3087 na Function EncodeBase64(AValue : TStream) : String;
  { Retirando as quebras de linha em campos blob }
  Result := StringReplace(AText, #$D#$A, '', [rfReplaceAll]);
  { Retirando as quebras de linha em campos blob }
  Result := StringReplace(Result, #13#10, '', [rfReplaceAll]);
end;

Function DWFieldTypeToFieldType(DWFieldType: Byte): TFieldType;
Begin
  Result := ftUnknown;
  Case DWFieldType Of
    dwftString:
      Result := ftString;
    dwftSmallint:
      Result := ftSmallint;
    dwftInteger:
      Result := ftInteger;
    dwftWord:
      Result := ftWord;
    dwftBoolean:
      Result := ftBoolean;
    dwftFloat:
      Result := ftFloat;
    dwftCurrency:
      Result := ftCurrency;
    dwftDate:
      Result := ftDate;
    dwftTime:
      Result := ftTime;
    dwftDateTime:
      Result := ftDateTime;
    dwftBytes:
      Result := ftBytes;
    dwftVarBytes:
      Result := ftVarBytes;
    dwftAutoInc:
      Result := ftAutoInc;
    dwftBlob:
      Result := ftBlob;
    dwftMemo:
      Result := ftMemo;
    dwftGraphic:
      Result := ftGraphic;
    dwftFmtMemo:
      Result := ftFmtMemo;
    dwftParadoxOle:
      Result := ftParadoxOle;
    dwftDBaseOle:
      Result := ftDBaseOle;
    dwftTypedBinary:
      Result := ftTypedBinary;
    dwftCursor:
      Result := ftCursor;
    dwftFixedChar:
      Result := ftFixedChar;
    dwftLargeint:
      Result := ftLargeint;
    dwftADT:
      Result := ftADT;
    dwftArray:
      Result := ftArray;
    dwftReference:
      Result := ftReference;
    dwftDataSet:
      Result := ftDataSet;
    dwftOraBlob:
      Result := ftOraBlob;
    dwftOraClob:
      Result := ftOraClob;
    dwftVariant:
      Result := ftVariant;
    dwftInterface:
      Result := ftInterface;
    dwftIDispatch:
      Result := ftIDispatch;
    dwftGuid:
      Result := ftGuid;
    dwftBCD:
      Result := ftBCD;
    dwftFMTBcd:
      Result := ftFMTBcd;
    {$IFDEF DELPHI2010UP}
    dwftTimeStamp:
      Result := ftTimeStamp;
    dwftWideString:
      Result := ftWideString;
    dwftFixedWideChar:
      Result := ftFixedWideChar;
    dwftWideMemo:
      Result := ftWideMemo;
    dwftOraTimeStamp:
      Result := ftOraTimeStamp;
    dwftOraInterval:
      Result := ftOraInterval;
    dwftLongWord:
      Result := ftLongWord;
    dwftShortint:
      Result := ftShortint;
    dwftByte:
      Result := ftByte;
    dwftExtended:
      Result := ftExtended;
    dwftConnection:
      Result := ftConnection;
    dwftParams:
      Result := ftParams;
    dwftStream:
      Result := ftStream;
    dwftTimeStampOffset:
      Result := ftTimeStampOffset;
    dwftObject:
      Result := ftObject;
    dwftSingle:
      Result := ftSingle;
    {$ELSE}
    {$IFDEF DELPHIXEUP}
    dwftFixedWideChar:
      Result := ftFixedWideChar;
    dwftWideMemo:
      Result := ftWideMemo;
    {$ELSE}
    dwftFixedWideChar:
      Result := ftFixedChar;
    dwftWideMemo:
      Result := ftMemo;
    {$ENDIF}
    dwftTimeStamp:
      Result := ftDateTime; // ftTimeStamp nao definido 3.2.4
    dwftWideString:
      Result := ftWideString;
    dwftOraTimeStamp:
      Result := ftDateTime; // ftTimeStamp nao definido 3.2.4
    dwftOraInterval:
      Result := ftInteger;
    dwftLongWord:
      Result := ftWord;
    dwftShortint:
      Result := ftInteger;
    dwftByte:
      Result := ftTypedBinary;
    dwftExtended:
      Result := ftFloat;
    dwftStream:
      Result := ftBlob;
    dwftTimeStampOffset:
      Result := ftDateTime; // ftTimeStamp nao definido 3.2.4
    dwftSingle:
      Result := ftFloat;
    {$ENDIF}
  End;
End;

Function FieldTypeToDWFieldType(FieldType: TFieldType): Byte;
Begin
  Result := dwftUnknown;
  Case FieldType Of
    ftString:
      Result := dwftString;
    ftSmallint:
      Result := dwftSmallint;
    ftInteger:
      Result := dwftInteger;
    ftWord:
      Result := dwftWord;
    ftBoolean:
      Result := dwftBoolean;
    ftFloat:
      Result := dwftFloat;
    ftCurrency:
      Result := dwftCurrency;
    ftBCD:
      Result := dwftBCD;
    ftDate:
      Result := dwftDate;
    ftTime:
      Result := dwftTime;
    ftDateTime:
      Result := dwftDateTime;
    ftBytes:
      Result := dwftBytes;
    ftVarBytes:
      Result := dwftVarBytes;
    ftAutoInc:
      Result := dwftAutoInc;
    ftBlob:
      Result := dwftBlob;
    ftMemo:
      Result := dwftMemo;
    ftGraphic:
      Result := dwftGraphic;
    ftFmtMemo:
      Result := dwftFmtMemo;
    ftParadoxOle:
      Result := dwftParadoxOle;
    ftDBaseOle:
      Result := dwftDBaseOle;
    ftTypedBinary:
      Result := dwftTypedBinary;
    ftCursor:
      Result := dwftCursor;
    ftFixedChar:
      Result := dwftFixedChar;
    ftWideString:
      Result := dwftWideString;
    ftLargeint:
      Result := dwftLargeint;
    ftADT:
      Result := dwftADT;
    ftArray:
      Result := dwftArray;
    ftReference:
      Result := dwftReference;
    ftDataSet:
      Result := dwftDataSet;
    ftOraBlob:
      Result := dwftOraBlob;
    ftOraClob:
      Result := dwftOraClob;
    ftVariant:
      Result := dwftVariant;
    ftInterface:
      Result := dwftInterface;
    ftIDispatch:
      Result := dwftIDispatch;
    ftGuid:
      Result := dwftGuid;
    ftTimeStamp:
      Result := dwftTimeStamp;
    ftFMTBcd:
      Result := dwftFMTBcd;
    {$IFDEF DELPHI2010UP} // Delphi 2010 acima
    ftFixedWideChar:
      Result := dwftFixedWideChar;
    ftWideMemo:
      Result := dwftWideMemo;
    ftOraTimeStamp:
      Result := dwftOraTimeStamp;
    ftOraInterval:
      Result := dwftOraInterval;
    ftLongWord:
      Result := dwftLongWord;
    ftShortint:
      Result := dwftShortint;
    ftByte:
      Result := dwftByte;
    ftExtended:
      Result := dwftExtended;
    ftConnection:
      Result := dwftConnection;
    ftParams:
      Result := dwftParams;
    ftStream:
      Result := dwftStream;
    ftTimeStampOffset:
      Result := dwftTimeStampOffset;
    ftObject:
      Result := dwftObject;
    ftSingle:
      Result := dwftSingle;
    {$ENDIF}
  End;
End;

{ TCripto }

Constructor TCripto.Create;
Begin
  Inherited;
  vKeyString := 'RDWBASEKEY256';
  vUseCripto := False;
End;

Destructor TCripto.Destroy;
Begin
  Inherited;
End;

Function TCripto.Encrypt(Value: String): String;
Var
  vDWString: TRESTDWString;
Begin
  vDWString := Value;
  Result := EncryptSHA256(vKeyString, vDWString, True);
End;

Function TCripto.Decrypt(Value: String): String;
Var
  vDWString: TRESTDWString;
Begin
  vDWString := Value;
  Result := EncryptSHA256(vKeyString, vDWString, False);
End;

Procedure TCripto.Assign(Source: TPersistent);
Var
  Src: TCripto;
Begin
  If Source is TCripto Then
  Begin
    Src := TCripto(Source);
    vKeyString := Src.vKeyString;
    vUseCripto := Src.vUseCripto;
  End
  Else
    Inherited;
End;

{$IFDEF RESTDWLAZARUS}

Function GetStringUnicode(Value: String): String;
Var
  Unicode, Charlen: Integer;
  P: PChar;
Begin
  P := PChar(Value);
  Result := '';
  Repeat
    Unicode := UTF8CharacterToUnicode(P, Charlen);
    Result := Result + UTF8Copy(P, 1, 1);
    Inc(P, Charlen);
  Until (Charlen = 0) or (Unicode = 0);
  Result := P;
End;

Function GetStringEncode(Value: String;
  DatabaseCharSet: TDatabaseCharSet): String;
Begin
  Result := Value;
  Case DatabaseCharSet Of
    csWin1250:
      Result := CP1250ToUTF8(Value);
    csWin1251:
      Result := CP1251ToUTF8(Value);
    csWin1252:
      Result := CP1252ToUTF8(Value);
    csWin1253:
      Result := CP1253ToUTF8(Value);
    csWin1254:
      Result := CP1254ToUTF8(Value);
    csWin1255:
      Result := CP1255ToUTF8(Value);
    csWin1256:
      Result := CP1256ToUTF8(Value);
    csWin1257:
      Result := CP1257ToUTF8(Value);
    csWin1258:
      Result := CP1258ToUTF8(Value);
    csUTF8:
      Result := UTF8ToUTF8BOM(Value);
    csISO_8859_1:
      Result := ISO_8859_1ToUTF8(Value);
    csISO_8859_2:
      Result := ISO_8859_2ToUTF8(Value);
  End;
End;

Function GetStringDecode(Value: String;
  DatabaseCharSet: TDatabaseCharSet): String;
Begin
  Result := Value;
  Case DatabaseCharSet Of
    csWin1250:
      Result := UTF8ToCP1250(Value);
    csWin1251:
      Result := UTF8ToCP1251(Value);
    csWin1252:
      Result := UTF8ToCP1252(Value);
    csWin1253:
      Result := UTF8ToCP1253(Value);
    csWin1254:
      Result := UTF8ToCP1254(Value);
    csWin1255:
      Result := UTF8ToCP1255(Value);
    csWin1256:
      Result := UTF8ToCP1256(Value);
    csWin1257:
      Result := UTF8ToCP1257(Value);
    csWin1258:
      Result := UTF8ToCP1258(Value);
    csUTF8:
      Result := UTF8BOMToUTF8(Value);
    csISO_8859_1:
      Result := UTF8ToISO_8859_1(Value);
    csISO_8859_2:
      Result := UTF8ToISO_8859_2(Value);
  End;
End;
{$ENDIF}

Function restdwMin(Const AValueOne, AValueTwo: Int64): Int64;
Begin
  If AValueOne > AValueTwo Then
    Result := AValueTwo
  Else
    Result := AValueOne;
End;

Procedure AppendByte(Var VBytes: TRESTDWBytes; Const AByte: Byte);
Var
  LOldLen: Integer;
Begin
  LOldLen := restdwLength(VBytes);
  SetLength(VBytes, LOldLen + 1);
  VBytes[LOldLen] := AByte;
End;

Function Result2JSON(wsResult: TResultErro): String;
Begin
  Result := Format('{"STATUS":"%s","MESSAGE":"%s"}',
    [wsResult.Status, wsResult.MessageText]);
End;

Function GetPairJSONInt(Status: Integer; MessageText: String;
  Encoding: TEncodeSelect = esUtf8): String;
Var
  wsResult: TResultErro;
Begin
  wsResult.Status := IntToStr(Status);
  wsResult.MessageText := MessageText;
  Result := Result2JSON(wsResult);
  // EncodeStrings(TServerUtils.Result2JSON(WSResult){$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
End;

Function GetPairJSONStr(Status, MessageText: String;
  Encoding: TEncodeSelect = esUtf8): String;
Var
  wsResult: TResultErro;
Begin
  wsResult.Status := Status;
  wsResult.MessageText := MessageText;
  Result := Result2JSON(wsResult);
  // EncodeStrings(TServerUtils.Result2JSON(WSResult){$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
End;

Function BytesToInt16(Const AValue: TRESTDWBytes; Const AIndex: Integer = 0)
  : DWInt32; {$IFDEF USE_INLINE}inline; {$ENDIF}
Begin
  Assert(Length(AValue) >= (AIndex + SizeOf(DWInt32)));
  Result := PDWInt32(@AValue[AIndex])^;
End;

Function BytesToInt32(Const AValue: TRESTDWBytes; Const AIndex: Integer = 0)
  : DWInt32; {$IFDEF USE_INLINE}inline; {$ENDIF}
Begin
  Assert(Length(AValue) >= (AIndex + SizeOf(DWInt32)));
  Result := PDWInt32(@AValue[AIndex])^;
End;

Function BytesToInt64(Const AValue: TRESTDWBytes; Const AIndex: Integer = 0)
  : DWInt64; {$IFDEF USE_INLINE}inline; {$ENDIF}
Begin
  Assert(Length(AValue) >= (AIndex + SizeOf(DWInt64)));
  Result := PDWInt64(@AValue[AIndex])^;
End;

Function Base64Decode(const AInput: String): TRESTDWBytes;
Begin
  Result := TRESTDWBase64.Decode(ToBytes(AInput));
End;

Function Base64Encode(Const S: String): String;
  Function Encode_Byte(b: Byte): Char;
  Begin
    Result := Char(B64Table[(b and $3F) + 1]);
  End;
{$R-}

var
  i: Integer;
Begin
  i := 1;
  Result := '';
  While i <= Length(S) do
  Begin
    Result := Result + Encode_Byte(Byte(S[i]) shr 2);
    Result := Result + Encode_Byte((Byte(S[i]) shl 4) or
      (Byte(S[i + 1]) shr 4));
    If i + 1 <= Length(S) Then
      Result := Result + Encode_Byte((Byte(S[i + 1]) shl 2) or
        (Byte(S[i + 2]) shr 6))
    Else
      Result := Result + '=';
    If i + 2 <= Length(S) Then
      Result := Result + Encode_Byte(Byte(S[i + 2]))
    Else
      Result := Result + '=';
    Inc(i, 3);
  End;
End;

Function RemoveHeaderEntry(Const AHeader, AEntry: String;
  AQuoteType: TRESTDWHeaderQuotingType): String;
Begin
  Result := ReplaceHeaderSubItem(AHeader, AEntry, '', AQuoteType);
End;

Function RemoveHeaderEntry(Const AHeader, AEntry: String; Var VOld: String;
  AQuoteType: TRESTDWHeaderQuotingType): String;
Begin
  Result := ReplaceHeaderSubItem(AHeader, AEntry, '', VOld, AQuoteType);
End;

Function MediaTypeMatches(Const AValue, AMediaType: String): Boolean;
Begin
  If Pos('/', AMediaType) > 0 Then
    Result := TextIsSame(AValue, AMediaType)
  Else
    Result := TextStartsWith(AValue, AMediaType + '/'); { do not localize }
End;

Function MakeTempFilename(Const APath: TFileName = ''): TFileName;
{$IFNDEF RESTDWLAZARUS}
Var
  lPath, lExt: TFileName;
  {$ENDIF}
Begin
  {$IFDEF RESTDWLAZARUS}
  Result := SysUtils.GetTempFileName(APath, 'restdw'); { Do not Localize }
  {$ELSE}
  lPath := APath;
  lExt := {$IFDEF RESTDWLINUX}''{$ELSE}'.tmp'{$ENDIF}; { Do not Localize }
  {$IFDEF RESTDWWINDOWS}
  If lPath = '' Then
    GetTempPath(0, PWideChar(lPath));
  {$ELSE}
  {$IFDEF RESTDWFMX}
  If lPath = '' Then
    lPath := System.IOUtils.TPath.GetTempPath;
  {$ENDIF}
  {$ENDIF}
  Result := GetUniqueFileName(lPath, 'restdw', lExt);
  {$ENDIF}
End;

Function CopyFileTo(Const Source, Destination: TFileName): Boolean;
Begin
  {$IFDEF RESTDWLAZARUS}
  Result := CopyFileTo(PChar(Source), PChar(Destination));
  {$ELSE}
  {$IFDEF RESTDWFMX}
  Result := False;
  Try
    TFile.Copy(Source, Destination, True);
    Result := True;
  Except
  End;
  {$ELSE}
  Result := CopyFile(PChar(Source), PChar(Destination), False);
  {$ENDIF}
  {$ENDIF}
End;

Function GetUniqueFileName(Const APath, APrefix, AExt: String): String;
Var
  {$IFDEF RESTDWLAZARUS}
  LPrefix: string;
  {$ELSE}
  LNamePart: Integer;
  LFQE, LFName: String;
  {$ENDIF}
Begin
  {$IFDEF RESTDWLAZARUS}
  LPrefix := APrefix;
  If LPrefix = '' Then
    LPrefix := 'restdw'; { Do not localize }
  Result := SysUtils.GetTempFileName(APath, LPrefix);
  {$ELSE}
  LFQE := AExt;
  If LFQE <> '' Then
  Begin
    If LFQE[1] <> '.' Then
      LFQE := '.' + LFQE;
  End;
  If APath <> '' Then
  Begin
    If Not DirectoryExists(APath) Then
      LFName := APrefix
    Else
      LFName := IncludeTrailingPathDelimiter(APath) + APrefix;
  End
  Else
    LFName := APrefix;
  LNamePart := Random(99999);
  Repeat
    Result := LFName + IntToHex(LNamePart, 8) + LFQE;
    If Not FileExists(Result) Then
      Break;
    Inc(LNamePart);
  Until False;
  {$ENDIF}
End;

Function IsHeaderMediaType(Const AHeaderLine, AMediaType: String): Boolean;
Begin
  Result := MediaTypeMatches(ExtractHeaderItem(AHeaderLine), AMediaType);
End;

Function IsHeaderMediaTypes(Const AHeaderLine: String;
  Const AMediaTypes: Array Of String): Boolean;
Var
  LHeader: String;
  i: Integer;
Begin
  Result := False;
  LHeader := ExtractHeaderItem(AHeaderLine);
  For i := Low(AMediaTypes) To High(AMediaTypes) Do
  Begin
    If MediaTypeMatches(LHeader, AMediaTypes[i]) Then
    Begin
      Result := True;
      Exit;
    End;
  End;
End;

Function FindFirstNotOf(Const AFind, AText: String; Const ALength: Integer = -1;
  Const AStartPos: Integer = 1): Integer;
Var
  i, LLength, LPos: Integer;
Begin
  Result := 0;
  LLength := restdwLength(AText, ALength, AStartPos);
  If LLength > 0 Then
  Begin
    If Length(AFind) = 0 Then
    Begin
      Result := AStartPos;
      Exit;
    End;
    For i := 0 To LLength - 1 Do
    Begin
      LPos := AStartPos + i;
      If InternalAnsiPos(AText[LPos], AFind) = 0 Then
      Begin
        Result := LPos;
        Exit;
      End;
    End;
  End;
End;

Function FindFirstOf(Const AFind, AText: String; Const ALength: Integer = -1;
  Const AStartPos: Integer = 1): Integer;
Var
  i, LLength, LPos: Integer;
Begin
  Result := 0;
  If Length(AFind) > 0 Then
  Begin
    LLength := restdwLength(AText, ALength, AStartPos);
    If LLength > 0 Then
    Begin
      For i := 0 To LLength - 1 Do
      Begin
        LPos := AStartPos + i;
        If InternalAnsiPos(AText[LPos], AFind) <> 0 Then
        Begin
          Result := LPos;
          Exit;
        End;
      End;
    End;
  End;
End;

Function UTCOffsetToStr(Const AOffset: TDateTime;
  Const AUseGMTStr: Boolean = False): String;
Var
  AHour, AMin, ASec, AMSec: Word;
Begin
  If (AOffset = 0.0) And AUseGMTStr Then
    Result := 'GMT'
  Else
  Begin
    DecodeTime(AOffset, AHour, AMin, ASec, AMSec);
    Result := Format(' %0.2d%0.2d', [AHour, AMin]); { do not localize }
    If AOffset < 0.0 Then
      Result[1] := '-'
    Else
      Result[1] := '+'; { do not localize }
  End;
End;

Function RDWStrToInt(Const S: String; ADefault: Integer = 0): Integer;
{$IFDEF USE_INLINE}inline; {$ENDIF}
Begin
  Result := StrToIntDef(Trim(S), ADefault);
End;

Function PosRDW(Const ASubStr, AStr: String; AStartPos: DWInt32): DWInt32;
  Function FindStr(ALStartPos, EndPos: DWUInt32; StartChar: Char;
    Const ALStr: String): DWUInt32;
  Begin
    For Result := ALStartPos To EndPos Do
    Begin
      If ALStr[Result] = StartChar Then
        Exit;
    End;
    Result := 0;
  End;
  Function FindNextStr(ALStartPos, EndPos: DWUInt32;
    const ALStr, ALSubStr: string): DWUInt32;
  Begin
    For Result := ALStartPos + 1 To EndPos Do
    Begin
      If ALStr[Result] <> ALSubStr[Result - ALStartPos + 1] Then
        Exit;
    End;
    Result := 0;
  End;

Var
  StartChar: Char;
  LenSubStr, LenStr, EndPos: DWUInt32;
Begin
  If AStartPos = 0 Then
    AStartPos := 1;
  Result := 0;
  LenSubStr := Length(ASubStr);
  LenStr := Length(AStr);
  If (LenSubStr = 0) Or (AStr = '') Or
    (LenSubStr > (LenStr - (AStartPos - 1))) Then
    Exit;
  StartChar := ASubStr[1];
  EndPos := LenStr - LenSubStr + 1;
  If LenSubStr = 1 Then
    Result := FindStr(AStartPos, EndPos, StartChar, AStr)
  Else
  Begin
    Repeat
      Result := FindStr(AStartPos, EndPos, StartChar, AStr);
      If Result = 0 Then
        Break;
      AStartPos := Result;
      Result := FindNextStr(Result, AStartPos + LenSubStr - 1, AStr, ASubStr);
      If Result = 0 Then
      Begin
        Result := AStartPos;
        Exit;
      End;
      Inc(AStartPos);
    Until False;
  End;
End;

Function ValidateBytes(Const ABytes: TRESTDWBytes;
  AByteIndex, AByteCount: Integer): PByte;
Var
  Len: Integer;
Begin
  Len := Length(ABytes);
  If (AByteIndex < 0) Or (AByteIndex >= Len) Then
    Raise Exception.CreateResFmt(PResStringRec(@cInvalidDestinationIndex),
      [AByteIndex]);
  If (Len - AByteIndex) < AByteCount Then
    Raise Exception.CreateRes(PResStringRec(@cInvalidDestinationArray));
  If AByteCount > 0 Then
    Result := @ABytes[AByteIndex]
  Else
    Result := nil;
End;

Function ValidateBytes(Const ABytes: TRESTDWBytes;
  AByteIndex, AByteCount, ANeeded: Integer): PByte;
Var
  Len: Integer;
Begin
  Len := Length(ABytes);
  If (AByteIndex < 0) Or (AByteIndex >= Len) Then
    Raise Exception.CreateResFmt(PResStringRec(@cInvalidDestinationIndex),
      [AByteIndex]);
  If (Len - AByteIndex) < ANeeded Then
    Raise Exception.CreateRes(PResStringRec(@cInvalidDestinationArray));
  If AByteCount > 0 Then
    Result := @ABytes[AByteIndex]
  Else
    Result := Nil;
End;

Function ValidateChars(Const AChars: TRESTDWWideChars;
  ACharIndex, ACharCount: Integer): PDWWideChar;
Var
  Len: Integer;
Begin
  Len := Length(String(AChars));
  If (ACharIndex < 0) Or (ACharIndex >= Len) Then
    Raise Exception.CreateResFmt(PResStringRec(@cCharIndexOutOfBounds),
      [ACharIndex]);
  If ACharCount < 0 Then
    Raise Exception.CreateResFmt(PResStringRec(@cInvalidCharCount),
      [ACharCount]);
  If (Len - ACharIndex) < ACharCount Then
    Raise Exception.CreateResFmt(PResStringRec(@cInvalidCharCount),
      [ACharCount]);
  If ACharCount > 0 Then
    Result := @AChars[ACharIndex]
  Else
    Result := nil;
End;

Function BytesToStringRaw(Const AValue: TRESTDWBytes): String; Overload;
{$IFDEF USE_INLINE}inline; {$ENDIF}
Begin
  Result := BytesToStringRaw(AValue, 0, -1);
End;

Function BytesToStringRaw(Const AValue: TRESTDWBytes;
  Const AStartIndex: Integer; Const ALength: Integer = -1): String;
Var
  LLength: Integer;
Begin
  LLength := restdwLength(AValue, ALength, AStartIndex);
  If LLength > 0 Then
  Begin
    {$IF Defined(RESTDWLAZARUS) OR not Defined(LINUXFMX)}
    SetString(Result, PAnsiChar(@AValue[AStartIndex]), LLength);
    {$ELSEIF Defined(LINUXFMX)}
    SetString(Result, PChar(@AValue[AStartIndex]), LLength);
    {$IFEND}
  End
  Else
    Result := '';
End;

Function GetByteCount(Const AChars: PDWWideChar; ACharCount: Integer): Integer;
Begin
  Result := ACharCount * SizeOf(WideChar);
End;

Function GetCharCount(Const ABytes: PByte; AByteCount: Integer): Integer;
Begin
  Result := AByteCount Div SizeOf(WideChar);
End;

Function GetByteCount(Const AChars: TRESTDWWideChars): Integer;
begin
  If AChars <> Nil Then
    Result := GetByteCount(PDWWideChar(AChars), Length(String(AChars)))
  Else
    Result := 0;
End;

Function GetByteCount(Const AChars: TRESTDWWideChars;
  ACharIndex, ACharCount: Integer): Integer;
Var
  LChars: PDWWideChar;
Begin
  LChars := ValidateChars(AChars, ACharIndex, ACharCount);
  If LChars <> Nil Then
    Result := GetByteCount(LChars, ACharCount)
  Else
    Result := 0;
End;

Function GetBytes(Const AChars: String): TRESTDWBytes;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Var
  Len: Integer;
Begin
  Result := nil;
  Len := Length(AChars);
  If Len > 0 Then
  Begin
    SetLength(Result, Len);
    GetBytes(PDWWideChar(AChars), Len, PByte(Result), Len);
  End;
End;

Function GetBytes(Const AChars: PDWWideChar; ACharCount: Integer): TRESTDWBytes;
Var
  Len: Integer;
Begin
  Result := nil;
  Len := GetByteCount(AChars, ACharCount);
  If Len > 0 Then
  Begin
    SetLength(Result, Len);
    GetBytes(AChars, ACharCount, PByte(Result), Len);
  End;
End;

Function GetBytes(Const AChars: PDWWideChar; ACharCount: Integer; ABytes: PByte;
  AByteCount: Integer): Integer;
Var
  P: PDWWideChar;
  i: Integer;
Begin
  P := AChars;
  Result := restdwMin(ACharCount, AByteCount);
  For i := 1 To Result Do
  Begin
    If DWUInt16(P^) > $007F Then
      ABytes^ := Byte(Ord('?'))
    Else
      ABytes^ := Byte(P^);
    Inc(P);
    Inc(ABytes);
  End;
End;

Function GetChars(Const ABytes: TRESTDWBytes): TRESTDWWideChars;
Begin
  If ABytes <> Nil Then
    Result := GetChars(PByte(ABytes), Length(ABytes))
  Else
    Result := nil;
End;

Function GetCharCount(Const ABytes: TRESTDWBytes;
  AByteIndex, AByteCount: Integer): Integer;
Var
  LBytes: PByte;
Begin
  LBytes := ValidateBytes(ABytes, AByteIndex, AByteCount);
  If LBytes <> Nil Then
    Result := GetCharCount(LBytes, AByteCount)
  Else
    Result := 0;
End;

Function GetChars(Const ABytes: TRESTDWBytes; AByteIndex, AByteCount: Integer)
  : TRESTDWWideChars;
Var
  Len: Integer;
Begin
  Result := Nil;
  Len := GetCharCount(ABytes, AByteIndex, AByteCount);
  If Len > 0 Then
  Begin
    SetLength(Result, Len);
    GetChars(@ABytes[AByteIndex], AByteCount, Result, Len);
  End;
End;

Function GetChars(Const ABytes: TRESTDWBytes; AByteIndex, AByteCount: Integer;
  Var VChars: TRESTDWWideChars; ACharIndex: Integer): Integer;
Var
  LBytes: PByte;
Begin
  LBytes := ValidateBytes(ABytes, AByteIndex, AByteCount);
  If LBytes <> Nil Then
    Result := GetChars(LBytes, AByteCount, VChars, ACharIndex)
  Else
    Result := 0;
End;

Function GetChars(Const ABytes: PByte; AByteCount: Integer): TRESTDWWideChars;
Var
  Len: Integer;
Begin
  Len := GetCharCount(ABytes, AByteCount);
  If Len > 0 Then
  Begin
    SetLength(Result, Len);
    GetChars(ABytes, AByteCount, Result, Len);
  End;
End;

Function GetChars(Const ABytes: PByte; AByteCount: Integer;
  Var VChars: TRESTDWWideChars; ACharIndex: Integer): Integer;
Var
  LCharCount: Integer;
Begin
  If (ABytes = Nil) And (AByteCount <> 0) Then
    Raise Exception.CreateRes(PResStringRec(@cInvalidSourceArray));
  If AByteCount < 0 Then
    Raise Exception.CreateResFmt(PResStringRec(@cInvalidCharCount),
      [AByteCount]);
  If (ACharIndex < 0) Or (ACharIndex > Length(VChars)) Then
    Raise Exception.CreateResFmt(PResStringRec(@cInvalidDestinationIndex),
      [ACharIndex]);
  LCharCount := GetCharCount(ABytes, AByteCount);
  If LCharCount > 0 Then
  Begin
    If (ACharIndex + LCharCount) > Length(VChars) Then
      Raise Exception.CreateRes(PResStringRec(@cInvalidDestinationArray));
    Result := GetChars(ABytes, AByteCount, @VChars[ACharIndex], LCharCount);
  End
  Else
    Result := 0;
End;

Function GetChars(Const ABytes: PByte; AByteCount: Integer; AChars: PDWWideChar;
  ACharCount: Integer): Integer;
Var
  P: PByte;
  i: Integer;
Begin
  P := ABytes;
  Result := restdwMin(ACharCount, AByteCount);
  For i := 1 To Result Do
  Begin
    If P^ > $7F Then
      DWUInt16(AChars^) := $FFFD
    Else
      DWUInt16(AChars^) := P^;
    Inc(AChars);
    Inc(P);
  End;
End;

Procedure CopyRDWString(Const ASource: String; Var VDest: TRESTDWBytes;
  Const ADestIndex: Integer; Const ALength: Integer = -1);
{$IFDEF USE_INLINE}inline; {$ENDIF}
Begin
  CopyRDWString(ASource, 1, VDest, ADestIndex, ALength);
End;

Procedure CopyRDWString(Const ASource: String; Const ASourceIndex: Integer;
  Var VDest: TRESTDWBytes; Const ADestIndex: Integer;
  Const ALength: Integer = -1); {$IFDEF USE_INLINE}inline; {$ENDIF}
Var
  LLength: Integer;
  LTmp: TRESTDWWideChars;
Begin
  LTmp := nil; // keep the compiler happy
  LLength := restdwLength(ASource, ALength, ASourceIndex);
  If LLength > 0 Then
    LTmp := GetChars(RawToBytes(ASource[ASourceIndex], LLength));
  // convert to Unicode
  GetBytes(LTmp, 0, Length(LTmp), VDest, ADestIndex);
End;

Function GetTokenString(Value: String): String;
Var
  vPos: Integer;
Begin
  Result := '';
  vPos := Pos('token=', Lowercase(Value));
  If vPos > 0 Then
    vPos := vPos + Length('token=')
  Else
  Begin
    vPos := Pos('basic ', Lowercase(Value));
    If vPos > 0 Then
      vPos := vPos + Length('basic ');
  End;
  If vPos > 0 Then
    Result := Trim(Copy(Value, vPos, Length(Value)));
  If Trim(Result) <> '' Then
    Result := StringReplace(Result, '"', '', [rfReplaceAll]);
End;

Function GetBearerString(Value: String): String;
Var
  vPos: Integer;
Begin
  Result := '';
  vPos := Pos('bearer', Lowercase(Value));
  If vPos > 0 Then
    vPos := vPos + Length('bearer');
  If vPos > 0 Then
    Result := Trim(Copy(Value, vPos, Length(Value)));
  If Trim(Result) <> '' Then
    Result := StringReplace(Result, '"', '', [rfReplaceAll]);
End;

Function GetBytes(Const AChars: PDWWideChar; ACharCount: Integer;
  Var VBytes: TRESTDWBytes; AByteIndex: Integer): Integer;
Var
  Len, LByteCount: Integer;
  LBytes: PByte;
Begin
  If (AChars = Nil) And (ACharCount <> 0) Then
    Raise Exception.CreateRes(PResStringRec(@cInvalidSourceArray));
  If (VBytes = Nil) And (ACharCount <> 0) Then
    Raise Exception.CreateRes(PResStringRec(@cInvalidDestinationArray));
  If ACharCount < 0 Then
    Raise Exception.CreateResFmt(PResStringRec(@cInvalidCharCount),
      [ACharCount]);
  Len := Length(VBytes);
  LByteCount := GetByteCount(AChars, ACharCount);
  LBytes := ValidateBytes(VBytes, AByteIndex, Len, LByteCount);
  Dec(Len, AByteIndex);
  If (ACharCount > 0) And (Len > 0) Then
    Result := GetBytes(AChars, ACharCount, LBytes, LByteCount)
  Else
    Result := 0;
End;

Function GetBytes(Const AChars: TRESTDWWideChars;
  ACharIndex, ACharCount: Integer; Var VBytes: TRESTDWBytes;
  AByteIndex: Integer): Integer;
Begin
  Result := GetBytes(ValidateChars(AChars, ACharIndex, ACharCount), ACharCount,
    VBytes, AByteIndex);
End;

Function ByteToHex(Const AByte: Byte): String;
{$IFDEF USE_INLINE} Inline; {$ENDIF}
Begin
  SetLength(Result, 2);
  Result[1] := RESTDWHexDigits[(AByte And $F0) Shr 4];
  Result[2] := RESTDWHexDigits[AByte And $F];
End;

Procedure ExpandBytes(Var VBytes: TRESTDWBytes; Const AIndex: Integer;
  Const ACount: Integer; Const AFillByte: Byte = 0);
Var
  i: Integer;
Begin
  If ACount > 0 Then
  Begin
    If AIndex <> restdwLength(VBytes) Then
    Begin
      Assert(AIndex >= 0);
      Assert(AIndex < restdwLength(VBytes));
    End;
    SetLength(VBytes, restdwLength(VBytes) + ACount);
    For i := restdwLength(VBytes) - 1 Downto AIndex + ACount Do
      VBytes[i] := VBytes[i - ACount];
    For i := AIndex To AIndex + ACount - 1 Do
      VBytes[i] := AFillByte;
  End;
End;

Procedure InsertBytes(Var VBytes: TRESTDWBytes; Const ADestIndex: Integer;
  Const ASource: TRESTDWBytes; Const ASourceIndex: Integer = 0);
Var
  LAddLen: Integer;
Begin
  LAddLen := restdwLength(ASource, -1, ASourceIndex);
  If LAddLen > 0 Then
  Begin
    ExpandBytes(VBytes, ADestIndex, LAddLen);
    CopyBytes(ASource, ASourceIndex, VBytes, ADestIndex, LAddLen);
  End;
End;

Procedure InsertByte(Var VBytes: TRESTDWBytes; Const AByte: Byte;
  Const AIndex: Integer);
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Begin
  ExpandBytes(VBytes, AIndex, 1, AByte);
End;

Procedure RemoveBytes(Var VBytes: TRESTDWBytes; Const ACount: Integer;
  Const AIndex: Integer = 0);
Var
  i, LActual: Integer;
Begin
  Assert(AIndex >= 0);
  LActual := restdwMin(restdwLength(VBytes) - AIndex, ACount);
  If LActual > 0 Then
  Begin
    If (AIndex + LActual) < restdwLength(VBytes) Then
    Begin
      For i := AIndex To restdwLength(VBytes) - LActual - 1 Do
        VBytes[i] := VBytes[i + LActual];
    End;
    SetLength(VBytes, restdwLength(VBytes) - LActual);
  End;
End;

Function ByteIndex(Const AByte: Byte; Const ABytes: TRESTDWBytes;
  Const AStartIndex: Integer = 0): Integer;
Var
  i: Integer;
Begin
  Result := -1;
  For i := AStartIndex To restdwLength(ABytes) - 1 Do
  Begin
    If ABytes[i] = AByte Then
    Begin
      Result := i;
      Exit;
    End;
  End;
End;

Function ByterdwInSet(Const ABytes: TRESTDWBytes; Const AIndex: Integer;
  Const ASet: TRESTDWBytes): Integer;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Begin
  If AIndex < 0 Then
    Raise eRESTDWException.Create('Invalid AIndex'); { do not localize }
  If AIndex < restdwLength(ABytes) Then
    Result := ByteIndex(ABytes[AIndex], ASet)
  Else
    Result := -1;
End;

Function ByteIsInSet(Const ABytes: TRESTDWBytes; Const AIndex: Integer;
  Const ASet: TRESTDWBytes): Boolean;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Begin
  Result := ByterdwInSet(ABytes, AIndex, ASet) > -1;
End;

Function ByteIsInEOL(Const ABytes: TRESTDWBytes; Const AIndex: Integer)
  : Boolean;
Var
  LSet: TRESTDWBytes;
Begin
  SetLength(LSet, 2);
  LSet[0] := 13;
  LSet[1] := 10;
  Result := ByteIsInSet(ABytes, AIndex, LSet);
End;

Procedure AppendBytes(Var VBytes: TRESTDWBytes; Const AToAdd: TRESTDWBytes;
  Const AIndex: Integer = 0; Const ALength: Integer = -1);
Var
  LOldLen, LAddLen: Integer;
Begin
  LAddLen := restdwLength(AToAdd, ALength, AIndex);
  If LAddLen > 0 Then
  Begin
    LOldLen := restdwLength(VBytes);
    SetLength(VBytes, LOldLen + LAddLen);
    CopyBytes(AToAdd, AIndex, VBytes, LOldLen, LAddLen);
  End;
End;

Function IsHeaderValue(Const AHeaderLine: String; Const AValue: String)
  : Boolean;
Begin
  Result := TextIsSame(ExtractHeaderItem(AHeaderLine), AValue);
End;

Function ReadStringFromStream(AStream: TStream; ASize: Integer = -1): String;
Var
  LBytes: TRESTDWBytes;
Begin
  ASize := TRESTDWStreamHelper.ReadBytes(AStream, LBytes, ASize);
  Result := BytesToString(LBytes, 0, ASize);
End;

Procedure StringToStream(AStream: TStream; Const AStr: String);
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Begin
  WriteStringToStream(AStream, AStr, -1, 1);
End;

procedure WriteStringToStream(AStream: TStream; Const AStr: String;
  Const ALength: Integer = -1; Const AIndex: Integer = 1);
Var
  LLength: Integer;
  LBytes: TRESTDWBytes;
Begin
  LBytes := nil;
  LLength := restdwLength(AStr, ALength, AIndex);
  If LLength > 0 Then
  Begin
    LBytes := ToBytes(AStr, LLength, AIndex);
    TRESTDWStreamHelper.Write(AStream, LBytes);
  End;
End;

Function ReadBytesFromStream(Const AStream: TStream; Var ABytes: TRESTDWBytes;
  Const Count: TRESTDWStreamSize; Const AIndex: Integer = 0): TRESTDWStreamSize;
Begin
  Result := TRESTDWStreamHelper.ReadBytes(AStream, ABytes, Count, AIndex);
End;

Procedure WriteBytesToStream(Const AStream: TStream; Const ABytes: TRESTDWBytes;
  Const ASize: Integer = -1; Const AIndex: Integer = 0);
Begin
  TRESTDWStreamHelper.Write(AStream, ABytes, ASize, AIndex);
End;

Procedure CopyBytes(Const ASource: TRESTDWBytes; Const ASourceIndex: Integer;
  Var VDest: TRESTDWBytes; Const ADestIndex: Integer; Const ALength: Integer);
Begin
  Assert(ASourceIndex >= 0);
  Assert((ASourceIndex + ALength) <= restdwLength(ASource));
  Move(ASource[ASourceIndex], VDest[ADestIndex], ALength);
End;

Function RawToBytes(Const AValue: String; Const ASize: Integer): TRESTDWBytes;
Var
  vSizeChar: Integer;
  vString: String;
Begin
  vSizeChar := 1;
  If SizeOf(WideChar) > 1 Then
    vSizeChar := 2;
  // SetLength(Result, ASize * vSizeChar);
  SetLength(Result, ASize);
  If ASize > 0 Then
  Begin
    {$IF Defined(RESTDWLAZARUS) OR not Defined(RESTDWFMX)}
    Move(AnsiString(AValue)[InitStrPos], PRESTDWBytes(Result)^, Length(Result));
    {$ELSEIF Defined(RESTDWFMX)}
    Move(Utf8String(AValue)[InitStrPos], PRESTDWBytes(Result)^, Length(Result));
    {$IFEND}
  End;
End;

Function ToBytes(Const AValue: String): TRESTDWBytes;
Begin
  Result := ToBytes(AValue, -1, 1);
End;

Function ToBytes(Const AValue: String; Const ALength: Integer;
  Const AIndex: Integer = 1): TRESTDWBytes;
Var
  LLength: Integer;
  LBytes: TRESTDWBytes;
Begin
  {$IFDEF STRING_IS_ANSI}
  LBytes := nil; // keep the compiler happy
  {$ENDIF}
  LLength := restdwLength(AValue, ALength, AIndex);
  If LLength > 0 Then
    Result := RawToBytes(AValue, LLength)
  Else
    SetLength(Result, 0);
End;

Function ToBytes(Const AValue: Char): TRESTDWBytes;
Var
  LBytes: TRESTDWBytes;
Begin
  LBytes := RawToBytes(AValue, 1);
  Result := LBytes;
End;

Function ToBytes(Const AValue: TRESTDWBytes; Const ASize: Integer;
  Const AIndex: Integer = 0): TRESTDWBytes;
Var
  LSize: Integer;
Begin
  LSize := restdwLength(AValue, ASize, AIndex);
  SetLength(Result, LSize);
  If LSize > 0 Then
    CopyBytes(AValue, AIndex, Result, 0, LSize);
End;

Function InternalrestdwIndexOfName(AStrings: TStrings; Const AStr: String;
  Const ACaseSensitive: Boolean = False): Integer;
Var
  i: Integer;
Begin
  Result := -1;
  For i := 0 To AStrings.Count - 1 Do
  Begin
    If ACaseSensitive Then
    Begin
      If AStrings.Names[i] = AStr Then
      Begin
        Result := i;
        Exit;
      End;
    End
    Else
    Begin
      If TextIsSame(AStrings.Names[i], AStr) Then
      Begin
        Result := i;
        Exit;
      End;
    End;
  End;
End;

Function restdwIndexOfName(AStrings: TStrings; Const AStr: String;
  Const ACaseSensitive: Boolean = False): Integer;
Begin
  Result := InternalrestdwIndexOfName(AStrings, AStr, ACaseSensitive);
End;

Function ExtractHeaderItem(Const AHeaderLine: String): String;
Var
  S: string;
Begin
  S := AHeaderLine;
  Result := Trim(Fetch(S, ';'));
End;

Function CharRange(Const AMin, AMax: Char): String;
Var
  i: Char;
Begin
  SetLength(Result, Ord(AMax) - Ord(AMin) + 1);
  For i := AMin To AMax Do
    Result[Ord(i) - Ord(AMin) + 1] := i;
End;

Function TextStartsWith(Const S, SubS: String): Boolean;
Var
  LLen: Integer;
  P1, P2: PChar;
Begin
  LLen := Length(SubS);
  Result := LLen <= Length(S);
  If Result Then
  Begin
    P1 := PChar(S);
    P2 := PChar(SubS);
    Result := AnsiCompareText(Copy(S, 1, LLen), SubS) = 0;
  End;
End;

Function TextEndsWith(Const S, SubS: String): Boolean;
Var
  LLen: Integer;
  P1, P2: PChar;
Begin
  LLen := Length(SubS);
  Result := LLen <= Length(S);
  If Result Then
  Begin
    P1 := PChar(S);
    P2 := PChar(SubS);
    Result := AnsiCompareText(Copy(S, Length(S) - LLen + 1, LLen), SubS) = 0;
  End;
End;

Function Max(Const AValueOne, AValueTwo: Int64): Int64;
Begin
  If AValueOne < AValueTwo Then
    Result := AValueTwo
  Else
    Result := AValueOne;
End;

Function Min(Const AValueOne, AValueTwo: Int64): Int64;
{$IFDEF USE_INLINE}inline; {$ENDIF}
Begin
  If AValueOne > AValueTwo Then
    Result := AValueTwo
  Else
    Result := AValueOne;
End;

Procedure SplitHeaderSubItems(AHeaderLine: String; AItems: TStrings;
  AQuoteType: TRESTDWHeaderQuotingType);
Var
  LName, LValue, LSep: String;
  LQuoted: Boolean;
  vObject: TObject;
  i: Integer;
  Function FetchQuotedString(Var VHeaderLine: String): String;
  Begin
    Result := '';
    Delete(VHeaderLine, 1, 1);
    i := 1;
    While i <= Length(VHeaderLine) Do
    Begin
      If VHeaderLine[i] = '\' Then
      Begin
        If i < Length(VHeaderLine) Then
          Delete(VHeaderLine, i, 1);
      End
      Else If VHeaderLine[i] = '"' Then
      Begin
        Result := Copy(VHeaderLine, 1, i - 1);
        VHeaderLine := Copy(VHeaderLine, i + 1, MaxInt);
        Break;
      End;
      Inc(i);
    End;
    Fetch(VHeaderLine, ';');
  End;

Begin
  Fetch(AHeaderLine, ';');
  LSep := CharRange(#0, #32) + QuoteSpecials[AQuoteType] + #127;
  While AHeaderLine <> '' Do
  Begin
    AHeaderLine := TrimLeft(AHeaderLine);
    If AHeaderLine = '' Then
      Exit;
    LName := Trim(Fetch(AHeaderLine, '=')); { do not localize }
    AHeaderLine := TrimLeft(AHeaderLine);
    LQuoted := TextStartsWith(AHeaderLine, '"'); { do not localize }
    If LQuoted Then
      LValue := FetchQuotedString(AHeaderLine)
    Else
    Begin
      i := FindFirstOf(LSep, AHeaderLine);
      If i <> 0 Then
      Begin
        LValue := Copy(AHeaderLine, 1, i - 1);
        If AHeaderLine[i] = ';' Then
          Inc(i);
        Delete(AHeaderLine, 1, i - 1);
      End
      Else
      Begin
        LValue := AHeaderLine;
        AHeaderLine := '';
      End;
    End;
    If (LName <> '') And ((LValue <> '') Or LQuoted) Then
    Begin
      {$IFDEF RESTDWLAZARUS}
      vObject := TObject(PtrUint(LQuoted));
      {$ELSE}
      vObject := TObject(LQuoted);
      {$ENDIF}
      AItems.AddObject(LName + '=' + LValue, vObject);
    End;
  End;
End;

Function StrToDay(Const ADay: String): Byte;
Begin
  Result := Succ(PosInStrArray(ADay, ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI',
    'SAT'], False));
End;

Function StrToMonth(Const AMonth: String): Byte;
Const
  Months: Array [0 .. 7] Of Array [1 .. 12] Of String =
    (('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT',
    'NOV', 'DEC'), ('', '', '', '', '', 'JUNE', 'JULY', '', 'SEPT', '', '', ''),
    ('', '', 'MRZ', '', 'MAI', '', '', '', '', 'OKT', '', 'DEZ'),
    ('ENO', 'FBRO', 'MZO', 'AB', '', '', '', 'AGTO', 'SBRE', 'OBRE', 'NBRE',
    'DBRE'), ('', '', 'MRT', '', 'MEI', '', '', '', '', 'OKT', '', ''),
    ('JANV', 'F' + Char($C9) + 'V', 'MARS', 'AVR', 'MAI', 'JUIN', 'JUIL',
    'AO' + Char($DB), 'SEPT', '', '', 'D' + Char($C9) + 'C'),
    ('', 'F' + Char($C9) + 'VR', '', '', '', '', 'JUI', 'AO' + Char($DB) + 'T',
    '', '', '', ''), ('', '', '', '', 'MAJ', '', '', '', 'AVG', '', '', ''));
Var
  i: Integer;
Begin
  If AMonth <> '' Then
  Begin
    For i := Low(Months) To High(Months) Do
    Begin
      For Result := Low(Months[i]) To High(Months[i]) Do
      Begin
        If TextIsSame(AMonth, Months[i][Result]) Then
          Exit;
      End;
    End;
  End;
  Result := 0;
End;

Function IsNumeric(Const AString: String; Const ALength: Integer;
  Const AIndex: Integer = 1): Boolean;
Var
  i, LLen: Integer;
Begin
  Result := False;
  LLen := restdwLength(AString, ALength, AIndex);
  If LLen > 0 Then
  Begin
    For i := 0 To LLen - 1 Do
    Begin
      If Not IsNumeric(AString[AIndex + i]) Then
        Exit;
    End;
    Result := True;
  End;
End;

Function IsNumeric(Const AChar: Char): Boolean;
Begin
  Result := (AChar >= '0') And (AChar <= '9'); { Do not Localize }
End;

Function CharEquals(Const AString: String; Const ACharPos: Integer;
  Const AValue: Char): Boolean;
Begin
  If ACharPos < 1 Then
    Raise eRESTDWException.Create('Invalid ACharPos'); { do not localize }
  Result := ACharPos <= Length(AString);
  If Result Then
    Result := AString[ACharPos] = AValue;
End;

Function RawStrInternetToDateTime(Var Value: String;
  Var VDateTime: TDateTime): Boolean;
Var
  i: Integer;
  Dt, Mo, Yr, Ho, Min, Sec, MSec: Word;
  sYear, sTime, sDelim: String;
  LAM, LPM: Boolean;
  Procedure ParseDayOfMonth;
  Begin
    Dt := RDWStrToInt(Fetch(Value, sDelim), 1);
    Value := TrimLeft(Value);
  End;
  Procedure ParseMonth;
  Begin
    Mo := StrToMonth(Fetch(Value, sDelim));
    Value := TrimLeft(Value);
  End;
  Function ParseISO8601: Boolean;
  Var
    S: String;
    Len, Offset, Found: Integer;
  Begin
    Result := False;
    S := Value;
    Len := Length(S);
    If Not IsNumeric(S, 4) Then
      Exit;
    Dt := 1;
    Mo := 1;
    Ho := 0;
    Min := 0;
    Sec := 0;
    MSec := 0;
    Yr := RDWStrToInt(Copy(S, 1, 4));
    Offset := 5;
    If Offset <= Len Then
    Begin
      If (Not CharEquals(S, Offset, '-')) Or
        (Not IsNumeric(S, 2, Offset + 1)) Then
        Exit;
      Mo := RDWStrToInt(Copy(S, Offset + 1, 2));
      Inc(Offset, 3);
      If Offset <= Len Then
      Begin
        If (Not CharEquals(S, Offset, '-')) Or { Do not Localize }
          (Not IsNumeric(S, 2, Offset + 1)) Then
          Exit;
        Dt := RDWStrToInt(Copy(S, Offset + 1, 2));
        Inc(Offset, 3);
        If Offset <= Len Then
        Begin
          If (Not CharEquals(S, Offset, 'T')) Or { Do not Localize }
            (Not IsNumeric(S, 2, Offset + 1)) Or
            (Not CharEquals(S, Offset + 3, ':')) Then { Do not Localize }
            Exit;
          Ho := RDWStrToInt(Copy(S, Offset + 1, 2));
          Inc(Offset, 4);
          If Not IsNumeric(S, 2, Offset) Then
            Exit;
          Min := RDWStrToInt(Copy(S, Offset, 2));
          Inc(Offset, 2);
          If Offset > Len Then
            Exit;
          If CharEquals(S, Offset, ':') Then { Do not Localize }
          Begin
            If Not IsNumeric(S, 2, Offset + 1) Then
              Exit;
            Sec := RDWStrToInt(Copy(S, Offset + 1, 2));
            Inc(Offset, 3);
            If Offset > Len Then
              Exit;
            If CharEquals(S, Offset, '.') Then { Do not Localize }
            Begin
              Found := FindFirstNotOf('0123456789', S, -1, Offset + 1);
              { Do not Localize }
              If Found = 0 Then
                Exit;
              MSec := RDWStrToInt(Copy(S, Offset + 1, Found - Offset - 1));
              Inc(Offset, Found - Offset + 1);
            End;
          End;
        End;
      End;
    End;
    VDateTime := EncodeDate(Yr, Mo, Dt) + EncodeTime(Ho, Min, Sec, MSec);
    Value := Copy(S, Offset, MaxInt);
    Result := True;
  End;

Begin
  Result := False;
  VDateTime := 0.0;
  Value := Trim(Value);
  If Length(Value) = 0 Then
    Exit;
  Try
    If ParseISO8601 Then
    Begin
      Result := True;
      Exit;
    End;
    If StrToDay(Copy(Value, 1, 3)) > 0 Then
    Begin
      If CharEquals(Value, 4, ',') And (Not CharEquals(Value, 5, ' ')) Then
        Insert(' ', Value, 5);
      Fetch(Value);
      Value := TrimLeft(Value);
    End;
    i := InternalAnsiPos('-', Value); { Do not Localize }
    If (i > 1) And (i < InternalAnsiPos(' ', Value)) Then
      sDelim := '-'
    Else
      sDelim := ' '; { Do not Localize }
    If StrToMonth(Fetch(Value, sDelim, False)) > 0 Then
    Begin
      ParseMonth;
      ParseDayOfMonth;
    End
    Else
    Begin
      ParseDayOfMonth;
      ParseMonth;
    End;
    sYear := Fetch(Value);
    Yr := RDWStrToInt(sYear, High(Word));
    If Yr = High(Word) Then
    Begin // Is sTime valid Integer?
      sTime := sYear;
      sYear := Fetch(Value);
      Value := TrimRight(sTime + ' ' + Value);
      Yr := RDWStrToInt(sYear);
    End;
    If Length(sYear) = 2 Then
    Begin
      If (Yr <= 49) Then
        Inc(Yr, 2000)
      Else If (Yr >= 50) And (Yr <= 99) Then
        Inc(Yr, 1900);
    End
    Else If Length(sYear) = 3 Then
      Inc(Yr, 1900);
    VDateTime := EncodeDate(Yr, Mo, Dt);
    If InternalAnsiPos('AM', Value) > 0 Then
    Begin { do not localize }
      LAM := True;
      LPM := False;
      Value := Fetch(Value, 'AM'); { do not localize }
    End
    Else If InternalAnsiPos('PM', Value) > 0 Then
    Begin { do not localize }
      LAM := False;
      LPM := True;
      Value := Fetch(Value, 'PM'); { do not localize }
    End
    Else
    Begin
      LAM := False;
      LPM := False;
    End;
    i := InternalAnsiPos('.', Value); { do not localize }
    If (i > 0) And (i < InternalAnsiPos(' ', Value)) Then
      sDelim := '.' { do not localize }
    Else
      sDelim := ':'; { do not localize }
    i := InternalAnsiPos(sDelim, Value);
    If i > 0 Then
    Begin
      sTime := Fetch(Value, ' '); { do not localize }
      Ho := RDWStrToInt(Fetch(sTime, sDelim), 0);
      Min := RDWStrToInt(Fetch(sTime, sDelim), 0);
      Sec := RDWStrToInt(Fetch(sTime), 0);
      MSec := 0;
      Value := TrimLeft(Value);
      If LAM Then
      Begin
        If Ho = 12 Then
          Ho := 0;
      End
      Else If LPM Then
      Begin
        If Ho < 12 Then
          Inc(Ho, 12);
      End;
      VDateTime := VDateTime + EncodeTime(Ho, Min, Sec, MSec);
    End;
    Value := TrimLeft(Value);
    Result := True;
  Except
    VDateTime := 0.0;
    Result := False;
  End;
End;

Procedure RDWDelete(Var S: String; AOffset, ACount: Integer);
Begin
  Delete(S, AOffset, ACount);
End;

Function TimeZoneToGmtOffsetStr(Const ATimeZone: String): String;
Type
  TimeZoneOffset = Record
    TimeZone, Offset: String;
  End;
Const
  cTimeZones: Array [0 .. 90] Of TimeZoneOffset = ((TimeZone: 'A';
    Offset: '+0100'),
    // Alpha Time Zone - Military                             {do not localize}
    (TimeZone: 'ACDT'; Offset: '+1030'),
    // Australian Central Daylight Time                       {do not localize}
    (TimeZone: 'ACST'; Offset: '+0930'),
    // Australian Central Standard Time                       {do not localize}
    (TimeZone: 'ADT'; Offset: '-0300'),
    // Atlantic Daylight Time - North America                 {do not localize}
    (TimeZone: 'AEDT'; Offset: '+1100'),
    // Australian Eastern Daylight Time                       {do not localize}
    (TimeZone: 'AEST'; Offset: '+1000'),
    // Australian Eastern Standard Time                       {do not localize}
    (TimeZone: 'AKDT'; Offset: '-0800'),
    // Alaska Daylight Time                                   {do not localize}
    (TimeZone: 'AKST'; Offset: '-0900'),
    // Alaska Standard Time                                   {do not localize}
    (TimeZone: 'AST'; Offset: '-0400'),
    // Atlantic Standard Time - North America                 {do not localize}
    (TimeZone: 'AWDT'; Offset: '+0900'),
    // Australian Western Daylight Time                       {do not localize}
    (TimeZone: 'AWST'; Offset: '+0800'),
    // Australian Western Standard Time                       {do not localize}
    (TimeZone: 'B'; Offset: '+0200'),
    // Bravo Time Zone - Military                             {do not localize}
    (TimeZone: 'BST'; Offset: '+0100'),
    // British Summer Time - Europe                           {do not localize}
    (TimeZone: 'C'; Offset: '+0300'),
    // Charlie Time Zone - Military                           {do not localize}
    (TimeZone: 'CDT'; Offset: '+1030'),
    // Central Daylight Time - Australia                      {do not localize}
    (TimeZone: 'CDT'; Offset: '-0500'),
    // Central Daylight Time - North America                  {do not localize}
    (TimeZone: 'CEDT'; Offset: '+0200'),
    // Central European Daylight Time                         {do not localize}
    (TimeZone: 'CEST'; Offset: '+0200'),
    // Central European Summer Time                           {do not localize}
    (TimeZone: 'CET'; Offset: '+0100'),
    // Central European Time                                  {do not localize}
    (TimeZone: 'CST'; Offset: '+1030'),
    // Central Summer Time - Australia                        {do not localize}
    (TimeZone: 'CST'; Offset: '+0930'),
    // Central Standard Time - Australia                      {do not localize}
    (TimeZone: 'CST'; Offset: '-0600'),
    // Central Standard Time - North America                  {do not localize}
    (TimeZone: 'CXT'; Offset: '+0700'),
    // Christmas Island Time - Australia                      {do not localize}
    (TimeZone: 'D'; Offset: '+0400'),
    // Delta Time Zone - Military                             {do not localize}
    (TimeZone: 'E'; Offset: '+0500'),
    // Echo Time Zone - Military                              {do not localize}
    (TimeZone: 'EDT'; Offset: '+1100'),
    // Eastern Daylight Time - Australia                      {do not localize}
    (TimeZone: 'EDT'; Offset: '-0400'),
    // Eastern Daylight Time - North America                  {do not localize}
    (TimeZone: 'EEDT'; Offset: '+0300'),
    // Eastern European Daylight Time                         {do not localize}
    (TimeZone: 'EEST'; Offset: '+0300'),
    // Eastern European Summer Time                           {do not localize}
    (TimeZone: 'EET'; Offset: '+0200'),
    // Eastern European Time                                  {do not localize}
    (TimeZone: 'EST'; Offset: '+1100'),
    // Eastern Summer Time - Australia                        {do not localize}
    (TimeZone: 'EST'; Offset: '+1000'),
    // Eastern Standard Time - Australia                      {do not localize}
    (TimeZone: 'EST'; Offset: '-0500'),
    // Eastern Standard Time - North America                  {do not localize}
    (TimeZone: 'F'; Offset: '+0600'),
    // Foxtrot Time Zone - Military                           {do not localize}
    (TimeZone: 'G'; Offset: '+0700'),
    // Golf Time Zone - Military                              {do not localize}
    (TimeZone: 'GMT'; Offset: '+0000'),
    // Greenwich Mean Time - Europe                           {do not localize}
    (TimeZone: 'H'; Offset: '+0800'),
    // Hotel Time Zone - Military                             {do not localize}
    (TimeZone: 'HAA'; Offset: '-0300'),
    // Heure Avancée de l'Atlantique - North America          {do not localize}
    (TimeZone: 'HAC'; Offset: '-0500'),
    // Heure Avancée du Centre - North America                {do not localize}
    (TimeZone: 'HADT'; Offset: '-0900'),
    // Hawaii-Aleutian Daylight Time - North America          {do not localize}
    (TimeZone: 'HAE'; Offset: '-0400'),
    // Heure Avancée de l'Est - North America                 {do not localize}
    (TimeZone: 'HAP'; Offset: '-0700'),
    // Heure Avancée du Pacifique - North America             {do not localize}
    (TimeZone: 'HAR'; Offset: '-0600'),
    // Heure Avancée des Rocheuses - North America            {do not localize}
    (TimeZone: 'HAST'; Offset: '-1000'),
    // Hawaii-Aleutian Standard Time - North America          {do not localize}
    (TimeZone: 'HAT'; Offset: '-0230'),
    // Heure Avancée de Terre-Neuve - North America           {do not localize}
    (TimeZone: 'HAY'; Offset: '-0800'),
    // Heure Avancée du Yukon - North America                 {do not localize}
    (TimeZone: 'HNA'; Offset: '-0400'),
    // Heure Normale de l'Atlantique - North America          {do not localize}
    (TimeZone: 'HNC'; Offset: '-0600'),
    // Heure Normale du Centre - North America                {do not localize}
    (TimeZone: 'HNE'; Offset: '-0500'),
    // Heure Normale de l'Est - North America                 {do not localize}
    (TimeZone: 'HNP'; Offset: '-0800'),
    // Heure Normale du Pacifique - North America             {do not localize}
    (TimeZone: 'HNR'; Offset: '-0700'),
    // Heure Normale des Rocheuses - North America            {do not localize}
    (TimeZone: 'HNT'; Offset: '-0330'),
    // Heure Normale de Terre-Neuve - North America           {do not localize}
    (TimeZone: 'HNY'; Offset: '-0900'),
    // Heure Normale du Yukon - North America                 {do not localize}
    (TimeZone: 'I'; Offset: '+0900'),
    // India Time Zone - Military                             {do not localize}
    (TimeZone: 'IST'; Offset: '+0100'),
    // Irish Summer Time - Europe                             {do not localize}
    (TimeZone: 'K'; Offset: '+1000'),
    // Kilo Time Zone - Military                              {do not localize}
    (TimeZone: 'L'; Offset: '+1100'),
    // Lima Time Zone - Military                              {do not localize}
    (TimeZone: 'M'; Offset: '+1200'),
    // Mike Time Zone - Military                              {do not localize}
    (TimeZone: 'MDT'; Offset: '-0600'),
    // Mountain Daylight Time - North America                 {do not localize}
    (TimeZone: 'MEHSZ'; Offset: '+0300'),
    // Mitteleuropäische Hochsommerzeit - Europe              {do not localize}
    (TimeZone: 'MESZ'; Offset: '+0200'),
    // Mitteleuroäische Sommerzeit - Europe                   {do not localize}
    (TimeZone: 'MEZ'; Offset: '+0100'),
    // Mitteleuropäische Zeit - Europe                        {do not localize}
    (TimeZone: 'MSD'; Offset: '+0400'),
    // Moscow Daylight Time - Europe                          {do not localize}
    (TimeZone: 'MSK'; Offset: '+0300'),
    // Moscow Standard Time - Europe                          {do not localize}
    (TimeZone: 'MST'; Offset: '-0700'),
    // Mountain Standard Time - North America                 {do not localize}
    (TimeZone: 'N'; Offset: '-0100'),
    // November Time Zone - Military                          {do not localize}
    (TimeZone: 'NDT'; Offset: '-0230'),
    // Newfoundland Daylight Time - North America             {do not localize}
    (TimeZone: 'NFT'; Offset: '+1130'),
    // Norfolk (Island), Time - Australia                     {do not localize}
    (TimeZone: 'NST'; Offset: '-0330'),
    // Newfoundland Standard Time - North America             {do not localize}
    (TimeZone: 'O'; Offset: '-0200'),
    // Oscar Time Zone - Military                             {do not localize}
    (TimeZone: 'P'; Offset: '-0300'),
    // Papa Time Zone - Military                              {do not localize}
    (TimeZone: 'PDT'; Offset: '-0700'),
    // Pacific Daylight Time - North America                  {do not localize}
    (TimeZone: 'PST'; Offset: '-0800'),
    // Pacific Standard Time - North America                  {do not localize}
    (TimeZone: 'Q'; Offset: '-0400'),
    // Quebec Time Zone - Military                            {do not localize}
    (TimeZone: 'R'; Offset: '-0500'),
    // Romeo Time Zone - Military                             {do not localize}
    (TimeZone: 'S'; Offset: '-0600'),
    // Sierra Time Zone - Military                            {do not localize}
    (TimeZone: 'T'; Offset: '-0700'),
    // Tango Time Zone - Military                             {do not localize}
    (TimeZone: 'U'; Offset: '-0800'),
    // Uniform Time Zone - Military                           {do not localize}
    (TimeZone: 'UT'; Offset: '+0000'),
    // Universal Time - Europe                                {do not localize}
    (TimeZone: 'UTC'; Offset: '+0000'),
    // Coordinated Universal Time - Europe                    {do not localize}
    (TimeZone: 'V'; Offset: '-0900'),
    // Victor Time Zone - Military                            {do not localize}
    (TimeZone: 'W'; Offset: '-1000'),
    // Whiskey Time Zone - Military                           {do not localize}
    (TimeZone: 'WDT'; Offset: '+0900'),
    // Western Daylight Time - Australia                      {do not localize}
    (TimeZone: 'WEDT'; Offset: '+0100'),
    // Western European Daylight Time - Europe                {do not localize}
    (TimeZone: 'WEST'; Offset: '+0100'),
    // Western European Summer Time - Europe                  {do not localize}
    (TimeZone: 'WET'; Offset: '+0000'),
    // Western European Time - Europe                         {do not localize}
    (TimeZone: 'WST'; Offset: '+0900'),
    // Western Summer Time - Australia                        {do not localize}
    (TimeZone: 'WST'; Offset: '+0800'),
    // Western Standard Time - Australia                      {do not localize}
    (TimeZone: 'X'; Offset: '-1100'),
    // X-ray Time Zone - Military                             {do not localize}
    (TimeZone: 'Y'; Offset: '-1200'),
    // Yankee Time Zone - Military                            {do not localize}
    (TimeZone: 'Z'; Offset: '+0000')
    // Zulu Time Zone - Military                              {do not localize}
    );
Var
  i: Integer;
Begin
  For i := Low(cTimeZones) To High(cTimeZones) Do
  Begin
    If TextIsSame(ATimeZone, cTimeZones[i].TimeZone) Then
    Begin
      Result := cTimeZones[i].Offset;
      Exit;
    End;
  End;
  Result := '-0000' { do not localize }
End;

Function GmtOffsetStrToDateTime(Const S: String): TDateTime;
Var
  sTmp: String;
Begin
  Result := 0.0;
  sTmp := Trim(S);
  sTmp := Fetch(sTmp);
  If Length(sTmp) > 0 Then
  Begin
    If not CharIsInSet(sTmp, 1, '-+') Then
      sTmp := TimeZoneToGmtOffsetStr(sTmp)
    Else
    Begin
      If Length(sTmp) = 6 Then
      Begin
        If CharEquals(sTmp, 4, ':') Then
          RDWDelete(sTmp, 4, 1);
      End
      Else If Length(sTmp) = 3 Then
        sTmp := sTmp + '00';
      If (Length(sTmp) <> 5) Or (Not IsNumeric(sTmp, 2, 2)) Or
        (Not IsNumeric(sTmp, 2, 4)) Then
        Exit;
    End;
    Try
      Result := EncodeTime(RDWStrToInt(Copy(sTmp, 2, 2)),
        RDWStrToInt(Copy(sTmp, 4, 2)), 0, 0);
      If CharEquals(sTmp, 1, '-') Then
        Result := -Result;
    Except
      Result := 0.0;
    End;
  End;
End;

Function ReplaceHeaderSubItem(Const AHeaderLine, ASubItem, AValue: String;
  AQuoteType: TRESTDWHeaderQuotingType): String;
Var
  LOld: String;
Begin
  Result := ReplaceHeaderSubItem(AHeaderLine, ASubItem, AValue, LOld,
    AQuoteType);
End;

Function ReplaceHeaderSubItem(Const AHeaderLine, ASubItem, AValue: String;
  Var VOld: String; AQuoteType: TRESTDWHeaderQuotingType): String;
Var
  LItems: TStringList;
  i: Integer;
  LValue: String;
  vValidate: Boolean;
  Function QuoteString(Const S: String; Const AForceQuotes: Boolean): String;
  Var
    i: Integer;
    LAddQuotes: Boolean;
    LNeedQuotes, LNeedEscape: String;
  Begin
    Result := '';
    If Length(S) = 0 Then
      Exit;
    LAddQuotes := AForceQuotes;
    LNeedQuotes := CharRange(#0, #32) + QuoteSpecials[AQuoteType] + #127;
    LNeedEscape := '"\';
    If AQuoteType In [QuoteRFC822, QuoteMIME] Then
      LNeedEscape := LNeedEscape + CR;
    For i := 1 To Length(S) Do
    Begin
      If CharIsInSet(S, i, LNeedEscape) Then
      Begin
        LAddQuotes := True;
        Result := Result + '\';
      End
      Else If CharIsInSet(S, i, LNeedQuotes) Then
        LAddQuotes := True;
      Result := Result + S[i];
      If LAddQuotes Then
        Result := '"' + Result + '"';
    End;
  End;

Begin
  Result := '';
  LItems := TStringList.Create;
  Try
    SplitHeaderSubItems(AHeaderLine, LItems, AQuoteType);
    {$IFDEF HAS_TStringList_CaseSensitive}
    LItems.CaseSensitive := False;
    {$ENDIF}
    i := InternalrestdwIndexOfName(LItems, ASubItem);
    If i >= 0 Then
    Begin
      VOld := LItems.Strings[i];
      Fetch(VOld, '=');
    End
    Else
      VOld := '';
    LValue := Trim(AValue);
    If LValue <> '' Then
    Begin
      If i < 0 Then
        LItems.Add(ASubItem + '=' + LValue)
      Else
        LItems.Strings[i] := ASubItem + '=' + LValue;
    End
    Else If i < 0 Then
    Begin
      Result := AHeaderLine;
      Exit;
    End
    Else
      LItems.Delete(i);
    Result := ExtractHeaderItem(AHeaderLine);
    If Result <> '' Then
    Begin
      For i := 0 To LItems.Count - 1 Do
      Begin
        {$IFDEF RESTDWLAZARUS}
        vValidate := Boolean(PtrUint(LItems.Objects[i]));
        {$ELSE}
        vValidate := Boolean(LItems.Objects[i]);
        {$ENDIF}
        Result := Result + '; ' + LItems.Names[i] + '=' +
          QuoteString(ValueFromIndex(LItems, i), vValidate); { do not localize }
      End;
    End;
  Finally
    LItems.Free;
  End;
End;

Function PosInStrArray(Const SearchStr: String; Const Contents: Array Of String;
  Const CaseSensitive: Boolean = True): Integer;
Begin
  For Result := Low(Contents) To High(Contents) Do
  Begin
    If CaseSensitive Then
    Begin
      If SearchStr = Contents[Result] Then
        Exit;
    End
    Else
    Begin
      If TextIsSame(SearchStr, Contents[Result]) Then
        Exit;
    End;
  End;
  Result := -1;
End;

Function InternalAnsiPos(Const Substr, S: String): Integer;
Begin
  Result := SysUtils.AnsiPos(Substr, S);
End;

Function iif(ATest: Boolean; Const ATrue: Integer;
  Const AFalse: Integer): Integer;
Begin
  If ATest Then
    Result := ATrue
  Else
    Result := AFalse;
End;

Function TextIsSame(Const A1, A2: String): Boolean;
Begin
  Result := AnsiCompareText(A1, A2) = 0;
End;

Function CharPosInSet(Const AString: String; Const ACharPos: Integer;
  Const ASet: String): Integer;
Var
  LChar: Char;
  i: Integer;
Begin
  Result := 0;
  If ACharPos < 1 Then
    Raise eRESTDWException.Create('Invalid ACharPos');
  If ACharPos <= Length(AString) Then
  Begin
    LChar := AString[ACharPos];
    For i := 1 To Length(ASet) Do
    Begin
      If ASet[i] = LChar Then
      Begin
        Result := i;
        Exit;
      End;
    End;
  End;
End;

Function CharIsInSet(Const AString: String; Const ACharPos: Integer;
  Const ASet: String): Boolean;
Begin
  Result := CharPosInSet(AString, ACharPos, ASet) > 0;
End;

Function ValueFromIndex(AStrings: TStrings; Const AIndex: Integer): String;
Var
  LTmp: String;
  LPos: Integer;
Begin
  Result := '';
  If AIndex >= 0 Then
  Begin
    LTmp := AStrings.Strings[AIndex];
    LPos := Pos('=', LTmp);
    If LPos > 0 Then
    Begin
      Result := Copy(LTmp, LPos + 1, MaxInt);
      Exit;
    End;
  End;
End;

Function ReadLnFromStream(AStream: TStream; Var VLine: String;
  AMaxLineLength: Integer = -1): Boolean;
Const
  LBUFMAXSIZE = 2048;
Var
  LStringLen, LResultLen, LBufSize: Integer;
  LBuf, LLine: TRESTDWBytes;
  LStrmPos, LStrmSize: TRESTDWStreamSize;
  LCrEncountered: Boolean;
  Function FindEOL(Const ABuf: TRESTDWBytes; Var VLineBufSize: Integer;
    Var VCrEncountered: Boolean): Integer;
  Var
    i: Integer;
  Begin
    Result := VLineBufSize; // EOL not found => use all
    i := 0;
    While i < VLineBufSize Do
    Begin
      Case ABuf[i] Of
        Ord(LF):
          Begin
            Result := i;
            VCrEncountered := True;
            VLineBufSize := i + 1;
            Break;
          End;
        Ord(CR):
          Begin
            Result := i;
            VCrEncountered := True;
            Inc(i);
            If (i < VLineBufSize) And (ABuf[i] = Ord(LF)) Then
              VLineBufSize := i + 1
            Else
              VLineBufSize := i;
            Break;
          End;
      End;
      Inc(i);
    End;
  End;

  Function ReadBytes(Const AStream: TStream; Var VBytes: TRESTDWBytes;
    Const ACount, AOffset: Integer): Integer;
  Var
    LActual: Integer;
  Begin
    Assert(AStream <> Nil);
    Result := 0;
    If VBytes = Nil Then
      SetLength(VBytes, 0);
    LActual := ACount;
    If LActual < 0 Then
      LActual := AStream.Size - AStream.Position;
    If LActual = 0 Then
      Exit;
    If restdwLength(VBytes) < (AOffset + LActual) Then
      SetLength(VBytes, AOffset + LActual);
    Assert(VBytes <> nil);
    Result := AStream.Read(VBytes[AOffset], LActual);
  End;
  Procedure CopyRESTDWBytes(Const ASource: TRESTDWBytes;
    Const ASourceIndex: Integer; Var VDest: TRESTDWBytes;
    Const ADestIndex, ALength: Integer);
  Begin
    Assert(ASourceIndex >= 0);
    Assert((ASourceIndex + ALength) <= restdwLength(ASource));
    Move(ASource[ASourceIndex], VDest[ADestIndex], ALength);
  End;

Begin
  Assert(AStream <> Nil);
  VLine := '';
  SetLength(LLine, 0);
  If AMaxLineLength < 0 Then
    AMaxLineLength := MaxInt;
  LStrmPos := AStream.Position;
  LStrmSize := AStream.Size;
  If LStrmPos >= LStrmSize Then
  Begin
    Result := False;
    Exit;
  End;
  SetLength(LBuf, LBUFMAXSIZE);
  LCrEncountered := False;
  Repeat
    LBufSize := ReadBytes(AStream, LBuf, restdwMin(LStrmSize - LStrmPos,
      LBUFMAXSIZE), 0);
    If LBufSize < 1 Then
      Break;
    LStringLen := FindEOL(LBuf, LBufSize, LCrEncountered);
    Inc(LStrmPos, LBufSize);
    LResultLen := Length(VLine);
    If (LResultLen + LStringLen) > AMaxLineLength Then
    Begin
      LStringLen := AMaxLineLength - LResultLen;
      LCrEncountered := True;
      Dec(LStrmPos, LBufSize);
      Inc(LStrmPos, LStringLen);
    End;
    If LStringLen > 0 Then
    Begin
      LBufSize := restdwLength(LLine);
      SetLength(LLine, LBufSize + LStringLen);
      CopyRESTDWBytes(LBuf, 0, LLine, LBufSize, LStringLen);
    End;
  Until (LStrmPos >= LStrmSize) or LCrEncountered;
  AStream.Position := LStrmPos;
  VLine := BytesToString(LLine, 0, -1);
  Result := True;
End;

Function restdwPos(Const Substr, S: String): Integer;
Begin
  Result := Pos(Substr, S);
End;

Function restdwMax(Const AValueOne, AValueTwo: Int64): Int64;
Begin
  If AValueOne < AValueTwo Then
    Result := AValueTwo
  Else
    Result := AValueOne;
End;

Function restdwLength(Const ABuffer: String; Const ALength: Integer = -1;
  Const AIndex: Integer = 1): Integer;
Var
  LAvailable: Integer;
Begin
  Assert(AIndex >= 1);
  LAvailable := restdwMax(Length(ABuffer) - AIndex + 1, 0);
  If ALength < 0 Then
    Result := LAvailable
  Else
    Result := restdwMin(LAvailable, ALength);
End;

Function restdwLength(Const ABuffer: TRESTDWBytes; Const ALength: Integer = -1;
  Const AIndex: Integer = 0): Integer;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Var
  LAvailable: Integer;
Begin
  Assert(AIndex >= 0);
  LAvailable := restdwMax(Length(ABuffer) - AIndex, 0);
  If ALength < 0 Then
    Result := LAvailable
  Else
    Result := restdwMin(LAvailable, ALength);
End;

Function restdwLength(Const ABuffer: TStream;
  Const ALength: TRESTDWStreamSize = -1): TRESTDWStreamSize;
{$IFDEF USE_INLINE}inline; {$ENDIF}
Var
  LAvailable: TRESTDWStreamSize;
Begin
  LAvailable := restdwMax(ABuffer.Size - ABuffer.Position, 0);
  If ALength < 0 Then
    Result := LAvailable
  Else
    Result := restdwMin(LAvailable, ALength);
End;

Function Fetch(Var AInput: String; Const ADelim: String = '';
  Const ADelete: Boolean = True; Const ACaseSensitive: Boolean = True): String;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Var
  LPos: Integer;
  Function FetchCaseInsensitive(Var AInput: String; Const ADelim: String;
    Const ADelete: Boolean): String;
  Var
    LPos: Integer;
  Begin
    If ADelim = #0 Then
      LPos := Pos(ADelim, AInput)
    Else
      LPos := restdwPos(UpperCase(ADelim), UpperCase(AInput));
    If LPos = 0 Then
    Begin
      Result := AInput;
      if ADelete Then
        AInput := '';
    End
    Else
    Begin
      Result := Copy(AInput, 1, LPos - 1);
      If ADelete Then
        AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
    End;
  End;

Begin
  If ACaseSensitive Then
  Begin
    If ADelim = #0 Then
      LPos := Pos(ADelim, AInput)
    Else
      LPos := restdwPos(ADelim, AInput);
    If LPos = 0 Then
    Begin
      Result := AInput;
      If ADelete Then
        AInput := ''; { Do not Localize }
    End
    Else
    Begin
      Result := Copy(AInput, 1, LPos - 1);
      If ADelete Then
        AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
    End;
  End
  Else
    Result := FetchCaseInsensitive(AInput, ADelim, ADelete);
End;

Function restdwValueFromIndex(AStrings: TStrings;
  Const AIndex: Integer): String;
Begin
  Result := ValueFromIndex(AStrings, AIndex);
End;

Procedure DeleteInvalidChar(Var Value: String);
Begin
  If Length(Value) > 0 Then
    If Value[InitStrPos] <> '{' then
      Delete(Value, 1, 1);
  If Length(Value) > 0 Then
    If Value[Length(Value) - FinalStrPos] <> '{' then
      Delete(Value, Length(Value), 1);
End;

Function StringToBoolean(AValue: String): Boolean;
Begin
  Result := Lowercase(Trim(AValue)) = 'true';
End;

Function BooleanToString(AValue: Boolean): String;
Begin
  If AValue Then
    Result := 'true'
  Else
    Result := 'false';
End;

Function ExtractHeaderSubItem(Const AHeaderLine, ASubItem: String;
  QuotingType: TRESTDWHeaderQuotingType): String;
Var
  LItems: TStringList;
  i: Integer;
Begin
  Result := '';
  LItems := TStringList.Create;
  Try
    SplitHeaderSubItems(AHeaderLine, LItems, QuotingType);
    i := restdwIndexOfName(LItems, ASubItem);
    If i <> -1 Then
      Result := restdwValueFromIndex(LItems, i);
  Finally
    LItems.Free;
  End;
End;

Function ReadLnFromStream(AStream: TStream; AMaxLineLength: Integer = -1;
  AExceptionIfEOF: Boolean = False): String; overload;
Begin
  If (Not ReadLnFromStream(AStream, Result, AMaxLineLength)) and AExceptionIfEOF
  then
    Raise Exception.Create(Format(cStreamReadError, ['ReadLnFromStream',
      AStream.Position]));
end;

Function RemoveBackslashCommands(Value: String): String;
Begin
  Result := StringReplace(Value, '../', '', [rfReplaceAll]);
  Result := StringReplace(Result, '..\', '', [rfReplaceAll]);
End;

Function TravertalPathFind(Value: String): Boolean;
Begin
  Result := Pos('../', Value) > 0;
  If Not Result Then
    Result := Pos('..\', Value) > 0;
End;

Function GetEventName(Value: String): String;
Begin
  Result := Value;
  If Pos('.', Result) > 0 Then
    Result := Copy(Result, Pos('.', Result) + 1, Length(Result));
End;

Function RESTDWFileExists(sFile, BaseFilePath: String): Boolean;
Var
  vTempFilename: String;
Begin
  vTempFilename := sFile;
  Result := (Pos('.', vTempFilename) > 0);
  If Result Then
  Begin
    Result := FileExists(vTempFilename);
    If Not Result Then
      Result := FileExists(BaseFilePath + vTempFilename);
  End;
End;

Procedure CopyStringList(Const Source, Dest: TStringList);
Var
  i: Integer;
Begin
  If Assigned(Source) And Assigned(Dest) Then
    For i := 0 To Source.Count - 1 Do
      Dest.Add(Source[i]);
End;

Function HexToBookmark(Value: String): TRESTDWBytes;
begin
  SetLength(Result, 0);
  If Trim(Value) = '' Then
    Exit;
  SetLength(Result, Length(Value) div SizeOf(Char));
  {$IF Defined(RESTDWMOBILE)} // Alterado para IOS Brito
  HexToBin(PWideChar(Value), 0, TBytes(Result), 0, restdwLength(Result));
  {$ELSEIF (NOT Defined(FPC) AND Defined(LINUX))} // Alteardo para Lazarus LINUX Brito
  HexToBin(PWideChar(Value), Result, restdwLength(Result));
  {$ELSE}
  HexToBin(PChar(Value), PAnsiChar(Result), restdwLength(Result));
  {$IFEND}
End;

Function BookmarkToHex(Value: TRESTDWBytes): String;
{$IFDEF RESTDWFMX}
Var
  bytes: TBytes;
  {$ENDIF}
Begin
  Result := '';
  If restdwLength(Value) > 0 Then
  Begin
    SetLength(Result, restdwLength(Value) * SizeOf(Char));
    {$IFDEF RESTDWFMX} // Alterado para IOS Brito
    SetLength(bytes, restdwLength(Value) div 2);
    HexToBin(PWideChar(Value), 0, bytes, 0, Length(bytes));
    Result := TEncoding.UTF8.GetString(bytes);
    {$ELSE}
    BinToHex(PAnsiChar(Value), PChar(Result), restdwLength(Value));
    {$ENDIF}
  End;
End;

Function Unescape_chars(S: String): String;
  Function HexValue(C: Char): Byte;
  Begin
    Case C of
      '0' .. '9':
        Result := Byte(C) - Byte('0');
      'a' .. 'f':
        Result := (Byte(C) - Byte('a')) + 10;
      'A' .. 'F':
        Result := (Byte(C) - Byte('A')) + 10;
    Else
      raise Exception.Create('Illegal hexadecimal characters "' + C + '"');
    End;
  End;

Var
  C: Char;
  i, ubuf: Integer;
Begin
  Result := '';
  i := InitStrPos;
  While i <= (Length(S) - FinalStrPos) Do
  Begin
    C := S[i];
    Inc(i);
    If C = '\' then
    Begin
      C := S[i];
      Inc(i);
      Case C of
        'b':
          Result := Result + #8;
        't':
          Result := Result + #9;
        'n':
          Result := Result + #10;
        'f':
          Result := Result + #12;
        'r':
          Result := Result + #13;
        'u':
          Begin
            If Not TryStrToInt('$' + Copy(S, i, 4), ubuf) Then
              Raise Exception.Create(Format('Invalid unicode \u%s',
                [Copy(S, i, 4)]));
            Result := Result + WideChar(ubuf);
            Inc(i, 4);
          End;
      Else
        Result := Result + C;
      End;
    End
    Else
      Result := Result + C;
  End;
End;

Function Escape_chars(S: String): String;
Var
  b, C: Char;
  i, Len: Integer;
  sb, t: String;
Const
  NoConversion = ['A' .. 'Z', 'a' .. 'z', '*', '@', '.', '_', '-', '0' .. '9',
    '$', '!', '''', '(', ')', ' '];
  Function toHexString(C: Char): String;
  Begin
    Result := IntToHex(Ord(C), 2);
  End;

Begin
  C := #0;
  {$IFDEF RESTDWLAZARUS}
  b := #0;
  i := 0;
  {$ENDIF}
  Len := Length(S);
  Result := '';
  // SetLength (s, len+4);
  t := '';
  sb := '';
  For i := InitStrPos to Len - FinalStrPos Do
  Begin
    b := C;
    C := S[i];
    Case (C) Of
      '\', '"':
        Begin
          sb := sb + '\';
          sb := sb + C;
        End;
      '/':
        Begin
          If (b = '<') Then
            sb := sb + '\';
          sb := sb + C;
        End;
      #8:
        Begin
          sb := sb + '\b';
        End;
      #9:
        Begin
          sb := sb + '\t';
        End;
      #10:
        Begin
          sb := sb + '\n';
        End;
      #12:
        Begin
          sb := sb + '\f';
        End;
      #13:
        Begin
          sb := sb + '\r';
        End;
    Else
      Begin
        If (Not(C in NoConversion)) Then
        Begin
          t := '000' + toHexString(C);
          sb := sb + '\u' + Copy(t, Length(t) - 3, 4);
        End
        Else
          sb := sb + C;
      End;
    End;
  End;
  Result := sb;
End;

Function StrToFieldType(FieldType: String): TFieldType;
Var
  vFieldType: String;
Begin
  Result := ftString;
  vFieldType := UpperCase(FieldType);
  If vFieldType = UpperCase('ftUnknown') Then
    Result := ftUnknown
  Else If vFieldType = UpperCase('ftString') Then
    Result := ftString
  Else If vFieldType = UpperCase('ftSmallint') Then
    Result := ftSmallint
  Else If vFieldType = UpperCase('ftInteger') Then
    Result := ftInteger
  Else If vFieldType = UpperCase('ftWord') Then
    Result := ftWord
  Else If vFieldType = UpperCase('ftBoolean') Then
    Result := ftBoolean
  Else If vFieldType = UpperCase('ftFloat') Then
    Result := ftFloat
  Else If vFieldType = UpperCase('ftCurrency') Then
    Result := ftCurrency
  Else If vFieldType = UpperCase('ftBCD') Then
    Result := ftFloat
  Else If vFieldType = UpperCase('ftDate') Then
    Result := ftDate
  Else If vFieldType = UpperCase('ftTime') Then
    Result := ftTime
  Else If vFieldType = UpperCase('ftDateTime') Then
    Result := ftDateTime
  Else If vFieldType = UpperCase('ftBytes') Then
    Result := ftBytes
  Else If vFieldType = UpperCase('ftVarBytes') Then
    Result := ftVarBytes
  Else If vFieldType = UpperCase('ftAutoInc') Then
    Result := ftAutoInc
  Else If vFieldType = UpperCase('ftBlob') Then
    Result := ftBlob
  Else If vFieldType = UpperCase('ftMemo') Then
    Result := ftMemo
    {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHIXEUP)} // delphi 7   compatibilidade enter Sever no XE e Client no D7
  Else If vFieldType = UpperCase('ftWideMemo') Then
    Result := ftMemo
    {$IFEND}
  Else If vFieldType = UpperCase('ftGraphic') Then
    Result := ftGraphic
  Else If vFieldType = UpperCase('ftFmtMemo') Then
    Result := ftFmtMemo
  Else If vFieldType = UpperCase('ftParadoxOle') Then
    Result := ftParadoxOle
  Else If vFieldType = UpperCase('ftDBaseOle') Then
    Result := ftDBaseOle
  Else If vFieldType = UpperCase('ftTypedBinary') Then
    Result := ftTypedBinary
  Else If vFieldType = UpperCase('ftCursor') Then
    Result := ftCursor
  Else If vFieldType = UpperCase('ftFixedChar') Then
    Result := ftFixedChar
  Else If vFieldType = UpperCase('ftWideString') Then
    {$IFDEF DELPHIXEUP}
    Result := ftWideString
    {$ELSE}
    Result := ftString
    {$ENDIF}
  Else If vFieldType = UpperCase('ftLargeint') Then
    Result := ftLargeint
  Else If vFieldType = UpperCase('ftADT') Then
    Result := ftADT
  Else If vFieldType = UpperCase('ftArray') Then
    Result := ftArray
  Else If vFieldType = UpperCase('ftReference') Then
    Result := ftReference
  Else If vFieldType = UpperCase('ftDataSet') Then
    Result := ftDataSet
  Else If vFieldType = UpperCase('ftOraBlob') Then
    Result := ftOraBlob
  Else If vFieldType = UpperCase('ftOraClob') Then
    Result := ftOraClob
  Else If vFieldType = UpperCase('ftVariant') Then
    Result := ftVariant
  Else If vFieldType = UpperCase('ftInterface') Then
    Result := ftInterface
  Else If vFieldType = UpperCase('ftIDispatch') Then
    Result := ftIDispatch
  Else If vFieldType = UpperCase('ftGuid') Then
    Result := ftGuid
  Else If vFieldType = UpperCase('ftTimeStamp') Then
    {$IFNDEF RESTDWLAZARUS}
    Result := ftTimeStamp
    {$ELSE}
    Result := ftDateTime
    {$ENDIF}
  Else If vFieldType = UpperCase('ftSingle') Then
    {$IFDEF DELPHIXEUP}
    Result := ftSingle
    {$ELSE}
    Result := ftFloat
    {$ENDIF}
  Else If vFieldType = UpperCase('ftFMTBcd') Then
    Result := ftFloat
    {$IFDEF DELPHIXEUP}
  Else If vFieldType = UpperCase('ftFixedWideChar') Then
    Result := ftFixedWideChar
  Else If vFieldType = UpperCase('ftWideMemo') Then
    Result := ftWideMemo
  Else If vFieldType = UpperCase('ftOraTimeStamp') Then
    Result := ftOraTimeStamp
  Else If vFieldType = UpperCase('ftOraInterval') Then
    Result := ftOraInterval
  Else If vFieldType = UpperCase('ftLongWord') Then
    Result := ftLongWord
  Else If vFieldType = UpperCase('ftShortint') Then
    Result := ftShortint
  Else If vFieldType = UpperCase('ftByte') Then
    Result := ftByte
  Else If vFieldType = UpperCase('ftExtended') Then
    Result := ftFloat
  Else If vFieldType = UpperCase('ftConnection') Then
    Result := ftConnection
  Else If vFieldType = UpperCase('ftParams') Then
    Result := ftParams
  Else If vFieldType = UpperCase('ftStream') Then
    Result := ftStream
  Else If vFieldType = UpperCase('ftTimeStampOffset') Then
    Result := ftTimeStampOffset
  Else If vFieldType = UpperCase('ftObject') Then
    Result := ftObject
    (* {$if CompilerVersion =15}
      Else If vFieldType = Uppercase('ftWideMemo')   Then
      Result := ftMemo
      {$IFEND}
    *)
    {$ENDIF};
End;

Function StringToFieldType(Const S: String): Integer;
Begin
  If not IdentToInt(S, Result, FieldTypeIdents) then
    Result := Integer(StrToFieldType(S))
  Else
    Result := Integer(StrToFieldType(S));
  If TFieldType(Result) = ftWideString Then
    Result := Integer(ftString);
End;

Function StreamToBytes(Stream: TStream): TRESTDWBytes;
Begin
  Try
    Stream.Position := 0;
    SetLength(Result, Stream.Size);
    Stream.ReadBuffer(Result[0], Stream.Size);
  Finally
  End;
end;

Function StringToBytes(AStr: String; aUnicode: Boolean): TRESTDWBytes;
Begin
  SetLength(Result, 0);
  If AStr <> '' Then
  Begin
    {$IF Defined(RESTDWLAZARUS) OR Defined(DELPHIXEUP)}
    If aUnicode Then
      Result := TRESTDWBytes(TEncoding.UTF8.GetBytes(AStr))
    Else
      Result := TRESTDWBytes(TEncoding.ANSI.GetBytes(AStr));
    {$ELSE}
    If aUnicode Then
    Begin
      SetLength(Result, Length(AStr) * 2);
      Move(Pointer(@AStr[InitStrPos])^, Pointer(Result)^, Length(AStr));
    End
    Else
    Begin
      SetLength(Result, Length(AStr) * 2);
      Move(Pointer(@AStr[InitStrPos])^, Pointer(Result)^, Length(AStr));
    End;
    {$IFEND}
  End;
End;

Function StringToBytes(AStr: String): TRESTDWBytes;
Begin
  SetLength(Result, 0);
  If AStr <> '' Then
  Begin
    {$IF Defined(RESTDWLAZARUS) OR Defined(DELPHIXEUP)}
    Result := TRESTDWBytes(TEncoding.ANSI.GetBytes(AStr));
    {$ELSE}
    SetLength(Result, Length(AStr));
    Move(Pointer(@AStr[InitStrPos])^, Pointer(Result)^, Length(AStr));
    {$IFEND}
  End;
End;

Function BytesToString(Const AValue: TRESTDWBytes; Const AStartIndex: Integer;
  Const ALength: Integer = -1): String;
Var
  LLength: Integer;
  LBytes: TRESTDWBytes;
Begin
  Result := '';
  {$IFDEF STRING_IS_ANSI}
  LBytes := Nil; // keep the compiler happy
  {$ENDIF}
  LLength := restdwLength(AValue, ALength, AStartIndex);
  If LLength > 0 Then
  Begin
    If (AStartIndex = 0) And (LLength = restdwLength(AValue)) Then
      LBytes := AValue
    Else
      LBytes := Copy(AValue, AStartIndex, LLength);
    {$IF Defined(RESTDWLAZARUS) OR not Defined(DELPHIXEUP)}
    SetString(Result, PAnsiChar(LBytes), restdwLength(LBytes));
    {$ELSEIF Defined(DELPHIXEUP)}
    SetString(Result, PAnsiChar(LBytes), restdwLength(LBytes));
    {$IFDEF MSWINDOWS}
    Result := TEncoding.ANSI.GetString(TBytes(LBytes));
    {$ELSE}
    Result := AnsiToUtf8(TEncoding.ANSI.GetString(TBytes(LBytes)));
    {$ENDIF}
    {$IFEND}
  End;
End;

Function BytesToString(Const bin: TRESTDWBytes; aUnicode: Boolean): String;
Var
  i: Integer;
  ABytes: TRESTDWBytes;
  {$IFDEF DELPHIXEUP}
  aResult: RawByteString;
  {$ENDIF}
Begin
  i := restdwLength(bin);
  If i > 0 Then
  Begin
    {$IF Defined(RESTDWLAZARUS)}
    If aUnicode Then
      SetString(Result, PChar(bin), i)
    Else
      SetString(Result, PAnsiChar(bin), i);
    {$ELSEIF not Defined(DELPHIXEUP)}
    If aUnicode Then
      SetString(Result, PWideChar(bin), i)
    Else
      SetString(Result, PAnsiChar(bin), i);
    {$ELSE}
    If aUnicode Then
    Begin
      ABytes := bin;
      SetLength(aResult, Length(bin));
      Move(ABytes[0], aResult[InitStrPos], Length(ABytes));
      Result := aResult;
    End
    Else
    Begin
      {$IFDEF RESTDWWINDOWS}
      Result := TEncoding.ANSI.GetString(TBytes(bin));
      {$ELSE}
      Result := AnsiToUtf8(TEncoding.ANSI.GetString(TBytes(bin)));
      {$ENDIF}
    End;
    {$IFEND}
  End;
End;

Function BytesToString(Const bin: TRESTDWBytes): String;
Var
  i: Integer;
Begin
  i := restdwLength(bin);
  If i > 0 Then
  Begin
    {$IF Defined(RESTDWLAZARUS) OR not Defined(DELPHIXEUP)}
    SetString(Result, PAnsiChar(bin), i);
    {$ELSE}
    SetString(Result, PAnsiChar(bin), i);
    {$IFDEF RESTDWWINDOWS}
    Result := TEncoding.ANSI.GetString(TBytes(bin));
    {$ELSE}
    Result := AnsiToUtf8(TEncoding.ANSI.GetString(TBytes(bin)));
    {$ENDIF}
    {$IFEND}
  End;
End;

Function BytesToStream(Const bin: TRESTDWBytes): TStream;
Var
  i: Integer;
Begin
  i := restdwLength(bin);
  Result := TMemoryStream.Create;
  If i > 0 Then
  Begin
    Result.Write(bin[0], i);
    Result.Position := 0;
  End;
End;

Function EncodeStream(Value: TStream): String;
{$IFNDEF RESTDWLAZARUS}
  Function EncodeBase64(AValue: TStream): String;
  Var
    StreamDecoded: TMemoryStream;
    StreamEncoded: TStringStream;
  Begin
    StreamDecoded := TMemoryStream.Create;
    StreamEncoded := TStringStream.Create('');
    Try
      StreamDecoded.CopyFrom(AValue, AValue.Size);
      StreamDecoded.Position := 0;
      EncdDecd.EncodeStream(StreamDecoded, StreamEncoded);
      Result := RemoveLineBreaks(StreamEncoded.DataString);
      // Gledston 03/12/2022
    Finally
      StreamEncoded.Free;
      StreamDecoded.Free;
    End;
  End;
{$ELSE}
  Function EncodeBase64(AValue: TStream): String;
  Var
    outstream: TStringStream;
  Begin
    outstream := TStringStream.Create('');
    Try
      outstream.CopyFrom(AValue, AValue.Size);
      outstream.Position := 0;
      Result := EncodeStrings(outstream.DataString, csUndefined);
    Finally
      FreeAndNil(outstream);
    End;
  End;
{$ENDIF}

Begin
  Result := '';
  Value.Position := 0;
  If Value.Size > 0 Then
    Result := EncodeBase64(Value);
  Value.Position := 0;
End;

Function DecodeStream(Value: String): TMemoryStream;
Var
  vRESTDWBytes: TRESTDWBytes;
Begin
  If Trim(Value) = '' Then
    Exit;
  vRESTDWBytes := Base64Decode(Value);
  Result := TMemoryStream.Create;
  Try
    Result.WriteBuffer(vRESTDWBytes[0], Length(vRESTDWBytes));
    Result.Position := 0;
  Except
  End;
End;

Function Encode64(Const S: String): String;
Var
  sa: String;
  {$IFDEF RESTDWMOBILE}
  ne: TBase64Encoding;
  {$ENDIF}
Begin
  {$IFDEF RESTDWMOBILE} // Alterado para IOS Brito
  ne := TBase64Encoding.Create(-1, '');
  Result := ne.Encode(S);
  ne.Free;
  {$ELSE}
  Result := Base64Encode(S);
  {$ENDIF}
End;

Function Decode64(const S: string): string;
Var
  sa: String;
  {$IFDEF RESTDWMOBILE}
  ne: TBase64Encoding;
  {$ENDIF}
Begin
  If (Trim(S) <> '') And (Trim(S) <> '""') Then
  Begin
    sa := S;
    If Pos(sLineBreak, sa) > 0 Then
      sa := StringReplace(sa, sLineBreak, '', [rfReplaceAll]);
    {$IFDEF RESTDWMOBILE} // Alterado para IOS Brito
    ne := TBase64Encoding.Create(-1, '');
    Try
      Result := ne.Decode(sa);
    Finally
      FreeAndNil(ne);
    End;
    {$ELSE}
    Result := BytesToString(Base64Decode(sa));
    {$ENDIF}
  End;
End;

{$IF Defined(RESTDWMOBILE)}
// Alterado para IOS Brito
Function DecodeBase64(Const Value: String): String;
{$ELSEIF (NOT Defined(RESTDWLAZARUS) AND Defined(RESTDWLINUX))}
// Alteardo para Lazarus LINUX Brito
Function DecodeBase64(Const Value: String): String;
{$ELSE}

Function DecodeBase64(Const Value: String
  {$IFDEF RESTDWLAZARUS}
  ; DatabaseCharSet: TDatabaseCharSet
  {$ENDIF}): String;
{$IFEND}
Var
  vValue: String;
Begin
  vValue := Decode64(Value);
  {$IFDEF RESTDWLAZARUS}
  Case DatabaseCharSet Of
    csWin1250:
      vValue := CP1250ToUTF8(vValue);
    csWin1251:
      vValue := CP1251ToUTF8(vValue);
    csWin1252:
      vValue := CP1252ToUTF8(vValue);
    csWin1253:
      vValue := CP1253ToUTF8(vValue);
    csWin1254:
      vValue := CP1254ToUTF8(vValue);
    csWin1255:
      vValue := CP1255ToUTF8(vValue);
    csWin1256:
      vValue := CP1256ToUTF8(vValue);
    csWin1257:
      vValue := CP1257ToUTF8(vValue);
    csWin1258:
      vValue := CP1258ToUTF8(vValue);
    csUTF8:
      vValue := UTF8ToUTF8BOM(vValue);
    csISO_8859_1:
      vValue := ISO_8859_1ToUTF8(vValue);
    csISO_8859_2:
      vValue := ISO_8859_2ToUTF8(vValue);
  End;
  {$ENDIF}
  Result := vValue;
End;

{$IF Defined(RESTDWMOBILE)}
// Alterado para IOS Brito
Function EncodeBase64(Const Value: String): String;
{$ELSEIF (NOT Defined(RESTDWLAZARUS) AND Defined(RESTDWLINUX))}
// Alterado para Lazarus LINUX Brito
Function EncodeBase64(Const Value: String): String;
{$ELSE}

Function EncodeBase64(Const Value: String
  {$IFDEF RESTDWLAZARUS}
  ; DatabaseCharSet: TDatabaseCharSet
  {$ENDIF}): String;
{$IFEND}
Var
  vValue: String;
  {$IFDEF DELPHIXE6UP}
  ne: TBase64Encoding;
  {$ENDIF}
Begin
  vValue := Value;
  {$IFDEF RESTDWLAZARUS}
  Case DatabaseCharSet Of
    csWin1250:
      vValue := CP1250ToUTF8(vValue);
    csWin1251:
      vValue := CP1251ToUTF8(vValue);
    csWin1252:
      vValue := CP1252ToUTF8(vValue);
    csWin1253:
      vValue := CP1253ToUTF8(vValue);
    csWin1254:
      vValue := CP1254ToUTF8(vValue);
    csWin1255:
      vValue := CP1255ToUTF8(vValue);
    csWin1256:
      vValue := CP1256ToUTF8(vValue);
    csWin1257:
      vValue := CP1257ToUTF8(vValue);
    csWin1258:
      vValue := CP1258ToUTF8(vValue);
    csUTF8:
      vValue := UTF8ToUTF8BOM(vValue);
    csISO_8859_1:
      vValue := ISO_8859_1ToUTF8(vValue);
    csISO_8859_2:
      vValue := ISO_8859_2ToUTF8(vValue);
  End;
  {$ENDIF}
  {$IF Defined(RESTDWLAZARUS) OR not Defined(DELPHIXE6UP)}
  Result := Base64Encode(Value);
  {$ELSE}
  ne := TBase64Encoding.Create(-1, '');
  Try
    Result := ne.Encode(Value);
  Finally
    FreeAndNil(ne);
  End;
  {$IFEND}
End;

Function EncodeStrings(Value: String
  {$IFDEF RESTDWLAZARUS}
  ; DatabaseCharSet: TDatabaseCharSet
  {$ENDIF}): String;
Begin
  Result := '';
  If Value = '' Then
    Exit;
  Result := EncodeBase64(Value{$IFDEF RESTDWLAZARUS}, DatabaseCharSet{$ENDIF});
End;

Function DecodeStrings(Value: String
  {$IFDEF RESTDWLAZARUS}
  ; DatabaseCharSet: TDatabaseCharSet
  {$ENDIF}): String;
Var
  vTempValue: String;
Begin
  Result := '';
  If Value = '' Then
    Exit;
  vTempValue := StringReplace(Value, sLineBreak, '', [rfReplaceAll]);
  Try
    {$IF Defined(RESTDWLAZARUS)}
    Result := DecodeBase64(vTempValue, DatabaseCharSet);
    {$ELSEIF Defined(RESTDWMOBILE)} // Alterado para IOS Brito
    Result := Decode64(vTempValue);
    {$ELSE}
    Result := DecodeBase64(vTempValue);
    {$IFEND}
  Except
    Result := vTempValue;
  End;
End;

Function WrapText(Const ALine, ABreakStr, ABreakChars: String;
  MaxCol: Integer): String;
Const
  QuoteChars = '"';
Var
  LCol, LPos, LLinePos, LLineLen, LBreakLen, LBreakPos: Integer;
  LQuoteChar, LCurChar: Char;
  LExistingBreak: Boolean;
Begin
  LCol := 1;
  LPos := 1;
  LLinePos := 1;
  LBreakPos := 0;
  LQuoteChar := ' ';
  LExistingBreak := False;
  LLineLen := Length(ALine);
  LBreakLen := Length(ABreakStr);
  Result := '';
  While LPos <= LLineLen Do
  Begin
    LCurChar := ALine[LPos];
    {$IFDEF STRING_IS_ANSI}
    If IsLeadChar(LCurChar) Then
    Begin
      Inc(LPos);
      Inc(LCol);
    End
    Else
    Begin
      {$ENDIF}
      If LCurChar = ABreakStr[1] Then
      Begin
        If LQuoteChar = ' ' Then
        Begin { Do not Localize }
          LExistingBreak := TextIsSame(ABreakStr, Copy(ALine, LPos, LBreakLen));
          If LExistingBreak Then
          Begin
            Inc(LPos, LBreakLen - 1);
            LBreakPos := LPos;
          End;
        End
      End
      Else
      Begin
        If CharIsInSet(LCurChar, 1, ABreakChars) Then
        Begin
          If LQuoteChar = ' ' Then
            LBreakPos := LPos;
        End
        Else
        Begin // if CurChar in BreakChars then
          If CharIsInSet(LCurChar, 1, QuoteChars) Then
          Begin
            If LCurChar = LQuoteChar Then
              LQuoteChar := ' '
            Else
            Begin
              If LQuoteChar = ' ' Then
                LQuoteChar := LCurChar;
            End;
          End;
        End;
      End;
      {$IFDEF STRING_IS_ANSI}
    End;
    {$ENDIF}
    Inc(LPos);
    Inc(LCol);
    If Not(CharIsInSet(LQuoteChar, 1, QuoteChars)) And
      (LExistingBreak Or ((LCol > MaxCol) And (LBreakPos > LLinePos))) Then
    Begin
      LCol := LPos - LBreakPos;
      Result := Result + Copy(ALine, LLinePos, LBreakPos - LLinePos + 1);
      If Not(CharIsInSet(LCurChar, 1, QuoteChars)) Then
      Begin
        While (LPos <= LLineLen) And
          (CharIsInSet(ALine, LPos, ABreakChars + #13 + #10)) Do
          Inc(LPos);
        If Not LExistingBreak And (LPos < LLineLen) Then
          Result := Result + ABreakStr;
      End;
      Inc(LBreakPos);
      LLinePos := LBreakPos;
      LExistingBreak := False;
    End;
  End;
  Result := Result + Copy(ALine, LLinePos, MaxInt);
End;

Function EncryptSHA256(Key, Text: TRESTDWString; Encrypt: Boolean): String;
Var
  Cipher: TRESTDWDCP_rijndael;
Begin
  Result := '';
  Cipher := TRESTDWDCP_rijndael.Create(Nil);
  Try
    Cipher.InitStr(Key, TRESTDWDCP_sha256);
    If Encrypt Then
      Result := Cipher.EncryptString(Text)
    Else
      Result := Cipher.DecryptString(Text);
  Finally
    Cipher.Burn;
    Cipher.Free;
  End;
End;

Function iif(ATest: Boolean; Const ATrue: String; Const AFalse: String): String;
{$IFDEF USE_INLINE}Inline; {$ENDIF}
Begin
  If ATest Then
    Result := ATrue
  Else
    Result := AFalse;
End;

Function iif(ATest: Boolean; Const ATrue: Boolean; Const AFalse: Boolean)
  : Boolean; {$IFDEF USE_INLINE}Inline; {$ENDIF}
Begin
  If ATest Then
    Result := ATrue
  Else
    Result := AFalse;
End;

Function RequestTypeToString(RequestType: TRequestType): String;
Begin
  Result := '';
  case RequestType Of
    rtGet:
      Result := 'GET';
    rtPost:
      Result := 'POST';
    rtPut:
      Result := 'PUT';
    rtPatch:
      Result := 'PATCH';
    rtDelete:
      Result := 'DELETE';
  End;
End;

Function StrDWLength(Value: String): Integer;
Begin
  Result := Length(Value);
End;

Procedure DeleteStr(Var Value: String; InitPos, FinalPos: Integer);
Begin
  Delete(Value, InitPos, FinalPos);
End;

Function RequestTypeToRoute(RequestType: TRequestType): TRESTDWRoute;
Begin
  Result := crAll;
  Case RequestType Of
    rtGet:
      Result := crGet;
    rtPost:
      Result := crPost;
    rtPut:
      Result := crPut;
    rtPatch:
      Result := crPatch;
    rtDelete:
      Result := crDelete;
    rtOption:
      Result := crOption;
  End;
End;

Function SystemProtectFiles(sFile: String): Boolean;
Const
  cProtectFiles: array [0 .. 1] of string = ('\winnt\', '\windows\');
Var
  i: Integer;
Begin
  Result := False;
  For i := 0 to Length(cProtectFiles) - 1 Do
  Begin
    Result := Pos(cProtectFiles[i], Lowercase(sFile)) > 0;
    If Result Then
      Break;
  End;
End;

Function Scripttags(Value: String): Boolean;
var
  i: Integer;
Begin
  Result := False;
  For i := 0 To Length(tScriptsDetected) - 1 Do
  Begin
    Result := Pos(tScriptsDetected[i], Value) > 0;
    If Result Then
      Break;
  End;
End;

Function DateTimeToUnix(ConvDate: TDateTime;
  AInputIsUTC: Boolean = True): Int64;
begin
  Result := DateUtils.DateTimeToUnix(ConvDate, AInputIsUTC);
end;

Function UnixToDateTime(USec: Int64; AInputIsUTC: Boolean = True): TDateTime;
begin
  Result := DateUtils.UnixToDateTime(USec, AInputIsUTC);
end;

Function MassiveModeToString(MassiveMode: TMassiveMode): String;
Begin
  Case MassiveMode Of
    mmInactive:
      Result := 'mmInactive';
    mmBrowse:
      Result := 'mmBrowse';
    mmInsert:
      Result := 'mmInsert';
    mmUpdate:
      Result := 'mmUpdate';
    mmDelete:
      Result := 'mmDelete';
    mmExec:
      Result := 'mmExec';
  End;
End;

Function StringToMassiveMode(Value: String): TMassiveMode;
Begin
  Result := mmInactive;
  If Lowercase(Value) = Lowercase('mmBrowse') Then
    Result := mmBrowse
  Else If Lowercase(Value) = Lowercase('mmInsert') Then
    Result := mmInsert
  Else If Lowercase(Value) = Lowercase('mmUpdate') Then
    Result := mmUpdate
  Else If Lowercase(Value) = Lowercase('mmDelete') Then
    Result := mmDelete
  Else If Lowercase(Value) = Lowercase('mmExec') Then
    Result := mmExec;
End;

Function DatasetStateToMassiveType(DatasetState: TDatasetState): TMassiveMode;
Begin
  Result := mmInactive;
  Case DatasetState Of
    dsInactive:
      Result := mmInactive;
    dsBrowse:
      Result := mmBrowse;
    dsInsert:
      Result := mmInsert;
    dsEdit:
      Result := mmUpdate;
  End;
End;

Procedure LimpaLixoHex(Var Value: String);
Begin
  If Length(Value) > 0 Then
  Begin
    If Value[1] = '{' Then
      Delete(Value, 1, 1);
  End;
  If Length(Value) > 0 Then
  Begin
    If Value[1] = #13 Then
      Delete(Value, 1, 1);
  End;
  If Length(Value) > 0 Then
  Begin
    If Value[1] = '"' Then
      Delete(Value, 1, 1);
  End;
  If Length(Value) > 0 Then
  Begin
    If Value[1] = 'L' Then
      Delete(Value, 1, 1);
  End;
  If Length(Value) > 0 Then
  Begin
    If Value[Length(Value)] = '"' Then
      Delete(Value, Length(Value), 1);
  End;
End;

Procedure HexToPChar(HexString: String; Var Data: PChar);
Var
  {$IFDEF RESTDWFMX} // Android}
  bytes: TBytes;
  {$ENDIF}
  Stream: TMemoryStream;
Begin
  LimpaLixoHex(HexString);
  Stream := TMemoryStream.Create;
  Try
    {$IF Defined(RESTDWFMX)} // Alteardo para IOS Brito
    SetLength(bytes, Length(HexString) div 2);
    HexToBin(PChar(HexString), 0, bytes, 0, Length(bytes));
    Stream.WriteBuffer(bytes[0], Length(bytes));
    {$ELSEIF Defined(RESTDWLAZARUS) OR not Defined(DELPHIXEUP)}
    HexToBin(PChar(HexString), TMemoryStream(Stream).Memory,
      TMemoryStream(Stream).Size);
    {$ELSE}
    TMemoryStream(Stream).Size := Length(HexString) Div 2;
    HexToBin(PWideChar(HexString), TMemoryStream(Stream).Memory,
      TMemoryStream(Stream).Size);
    {$IFEND}
    Stream.Position := 0;
  Finally
    Stream.Read(Data, Stream.Size);
    FreeAndNil(Stream);
  End;
End;

Procedure HexToStream(Str: String; Stream: TStream);
{$IFDEF RESTDWFMX} // Android}
var
  bytes: TBytes;
  {$ENDIF}
Begin
  LimpaLixoHex(Str);
  {$IF Defined(RESTDWFMX)}
  SetLength(bytes, Length(Str) div 2);
  HexToBin(PChar(Str), 0, bytes, 0, Length(bytes));
  Stream.WriteBuffer(bytes[0], Length(bytes));
  {$ELSEIF Defined(RESTDWLAZARUS) OR not Defined(DELPHIXEUP)}
  HexToBin(PChar(Str), TMemoryStream(Stream).Memory,
    TMemoryStream(Stream).Size);
  {$ELSE}
  TMemoryStream(Stream).Size := Length(Str) Div 2;
  HexToBin(PWideChar(Str), TMemoryStream(Stream).Memory,
    TMemoryStream(Stream).Size);
  {$IFEND}
  Stream.Position := 0;
End;

{$IFDEF RESTDWFMX}

function abbintohexstring(Stream: TStream): string;
var
  S: TStream;
  i: Integer;
  b: Byte;
  hex: String;
begin
  S := Stream;
  try
    S.Seek(Int64(0), Word(soFromBeginning));
    for i := 1 to S.Size do
    begin
      S.Read(b, 1);
      hex := IntToHex(b, 2);
      // .....
      Result := Result + hex;
    end;
  finally
    S.Free;
  end;
end;
{$ENDIF}

Function PCharToHex(Data: PChar; Size: Integer;
  QQuoted: Boolean = True): String;
Var
  Stream: TMemoryStream;
Begin
  Stream := TMemoryStream.Create;
  Try
    Stream.Write(Data, Size);
    Stream.Position := 0;
    {$IF Defined(RESTDWFMX)}
    Result := abbintohexstring(Stream);
    {$ELSE}
    SetLength(Result, Stream.Size * 2);
    BinToHex(TMemoryStream(Stream).Memory, PChar(Result), Stream.Size);
    {$IFEND}
  Finally
    FreeAndNil(Stream);
    If QQuoted Then
      Result := '"' + Result + '"';
  End;
End;

Function StreamToHex(Stream: TStream; QQuoted: Boolean = True): String;
Begin
  Stream.Position := 0;
  {$IF Defined(RESTDWFMX)}
  Result := abbintohexstring(Stream);
  {$ELSE}
  SetLength(Result, Stream.Size * 2);
  BinToHex(TMemoryStream(Stream).Memory, PChar(Result), Stream.Size);
  {$IFEND}
  If QQuoted Then
    Result := '"' + Result + '"';
End;

Function FileToStr(Const FileName: String): string;
Var
  Stream: TFileStream;
Begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  Try
    SetLength(Result, Stream.Size);
    Stream.Position := 0;
    Stream.ReadBuffer(Pointer(Result)^, Stream.Size);
  Finally
    Stream.Free;
  End;
End;

Procedure StrToFile(Const FileName, SourceString: string);
Var
  Stream: TFileStream;
Begin
  If FileExists(FileName) Then
    DeleteFile(FileName);
  Stream := TFileStream.Create(FileName, fmCreate);
  Try
    Stream.WriteBuffer(Pointer(SourceString)^, Length(SourceString));
  Finally
    Stream.Free;
  End;
End;

Procedure CopyStream(Const Source: TStream; Dest: TStream);
Var
  BytesRead: Integer;
  Buffer: PByte;
Const
  MaxBufSize = $F000;
Begin
  { ** Criando a instância do objeto TMemoryStream para retorno do método ** }
  Dest := TMemoryStream.Create;
  { ** Reposicionando o stream para o seu início ** }
  Source.Seek(0, soBeginning);
  Source.Position := 0;
  GetMem(Buffer, MaxBufSize);
  { ** Realizando a leitura do stream original, buffer a buffer ** }
  Repeat
    BytesRead := Source.Read(Buffer^, MaxBufSize);
    If BytesRead > 0 then
      Dest.WriteBuffer(Buffer^, BytesRead);
  Until MaxBufSize > BytesRead;
  { ** Reposicionando o stream de retorno para o seu início ** }
  Dest.Seek(0, soBeginning);
End;

Function GenerateStringFromStream(Stream: TStream{$IFDEF DELPHIXEUP};
  AEncoding: TEncoding{$ENDIF}): String;
Var
  StringStream: TStringStream;
Begin
  StringStream := TStringStream.Create(''{$IFDEF DELPHIXEUP},
    AEncoding{$ENDIF});
  Try
    Stream.Position := 0;
    StringStream.CopyFrom(Stream, Stream.Size);
    Result := StringStream.DataString;
  Finally
    {$IFDEF DELPHIXEUP}StringStream.Clear; {$ENDIF}
    StringStream.Free;
  End;
End;

Function StringFloat(AValue: String): String;
Begin
  Result := StringReplace(AValue, '.', '', [rfReplaceAll]);
End;

Function GetStringFromBoolean(Value: Boolean): String;
Begin
  Result := 'false';
  If Value Then
    Result := 'true';
End;

Function GetObjectName(TypeObject: TTypeObject): String;
Begin
  Result := 'toObject';
  Case TypeObject Of
    toDataset:
      Result := 'toDataset';
    toParam:
      Result := 'toParam';
    toVariable:
      Result := 'toVariable';
    toObject:
      Result := 'toObject';
    toMassive:
      Result := 'toMassive';
  End;
End;

Function GetDataModeName(TypeObject: TDataMode): String;
Begin
  Result := 'dmDataware';
  Case TypeObject Of
    dmDataware:
      Result := 'dmDataware';
    dmRAW:
      Result := 'dmRAW';
    // jmUndefined : Result := 'jmUndefined';
  Else
    Result := 'dmDataware';
  End;
End;

Function FieldTypeToObjectValue(FieldType: TFieldType): TObjectValue;
Begin
  Result := ovUnknown;
  Case FieldType Of
    ftString:
      Result := ovString;
    ftSmallint:
      Result := ovSmallint;
    ftInteger:
      Result := ovInteger;
    ftWord:
      Result := ovWord;
    ftBoolean:
      Result := ovBoolean;
    ftFloat:
      Result := ovFloat;
    ftCurrency:
      Result := ovCurrency;
    ftBCD:
      Result := ovBCD;
    ftDate:
      Result := ovDate;
    ftTime:
      Result := ovTime;
    ftDateTime:
      Result := ovDateTime;
    ftBytes:
      Result := ovBytes;
    ftVarBytes:
      Result := ovVarBytes;
    ftAutoInc:
      Result := ovAutoInc;
    ftBlob:
      Result := ovBlob;
    ftMemo:
      Result := ovMemo;
    ftGraphic:
      Result := ovGraphic;
    ftFmtMemo:
      Result := ovFmtMemo;
    ftParadoxOle:
      Result := ovParadoxOle;
    ftDBaseOle:
      Result := ovDBaseOle;
    ftTypedBinary:
      Result := ovTypedBinary;
    ftCursor:
      Result := ovCursor;
    ftFixedChar:
      Result := ovFixedChar;
    ftWideString:
      Result := ovWideString;
    ftLargeint:
      Result := ovLargeint;
    ftADT:
      Result := ovADT;
    ftArray:
      Result := ovArray;
    ftReference:
      Result := ovReference;
    ftDataSet:
      Result := ovDataSet;
    ftOraBlob:
      Result := ovOraBlob;
    ftOraClob:
      Result := ovOraClob;
    ftVariant:
      Result := ovVariant;
    ftInterface:
      Result := ovInterface;
    ftIDispatch:
      Result := ovIDispatch;
    ftGuid:
      Result := ovGuid;
    ftTimeStamp:
      Result := ovTimeStamp;
    ftFMTBcd:
      Result := ovFMTBcd;
    {$IFDEF DELPHIXEUP}
    ftFixedWideChar:
      Result := ovFixedWideChar;
    ftWideMemo:
      Result := ovWideMemo;
    ftOraTimeStamp:
      Result := ovOraTimeStamp;
    ftOraInterval:
      Result := ovOraInterval;
    ftLongWord:
      Result := ovLongWord;
    ftShortint:
      Result := ovShortint;
    ftByte:
      Result := ovByte;
    ftExtended:
      Result := ovExtended;
    ftConnection:
      Result := ovConnection;
    ftParams:
      Result := ovParams;
    ftStream:
      Result := ovStream;
    ftTimeStampOffset:
      Result := ovTimeStampOffset;
    ftObject:
      Result := ovObject;
    ftSingle:
      Result := ovSingle;
    {$ENDIF}
  End;
End;

Function ObjectValueToFieldType(TypeObject: TObjectValue): TFieldType;
Begin
  Result := ftUnknown;
  Case TypeObject Of
    ovString:
      Result := ftString;
    ovSmallint:
      Result := ftSmallint;
    ovInteger:
      Result := ftInteger;
    ovWord:
      Result := ftWord;
    ovBoolean:
      Result := ftBoolean;
    ovFloat:
      Result := ftFloat;
    ovCurrency:
      Result := ftCurrency;
    ovBCD:
      Result := ftBCD;
    ovDate:
      Result := ftDate;
    ovTime:
      Result := ftTime;
    ovDateTime:
      Result := ftDateTime;
    ovBytes:
      Result := ftBytes;
    ovVarBytes:
      Result := ftVarBytes;
    ovAutoInc:
      Result := ftAutoInc;
    ovBlob:
      Result := ftBlob;
    ovMemo:
      Result := ftMemo;
    ovGraphic:
      Result := ftGraphic;
    ovFmtMemo:
      Result := ftFmtMemo;
    ovParadoxOle:
      Result := ftParadoxOle;
    ovDBaseOle:
      Result := ftDBaseOle;
    ovTypedBinary:
      Result := ftTypedBinary;
    ovCursor:
      Result := ftCursor;
    ovFixedChar:
      Result := ftFixedChar;
    ovWideString:
      Result := ftWideString;
    ovLargeint:
      Result := ftLargeint;
    ovADT:
      Result := ftADT;
    ovArray:
      Result := ftArray;
    ovReference:
      Result := ftReference;
    ovDataSet:
      Result := ftDataSet;
    ovOraBlob:
      Result := ftOraBlob;
    ovOraClob:
      Result := ftOraClob;
    ovVariant:
      Result := ftVariant;
    ovInterface:
      Result := ftInterface;
    ovIDispatch:
      Result := ftIDispatch;
    ovGuid:
      Result := ftGuid;
    ovTimeStamp:
      Result := ftTimeStamp;
    ovFMTBcd:
      Result := ftFMTBcd;
    {$IFDEF DELPHIXEUP}
    ovFixedWideChar:
      Result := ftFixedWideChar;
    ovWideMemo:
      Result := ftWideMemo;
    ovOraTimeStamp:
      Result := ftOraTimeStamp;
    ovOraInterval:
      Result := ftOraInterval;
    ovLongWord:
      Result := ftLongWord;
    ovShortint:
      Result := ftShortint;
    ovByte:
      Result := ftByte;
    ovExtended:
      Result := ftExtended;
    ovConnection:
      Result := ftConnection;
    ovParams:
      Result := ftParams;
    ovStream:
      Result := ftStream;
    ovTimeStampOffset:
      Result := ftTimeStampOffset;
    ovObject:
      Result := ftObject;
    ovSingle:
      Result := ftSingle;
    {$ENDIF}
  End;
End;

Function GetObjectName(TypeObject: String): TTypeObject;
Var
  vTypeObject: String;
Begin
  Result := toObject;
  vTypeObject := UpperCase(TypeObject);
  If vTypeObject = UpperCase('toObject') Then
    Result := toObject
  Else If vTypeObject = UpperCase('toDataset') Then
    Result := toDataset
  Else If vTypeObject = UpperCase('toParam') Then
    Result := toParam
  Else If vTypeObject = UpperCase('toVariable') Then
    Result := toVariable
  Else If vTypeObject = UpperCase('toMassive') Then
    Result := toMassive;
End;

Function GetDataModeName(TypeObject: String): TDataMode;
Var
  vTypeObject: String;
Begin
  Result := dmDataware;
  vTypeObject := UpperCase(TypeObject);
  If vTypeObject = UpperCase('dmDataware') Then
    Result := dmDataware
  Else If vTypeObject = UpperCase('dmRAW') Then
    Result := dmRAW;
End;

Function GetDirectionName(ObjectDirection: TObjectDirection): String;
Begin
  Result := 'odINOUT';
  Case ObjectDirection Of
    odINOUT:
      Result := 'odINOUT';
    odIN:
      Result := 'odIN';
    odOUT:
      Result := 'odOUT';
  End;
End;

Function GetBooleanFromString(Value: String): Boolean;
Begin
  Result := UpperCase(Value) = 'TRUE';
End;

Function GetDirectionName(ObjectDirection: String): TObjectDirection;
Var
  vObjectDirection: String;
Begin
  Result := odOUT;
  vObjectDirection := UpperCase(ObjectDirection);
  If vObjectDirection = UpperCase('odINOUT') Then
    Result := odINOUT
  Else If vObjectDirection = UpperCase('odIN') Then
    Result := odIN;
  {
    Else If vObjectDirection = Uppercase('odOUT') Then
    Result := odOUT;
  }
End;

Function GetValueType(ObjectValue: TObjectValue): String;
Begin
  Result := 'ovUnknown';
  Case ObjectValue Of
    ovUnknown:
      Result := 'ovUnknown';
    ovString:
      Result := 'ovString';
    ovSmallint:
      Result := 'ovSmallint';
    ovInteger:
      Result := 'ovInteger';
    ovWord:
      Result := 'ovWord';
    ovBoolean:
      Result := 'ovBoolean';
    ovFloat:
      Result := 'ovFloat';
    ovCurrency:
      Result := 'ovCurrency';
    ovBCD:
      Result := 'ovBCD';
    ovDate:
      Result := 'ovDate';
    ovTime:
      Result := 'ovTime';
    ovDateTime:
      Result := 'ovDateTime';
    ovBytes:
      Result := 'ovBytes';
    ovVarBytes:
      Result := 'ovVarBytes';
    ovAutoInc:
      Result := 'ovAutoInc';
    ovBlob:
      Result := 'ovBlob';
    ovMemo:
      Result := 'ovMemo';
    ovGraphic:
      Result := 'ovGraphic';
    ovFmtMemo:
      Result := 'ovFmtMemo';
    ovParadoxOle:
      Result := 'ovParadoxOle';
    ovDBaseOle:
      Result := 'ovDBaseOle';
    ovTypedBinary:
      Result := 'ovTypedBinary';
    ovCursor:
      Result := 'ovCursor';
    ovFixedChar:
      Result := 'ovFixedChar';
    ovWideString:
      Result := 'ovWideString';
    ovLargeint:
      Result := 'ovLargeint';
    ovADT:
      Result := 'ovADT';
    ovArray:
      Result := 'ovArray';
    ovReference:
      Result := 'ovReference';
    ovDataSet:
      Result := 'ovDataSet';
    ovOraBlob:
      Result := 'ovOraBlob';
    ovOraClob:
      Result := 'ovOraClob';
    ovVariant:
      Result := 'ovVariant';
    ovInterface:
      Result := 'ovInterface';
    ovIDispatch:
      Result := 'ovIDispatch';
    ovGuid:
      Result := 'ovGuid';
    ovTimeStamp:
      Result := 'ovTimeStamp';
    ovFMTBcd:
      Result := 'ovFMTBcd';
    ovFixedWideChar:
      Result := 'ovFixedWideChar';
    ovWideMemo:
      Result := 'ovWideMemo';
    ovOraTimeStamp:
      Result := 'ovOraTimeStamp';
    ovOraInterval:
      Result := 'ovOraInterval';
    ovLongWord:
      Result := 'ovLongWord';
    ovShortint:
      Result := 'ovShortint';
    ovByte:
      Result := 'ovByte';
    ovExtended:
      Result := 'ovExtended';
    ovConnection:
      Result := 'ovConnection';
    ovParams:
      Result := 'ovParams';
    ovStream:
      Result := 'ovStream';
    ovTimeStampOffset:
      Result := 'ovTimeStampOffset';
    ovObject:
      Result := 'ovObject';
    ovSingle:
      Result := 'ovSingle';
  End;
End;

Function GetValueType(ObjectValue: String): TObjectValue;
Var
  vObjectValue: String;
Begin
  Result := ovSingle;
  vObjectValue := UpperCase(ObjectValue);
  If vObjectValue = UpperCase('ovUnknown') Then
    Result := ovUnknown
  Else If vObjectValue = UpperCase('ovString') Then
    Result := ovString
  Else If vObjectValue = UpperCase('ovSmallint') Then
    Result := ovSmallint
  Else If vObjectValue = UpperCase('ovInteger') Then
    Result := ovInteger
  Else If vObjectValue = UpperCase('ovWord') Then
    Result := ovWord
  Else If vObjectValue = UpperCase('ovBoolean') Then
    Result := ovBoolean
  Else If vObjectValue = UpperCase('ovFloat') Then
    Result := ovFloat
  Else If vObjectValue = UpperCase('ovCurrency') Then
    Result := ovCurrency
  Else If vObjectValue = UpperCase('ovBCD') Then
    Result := ovBCD
  Else If vObjectValue = UpperCase('ovDate') Then
    Result := ovDate
  Else If vObjectValue = UpperCase('ovTime') Then
    Result := ovTime
  Else If vObjectValue = UpperCase('ovDateTime') Then
    Result := ovDateTime
  Else If vObjectValue = UpperCase('ovBytes') Then
    Result := ovBytes
  Else If vObjectValue = UpperCase('ovVarBytes') Then
    Result := ovVarBytes
  Else If vObjectValue = UpperCase('ovAutoInc') Then
    Result := ovAutoInc
  Else If vObjectValue = UpperCase('ovBlob') Then
    Result := ovBlob
  Else If vObjectValue = UpperCase('ovMemo') Then
    Result := ovMemo
  Else If vObjectValue = UpperCase('ovGraphic') Then
    Result := ovGraphic
  Else If vObjectValue = UpperCase('ovFmtMemo') Then
    Result := ovFmtMemo
  Else If vObjectValue = UpperCase('ovParadoxOle') Then
    Result := ovParadoxOle
  Else If vObjectValue = UpperCase('ovDBaseOle') Then
    Result := ovDBaseOle
  Else If vObjectValue = UpperCase('ovTypedBinary') Then
    Result := ovTypedBinary
  Else If vObjectValue = UpperCase('ovCursor') Then
    Result := ovCursor
  Else If vObjectValue = UpperCase('ovFixedChar') Then
    Result := ovFixedChar
  Else If vObjectValue = UpperCase('ovWideString') Then
    Result := ovWideString
  Else If vObjectValue = UpperCase('ovLargeint') Then
    Result := ovLargeint
  Else If vObjectValue = UpperCase('ovADT') Then
    Result := ovADT
  Else If vObjectValue = UpperCase('ovArray') Then
    Result := ovArray
  Else If vObjectValue = UpperCase('ovReference') Then
    Result := ovReference
  Else If vObjectValue = UpperCase('ovDataSet') Then
    Result := ovDataSet
  Else If vObjectValue = UpperCase('ovOraBlob') Then
    Result := ovOraBlob
  Else If vObjectValue = UpperCase('ovOraClob') Then
    Result := ovOraClob
  Else If vObjectValue = UpperCase('ovVariant') Then
    Result := ovVariant
  Else If vObjectValue = UpperCase('ovInterface') Then
    Result := ovInterface
  Else If vObjectValue = UpperCase('ovIDispatch') Then
    Result := ovIDispatch
  Else If vObjectValue = UpperCase('ovGuid') Then
    Result := ovGuid
  Else If vObjectValue = UpperCase('ovTimeStamp') Then
    Result := ovTimeStamp
  Else If vObjectValue = UpperCase('ovFMTBcd') Then
    Result := ovFMTBcd
  Else If vObjectValue = UpperCase('ovFixedWideChar') Then
    Result := ovFixedWideChar
  Else If vObjectValue = UpperCase('ovWideMemo') Then
    Result := ovWideMemo
  Else If vObjectValue = UpperCase('ovOraTimeStamp') Then
    Result := ovOraTimeStamp
  Else If vObjectValue = UpperCase('ovOraInterval') Then
    Result := ovOraInterval
  Else If vObjectValue = UpperCase('ovLongWord') Then
    Result := ovLongWord
  Else If vObjectValue = UpperCase('ovShortint') Then
    Result := ovShortint
  Else If vObjectValue = UpperCase('ovByte') Then
    Result := ovByte
  Else If vObjectValue = UpperCase('ovExtended') Then
    Result := ovExtended
  Else If vObjectValue = UpperCase('ovConnection') Then
    Result := ovConnection
  Else If vObjectValue = UpperCase('ovParams') Then
    Result := ovParams
  Else If vObjectValue = UpperCase('ovStream') Then
    Result := ovStream
  Else If vObjectValue = UpperCase('ovTimeStampOffset') Then
    Result := ovTimeStampOffset
  Else If vObjectValue = UpperCase('ovObject') Then
    Result := ovObject
  Else If vObjectValue = UpperCase('ovSingle') Then
    Result := ovSingle;
End;

Function GetValueTypeTranslator(ObjectValue: String): TObjectValue;
Var
  vObjectValue: String;
Begin
  Result := ovString;
  vObjectValue := UpperCase(ObjectValue);
  If vObjectValue = UpperCase('_Unknown') Then
    Result := ovUnknown
  Else If vObjectValue = UpperCase('_String') Then
    Result := ovString
  Else If vObjectValue = UpperCase('_Smallint') Then
    Result := ovSmallint
  Else If vObjectValue = UpperCase('_Integer') Then
    Result := ovInteger
  Else If vObjectValue = UpperCase('_Word') Then
    Result := ovWord
  Else If vObjectValue = UpperCase('_Boolean') Then
    Result := ovBoolean
  Else If vObjectValue = UpperCase('_Float') Then
    Result := ovFloat
  Else If vObjectValue = UpperCase('_Currency') Then
    Result := ovCurrency
  Else If vObjectValue = UpperCase('_BCD') Then
    Result := ovBCD
  Else If vObjectValue = UpperCase('_Date') Then
    Result := ovDate
  Else If vObjectValue = UpperCase('_Time') Then
    Result := ovTime
  Else If vObjectValue = UpperCase('_DateTime') Then
    Result := ovDateTime
  Else If vObjectValue = UpperCase('_Bytes') Then
    Result := ovBytes
  Else If vObjectValue = UpperCase('_VarBytes') Then
    Result := ovVarBytes
  Else If vObjectValue = UpperCase('_AutoInc') Then
    Result := ovAutoInc
  Else If vObjectValue = UpperCase('_Blob') Then
    Result := ovBlob
  Else If vObjectValue = UpperCase('_Memo') Then
    Result := ovMemo
  Else If vObjectValue = UpperCase('_Graphic') Then
    Result := ovGraphic
  Else If vObjectValue = UpperCase('_FmtMemo') Then
    Result := ovFmtMemo
  Else If vObjectValue = UpperCase('_ParadoxOle') Then
    Result := ovParadoxOle
  Else If vObjectValue = UpperCase('_DBaseOle') Then
    Result := ovDBaseOle
  Else If vObjectValue = UpperCase('_TypedBinary') Then
    Result := ovTypedBinary
  Else If vObjectValue = UpperCase('_Cursor') Then
    Result := ovCursor
  Else If vObjectValue = UpperCase('_FixedChar') Then
    Result := ovFixedChar
  Else If vObjectValue = UpperCase('_WideString') Then
    Result := ovWideString
  Else If vObjectValue = UpperCase('_Largeint') Then
    Result := ovLargeint
  Else If vObjectValue = UpperCase('_ADT') Then
    Result := ovADT
  Else If vObjectValue = UpperCase('-Array') Then
    Result := ovArray
  Else If vObjectValue = UpperCase('_Reference') Then
    Result := ovReference
  Else If vObjectValue = UpperCase('_DataSet') Then
    Result := ovDataSet
  Else If vObjectValue = UpperCase('-OraBlob') Then
    Result := ovOraBlob
  Else If vObjectValue = UpperCase('_OraClob') Then
    Result := ovOraClob
  Else If vObjectValue = UpperCase('_Variant') Then
    Result := ovVariant
  Else If vObjectValue = UpperCase('_Interface') Then
    Result := ovInterface
  Else If vObjectValue = UpperCase('_IDispatch') Then
    Result := ovIDispatch
  Else If vObjectValue = UpperCase('_Guid') Then
    Result := ovGuid
  Else If vObjectValue = UpperCase('_TimeStamp') Then
    Result := ovTimeStamp
  Else If vObjectValue = UpperCase('_FMTBcd') Then
    Result := ovFMTBcd
  Else If vObjectValue = UpperCase('_FixedWideChar') Then
    Result := ovFixedWideChar
  Else If vObjectValue = UpperCase('_WideMemo') Then
    Result := ovWideMemo
  Else If vObjectValue = UpperCase('_OraTimeStamp') Then
    Result := ovOraTimeStamp
  Else If vObjectValue = UpperCase('_OraInterval') Then
    Result := ovOraInterval
  Else If vObjectValue = UpperCase('_LongWord') Then
    Result := ovLongWord
  Else If vObjectValue = UpperCase('_Shortint') Then
    Result := ovShortint
  Else If vObjectValue = UpperCase('_Byte') Then
    Result := ovByte
  Else If vObjectValue = UpperCase('_Extended') Then
    Result := ovExtended
  Else If vObjectValue = UpperCase('_Connection') Then
    Result := ovConnection
  Else If vObjectValue = UpperCase('_Params') Then
    Result := ovParams
  Else If vObjectValue = UpperCase('_Stream') Then
    Result := ovStream
  Else If vObjectValue = UpperCase('_TimeStampOffset') Then
    Result := ovTimeStampOffset
  Else If vObjectValue = UpperCase('-Object') Then
    Result := ovObject
  Else If vObjectValue = UpperCase('_Single') Then
    Result := ovSingle;
End;

Function FieldTypeToStr(FieldType: TFieldType): String;
Begin
  Result := GetFieldType(FieldType);
End;

Function GetFieldType(FieldType: TFieldType): String;
Begin
  Result := 'ftUnknown';
  Case FieldType Of
    ftUnknown:
      Result := 'ftUnknown';
    ftString:
      Result := 'ftString';
    ftSmallint:
      Result := 'ftSmallint';
    ftInteger:
      Result := 'ftInteger';
    ftWord:
      Result := 'ftWord';
    ftBoolean:
      Result := 'ftBoolean';
    ftFloat:
      Result := 'ftFloat';
    ftCurrency:
      Result := 'ftCurrency';
    ftBCD:
      Result := 'ftBCD';
    ftDate:
      Result := 'ftDate';
    ftTime:
      Result := 'ftTime';
    ftDateTime:
      Result := 'ftDateTime';
    ftBytes:
      Result := 'ftBytes';
    ftVarBytes:
      Result := 'ftVarBytes';
    ftAutoInc:
      Result := 'ftAutoInc';
    ftBlob:
      Result := 'ftBlob';
    ftMemo:
      Result := 'ftMemo';
    ftGraphic:
      Result := 'ftGraphic';
    ftFmtMemo:
      Result := 'ftFmtMemo';
    ftParadoxOle:
      Result := 'ftParadoxOle';
    ftDBaseOle:
      Result := 'ftDBaseOle';
    ftTypedBinary:
      Result := 'ftTypedBinary';
    ftCursor:
      Result := 'ftCursor';
    {$IF Defined(RESTDWLAZARUS) OR not Defined(DELPHIXEUP)}
    ftFixedChar:
      Result := 'ftString';
    {$ELSE}
    ftFixedChar:
      Result := 'ftFixedChar';
    {$IFEND}
    ftWideString:
      Result := 'ftString';
    ftLargeint:
      Result := 'ftLargeint';
    ftADT:
      Result := 'ftADT';
    ftArray:
      Result := 'ftArray';
    ftReference:
      Result := 'ftReference';
    ftDataSet:
      Result := 'ftDataSet';
    ftOraBlob:
      Result := 'ftOraBlob';
    ftOraClob:
      Result := 'ftOraClob';
    ftVariant:
      Result := 'ftVariant';
    ftInterface:
      Result := 'ftInterface';
    ftIDispatch:
      Result := 'ftIDispatch';
    ftGuid:
      Result := 'ftGuid';
    ftTimeStamp:
      Result := 'ftTimeStamp';
    ftFMTBcd:
      Result := 'ftFMTBcd';
    {$IFDEF RESTDWLAZARUS}
    ftWideMemo:
      Result := 'ftWideMemo';
    ftFixedWideChar:
      Result := 'ftFixedWideChar';
    {$ENDIF}
    {$IFDEF DELPHIXEUP}
    ftSingle:
      Result := 'ftSingle';
    ftWideMemo:
      Result := 'ftWideMemo';
    ftFixedWideChar:
      Result := 'ftFixedWideChar';
    ftOraTimeStamp:
      Result := 'ftOraTimeStamp';
    ftOraInterval:
      Result := 'ftOraInterval';
    ftLongWord:
      Result := 'ftLongWord';
    ftShortint:
      Result := 'ftShortint';
    ftExtended:
      Result := 'ftFloat';
    ftByte:
      Result := 'ftByte';
    ftConnection:
      Result := 'ftConnection';
    ftParams:
      Result := 'ftParams';
    ftStream:
      Result := 'ftBlob';
    ftTimeStampOffset:
      Result := 'ftTimeStamp';
    ftObject:
      Result := 'ftObject';
    {$ENDIF}
  End;
End;

Function GetFieldType(FieldType: String): TFieldType;
Var
  vFieldType: String;
Begin
  Result := ftString;
  vFieldType := UpperCase(FieldType);
  If vFieldType = UpperCase('ftUnknown') Then
    Result := ftUnknown
  Else If vFieldType = UpperCase('ftString') Then
    Result := ftString
  Else If vFieldType = UpperCase('ftSmallint') Then
    Result := ftSmallint
  Else If vFieldType = UpperCase('ftInteger') Then
    Result := ftInteger
  Else If vFieldType = UpperCase('ftWord') Then
    Result := ftWord
  Else If vFieldType = UpperCase('ftBoolean') Then
    Result := ftBoolean
  Else If vFieldType = UpperCase('ftFloat') Then
    Result := ftFloat
  Else If vFieldType = UpperCase('ftCurrency') Then
    Result := ftCurrency
  Else If vFieldType = UpperCase('ftBCD') Then
    Result := ftFMTBcd
  Else If vFieldType = UpperCase('ftDate') Then
    Result := ftDate
  Else If vFieldType = UpperCase('ftTime') Then
    Result := ftTime
  Else If vFieldType = UpperCase('ftDateTime') Then
    Result := ftDateTime
  Else If vFieldType = UpperCase('ftBytes') Then
    Result := ftBytes
  Else If vFieldType = UpperCase('ftVarBytes') Then
    Result := ftVarBytes
  Else If vFieldType = UpperCase('ftAutoInc') Then
    Result := ftAutoInc
  Else If vFieldType = UpperCase('ftBlob') Then
    Result := ftBlob
  Else If vFieldType = UpperCase('ftMemo') Then
    Result := ftMemo
    {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHIXEUP)}
  Else If vFieldType = UpperCase('ftWideMemo') Then
    Result := ftMemo
    {$IFEND}
  Else If vFieldType = UpperCase('ftGraphic') Then
    Result := ftGraphic
  Else If vFieldType = UpperCase('ftFmtMemo') Then
    Result := ftFmtMemo
  Else If vFieldType = UpperCase('ftParadoxOle') Then
    Result := ftParadoxOle
  Else If vFieldType = UpperCase('ftDBaseOle') Then
    Result := ftDBaseOle
  Else If vFieldType = UpperCase('ftTypedBinary') Then
    Result := ftTypedBinary
  Else If vFieldType = UpperCase('ftCursor') Then
    Result := ftCursor
  Else If vFieldType = UpperCase('ftFixedChar') Then
    Result := ftFixedChar
  Else If vFieldType = UpperCase('ftWideString') Then
    {$IF Defined(RESTDWLAZARUS) OR not Defined(DELPHIXEUP)}
    Result := ftString
    {$ELSE}
    Result := ftWideString
    {$IFEND}
  Else If vFieldType = UpperCase('ftLargeint') Then
    Result := ftLargeint
  Else If vFieldType = UpperCase('ftADT') Then
    Result := ftADT
  Else If vFieldType = UpperCase('ftArray') Then
    Result := ftArray
  Else If vFieldType = UpperCase('ftReference') Then
    Result := ftReference
  Else If vFieldType = UpperCase('ftDataSet') Then
    Result := ftDataSet
  Else If vFieldType = UpperCase('ftOraBlob') Then
    Result := ftOraBlob
  Else If vFieldType = UpperCase('ftOraClob') Then
    Result := ftOraClob
  Else If vFieldType = UpperCase('ftVariant') Then
    Result := ftVariant
  Else If vFieldType = UpperCase('ftInterface') Then
    Result := ftInterface
  Else If vFieldType = UpperCase('ftIDispatch') Then
    Result := ftIDispatch
  Else If vFieldType = UpperCase('ftGuid') Then
    Result := ftGuid
  Else If vFieldType = UpperCase('ftTimeStamp') Then
  Begin
    {$IFNDEF RESTDWLAZARUS}
    Result := ftTimeStamp;
    {$ELSE}
    Result := ftDateTime;
    {$ENDIF}
  End
  Else If vFieldType = UpperCase('ftSingle') Then
  Begin
    {$IFDEF DELPHIXEUP}
    Result := ftSingle;
    {$ELSE}
    Result := ftFloat;
    {$ENDIF}
  End
  Else If vFieldType = UpperCase('ftFMTBcd') Then
    Result := ftFMTBcd
    {$IFDEF DELPHIXEUP}
  Else If vFieldType = UpperCase('ftFixedWideChar') Then
    Result := ftFixedWideChar
  Else If vFieldType = UpperCase('ftWideMemo') Then
    Result := ftWideMemo
  Else If vFieldType = UpperCase('ftOraTimeStamp') Then
    Result := ftOraTimeStamp
  Else If vFieldType = UpperCase('ftOraInterval') Then
    Result := ftOraInterval
  Else If vFieldType = UpperCase('ftLongWord') Then
    Result := ftLongWord
  Else If vFieldType = UpperCase('ftShortint') Then
    Result := ftShortint
  Else If vFieldType = UpperCase('ftByte') Then
    Result := ftByte
  Else If vFieldType = UpperCase('ftExtended') Then
    Result := ftExtended
  Else If vFieldType = UpperCase('ftConnection') Then
    Result := ftConnection
  Else If vFieldType = UpperCase('ftParams') Then
    Result := ftParams
  Else If vFieldType = UpperCase('ftStream') Then
    Result := ftStream
  Else If vFieldType = UpperCase('ftTimeStampOffset') Then
    Result := ftTimeStampOffset
  Else If vFieldType = UpperCase('ftObject') Then
    Result := ftObject
    {$ENDIF};
End;

{$IFDEF DELPHIXEUP}

Function GetEncoding(AValue: TEncodeSelect): TEncoding;
Begin
  Result := TEncoding.UTF8;
  Case AValue of
    esUtf8:
      Result := TEncoding.Unicode;
    esANSI:
      Result := TEncoding.ANSI;
    esASCII:
      Result := TEncoding.ASCII;
  End;
End;
{$ENDIF}

Function BuildStringFloat(Value: String; DataModeD: TDataMode = dmDataware;
  FloatDecimalFormat: String = ''): String;
Begin
  {$IFDEF DELPHIXEUP}
  DecimalLocal := FormatSettings.DecimalSeparator;
  {$ELSE}
  DecimalLocal := DecimalSeparator;
  {$ENDIF}
  Case DataModeD Of
    dmDataware:
      Result := StringReplace(Value, DecimalLocal, TDecimalChar,
        [rfReplaceAll]);
    dmRAW:
      Begin
        If FloatDecimalFormat = '' Then
          Result := Value
        Else If DecimalLocal <> FloatDecimalFormat Then
          Result := StringReplace(Value, DecimalLocal, FloatDecimalFormat,
            [rfReplaceAll])
        Else
          Result := Value;
      End;
  End;
End;

Function BuildFloatString(Value: String): String;
Begin
  {$IFDEF DELPHIXEUP}
  DecimalLocal := FormatSettings.DecimalSeparator;
  {$ELSE}
  DecimalLocal := DecimalSeparator;
  {$ENDIF}
  Result := StringReplace(Value, TDecimalChar, DecimalLocal, [rfReplaceAll]);
End;

Function RandomString(strLen: Integer): String;
Var
  Str: String;
Begin
  Randomize;
  Str := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW XYZ';
  Result := '';
  Repeat
    Result := Result + Str[Random(Length(Str) - FinalStrPos) + 1];
  Until (Length(Result) = strLen) End;

  Procedure InitializeStrings;
  {$IFDEF DELPHIXEUP}
  Var
    S: String;
    {$ENDIF}
  Begin
    {$IFDEF DELPHIXEUP}
    S := '0';
    If Low(S) = 0 Then
    Begin
      InitStrPos := 0;
      FinalStrPos := 1;
    End
    Else
    Begin
      InitStrPos := 1;
      FinalStrPos := 0;
    End;
    {$ELSE}
    InitStrPos := 1;
    FinalStrPos := 0;
    {$ENDIF}
  End;

initialization

InitializeStrings;

End.
