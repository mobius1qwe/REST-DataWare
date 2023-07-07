unit uRESTDWBasicClass;

{$I ..\..\Source\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

Uses
  SysUtils, Classes,
  uRESTDWAbout, uRESTDWConsts, uRESTDWDataUtils, uRESTDWComponentEvents,
  uRESTDWBasicTypes;

Type
 TRESTDWClientRESTBase = Class(TRESTDWComponent) //Novo Componente de Acesso a Requisições REST para o Servidores Diversos
 Private
  //Variáveis, Procedures e Funções Privadas
  vRSCharset           : TEncodeSelect;
  vLastErrorCode,
  vRedirectMaximum     : Integer;
  vDefaultCustomHeader : TStrings;
  vOnWorkBegin,
  vOnWork              : TOnWork;
  vOnWorkEnd           : TOnWorkEnd;
  vOnStatus            : TOnStatus;
  vAuthOptionParams    : TRESTDWClientAuthOptionParams;
  vMaxAuthRetries      : Integer;
  vLastErrorMessage,
  vCharset,
  vAUrl,
  vContentEncoding,
  vAccept,
  vAccessControlAllowOrigin,
  vUserAgent,
  vAcceptEncoding,
  vContentType         : String;
  vTransparentProxy    : TProxyConnectionInfo;
  vAllowCookies,
  vHandleRedirects,
  vUseSSL              : Boolean;
  vConnectTimeOut,
  vRequestTimeOut      : Integer;
  vOnBeforeGet         : TPrepareGet;
  vOnBeforePost,
  vOnBeforePut,
  vOnBeforeDelete,
  vOnBeforePatch       : TPrepareEvent;
  vOnAfterRequest      : TAfterRequest;
  vOnHeadersAvailable  : TOnHeadersAvailable;
  Procedure SetAuthOptionParams(Value    : TRESTDWClientAuthOptionParams);
  Procedure SetDefaultCustomHeader(Value : TStrings);
  Function  GetUseSSL                    : Boolean;
  Function  GetAllowCookies              : Boolean;
  Procedure SetAllowCookies   (Value     : Boolean);
  Function  GetHandleRedirects           : Boolean;
  Procedure SetHandleRedirects(Value     : Boolean);
 Public
  Procedure SetHeaders (AHeaders         : TStringList); Virtual;Abstract;
  Procedure SetUseSSL  (Value            : Boolean);     Virtual;
  Procedure SetOnWork          (Value    : TOnWork);     Virtual;
  Procedure SetOnWorkBegin     (Value    : TOnWork);     Virtual;
  Procedure SetOnWorkEnd       (Value    : TOnWorkEnd);  Virtual;
  Procedure SetOnStatus        (Value    : TOnStatus);   Virtual;
  Procedure DestroyClient;                               Virtual;Abstract;
  Constructor Create           (AOwner   : TComponent);  Override;
  Destructor  Destroy;Override;
  Function   Get       (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;Virtual;
  Function   Get       (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        IgnoreEvents    : Boolean        = False):String; Overload;Virtual;
  Function   Post      (AUrl             : String         = '';
                        CustomHeaders    : TStringList    = Nil;
                        Const CustomBody : TStream        = Nil;
                        IgnoreEvents     : Boolean        = False;
                        RawHeaders       : Boolean        = False):Integer;Overload;Virtual;
  Function   Post      (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        CustomBody      : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;Virtual;
  Function   Post      (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        FileName        : String         = '';
                        FileStream      : TStream        = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;Virtual;
  Function   Post      (AUrl            : String;
                        var AResponseText : String;
                        CustomHeaders   : TStringList    = Nil;
                        CustomParams    : TStringList    = Nil;
                        Const CustomBody : TStream        = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;Virtual;
  Function   Post      (AUrl            : String;
                        CustomHeaders   : TStringList    = Nil;
                        CustomParams    : TStringList    = Nil;
                        FileName        : String         = '';
                        FileStream      : TStream        = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;Virtual;
  Function   Put       (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;Virtual;
  Function   Put       (AUrl            : String         = '';
                        CustomHeaders    : TStringList    = Nil;
                        Const CustomBody : TStream        = Nil;
                        Const AResponse  : TStream        = Nil;
                        IgnoreEvents     : Boolean        = False):Integer;Overload;Virtual;
  Function   Put       (AUrl             : String         = '';
                        CustomHeaders    : TStringList    = Nil;
                        FileName         : String         = '';
                        FileStream       : TStream        = Nil;
                        Const AResponse  : TStream        = Nil;
                        IgnoreEvents     : Boolean        = False):Integer;Overload;Virtual;
  Function   Put       (AUrl            : String         = '';
                        CustomHeaders    : TStringList    = Nil;
                        CustomParams     : TStringList    = Nil;
                        Const CustomBody : TStream        = Nil;
                        Const AResponse  : TStream        = Nil;
                        IgnoreEvents     : Boolean        = False):Integer;Overload;Virtual;
  Function   Put       (AUrl            : String         = '';
                        CustomHeaders    : TStringList    = Nil;
                        CustomParams     : TStringList    = Nil;
                        FileName         : String         = '';
                        FileStream       : TStream        = Nil;
                        Const AResponse  : TStream        = Nil;
                        IgnoreEvents     : Boolean        = False):Integer;Overload;Virtual;
  Function   Patch     (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;Virtual;
  Function   Patch     (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        CustomBody      : TStream        = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;Virtual;
  Function   Patch     (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        CustomParams    : TStringList    = Nil;
                        CustomBody      : TStream        = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;Virtual;
  Function   Patch     (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        CustomParams    : TStringList    = Nil;
                        FileName        : String         = '';
                        FileStream      : TStream        = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;Virtual;
  Function   Delete    (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;Virtual;
  Function   Delete    (AUrl              : String;
                        CustomHeaders     : TStringList  = Nil;
                        CustomParams      : TStringList  = Nil;
                        Const AResponse   : TStream      = Nil;
                        IgnoreEvents      : Boolean      = False):Integer;Overload;Virtual;
  Property ActiveRequest            : String                        Read vAUrl                     Write vAUrl;
  Property LastErrorMessage         : String                        Read vLastErrorMessage         Write vLastErrorMessage;
  Property LastErrorCode            : Integer                       Read vLastErrorCode            Write vLastErrorCode;
 Published
  Property UseSSL                   : Boolean                       Read GetUseSSL                 Write SetUseSSL;
  Property UserAgent                : String                        Read vUserAgent                Write vUserAgent;
  Property Accept                   : String                        Read vAccept                   Write vAccept;
  Property Charset                  : String                        Read vCharset                  Write vCharset;
  Property AcceptEncoding           : String                        Read vAcceptEncoding           Write vAcceptEncoding;
  Property ContentEncoding          : String                        Read vContentEncoding          Write vContentEncoding;
  Property MaxAuthRetries           : Integer                       Read vMaxAuthRetries           Write vMaxAuthRetries;
  Property ContentType              : String                        Read vContentType              Write vContentType;
  Property RequestCharset           : TEncodeSelect                 Read vRSCharset                Write vRSCharset;
  Property DefaultCustomHeader      : TStrings                      Read vDefaultCustomHeader      Write SetDefaultCustomHeader;
  Property RequestTimeOut           : Integer                       Read vRequestTimeOut           Write vRequestTimeOut;
  Property ConnectTimeOut           : Integer                       Read vConnectTimeOut           Write vConnectTimeOut;
  Property RedirectMaximum          : Integer                       Read vRedirectMaximum          Write vRedirectMaximum;
  Property AllowCookies             : Boolean                       Read GetAllowCookies           Write SetAllowCookies;
  Property HandleRedirects          : Boolean                       Read GetHandleRedirects        Write SetHandleRedirects;
  Property AuthenticationOptions    : TRESTDWClientAuthOptionParams Read vAuthOptionParams         Write SetAuthOptionParams;
  Property AccessControlAllowOrigin : String                        Read vAccessControlAllowOrigin Write vAccessControlAllowOrigin;
  Property ProxyOptions             : TProxyConnectionInfo          Read vTransparentProxy         Write vTransparentProxy;
  Property OnWork                   : TOnWork                       Read vOnWork                   Write SetOnWork;
  Property OnWorkBegin              : TOnWork                       Read vOnWorkBegin              Write SetOnWorkBegin;
  Property OnWorkEnd                : TOnWorkEnd                    Read vOnWorkEnd                Write SetOnWorkEnd;
  Property OnStatus                 : TOnStatus                     Read vOnStatus                 Write SetOnStatus;
  Property OnBeforeGet              : TPrepareGet                   Read vOnBeforeGet              Write vOnBeforeGet;
  Property OnBeforePost             : TPrepareEvent                 Read vOnBeforePost             Write vOnBeforePost;
  Property OnBeforePut              : TPrepareEvent                 Read vOnBeforePut              Write vOnBeforePut;
  Property OnBeforeDelete           : TPrepareEvent                 Read vOnBeforeDelete           Write vOnBeforeDelete;
  Property OnBeforePatch            : TPrepareEvent                 Read vOnBeforePatch            Write vOnBeforePatch;
  Property OnAfterRequest           : TAfterRequest                 Read vOnAfterRequest           Write vOnAfterRequest;
  Property OnHeadersAvailable       : TOnHeadersAvailable           Read vOnHeadersAvailable       Write vOnHeadersAvailable;
End;

implementation

Procedure TRESTDWClientRESTBase.SetOnWork(Value : TOnWork);
Begin
  vOnWork := Value;
End;

Procedure TRESTDWClientRESTBase.SetOnWorkBegin(Value: TOnWork);
Begin
  vOnWorkBegin := Value;
End;

procedure TRESTDWClientRESTBase.SetOnWorkEnd(Value: TOnWorkEnd);
begin
  vOnWorkEnd := Value;
end;

procedure TRESTDWClientRESTBase.SetOnStatus(Value: TOnStatus);
begin
  vOnStatus := Value;
end;

Procedure TRESTDWClientRESTBase.SetAllowCookies(Value : Boolean);
Begin
 vAllowCookies := Value;
End;

Procedure TRESTDWClientRESTBase.SetAuthOptionParams(Value : TRESTDWClientAuthOptionParams);
Begin
 vAuthOptionParams.Assign(Value);
End;

Procedure TRESTDWClientRESTBase.SetDefaultCustomHeader(Value: TStrings);
Begin
 vDefaultCustomHeader.Assign(value);
End;

Procedure TRESTDWClientRESTBase.SetUseSSL(Value     : Boolean);
Begin
 vUseSSL := Value;
End;

Function TRESTDWClientRESTBase.GetUseSSL : Boolean;
Begin
 Result := vUseSSL;
End;

Procedure TRESTDWClientRESTBase.SetHandleRedirects(Value : Boolean);
Begin
 vHandleRedirects := Value;
End;

Constructor TRESTDWClientRESTBase.Create(AOwner: TComponent);
Begin
 Inherited;
 vContentType                    := cDefaultContentType;
 vContentEncoding                := cContentTypeMultiPart;
 vAccept                         := cDefaultAccept;
 vAcceptEncoding                 := '';
 vCharset                        := 'utf8';
 vMaxAuthRetries                 := 0;
 vUserAgent                      := cUserAgent;
 vAuthOptionParams               := TRESTDWClientAuthOptionParams.Create(Self);
 vTransparentProxy               := TProxyConnectionInfo.Create;
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vAccessControlAllowOrigin       := '*';
 vAUrl                           := '';
 vRedirectMaximum                := 1;
 vDefaultCustomHeader            := TStringList.Create;
 vLastErrorCode                  := 0;
 vLastErrorMessage               := '';
 {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
  vRSCharset                     := esUtf8;
 {$ELSE}
  vRSCharset                     := esAnsi;
 {$IFEND}
 vRequestTimeOut                 := 5000;
 vConnectTimeOut                 := 5000;
End;

Function TRESTDWClientRESTBase.Delete(AUrl            : String;
                                      CustomHeaders   : TStringList;
                                      Const AResponse : TStream;
                                      IgnoreEvents    : Boolean): Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Delete(AUrl            : String;
                                      CustomHeaders,
                                      CustomParams    : TStringList;
                                      Const AResponse : TStream;
                                      IgnoreEvents    : Boolean): Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Destructor TRESTDWClientRESTBase.Destroy;
Begin
 FreeAndNil(vDefaultCustomHeader);
 FreeAndNil(vTransparentProxy);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Function TRESTDWClientRESTBase.Get(AUrl            : String;
                                   CustomHeaders   : TStringList;
                                   Const AResponse : TStream;
                                   IgnoreEvents    : Boolean) : Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Get(AUrl          : String;
                                   CustomHeaders : TStringList;
                                   IgnoreEvents  : Boolean): String;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.GetAllowCookies : Boolean;
Begin
 Result := vAllowCookies;
End;

Function TRESTDWClientRESTBase.GetHandleRedirects : Boolean;
Begin
 Result := vHandleRedirects;
End;

Function TRESTDWClientRESTBase.Patch(AUrl            : String;
                                     CustomHeaders,
                                     CustomParams    : TStringList;
                                     FileName        : String;
                                     FileStream      : TStream;
                                     Const AResponse : TStream;
                                     IgnoreEvents    : Boolean) : Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Patch(AUrl            : String;
                                     CustomHeaders   : TStringList;
                                     Const AResponse : TStream;
                                     IgnoreEvents    : Boolean) : Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Patch(AUrl            : String;
                                     CustomHeaders   : TStringList;
                                     CustomBody      : TStream;
                                     Const AResponse : TStream;
                                     IgnoreEvents    : Boolean): Integer;
Begin

End;

Function TRESTDWClientRESTBase.Patch(AUrl            : String;
                                     CustomHeaders,
                                     CustomParams    : TStringList;
                                     CustomBody      : TStream;
                                     Const AResponse : TStream;
                                     IgnoreEvents    : Boolean): Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Post  (AUrl             : String;
                                      CustomHeaders    : TStringList;
                                      Const CustomBody : TStream;
                                      IgnoreEvents,
                                      RawHeaders       : Boolean) : Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Post  (AUrl            : String         = '';
                                      CustomHeaders   : TStringList    = Nil;
                                      CustomBody      : TStringList    = Nil;
                                      Const AResponse : TStringStream  = Nil;
                                      IgnoreEvents    : Boolean        = False;
                                      RawHeaders      : Boolean        = False):Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Post  (AUrl              : String;
                                      Var AResponseText : String;
                                      CustomHeaders     : TStringList    = Nil;
                                      CustomParams      : TStringList    = Nil;
                                      Const CustomBody  : TStream        = Nil;
                                      Const AResponse   : TStream        = Nil;
                                      IgnoreEvents      : Boolean        = False;
                                      RawHeaders        : Boolean        = False):Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Post  (AUrl            : String;
                                      CustomHeaders   : TStringList;
                                      FileName        : String;
                                      FileStream      : TStream;
                                      Const AResponse : TStream;
                                      IgnoreEvents,
                                      RawHeaders      : Boolean) : Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Post  (AUrl            : String;
                                      CustomHeaders,
                                      CustomParams    : TStringList;
                                      FileName        : String;
                                      FileStream      : TStream;
                                      Const AResponse : TStream;
                                      IgnoreEvents,
                                      RawHeaders      : Boolean): Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Put   (AUrl              : String;
                                      CustomHeaders,
                                      CustomParams      : TStringList;
                                      Const CustomBody,
                                      AResponse         : TStream;
                                      IgnoreEvents      : Boolean): Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Put   (AUrl            : String;
                                      CustomHeaders,
                                      CustomParams    : TStringList;
                                      FileName        : String;
                                      FileStream      : TStream;
                                      Const AResponse : TStream;
                                      IgnoreEvents    : Boolean) : Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Put   (AUrl            : String;
                                      CustomHeaders   : TStringList;
                                      FileName        : String;
                                      FileStream      : TStream;
                                      Const AResponse : TStream;
                                      IgnoreEvents    : Boolean): Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Put   (AUrl            : String;
                                      CustomHeaders   : TStringList;
                                      Const AResponse : TStream;
                                      IgnoreEvents    : Boolean): Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

Function TRESTDWClientRESTBase.Put   (AUrl              : String;
                                      CustomHeaders     : TStringList;
                                      Const CustomBody,
                                      AResponse         : TStream;
                                      IgnoreEvents      : Boolean): Integer;
Begin
 Raise Exception.Create(cMethodNotImplemented);
End;

end.
