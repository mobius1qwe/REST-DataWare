unit uRESTDWAuthenticators;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

uses
  Classes, SysUtils, DateUtils,
  uRESTDWConsts, uRESTDWAbout, uRESTDWDataUtils, uRESTDWJSONInterface,
  uRESTDWTools, uRESTDWParams;

type
  TRESTDWAuthenticatorBase = class(TRESTDWComponent)
  private
    FAuthDialog: Boolean;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property AuthDialog: Boolean read FAuthDialog write FAuthDialog;
  end;

  // Classe Especifica para Autenticacao pelo Server
  TRESTDWServerAuthBase = class(TRESTDWAuthenticatorBase)
  private

  public
    function AuthValidate(ADataModuleRESTDW: TObject;
      AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername,
      AAuthPassword: String; ARawHeaders: TStrings; ARequestType: TRequestType;
      var ADWParams: TRESTDWParams; var AGetToken: Boolean;
      var ATokenValidate: Boolean; var AToken: String; var AErrorCode: Integer;
      var AErrorMessage: String; var AAcceptAuth: Boolean): Boolean;
      virtual; abstract;
  end;

  TRESTDWAuthBasic = class(TRESTDWServerAuthBase)
  private
    FPassword: String;
    FUserName: String;
    procedure PrepareBasicAuth(AAuthenticationString: String;
      var AAuthUsername, AAuthPassword: String);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function AuthValidate(ADataModuleRESTDW: TObject;
      AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername,
      AAuthPassword: String; ARawHeaders: TStrings; ARequestType: TRequestType;
      var ADWParams: TRESTDWParams; var AGetToken: Boolean;
      var ATokenValidate: Boolean; var AToken: String; var AErrorCode: Integer;
      var AErrorMessage: String; var AAcceptAuth: Boolean): Boolean; override;
    function ValidateAuth(AUserName, APassword: string): Boolean;
  published
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
  end;

  TRESTDWAuthToken = class(TRESTDWServerAuthBase)
  private
    FBeginTime: TDateTime;
    FEndTime: TDateTime;
    FSecrets: String;
    FServerSignature: String;
    FTokenType: TRESTDWTokenType;
    FCryptType: TRESTDWCryptType;
    FTokenRequestType: TRESTDWTokenRequest;
    FKey: String;
    FGetTokenEvent: String;
    FGetTokenRoutes: TRESTDWRoutes;
    FTokenHash: String;
    FLifeCycle: Integer;
    FToken: String;
    FAutoGetToken: Boolean;
    FAutoRenewToken: Boolean;
    procedure ClearToken;
    procedure SetGetTokenEvent(AValue: String);
    procedure SetToken(AValue: String);
    function GetTokenType(AValue: String): TRESTDWTokenType;
    function GetCryptType(AValue: String): TRESTDWCryptType;
    procedure GenerateToken(ADataModuleRESTDW: TObject;
      ARequestType: TRequestType; AParams: TRESTDWParams; ARawHeaders: TStrings;
      AWelcomeMessage, AAccessTag: String; var ATokenValidate: Boolean;
      var AToken: String; var AGetToken: Boolean; var AErrorCode: Integer;
      var AErrorMessage: String; var AAcceptAuth: Boolean);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(ASource: TPersistent);
    procedure FromToken(ATokenValue: String);
    function GetToken(ASecrets: String): String;
    function ValidateToken(AValue: String): Boolean; overload;
    function AuthValidate(ADataModuleRESTDW: TObject;
      AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername,
      AAuthPassword: String; ARawHeaders: TStrings; ARequestType: TRequestType;
      var ADWParams: TRESTDWParams; var AGetToken: Boolean;
      var ATokenValidate: Boolean; var AToken: String; var AErrorCode: Integer;
      var AErrorMessage: String; var AAcceptAuth: Boolean): Boolean; override;
  published
    property BeginTime: TDateTime read FBeginTime write FBeginTime;
    property EndTime: TDateTime read FEndTime write FEndTime;
    property Secrets: String read FSecrets write FSecrets;
    property TokenType: TRESTDWTokenType read FTokenType write FTokenType;
    property CryptType: TRESTDWCryptType read FCryptType write FCryptType;
    property TokenRequestType: TRESTDWTokenRequest Read FTokenRequestType
      write FTokenRequestType;
    property Key: String read FKey write FKey;
    property GetTokenEvent: String read FGetTokenEvent write SetGetTokenEvent;
    property GetTokenRoutes: TRESTDWRoutes read FGetTokenRoutes
      write FGetTokenRoutes;
    property TokenHash: String read FTokenHash write FTokenHash;
    property ServerSignature: String read FServerSignature
      write FServerSignature;
    property LifeCycle: Integer read FLifeCycle write FLifeCycle;
    property Token: String read FToken write SetToken;
    property AutoGetToken: Boolean read FAutoGetToken write FAutoGetToken;
    property AutoRenewToken: Boolean read FAutoRenewToken write FAutoRenewToken;
  end;

  TRESTDWAuthOAuth = class(TRESTDWServerAuthBase)
  private
    FTokenType: TRESTDWAuthOptionTypes;
    FAutoBuildHex: Boolean;
    FToken: String;
    FGrantCodeEvent: String;
    FGrantType: String;
    FGetTokenEvent: String;
    FClientID: String;
    FClientSecret: String;
    FRedirectURI: String;
    FExpiresIn: TDateTime;
  public
    constructor Create(aOwner: TComponent); override;
    function AuthValidate(ADataModuleRESTDW: TObject;
      AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername,
      AAuthPassword: String; ARawHeaders: TStrings; ARequestType: TRequestType;
      var ADWParams: TRESTDWParams; var AGetToken: Boolean;
      var ATokenValidate: Boolean; var AToken: String; var AErrorCode: Integer;
      var AErrorMessage: String; var AAcceptAuth: Boolean): Boolean; override;
  published
    property TokenType: TRESTDWAuthOptionTypes read FTokenType write FTokenType;
    property AutoBuildHex: Boolean read FAutoBuildHex write FAutoBuildHex;
    property Token: String read FToken write FToken;
    property GrantCodeEvent: String read FGrantCodeEvent write FGrantCodeEvent;
    property GrantType: String read FGrantType write FGrantType;
    property GetTokenEvent: String read FGetTokenEvent write FGetTokenEvent;
    property ClientID: String read FClientID write FClientID;
    property ClientSecret: String read FClientSecret write FClientSecret;
    property RedirectURI: String read FRedirectURI write FRedirectURI;
    property ExpiresIn: TDateTime read FExpiresIn;
  end;

  TOnUserBasicAuth = Procedure(Welcomemsg, AccessTag, UserName,
    Password: String; Var Params: TRESTDWParams; Var ErrorCode: Integer;
    Var ErrorMessage: String; Var Accept: Boolean) Of Object;

  TOnGetToken = Procedure(Welcomemsg, AccessTag: String; Params: TRESTDWParams;
    AuthOptions: TRESTDWAuthToken; Var ErrorCode: Integer;
    Var ErrorMessage: String; Var TokenID: String; Var Accept: Boolean)
    Of Object;

  TOnUserTokenAuth = Procedure(Welcomemsg, AccessTag: String;
    Params: TRESTDWParams; AuthOptions: TRESTDWAuthToken;
    Var ErrorCode: Integer; Var ErrorMessage: String; Var TokenID: String;
    Var Accept: Boolean) Of Object;

  TOnRenewToken = Procedure() of Object;

