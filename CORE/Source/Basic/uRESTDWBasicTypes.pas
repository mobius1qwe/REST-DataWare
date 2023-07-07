unit uRESTDWBasicTypes;

{$I ..\..\Source\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
  {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHIXE3UP)}
  DbTables,
  {$IFEND}
  SysUtils,  Classes, Db, FMTBcd,
  uRESTDWAbout, uRESTDWMemoryDataset, uRESTDWConsts,
  uRESTDWProtoTypes, uRESTDWTools;

 Type
  TFieldDefinition = Class
  Public
   FieldName : String;
   DataType  : TFieldType;
   Size,
   Precision : Integer;
   Required  : Boolean;
 End;

 Type
  TResultErro = Record
   Status,
   MessageText: String;
 End;

 Type
  TSQLTimeStamp = Record
   Year,
   Month,
   Day,
   Hour,
   Minute,
   Second    : Word;
   Fractions : Cardinal;
 End;

type
  TSQLTimeStampOffset = record
   Year,
   Month,
   Day,
   Hour,
   Minute,
   Second    : Word;
   Fractions : Cardinal;
   TimeZoneHour: SmallInt;
   TimeZoneMinute: SmallInt;
 end;


 Type
  TClassNull= Class(TComponent)
 End;

 Type
  TFieldsList          = Array of TFieldDefinition;
  TProxyConnectionInfo = Class(TPersistent)
 Protected
  FPassword,
  FServer,
  FUsername : String;
  FPort     : Integer;
  Procedure AssignTo      (Destination : TPersistent); Override;
  Procedure SetProxyPort  (Const Value : Integer);
  Procedure SetProxyServer(Const Value : String);
 Public
  Procedure   AfterConstruction; Override;
  Constructor Create;
  Procedure   Clear;
  Destructor  Destroy; Override;
 Published
  property ProxyPassword : String  Read FPassword Write FPassword;
  property ProxyPort     : Integer Read FPort     Write SetProxyPort;
  property ProxyServer   : String  Read FServer   Write SetProxyServer;
  property ProxyUsername : String  Read FUsername Write FUserName;
 End;


 Type
  TConnectionDefs = Class(TPersistent)
  Private
   votherDetails,
   vCharset,
   vDatabaseName,
   vHostName,
   vUsername,
   vPassword,
   vProtocol,
   vDriverID,
   vDataSource       : String;
   vdbPort         : Integer;
   vDWDatabaseType : TRESTDWDatabaseType;
  Private
   Function GetDatabaseType(Value : String)          : TRESTDWDatabaseType;Overload;
   Function GetDatabaseType(Value : TRESTDWDatabaseType) : String;         Overload;
  Public
   Constructor Create; //Cria o Componente
   Destructor  Destroy;Override;//Destroy a Classe
   Procedure   Assign(Source : TPersistent); Override;
   Function    ToJSON : String;
   Procedure   LoadFromJSON(Value : String);
  Published
   Property DriverType   : TRESTDWDatabaseType Read vDWDatabaseType Write vDWDatabaseType;
   Property Charset      : String          Read vCharset        Write vCharset;
   Property DriverID     : String          Read vDriverID       Write vDriverID;
   Property DatabaseName : String          Read vDatabaseName   Write vDatabaseName;
   Property HostName     : String          Read vHostName       Write vHostName;
   Property Username     : String          Read vUsername       Write vUsername;
   Property Password     : String          Read vPassword       Write vPassword;
   Property Protocol     : String          Read vProtocol       Write vProtocol;
   Property DBPort       : Integer         Read vdbPort         Write vdbPort;
   Property DataSource   : String          Read vDataSource     Write vDataSource;
   Property OtherDetails : String          Read votherDetails   Write votherDetails;
  End;

  Type
   TRESTDWDataRoute   = Class
   Private
    vDataRoute         : String;
    vServerMethodClass : TComponentClass;
    Procedure SetDataRoute(Value : String);
   Public
    Constructor Create;
    Property DataRoute         : String           Read vDataRoute         Write SetDataRoute;
    Property ServerMethodClass : TComponentClass  Read vServerMethodClass Write vServerMethodClass;
  End;

  Type
   PRESTDWDataRoute     = ^TRESTDWDataRoute;
   TRESTDWDataRouteList = Class(TList)
   Private
    Function  GetRec(Index : Integer) : TRESTDWDataRoute; Overload;
    Procedure PutRec(Index : Integer;
                     Item  : TRESTDWDataRoute); Overload;
   Public
    Procedure ClearList;
    Constructor Create;
    Destructor  Destroy; Override;
    Function    RouteExists(Var Value : String) : Boolean;
    Procedure   Delete(Index : Integer); Overload;
    Function    Add   (Item  : TRESTDWDataRoute) : Integer; Overload;
    Function    GetServerMethodClass(Var DataRoute,
                                     FullRequest           : String;
                                     Var ServerMethodClass : TComponentClass) : Boolean;
    Property    Items [Index : Integer] : TRESTDWDataRoute Read GetRec Write PutRec; Default;
  End;

 Type
  TArguments = Array Of String;

 Type
  TStreamType = (stMetaData, stAll);

 Type
  TPrivateClass = Class
 End;

 Type
  TRESTDWAppendFileStream           = Class(TFileStream)
 Public
  Constructor Create(Const AFile    : String);
 End;
  TRESTDWReadFileExclusiveStream    = Class(TFileStream)
 Public
  Constructor Create(Const AFile    : String);
 End;
  TRESTDWReadFileNonExclusiveStream = Class(TFileStream)
 Public
  Constructor Create(Const AFile    : String);
 End;
  TRESTDWFileCreateStream           = Class(TFileStream)
 Public
  Constructor Create(Const AFile    : String);
 End;

 Type
  TRESTDWStreamHelper = Class
 Public
  Class Function ReadBytes(Const AStream : TStream;
                           Var   VBytes  : TRESTDWBytes;
                           Const ACount  : Integer = -1;
                           Const AOffset : Integer = 0) : Integer;
  Class Function Write    (Const AStream : TStream;
                           Const ABytes  : TRESTDWBytes;
                           Const ACount  : Integer = -1;
                           Const AOffset : Integer = 0) : Integer;
  Class Function Seek     (Const AStream : TStream;
                           Const AOffset : TRESTDWStreamSize;
                           Const AOrigin : TSeekOrigin) : TRESTDWStreamSize;
 End;

 Type
  TRESTDWClientSQLBase  = Class(TRESTDWMemTable)             //Classe com as funcionalidades de um DBQuery
  Private
   fsAbout                            : TRESTDWAboutInfo;
   vComponentTag,
   vSequenceField,
   vSequenceName                      : String;
   vLoadFromStream,
   vBinaryCompatibleMode,
   vOnLoadStream,
   vBinaryLoadRequest                 : Boolean;
   vOnWriterProcess                   : TOnWriterProcess;
   {$IFDEF RESTDWLAZARUS}
   vDatabaseCharSet                   : TDatabaseCharSet;
   Procedure SetDatabaseCharSet(Value : TDatabaseCharSet);
   Function  GetDatabaseCharSet : TDatabaseCharSet;
   {$ENDIF}
   Function  OnEditingState : Boolean;
  Public
   Procedure   BaseOpen;
   Procedure   BaseClose;
   Procedure   ForceInternalCalc;
   Procedure   SetComponentTAG;
   Procedure   SetInDesignEvents(Const Value : Boolean);Virtual;Abstract;
   Procedure   SetInBlockEvents (Const Value : Boolean);Virtual;Abstract;
   Procedure   SetInitDataset   (Const Value : Boolean);Virtual;Abstract;
   Procedure   PrepareDetailsNew;                       Virtual;Abstract;
   Procedure   PrepareDetails(ActiveMode : Boolean);    Virtual;Abstract;
   Constructor Create(AOwner: TComponent);Override;
   Property    InLoadFromStream  : Boolean       Read vLoadFromStream;
   Property    BinaryLoadRequest : Boolean       Read vBinaryLoadRequest;
   Property    OnLoadStream      : Boolean       Read vOnLoadStream       Write vOnLoadStream;
   Property    Componenttag      : String        Read vComponentTag;
   {$IFDEF RESTDWLAZARUS}
   Property DatabaseCharSet      : TDatabaseCharSet Read GetDatabaseCharSet Write SetDatabaseCharSet;
   {$ENDIF}
  Published
   Property    SequenceName      : String           Read vSequenceName          Write vSequenceName;
   Property    SequenceField     : String           Read vSequenceField         Write vSequenceField;
   Property    OnWriterProcess   : TOnWriterProcess Read vOnWriterProcess       Write vOnWriterProcess;
   Property    AboutInfo         : TRESTDWAboutInfo Read fsAbout                Write fsAbout Stored False;
 End;

