unit uRESTDWDataUtils;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

Uses
  {$IFNDEF RESTDWLAZARUS}StringBuilderUnit,{$ENDIF}
  Classes, SysUtils,
  uRESTDWTools, uRESTDWConsts, uRESTDWMD5, uRESTDWBasicTypes, uRESTDWParams,
  uRESTDWMimeTypes,
  DateUtils;

Type
 {$IFDEF RESTDWLAZARUS}
  DWInteger       = Longint;
  DWInt64         = Int64;
  DWFloat         = Real;
  DWFieldTypeSize = Longint;
  DWBufferSize    = Longint;
 {$ELSE}
  DWInteger       = Integer;
  DWInt64         = Int64;
  DWFloat         = Real;
  DWFieldTypeSize = Integer;
  DWBufferSize    = Longint;
 {$ENDIF}
 PDWInt64         = ^DWInt64;

  {$IFDEF RESTDWLAZARUS}
  DWString     = AnsiString;
  DWWideString = WideString;
  {$ELSE}
    {$IF (Defined(DELPHIXE5UP) and (not defined(DELPHI10_0UP)))}
      {$IFDEF RESTDWFMX}
      DWString     = String;
      DWWideString = String;
      {$ELSE}
      DWString     = Utf8String;
      DWWideString = Utf8String;
      {$ENDIF}
    {$ELSE}
      {$IFDEF RESTDWFMX}
      DWString     = Utf8String;
      DWWideString = Utf8String;
      {$ELSE}
      DWString     = AnsiString;
      DWWideString = WideString;
      {$ENDIF}
    {$IFEND}
  {$ENDIF}

Type
 TRESTDWParamsHeader = Packed Record
  VersionNumber,
  RecordCount,
  ParamsCount    : DWInteger; //new for ver15
  DataSize       : DWInt64; //new for ver15
End;

 TTokenValue = Class
 Private
  vInitRequest,
  vFinalRequest         : TDateTime;
  vServerSignature,
  vTokenHash,
  vToken,
  vSecrets,
  vMD5                  : String;
  vRDWTokenType         : TRESTDWTokenType;
  vRDWCryptType         : TRESTDWCryptType;
  Procedure   SetTokenHash (Token : String);
  Function    ToJSON       : String;
  Function    GetCryptType : String;
  Function    GetTokenType : String;
  Function    GetHeader    : String;
  Procedure   SetSecrets     (Value : String);
  Procedure   SetFinalRequest(Value : TDateTime);
 Public
  vCripto: TCripto;
  Constructor    Create;
  Destructor     Destroy;Override;
  Class Function GetMD5       (Const Value : String)    : String;
  Class Function ISO8601FromDateTime(Value : TDateTime) : String;
  Class Function DateTimeFromISO8601(Value : String)    : TDateTime;
  Function       ToToken           : String;
  Property       TokenType         : TRESTDWTokenType Read vRDWTokenType      Write vRDWTokenType;
  Property       CryptType         : TRESTDWCryptType Read vRDWCryptType      Write vRDWCryptType;
  Property       BeginTime         : TDateTime        Read vInitRequest       Write vInitRequest;
  Property       EndTime           : TDateTime        Read vFinalRequest      Write SetFinalRequest;
  Property       Iss               : String           Read vServerSignature   Write vServerSignature;
  Property       Secrets           : String           Read vSecrets           Write SetSecrets;
  Property       TokenHash         : String           Read vTokenHash         Write SetTokenHash;
  Property       Token             : String           Read ToToken;
End;

 TRESTDWAuthOptionParam = Class(TPersistent)
 Private
  vCustom404TitleMessage,
  vCustom404BodyMessage,
  vCustom404FooterMessage,
  vCustomAuthMessage       : String;
  vAuthDialog              : Boolean;
  vCustomAuthErrorPage     : TStringList;
  Procedure SetCustomAuthErrorPage (Value : TStringList);
 Protected
 Public
//  Procedure   Assign   (Source   : TPersistent);Override;
  Constructor Create;
  Destructor  Destroy;Override;
 Published
  Property AuthDialog              : Boolean     Read vAuthDialog             Write vAuthDialog;
  Property CustomDialogAuthMessage : String      Read vCustomAuthMessage      Write vCustomAuthMessage;
  Property Custom404TitleMessage   : String      Read vCustom404TitleMessage  Write vCustom404TitleMessage;
  Property Custom404BodyMessage    : String      Read vCustom404BodyMessage   Write vCustom404BodyMessage;
  Property Custom404FooterMessage  : String      Read vCustom404FooterMessage Write vCustom404FooterMessage;
  Property CustomAuthErrorPage     : TStringList Read vCustomAuthErrorPage    Write SetCustomAuthErrorPage;
End;

 TRESTDWAuthTokenParam = Class(TRESTDWAuthOptionParam)
 Private
  vInitRequest,
  vFinalRequest : TDateTime;
  vServerSignature,
  vSecrets,
  vGetTokenName,
  vTokenName,
  vTokenHash    : String;
  vDWRoutes     : TRESTDWRoutes;
  vLifeCycle    : Integer;
  vRDWTokenType : TRESTDWTokenType;
  vRDWCryptType : TRESTDWCryptType;
  Procedure   SetTokenHash   (Token : String);
  Procedure   SetGetTokenName(Value : String);
  Procedure   SetCryptType   (Value : TRESTDWCryptType);
  Function    GetTokenType   (Value : String) : TRESTDWTokenType;
  Function    GetCryptType   (Value : String) : TRESTDWCryptType;
 Protected
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Procedure   Assign   (Source   : TPersistent);Override;
  Function    GetToken (aSecrets : String) : String;  Virtual; Abstract;
  Function    FromToken(Value    : String) : Boolean; Virtual; Abstract;
  Property    BeginTime          : TDateTime       Read vInitRequest     Write vInitRequest;
  Property    EndTime            : TDateTime       Read vFinalRequest    Write vFinalRequest;
  Property    Secrets            : String          Read vSecrets         Write vSecrets;
 Published
  Property    TokenType         : TRESTDWTokenType Read vRDWTokenType    Write vRDWTokenType;
  Property    CryptType         : TRESTDWCryptType Read vRDWCryptType    Write SetCryptType;
  Property    Key               : String           Read vTokenName       Write vTokenName;
  Property    GetTokenEvent     : String           Read vGetTokenName    Write SetGetTokenName;
  Property    GetTokenRoutes    : TRESTDWRoutes    Read vDWRoutes        Write vDWRoutes;
  Property    TokenHash         : String           Read vTokenHash       Write SetTokenHash;
  Property    ServerSignature   : String           Read vServerSignature Write vServerSignature;
  Property    LifeCycle         : Integer          Read vLifeCycle       Write vLifeCycle;
End;

 TRESTDWAuthOptionBasic = Class(TRESTDWAuthOptionParam)
 Private
  vUserName,
  vPassword : String;
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
 Published
  Property    Username : String Read vUserName Write vUserName;
  Property    Password : String Read vPassword Write vPassword;
End;

 TRESTDWAuthOAuth = Class(TRESTDWAuthOptionParam)
 Private
  vRedirectURI,
  vGetTokenName,
  vGrantCodeName,
  vClientID,
  vToken,
  vGrantType,
  vClientSecret : String;
  vAutoBuildHex : Boolean;
  vExpiresin    : TDatetime;
  vRDWTokenType : TRESTDWAuthOptionTypes;
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
  Procedure   GetGrantCode;
  Procedure   GetGetToken;
 Published
  Property    TokenType      : TRESTDWAuthOptionTypes Read vRDWTokenType  Write vRDWTokenType;
  Property    AutoBuildHex   : Boolean             Read vAutoBuildHex  Write vAutoBuildHex;
  Property    Token          : String              Read vToken         Write vToken;
  Property    GrantCodeEvent : String              Read vGrantCodeName Write vGrantCodeName;
  Property    GrantType      : String              Read vGrantType     Write vGrantType;
  Property    GetTokenEvent  : String              Read vGetTokenName  Write vGetTokenName;
  Property    ClientID       : String              Read vClientID      Write vClientID;
  Property    ClientSecret   : String              Read vClientSecret  Write vClientSecret;
  Property    RedirectURI    : String              Read vRedirectURI   Write vRedirectURI;
  Property    Expires_in     : TDateTime           Read vExpiresin;
End;

 TRESTDWAuthOptionBearerClient = Class(TRESTDWAuthOptionParam)
 Private
  vGetTokenName,
  vSecrets,
  vTokenName,
  vToken           : String;
  vRDWTokenType    : TRESTDWTokenType;
  vInitRequest,
  vFinalRequest    : TDateTime;
  vAutoRenewToken,
  vAutoGetToken    : Boolean;
  vTokenRequest    : TRESTDWTokenRequest;
  Procedure ClearToken;
  Procedure SetToken(Value : String);
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
  Procedure   FromToken(TokenValue : String);
 Published
  Property    TokenType        : TRESTDWTokenType    Read vRDWTokenType    Write vRDWTokenType;
  Property    TokenRequestType : TRESTDWTokenRequest Read vTokenRequest    Write vTokenRequest;
  Property    GetTokenEvent    : String           Read vGetTokenName    Write vGetTokenName;
  Property    Key               : String          Read vTokenName       Write vTokenName;
  Property    BeginTime        : TDateTime        Read vInitRequest;
  Property    EndTime          : TDateTime        Read vFinalRequest;
  Property    Secrets          : String           Read vSecrets;
  Property    Token            : String           Read vToken           Write SetToken;
  Property    AutoGetToken     : Boolean          Read vAutoGetToken    Write vAutoGetToken;
  Property    AutoRenewToken   : Boolean          Read vAutoRenewToken  Write vAutoRenewToken;
End;

 TRESTDWAuthOptionTokenClient = Class(TRESTDWAuthOptionParam)
 Private
  vSecrets,
  vGetTokenName,
  vTokenName,
  vToken           : String;
  vTokenRequest    : TRESTDWTokenRequest;
  vRDWTokenType    : TRESTDWTokenType;
  vInitRequest,
  vFinalRequest    : TDateTime;
  vAutoRenewToken,
  vAutoGetToken    : Boolean;
  Procedure ClearToken;
  Procedure SetToken(Value : String);
 Protected
 Public
  Constructor Create;
  Procedure   Assign(Source  : TPersistent); Override;
  Procedure   FromToken(TokenValue : String);
 Published
  Property    TokenType        : TRESTDWTokenType    Read vRDWTokenType    Write vRDWTokenType;
  Property    TokenRequestType : TRESTDWTokenRequest Read vTokenRequest    Write vTokenRequest;
  Property    GetTokenEvent    : String           Read vGetTokenName    Write vGetTokenName;
  Property    Key              : String           Read vTokenName       Write vTokenName;
  Property    BeginTime        : TDateTime        Read vInitRequest;
  Property    EndTime          : TDateTime        Read vFinalRequest;
  Property    Secrets          : String           Read vSecrets;
  Property    Token            : String           Read vToken           Write SetToken;
  Property    AutoGetToken     : Boolean          Read vAutoGetToken    Write vAutoGetToken;
  Property    AutoRenewToken   : Boolean          Read vAutoRenewToken  Write vAutoRenewToken;
End;

 TRESTDWAuthOptionBearerServer = Class(TRESTDWAuthTokenParam)
 Private
 Protected
 Public
  Function    GetToken (aSecrets : String = '') : String;  Override;
  Function    FromToken(Value    : String)      : Boolean; Override;
End;

 TRESTDWAuthOptionTokenServer = Class(TRESTDWAuthTokenParam)
 Private
 Protected
 Public
  Function    GetToken(aSecrets  : String = '') : String;  Override;
  Function    FromToken(Value    : String)      : Boolean; Override;