implementation

uses
  uRESTDWDatamodule;

{ TRESTDWAuthBasic }

function TRESTDWAuthBasic.AuthValidate(ADataModuleRESTDW: TObject;
  AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername, AAuthPassword: String;
  ARawHeaders: TStrings; ARequestType: TRequestType;
  var ADWParams: TRESTDWParams; var AGetToken, ATokenValidate: Boolean;
  var AToken: String; var AErrorCode: Integer; var AErrorMessage: String;
  var AAcceptAuth: Boolean): Boolean;
var
  LAuthenticationString: String;
begin
  LAuthenticationString :=
    DecodeStrings(StringReplace(ARawHeaders.Values['Authorization'], 'Basic ',
    '', [rfReplaceAll]){$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
  if Assigned(TServerMethodDataModule(ADataModuleRESTDW).OnUserBasicAuth) then
    TServerMethodDataModule(ADataModuleRESTDW).OnUserBasicAuth(AWelcomeMessage,
      AAccessTag, AAuthUsername, AAuthPassword, ADWParams, AErrorCode,
      AErrorMessage, AAcceptAuth)
  else if (LAuthenticationString <> '') and
    ((AAuthUsername = '') and (AAuthPassword = '')) then
    Self.PrepareBasicAuth(LAuthenticationString, AAuthUsername, AAuthPassword)
  else
    AAcceptAuth := Self.ValidateAuth(AAuthUsername, AAuthPassword);

  Result := AAcceptAuth;
end;

constructor TRESTDWAuthBasic.Create(aOwner: TComponent);
begin
  inherited;
  FUserName := cDefaultBasicAuthUser;
  FPassword := cDefaultBasicAuthPassword;
end;

destructor TRESTDWAuthBasic.Destroy;
begin

  inherited;
end;

procedure TRESTDWAuthBasic.PrepareBasicAuth(AAuthenticationString: String;
  var AAuthUsername, AAuthPassword: String);
begin
  AAuthUsername := Copy(AAuthenticationString, InitStrPos,
    Pos(':', AAuthenticationString) - 1);
  Delete(AAuthenticationString, InitStrPos, Pos(':', AAuthenticationString));
  AAuthPassword := AAuthenticationString;
end;

function TRESTDWAuthBasic.ValidateAuth(AUserName, APassword: string): Boolean;
begin
  Result := (AUserName = UserName) and (APassword = Password)
end;

{ TRESTDWAuthToken }

procedure TRESTDWAuthToken.Assign(ASource: TPersistent);
var
  LSrc: TRESTDWAuthToken;
begin
  if ASource is TRESTDWAuthToken then
  begin
    LSrc := TRESTDWAuthToken(ASource);
    TokenType := LSrc.TokenType;
    CryptType := LSrc.CryptType;
    GetTokenEvent := LSrc.GetTokenEvent;
    TokenHash := LSrc.TokenHash;
    ServerSignature := LSrc.ServerSignature;
    LifeCycle := LSrc.LifeCycle;
  end
  else
    inherited Assign(ASource);
end;

function TRESTDWAuthToken.AuthValidate(ADataModuleRESTDW: TObject;
  AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername, AAuthPassword: String;
  ARawHeaders: TStrings; ARequestType: TRequestType;
  var ADWParams: TRESTDWParams; var AGetToken, ATokenValidate: Boolean;
  var AToken: String; var AErrorCode: Integer; var AErrorMessage: String;
  var AAcceptAuth: Boolean): Boolean;
var
  LUrlToken, LToken, LTokenOrig: String;
  LAuthTokenParam: TRESTDWAuthToken;
begin
  // Se for o Evento Get Token
  LUrlToken := LowerCase(AUrlToExec);

  if Copy(LUrlToken, InitStrPos, 1) = '/' then
    Delete(LUrlToken, InitStrPos, 1);

  if LUrlToken = LowerCase(Self.GetTokenEvent) then
  begin
    Self.GenerateToken(ADataModuleRESTDW, ARequestType, ADWParams, ARawHeaders,
      AWelcomeMessage, AAccessTag, ATokenValidate, AToken, AGetToken,
      AErrorCode, AErrorMessage, AAcceptAuth);
    Exit;
  end;

  // Se for Validar o Token
  AErrorCode := 401;
  AErrorMessage := cInvalidAuth;
  ATokenValidate := True;
  LTokenOrig := AToken;

  LAuthTokenParam := TRESTDWAuthToken.Create(Self);
  LAuthTokenParam.Assign(Self);

  if ADWParams.ItemsString[Self.Key] <> Nil then
    AToken := ADWParams.ItemsString[Self.Key].AsString
  else
  begin
    if Trim(AToken) = '' then
      AToken := ARawHeaders.Values['Authorization'];

    if Trim(AToken) <> '' then
    begin
      LToken := GetTokenString(AToken);

      if LToken = '' then
        LToken := GetBearerString(AToken);

      if LToken = '' then
        LToken := LTokenOrig;

      AToken := LToken;
    end;
  end;

  if not LAuthTokenParam.ValidateToken(AToken) then
  begin
    AAcceptAuth := False;
    Exit;
  end
  else
    ATokenValidate := False;

  if Assigned(TServerMethodDataModule(ADataModuleRESTDW).OnUserTokenAuth) then
  begin
    TServerMethodDataModule(ADataModuleRESTDW).OnUserTokenAuth(AWelcomeMessage,
      AAccessTag, ADWParams, TRESTDWAuthToken(LAuthTokenParam), AErrorCode,
      AErrorMessage, AToken, AAcceptAuth);

    ATokenValidate := Not(AAcceptAuth);
  end;

  Result := AAcceptAuth;
end;

procedure TRESTDWAuthToken.ClearToken;
begin
  FSecrets := '';
  FToken := '';
  FBeginTime := 0;
  FEndTime := 0;
end;

constructor TRESTDWAuthToken.Create(aOwner: TComponent);
begin
  inherited;
  FTokenHash := 'RDWTS_HASH0011';
  FServerSignature := 'RESTDWServer01';
  FGetTokenEvent := 'GetToken';
  FKey := 'token';
  FLifeCycle := 1800; // 30 Minutos
  FTokenType := rdwJWT;
  FCryptType := rdwHSHA256;
  FServerSignature := '';
  FBeginTime := 0;
  FEndTime := 0;
  FSecrets := '';
  FGetTokenRoutes := [crPost];
  FTokenRequestType := rdwtHeader;
  FToken := '';
  FSecrets := '';
  FAutoGetToken := True;
  FAutoRenewToken := True;
end;

destructor TRESTDWAuthToken.Destroy;
begin

  inherited;
end;

procedure TRESTDWAuthToken.FromToken(ATokenValue: String);
var
  LJsonValue: TRESTDWJSONInterfaceObject;
  LHeader, LBody: String;
begin
  FToken := ATokenValue;

  try
    LHeader := Copy(ATokenValue, InitStrPos, Pos('.', ATokenValue) - 1);
    Delete(ATokenValue, InitStrPos, Pos('.', ATokenValue));
    LBody := Copy(ATokenValue, InitStrPos, Pos('.', ATokenValue) - 1);

    // Read Header
    if Trim(LHeader) <> '' then
    begin
      LJsonValue := TRESTDWJSONInterfaceObject.Create
        (DecodeStrings(LHeader{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));

      if LJsonValue.PairCount > 0 then
      begin
        if not LJsonValue.PairByName['typ'].IsNull then
          FTokenType := GetTokenType(LJsonValue.PairByName['typ'].Value);
      end;

      FreeAndNil(LJsonValue);
    end;

    // Read Body
    if Trim(LBody) <> '' then
    begin
      LJsonValue := TRESTDWJSONInterfaceObject.Create
        (DecodeStrings(LBody{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));

      if LJsonValue.PairCount > 0 then
      begin
        if not LJsonValue.PairByName['iat'].IsNull then
        begin
          if FTokenType = rdwTS then
            FBeginTime := TTokenValue.DateTimeFromISO8601
              (LJsonValue.PairByName['iat'].Value)
          else
            FBeginTime := UnixToDateTime
              (StrToInt64(LJsonValue.PairByName['iat'].Value), False);
        end;

        if not LJsonValue.PairByName['exp'].IsNull then
        begin
          if FTokenType = rdwTS then
            FEndTime := TTokenValue.DateTimeFromISO8601
              (LJsonValue.PairByName['exp'].Value)
          else
            FEndTime := UnixToDateTime
              (StrToInt64(LJsonValue.PairByName['exp'].Value), False);
        end;

        if not LJsonValue.PairByName['secrets'].IsNull Then
          FSecrets := DecodeStrings(LJsonValue.PairByName['secrets']
            .Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
      end;

      FreeAndNil(LJsonValue);
    end;
  except

  end;
end;

procedure TRESTDWAuthToken.GenerateToken(ADataModuleRESTDW: TObject;
  ARequestType: TRequestType; AParams: TRESTDWParams; ARawHeaders: TStrings;
  AWelcomeMessage, AAccessTag: String; var ATokenValidate: Boolean;
  var AToken: String; var AGetToken: Boolean; var AErrorCode: Integer;
  var AErrorMessage: String; var AAcceptAuth: Boolean);
var
  LAuthTokenParam: TRESTDWAuthToken;
  LParams: TRESTDWParams;
begin
  AGetToken := True;
  AErrorCode := 404;
  AErrorMessage := cEventNotFound;

  if (RequestTypeToRoute(ARequestType) in Self.GetTokenRoutes) or
    (crAll in Self.GetTokenRoutes) then
  begin
    if Assigned(TServerMethodDataModule(ADataModuleRESTDW).OnGetToken) then
    begin
      ATokenValidate := True;
      LAuthTokenParam := TRESTDWAuthToken.Create(Self);
      LAuthTokenParam.Assign(Self);

      {$IFNDEF RESTDWLAZARUS}
      if Trim(AToken) = '' Then
        AToken := ARawHeaders.Values['Authorization'];
      {$ENDIF}
      if AParams.ItemsString['RDWParams'] <> Nil then
      begin
        LParams := TRESTDWParams.Create;
        LParams.FromJSON(AParams.ItemsString['RDWParams'].Value);

        TServerMethodDataModule(ADataModuleRESTDW).OnGetToken(AWelcomeMessage,
          AAccessTag, LParams, LAuthTokenParam, AErrorCode, AErrorMessage,
          AToken, AAcceptAuth);

        FreeAndNil(LParams);
      end
      else
        TServerMethodDataModule(ADataModuleRESTDW).OnGetToken(AWelcomeMessage,
          AAccessTag, AParams, LAuthTokenParam, AErrorCode, AErrorMessage,
          AToken, AAcceptAuth);
    end;
  end;
end;

function TRESTDWAuthToken.GetCryptType(AValue: String): TRESTDWCryptType;
begin
  Result := rdwAES256;

  if LowerCase(AValue) = 'hs256' then
    Result := rdwHSHA256
  else if LowerCase(AValue) = 'rsa' then
    Result := rdwRSA;
end;

function TRESTDWAuthToken.GetToken(ASecrets: String): String;
var
  LTokenValue: TTokenValue;
begin
  LTokenValue := TTokenValue.Create;
  LTokenValue.TokenHash := FTokenHash;
  LTokenValue.TokenType := FTokenType;
  LTokenValue.CryptType := FCryptType;

  if Trim(FServerSignature) <> '' then
    LTokenValue.Iss := LTokenValue.vCripto.Encrypt(FServerSignature);

  LTokenValue.Secrets := ASecrets;
  LTokenValue.BeginTime := Now;

  if FLifeCycle > 0 then
    LTokenValue.EndTime := IncSecond(LTokenValue.BeginTime, FLifeCycle);

  try
    Result := LTokenValue.ToToken;
  finally
    FreeAndNil(LTokenValue);
  end;
end;

function TRESTDWAuthToken.GetTokenType(AValue: String): TRESTDWTokenType;
begin
  Result := rdwTS;

  If LowerCase(AValue) = 'jwt' then
    Result := rdwJWT
  else if LowerCase(AValue) = 'rdwcustom' then
    Result := rdwPersonal;
end;

procedure TRESTDWAuthToken.SetGetTokenEvent(AValue: String);
begin
  if Length(AValue) > 0 then
    FGetTokenEvent := AValue
  else
    raise Exception.Create('Invalid GetTokenName');
end;

procedure TRESTDWAuthToken.SetToken(AValue: String);
begin
  ClearToken;
  FToken := AValue;

  if FToken <> '' then
    FromToken(FToken)
end;

function TRESTDWAuthToken.ValidateToken(AValue: String): Boolean;
var
  LHeader, LBody, LStringComparer: String;
  LTokenValue: TTokenValue;

  function ReadHeader(AValue: String): Boolean;
  var
    LJsonValue: TRESTDWJSONInterfaceObject;
  begin
    LJsonValue := Nil;
    Result := False;

    try
      LJsonValue := TRESTDWJSONInterfaceObject.Create(AValue);

      if LJsonValue.PairCount = 2 then
      begin
        Result := (LowerCase(LJsonValue.Pairs[0].Name) = 'alg') And
          (LowerCase(LJsonValue.Pairs[1].Name) = 'typ');

        if Result then
        begin
          FTokenType := GetTokenType(LJsonValue.Pairs[1].Value);
          FCryptType := GetCryptType(LJsonValue.Pairs[0].Value);
        end;
      end;
    except

    end;

    if Assigned(LJsonValue) Then
      FreeAndNil(LJsonValue);
  end;

  function ReadBody(AValue: String): Boolean;
  var
    LJsonValue: TRESTDWJSONInterfaceObject;
  begin
    LJsonValue := Nil;
    Result := False;

    try
      LJsonValue := TRESTDWJSONInterfaceObject.Create(AValue);
      Result := Trim(LJsonValue.PairByName['iss'].Name) <> '';

      if Result then
      begin
        Result := FServerSignature = LTokenValue.vCripto.Decrypt
          (LJsonValue.PairByName['iss'].Value);

        if Result then
        begin
          Result := False;
          FServerSignature := LTokenValue.vCripto.Decrypt
            (LJsonValue.PairByName['iss'].Value);
          Result := Trim(LJsonValue.PairByName['iat'].Name) <> '';

          if Result then
          Begin
            Result := False;

            if FTokenType = rdwTS then
              FBeginTime := TTokenValue.DateTimeFromISO8601
                (LJsonValue.PairByName['iat'].Value)
            else
              FBeginTime :=
                UnixToDateTime
                (StrToInt64(LJsonValue.PairByName['iat'].Value), False);
          end;

          Result := Trim(LJsonValue.PairByName['secrets'].Name) <> '';

          if Result then
            FSecrets := DecodeStrings(LJsonValue.PairByName['secrets']
              .Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});

          if Trim(LJsonValue.PairByName['exp'].Name) <> '' Then
          begin
            Result := False;

            if FTokenType = rdwTS then
              FEndTime := TTokenValue.DateTimeFromISO8601
                (LJsonValue.PairByName['exp'].Value)
            else
              FEndTime := UnixToDateTime
                (StrToInt64(LJsonValue.PairByName['exp'].Value), False);

            Result := Now < FEndTime;
          end;
        end;
      end
      else
        Result := FLifeCycle = 0;
    except

    end;

    if Assigned(LJsonValue) Then
      FreeAndNil(LJsonValue);
  end;

begin
  LHeader := '';
  LBody := '';
  LStringComparer := '';
  AValue := StringReplace(AValue, ' ', '+', [rfReplaceAll]);
  // Remove espaços na Token e add os caracteres "+" em seu lugar
  LHeader := Copy(AValue, InitStrPos, Pos('.', AValue) - 1);

  Delete(AValue, InitStrPos, Pos('.', AValue));

  LBody := Copy(AValue, InitStrPos, Pos('.', AValue) - 1);

  Delete(AValue, InitStrPos, Pos('.', AValue));

  LStringComparer := AValue;
  Result := (Trim(LHeader) <> '') And (Trim(LBody) <> '') And
    (Trim(LStringComparer) <> '');

  if Result then
  begin
    Result := ReadHeader(DecodeStrings(LHeader{$IFDEF RESTDWLAZARUS},
      csUndefined{$ENDIF}));

    if Result then
    begin
      Result := False;
      LTokenValue := TTokenValue.Create;

      try
        LTokenValue.TokenHash := FTokenHash;
        LTokenValue.CryptType := FCryptType;
        LStringComparer := LTokenValue.vCripto.Decrypt(LStringComparer);
        Result := LStringComparer = LHeader + '.' + LBody;

        if Result then
        begin
          Result := False;
          LHeader := DecodeStrings(LHeader{$IFDEF RESTDWLAZARUS},
            csUndefined{$ENDIF});
          LBody := DecodeStrings(LBody{$IFDEF RESTDWLAZARUS},
            csUndefined{$ENDIF});
          Secrets := DecodeStrings(GetSecretsValue(LBody){$IFDEF RESTDWLAZARUS},
            csUndefined{$ENDIF});
          Secrets := DecodeStrings
            (GetSecretsValue(Secrets){$IFDEF RESTDWLAZARUS},
            csUndefined{$ENDIF});
          Result := ReadBody(LBody);
        end;
      finally
        FreeAndNil(LTokenValue);
      end;
    end;
  end;
end;

{ TRESTDWAuthOAuth }

function TRESTDWAuthOAuth.AuthValidate(ADataModuleRESTDW: TObject;
  AUrlToExec, AWelcomeMessage, AAccessTag, AAuthUsername, AAuthPassword: String;
  ARawHeaders: TStrings; ARequestType: TRequestType;
  var ADWParams: TRESTDWParams; var AGetToken, ATokenValidate: Boolean;
  var AToken: String; var AErrorCode: Integer; var AErrorMessage: String;
  var AAcceptAuth: Boolean): Boolean;
begin
  AAcceptAuth := False;
  Result := False;
  raise Exception.Create(cErrorOAuthNotImplenented);
end;

constructor TRESTDWAuthOAuth.Create(aOwner: TComponent);
begin
  inherited;
  FClientID := '';
  FClientSecret := '';
  FToken := '';
  FRedirectURI := '';
  FGrantType := 'client_credentials';
  FGetTokenEvent := 'access-token';
  FGrantCodeEvent := 'authorize';
  FAutoBuildHex := False;
  FExpiresIn := 0;
  FTokenType := rdwOATBasic;
end;

{ TRESTDWAuthenticatorBase }

constructor TRESTDWAuthenticatorBase.Create(aOwner: TComponent);
begin
  inherited;
  FAuthDialog := True;
end;

destructor TRESTDWAuthenticatorBase.Destroy;
begin

  inherited;
end;

end.