Type
 TRESTDWDatasetArray = Array of TRESTDWClientSQLBase;
 TArrayMonth         = Array [1..12] Of String;
 TArrayWeek          = Array [1..7] Of String;

Var
 RESTDWHexDigits        : Array [0..15] Of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
 RESTDWOctalDigits      : Array [0..7]  Of Char = ('0', '1', '2', '3', '4', '5', '6', '7');
 RESTDWShortMonthNames,
 RESTDWLongMonthNames   : TArrayMonth;
 RESTDWShortDayNames,
 RESTDWLongDayNames     : TArrayWeek;
 RESTDWTimeAMString,
 RESTDWTimePMString,
 RESTDWCurrencyString,
 RESTDWShortTimeFormat,
 RESTDWShortDateFormat  : DWString;
 RESTDWCurrencyDecimals : Byte;
 RESTDWDateSeparator,
 RESTDWTimeSeparator,
 RESTDWThousandSeparator,
 RESTDWDecimalSeparator : Char;

Implementation

Uses
  uRESTDWDataJSON, uRESTDWJSONInterface, uRESTDWBasicDB,
  uRESTDWDataUtils, uRESTDWMimeTypes;

Class Function TRESTDWStreamHelper.ReadBytes(Const AStream : TStream;
                                             Var   VBytes  : TRESTDWBytes;
                                             Const ACount,
                                             AOffset       : Integer): Integer;