End;

 TRESTDWServerAuthOptionParams = Class(TPersistent)
 Private
  FOwner                          : TPersistent;
  RDWAuthOptionParam              : TRESTDWAuthOptionParam;
  RDWAuthOption                   : TRESTDWAuthOption;
  Procedure   DestroyParam;
  Procedure   SetAuthOption(Value : TRESTDWAuthOption);
 Protected
  Function    GetOwner            : TPersistent; Override;
 Public
  Constructor Create(AOwner       : TPersistent);
  Procedure   Assign(Source       : TPersistent); Override;
  Destructor  Destroy;Override;
  Procedure   CopyServerAuthParams(Var Value : TRESTDWAuthOptionParam);
 Published
  Property AuthorizationOption    : TRESTDWAuthOption       Read RDWAuthOption      Write SetAuthOption;
  Property OptionParams           : TRESTDWAuthOptionParam  Read RDWAuthOptionParam Write RDWAuthOptionParam;
End;

 TRESTDWClientAuthOptionParams = Class(TPersistent)
 Private
  FOwner                          : TPersistent;
  RDWAuthOptionParam              : TRESTDWAuthOptionParam;
  RDWAuthOption                   : TRESTDWAuthOption;
  Procedure   DestroyParam;
  Procedure   SetAuthOption(Value : TRESTDWAuthOption);
 Protected
  Function    GetOwner            : TPersistent; Override;
 Public
  Constructor Create(AOwner       : TPersistent);
  Procedure   Assign(Source       : TPersistent); Override;
  Destructor  Destroy;Override;
 Published
  Property AuthorizationOption    : TRESTDWAuthOption       Read RDWAuthOption      Write SetAuthOption;
  Property OptionParams           : TRESTDWAuthOptionParam  Read RDWAuthOptionParam Write RDWAuthOptionParam;
End;

 TRESTDWAuthRequest = Class
 Private
  vToken : String;
 Public
  Constructor Create;
  Property Token : String Read vToken Write vToken;
End;

 TRESTDWDataUtils = Class
 Public
 Class Procedure ParseRESTURL           (Const Cmd       : String;
                                         Encoding        : TEncodeSelect;
                                         Var mark        : String
                                         {$IFDEF RESTDWLAZARUS}
                                         ;DatabaseCharSet: TDatabaseCharSet
                                         {$ENDIF};
                                         Var Result      : TRESTDWParams);Overload;
 Class Procedure ParseRESTURL           (UriParams       : String;
                                         Encoding        : TEncodeSelect;
                                         {$IFDEF RESTDWLAZARUS}
                                         DatabaseCharSet : TDatabaseCharSet;
                                         {$ENDIF}
                                         Var Result      : TRESTDWParams);Overload;
 Class Function  Result2JSON            (wsResult        : TResultErro): String;
 Class Procedure ParseWebFormsParams    (Params          : TStrings;
                                         Const URL,
                                         Query           : String;
                                         Var mark        : String;
                                         Encoding        : TEncodeSelect;
                                         {$IFDEF RESTDWLAZARUS}
                                         DatabaseCharSet : TDatabaseCharSet;
                                         {$ENDIF}
                                         Var Result      : TRESTDWParams;
                                         MethodType      : TRequestType = rtPost;
                                         ContentType     : String = cDefaultContentType); Overload;
 Class Procedure ParseWebFormsParams    (Var DWParams    : TRESTDWParams;
                                         WebParams       : TStrings;
                                         Encoding        : TEncodeSelect
                                         {$IFDEF RESTDWLAZARUS}
                                         ;DatabaseCharSet: TDatabaseCharSet
                                         {$ENDIF};
                                         MethodType      : TRequestType = rtPost);Overload;
 Class Function ParseDWParamsURL        (Const Cmd       : String;
                                         Encoding        : TEncodeSelect;
                                         Var ResultPR    : TRESTDWParams
                                         {$IFDEF RESTDWLAZARUS}
                                         ;DatabaseCharSet: TDatabaseCharSet
                                         {$ENDIF})       : Boolean;
 Class Function ParseBodyRawToDWParam   (Const BodyRaw   : String;
                                         Encoding        : TEncodeSelect;
                                         Var ResultPR    : TRESTDWParams
                                         {$IFDEF RESTDWLAZARUS}
                                         ;DatabaseCharSet: TDatabaseCharSet
                                         {$ENDIF})       : Boolean;Overload;
 Class Function ParseBodyRawToDWParam   (Const BodyRaw   : TStream;
                                         Encoding        : TEncodeSelect;
                                         Var ResultPR    : TRESTDWParams
                                         {$IFDEF RESTDWLAZARUS}
                                         ;DatabaseCharSet: TDatabaseCharSet
                                         {$ENDIF})       : Boolean;Overload;
 Class Function ParseBodyBinToDWParam   (Const BodyBin   : String;
                                         Encoding        : TEncodeSelect;
                                         Var ResultPR    : TRESTDWParams
                                         {$IFDEF RESTDWLAZARUS}
                                         ;DatabaseCharSet: TDatabaseCharSet
                                         {$ENDIF})       : Boolean;
 Class Function ParseFormParamsToDWParam(Const FormParams: String;
                                         Encoding        : TEncodeSelect;
                                         Var ResultPR    : TRESTDWParams
                                         {$IFDEF RESTDWLAZARUS}
                                         ;DatabaseCharSet: TDatabaseCharSet
                                         {$ENDIF})       : Boolean;
 End;

Function GettokenValue  (Value      : String) : String;
Function GetTokenType   (Value      : String) : TRESTDWTokenType;
Function CountExpression(Value      : String;
                         Expression : Char)   : Integer;
Function GetSecretsValue(Value      : String) : String;
Procedure BuildCORS(Routes                 : TRESTDWRoutes;
                    Var CORS_CustomHeaders : TStrings);

implementation

Uses uRESTDWJSONInterface;

Procedure BuildCORS(Routes                 : TRESTDWRoutes;
                    Var CORS_CustomHeaders : TStrings);
Var
 vStrAcceptedRoutes : String;
Begin
 vStrAcceptedRoutes := '';
 If Assigned(CORS_CustomHeaders) Then
  Begin
//   CORS_CustomHeaders.Clear;
   If crAll In Routes Then
    CORS_CustomHeaders.Add('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS')
   Else
    Begin
     If crGet in Routes Then
      Begin
       If vStrAcceptedRoutes <> '' Then
        vStrAcceptedRoutes := vStrAcceptedRoutes + ', GET'
       Else
        vStrAcceptedRoutes := 'GET';
      End;
     If crPost in Routes Then
      Begin
       If vStrAcceptedRoutes <> '' Then
        vStrAcceptedRoutes := vStrAcceptedRoutes + ', POST'
       Else
        vStrAcceptedRoutes := 'POST';
      End;
     If crPut in Routes Then
      Begin
       If vStrAcceptedRoutes <> '' Then
        vStrAcceptedRoutes := vStrAcceptedRoutes + ', PUT'
       Else
        vStrAcceptedRoutes := 'PUT';
      End;
     If crPatch in Routes Then
      Begin
       If vStrAcceptedRoutes <> '' Then
        vStrAcceptedRoutes := vStrAcceptedRoutes + ', PATCH'
       Else
        vStrAcceptedRoutes := 'PATCH';
      End;
     If crDelete in Routes Then
      Begin
       If vStrAcceptedRoutes <> '' Then
        vStrAcceptedRoutes := vStrAcceptedRoutes + ', DELETE'
       Else
        vStrAcceptedRoutes := 'DELETE';
      End;
     If crOption in Routes Then
      Begin
       If vStrAcceptedRoutes <> '' Then
        vStrAcceptedRoutes := vStrAcceptedRoutes + ', OPTION'
       Else
        vStrAcceptedRoutes := 'OPTION';
      End;
     If vStrAcceptedRoutes <> '' Then
      CORS_CustomHeaders.Add('Access-Control-Allow-Methods=' + vStrAcceptedRoutes);
    End;
  End;
End;

Function URLDecode(Const s : String) : String;
Var
 sAnsi,
 sUtf8    : String;
 sWide    : DWString;
 i, len   : Cardinal;
 ESC      : String;
 CharCode : Integer;
 c        : Char;
Begin
 sAnsi := PChar(s);
 SetLength(sUtf8, Length(sAnsi));
 i   := InitStrPos;
 len := InitStrPos;
 While (i <= Cardinal(Length(sAnsi))) Do
  Begin
   If (sAnsi[i] <> '%') Then
    Begin
     If (sAnsi[i] = '+') Then
      c := ' '
     Else
      c := sAnsi[i];
     sUtf8[len] := c;
     Inc(len);
    End
   Else
    Begin
     Inc(i);
     ESC := Copy(sAnsi, i, 2);
     Inc(i, 1);
     Try
      CharCode := StrToInt('$' + ESC);
      c := Char(CharCode);
      sUtf8[len] := c;
      Inc(len);
     Except
     End;
    End;
   Inc(i);
  End;
 Dec(len);
 SetLength(sUtf8, len);
 sWide := UTF8Decode(sUtf8);
 len := Length(sWide);
 Result := sWide;
End;

Function CountExpression(Value      : String;
                         Expression : Char): Integer;
Var
 I : Integer;
Begin
 Result := 0;
 For I := InitStrPos To Length(Value) - FinalStrPos Do
  Begin
   If Value[I] = Expression Then
    Inc(Result);
  End;
End;

Function GetTokenType (Value : String) : TRESTDWTokenType;
Begin
 Result := rdwTS;
 If Lowercase(Value) = 'jwt' Then
  Result := rdwJWT;
End;

Function GettokenValue(Value : String) : String;
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
Begin
 Result     := '';
 Try
  bJsonValue := TRESTDWJSONInterfaceObject.Create(Value);
  If bJsonValue.PairCount > 0 Then
   If Not bJsonValue.PairByName['token'].isnull Then
    Result     := bJsonValue.PairByName['token'].Value;
  FreeAndNil(bJsonValue);
 Except

 End;
End;

Function GetSecretsValue(Value : String) : String;
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
Begin
 Result     := '';
 Try
  bJsonValue := TRESTDWJSONInterfaceObject.Create(Value);
  If bJsonValue.PairCount > 0 Then
   If Not bJsonValue.PairByName['secrets'].isnull Then
    Result     := bJsonValue.PairByName['secrets'].Value;
  FreeAndNil(bJsonValue);
 Except

 End;
End;

Class Function TTokenValue.GetMD5(Const Value : String) : String;
Begin
 Try
  Result := MD5DigestToStr(MD5String(Value));
 Finally
 End;
End;

Class Function TTokenValue.ISO8601FromDateTime(Value : TDateTime) : String;
Begin
 Result := FormatDateTime('yyyy-mm-dd"T"hh":"nn":"ss', Value);
End;

Class Function TTokenValue.DateTimeFromISO8601(Value : String)    : TDateTime;
 Function ExtractNum(Value  : String;
                     a, len : Integer) : Integer;
 Begin
  Result := StrToIntDef(Copy(Value, a, len), 0);
 End;
 Function ISO8601StrToTime(Const S : String) : TDateTime;
 Begin
  If (Length(s) >= 8) And
         (s[3] = ':') Then
   Result := EncodeTime(ExtractNum(s, 1, 2),
                        ExtractNum(s, 4, 2),
                        ExtractNum(s, 7, 2), 0)
  Else
   Result := 0.0;
 End;
Var
 year,
 month,
 day   : Integer;
Begin
 If (Length(Value) >= 10)  And
         (Value[5]  = '-') And
         (Value[8]  = '-') Then
  Begin
   year      := ExtractNum(Value, 1, 4);
   month     := ExtractNum(Value, 6, 2);
   day       := ExtractNum(Value, 9, 2);
   If (year   = 0) And
      (month  = 0) And
      (day    = 0) Then
    Result   := 0.0
   Else
    Result   := EncodeDate(year, month, day);
   If (Length(Value) > 10)  And
         (Value[11]  = 'T') Then
    Result   := Result + ISO8601StrToTime(Copy(Value, 12, Length(Value)));
  End
 Else
  Result     := ISO8601StrToTime(Value);
