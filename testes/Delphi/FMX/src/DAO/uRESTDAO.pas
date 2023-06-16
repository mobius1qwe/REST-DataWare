unit uRESTDAO;

interface

uses
  System.JSON, uConsts, System.SysUtils, System.Classes,
  REST.Client, REST.Types, REST.Authenticator.Basic

    ;

type
  TRESTDAO = Class
  private
    FRESTAPI: TRESTRequest;
    FClientAPI: TRESTClient;
    FBasicAuth: THTTPBasicAuthenticator;
    FServer: String;
  public
    constructor Create(aServer, aPort: string);
    destructor Destroy; override;
    procedure SetBasicAuth(user, password: string);
    function TesteEndpoint(aEndpoint: string; aMethod: TTestRequestMethod;
      out erro: string): boolean;
    function TesteConcorrente(aEndpoint: string; aMethod: TTestRequestMethod;
      cRepeat, cRequests: integer): boolean;
  End;

implementation

{ TRESTDAO }

constructor TRESTDAO.Create(aServer, aPort: string);
begin
  FClientAPI := TRESTClient.Create(nil);
  FClientAPI.AddParameter('Connection', 'close', pkHTTPHEADER);
  FRESTAPI := TRESTRequest.Create(nil);
  try
    FServer := aServer + ':' + aPort;

    FClientAPI.BaseURL := FServer;
    FRESTAPI.Client := FClientAPI;

    FClientAPI.UserAgent := 'RDWTestFMX Tool v1.0';
  except
  end;
end;

destructor TRESTDAO.Destroy;
begin
  FRESTAPI.Response := nil;

  if FBasicAuth <> nil then
    FBasicAuth.Free;
  FClientAPI.Free;
  FRESTAPI.Free;

  inherited;
end;

procedure TRESTDAO.SetBasicAuth(user, password: string);
begin
  if FBasicAuth = nil then
    FBasicAuth := THTTPBasicAuthenticator.Create(nil);
  FBasicAuth.Username := user;
  FBasicAuth.password := password;
  FClientAPI.Authenticator := FBasicAuth;
end;

function TRESTDAO.TesteConcorrente(aEndpoint: string;
  aMethod: TTestRequestMethod; cRepeat, cRequests: integer): boolean;
begin

end;

function TRESTDAO.TesteEndpoint(aEndpoint: string; aMethod: TTestRequestMethod;
  out erro: string): boolean;
var
  expectedCode: integer;
  currentmethod: string;
begin
  Result := false;
  FRESTAPI.Response := nil;
  FRESTAPI.Resource := aEndpoint;
  case aMethod of
    rtmGET:
      begin
        FRESTAPI.Method := rmGET;
        currentmethod := 'GET';
        expectedCode := 200;
      end;
    rtmPOST:
      begin
        FRESTAPI.Method := rmPOST;
        currentmethod := 'POST';
        expectedCode := 201;
      end;
    rtmPUT:
      begin
        FRESTAPI.Method := rmPUT;
        currentmethod := 'PUT';
        expectedCode := 201;
      end;
    rtmPATCH:
      begin
        FRESTAPI.Method := rmPATCH;
        currentmethod := 'PATCH';
        expectedCode := 201;
      end;
    rtmDELETE:
      begin
        FRESTAPI.Method := rmDELETE;
        currentmethod := 'DELETE';
        expectedCode := 200;
      end;
  end;

  try
    FRESTAPI.Execute;
    Result := FRESTAPI.Response.StatusCode = expectedCode;
  except
    on e: exception do
    begin
      Result := false;
      erro := Format('Método %s falhou, com erro "%s" e status code: "%d"',
        [currentmethod, e.Message, FRESTAPI.Response.StatusCode]);
    end;
  end;
end;

end.