Var
 LActual : Integer;
Begin
 Assert(AStream<>nil);
 Result := 0;
 If VBytes = Nil Then
  SetLength(VBytes, 0);
 LActual := ACount;
 If LActual < 0 Then
  LActual := AStream.Size - AStream.Position;
 If LActual = 0 Then
  Exit;
 If Length(VBytes) < (AOffset+LActual) Then
  SetLength(VBytes, AOffset+LActual);
 Assert(VBytes<>nil);
 Result := AStream.Read(VBytes[AOffset], LActual);
End;

Class Function TRESTDWStreamHelper.Write(Const AStream : TStream;
                                         Const ABytes  : TRESTDWBytes;
                                         Const ACount  : Integer;
                                         Const AOffset : Integer) : Integer;
Var
 LActual : Integer;
Begin
 Result := 0;
 Assert(AStream<>nil);
 If ABytes <> Nil Then
  Begin
   LActual := restdwLength(ABytes, ACount, AOffset);
   If LActual > 0 Then
    Result := AStream.Write(ABytes[AOffset], LActual);
  End;
End;

Class Function TRESTDWStreamHelper.Seek(Const AStream : TStream;
                                        Const AOffset : TRESTDWStreamSize;
                                        Const AOrigin : TSeekOrigin) : TRESTDWStreamSize;
{$IFNDEF STREAM_SIZE_64}
Const
 cOrigins: array[TSeekOrigin] of Word = (soFromBeginning, soFromCurrent, soFromEnd);
{$ENDIF}
Begin
 {$IFDEF STREAM_SIZE_64}
  Result := AStream.Seek(AOffset, AOrigin);
 {$ELSE}
  Result := AStream.Seek(AOffset, cOrigins[AOrigin]);
 {$ENDIF}
End;

Procedure TProxyConnectionInfo.SetProxyPort(Const Value : Integer);
Begin
 FPort := Value;
End;

Procedure TProxyConnectionInfo.SetProxyServer(Const Value : String);
Begin
 FServer := Value;
End;

Procedure TProxyConnectionInfo.AssignTo(Destination : TPersistent);
Var
 LDest : TProxyConnectionInfo;