End;

Constructor TTokenValue.Create;
Begin
 vCripto            := TCripto.Create;
 vRDWTokenType      := rdwTS;
 vRDWCryptType      := rdwAES256;
 vToken             := '';
 vServerSignature   := '';
 vSecrets           := '';
 vInitRequest       := 0;
 vFinalRequest      := 0;
End;

Destructor  TTokenValue.Destroy;
Begin
 FreeAndNil(vCripto);
 Inherited;
End;

Function TTokenValue.GetTokenType : String;
Begin
 Result := 'JWT';
 If vRDWTokenType = rdwTS Then
  Result := 'RDWTS'
 Else If vRDWTokenType = rdwPersonal Then
  Result := 'CUSTOM';
End;

Function TTokenValue.GetCryptType : String;
Begin
 Result := 'AES256';
 If vRDWCryptType = rdwHSHA256 Then
  Result := 'HS256'
 Else If vRDWCryptType = rdwRSA Then
  Result := 'RSA';
End;

Procedure TTokenValue.SetFinalRequest(Value : TDateTime);
Begin
 vFinalRequest := Value;
End;

Function TTokenValue.GetHeader : String;
Begin
 Result := Format('{"alg": "%s", "typ": "%s"}', [GetCryptType, GetTokenType]);
End;

Function TTokenValue.ToToken : String;
Var
 viss,
 vBuildData : String;