Begin
 If Destination Is TProxyConnectionInfo Then
  Begin
   LDest := TProxyConnectionInfo(Destination);
   LDest.FPassword := FPassword;
   LDest.FPort := FPort;
   LDest.FServer := FServer;
   LDest.FUsername := FUsername;
  End
 Else
  Inherited AssignTo(Destination);
End;

Procedure TProxyConnectionInfo.Clear;
Begin
 FServer := '';
 FUsername := '';
 FPassword := '';
 FPort := 0;
End;

Constructor TProxyConnectionInfo.Create;
Begin
 Inherited Create;
End;

Procedure TProxyConnectionInfo.AfterConstruction;
Begin
 Inherited AfterConstruction;
 Clear;
End;

Destructor TProxyConnectionInfo.Destroy;
Begin
 Inherited Destroy;
End;

Constructor TRESTDWFileCreateStream.Create(const AFile : String);
Begin
 Inherited Create(AFile, fmCreate or fmOpenReadWrite or fmShareDenyWrite);
End;

Constructor TRESTDWAppendFileStream.Create(const AFile : String);
Var
 LFlags: Word;
Begin
 LFlags := fmOpenReadWrite or fmShareDenyWrite;
 If Not FileExists(AFile) Then
  LFlags := LFLags or fmCreate;
 Inherited Create(AFile, LFlags);
 If (LFlags and fmCreate) = 0 Then
  TRESTDWStreamHelper.Seek(Self, 0, soEnd);
End;

Constructor TRESTDWReadFileNonExclusiveStream.Create(const AFile : String);
Begin
 Inherited Create(AFile, fmOpenRead or fmShareDenyNone);
End;

Constructor TRESTDWReadFileExclusiveStream.Create(Const AFile : String);
Begin
 Inherited Create(AFile, fmOpenRead or fmShareDenyWrite);
End;

Constructor TConnectionDefs.Create;
Begin
 Inherited;
 vdbPort          := -1;
 vDWDatabaseType  := dbtUndefined;
End;

Destructor  TConnectionDefs.Destroy;
Begin
 Inherited;
End;

Function TConnectionDefs.GetDatabaseType(Value : String)          : TRESTDWDatabaseType;
Begin
 Result := dbtUndefined;
 If LowerCase(Value) = LowerCase('dbtUndefined')       Then
  Result := dbtUndefined
 Else If LowerCase(Value) = LowerCase('dbtAccess')     Then
  Result := dbtAccess
 Else If LowerCase(Value) = LowerCase('dbtDbase')      Then
  Result := dbtDbase
 Else If LowerCase(Value) = LowerCase('dbtFirebird')   Then
  Result := dbtFirebird
 Else If LowerCase(Value) = LowerCase('dbtInterbase')  Then
  Result := dbtInterbase
 Else If LowerCase(Value) = LowerCase('dbtMySQL')      Then
  Result := dbtMySQL
 Else If LowerCase(Value) = LowerCase('dbtMsSQL')      Then
  Result := dbtMsSQL
 Else If LowerCase(Value) = LowerCase('dbtOracle')     Then
  Result := dbtOracle
 Else If LowerCase(Value) = LowerCase('dbtODBC')       Then
  Result := dbtODBC
 Else If LowerCase(Value) = LowerCase('dbtParadox')    Then
  Result := dbtParadox
 Else If LowerCase(Value) = LowerCase('dbtPostgreSQL') Then
  Result := dbtPostgreSQL
 Else If LowerCase(Value) = LowerCase('dbtSQLLite')    Then
  Result := dbtSQLLite
 Else If LowerCase(Value) = LowerCase('dbtAdo')    Then
  Result := dbtAdo;
End;

Function TConnectionDefs.GetDatabaseType(Value : TRESTDWDatabaseType) : String;
Begin
 Case Value Of
  dbtUndefined  : Result := LowerCase('dbtUndefined');
  dbtAccess     : Result := LowerCase('dbtAccess');
  dbtDbase      : Result := LowerCase('dbtDbase');
  dbtFirebird   : Result := LowerCase('dbtFirebird');
  dbtInterbase  : Result := LowerCase('dbtInterbase');
  dbtMySQL      : Result := LowerCase('dbtMySQL');
  dbtSQLLite    : Result := LowerCase('dbtSQLLite');
  dbtOracle     : Result := LowerCase('dbtOracle');
  dbtMsSQL      : Result := LowerCase('dbtMsSQL');
  dbtParadox    : Result := LowerCase('dbtParadox');
  dbtPostgreSQL : Result := LowerCase('dbtPostgreSQL');
  dbtODBC       : Result := LowerCase('dbtODBC');
  dbtAdo        : Result := LowerCase('dbtAdo');
 End;
End;

Procedure   TConnectionDefs.Assign(Source : TPersistent);
Var
 Src : TConnectionDefs;
Begin
 If Source is TConnectionDefs Then
  Begin
   Src           := TConnectionDefs(Source);
   votherDetails := Src.votherDetails;
   vDatabaseName := Src.vDatabaseName;
   vHostName     := Src.vHostName;
   vUsername     := Src.vUsername;
   vPassword     := Src.vPassword;
   vdbPort       := Src.vdbPort;
   vDriverID     := Src.vDriverID;
   vDataSource   := Src.vDataSource;
  End
 Else
  Inherited;
End;