Begin
 Result      := ToJSON;
 viss        := '';
 If trim(vServerSignature) <> '' Then
  viss := Format('"iss":"%s", ', [vServerSignature]);
 vBuildData  := '';
 //Por enquanto igual mais no futuro haverá diferenças
 Case vRDWTokenType Of
  rdwTS,
  rdwPersonal : Begin
                 vCripto.Key := vTokenHash;
                 vMD5        := TTokenValue.GetMD5(vSecrets);
                 If vFinalRequest <> 0 Then
                  vBuildData := Format(cValueToken, [viss,
                                                     ISO8601FromDateTime(vFinalRequest),
                                                     ISO8601FromDateTime(vInitRequest),
                                                     EncodeStrings(Format(cValueKeyToken, [EncodeStrings(vSecrets{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}), vMD5])
                                                                   {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})])
                 Else
                  vBuildData := Format(cValueTokenNoLife, [viss,
                                                           ISO8601FromDateTime(vInitRequest),
                                                           EncodeStrings(Format(cValueKeyToken, [EncodeStrings(vSecrets{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}), vMD5])
                                                                         {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})]);
                 Result     := Result + '.' + EncodeStrings(vBuildData{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
                 Result     := Format(cTokenStringRDWTS, [Result + '.' + vCripto.Encrypt(Result)]);
                End;
  rdwJWT      : Begin
                 vCripto.Key := vTokenHash;
                 vMD5        := TTokenValue.GetMD5(vSecrets);
                 If vFinalRequest <> 0 Then
                  vBuildData := Format(cValueToken, [viss,
                                                     IntToStr(DateTimeToUnix(vFinalRequest, False)),
                                                     IntToStr(DateTimeToUnix(vInitRequest, False)),
                                                     EncodeStrings(Format(cValueKeyToken, [EncodeStrings(vSecrets{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}), vMD5])
                                                                   {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})])
                 Else
                  vBuildData := Format(cValueTokenNoLife, [viss,
                                                           IntToStr(DateTimeToUnix(vInitRequest, False)),
                                                           EncodeStrings(Format(cValueKeyToken, [EncodeStrings(vSecrets{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}), vMD5])
                                                                         {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})]);
                 Result     := Result + '.' + EncodeStrings(vBuildData{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
                 Result     := Format(cTokenStringRDWTS, [Result + '.' + vCripto.Encrypt(Result)]);
                End;
 End;
End;

Function TTokenValue.ToJSON  : String;
Begin
  Result := EncodeStrings(GetHeader{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
End;

Procedure TTokenValue.SetSecrets  (Value : String);
Begin
 vSecrets := Value;
End;

Procedure TTokenValue.SetTokenHash(Token : String);
Begin
 vTokenHash  := Token;
 vCripto.Key := vTokenHash;
End;

Procedure TRESTDWAuthOAuth.GetGetToken;
Begin

End;

Procedure TRESTDWAuthOAuth.GetGrantCode;
Begin

End;

Procedure TRESTDWAuthOAuth.Assign(Source: TPersistent);
Var
 Src : TRESTDWAuthOAuth;
Begin
 If Source is TRESTDWAuthOAuth Then
  Begin
   Src                := TRESTDWAuthOAuth(Source);
   vAutoBuildHex      := Src.AutoBuildHex;
   vClientID          := Src.ClientID;
   vClientSecret      := Src.ClientSecret;
   vGrantCodeName     := Src.GrantCodeEvent;
   vGetTokenName      := Src.GetTokenEvent;
  End
 Else
  Inherited Assign(Source);
End;

Procedure TRESTDWAuthOptionBasic.Assign(Source: TPersistent);
Var
 Src : TRESTDWAuthOptionBasic;
Begin
 If Source is TRESTDWAuthOptionBasic Then
  Begin
   Src                := TRESTDWAuthOptionBasic(Source);
   vUserName          := Src.Username;
   vPassword          := Src.Password;
  End
 Else
  Inherited Assign(Source);
End;

Procedure TRESTDWAuthOptionTokenClient.FromToken(TokenValue : String);
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
 vTokenB,
 vHeader,
 vBody      : String;
Begin
 vTokenB     := TokenValue;
 If Trim(vTokenB) <> '' Then
  Begin
   vTokenB     := GetTokenString(TokenValue);
   If vTokenB = '' Then
    vTokenB     := GetBearerString(TokenValue);
   If vTokenB = '' Then
    vTokenB     := TokenValue;
  End;
 vToken := vTokenB;
 Try
  vHeader   := Copy(vTokenB, InitStrPos, Pos('.', vTokenB) - 1);
  Delete(vTokenB, InitStrPos, Pos('.', vTokenB));
  vBody     := Copy(vTokenB, InitStrPos, Pos('.', vTokenB) - 1);
  //Read Header
  If Trim(vHeader) <> '' Then
   Begin
    bJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(vHeader{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));
    If bJsonValue.PairCount > 0 Then
     Begin
      If Not bJsonValue.PairByName['typ'].isnull Then
       vRDWTokenType := GetTokenType(bJsonValue.PairByName['typ'].Value);
     End;
    FreeAndNil(bJsonValue);
   End;
  //Read Body
  If Trim(vBody) <> '' Then
   Begin
    bJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(vBody{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));
    If bJsonValue.PairCount > 0 Then
     Begin
      If (Not (bJsonValue.PairByName['iat'].isnull)) And
         (bJsonValue.PairByName['iat'].Value <> '')  Then
       Begin
        If      vRDWTokenType = rdwTS Then
         vInitRequest := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['iat'].Value)
        Else If vRDWTokenType = rdwJWT Then
         vInitRequest := UnixToDateTime(StrToInt64(bJsonValue.PairByName['iat'].Value)
                         {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXE6UP)}
                         , False{$IFEND});
       End;
      If (Not (bJsonValue.PairByName['exp'].isnull)) And
         (bJsonValue.PairByName['exp'].Value <> '') Then
       Begin
        If      vRDWTokenType = rdwTS Then
         vFinalRequest := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['exp'].Value)
        Else If vRDWTokenType = rdwJWT Then
         vFinalRequest := UnixToDateTime(StrToInt64(bJsonValue.PairByName['exp'].Value)
                          {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXE6UP)}
                         , False{$IFEND});
       End;
      If Not bJsonValue.PairByName['secrets'].isnull Then
       vSecrets := DecodeStrings(bJsonValue.PairByName['secrets'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     End;
    FreeAndNil(bJsonValue);
   End;
 Except

 End;
End;

Procedure TRESTDWAuthOptionTokenClient.Assign(Source: TPersistent);
Var
 Src : TRESTDWAuthOptionTokenClient;
Begin
 If Source is TRESTDWAuthOptionTokenClient Then
  Begin
   Src           := TRESTDWAuthOptionTokenClient(Source);
   vToken        := Src.Token;
  End
 Else
  Inherited Assign(Source);
End;

Function TRESTDWAuthOptionTokenServer.FromToken(Value : String)    : Boolean;
Var
 vHeader,
 vBody,
 vStringComparer : String;
 vTokenValue     : TTokenValue;
 Function ReadHeader(Value : String) : Boolean;
 Var
  bJsonValue     : TRESTDWJSONInterfaceObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue    := TRESTDWJSONInterfaceObject.Create(Value);
   If bJsonValue.PairCount = 2 Then
    Begin
     Result      := (Lowercase(bJsonValue.Pairs[0].Name) = 'alg') And
                    (Lowercase(bJsonValue.Pairs[1].Name) = 'typ');
     If Result Then
      Begin
       vRDWTokenType := GetTokenType(bJsonValue.Pairs[1].Value);
       vRDWCryptType := GetCryptType(bJsonValue.Pairs[0].Value);
      End;
    End;
  Except

  End;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
 End;
 Function ReadBody(Value : String) : Boolean;
 Var
  bJsonValue     : TRESTDWJSONInterfaceObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue            := TRESTDWJSONInterfaceObject.Create(Value);
   Result                := Trim(bJsonValue.PairByName['iss'].Name) <> '';
   If Result Then
    Begin
     Result              := vServerSignature = vTokenValue.vCripto.Decrypt(bJsonValue.PairByName['iss'].Value);
     If Result Then
      Begin
       Result := False;
       vServerSignature  := vTokenValue.vCripto.Decrypt(bJsonValue.PairByName['iss'].Value);
       Result            := Trim(bJsonValue.PairByName['iat'].Name) <> '';
       If Result Then
        Begin
         Result          := False;
         If vRDWTokenType = rdwTS Then
          vInitRequest   := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['iat'].Value)
         Else
          vInitRequest   := UnixToDateTime(StrToInt64(bJsonValue.PairByName['iat'].Value)
                            {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXE6UP)}
                            , False{$IFEND});
        End;
       Result            := Trim(bJsonValue.PairByName['secrets'].Name) <> '';
       If Result Then
        vSecrets         := DecodeStrings(bJsonValue.PairByName['secrets'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
       If Trim(bJsonValue.PairByName['exp'].Name) <> '' Then
        Begin
         Result          := False;
         If vRDWTokenType = rdwTS Then
          vFinalRequest  := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['exp'].Value)
         Else
          vFinalRequest  := UnixToDateTime(StrToInt64(bJsonValue.PairByName['exp'].Value)
                            {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXE6UP)}
                            , False{$IFEND});
         Result          := Now < vFinalRequest;
        End;
      End;
    End
   Else
    Result               := LifeCycle = 0;
  Except

  End;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
 End;
Begin
 vHeader         := '';
 vBody           := '';
 vStringComparer := '';
 Value           := StringReplace(Value, ' ', '+', [rfReplaceAll]); //Remove espaços na Token e add os caracteres "+" em seu lugar
 vHeader         := Copy(Value, InitStrPos, Pos('.', Value) -1);
 Delete(Value, InitStrPos, Pos('.', Value));
 vBody           := Copy(Value, InitStrPos, Pos('.', Value) -1);
 Delete(Value, InitStrPos, Pos('.', Value));
 vStringComparer := Value;
 Result          := (Trim(vHeader) <> '') And (Trim(vBody) <> '') And (Trim(vStringComparer) <> '');
 If Result Then
  Begin
   Result                   := ReadHeader(DecodeStrings(vHeader{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));
   If Result Then
    Begin
     Result                 := False;
     vTokenValue            := TTokenValue.Create;
     Try
      vTokenValue.TokenHash := vTokenHash;
      vTokenValue.CryptType := vRDWCryptType;
      vStringComparer       := vTokenValue.vCripto.Decrypt(vStringComparer);
      Result                := vStringComparer = vHeader + '.' + vBody;
      If Result Then
       Begin
        Result              := False;
        vHeader             := DecodeStrings(vHeader                 {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        vBody               := DecodeStrings(vBody                   {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        Secrets             := DecodeStrings(GetSecretsValue(vBody)  {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        Secrets             := DecodeStrings(GetSecretsValue(Secrets){$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        Result              := ReadBody(vBody);
       End;
     Finally
      FreeAndNil(vTokenValue);
     End;
    End;
  End;
End;

Function TRESTDWAuthOptionTokenServer.GetToken(aSecrets   : String = '') : String;
Var
 vTokenValue : TTokenValue;
Begin
 vTokenValue               := TTokenValue.Create;
 vTokenValue.TokenHash     := vTokenHash;
 vTokenValue.vRDWTokenType := TokenType;
 vTokenValue.CryptType     := vRDWCryptType;
 If Trim(ServerSignature)  <> '' Then
  vTokenValue.Iss          := vTokenValue.vCripto.Encrypt(ServerSignature);
 vTokenValue.Secrets       := aSecrets;
 vTokenValue.BeginTime     := Now;
 If vLifeCycle > 0 Then
  vTokenValue.EndTime      := IncSecond(vTokenValue.BeginTime, vLifeCycle);
 Try
  Result                   := vTokenValue.ToToken;
 Finally
  FreeAndNil(vTokenValue);
 End;
End;

Procedure TRESTDWAuthOptionBearerClient.FromToken(TokenValue : String);
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
 vHeader,
 vBody      : String;
Begin
 vToken     := TokenValue;
 Try
  vHeader   := Copy(TokenValue, InitStrPos, Pos('.', TokenValue) - 1);
  Delete(TokenValue, InitStrPos, Pos('.', TokenValue));
  vBody     := Copy(TokenValue, InitStrPos, Pos('.', TokenValue) - 1);
  //Read Header
  If Trim(vHeader) <> '' Then
   Begin
    bJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(vHeader{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));
    If bJsonValue.PairCount > 0 Then
     Begin
      If Not bJsonValue.PairByName['typ'].isnull Then
       vRDWTokenType := GetTokenType(bJsonValue.PairByName['typ'].Value);
     End;
    FreeAndNil(bJsonValue);
   End;
  //Read Body
  If Trim(vBody) <> '' Then
   Begin
    bJsonValue := TRESTDWJSONInterfaceObject.Create(DecodeStrings(vBody{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));
    If bJsonValue.PairCount > 0 Then
     Begin
      If Not bJsonValue.PairByName['iat'].isnull Then
       Begin
        If      vRDWTokenType = rdwTS Then
         vInitRequest := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['iat'].Value)
        Else If vRDWTokenType = rdwJWT Then
         vInitRequest := UnixToDateTime(StrToInt64(bJsonValue.PairByName['iat'].Value)
                         {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXE6UP)}
                         , False{$IFEND});
       End;
      If Not bJsonValue.PairByName['exp'].isnull Then
       Begin
        If      vRDWTokenType = rdwTS Then
         vFinalRequest := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['exp'].Value)
        Else If vRDWTokenType = rdwJWT Then
         vFinalRequest := UnixToDateTime(StrToInt64(bJsonValue.PairByName['exp'].Value)
                          {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXE6UP)}
                          , False{$IFEND});
       End;
      If Not bJsonValue.PairByName['secrets'].isnull Then
       vSecrets := DecodeStrings(bJsonValue.PairByName['secrets'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     End;
    FreeAndNil(bJsonValue);
   End;
 Except

 End;
End;

Procedure TRESTDWAuthOptionBearerClient.Assign(Source: TPersistent);
Var
 Src : TRESTDWAuthOptionBearerClient;
Begin
 If Source is TRESTDWAuthOptionBearerClient Then
  Begin
   Src           := TRESTDWAuthOptionBearerClient(Source);
   vToken        := Src.Token;
  End
 Else
  Inherited Assign(Source);
End;

Function TRESTDWAuthOptionBearerServer.FromToken(Value    : String)    : Boolean;
Var
 vHeader,
 vBody,
 vStringComparer : String;
 vTokenValue     : TTokenValue;
 Function ReadHeader(Value : String) : Boolean;
 Var
  bJsonValue     : TRESTDWJSONInterfaceObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue    := TRESTDWJSONInterfaceObject.Create(Value);
   If bJsonValue.PairCount = 2 Then
    Begin
     Result      := (Lowercase(bJsonValue.Pairs[0].Name) = 'alg') And
                    (Lowercase(bJsonValue.Pairs[1].Name) = 'typ');
     If Result Then
      Begin
       vRDWTokenType := GetTokenType(bJsonValue.Pairs[1].Value);
       vRDWCryptType := GetCryptType(bJsonValue.Pairs[0].Value);
      End;
    End;
  Except

  End;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
 End;
 Function ReadBody(Value : String) : Boolean;
 Var
  bJsonValue     : TRESTDWJSONInterfaceObject;
 Begin
  bJsonValue     := Nil;
  Result         := False;
  Try
   bJsonValue            := TRESTDWJSONInterfaceObject.Create(Value);
   Result                := Trim(bJsonValue.PairByName['iss'].Name) <> '';
   If Result Then
    Begin
     Result              := vServerSignature = vTokenValue.vCripto.Decrypt(bJsonValue.PairByName['iss'].Value);
     If Result Then
      Begin
       Result := False;
       vServerSignature  := vTokenValue.vCripto.Decrypt(bJsonValue.PairByName['iss'].Value);
       Result            := Trim(bJsonValue.PairByName['iat'].Name) <> '';
       If Result Then
        Begin
         Result          := False;
         If vRDWTokenType = rdwTS Then
          vInitRequest   := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['iat'].Value)
         Else
          vInitRequest   := UnixToDateTime(StrToInt64(bJsonValue.PairByName['iat'].Value)
                            {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXE6UP)}
                            , False{$IFEND});
        End;
       Result            := Trim(bJsonValue.PairByName['secrets'].Name) <> '';
       If Result Then
        vSecrets         := DecodeStrings(bJsonValue.PairByName['secrets'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
       If Trim(bJsonValue.PairByName['exp'].Name) <> '' Then
        Begin
         Result          := False;
         If vRDWTokenType = rdwTS Then
          vFinalRequest  := TTokenValue.DateTimeFromISO8601(bJsonValue.PairByName['exp'].Value)
         Else
          vFinalRequest  := UnixToDateTime(StrToInt64(bJsonValue.PairByName['exp'].Value)
                            {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXE6UP)}
                            , False{$IFEND});
         Result          := Now < vFinalRequest;
        End;
      End;
    End;
  Except

  End;
  If Assigned(bJsonValue) Then
   FreeAndNil(bJsonValue);
 End;
Begin
 vHeader         := '';
 vBody           := '';
 vStringComparer := '';
 vHeader         := Copy(Value, InitStrPos, Pos('.', Value) -1);
 Delete(Value, InitStrPos, Pos('.', Value));
 vBody           := Copy(Value, InitStrPos, Pos('.', Value) -1);
 Delete(Value, InitStrPos, Pos('.', Value));
 vStringComparer := Value;
 Result          := (Trim(vHeader) <> '') And (Trim(vBody) <> '') And (Trim(vStringComparer) <> '');
 If Result Then
  Begin
   Result                   := ReadHeader(DecodeStrings(vHeader{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));
   If Result Then
    Begin
     Result                 := False;
     vTokenValue            := TTokenValue.Create;
     Try
      vTokenValue.TokenHash := vTokenHash;
      vTokenValue.CryptType := vRDWCryptType;
      vStringComparer       := vTokenValue.vCripto.Decrypt(vStringComparer);
      Result                := vStringComparer = vHeader + '.' + vBody;
      If Result Then
       Begin
        Result              := False;
        vHeader             := DecodeStrings(vHeader                 {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        vBody               := DecodeStrings(vBody                   {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        Secrets             := DecodeStrings(GetSecretsValue(vBody)  {$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        Secrets             := DecodeStrings(GetSecretsValue(Secrets){$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
        Result              := ReadBody(vBody);
       End;
     Finally
      FreeAndNil(vTokenValue);
     End;
    End;
  End;
End;

Function TRESTDWAuthOptionBearerServer.GetToken(aSecrets : String = '') : String;
Var
 vTokenValue : TTokenValue;
Begin
 vTokenValue           := TTokenValue.Create;
 vTokenValue.TokenHash := vTokenHash;
 vTokenValue.CryptType := vRDWCryptType;
 If Trim(ServerSignature) <> '' Then
  vTokenValue.Iss      := vTokenValue.vCripto.Encrypt(ServerSignature);
 vTokenValue.Secrets   := aSecrets;
 vTokenValue.BeginTime := Now;
 If vLifeCycle > 0 Then
  vTokenValue.EndTime  := IncSecond(vTokenValue.BeginTime, vLifeCycle);
 Try
  Result               := vTokenValue.ToToken;
 Finally
  FreeAndNil(vTokenValue);
 End;
End;

Destructor TRESTDWClientAuthOptionParams.Destroy;
Begin
 DestroyParam;
 Inherited;
End;

Procedure TRESTDWServerAuthOptionParams.CopyServerAuthParams(Var Value : TRESTDWAuthOptionParam);
Begin
 If RDWAuthOptionParam is TRESTDWAuthTokenParam Then
  Begin
   If Value <> Nil Then
    FreeAndNil(Value);
   Value                                        := TRESTDWAuthTokenParam.Create;
   TRESTDWAuthTokenParam(Value).TokenType       := TRESTDWAuthTokenParam(RDWAuthOptionParam).TokenType;
   TRESTDWAuthTokenParam(Value).CryptType       := TRESTDWAuthTokenParam(RDWAuthOptionParam).CryptType;
   TRESTDWAuthTokenParam(Value).GetTokenEvent   := TRESTDWAuthTokenParam(RDWAuthOptionParam).GetTokenEvent;
   TRESTDWAuthTokenParam(Value).TokenHash       := TRESTDWAuthTokenParam(RDWAuthOptionParam).TokenHash;
   TRESTDWAuthTokenParam(Value).ServerSignature := TRESTDWAuthTokenParam(RDWAuthOptionParam).ServerSignature;
   TRESTDWAuthTokenParam(Value).LifeCycle       := TRESTDWAuthTokenParam(RDWAuthOptionParam).LifeCycle;
   TRESTDWAuthTokenParam(Value).AuthDialog               := TRESTDWAuthTokenParam(RDWAuthOptionParam).AuthDialog;
   TRESTDWAuthTokenParam(Value).Key                      := TRESTDWAuthTokenParam(RDWAuthOptionParam).Key;
   TRESTDWAuthTokenParam(Value).CustomDialogAuthMessage  := TRESTDWAuthTokenParam(RDWAuthOptionParam).CustomDialogAuthMessage;
   TRESTDWAuthTokenParam(Value).Custom404TitleMessage    := TRESTDWAuthTokenParam(RDWAuthOptionParam).Custom404TitleMessage;
   TRESTDWAuthTokenParam(Value).Custom404BodyMessage     := TRESTDWAuthTokenParam(RDWAuthOptionParam).Custom404BodyMessage;
   TRESTDWAuthTokenParam(Value).Custom404FooterMessage   := TRESTDWAuthTokenParam(RDWAuthOptionParam).Custom404FooterMessage;
   TRESTDWAuthTokenParam(Value).CustomAuthErrorPage.Text := TRESTDWAuthTokenParam(RDWAuthOptionParam).CustomAuthErrorPage.Text;
  End
 Else If RDWAuthOptionParam is TRESTDWAuthOptionBasic Then
  Begin
   If Value <> Nil Then
    FreeAndNil(Value);
   Value                                                  := TRESTDWAuthOptionBasic.Create;
   TRESTDWAuthOptionBasic(Value).Username                 := TRESTDWAuthOptionBasic(RDWAuthOptionParam).Username;
   TRESTDWAuthOptionBasic(Value).Password                 := TRESTDWAuthOptionBasic(RDWAuthOptionParam).Password;
   TRESTDWAuthOptionBasic(Value).AuthDialog               := TRESTDWAuthOptionBasic(RDWAuthOptionParam).AuthDialog;
   TRESTDWAuthOptionBasic(Value).CustomDialogAuthMessage  := TRESTDWAuthOptionBasic(RDWAuthOptionParam).CustomDialogAuthMessage;
   TRESTDWAuthOptionBasic(Value).Custom404TitleMessage    := TRESTDWAuthOptionBasic(RDWAuthOptionParam).Custom404TitleMessage;
   TRESTDWAuthOptionBasic(Value).Custom404BodyMessage     := TRESTDWAuthOptionBasic(RDWAuthOptionParam).Custom404BodyMessage;
   TRESTDWAuthOptionBasic(Value).Custom404FooterMessage   := TRESTDWAuthOptionBasic(RDWAuthOptionParam).Custom404FooterMessage;
   TRESTDWAuthOptionBasic(Value).CustomAuthErrorPage.Text := TRESTDWAuthOptionBasic(RDWAuthOptionParam).CustomAuthErrorPage.Text;
  End;
End;

Destructor TRESTDWServerAuthOptionParams.Destroy;
Begin
 DestroyParam;
 Inherited;
End;

Procedure TRESTDWClientAuthOptionParams.Assign(Source: TPersistent);
Var
 Src : TRESTDWClientAuthOptionParams;
Begin
 If Source is TRESTDWClientAuthOptionParams Then
  Begin
   Src := TRESTDWClientAuthOptionParams(Source);
   SetAuthOption(Src.AuthorizationOption);
   Case RDWAuthOption Of
    rdwAOBasic  : Begin
                   TRESTDWAuthOptionBasic(RDWAuthOptionParam).Username := TRESTDWAuthOptionBasic(Src.OptionParams).Username;
                   TRESTDWAuthOptionBasic(RDWAuthOptionParam).Password := TRESTDWAuthOptionBasic(Src.OptionParams).Password;
                  End;
    rdwAOBearer : Begin
                   TRESTDWAuthOptionBearerClient(RDWAuthOptionParam).TokenType        := TRESTDWAuthOptionBearerClient(Src.OptionParams).TokenType;
                   TRESTDWAuthOptionBearerClient(RDWAuthOptionParam).TokenRequestType := TRESTDWAuthOptionBearerClient(Src.OptionParams).TokenRequestType;
                   TRESTDWAuthOptionBearerClient(RDWAuthOptionParam).Token            := TRESTDWAuthOptionBearerClient(Src.OptionParams).Token;
                   TRESTDWAuthOptionBearerClient(RDWAuthOptionParam).GetTokenEvent    := TRESTDWAuthOptionBearerClient(Src.OptionParams).GetTokenEvent;
                   // Eloy
                   TRESTDWAuthOptionBearerClient(RDWAuthOptionParam).AutoGetToken     := TRESTDWAuthOptionBearerClient(Src.OptionParams).AutoGetToken;
                   TRESTDWAuthOptionBearerClient(RDWAuthOptionParam).AutoRenewToken   := TRESTDWAuthOptionBearerClient(Src.OptionParams).AutoRenewToken;
                   TRESTDWAuthOptionBearerClient(RDWAuthOptionParam).AuthDialog       := TRESTDWAuthOptionBearerClient(Src.OptionParams).AuthDialog;
                   TRESTDWAuthOptionBearerClient(RDWAuthOptionParam).Key              := TRESTDWAuthOptionBearerClient(Src.OptionParams).Key;
                  End;
    rdwAOToken  : Begin
                   TRESTDWAuthOptionTokenClient(RDWAuthOptionParam).TokenType        := TRESTDWAuthOptionTokenClient(Src.OptionParams).TokenType;
                   TRESTDWAuthOptionTokenClient(RDWAuthOptionParam).TokenRequestType := TRESTDWAuthOptionTokenClient(Src.OptionParams).TokenRequestType;
                   TRESTDWAuthOptionTokenClient(RDWAuthOptionParam).Token            := TRESTDWAuthOptionTokenClient(Src.OptionParams).Token;
                   TRESTDWAuthOptionTokenClient(RDWAuthOptionParam).GetTokenEvent    := TRESTDWAuthOptionTokenClient(Src.OptionParams).GetTokenEvent;
                   // Eloy
                   TRESTDWAuthOptionTokenClient(RDWAuthOptionParam).AutoGetToken     := TRESTDWAuthOptionTokenClient(Src.OptionParams).AutoGetToken;
                   TRESTDWAuthOptionTokenClient(RDWAuthOptionParam).AutoRenewToken   := TRESTDWAuthOptionTokenClient(Src.OptionParams).AutoRenewToken;
                   TRESTDWAuthOptionTokenClient(RDWAuthOptionParam).AuthDialog       := TRESTDWAuthOptionTokenClient(Src.OptionParams).AuthDialog;
                   TRESTDWAuthOptionTokenClient(RDWAuthOptionParam).Key              := TRESTDWAuthOptionTokenClient(Src.OptionParams).Key;
                  End;
   End;
  End
 Else
  Inherited Assign(Source);
End;

Procedure TRESTDWServerAuthOptionParams.Assign(Source: TPersistent);
Var
 Src : TRESTDWServerAuthOptionParams;
Begin
 If Source is TRESTDWServerAuthOptionParams Then
  Begin
   Src                := TRESTDWServerAuthOptionParams(Source);
   SetAuthOption(Src.AuthorizationOption);
   Case RDWAuthOption Of
    rdwAOBasic  : Begin
                   TRESTDWAuthOptionBasic(RDWAuthOptionParam).Username := TRESTDWAuthOptionBasic(Src.OptionParams).Username;
                   TRESTDWAuthOptionBasic(RDWAuthOptionParam).Password := TRESTDWAuthOptionBasic(Src.OptionParams).Password;
                  End;
    rdwAOBearer : Begin
                   TRESTDWAuthOptionBearerServer(RDWAuthOptionParam).TokenType       := TRESTDWAuthOptionBearerServer(Src.OptionParams).TokenType;
                   TRESTDWAuthOptionBearerServer(RDWAuthOptionParam).CryptType       := TRESTDWAuthOptionBearerServer(Src.OptionParams).CryptType;
                   TRESTDWAuthOptionBearerServer(RDWAuthOptionParam).GetTokenEvent   := TRESTDWAuthOptionBearerServer(Src.OptionParams).GetTokenEvent;
                   TRESTDWAuthOptionBearerServer(RDWAuthOptionParam).TokenHash       := TRESTDWAuthOptionBearerServer(Src.OptionParams).TokenHash;
                   TRESTDWAuthOptionBearerServer(RDWAuthOptionParam).ServerSignature := TRESTDWAuthOptionBearerServer(Src.OptionParams).ServerSignature;
                   TRESTDWAuthOptionBearerServer(RDWAuthOptionParam).LifeCycle       := TRESTDWAuthOptionBearerServer(Src.OptionParams).LifeCycle;
                  End;
    rdwAOToken  : Begin
                   TRESTDWAuthOptionTokenServer(RDWAuthOptionParam).TokenType       := TRESTDWAuthOptionTokenServer(Src.OptionParams).TokenType;
                   TRESTDWAuthOptionTokenServer(RDWAuthOptionParam).CryptType       := TRESTDWAuthOptionTokenServer(Src.OptionParams).CryptType;
                   TRESTDWAuthOptionTokenServer(RDWAuthOptionParam).GetTokenEvent   := TRESTDWAuthOptionTokenServer(Src.OptionParams).GetTokenEvent;
                   TRESTDWAuthOptionTokenServer(RDWAuthOptionParam).TokenHash       := TRESTDWAuthOptionTokenServer(Src.OptionParams).TokenHash;
                   TRESTDWAuthOptionTokenServer(RDWAuthOptionParam).ServerSignature := TRESTDWAuthOptionTokenServer(Src.OptionParams).ServerSignature;
                   TRESTDWAuthOptionTokenServer(RDWAuthOptionParam).LifeCycle       := TRESTDWAuthOptionTokenServer(Src.OptionParams).LifeCycle;
                  End;
   End;
  End
 Else
  Inherited Assign(Source);
End;

Constructor TRESTDWAuthOAuth.Create;
Begin
 inherited;
 vClientID      := '';
 vClientSecret  := '';
 vToken         := '';
 vRedirectURI   := '';
 vGrantType     := 'client_credentials';
 vGetTokenName  := 'access-token';
 vGrantCodeName := 'authorize';
 vAutoBuildHex  := False;
 vExpiresin     := 0;
 vRDWTokenType  := rdwOATBasic;
End;

Constructor TRESTDWAuthOptionBasic.Create;
Begin
 inherited;
 vUserName := cDefaultBasicAuthUser;
 vPassword := cDefaultBasicAuthPassword;
End;

Constructor TRESTDWAuthOptionTokenClient.Create;
Begin
 inherited;
 vToken          := '';
 vRDWTokenType   := rdwJWT;
 vTokenRequest   := rdwtHeader;
 vSecrets        := '';
 vGetTokenName   := 'GetToken';
 vTokenName      := 'token';
 vAutoGetToken   := True;
 vAutoRenewToken := True;
 vInitRequest    := 0;
 vFinalRequest   := 0;
End;

Constructor TRESTDWAuthTokenParam.Create;
Begin
 inherited;
 vTokenHash       := 'RDWTS_HASH0011';
 vServerSignature := 'RESTRESTDWServer01';
 vGetTokenName    := 'GetToken';
 vTokenName       := 'token';
 vLifeCycle       := 1800;//30 Minutos
 vRDWTokenType    := rdwJWT;
 vRDWCryptType    := rdwHSHA256;
 vServerSignature := '';
 vInitRequest     := 0;
 vFinalRequest    := 0;
 vSecrets         := '';
 vDWRoutes        := [crAll];
End;

Procedure TRESTDWAuthTokenParam.Assign(Source: TPersistent);
Var
 Src : TRESTDWAuthTokenParam;
Begin
 If Source is TRESTDWAuthTokenParam Then
  Begin
   Src             := TRESTDWAuthTokenParam(Source);
   TokenType       := Src.TokenType;
   CryptType       := Src.CryptType;
   GetTokenEvent   := Src.GetTokenEvent;
   TokenHash       := Src.TokenHash;
   ServerSignature := Src.ServerSignature;
   LifeCycle       := Src.LifeCycle;
  End
 Else
  Inherited Assign(Source);
End;

Destructor TRESTDWAuthTokenParam.Destroy;
Begin
 Inherited;
End;

Procedure TRESTDWAuthTokenParam.SetTokenHash(Token : String);
Begin
 vTokenHash := Token;
End;

Function TRESTDWAuthTokenParam.GetTokenType   (Value : String) : TRESTDWTokenType;
Begin
 Result := rdwTS;
 If Lowercase(Value) = 'jwt' Then
  Result := rdwJWT
 Else If Lowercase(Value) = 'rdwcustom' Then
  Result := rdwPersonal;
End;

Function TRESTDWAuthTokenParam.GetCryptType   (Value : String) : TRESTDWCryptType;
Begin
 Result := rdwAES256;
 If Lowercase(Value) = 'hs256' Then
  Result := rdwHSHA256
 Else If Lowercase(Value) = 'rsa' Then
  Result := rdwRSA;
End;

Procedure TRESTDWAuthTokenParam.SetCryptType   (Value : TRESTDWCryptType);
Begin
 vRDWCryptType := Value;
End;

Procedure TRESTDWAuthTokenParam.SetGetTokenName(Value : String);
Begin
 If Length(Value) > 0 Then
  vGetTokenName := Value
 Else
  Raise Exception.Create('Invalid GetTokenName');
End;

Procedure TRESTDWAuthOptionTokenClient.ClearToken;
Begin
 vSecrets      := '';
 vToken        := '';
 vInitRequest  := 0;
 vFinalRequest := 0;
End;

Procedure TRESTDWAuthOptionTokenClient.SetToken(Value : String);
Begin
 ClearToken;
 vToken        := Value;
 If vToken <> '' Then
  FromToken(vToken);
End;

Procedure TRESTDWAuthOptionBearerClient.ClearToken;
Begin
 vSecrets      := '';
 vToken        := '';
 vInitRequest  := 0;
 vFinalRequest := 0;
End;

Procedure TRESTDWAuthOptionBearerClient.SetToken(Value : String);
Begin
 ClearToken;
 vToken        := Value;
 If vToken <> '' Then
  FromToken(vToken)
End;

Constructor TRESTDWAuthOptionBearerClient.Create;
Begin
 inherited;
 vRDWTokenType   := rdwTS;
 vTokenRequest   := rdwtHeader;
 vToken          := '';
 vSecrets        := '';
 vGetTokenName   := 'GetToken';
 vTokenName      := 'token';
 vAutoGetToken   := True;
 vAutoRenewToken := True;
 vInitRequest    := 0;
 vFinalRequest   := 0;
End;

Constructor TRESTDWAuthRequest.Create;
Begin
 vToken := '';
End;

Constructor TRESTDWClientAuthOptionParams.Create(AOwner: TPersistent);
Begin
 inherited Create;
 FOwner             := AOwner;
 RDWAuthOptionParam := Nil;
 RDWAuthOption      := rdwAONone;
End;

Constructor TRESTDWServerAuthOptionParams.Create(AOwner: TPersistent);
Begin
 inherited Create;
 FOwner             := AOwner;
 RDWAuthOptionParam := Nil;
 RDWAuthOption      := rdwAONone;
End;

Procedure TRESTDWClientAuthOptionParams.DestroyParam;
Begin
 {$IFDEF RESTDWLAZARUS}
 If Not(csDesigning in TComponent(GetOwner).ComponentState) Then
  Begin
   If Assigned(RDWAuthOptionParam) Then
    FreeAndNil(RDWAuthOptionParam);
  End
 Else
  Begin
   If RDWAuthOption = rdwAONone Then
    RDWAuthOptionParam := Nil;
  End;
 {$ELSE}
 If Assigned(RDWAuthOptionParam) Then
  FreeAndNil(RDWAuthOptionParam);
 {$ENDIF}
End;

Procedure TRESTDWServerAuthOptionParams.DestroyParam;
Begin
 {$IFDEF RESTDWLAZARUS}
 If Not(csDesigning in TComponent(GetOwner).ComponentState) Then
  Begin
   If Assigned(RDWAuthOptionParam) Then
    FreeAndNil(RDWAuthOptionParam);
  End
 Else
  Begin
   If RDWAuthOption = rdwAONone Then
    RDWAuthOptionParam := Nil;
  End;
 {$ELSE}
 If Assigned(RDWAuthOptionParam) Then
  FreeAndNil(RDWAuthOptionParam);
 {$ENDIF}
End;

Procedure TRESTDWClientAuthOptionParams.SetAuthOption(Value : TRESTDWAuthOption);
Begin
 RDWAuthOption := Value;
 DestroyParam;
 Case Value Of
  rdwAOBasic  : RDWAuthOptionParam := TRESTDWAuthOptionBasic.Create;
  rdwAOBearer : RDWAuthOptionParam := TRESTDWAuthOptionBearerClient.Create;
  rdwAOToken  : RDWAuthOptionParam := TRESTDWAuthOptionTokenClient.Create;
  rdwOAuth    : RDWAuthOptionParam := TRESTDWAuthOAuth.Create;
 End;
End;

Procedure TRESTDWServerAuthOptionParams.SetAuthOption(Value : TRESTDWAuthOption);
Begin
 RDWAuthOption := Value;
 DestroyParam;
 Case Value Of
  rdwAOBasic  : RDWAuthOptionParam := TRESTDWAuthOptionBasic.Create;
  rdwAOBearer : RDWAuthOptionParam := TRESTDWAuthOptionBearerServer.Create;
  rdwAOToken  : RDWAuthOptionParam := TRESTDWAuthOptionTokenServer.Create;
  rdwOAuth    : Raise Exception.Create(cNotWorkYet);
 End;
End;

Function TRESTDWClientAuthOptionParams.GetOwner: TPersistent;
Begin
 Result := FOwner;
End;

Function TRESTDWServerAuthOptionParams.GetOwner: TPersistent;
Begin
 Result := FOwner;
End;

{ TRESTDWAuthOptionParam }

Constructor TRESTDWAuthOptionParam.Create;
Begin
 Inherited;
 vCustomAuthMessage      := 'Protected Space...';
 vCustom404TitleMessage  := '(404) The address you are looking for does not exist';
 vCustom404BodyMessage   := '404';
 vCustom404FooterMessage := 'Take me back to <a href="./">Home REST Dataware';
 vAuthDialog             := True;
 vCustomAuthErrorPage    := TStringList.Create;
End;

Destructor TRESTDWAuthOptionParam.Destroy;
Begin
 FreeAndNil(vCustomAuthErrorPage);
 Inherited;
End;

Procedure TRESTDWAuthOptionParam.SetCustomAuthErrorPage(Value: TStringList);
Var
 I : Integer;
Begin
 vCustomAuthErrorPage.Clear;
 For I := 0 To Value.Count -1 do
  vCustomAuthErrorPage.Add(Value[I]);
End;

Class Procedure TRESTDWDataUtils.ParseRESTURL(Const Cmd    : String;
                                        Encoding           : TEncodeSelect;
                                        Var mark           : String
                                        {$IFDEF RESTDWLAZARUS};
                                        DatabaseCharSet    : TDatabaseCharSet
                                        {$ENDIF};
                                        Var Result         : TRESTDWParams);
Var
 vTempData,
 NewCmd,
 vArrayValues : String;
 ArraySize,
 iBar1,
 IBar2, Count : Integer;
 aNewParam    : Boolean;
 JSONParam    : TJSONParam;
Begin
 JSONParam    := Nil;
 vArrayValues := '';
 If Pos('?', Cmd) > 0 Then
  Begin
   vArrayValues := Copy(Cmd, Pos('?', Cmd) + 1, Length(Cmd));
   NewCmd       := Copy(Cmd, 1, Pos('?', Cmd) - 1);
  End
 Else
  NewCmd     := Cmd;
 If NewCmd <> '' Then
  Begin
   If NewCmd[Length(NewCmd) - FinalStrPos] <> '/' Then
    NewCmd := NewCmd + '/';
  End;
 If Not Assigned(Result) Then
  Begin
   Result := TRESTDWParams.Create;
   Result.Encoding := Encoding;
   {$IFDEF RESTDWLAZARUS}
   Result.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
  End;
 If (CountExpression(NewCmd, '/') > 1) Then
  Begin
   If NewCmd[InitStrPos] <> '/' then
    NewCmd := '/' + NewCmd
   Else
    NewCmd := Copy(NewCmd, 2, Length(NewCmd));
   If NewCmd[Length(NewCmd) - FinalStrPos] <> '/' Then
    NewCmd := NewCmd + '/';
   ArraySize := CountExpression(vArrayValues, '&');
   If ArraySize = 0 Then
    Begin
     If Length(vArrayValues) > 0 Then
      ArraySize := 1;
    End
   Else
    ArraySize := ArraySize + 1;
   For Count := 0 to ArraySize - 1 Do
    Begin
     IBar2     := Pos('&', vArrayValues);
     If IBar2 = 0 Then
      Begin
       IBar2    := Length(vArrayValues);
       vTempData := Copy(vArrayValues, 1, IBar2);
      End
     Else
      vTempData := Copy(vArrayValues, 1, IBar2 - 1);
      If Pos('dwmark:', vTempData) > 0 Then
       mark := Copy(vTempData, Pos('dwmark:', vTempData) + 7, Length(vTempData))
      Else
       Begin
        If Pos('=', vTempData) > 0 Then
         Begin
          aNewParam := False;
          If Copy(vTempData, 1, Pos('=', vTempData) - 1) <> '' Then
           JSONParam := Result.ItemsString[Copy(vTempData, 1, Pos('=', vTempData) - 1)]
          Else
           JSONParam := Result.ItemsString[cUndefined];
          If JSONParam = Nil Then
           Begin
            aNewParam := True;
            JSONParam := TJSONParam.Create(Result.Encoding);
            JSONParam.ObjectDirection := odIN;
            JSONParam.ParamName := Copy(vTempData, 1, Pos('=', vTempData) - 1);
            Delete(vTempData, 1, Pos('=', vTempData));
            vTempData          := URLDecode(vTempData);
            JSONParam.SetValue(vTempData);
            Result.Add(JSONParam);
           End;
         End
        Else
         Begin
          aNewParam := False;
          JSONParam := Result.ItemsString[cUndefined];
          If JSONParam = Nil Then
           Begin
            aNewParam := True;
            JSONParam := TJSONParam.Create(Result.Encoding);
            JSONParam.ParamName := cUndefined;//Format('PARAM%d', [0]);
            JSONParam.ObjectDirection := odIN;
            JSONParam.SetValue(vTempData);
            Result.Add(JSONParam);
           End;
         End;
       End;
     Delete(vArrayValues, 1, IBar2);
    End;
  End;
End;

Class Procedure TRESTDWDataUtils.ParseRESTURL(UriParams    : String;
                                        Encoding           : TEncodeSelect;
                                        {$IFDEF RESTDWLAZARUS}
                                        DatabaseCharSet    : TDatabaseCharSet;
                                        {$ENDIF}
                                        Var Result         : TRESTDWParams);
Var
 vValue,
 vTempdata : String;
 A, I,
 IndexS,
 Count     : Integer;
 JSONParam : TJSONParam;
Begin
 JSONParam    := Nil;
 A            := 0;
 If Not Assigned(Result) Then
  Begin
   Result := TRESTDWParams.Create;
   Result.Encoding := Encoding;
   {$IFDEF RESTDWLAZARUS}
   Result.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
  End;
 vTempdata := UriParams;
 IndexS    := InitStrPos;
 Count     := Length(vTempdata);
 vValue    := '';
 For I := IndexS To Count - FinalStrPos Do
  Begin
   If (Trim(vValue) <> '')        And
      ((vTempData[I] = '/')       Or
       (vTempData[I] = '?')       Or
       (vTempData[I] = '&')       Or
       (I = Count - FinalStrPos)) Then
    Begin
     If (I = Count - FinalStrPos) Then
      vValue := vValue + vTempData[I];
     If Pos('=', vValue) > 0 Then
      Begin
       JSONParam := TJSONParam.Create(Result.Encoding);
       JSONParam.ObjectDirection := odIN;
       JSONParam.ParamName := Copy(vValue, InitStrPos, Pos('=', vValue) - 1);
       Delete(vValue, 1, Pos('=', vValue));
       vValue            := URLDecode(vValue);
       JSONParam.SetValue(vValue);
      End
     Else
      Begin
       JSONParam := Result.ItemsString[IntToStr(A)];
       If JSONParam = Nil Then
        Begin
         JSONParam := TJSONParam.Create(Result.Encoding);
         JSONParam.ParamName := IntToStr(A);
         JSONParam.ObjectDirection := odIN;
         Result.Add(JSONParam);
        End;
       JSONParam.SetValue(vValue);
       Inc(A);
      End;
     vValue := '';
    End
   Else
    vValue := vValue + vTempData[I];
   // Adicionado para URIParams que vem com o tamanho da string 1 (Exemplo: http://localhost:9092/helloworld/1)
   If (Count = 1) then
    Begin
     JSONParam := Result.ItemsString[IntToStr(A)];
     If JSONParam = Nil Then
      Begin
       JSONParam := TJSONParam.Create(Result.Encoding);
       JSONParam.ParamName := IntToStr(A);
       JSONParam.ObjectDirection := odIN;
       Result.Add(JSONParam);
      End;
     JSONParam.SetValue(vValue);
     Inc(A);
     vValue := '';
    End;
  End;
End;

Class Function TRESTDWDataUtils.Result2JSON(wsResult : TResultErro) : String;
Begin
 Result := '{"STATUS":"' + wsResult.Status + '","MESSAGE":"' + wsResult.MessageText + '"}';
End;

Class Procedure TRESTDWDataUtils.ParseWebFormsParams(Params             : TStrings;
                                               Const URL,
                                               Query              : String;
                                               Var mark           : String;
                                               Encoding           : TEncodeSelect;
                                               {$IFDEF RESTDWLAZARUS}
                                                DatabaseCharSet   : TDatabaseCharSet;
                                               {$ENDIF}
                                               Var Result         : TRESTDWParams;
                                               MethodType         : TRequestType = rtPost;
                                               ContentType        : String = cDefaultContentType);
Var
 aParamsIndex,
 I, IBar    : Integer;
 JSONParam  : TJSONParam;
 vParams    : TStringList;
 vTempValue,
 Cmd,
 vParamName,
 vTempData,
 vValue     : String;
 vNewParam,
 vCreateParam,
 aNewParam  : Boolean;
Begin
  // Extrai nome do ServerMethod
 If Not Assigned(Result) Then
  Begin
   Result := TRESTDWParams.Create;
   Result.Encoding := Encoding;
   {$IFDEF RESTDWLAZARUS}
   Result.DatabaseCharSet := DatabaseCharSet;
   {$ENDIF}
  End;
 JSONParam := Nil;
 Cmd := URL;
 aParamsIndex := 0;
 If Pos('?', Cmd) > 0 Then
  Begin
   I := Pos('?', Cmd);
   Cmd := Copy(Cmd, InitStrPos, I - FinalStrPos);
  End;
 If Cmd <> '' Then
  Begin
   If Cmd[Length(Cmd) - FinalStrPos] <> '/' Then
    Cmd := URL + '/';
  End;
 If (CountExpression(Cmd, '/') > 1) Then
  Begin
   If Cmd[InitStrPos] <> '/' then
    Cmd := '/' + Cmd
   Else
    Cmd := Copy(Cmd, 2, Length(Cmd));
   If Cmd[Length(Cmd) - FinalStrPos] <> '/' Then
    Cmd := Cmd + '/';
  End;
  // Extrai Parametros
 If (Params.Count > 0) And (MethodType = rtPost) Then
  Begin
   If ContentType <> cApplicationJSON then
    Params.Text := URLDecode(Params.Text);
   For I := 0 To Params.Count - 1 Do
    Begin
     vCreateParam := False;
     If Pos('dwmark:', Params[I]) > 0 Then
      mark := Copy(Params[I], Pos('dwmark:', Params[I]) + 7, Length(Params[I]))
     Else
      Begin
       If Pos('{"ObjectType":"toParam", "Direction":"', Params[I]) > 0 Then
        Begin
         vCreateParam := True;
         JSONParam := TJSONParam.Create(Result.Encoding);
         {$IFDEF RESTDWLAZARUS}
         JSONParam.DatabaseCharSet := DatabaseCharSet;
         {$ENDIF}
         JSONParam.ObjectDirection := odIN;
         If Pos('=', Params[I]) > 0 Then
          JSONParam.FromJSON(Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I]))))
         Else
          JSONParam.FromJSON(Params[I]);
        End
       Else
        Begin
         If ((Copy(Params[I], 1, Pos('=', Params[I]) - 1) = '')) And
            (ContentType = cApplicationJSON) Then
          Begin
           JSONParam := Result.ItemsString[cUndefined];
           If JSONParam = Nil Then
            Begin
             vCreateParam := True;
             JSONParam := TJSONParam.Create(Result.Encoding);
             {$IFDEF RESTDWLAZARUS}
             JSONParam.DatabaseCharSet := DatabaseCharSet;
             {$ENDIF}
             JSONParam.ObjectDirection := odIN;
             JSONParam.ParamName       := cUndefined;
            End;
          End
         Else
          Begin
           If Copy(Params[I], 1, Pos('=', Params[I]) - 1) <> '' Then
            JSONParam := Result.ItemsString[Copy(Params[I], 1, Pos('=', Params[I]) - 1)]
           Else
            JSONParam := Result.ItemsString[cUndefined];
           If JSONParam = Nil Then
            Begin
             vCreateParam := True;
             JSONParam := TJSONParam.Create(Result.Encoding);
             {$IFDEF RESTDWLAZARUS}
             JSONParam.DatabaseCharSet := DatabaseCharSet;
             {$ENDIF}
             JSONParam.ObjectDirection := odIN;
             If Copy(Params[I], 1, Pos('=', Params[I]) - 1) <> '' Then
              JSONParam.ParamName := Copy(Params[I], 1, Pos('=', Params[I]) - 1)
             Else
              JSONParam.ParamName := cUndefined;
            End;
          End;
         If JSONParam.IsNull Then
          Begin
           If ContentType <> cApplicationJSON Then
            Begin
             vValue  := Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I])));
             {$IFNDEF RESTDWLAZARUS}
              If Result.Encoding = esUtf8 then
               vValue   := Utf8Encode(vValue);
             {$ENDIF}
            End
           Else
            Begin
             If Copy(Params[I], 1, Pos('=', Params[I]) - 1) <> '' Then
              vValue  := Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I])))
             Else
              vValue  := Params[I];
            End;
           JSONParam.AsString   := vValue;
           If JSONParam.AsString = '' Then
            JSONParam.Encoded   := False;
          End;
        End;
       If vCreateParam Then
        Result.Add(JSONParam);
      End;
    End;
  End
 Else
  Begin
   If (MethodType In [rtGet, rtDelete]) Then
    Begin
    End;
   vParams := TStringList.Create;
   vParams.Delimiter := '&';
   {$IFDEF DELPHIXEUP}vParams.StrictDelimiter := true;{$ENDIF}
   If ((Params.Count > 0) And (Pos('?', URL) = 0)) And (Query = '') then
    Cmd := Cmd + URLDecode(Params.Text)
   Else
    Cmd := URLDecode(Query);
//    Uri := TIdURI.Create(Cmd);
   Try
//    vParams.Delimiter := '|';
    vParams.Text := StringReplace(Cmd, '&', sLineBreak, [rfReplaceAll]);
    If vParams.count = 0 Then
     If Trim(Cmd) <> '' Then
      vParams.DelimitedText := StringReplace(Cmd, sLineBreak, '&', [rfReplaceAll]); //Alterações enviadas por "joaoantonio19"
      //vParams.Add(Cmd);
   Finally
    For I := 0 To vParams.Count - 1 Do
     Begin
      If Pos('dwmark:', vParams[I]) > 0 Then
       mark := Copy(vParams[I], Pos('dwmark:', vParams[I]) + 7, Length(vParams[I]))
      Else
       Begin
        vNewParam := False;
        If vParams[I] <> '' Then
         Begin
          If (vParams.names[I] <> '') And
             (Trim(Query)      <> '') Then
           vParamName := Trim(Copy(vParams[I], 1, Pos('=', vParams[I]) - 1))
          Else
           vParamName := IntToStr(I);
          JSONParam                 := Result.ItemsString[vParamName];
          If JSONParam = Nil Then
           Begin
            vNewParam := True;
            JSONParam               := TJSONParam.Create(Result.Encoding);
            JSONParam.ObjectDirection := odIN;
            If (vParams.names[I] <> '') And
               (Trim(Query)      <> '') Then
             Begin
              JSONParam.ParamName       := Trim(Copy(vParams[I], 1, Pos('=', vParams[I]) - 1));
              JSONParam.AsString        := Trim(Copy(vParams[I],    Pos('=', vParams[I]) + 1, Length(vParams[I])));
             End
            Else
             Begin
              JSONParam.ParamName       := IntToStr(I);
              JSONParam.AsString        := vParams[I];
             End;
            {$IFDEF RESTDWLAZARUS}
            JSONParam.DatabaseCharSet := DatabaseCharSet;
            {$ENDIF}
//          If vNewParam Then
            Result.Add(JSONParam);
           End;
         End;
       End;
     End;
    vParams.Free;
   End;
  End;
End;

Class Procedure TRESTDWDataUtils.ParseWebFormsParams (Var DWParams: TRESTDWParams;
                                                WebParams         : TStrings;
                                                Encoding          : TEncodeSelect
                                                {$IFDEF RESTDWLAZARUS}
                                                 ;DatabaseCharSet : TDatabaseCharSet
                                                {$ENDIF};
                                                MethodType        : TRequestType = rtPost);
Var
 I          : Integer;
 JSONParam  : TJSONParam;
 vParams    : TStringList;
 vParamName : String;
Begin
 JSONParam := Nil;
 vParams   := Nil;
 If (WebParams.Count > 0) Then
  Begin
   WebParams.Text := URLDecode(WebParams.Text);
   For I := 0 To WebParams.Count - 1 Do
    Begin
     If Pos('{"ObjectType":"toParam", "Direction":"', WebParams[I]) > 0 Then
      Begin
       JSONParam := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ObjectDirection := odIN;
       If Pos('=', WebParams[I]) > 0 Then
        JSONParam.FromJSON(Trim(Copy(WebParams[I], Pos('=', WebParams[I]) + 1, Length(WebParams[I]))))
       Else
        JSONParam.FromJSON(WebParams[I]);
      End
     Else
      Begin
       vParamName := Copy(WebParams[I], 1, Pos('=', WebParams[I]) - 1);
       JSONParam  := DWParams.ItemsString[vParamName];
       If Not Assigned(JSONParam) Then
        JSONParam := TJSONParam.Create(DWParams.Encoding)
       Else
        Continue;
       JSONParam.ObjectDirection := odIN;
       JSONParam.ParamName := vParamName;
       If DWParams.Encoding = esUtf8 then
        JSONParam.AsString  := Utf8Encode(Trim(Copy(WebParams[I], Pos('=', WebParams[I]) + 1, Length(WebParams[I]))))
       Else
        JSONParam.AsString  := Trim(Copy(WebParams[I], Pos('=', WebParams[I]) + 1, Length(WebParams[I])));
       If JSONParam.AsString = '' Then
        JSONParam.Encoded         := False;
      End;
     If Assigned(JSONParam) Then
      DWParams.Add(JSONParam);
    End;
  End;
End;

Class Function TRESTDWDataUtils.ParseDWParamsURL(Const Cmd        : String;
                                                 Encoding         : TEncodeSelect;
                                                 Var ResultPR     : TRESTDWParams
                                                 {$IFDEF RESTDWLAZARUS}
                                                 ;DatabaseCharSet : TDatabaseCharSet
                                                 {$ENDIF})        : Boolean;
Var
 vTempData,
 vTempName,
 vArrayValues : String;
 ArraySize,
 IBar2, Cont  : Integer;
 JSONParam    : TJSONParam;
 vParamList   : TStringList;
Begin
 vArrayValues         := Cmd;
 vParamList           := TStringList.Create;
 vParamList.Text      := StringReplace(vArrayValues, '&', #13, [rfReplaceAll]);
 If vParamList.Count < 1 Then
  Begin
   Result := Pos('=', vArrayValues) > 0;
   If Result Then
    Begin
     If Not Assigned(ResultPR) Then
      Begin
       ResultPR := TRESTDWParams.Create;
       ResultPR.Encoding := Encoding;
       {$IFDEF RESTDWLAZARUS}
       ResultPR.DatabaseCharSet := DatabaseCharSet;
       {$ENDIF}
      End;
     JSONParam  := Nil;
     ArraySize := CountExpression(vArrayValues, '&');
     If ArraySize = 0 Then
      Begin
       If Length(vArrayValues) > 0 Then
        ArraySize := 1;
      End
     Else
      ArraySize := ArraySize + 1;
     For Cont := 0 to ArraySize - 1 Do
      Begin
       IBar2     := Pos('&', vArrayValues);
       If IBar2 = 0 Then
        Begin
         IBar2    := Length(vArrayValues);
         vTempData := Copy(vArrayValues, 1, IBar2);
        End
       Else
        vTempData := Copy(vArrayValues, 1, IBar2 - 1);
       If Pos('=', vTempData) > 0 Then
        Begin
         vTempName := Copy(vTempData, 1, Pos('=', vTempData) - 1);
         JSONParam := ResultPR.ItemsString[vTempName]; //TJSONParam.Create(ResultPR.Encoding);
         If JSONParam  = Nil Then
          Begin
           JSONParam.ObjectDirection := odIN;
           JSONParam.ParamName := vTempName;
           Delete(vTempData, 1, Pos('=', vTempData));
           JSONParam.SetValue(URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll])));
           ResultPR.Add(JSONParam);
          End;
        End
       Else
        Begin
         JSONParam := ResultPR.ItemsString[cUndefined];
         If JSONParam = Nil Then
          Begin
           JSONParam                 := TJSONParam.Create(ResultPR.Encoding);
           JSONParam.ObjectDirection := odIN;
           JSONParam.ParamName       := cUndefined;//Format('PARAM%d', [0]);
           JSONParam.SetValue(URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll])));
           ResultPR.Add(JSONParam);
          End;
        End;
       Delete(vArrayValues, 1, IBar2);
      End;
    End;
  End
 Else
  Begin
   Result   := True;
   vArrayValues := StringReplace(Trim(vArrayValues), #239#187#191, '', [rfReplaceAll]);
   vArrayValues := StringReplace(vArrayValues, sLineBreak,   '', [rfReplaceAll]);
   If (vArrayValues[InitStrPos] = '[') or (vArrayValues[InitStrPos] = '{') then
    Begin
     JSONParam := TJSONParam.Create(ResultPR.Encoding);
     JSONParam.ParamName       := cUndefined;
     JSONParam.ObjectDirection := odIN;
     JSONParam.SetValue(vArrayValues, True);
     ResultPR.Add(JSONParam);
    End
   Else
    Begin
     For Cont := 0 to vParamList.Count - 1 Do
      Begin
       If vParamList.Names[cont] = '' Then
        Begin
         JSONParam := ResultPR.ItemsString[cUndefined];
         If JSONParam = Nil Then
          Begin
           JSONParam := TJSONParam.Create(ResultPR.Encoding);
           JSONParam.ParamName := cUndefined;
           JSONParam.ObjectDirection := odIN;
           JSONParam.SetValue(vParamList[cont]);
           ResultPR.Add(JSONParam);
          End;
        End
       Else
        Begin
         JSONParam := ResultPR.ItemsString[vParamList.Names[cont]];
         If JSONParam = Nil Then
          Begin
           JSONParam := TJSONParam.Create(ResultPR.Encoding);
           JSONParam.ObjectDirection := odIN;
           JSONParam.ParamName := vParamList.Names[cont];
           JSONParam.SetValue(vParamList.Values[vParamList.Names[cont]]);
           ResultPR.Add(JSONParam);
          End;
        End;
      End;
    End;
  End;
 vParamList.Free;
End;

Class Function TRESTDWDataUtils.ParseBodyRawToDWParam(Const BodyRaw    : String;
                                                      Encoding         : TEncodeSelect;
                                                      Var ResultPR     : TRESTDWParams
                                                      {$IFDEF RESTDWLAZARUS}
                                                      ;DatabaseCharSet : TDatabaseCharSet
                                                      {$ENDIF})        : Boolean;
Var
 JSONParam: TJSONParam;
Begin
 If (BodyRaw <> EmptyStr) Then
  Begin
   If Not Assigned(ResultPR) Then
    Begin
     ResultPR := TRESTDWParams.Create;
     ResultPR.Encoding := Encoding;
     {$IFDEF RESTDWLAZARUS}
     ResultPR.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
    End;
   JSONParam                 := TJSONParam.Create(ResultPR.Encoding);
   JSONParam.ObjectDirection := odIN;
   If Assigned(ResultPR.ItemsString['dwNameParamBody']) And (ResultPR.ItemsString['dwNameParamBody'].AsString<>'') Then
    JSONParam.ParamName       := ResultPR.ItemsString['dwNameParamBody'].AsString
   Else
    JSONParam.ParamName       := 'UNDEFINED';
   JSONParam.SetValue(BodyRaw, True);
   ResultPR.Add(JSONParam);
  End;
End;

Class Function TRESTDWDataUtils.ParseBodyRawToDWParam(Const BodyRaw    : TStream;
                                                      Encoding         : TEncodeSelect;
                                                      Var ResultPR     : TRESTDWParams
                                                      {$IFDEF RESTDWLAZARUS}
                                                      ;DatabaseCharSet : TDatabaseCharSet
                                                      {$ENDIF})        : Boolean;
Var
 JSONParam: TJSONParam;
Begin
 If (BodyRaw.Size > 0) Then
  Begin
   BodyRaw.Position := 0;
   If Not Assigned(ResultPR) Then
    Begin
     ResultPR := TRESTDWParams.Create;
     ResultPR.Encoding := Encoding;
     {$IFDEF RESTDWLAZARUS}
     ResultPR.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
    End;
   JSONParam                 := TJSONParam.Create(ResultPR.Encoding);
   JSONParam.ObjectDirection := odIN;
   If Assigned(ResultPR.ItemsString['dwNameParamBody']) And (ResultPR.ItemsString['dwNameParamBody'].AsString<>'') Then
    JSONParam.ParamName       := ResultPR.ItemsString['dwNameParamBody'].AsString
   Else
    JSONParam.ParamName       := 'UNDEFINED';
   JSONParam.LoadFromStream(BodyRaw);
   ResultPR.Add(JSONParam);
  End;
End;

Class Function TRESTDWDataUtils.ParseBodyBinToDWParam(Const BodyBin    : String;
                                                      Encoding         : TEncodeSelect;
                                                      Var ResultPR     : TRESTDWParams
                                                      {$IFDEF RESTDWLAZARUS}
                                                      ;DatabaseCharSet : TDatabaseCharSet
                                                      {$ENDIF})        : Boolean;
Var
 JSONParam    : TJSONParam;
 vContentType : String;
Begin
 If (BodyBin <> EmptyStr) then
  Begin
   If Not Assigned(ResultPR) Then
    Begin
     ResultPR := TRESTDWParams.Create;
     ResultPR.Encoding := Encoding;
     {$IFDEF RESTDWLAZARUS}
     ResultPR.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
    End;
   JSONParam                 := TJSONParam.Create(ResultPR.Encoding);
   JSONParam.ObjectDirection := odIN;
   If Assigned(ResultPR.ItemsString['dwParamNameBody']) And (ResultPR.ItemsString['dwParamNameBody'].AsString<>'') Then
    JSONParam.ParamName       := ResultPR.ItemsString['dwParamNameBody'].AsString
   Else
    JSONParam.ParamName       := 'UNDEFINED';
   JSONParam.SetValue(BodyBin, True);
   ResultPR.Add(JSONParam);
   If Assigned(ResultPR.ItemsString['dwFileNameBody']) And (ResultPR.ItemsString['dwFileNameBody'].AsString<>'') Then
    Begin
     JSONParam   := TJSONParam.Create(ResultPR.Encoding);
     JSONParam.ObjectDirection := odIN;
     JSONParam.ParamName := 'dwfilename';
     JSONParam.SetValue(ResultPR.ItemsString['dwFileNameBody'].AsString, JSONParam.Encoded);
     ResultPR.Add(JSONParam);
     If Not Assigned(ResultPR.ItemsString['Content-Type']) then
      Begin
       vContentType:= TRESTDWMimeType.GetMIMEType(ResultPR.ItemsString['dwFileNameBody'].AsString);
       If vContentType <> '' then
        Begin
         JSONParam   := TJSONParam.Create(ResultPR.Encoding);
         JSONParam.ObjectDirection := odIN;
         JSONParam.ParamName := 'Content-Type';
         JSONParam.SetValue(vContentType, JSONParam.Encoded);
         ResultPR.Add(JSONParam);
        End;
      End;
    End;
  End;
End;

Class Function TRESTDWDataUtils.ParseFormParamsToDWParam(Const FormParams : String;
                                                         Encoding         : TEncodeSelect;
                                                         Var ResultPR     : TRESTDWParams
                                                         {$IFDEF RESTDWLAZARUS}
                                                         ;DatabaseCharSet : TDatabaseCharSet
                                                         {$ENDIF})        : Boolean;
Var
 JSONParam: TJSONParam;
 i            : Integer;
 vTempValue,
 vObjectName,
 vArrayValues : String;
 vParamList   : TStringList;
 Function FindValue(ParamList   : TStringList; Var IndexValue : Integer) : String;
 Var
  vFlagnew : Boolean;
 Begin
  vFlagnew := False;
  Result := '';
  While IndexValue <= ParamList.Count -1 Do
   Begin
    If vFlagnew Then
     Begin
      Result := ParamList[IndexValue];
      Break;
     End
    Else
     vFlagnew := ParamList[IndexValue] = '';
    Inc(IndexValue);
   End;
 End;
begin
 vArrayValues := StringReplace(FormParams, '=' + sLineBreak,   '', [rfReplaceAll]);
 vParamList      := TStringList.Create;
 Try
  If (vArrayValues <> EmptyStr) Then
   Begin
    vParamList.Text := vArrayValues;
    I := 0;
    While I <= vParamList.Count -1 Do
     Begin
      If Not Assigned(ResultPR) Then
       Begin
        ResultPR := TRESTDWParams.Create;
        ResultPR.Encoding := Encoding;
        {$IFDEF RESTDWLAZARUS}
        ResultPR.DatabaseCharSet := DatabaseCharSet;
        {$ENDIF}
       End;
      vObjectName := Copy(lowercase(vParamList[I]), Pos('; name="', lowercase(vParamList[I])) + length('; name="'),  length(lowercase(vParamList[I])));
      vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
      If vObjectName = '' Then
       Begin
        Inc(I);
        Continue;
       End;
      JSONParam                 := TJSONParam.Create(ResultPR.Encoding);
      JSONParam.ObjectDirection := odIN;
      JSONParam.ParamName       := vObjectName;
      vTempValue := FindValue(vParamList, I);
      If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(vTempValue)) > 0) Or
         (Pos(Lowercase('{"ObjectType":"toObject", "Direction":"'), lowercase(vTempValue)) > 0) Then
       JSONParam.FromJSON(vTempValue)
      Else
       JSONParam.SetValue(vTempValue, True);
      ResultPR.Add(JSONParam);
      Inc(I);
     End;
   End;
 Finally
  FreeAndNil(vParamList);
 End;
End;

end.