Function    TConnectionDefs.ToJSON : String;
Begin
 Result := Format('{"databasename":"%s","hostname":"%s",'+
                  '"username":"%s","password":"%s","dbPort":%d,'+
                  '"otherDetails":"%s","charset":"%s","databasetype":"%s","protocol":"%s",'+
                  '"driverID":"%s","datasource":"%s"}',
                  [EncodeStrings(vDatabaseName{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                   EncodeStrings(vHostName{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                   EncodeStrings(vUsername{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                   EncodeStrings(vPassword{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                   vdbPort,
                   EncodeStrings(votherDetails{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                   EncodeStrings(vCharset{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                   EncodeStrings(GetDatabaseType(vDWDatabaseType){$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                   EncodeStrings(vProtocol{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                   EncodeStrings(vDriverID{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                   EncodeStrings(vDataSource{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})]);
End;

Procedure TConnectionDefs.LoadFromJSON(Value : String);
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
Begin
 bJsonValue := TRESTDWJSONInterfaceObject.Create(Value);
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    vDatabaseName   := DecodeStrings(bJsonValue.Pairs[0].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    vHostName       := DecodeStrings(bJsonValue.Pairs[1].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    vUsername       := DecodeStrings(bJsonValue.Pairs[2].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    vPassword       := DecodeStrings(bJsonValue.Pairs[3].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    If bJsonValue.Pairs[4].Value <> '' Then
     vdbPort        := StrToInt(bJsonValue.Pairs[4].Value)
    Else
     vdbPort        := -1;
    votherDetails   := DecodeStrings(bJsonValue.Pairs[5].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    vCharset        := DecodeStrings(bJsonValue.Pairs[6].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    vDWDatabaseType := GetDatabaseType(DecodeStrings(bJsonValue.Pairs[7].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));
    vProtocol       := DecodeStrings(bJsonValue.Pairs[8].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    vDriverID       := DecodeStrings(bJsonValue.Pairs[9].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
    vDataSource     := DecodeStrings(bJsonValue.Pairs[10].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Function RPos(const Substr, S: string): Integer;
Var
 I, X, Len: Integer;
Begin
 Len := Length(SubStr);
 I := Length(S) - Len + 1;
 If (I <= 0) Or (Len = 0) Then
  Begin
   RPos := 0;
   Exit;
  End
 Else
  Begin
   While I > 0 Do
    Begin
     If S[I] = SubStr[1] Then
      Begin
       X := 1;
       While (X < Len) And (S[I + X] = SubStr[X + 1]) Do
        Inc(X);
       If (X = Len) Then
        Begin
         RPos := I;
         exit;
        End;
      End;
     Dec(I);
    End;
   RPos := 0;
  End;
End;

Procedure TRESTDWClientSQLBase.BaseClose;
Begin
 TRESTDWClientSQLBase(Self).Close;
End;

Procedure TRESTDWClientSQLBase.BaseOpen;
Begin
 TRESTDWClientSQLBase(Self).Open;
End;

Constructor TRESTDWClientSQLBase.Create(AOwner: TComponent);
Begin
 Inherited;
 vOnWriterProcess      := Nil;
 vBinaryCompatibleMode := False;
 vLoadFromStream       := False;
 vBinaryCompatibleMode := True;
End;

{$IFDEF RESTDWLAZARUS}
Function  TRESTDWClientSQLBase.GetDatabaseCharSet : TDatabaseCharSet;
Begin
 Result := vDatabaseCharSet;
End;

Procedure TRESTDWClientSQLBase.SetDatabaseCharSet(Value : TDatabaseCharSet);
Begin
 vDatabaseCharSet := Value;
End;
{$ENDIF}

Function TRESTDWClientSQLBase.OnEditingState: Boolean;
Begin
 Result := (State in [dsEdit, dsInsert]);
 If Result then
  Edit;
End;

Procedure TRESTDWClientSQLBase.SetComponentTAG;
Begin
 vComponentTag := EncodeStrings(RandomString(10){$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
End;

Procedure TRESTDWClientSQLBase.ForceInternalCalc;
Var
 needsPost : Boolean;
 saveState : TDataSetState;
Begin
 needsPost := OnEditingState;
 saveState := setTempState(dsInternalCalc);
 Try
  RefreshInternalCalcFields(ActiveBuffer);
 Finally
  RestoreState(saveState);
 End;
 If needsPost Then
  Post;
End;

Procedure TRESTDWDataRoute.SetDataRoute(Value : String);
Begin
 vDataRoute := Value;
 If Trim(vDataRoute) = '' Then
  vDataRoute := '/'
 Else
  Begin
   If Copy(vDataRoute, 1, 1) <> '/' Then
    vDataRoute := '/' + vDataRoute;
   If Copy(vDataRoute, Length(vDataRoute), 1) <> '/' Then
    vDataRoute := vDataRoute + '/';
  End;
End;

Constructor TRESTDWDataRoute.Create;
Begin
 vDataRoute         := '';
 vServerMethodClass := TClassNull;
End;

Function TRESTDWDataRouteList.GetRec(Index : Integer) : TRESTDWDataRoute;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TRESTDWDataRoute(TList(Self).Items[Index]^);
End;

Procedure TRESTDWDataRouteList.PutRec(Index : Integer;
                                      Item  : TRESTDWDataRoute);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TRESTDWDataRoute(TList(Self).Items[Index]^) := Item;
End;

Procedure TRESTDWDataRouteList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Constructor TRESTDWDataRouteList.Create;
Begin
 Inherited;
End;

Function   TRESTDWDataRouteList.RouteExists(Var Value : String) : Boolean;
Var
 I          : Integer;
 vTempRoute,
 vTempValue : String;
Begin
 Result := False;
 If Length(Value) = 0 Then
  Exit;
 For I := 0 To Count -1 Do
  Begin
   vTempRoute := Lowercase(Items[I].DataRoute);
   vTempValue := Lowercase(Value);
   Result     := vTempRoute = Copy(vTempValue, 1, Length(vTempRoute));
   If Result Then
    Break;
  End;
End;

Destructor TRESTDWDataRouteList.Destroy;
Begin
 ClearList;
 Inherited;
End;

Procedure TRESTDWDataRouteList.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
      {$IFDEF RESTDWLAZARUS}
        FreeAndNil(TList(Self).Items[Index]^);
        Dispose(PRESTDWDataRoute(TList(Self).Items[Index]));
      {$ELSE}
        {$IFDEF DELPHI10_4UP}
          FreeAndNil(TRESTDWDataRoute(TList(Self).Items[Index]^));
        {$ELSE}
          FreeAndNil(TList(Self).Items[Index]^);
        {$ENDIF}
        Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Function TRESTDWDataRouteList.GetServerMethodClass(Var DataRoute,
                                                   FullRequest           : String;
                                                   Var ServerMethodClass : TComponentClass) : Boolean;
Var
 I           : Integer;
 vTempRoute,
 vTempValue  : String;
Begin
 Result            := False;
 ServerMethodClass := Nil;
 Result := False;
 If Length(DataRoute) = 0 Then
  Exit;
 For I := 0 To Self.Count -1 Do
  Begin
   vTempRoute := Lowercase(TRESTDWDataRoute(TList(Self).Items[I]^).DataRoute);
   vTempValue := Lowercase(DataRoute);
   Result     := vTempRoute = Copy(vTempValue, 1, Length(vTempRoute));
   If (Result) Then
    Begin
     ServerMethodClass := TRESTDWDataRoute(TList(Self).Items[I]^).ServerMethodClass;
     DataRoute         := Copy(vTempValue,  Length(vTempRoute), Length(DataRoute) - (Length(vTempRoute) -1));
     FullRequest       := Copy(FullRequest, Length(vTempRoute), Length(FullRequest) - (Length(vTempRoute) -1));
     Break;
    End;
  End;
End;

Function TRESTDWDataRouteList.Add(Item : TRESTDWDataRoute) : Integer;
Var
 vItem : PRESTDWDataRoute;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Initialization
{$IFDEF RESTDWLAZARUS}
 RESTDWDecimalSeparator  := DecimalSeparator;
 RESTDWThousandSeparator := ThousandSeparator;
 RESTDWCurrencyDecimals  := CurrencyDecimals;
 RESTDWShortDateFormat   := ShortDateFormat;
 RESTDWDateSeparator     := DateSeparator;
 RESTDWTimeSeparator     := TimeSeparator;
 RESTDWShortTimeFormat   := ShortTimeFormat;
 RESTDWTimeAMString      := TimeAMString;
 RESTDWTimePMString      := TimePMString;
 RESTDWLongMonthNames    := TArrayMonth(LongMonthNames);
 RESTDWShortMonthNames   := TArrayMonth(ShortMonthNames);
 RESTDWShortDayNames     := TArrayWeek(ShortDayNames);
 RESTDWLongDayNames      := TArrayWeek(LongDayNames);
 RESTDWCurrencyString    := CurrencyString;
{$ELSE}
 {$IFDEF DELPHIXEUP}
  RESTDWDecimalSeparator  := FormatSettings.DecimalSeparator;
  RESTDWThousandSeparator := FormatSettings.ThousandSeparator;
  RESTDWCurrencyDecimals  := FormatSettings.CurrencyDecimals;
  RESTDWShortDateFormat   := FormatSettings.ShortDateFormat;
  RESTDWDateSeparator     := FormatSettings.DateSeparator;
  RESTDWTimeSeparator     := FormatSettings.TimeSeparator;
  RESTDWShortTimeFormat   := FormatSettings.ShortTimeFormat;
  RESTDWTimeAMString      := FormatSettings.TimeAMString;
  RESTDWTimePMString      := FormatSettings.TimePMString;
  RESTDWCurrencyString    := FormatSettings.CurrencyString;
  RESTDWLongMonthNames    := TArrayMonth(FormatSettings.LongMonthNames);
  RESTDWShortMonthNames   := TArrayMonth(FormatSettings.ShortMonthNames);
  RESTDWShortDayNames     := TArrayWeek(FormatSettings.ShortDayNames);
  RESTDWLongDayNames      := TArrayWeek(FormatSettings.LongDayNames);
 {$ELSE}
  RESTDWDecimalSeparator  := DecimalSeparator;
  RESTDWThousandSeparator := ThousandSeparator;
  RESTDWCurrencyDecimals  := CurrencyDecimals;
  RESTDWShortDateFormat   := ShortDateFormat;
  RESTDWDateSeparator     := DateSeparator;
  RESTDWTimeSeparator     := TimeSeparator;
  RESTDWShortTimeFormat   := ShortTimeFormat;
  RESTDWTimeAMString      := TimeAMString;
  RESTDWTimePMString      := TimePMString;
  RESTDWLongMonthNames    := TArrayMonth(LongMonthNames);
  RESTDWShortMonthNames   := TArrayMonth(ShortMonthNames);
  RESTDWShortDayNames     := TArrayWeek(ShortDayNames);
  RESTDWLongDayNames      := TArrayWeek(LongDayNames);
  RESTDWCurrencyString    := CurrencyString;
 {$ENDIF}
{$ENDIF}

end.
