unit uRESTDWBasic;

{$I ..\Includes\uRESTDWPlataform.inc}

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
}

interface

Uses
 {$IFNDEF FPC}
  {$IF Defined(RESTDWFMX)}System.IOUtils,{$IFEND}
 {$ENDIF}
 SysUtils, Classes, Db, Variants, SyncObjs,
 uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWProtoTypes, uRESTDWJSONObject,
 uRESTDWParams, uRESTDWMassiveBuffer, uRESTDWDataUtils,
 uRESTDWTools, uRESTDWConsts, uRESTDWMessageCoderMIME,
 uRESTDWZLib, uRESTDWMimeTypes, uRESTDWAbout;

 type
  TRedirect = Procedure(Url : String;
                     AResponse   : TObject) {$IFNDEF FPC}Of Object{$ENDIF};

type
  TJvComponent = class(TRESTDWComponent)
  private
  published
  end;

 Type
  TServerMethodClass = Class(TComponent)
 End;

 Type
  TClassNull= Class(TComponent)
 End;

Type
 TRESTDWClientIpVersions = (civIPv4, civIPv6);

Type
 TRESTDWServerIpVersions = (sivIPv4, sivIPv6, sivBoth);

Type
 TRESTDWServerIpVersionConfig = class(TPersistent)
 Private
  //IP version select
  vServerIpVersion: TRESTDWServerIpVersions;
  //IPv4
  vIPv4Address: String;
  //IPv6
  vIPv6Address: String;
 Public
  Constructor Create;
  Destructor  Destroy;
 Published
  Property ServerIpVersion : TRESTDWServerIpVersions   Read vServerIpVersion  Write vServerIpVersion default sivIPv4;
  Property IPv4Address     : String                    Read vIPv4Address      Write vIPv4Address;
  Property IPv6Address     : String                    Read vIPv6Address      Write vIPv6Address;
end;

Type
 TRESTDWConnectionServerCP = Class(TCollectionItem)
 Private
  vTransparentProxy     : TProxyConnectionInfo;
  vAuthentication,
  vEncodeStrings,
  vCompression,
  vActive               : Boolean;
  vTimeOut,
  vConnectTimeOut,
  vPoolerPort           : Integer;
  vDataRoute,
  vServerEventName,
  vListName,
  vAccessTag,
  vWelcomeMessage,
  vRestWebService       : String;
  vAuthOptionParams     : TRESTDWClientAuthOptionParams;
  vEncoding             : TEncodeSelect;
  {$IFDEF FPC}
  vDatabaseCharSet      : TDatabaseCharSet;
  {$ENDIF}
  vTypeRequest          : TTypeRequest;
  vCripto               : TCripto;
  Procedure SetCripto(Value : TCripto);
 Public
  Function    GetDisplayName             : String;      Override;
  Procedure   SetDisplayName(Const Value : String);     Override;
  Function    GetPoolerList : TStringList;
  Constructor Create        (aCollection : TCollection);Override;
  Destructor  Destroy;Override;//Destroy a Classe
 Published
  Property Active                : Boolean                       Read vActive               Write vActive;            //Seta o Estado da Conexão
  Property Compression           : Boolean                       Read vCompression          Write vCompression;       //Compressão de Dados
  Property CriptOptions          : TCripto                       Read vCripto               Write SetCripto;
  Property AuthenticationOptions : TRESTDWClientAuthOptionParams Read vAuthOptionParams     Write vAuthOptionParams;
  Property Authentication        : Boolean                       Read vAuthentication       Write vAuthentication      Default True;
  Property Host                  : String                        Read vRestWebService       Write vRestWebService;    //Host do WebService REST
  Property Port                  : Integer                       Read vPoolerPort           Write vPoolerPort;        //A Porta do Pooler do DataSet
  Property RequestTimeOut        : Integer                       Read vTimeOut              Write vTimeOut;           //Timeout da Requisição
  Property ConnectTimeOut        : Integer                       Read vConnectTimeOut       Write vConnectTimeOut;
  Property hEncodeStrings        : Boolean                       Read vEncodeStrings        Write vEncodeStrings;
  Property Encoding              : TEncodeSelect                 Read vEncoding             Write vEncoding;          //Encoding da string
  Property WelcomeMessage        : String                        Read vWelcomeMessage       Write vWelcomeMessage;
  Property ProxyOptions          : TProxyConnectionInfo          Read vTransparentProxy     Write vTransparentProxy;
  {$IFDEF FPC}
  Property DatabaseCharSet       : TDatabaseCharSet              Read vDatabaseCharSet      Write vDatabaseCharSet;
  {$ENDIF}
  Property Name                  : String                        Read vListName             Write vListName;
  Property AccessTag             : String                        Read vAccessTag            Write vAccessTag;
  Property TypeRequest           : TTypeRequest                  Read vTypeRequest          Write vTypeRequest       Default trHttp;
  Property ServerEventName       : String                        Read vServerEventName      Write vServerEventName;
  Property DataRoute             : String                        Read vDataRoute            Write vDataRoute;
End;

Type
 TOnFailOverExecute       = Procedure (ConnectionServer   : TRESTDWConnectionServerCP) Of Object;
 TOnFailOverError         = Procedure (ConnectionServer   : TRESTDWConnectionServerCP;
                                       MessageError       : String)                  Of Object;

Type
 TFailOverConnections = Class(TRESTDWOwnedCollection)
 Private
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec     (Index       : Integer) : TRESTDWConnectionServerCP;  Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TRESTDWConnectionServerCP);            Overload;
  Function    GetRecName(Index        : String)  : TRESTDWConnectionServerCP;  Overload;
  Procedure   PutRecName(Index        : String;
                         Item         : TRESTDWConnectionServerCP);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create     (AOwner      : TPersistent;
                          aItemClass  : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    Add                     : TCollectionItem;
  Procedure   Delete     (Index       : Integer);  Overload;
  Procedure   Delete     (Index       : String);   Overload;
  Property    Items      [Index       : Integer] : TRESTDWConnectionServerCP Read GetRec     Write PutRec; Default;
  Property    ItemsByName[Index       : String ] : TRESTDWConnectionServerCP Read GetRecName Write PutRecName;
End;

Type
 TRESTClientPoolerBase = Class(TRESTDWComponent) //Novo Componente de Acesso a Requisições REST para o RESTDataware
 Protected
  //Variáveis, Procedures e  Funções Protegidas
  vCripto           : TCripto;
  Procedure SetOnWork      (Value             : TOnWork);
  Procedure SetOnWorkBegin (Value             : TOnWork);
  Procedure SetOnWorkEnd   (Value             : TOnWorkEnd);
  Procedure SetOnStatus    (Value             : TOnStatus);
  Function  GetAllowCookies                   : Boolean;
  Procedure SetAllowCookies(Value             : Boolean);
 Private
  vClientIpVersion      : TRESTDWClientIpVersions;
  //Variáveis, Procedures e Funções Privadas
  vTransparentProxy    : TProxyConnectionInfo;
  vOnWorkBegin,
  vOnWork              : TOnWork;
  vOnWorkEnd           : TOnWorkEnd;
  vOnStatus            : TOnStatus;
  vOnFailOverExecute   : TOnFailOverExecute;
  vOnFailOverError     : TOnFailOverError;
  vOnBeforeExecute     : TOnBeforeExecute;
  vOnBeforeGetToken    : TOnBeforeGetToken;
  vTypeRequest         : TTypeRequest;
  vRSCharset           : TEncodeSelect;
  vAuthOptionParams    : TRESTDWClientAuthOptionParams;
  vAccept,
  vContentEncoding,
  vAcceptEncoding,
  vDataRoute,
  vUserAgent,
  vAccessTag,
  vWelcomeMessage,
  vPoolerNotFoundMessage,
  vLastErrorMessage,
  vContentType,
  vCharset,
  vHost                : String;
  vRequestTimeOut,
  vConnectTimeOut,
  vRedirectMaximum,
  vErrorCode,
  vPort                : Integer;
  vAllowCookies,
  vHandleRedirects,
  vPropThreadRequest,
  vBinaryRequest,
  vFailOver,
  vFailOverReplaceDefaults,
  vEncodeStrings,
  vDatacompress,
  vUseSSL,
  vAuthentication      : Boolean;
  {$IFDEF FPC}
  vDatabaseCharSet     : TDatabaseCharSet;
  {$ENDIF}
  vFailOverConnections : TFailOverConnections;
  vSSLVersions         : TRESTDWSSLVersions;
  Function    SendEvent      (EventData        : String)          : String;Overload;
  Procedure   SetDataRoute   (Value : String);
  Procedure   SetIpVersion   (IpV: TRESTDWClientIpVersions);
 Public
  //Métodos, Propriedades, Variáveis, Procedures e Funções Publicas
  Procedure   ReconfigureConnection(TypeRequest           : Ttyperequest;
                                    WelcomeMessage,
                                    Host                  : String;
                                    Port                  : Integer;
                                    Compression,
                                    EncodeStrings         : Boolean;
                                    Encoding              : TEncodeSelect;
                                    AccessTag             : String;
                                    AuthenticationOptions : TRESTDWClientAuthOptionParams);Virtual;Abstract;
  Procedure   NewToken;
  Function    RenewToken  (Var Params       : TRESTDWParams;
                           Var Error        : Boolean;
                           Var MessageError : String) : String;
  Procedure   SetAccessTag(Value            : String);
  Function    GetAccessTag                  : String;
  Function    SendEvent   (EventData        : String;
                           Var Params       : TRESTDWParams;
                           EventType        : TSendEvent = sePOST;
                           DataMode         : TDataMode  = dmDataware;
                           ServerEventName  : String     = '';
                           Assyncexec       : Boolean    = False) : String;Overload;Virtual;Abstract;
  Procedure   SetAuthOptionParams(Value     : TRESTDWClientAuthOptionParams);
  Constructor Create      (AOwner           : TComponent);Override;
  Destructor  Destroy;Override;
  Procedure   Abort;Virtual;Abstract;
  Property    LastErrorMessage     : String                        Read vLastErrorMessage        Write vLastErrorMessage;
  Property    LastErrorCode        : Integer                       Read vErrorCode               Write vErrorCode;
 Published
  //Métodos e Propriedades
  Property DataCompression         : Boolean                       Read vDatacompress            Write vDatacompress;
  Property Accept                  : String                        Read vAccept                  Write vAccept;
  Property AcceptEncoding          : String                        Read vAcceptEncoding          Write vAcceptEncoding;
  Property ContentEncoding         : String                        Read vContentEncoding         Write vContentEncoding;
  Property ContentType             : String                        Read vContentType             Write vContentType;
  Property Charset                 : String                        Read vCharset                 Write vCharset;
  Property DataRoute               : String                        Read vDataRoute               Write SetDataRoute;
  Property Encoding                : TEncodeSelect                 Read vRSCharset               Write vRSCharset;
  Property EncodedStrings          : Boolean                       Read vEncodeStrings           Write vEncodeStrings;
  Property TypeRequest             : TTypeRequest                  Read vTypeRequest             Write vTypeRequest         Default trHttp;
  Property ThreadRequest           : Boolean                       Read vPropThreadRequest       Write vPropThreadRequest;
  Property Host                    : String                        Read vHost                    Write vHost;
  Property Port                    : Integer                       Read vPort                    Write vPort                Default 8082;
  Property AuthenticationOptions   : TRESTDWClientAuthOptionParams Read vAuthOptionParams        Write SetAuthOptionParams;
  Property RequestTimeOut          : Integer                       Read vRequestTimeOut          Write vRequestTimeOut;
  Property ConnectTimeOut          : Integer                       Read vConnectTimeOut          Write vConnectTimeOut;
  Property AllowCookies            : Boolean                       Read GetAllowCookies          Write SetAllowCookies;
  Property RedirectMaximum         : Integer                       Read vRedirectMaximum         Write vRedirectMaximum;
  Property HandleRedirects         : Boolean                       Read vHandleRedirects         Write vHandleRedirects;
  Property WelcomeMessage          : String                        Read vWelcomeMessage          Write vWelcomeMessage;
  Property AccessTag               : String                        Read vAccessTag               Write vAccessTag;
  Property ProxyOptions            : TProxyConnectionInfo          Read vTransparentProxy        Write vTransparentProxy;
  Property OnWork                  : TOnWork                       Read vOnWork                  Write SetOnWork;
  Property OnWorkBegin             : TOnWork                       Read vOnWorkBegin             Write SetOnWorkBegin;
  Property OnWorkEnd               : TOnWorkEnd                    Read vOnWorkEnd               Write SetOnWorkEnd;
  Property OnStatus                : TOnStatus                     Read vOnStatus                Write SetOnStatus;
  Property OnFailOverExecute       : TOnFailOverExecute            Read vOnFailOverExecute       Write vOnFailOverExecute;
  Property OnFailOverError         : TOnFailOverError              Read vOnFailOverError         Write vOnFailOverError;
  Property OnBeforeExecute         : TOnBeforeExecute              Read vOnBeforeExecute         Write vOnBeforeExecute;
  Property OnBeforeGetToken        : TOnBeforeGetToken             Read vOnBeforeGetToken        Write vOnBeforeGetToken;
  Property FailOver                : Boolean                       Read vFailOver                Write vFailOver;
  Property UseSSL                  : Boolean                       Read vUseSSL                  Write vUseSSL;
  Property FailOverConnections     : TFailOverConnections          Read vFailOverConnections     Write vFailOverConnections;
  Property FailOverReplaceDefaults : Boolean                       Read vFailOverReplaceDefaults Write vFailOverReplaceDefaults;
  Property BinaryRequest           : Boolean                       Read vBinaryRequest           Write vBinaryRequest;
  Property CriptOptions            : TCripto                       Read vCripto                  Write vCripto;
  Property UserAgent               : String                        Read vUserAgent               Write vUserAgent;
  Property PoolerNotFoundMessage   : String                        Read vPoolerNotFoundMessage   Write vPoolerNotFoundMessage;
  Property SSLVersions             : TRESTDWSSLVersions            Read vSSLVersions             Write vSSLVersions;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet              Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
  Property ClientIpVersion         : TRESTDWClientIpVersions       Read vClientIpVersion         Write SetIpVersion default civIPv4;
 End;

 Type
  TRESTDWServiceNotificationBase = Class(TRESTDWComponent)
  Private
   vLoginMessage                  : String;
   vMultiCORE,
   vForceWelcomeAccess,
   vActive                        : Boolean;
   vServicePort,
   vServiceTimeout                : Integer;
   aServerMethod                  : TComponentClass;
   vServerAuthOptions             : TRESTDWServerAuthOptionParams;
   vOnDisconnect,
   vOnConnect,
   vOnAuthAccept                  : TRESTDWOnSessionData;
   vReceiveMessage,
   vLastRequest                   : TLastSockRequest;
   vReceiveStream                 : TLastSockStream;
   vLastResponse                  : TLastSockResponse;
   vOnConnectionRename            : TConnectionRename;
   vEncoding                      : TEncodeSelect;
   vCripto                        : TCripto;
   vProxyOptions                  : TProxyConnectionInfo;
   vAccessTag                     : String;
   vGarbageTime                   : Integer;
   vNotifyWelcomeMessage          : TNotifyWelcomeMessage;
   vRESTDwAuthError               : TRESTDWAuthError;
   {$IFDEF FPC}
   vDatabaseCharSet               : TDatabaseCharSet;
   {$ENDIF}
   Procedure  ProcessMessages;
   Procedure  SetAccessTag(Value  : String);
   Function   GetAccessTag        : String;
   Procedure  SetActive (Value    : Boolean);Virtual;Abstract;
   Procedure  Disconnect(AContext : TComponent);Virtual;Abstract;
   Procedure  Connect   (AContext : TComponent);Virtual;Abstract;
   Procedure  SetServerAuthOptions(AuthenticationOptions : TRESTDWServerAuthOptionParams);
   Procedure  SetServerMethod(Value                      : TComponentClass);
  Public
   Procedure   Execute            (AContext      : TComponent);Virtual;Abstract;
   Constructor Create             (AOwner        : TComponent);Override; //Cria o Componente
   Destructor  Destroy;Override; //Destroy a Classe
   Function    SendMessage     (aUser            : String;
                                aMessage         : String;
                                Var ErrorMessage : String) : Boolean;Virtual;Abstract;
   Function    SendStream      (aUserSource,
                                aUserDest        : String;
                                Var aStream      : TMemoryStream;
                                Var ErrorMessage : String) : Boolean;Virtual;Abstract;
   Procedure   BroadcastMessage(aMessage : String);Overload;Virtual;Abstract;
   Procedure   BroadcastStream (Var aStream    : TMemoryStream);Virtual;Abstract;
   Procedure   Kickall;Virtual;Abstract;
   Procedure   Kickuser        (aUser          : String);Virtual;Abstract;
  Published
   Property Active                : Boolean                    Read vActive                Write SetActive;
   Property ForceWelcomeAccess    : Boolean                    Read vForceWelcomeAccess    Write vForceWelcomeAccess;
   Property AuthenticationOptions : TRESTDWServerAuthOptionParams Read vServerAuthOptions     Write SetServerAuthOptions;
   Property ServerMethodClass     : TComponentClass            Read aServerMethod          Write SetServerMethod;
   Property Encoding              : TEncodeSelect              Read vEncoding              Write vEncoding;          //Encoding da string
   {$IFDEF FPC}
   Property DatabaseCharSet       : TDatabaseCharSet           Read vDatabaseCharSet       Write vDatabaseCharSet;
   {$ENDIF}
   Property CriptOptions          : TCripto                    Read vCripto                Write vCripto;
   Property MultiCORE             : Boolean                    Read vMultiCORE             Write vMultiCORE;
   Property RequestTimeout        : Integer                    Read vServiceTimeout        Write vServiceTimeout;
   Property ServicePort           : Integer                    Read vServicePort           Write vServicePort;  //A Porta do Serviço do DataSet
   Property ProxyOptions          : TProxyConnectionInfo       Read vProxyOptions          Write vProxyOptions; //Se tem Proxy diz quais as opções
   Property GarbageTime           : Integer                    Read vGarbageTime           Write vGarbageTime;
   Property AccessTag             : String                     Read vAccessTag             Write vAccessTag;
   Property LoginMessage          : String                     Read vLoginMessage          Write vLoginMessage;
   Property OnConnect             : TRESTDWOnSessionData       Read vOnConnect             Write vOnConnect;
   Property OnDisconnect          : TRESTDWOnSessionData       Read vOnDisconnect          Write vOnDisconnect;
   Property OnAuthAccept          : TRESTDWOnSessionData       Read vOnAuthAccept          Write vOnAuthAccept;
   Property OnAuthError           : TRESTDWAuthError           Read vRESTDwAuthError       Write vRESTDwAuthError;
   Property OnWelcomeMessage      : TNotifyWelcomeMessage      Read vNotifyWelcomeMessage  Write vNotifyWelcomeMessage;
   Property OnReceiveMessage      : TLastSockRequest           Read vReceiveMessage        Write vReceiveMessage;
   Property OnReceiveStream       : TLastSockStream            Read vReceiveStream         Write vReceiveStream;
   Property OnLastRequest         : TLastSockRequest           Read vLastRequest           Write vLastRequest;
   Property OnLastResponse        : TLastSockResponse          Read vLastResponse          Write vLastResponse;
   Property OnConnectionRename    : TConnectionRename          Read vOnConnectionRename    Write vOnConnectionRename;
 End;

Type
 TRESTDWSelfSignedBase = Class(TRESTDWComponent)
 Protected
 Private
 Public
End;

Type
 TRESTServiceBase = Class(TRESTDWComponent)
 Protected
 Private
  {$IFDEF FPC}
   vCriticalSection    : TRTLCriticalSection;
   vDatabaseCharSet    : TDatabaseCharSet;
  {$ELSE}
   {$IF CompilerVersion > 21}
    {$IFDEF WINDOWS}
     vCriticalSection : TRTLCriticalSection;
    {$ELSE}
     vCriticalSection : TCriticalSection;
    {$ENDIF}
   {$ELSE}
    vCriticalSection : TCriticalSection;
   {$IFEND}
  {$ENDIF}
  vBeforeUseCriptKey   : TBeforeUseCriptKey;
  vCORSCustomHeaders,
  vDefaultPage         : TStringList;
  vEncode_Errors,
  vPathTraversalRaiseError,
  vForceWelcomeAccess,
  vCORS,
  vActive                : Boolean;
  vProxyOptions          : TProxyConnectionInfo;
  vServiceTimeout,
  vServicePort           : Integer;
  vCripto                : TCripto;
  aServerMethod          : TComponentClass;
  vDataRouteList         : TRESTDWDataRouteList;
  vServerAuthOptions     : TRESTDWServerAuthOptionParams;
  vLastRequest           : TLastRequest;
  vLastResponse          : TLastResponse;
  FRootPath,
  aDefaultUrl            : String;
  vEncoding              : TEncodeSelect;
  vOnCreate              : TOnCreate;
  vSSLVersions           : TRESTDWSSLVersions;
  vServerIpVersionConfig : TRESTDWServerIpVersionConfig;
  Procedure SetCORSCustomHeader (Value : TStringList);
  Procedure SetDefaultPage (Value : TStringList);
  Procedure SetServerMethod(Value                     : TComponentClass);
//  Procedure Loaded; Override;
  Procedure GetTableNames            (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetFieldNames            (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetKeyFieldNames         (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetPoolerList            (ServerMethodsClass      : TComponent;
                                      Var PoolerList          : String;
                                      AccessTag               : String);
  Function  ServiceMethods           (BaseObject              : TComponent;
                                      AContext                : TComponent;
                                      UrlToExec,
                                      Poolername              : String;
                                      Var DWParams            : TRESTDWParams;
                                      Var JSONStr             : String;
                                      Var DataMode            : TDataMode;
                                      Var ErrorCode           : Integer;
                                      Var ContentType         : String;
                                      Var ServerContextCall   : Boolean;
                                      Var ServerContextStream : TMemoryStream;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      WelcomeAccept           : Boolean;
                                      Const RequestType       : TRequestType;
                                      mark                    : String;
                                      RequestHeader           : TStringList;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean;
                                      CompareContext          : Boolean) : Boolean;
  Procedure ExecuteCommandPureJSON   (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandPureJSONTB (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandJSON       (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandJSONTB     (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure InsertMySQLReturnID      (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdatesJSON         (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings,
                                      BinaryEvent             : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdatesJSONTB       (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings,
                                      BinaryEvent             : Boolean;
                                      AccessTag               : String);
  Procedure OpenDatasets             (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryRequest           : Boolean;
                                      BinaryCompatible        : Boolean);
  Procedure ApplyUpdates_MassiveCache(ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdates_MassiveCacheTB(ServerMethodsClass    : TComponent;
                                        Var Pooler            : String;
                                        Var DWParams          : TRESTDWParams;
                                        ConnectionDefs        : TConnectionDefs;
                                        hEncodeStrings        : Boolean;
                                        AccessTag             : String);
  Procedure ProcessMassiveSQLCache   (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetEvents                (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var DWParams            : TRESTDWParams);
  Function ReturnEvent               (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var vResult             : String;
                                      Var DWParams            : TRESTDWParams;
                                      Var DataMode            : TDataMode;
                                      Var ErrorCode           : Integer;
                                      Var ContentType,
                                      AccessTag               : String;
                                      Const RequestType       : TRequestType;
                                      Var   RequestHeader     : TStringList) : Boolean;
  Procedure GetServerEventsList      (ServerMethodsClass      : TComponent;
                                      Var ServerEventsList    : String;
                                      AccessTag               : String);
  Function ReturnContext             (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var vResult,
                                      ContentType             : String;
                                      Var ServerContextStream : TMemoryStream;
                                      Var Error               : Boolean;
                                      Var   DWParams          : TRESTDWParams;
                                      Const RequestType       : TRequestType;
                                      mark                    : String;
                                      RequestHeader           : TStringList;
                                      Var ErrorCode           : Integer) : Boolean;
  Procedure SetServerAuthOptions     (AuthenticationOptions   : TRESTDWServerAuthOptionParams);
 Public
  Procedure EchoPooler               (ServerMethodsClass      : TComponent;
                                      AContext                : TComponent;
                                      Var Pooler, MyIP        : String;
                                      AccessTag               : String;
                                      Var InvalidTag          : Boolean);Virtual;Abstract;
  Procedure SetActive                (Value               : Boolean);Virtual;
  Function CommandExec     (Const AContext        : TComponent;
                            Url,
                            RawHTTPCommand        : String;
                            Var ContentType       : String;
                            ClientIP,
                            UserAgent,
                            AuthUsername,
                            AuthPassword,
                            Token                 : String;
                            RequestHeaders        : TStringList;
                            ClientPort            : Integer;
                            RawHeaders,
                            Params                : TStrings;
                            QueryParams           : String;
                            ContentStringStream   : TStream;
                            Var AuthRealm,
                            sCharSet,
                            ErrorMessage          : String;
                            Var StatusCode        : Integer;
                            Var ResponseHeaders   : TStringList;
                            Var ResponseString    : String;
                            Var ResultStream      : TStream;
                            Var CORSCustomHeaders : TStrings;
                            Redirect              : TRedirect) : Boolean;
  Procedure   ClearDataRoute;
  Procedure   AddDataRoute (DataRoute           : String; MethodClass : TComponentClass);
  Function    GetDataRouteCount: integer;
  Constructor Create       (AOwner              : TComponent);Override;//Cria o Componente
  Destructor  Destroy; Override;//Destroy a Classe
 Published
  Property Active                  : Boolean                       Read vActive                  Write SetActive;
  Property CORS                    : Boolean                       Read vCORS                    Write vCORS;
  Property CORS_CustomHeaders      : TStringList                   Read vCORSCustomHeaders       Write SetCORSCustomHeader;
  Property DefaultPage             : TStringList                   Read vDefaultPage             Write SetDefaultPage;
  Property DefaultUrl              : String                        Read aDefaultUrl              Write aDefaultUrl;
  Property PathTraversalRaiseError : Boolean                       Read vPathTraversalRaiseError Write vPathTraversalRaiseError;
  Property RequestTimeout          : Integer                       Read vServiceTimeout          Write vServiceTimeout;
  Property ServicePort             : Integer                       Read vServicePort             Write vServicePort;  //A Porta do Serviço do DataSet
  Property ProxyOptions            : TProxyConnectionInfo          Read vProxyOptions            Write vProxyOptions; //Se tem Proxy diz quais as opções
  Property AuthenticationOptions   : TRESTDWServerAuthOptionParams Read vServerAuthOptions       Write SetServerAuthOptions;
  Property ServerMethodClass       : TComponentClass               Read aServerMethod            Write SetServerMethod;
  Property OnLastRequest           : TLastRequest                  Read vLastRequest             Write vLastRequest;
  Property OnLastResponse          : TLastResponse                 Read vLastResponse            Write vLastResponse;
  Property Encoding                : TEncodeSelect                 Read vEncoding                Write vEncoding;          //Encoding da string
  Property RootPath                : String                        Read FRootPath                Write FRootPath;
  Property ForceWelcomeAccess      : Boolean                       Read vForceWelcomeAccess      Write vForceWelcomeAccess;
  Property OnBeforeUseCriptKey     : TBeforeUseCriptKey            Read vBeforeUseCriptKey       Write vBeforeUseCriptKey;
  Property CriptOptions            : TCripto                       Read vCripto                  Write vCripto;
  Property EncodeErrors            : Boolean                       Read vEncode_Errors           Write vEncode_Errors;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet              Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
  Property OnCreate                : TOnCreate                     Read vOnCreate                Write vOnCreate;
  Property SSLVersions             : TRESTDWSSLVersions            Read vSSLVersions             Write vSSLVersions;
  Property ServerIPVersionConfig   : TRESTDWServerIpVersionConfig  Read vServerIpVersionConfig   Write vServerIpVersionConfig;
End;

//Heranças para Servidores Standalone
Type
 TRESTServicePoolerBase   = Class(TRESTServiceBase)
End;

Type
 TRESTShellServicesBase   = Class(TRESTServiceBase)
 Private
  Procedure Loaded; Override;
 Protected
  Procedure Notification              (AComponent            : TComponent;
                                       Operation             : TOperation); Override;
 Public
  Procedure Command                   (ARequest              : TComponent;
                                       AResponse             : TComponent;
                                       Var Handled           : Boolean);Virtual;Abstract;
  Constructor Create                  (AOwner                : TComponent); Override; //Cria o Componente
  Destructor  Destroy;Override;
 Published
  Property    OnCreate : TOnCreate     Read vOnCreate        Write vOnCreate;
End;

//Heranças para Servidores CGI/Isapi
Type
 TRESTServiceShareBase    = Class(TRESTServiceBase)
 Protected
  Property ServicePort;
  Property ProxyOptions;
  Property Active;
 Public
  Constructor Create(AOwner: TComponent);Override;
End;

 Procedure SaveLogData(Filename, Content : String);

Implementation

Uses uRESTDWDatamodule,   uRESTDWPoolermethod,
     uRESTDWServerEvents, uRESTDWServerContext, uRESTDWMessageCoder,
     uRESTDWBasicDB,      uRESTDWBufferBase,    ZLib;

Procedure SaveLogData(Filename, Content : String);
{$IF not(Defined(FPC)) AND (CompilerVersion < 21)}
Var
  vFileData: TFileStream;
Begin
  vFileData := TFileStream.Create(Filename, fmCreate);
  try
    vFileData.WriteBuffer(Pointer(Content)^, Length(Content));
  finally
    FreeAndNil(vFileData);
  end;
{$ELSE}
Var
 vFileData : TStringStream;
Begin
 vFileData := TStringStream.Create(Content);
 Try
   vFileData.SaveToFile(Filename);
 Finally
  FreeAndNil(vFileData);
 End;
{$IFEND}
End;

Function GetParamsReturn(Params : TRESTDWParams) : String;
Var
 A, I : Integer;
Begin
 A := 0;
 Result := '';
 If Assigned(Params) Then
  Begin
   For I := 0 To Params.Count -1 Do
    Begin
     If TJSONParam(TList(Params).Items[I]^).ObjectDirection in [odOUT, odINOUT] Then
      Begin
       If A = 0 Then
        Result := TJSONParam(TList(Params).Items[I]^).ToJSON
       Else
        Result := Result + ', ' + TJSONParam(TList(Params).Items[I]^).ToJSON;
       Inc(A);
      End;
    End;
  End;
 If Trim(Result) = '' Then
  Result := 'null';
End;

Procedure TRESTDWServiceNotificationBase.ProcessMessages;
Begin
// {$IFNDEF FPC}
//  {$IF Defined(RESTDWFMX)}
//   {$IF Defined(RESTDWWINDOWS)}
//    FMX.Forms.TApplication.ProcessMessages;
//   {$IFEND}
//  {$ELSE}{$IF Defined(RESTDWWINDOWS)}Application.Processmessages;{$IFEND}{$IFEND}
// {$ENDIF}
 Sleep(1);
End;

Procedure TRESTDWServiceNotificationBase.SetAccessTag   (Value    : String);
Begin
 vAccessTag := Value;
End;

Function TRESTDWServiceNotificationBase.GetAccessTag              : String;
Begin
 Result := vAccessTag;
End;

Procedure TRESTDWServiceNotificationBase.SetServerAuthOptions(AuthenticationOptions : TRESTDWServerAuthOptionParams);
Begin
 If AuthenticationOptions <> Nil Then
  vServerAuthOptions := AuthenticationOptions;
End;

Procedure TRESTDWServiceNotificationBase.SetServerMethod     (Value                 : TComponentClass);
Begin
 {$IFNDEF FPC}
  If (Value.InheritsFrom(TServerMethodDatamodule))           Or
     (Value            = TServerMethodDatamodule)            Then
 {$ELSE}
  If (Value.ClassType.InheritsFrom(TServerMethodDatamodule)) Or
     (Value             = TServerMethodDatamodule)           Then
 {$ENDIF}
 aServerMethod := Value;
End;

Constructor TRESTDWServiceNotificationBase.Create(AOwner : TComponent);
Begin
 Inherited;
 vGarbageTime               := 60000;
 vServiceTimeout            := 5000;
 vServicePort               := 9092;
 vForceWelcomeAccess        := False;
 vServerAuthOptions         := TRESTDWServerAuthOptionParams.Create(Self);
 vCripto                    := TCripto.Create;
 vServerAuthOptions.AuthorizationOption := rdwAONone;
 vLoginMessage              := '';
 vRESTDwAuthError           := Nil;
 vNotifyWelcomeMessage      := Nil;
 vLastRequest               := Nil;
 vLastResponse              := Nil;
End;

Destructor TRESTDWServiceNotificationBase.Destroy;
Begin
 FreeAndNil(vServerAuthOptions);
 FreeAndNil(vCripto);
 Inherited;
End;

Function  TRESTDWConnectionServerCP.GetDisplayName             : String;
Begin
 Result := vListName;
End;

Function  TRESTDWConnectionServerCP.GetPoolerList : TStringList;
Var
 I                : Integer;
 vTempList        : TStringList;
 RESTClientPooler : TRESTClientPoolerBase;
 vConnection      : TRESTDWPoolerMethodClient;
Begin
 Result := Nil;
 RESTClientPooler := TRESTClientPoolerBase.Create(Nil);
 Try
  vConnection                  := TRESTDWPoolerMethodClient.Create(Nil);
  vConnection.WelcomeMessage   := vWelcomeMessage;
  vConnection.Host             := vRestWebService;
  vConnection.Port             := vPoolerPort;
  vConnection.Compression      := vCompression;
  vConnection.TypeRequest      := vTypeRequest;
  vConnection.AccessTag        := vAccessTag;
  vConnection.CriptOptions.Use := CriptOptions.Use;
  vConnection.CriptOptions.Key := CriptOptions.Key;
  vConnection.DataRoute        := DataRoute;
  vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
  Result := TStringList.Create;
  Try
   vTempList := vConnection.GetServerEvents(vDataRoute, vTimeOut);
   Try
    For I := 0 To vTempList.Count -1 do
     Result.Add(vTempList[I]);
   Finally
    If Assigned(vTempList) Then
     vTempList.Free;
   End;
  Except
   On E : Exception do
    Begin
     Raise Exception.Create(cInvalidRDWServer);
    End;
  End;
  FreeAndNil(vConnection);
 Finally
  FreeAndNil(RESTClientPooler);
 End;
End;

Procedure TRESTDWConnectionServerCP.SetDisplayName(Const Value : String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidConnectionName)
 Else
  Begin
   vListName := Trim(Value);
   Inherited;
  End;
End;

Destructor TRESTDWConnectionServerCP.Destroy;
Begin
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 If Assigned(vCripto) Then
  FreeAndNil(vCripto);
 FreeAndNil(vTransparentProxy);
 Inherited;
End;

Constructor TRESTDWConnectionServerCP.Create(aCollection: TCollection);
Begin
 Inherited;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding         := esUtf8;
 {$ELSE}
  vEncoding         := esAscii;
 {$IFEND}
 {$ELSE}
  vEncoding         := esUtf8;
  vDatabaseCharSet  := csUndefined;
 {$ENDIF}
 vTransparentProxy  := TProxyConnectionInfo.Create;
 vListName          :=  Format('server(%d)', [aCollection.Count]);
 vRestWebService    := '127.0.0.1';
 vCompression       := True;
 vAuthentication    := True;
 vAuthOptionParams  := TRESTDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vPoolerPort        := 8082;
 vEncodeStrings     := True;
 vTimeOut           := 10000;
 vActive            := True;
 vServerEventName   := '';
 vDataRoute         := '';
 vCripto            := TCripto.Create;
End;

Procedure TRESTDWConnectionServerCP.SetCripto(Value : TCripto);
Begin
 vCripto.Use := Value.Use;
 vCripto.Key := Value.Key;
End;

Function TFailOverConnections.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

Function TFailOverConnections.GetRec(Index : Integer) : TRESTDWConnectionServerCP;
Begin
 Result := TRESTDWConnectionServerCP(Inherited GetItem(Index));
End;

Procedure TFailOverConnections.PutRec(Index: Integer; Item: TRESTDWConnectionServerCP);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
End;

Function  TFailOverConnections.GetRecName(Index : String)  : TRESTDWConnectionServerCP;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Result := TRESTDWConnectionServerCP(Self.Items[I]);
     Break;
    End;
  End;
End;

Procedure TFailOverConnections.PutRecName(Index        : String;
                                          Item         : TRESTDWConnectionServerCP);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Self.Items[I] := Item;
     Break;
    End;
  End;
End;

Procedure TFailOverConnections.ClearList;
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

Constructor TFailOverConnections.Create(AOwner      : TPersistent;
                                        aItemClass  : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWConnectionServerCP);
 fOwner  := AOwner;
End;

Destructor TFailOverConnections.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TFailOverConnections.Add: TCollectionItem;
Begin
 Result := TRESTDWConnectionServerCP(Inherited Add);
End;

Procedure TFailOverConnections.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
End;

Procedure TFailOverConnections.Delete(Index : String);
Begin
 If ItemsByName[Index] <> Nil Then
  TOwnedCollection(Self).Delete(ItemsByName[Index].Index);
End;

Procedure TRESTClientPoolerBase.SetOnWork(Value : TOnWork);
Begin
  vOnWork := Value;
End;

Procedure TRESTClientPoolerBase.SetOnWorkBegin(Value : TOnWork);
Begin
  vOnWorkBegin := Value;
End;

Procedure TRESTClientPoolerBase.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
  vOnWorkEnd := Value;
End;

Procedure TRESTClientPoolerBase.SetOnStatus(Value : TOnStatus);
Begin
  vOnStatus := Value;
End;

Function TRESTClientPoolerBase.GetAllowCookies: Boolean;
Begin
 Result := vAllowCookies;
End;

Procedure TRESTClientPoolerBase.SetAllowCookies(Value: Boolean);
Begin
 vAllowCookies := Value;
End;

Procedure TRESTClientPoolerBase.NewToken;
Var
 DWParams       : TRESTDWParams;
 vErrorBoolean  : Boolean;
 vMessageError,
 vToken         : String;
Begin
 DWParams := TRESTDWParams.Create;
 Try
  DWParams.Encoding := Encoding;
  If AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
   Begin
    Case AuthenticationOptions.AuthorizationOption Of
     rdwAOBearer : Begin
                    If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                       (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token = '') Then
                     Begin
                      If Assigned(OnBeforeGetToken) Then
                       OnBeforeGetToken(WelcomeMessage,
                                        AccessTag, DWParams);
                      vToken :=  RenewToken(DWParams, vErrorBoolean, vMessageError);
                      If Not vErrorBoolean Then
                       TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := vToken;
                     End;
                   End;
     rdwAOToken  : Begin
                    If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                       (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token = '') Then
                     Begin
                      If Assigned(OnBeforeGetToken) Then
                       OnBeforeGetToken(WelcomeMessage,
                                        AccessTag, DWParams);
                      vToken :=  RenewToken(DWParams, vErrorBoolean, vMessageError);
                      If Not vErrorBoolean Then
                       TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := vToken;
                     End;
                   End;
    End;
   End;
 Finally
  FreeAndNil(DWParams);
 End;
End;

Function  TRESTClientPoolerBase.RenewToken(Var Params             : TRESTDWParams;
                                           Var Error              : Boolean;
                                           Var MessageError       : String) : String;
Var
 I                    : Integer;
 vTempSend            : String;
 vConnection          : TRESTDWPoolerMethodClient;
Begin
 //Atualização de Token na autenticação
 Result                       := '';
 MessageError                 := '';
 vConnection                  := TRESTDWPoolerMethodClient.Create(Nil);
 vConnection.UserAgent        := vUserAgent;
 vConnection.TypeRequest      := vTypeRequest;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vHost;
 vConnection.Port             := vPort;
 vConnection.BinaryRequest    := BinaryRequest;
 vConnection.Compression      := vDatacompress;
 vConnection.EncodeStrings    := EncodedStrings;
 vConnection.Encoding         := Encoding;
 vConnection.AccessTag        := vAccessTag;
 vConnection.CriptOptions.Use := vCripto.Use;
 vConnection.CriptOptions.Key := vCripto.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFNDEF FPC}
  vConnection.Encoding      := vRSCharset;
 {$ELSE}
  vConnection.DatabaseCharSet := csUndefined;
 {$ENDIF}
 If vAuthOptionParams.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   Try
    Try
     Case vAuthOptionParams.AuthorizationOption Of
      rdwAOBearer : Begin
                     vTempSend := vConnection.GetToken(vDataRoute,
                                                       Params,       Error,
                                                       MessageError, vRequestTimeOut, vConnectTimeOut,
                                                       Nil,          Self);
                     vTempSend := GettokenValue(vTempSend);
                     TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
      rdwAOToken  : Begin
                     vTempSend := vConnection.GetToken(vDataRoute,
                                                       Params,       Error,
                                                       MessageError, vRequestTimeOut, vConnectTimeOut,
                                                       Nil,          Self);
                     vTempSend                                          := GettokenValue(vTempSend);
                     TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
     End;
     Result      := vTempSend;
     If csDesigning in ComponentState Then
      If Error Then Raise Exception.Create(PChar(cAuthenticationError));
     If Error Then
      Begin
       If vFailOver Then
        Begin
         If vFailOverConnections.Count = 0 Then
          Begin
           Result      := '';
           If csDesigning in ComponentState Then
            Raise Exception.Create(PChar(cInvalidConnection))
           Else
            Raise Exception.Create(cInvalidConnection);
          End
         Else
          Begin
           For I := 0 To vFailOverConnections.Count -1 Do
            Begin
             If I = 0 Then
              Begin
               If ((vFailOverConnections[I].vTypeRequest    = vConnection.TypeRequest)    And
                   (vFailOverConnections[I].vWelcomeMessage = vConnection.WelcomeMessage) And
                   (vFailOverConnections[I].vRestWebService = vConnection.Host)           And
                   (vFailOverConnections[I].vPoolerPort     = vConnection.Port)           And
                   (vFailOverConnections[I].vCompression    = vConnection.Compression)    And
                   (vFailOverConnections[I].hEncodeStrings  = vConnection.EncodeStrings)  And
                   (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                   (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
                   (vFailOverConnections[I].vDataRoute      = vConnection.DataRoute))     Or
                 (Not (vFailOverConnections[I].Active))                                   Then
               Continue;
              End;
             If Assigned(vOnFailOverExecute) Then
              vOnFailOverExecute(vFailOverConnections[I]);
             ReconfigureConnection(vFailOverConnections[I].vTypeRequest,
                                   vFailOverConnections[I].vWelcomeMessage,
                                   vFailOverConnections[I].vRestWebService,
                                   vFailOverConnections[I].vPoolerPort,
                                   vFailOverConnections[I].vCompression,
                                   vFailOverConnections[I].hEncodeStrings,
                                   vFailOverConnections[I].Encoding,
                                   vFailOverConnections[I].vAccessTag,
                                   vFailOverConnections[I].AuthenticationOptions);
             Try
              Case vAuthOptionParams.AuthorizationOption Of
               rdwAOBearer : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vDataRoute,
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut, vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          Self);
                              vTempSend                                           := GettokenValue(vTempSend);
                              TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vDataRoute,
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut, vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          Self);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
              End;
              Result      := GettokenValue(vTempSend);
              If Not(Error) Then
               Begin
//                vMyIP     := vTempSend;
                If vFailOverReplaceDefaults Then
                 Begin
                  vTypeRequest      := vConnection.TypeRequest;
                  vWelcomeMessage   := vConnection.WelcomeMessage;
                  vHost             := vConnection.Host;
                  vPort             := vConnection.Port;
                  vDatacompress     := vConnection.Compression;
                  vEncodeStrings    := vConnection.EncodeStrings;
                  vRSCharset        := vConnection.Encoding;
                  vAccessTag        := vConnection.AccessTag;
                  vDataRoute        := vFailOverConnections[I].vDataRoute;
                  vRequestTimeOut   := vFailOverConnections[I].vTimeOut;
                  vConnectTimeOut   := vFailOverConnections[I].vConnectTimeOut;
                  vAuthOptionParams := vFailOverConnections[I].AuthenticationOptions;
                 End;
               End;
              If csDesigning in ComponentState Then
               If Not(Result = '') Then
                Raise Exception.Create(PChar(cAuthenticationError))
               Else
                Break;
             Except
              On E : Exception do
               Begin
                If Assigned(vOnFailOverError) Then
                 vOnFailOverError(vFailOverConnections[I], E.Message);
               End;
             End;
            End;
          End;
        End;
      End;
    Except
     On E : Exception do
      Begin
       DestroyComponents;
       If vFailOver Then
        Begin
         If vFailOverConnections.Count > 0 Then
          Begin
           If Assigned(vFailOverConnections) Then
           For I := 0 To vFailOverConnections.Count -1 Do
            Begin
             DestroyComponents;
             If I = 0 Then
              Begin
               If ((vFailOverConnections[I].vTypeRequest    = vConnection.TypeRequest)    And
                   (vFailOverConnections[I].vWelcomeMessage = vConnection.WelcomeMessage) And
                   (vFailOverConnections[I].vRestWebService = vConnection.Host)           And
                   (vFailOverConnections[I].vPoolerPort     = vConnection.Port)           And
                   (vFailOverConnections[I].vCompression    = vConnection.Compression)    And
                   (vFailOverConnections[I].hEncodeStrings  = vConnection.EncodeStrings)  And
                   (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                   (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
                   (vFailOverConnections[I].vDataRoute      = vConnection.DataRoute))     Or
                   (Not (vFailOverConnections[I].Active))                                 Then
               Continue;
              End;
             If Assigned(vOnFailOverExecute) Then
              vOnFailOverExecute(vFailOverConnections[I]);
             ReconfigureConnection(vFailOverConnections[I].vTypeRequest,
                                   vFailOverConnections[I].vWelcomeMessage,
                                   vFailOverConnections[I].vRestWebService,
                                   vFailOverConnections[I].vPoolerPort,
                                   vFailOverConnections[I].vCompression,
                                   vFailOverConnections[I].hEncodeStrings,
                                   vFailOverConnections[I].Encoding,
                                   vFailOverConnections[I].vAccessTag,
                                   vFailOverConnections[I].AuthenticationOptions);
             Try
              Case vAuthOptionParams.AuthorizationOption Of
               rdwAOBearer : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vDataRoute,
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut, vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          Self);
                              vTempSend                                           := GettokenValue(vTempSend);
                              TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vDataRoute,
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,  vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          Self);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
              End;
              Result      := GettokenValue(vTempSend);
              If Not(Error) Then
               Begin
                If vFailOverReplaceDefaults Then
                 Begin
                  vTypeRequest      := vConnection.TypeRequest;
                  vWelcomeMessage   := vConnection.WelcomeMessage;
                  vHost             := vConnection.Host;
                  vPort             := vConnection.Port;
                  vDatacompress     := vConnection.Compression;
                  vEncodeStrings    := vConnection.EncodeStrings;
                  vRSCharset        := vConnection.Encoding;
                  vAccessTag        := vConnection.AccessTag;
                  vDataRoute        := vFailOverConnections[I].vDataRoute;
                  vRequestTimeOut   := vFailOverConnections[I].vTimeOut;
                  vConnectTimeOut   := vFailOverConnections[I].vConnectTimeOut;
                  vAuthOptionParams := vFailOverConnections[I].AuthenticationOptions;
                 End;
               End;
              If csDesigning in ComponentState Then
               If Not (Result = '') Then
                Raise Exception.Create(PChar(cAuthenticationError))
               Else
                Break;
             Except
              On E : Exception do
               Begin
                If Assigned(vOnFailOverError) Then
                 vOnFailOverError(vFailOverConnections[I], E.Message);
               End;
             End;
            End;
          End
         Else
          Begin
           Result      := '';
           If csDesigning in ComponentState Then
            Raise Exception.Create(PChar(E.Message))
           Else
            Raise Exception.Create(E.Message);
          End;
        End
       Else
        Begin
         Result      := '';
         If csDesigning in ComponentState Then
          Raise Exception.Create(PChar(E.Message))
         Else
          Raise Exception.Create(E.Message);
        End;
      End;
    End;
   Finally
    If Assigned(vConnection) Then
     FreeAndNil(vConnection);
   End;
  End;
End;

Procedure TRESTClientPoolerBase.SetAccessTag(Value : String);
Begin
 vAccessTag := Value;
End;

Function TRESTClientPoolerBase.GetAccessTag: String;
Begin
 Result := vAccessTag;
End;

Function TRESTClientPoolerBase.SendEvent(EventData : String) : String;
Var
 Params : TRESTDWParams;
Begin
 Try
  Params := Nil;
  Result := SendEvent(EventData, Params);
 Finally
 End;
End;

Procedure TRESTClientPoolerBase.SetAuthOptionParams(Value : TRESTDWClientAuthOptionParams);
Begin
 vAuthOptionParams.Assign(Value);
End;

Procedure TRESTClientPoolerBase.SetDataRoute(Value: String);
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

procedure TRESTClientPoolerBase.SetIpVersion(IpV: TRESTDWClientIpVersions);
begin
 vClientIpVersion := Ipv;
end;

Constructor TRESTClientPoolerBase.Create(AOwner: TComponent);
Begin
 Inherited;
 vCripto                               := TCripto.Create;
 vErrorCode                            := -1;
 vHost                                 := 'localhost';
 vDataRoute                            := '';
 vPort                                 := 8082;
 vAuthOptionParams                     := TRESTDWClientAuthOptionParams.Create(Self);
 vTransparentProxy                     := TProxyConnectionInfo.Create;
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vRSCharset                            := esUtf8;
 vCharset                              := 'utf8';
 vAuthentication                       := True;
 vRequestTimeOut                       := 10000;
 vConnectTimeOut                       := 3000;
 vRedirectMaximum                      := 0;
 vDatacompress                         := True;
 vEncodeStrings                        := True;
 vAllowCookies                         := False;
 vBinaryRequest                        := False;
 vHandleRedirects                      := False;
 vUserAgent                            := cUserAgent;
 vLastErrorMessage                     := '';
 {$IFDEF FPC}
 vDatabaseCharSet                      := csUndefined;
 {$ENDIF}
 vContentType                          := cDefaultContentType;
 vContentEncoding                      := cContentTypeMultiPart;
 vAccept                               := cDefaultAccept;
 vAcceptEncoding                       := '';
 vFailOver                             := False;
 vFailOverReplaceDefaults              := False;
 vPropThreadRequest                    := False;
 vUseSSL                               := False;
 vFailOverConnections                  := TFailOverConnections.Create(Self, TRESTDWConnectionServerCP);
 vPoolerNotFoundMessage                := cPoolerNotFound;
 vClientIpVersion                      := civIPv4;
End;

Destructor  TRESTClientPoolerBase.Destroy;
Begin
 Try
//  If HttpRequest.Connected Then
//   HttpRequest.Disconnect;
 Except
 End;
// FreeAndNil(HttpRequest);
 FreeAndNil(vFailOverConnections);
 FreeAndNil(vCripto);
 FreeAndNil(vTransparentProxy);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Function TRESTServiceBase.CommandExec(Const AContext        : TComponent;
                                      Url,
                                      RawHTTPCommand        : String;
                                      Var ContentType       : String;
                                      ClientIP,
                                      UserAgent,
                                      AuthUsername,
                                      AuthPassword,
                                      Token                 : String;
                                      RequestHeaders        : TStringList;
                                      ClientPort            : Integer;
                                      RawHeaders,
                                      Params                : TStrings;
                                      QueryParams           : String;
                                      ContentStringStream   : TStream;
                                      Var AuthRealm,
                                      sCharSet,
                                      ErrorMessage          : String;
                                      Var StatusCode        : Integer;
                                      Var ResponseHeaders   : TStringList;
                                      Var ResponseString    : String;
                                      Var ResultStream      : TStream;
                                      Var CORSCustomHeaders : TStrings;
                                      Redirect              : TRedirect) : Boolean;
Var
 I, vErrorCode      : Integer;
 DataMode           : TDataMode;
 DWParamsD,
 DWParams           : TRESTDWParams;
 vOldMethod,
 vBasePath,
 vObjectName,
 vAccessTag,
 vWelcomeMessage,
 boundary,
 startboundary,
 vReplyString,
 vReplyStringResult,
 vUrlToken,
 baseEventUnit,
 serverEventsName,
 Cmd, vmark,
 aurlContext,
 tmp, JSONStr,
 ReturnObject,
 vTempText,
 sFile,
 sContentType,
 vContentType,
 LocalDoc,
 vErrorMessage,
 aToken,
 vToken,
 vDataBuff,
 vUrlToExec,
 vOldRequest,
 vdwservereventname,
 vUrlRedirect,
 vAuthenticationString : String;
 vAuthTokenParam       : TRESTDWAuthTokenParam;
 vdwConnectionDefs     : TConnectionDefs;
 vTempServerMethods    : TObject;
 ContentStream         : TStream;
// newdecoder,
// Decoder             : TIdMessageDecoder;
 vRDWAuthOptionParam   : TRESTDWAuthOptionParam;
 JSONParam             : TJSONParam;
 JSONValue             : TJSONValue;
 vAcceptAuth,
 vMetadata,
 vBinaryCompatibleMode,
 vBinaryEvent,
 dwassyncexec,
 vFileExists,
 vSpecialServer,
 vServerContextCall,
 vTagReply,
 WelcomeAccept,
 encodestrings,
 compresseddata,
 vdwCriptKey,
 vGettoken,
 vTokenValidate,
 vNeedAuthorization,
 vCompareContext,
 vIsQueryParam,
 msgEnd              : Boolean;
 vServerBaseMethod   : TComponentClass;
 vServerMethod       : TComponentClass;
 ServerContextStream : TMemoryStream;
 newdecoder          : TRESTDWMessageDecoder;
 decoder             : TRESTDWMessageDecoderMIME;
 mb,
 mb2,
 ms                  : TStream;
 RequestType         : TRequestType;
 vRequestHeader,
 vDecoderHeaderList  : TStringList;
 vTempContext        : TRESTDWContext;
 vTempEvent          : TRESTDWEvent;
 Function ExcludeTag(Value : String) : String;
 Begin
  Result := Value;
  If (UpperCase(Copy (Value, InitStrPos, 3)) = 'GET')    or
     (UpperCase(Copy (Value, InitStrPos, 4)) = 'POST')   or
     (UpperCase(Copy (Value, InitStrPos, 3)) = 'PUT')    or
     (UpperCase(Copy (Value, InitStrPos, 6)) = 'DELETE') or
     (UpperCase(Copy (Value, InitStrPos, 5)) = 'PATCH')  Then
   Begin
    While (Result <> '') And (Result[InitStrPos] <> '/') Do
     Delete(Result, 1, 1);
   End;
  If Result <> '' Then
   If Result[InitStrPos] = '/' Then
    Delete(Result, 1, 1);
  Result := Trim(Result);
 End;
 Function GetFileOSDir(Value : String) : String;
 Begin
  {$IF Defined(ANDROID) Or Defined(IOS)}
  Result := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, Value);
  {$ELSE}
  Result := vBasePath + Value;
  {$IFEND}
  {$IFDEF MSWINDOWS}
   Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  {$ENDIF}
 End;
 Function GetLastMethod(Value : String) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> '' Then
   Begin
    If Value[Length(Value) - FinalStrPos] <> '/' Then
     Begin
      For I := (Length(Value) - FinalStrPos) Downto InitStrPos Do
       Begin
        If Value[I] <> '/' Then
         Result := Value[I] + Result
        Else
         Break;
       End;
     End;
   End;
 End;
 procedure ReadRawHeaders;
 var
  I: Integer;
  JSONParam : TJSONParam;
 begin
  If Not Assigned(RawHeaders) Then
   Exit;
  Try
   If RawHeaders.Count > 0 Then
    Begin
     RawHeaders.NameValueSeparator := ':';
     vRequestHeader.Add(RawHeaders.Text);
     For I := 0 To RawHeaders.Count -1 Do
      Begin
       tmp := RawHeaders.Names[I];
       vTempText := RawHeaders.Values[tmp];
       if (vTempText <> '') and (vTempText[InitStrPos] = ' ') then
         Delete(vTempText,1,1);

       If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
        vWelcomeMessage := DecodeStrings(vTempText{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('dwaccesstag', lowercase(tmp)) > 0 Then
        vAccessTag := DecodeStrings(vTempText{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('datacompression', lowercase(tmp)) > 0 Then
        compresseddata := StringToBoolean(vTempText)
       Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
        encodestrings  := StringToBoolean(vTempText)
       Else If pos('dwusecript', lowercase(tmp)) > 0 Then
        vdwCriptKey    := StringToBoolean(vTempText)
       Else If (pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
        dwassyncexec   := StringToBoolean(vTempText)
       Else if pos('binaryrequest', lowercase(tmp)) > 0 Then
        vBinaryEvent   := StringToBoolean(vTempText)
       Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
        Begin
         vdwConnectionDefs   := TConnectionDefs.Create;
         JSONValue           := TJSONValue.Create;
         Try
          JSONValue.Encoding  := vEncoding;
          JSONValue.Encoded  := True;
          JSONValue.LoadFromJSON(vTempText);
          vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
         Finally
          FreeAndNil(JSONValue);
         End;
        End
       Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
        Begin
         JSONValue           := TJSONValue.Create;
         Try
          JSONValue.Encoding  := vEncoding;
          JSONValue.Encoded  := True;
          {$IFDEF FPC}
          JSONValue.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          JSONValue.LoadFromJSON(vTempText);
          vdwservereventname := JSONValue.AsString;
         Finally
          FreeAndNil(JSONValue);
         End;
        End
       Else
        Begin
         If Not Assigned(DWParams) Then
          TRESTDWDataUtils.ParseWebFormsParams (Params, Url,
                                          QueryParams,
                                          vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, RequestType);
         Try
          If Trim(lowercase(tmp)) <> '' Then
           Begin
            JSONParam                 := DWParams.ItemsString[lowercase(tmp)];
            If JSONParam = Nil Then
             Begin
              JSONParam := TJSONParam.Create(DWParams.Encoding);
              JSONParam.ObjectDirection := odIN;
              JSONParam.ParamName       := lowercase(tmp);
              {$IFDEF FPC}
              JSONParam.DatabaseCharSet := vDatabaseCharSet;
              {$ENDIF}
              If (Pos(LowerCase('{"ObjectType":"toParam", "Direction":"'), LowerCase(vTempText)) > 0) Then
               JSONParam.FromJSON(vTempText)
              Else
               JSONParam.AsString  := vTempText;
              DWParams.Add(JSONParam);
             End;
           End;
         Finally
         End;
        End;
      End;
    End;
  Finally
   If RawHeaders <> Nil Then
    If RawHeaders.Text <> '' Then
     DWParams.RequestHeaders.Input.Assign(RawHeaders);
   tmp := '';
  End;
 End;
 Procedure WriteError;
 Begin
  {$IFDEF FPC}
   If vEncoding = esUtf8 Then
    mb                              := TStringStream.Create(Utf8Encode(vErrorMessage))
   Else
    mb                              := TStringStream.Create(vErrorMessage);
  {$ELSE}
   mb                               := TStringStream.Create(vErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
  {$ENDIF}
  mb.Position                      := 0;
  StatusCode                       := vErrorCode;
  If Not (Assigned(ResultStream)) Then
   ResultStream := TStringStream.Create('');
  ResultStream.Position            := 0;
  ResultStream.CopyFrom(mb, mb.Size);
  ResultStream.Position := 0;
  If Assigned(mb) Then
   FreeAndNil(mb);
 End;
 Procedure WriteStream(Source, Dest : TStream);
 Begin
  Source.Position := 0;
  Dest.Position   := 0;
  Dest.CopyFrom(Source, Source.Size);
  Dest.Position   := 0;
 End;
 Procedure DestroyComponents;
 Begin
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
  If Assigned(vdwConnectionDefs) Then
   FreeAndNil(vdwConnectionDefs);
  If Assigned(vRequestHeader)    Then
   FreeAndNil(vRequestHeader);
  If Assigned(vAuthTokenParam)   Then
   FreeAndNil(vAuthTokenParam);
  If Assigned(vRDWAuthOptionParam) Then
   FreeAndNil(vRDWAuthOptionParam);
  If Assigned(vAuthTokenParam) Then
   FreeAndNil(vAuthTokenParam);
  If Assigned(vServerMethod) Then
   If Assigned(vTempServerMethods) Then
    Begin
     Try
      {$IFDEF POSIX} //no linux nao precisa libertar porque é [weak]
      {$ELSE}
      FreeAndNil(vTempServerMethods); //.free;
      {$ENDIF}
     Except
     End;
    End;
 End;
 Function ReturnEventValidation(ServerMethodsClass : TComponent;
                                urlContext         : String) : TRESTDWEvent;
 Var
  vTagService : Boolean;
  I           : Integer;
  Pooler      : String;
 Begin
  Result        := Nil;
  vTagService   := False;
  If ServerMethodsClass <> Nil Then
   Begin
    Pooler := urlContext;
    If Pos('?', Pooler) > 0 Then
     Pooler := Copy(Pooler, 1, Pos('?', Pooler) -1);
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWServerEvents Then
       Begin
        Result   := TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler];
        If Assigned(Result) Then
          Break;
       End;
     End;
   End;
 End;
 Function ReturnContextValidation(ServerMethodsClass : TComponent;
                                  urlContext         : String) : TRESTDWContext;
 Var
  I            : Integer;
  vTagService  : Boolean;
  aEventName,
  aServerEvent,
  vRootContext : String;
 Begin
  Result        := Nil;
  vRootContext  := '';
  If (aServerEvent = '') Then
   Begin
//    aServerEvent := StringReplace(urlContext, '/', '', [rfReplaceAll]);
    aServerEvent := urlContext;
    If Pos('?', aServerEvent) > 0 Then
     aServerEvent := Copy(aServerEvent, 1, Pos('?', aServerEvent) -1);
    aEventName   := '';
   End;
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWServerContext Then
       Begin
        If (TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[aServerEvent] <> Nil)   Then
         Begin
          vRootContext := '';
          Result := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[aServerEvent];
          If Assigned(Result) Then
           Break;
         End;
       End;
     End;
   End;
 End;
 Function ClearRequestType(Value : String) : String;
 Begin
  Result := Value;
  If (Pos('GET ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'GET ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('POST ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'POST ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('PUT ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'PUT ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('DELETE ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'DELETE ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('PATCH ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'PATCH ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('OPTION ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'OPTION ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('OPTIONS ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'OPTIONS ', '', [rfReplaceAll, rfIgnoreCase]);
 End;
 Function CompareBaseURL(Var Value : String) : Boolean;
 Var
  vTempValue : String;
 Begin
  Result := False;
  If aDefaultUrl <> '' Then
   Begin
    If Value = '/' Then
     Value := aDefaultUrl
    Else
     Begin
      vTempValue := Copy(Value, InitStrPos, Length(aDefaultUrl));
      If Lowercase(vTempValue) <> Lowercase(aDefaultUrl) Then
       Begin
        Value  := aDefaultUrl + Value;
        Result := True;
       End;
     End;
   End;
 End;
 Procedure PrepareBasicAuth(AuthenticationString : String; Var AuthUsername, AuthPassword : String);
 Begin
  AuthUsername := Copy(AuthenticationString, InitStrPos, Pos(':', AuthenticationString) -1);
  Delete(AuthenticationString, InitStrPos, Pos(':', AuthenticationString));
  AuthPassword := AuthenticationString;
 End;
Begin
 ResultStream          := Nil;
 Result                := True;
 vRDWAuthOptionParam   := Nil;
 decoder               := Nil;
 mb2                   := Nil;
 mb                    := Nil;
 ms                    := Nil;
 vAuthTokenParam       := Nil;
 tmp                   := '';
 DataMode              := dmDataware;
 baseEventUnit         := '';
 vAccessTag            := '';
 vErrorMessage         := '';
 vServerMethod         := Nil;
 {$IF Defined(ANDROID) Or Defined(IOS) or Defined(HAS_FMX)}
 vBasePath             := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, '/');
 {$ELSE}
 vBasePath             := ExtractFilePath(ParamStr(0));
 {$IFEND}
 vContentType          := vContentType;
 vdwConnectionDefs     := Nil;
 vTempServerMethods    := Nil;
 DWParams              := Nil;
 ServerContextStream   := Nil;
 mb                    := Nil;
 compresseddata        := False;
 encodestrings         := False;
 vTagReply             := False;
 vServerContextCall    := False;
 dwassyncexec          := False;
 vBinaryEvent          := False;
 vBinaryCompatibleMode := False;
 vMetadata             := False;
 vdwCriptKey           := False;
 vGettoken             := False;
 vTokenValidate        := False;
 vErrorCode            := 200;
 vIsQueryParam         := False;
 vUrlToExec            := '';
 vToken                := '';
 vDataBuff             := '';
 vRequestHeader        := TStringList.Create;
 vCompareContext       := False;
 Cmd                   := RemoveBackslashCommands(Trim(RawHTTPCommand));
 Try
  sCharSet := '';
  If (UpperCase(Copy (Cmd, 1, 3)) = 'GET')    Then
   Begin
    If     (Pos('.HTML', UpperCase(Cmd)) > 0) Then
     Begin
      sContentType:='text/html';
      sCharSet := 'utf-8';
     End
    Else If (Pos('.PNG', UpperCase(Cmd)) > 0) Then
     sContentType := 'image/png'
    Else If (Pos('.ICO', UpperCase(Cmd)) > 0) Then
     sContentType := 'image/ico'
    Else If (Pos('.GIF', UpperCase(Cmd)) > 0) Then
     sContentType := 'image/gif'
    Else If (Pos('.JPG', UpperCase(Cmd)) > 0) Then
     sContentType := 'image/jpg'
    Else If (Pos('.JS',  UpperCase(Cmd)) > 0) Then
     sContentType := 'application/javascript'
    Else If (Pos('.PDF', UpperCase(Cmd)) > 0) Then
     sContentType := 'application/pdf'
    Else If (Pos('.CSS', UpperCase(Cmd)) > 0) Then
     sContentType:='text/css';
    sFile := Url;
    If Pos(vTempText, sFile) >= InitStrPos Then
     Delete(sFile, Pos(vTempText, sFile) - FinalStrPos, Length(vTempText));
    sFile := IncludeTrailingPathDelimiter(FRootPath) + sFile;
    {$IFDEF MSWINDOWS}
     sFile := StringReplace(sFile, '/', '\', [rfReplaceAll]);
     sFile := StringReplace(sFile, '\\', '\', [rfReplaceAll]);
    {$ELSE}
     sFile := StringReplace(sFile, '//', '/', [rfReplaceAll]);
    {$ENDIF}
    If (vPathTraversalRaiseError) And
       (RESTDWFileExists(sFile, FRootPath)) And
       (SystemProtectFiles(sFile)) Then
     Begin
      StatusCode               := 404;
      If compresseddata Then
       mb                                  := TStringStream(ZCompressStreamNew(cEventNotFound))
      Else
       mb                                  := TStringStream.Create(cEventNotFound{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      mb.Position                          := 0;
      If Not (Assigned(ResultStream)) Then
       ResultStream := TStringStream.Create('');
      ResultStream.CopyFrom(mb, mb.Size);
      FreeAndNil(mb);
      DestroyComponents;
      Exit;
     End;
    If RESTDWFileExists(sFile, FRootPath) then
     Begin
      StatusCode    := 200;
      ContentType   := TRESTDWMIMEType.GetMIMEType(sFile);
      ServerContextStream := TMemoryStream.Create;
      ServerContextStream.LoadFromFile(sFile);
      ServerContextStream.Position := 0;
      If Not (Assigned(ResultStream)) Then
       ResultStream := TMemoryStream.Create;
      ResultStream.CopyFrom(ServerContextStream, ServerContextStream.Size);
      FreeAndNil(ServerContextStream);
      DestroyComponents;
      Exit;
     End;
   End;
  If (vPathTraversalRaiseError) And (TravertalPathFind(Trim(RawHTTPCommand))) Then
   Begin
    StatusCode                            := 404;
    If compresseddata Then
     mb                                  := TStringStream(ZCompressStreamNew(cEventNotFound))
    Else
     mb                                  := TStringStream.Create(cEventNotFound{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
    mb.Position                          := 0;
    If Not (Assigned(ResultStream)) Then
     ResultStream := TStringStream.Create('');
    ResultStream.CopyFrom(mb, mb.Size);
    FreeAndNil(mb);
    DestroyComponents;
    Exit;
   End;
  Cmd := RemoveBackslashCommands(Trim(RawHTTPCommand));
  vRequestHeader.Add(Cmd);
  Cmd := StringReplace(Cmd, ' HTTP/1.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/1.1', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.1', '', [rfReplaceAll]);
  If (UpperCase(Copy (Cmd, 1, 3)) = 'GET' )   OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'POST')   OR
     (UpperCase(Copy (Cmd, 1, 3)) = 'PUT')    OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'DELE')   OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'PATC')   OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'OPTI')   Then
   Begin
    RequestType := rtGet;
    If (UpperCase(Copy (Cmd, 1, 4))      = 'POST') Then
     RequestType := rtPost
    Else If (UpperCase(Copy (Cmd, 1, 3)) = 'PUT')  Then
     RequestType := rtPut
    Else If (UpperCase(Copy (Cmd, 1, 4)) = 'DELE') Then
     RequestType := rtDelete
    Else If (UpperCase(Copy (Cmd, 1, 4)) = 'PATC') Then
     RequestType := rtPatch
    Else If (UpperCase(Copy (Cmd, 1, 4)) = 'OPTI') Then
     RequestType := rtOption;
    If Url = '/favicon.ico' Then
     Exit;
    Cmd := ClearRequestType(Cmd);
    vIsQueryParam := (Pos('?', Lowercase(Url)) > 0) And
                     (Pos('=', Lowercase(Url)) > 0);
    If Not vIsQueryParam Then
     vIsQueryParam := (Pos('?', Lowercase(RawHTTPCommand)) > 0);
    If (cmd = '') or (cmd = '/') Then
     vOldRequest   := aDefaultUrl
    Else
     vOldRequest   := Cmd;
    If vIsQueryParam Then
     vUrlToExec    := Url
    Else
     vUrlToExec    := Cmd;
    If (Cmd <> '/') And (Cmd <> '') Then
     ReadRawHeaders;
    vCompareContext := CompareBaseURL(Cmd); // := aDefaultUrl;
    If Cmd <> '' Then
     TRESTDWDataUtils.ParseRESTURL (ClearRequestType(Cmd), vEncoding, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams);
    If ((Params.Count > 0) And (RequestType In [rtGet, rtDelete])) Then
     Begin
      vRequestHeader.Add(Url);
      vRequestHeader.Add(Params.Text);
      vRequestHeader.Add(QueryParams);
      TRESTDWDataUtils.ParseWebFormsParams(Params, Url, QueryParams,
                                     vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, RequestType);
      If DWParams <> Nil Then
       Begin
        If (DWParams.ItemsString['dwwelcomemessage']     <> Nil)    Then
         vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
        If (DWParams.ItemsString['dwaccesstag']          <> Nil)    Then
         vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
        If (DWParams.ItemsString['datacompression']      <> Nil)    Then
         compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
        If (DWParams.ItemsString['dwencodestrings']      <> Nil)    Then
         encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
        If (DWParams.ItemsString['dwusecript']           <> Nil)    Then
         vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
        If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil)    Then
         vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
        If (DWParams.ItemsString['dwservereventname']    <> Nil)    Then
         Begin
          If vdwservereventname <> GetEventName(Lowercase(DWParams.ItemsString['dwservereventname'].AsString)) Then
           vdwservereventname := DecodeStrings(DWParams.ItemsString['dwservereventname'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         End;
       End;
     End
    Else
     Begin
      If (RequestType In [rtGet, rtDelete]) Then
       Begin
        aurlContext  := vUrlToExec;
        If Not Assigned(DWParams) Then
         TRESTDWDataUtils.ParseRESTURL (Url, vEncoding, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams);
        vOldMethod := vUrlToExec;
        If DWParams <> Nil Then
         Begin
          If DWParams.ItemsString['dwwelcomemessage']      <> Nil  Then
           vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
           vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['datacompression']      <> Nil) Then
           compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
          If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
           encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
          If (DWParams.ItemsString['dwservereventname']    <> Nil) Then
           Begin
            If vdwservereventname <> GetEventName(Lowercase(DWParams.ItemsString['dwservereventname'].AsString)) Then
             vdwservereventname := DecodeStrings(DWParams.ItemsString['dwservereventname'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
           End;
          If (DWParams.ItemsString['dwusecript']           <> Nil) Then
           vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
          If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
           dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
          If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
           vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
         End;
        If (vUrlToExec = '') And (aurlContext <> '') Then
         vUrlToExec := aurlContext;
       End;
      If (RequestType In [rtPut, rtPatch, rtDelete]) Then //New Code to Put
       Begin
        If QueryParams <> '' Then
         Begin
          TRESTDWDataUtils.ParseFormParamsToDWParam(QueryParams, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['dwwelcomemessage']     <> Nil) Then
           vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
           vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['datacompression']      <> Nil) Then
           compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
          If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
           encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
          If (DWParams.ItemsString['dwservereventname']    <> Nil) Then
           Begin
            If vdwservereventname <> GetEventName(Lowercase(DWParams.ItemsString['dwservereventname'].AsString)) Then
             vdwservereventname := DWParams.ItemsString['dwservereventname'].AsString;
           End;
          If (DWParams.ItemsString['dwusecript']           <> Nil) Then
           vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
          If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
           dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
          If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
           vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
         End;
       End;
      If Assigned(ContentStringStream) Then
       Begin
         ContentStringStream.Position := 0;
         If Not vBinaryEvent Then
          Begin
           Try
            mb := TStringStream.Create(''); //{$IFNDEF FPC}{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
            try
             mb.CopyFrom(ContentStringStream, ContentStringStream.Size);
                         ContentStringStream.Position := 0;
             mb.Position := 0;
             If (pos('--', TStringStream(mb).DataString) > 0) and (pos('boundary', ContentType) > 0) Then
              Begin
               msgEnd   := False;
               boundary := ExtractHeaderSubItem(ContentType, 'boundary', QuoteHTTP);
               startboundary := '--' + boundary;
               Repeat
                tmp := ReadLnFromStream(ContentStringStream, -1, True);
               Until tmp = startboundary;
              End;
            finally
             if Assigned(mb) then
              FreeAndNil(mb);
            end;
           Except
           End;
          End;
        If (ContentStringStream.Size > 0) And (boundary <> '') Then
         Begin
          Try
           Repeat
            decoder := TRESTDWMessageDecoderMIME.Create(nil);
            TRESTDWMessageDecoderMIME(decoder).MIMEBoundary := boundary;
            decoder.SourceStream := ContentStringStream;
            decoder.FreeSourceStream := False;
            decoder.ReadHeader;
            Inc(I);
            Case Decoder.PartType of
             mcptAttachment:
              Begin
               ms := TMemoryStream.Create;
               ms.Position := 0;
               NewDecoder := Decoder.ReadBody(ms, MsgEnd);
               vDecoderHeaderList := TStringList.Create;
               vDecoderHeaderList.Assign(Decoder.Headers);
               sFile := ExtractFileName(Decoder.FileName);
               FreeAndNil(Decoder);
               Decoder := TRESTDWMessageDecoderMIME(NewDecoder);
               If Decoder <> Nil Then
                TRESTDWMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
               If Not Assigned(DWParams) Then
                Begin
                 If (Params.Count = 0) Then
                  Begin
                   DWParams           := TRESTDWParams.Create;
                   DWParams.Encoding  := vEncoding;
                  End
                 Else
                  TRESTDWDataUtils.ParseWebFormsParams (Params, Url,
                                                    QueryParams,
                                                    vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, RequestType);
                End;
               JSONParam    := TJSONParam.Create(DWParams.Encoding);
               JSONParam.ObjectDirection := odIN;
               vObjectName  := '';
               sContentType := '';
               For I := 0 To vDecoderHeaderList.Count - 1 Do
                Begin
                 tmp := vDecoderHeaderList.Strings[I];
                 If Pos('; name="', lowercase(tmp)) > 0 Then
                  Begin
                   vObjectName := Copy(lowercase(tmp),
                                       Pos('; name="', lowercase(tmp)) + length('; name="'),
                                       length(lowercase(tmp)));
                   vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                  End;
                 If Pos('content-type=', lowercase(tmp)) > 0 Then
                  Begin
                   sContentType := Copy(lowercase(tmp),
                                       Pos('content-type=', lowercase(tmp)) + length('content-type='),
                                       length(lowercase(tmp)));
                  End;
                End;
                // Correção de FORM-DATA / FILE criar parametros automaticos: ICO 20-09-2019
               If (vObjectName <> '') Then
                JSONParam.ParamName        := vObjectName
               Else
                Begin
                 vObjectName := 'dwfilename';
                 JSONParam.ParamName       := vObjectName
                End;
               If (sContentType =  '') And
                  (sFile        <> '') Then
                vObjectName := TRESTDWMIMEType.GetMIMEType(sFile);
               JSONParam.ParamName        := vObjectName;
               JSONParam.ParamFileName    := sFile;
               JSONParam.ParamContentType := sContentType;
               ms.Position := 0;
               If (sFile <> '') Then
                JSONParam.LoadFromStream(ms)
               Else If vBinaryEvent Then
                Begin
                 If Assigned(JSONParam) Then
                  FreeAndNil(JSONParam);
                 If ms.Size > 0 Then
                  Begin
                   DWParams.Clear;
                   DWParams.LoadFromStream(ms);
                  End;
                End
               Else If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(TStringStream(ms).DataString)) > 0) Then
                JSONParam.FromJSON(TStringStream(ms).DataString)
               Else
                Begin
                 JSONParam.AsString := StringReplace(StringReplace(TStringStream(ms).DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                 DWParams.Add(JSONParam);
                End;
               ms.Free;
               vDecoderHeaderList.Free;
              End;
             mcptText :
              Begin
               {$IFDEF FPC}
               ms := TStringStream.Create('');
               {$ELSE}
               ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
               {$ENDIF}
               ms.Position := 0;
               newdecoder  := Decoder.ReadBody(ms, msgEnd);
               tmp         := Decoder.Headers.Text;
               FreeAndNil(Decoder);
               Decoder     := TRESTDWMessageDecoderMIME(newdecoder);
               vObjectName := '';
               If Decoder <> Nil Then
                TRESTDWMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
               If pos('dwwelcomemessage', lowercase(tmp)) > 0      Then
                vWelcomeMessage := DecodeStrings(TStringStream(ms).DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
               Else If pos('dwaccesstag', lowercase(tmp)) > 0      Then
                vAccessTag := DecodeStrings(TStringStream(ms).DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
               Else If Pos('dwusecript', lowercase(tmp)) > 0       Then
                vdwCriptKey  := StringToBoolean(TStringStream(ms).DataString)
               Else If pos('datacompression', lowercase(tmp)) > 0  Then
                compresseddata := StringToBoolean(TStringStream(ms).DataString)
               Else If pos('dwencodestrings', lowercase(tmp)) > 0  Then
                encodestrings  := StringToBoolean(TStringStream(ms).DataString)
               Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                dwassyncexec := StringToBoolean(TStringStream(ms).DataString)
               Else If Pos('binaryrequest', lowercase(tmp)) > 0    Then
                vBinaryEvent := StringToBoolean(TStringStream(ms).DataString)
               Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                Begin
                 vdwConnectionDefs   := TConnectionDefs.Create;
                 JSONValue           := TJSONValue.Create;
                 Try
                  JSONValue.Encoding  := vEncoding;
                  JSONValue.Encoded  := True;
                  JSONValue.LoadFromJSON(TStringStream(ms).DataString);
                  vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                 Finally
                  FreeAndNil(JSONValue);
                 End;
                End
               Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                Begin
                 JSONValue           := TJSONValue.Create;
                 Try
                  JSONValue.Encoding := vEncoding;
                  JSONValue.Encoded  := True;
                  JSONValue.LoadFromJSON(TStringStream(ms).DataString);
                  vdwservereventname := JSONValue.Value;
                  If Pos('.', vdwservereventname) > 0 Then
                   Begin
                    baseEventUnit       := Copy(vdwservereventname, InitStrPos, Pos('.', vdwservereventname) - 1 - FinalStrPos);
                    vdwservereventname := Copy(vdwservereventname, Pos('.', vdwservereventname) + 1, Length(vdwservereventname));
                   End;
                 Finally
                  FreeAndNil(JSONValue);
                 End;
                End
               Else
                Begin
                 If DWParams = Nil Then
                  Begin
                   DWParams           := TRESTDWParams.Create;
                   DWParams.Encoding  := vEncoding;
                  End;
                 If (lowercase(vObjectName) = 'binarydata') then
                  Begin
                   DWParams.LoadFromStream(ms);
                   If Assigned(JSONParam) Then
                    FreeAndNil(JSONParam);
                   {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                   FreeAndNil(ms);
                   If DWParams <> Nil Then
                    Begin
                     If (DWParams.ItemsString['dwwelcomemessage']     <> Nil) Then
                      vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                     If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
                      vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                     If (DWParams.ItemsString['datacompression']      <> Nil) Then
                      compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
                     If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
                      encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
                     If (DWParams.ItemsString['dwservereventname']    <> Nil) Then
                      Begin
                       If (vdwservereventname <> GetEventName(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
                        vdwservereventname := DWParams.ItemsString['dwservereventname'].AsString;
                      End;
                     If (DWParams.ItemsString['dwusecript']           <> Nil) Then
                      vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
                     If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
                      dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
                     If (DWParams.ItemsString['binaryrequest']        <> Nil) Then
                      vBinaryEvent          := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
                     If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
                      vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
                    End;
                   If Assigned(decoder) Then
                    FreeAndNil(decoder);
                   Continue;
                  End;
                 vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                 vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                 JSONParam   := TJSONParam.Create(DWParams.Encoding);
                 JSONParam.ObjectDirection := odIN;
                 If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(TStringStream(ms).DataString)) > 0) Then
                  JSONParam.FromJSON(TStringStream(ms).DataString)
                 Else
                  JSONParam.AsString := StringReplace(StringReplace(TStringStream(ms).DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                 JSONParam.ParamName := vObjectName;
                 DWParams.Add(JSONParam);
                End;
               {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
               FreeAndNil(ms);
               If Assigned(Newdecoder)  Then
                FreeAndNil(Newdecoder);
              End;
             mcptIgnore :
              Begin
               Try
                If decoder <> Nil Then
                 FreeAndNil(decoder);
                decoder := TRESTDWMessageDecoderMIME.Create(Nil);
                TRESTDWMessageDecoderMIME(decoder).MIMEBoundary := boundary;
               Finally
               End;
              End;

             mcptEOF:
              Begin
               FreeAndNil(decoder);
               msgEnd := True
              End;

            End;
           Until (Decoder = Nil) Or (msgEnd);
          Finally
           If Assigned(decoder) then
            FreeAndNil(decoder);
          End;
         End
        Else
         Begin
          If (ContentStringStream.Size > 0) And (boundary = '') Then
           Begin
            mb       := TStringStream.Create('');
            Try
             ContentStringStream.Position := 0;
             mb.CopyFrom(ContentStringStream, ContentStringStream.Size);
             ContentStringStream.Position := 0;
             mb.Position  := 0;
             If Not Assigned(DWParams) Then
              TRESTDWDataUtils.ParseWebFormsParams (Params, Url,
                                                QueryParams,
                                                vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, RequestType);
             If Assigned(DWParams.ItemsString['dwReadBodyRaw']) And (DWParams.ItemsString['dwReadBodyRaw'].AsString='1') Then
              TRESTDWDataUtils.ParseBodyRawToDWParam(TStringStream(mb).DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
             Else If (Assigned(DWParams.ItemsString['dwReadBodyBin']) And
                     (DWParams.ItemsString['dwReadBodyBin'].AsString='1')) Then
              TRESTDWDataUtils.ParseBodyBinToDWParam(TStringStream(mb).DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
             Else If (vBinaryEvent) Then
              Begin
               If (pos('--', TStringStream(mb).DataString) > 0) and (pos('boundary', ContentType) > 0) Then
                Begin
                 msgEnd   := False;
                 boundary := ExtractHeaderSubItem(ContentType, 'boundary', QuoteHTTP);
                 startboundary := '--' + boundary;
                 Repeat
                  tmp := ReadLnFromStream(ContentStringStream, -1, True);
                 Until tmp = startboundary;
                End;
                Try
                 Repeat
                  decoder := TRESTDWMessageDecoderMIME.Create(nil);
                  TRESTDWMessageDecoderMIME(decoder).MIMEBoundary := boundary;
                  decoder.SourceStream := ContentStringStream;
                  decoder.FreeSourceStream := False;
                  decoder.ReadHeader;
                  Inc(I);
                  Case Decoder.PartType of
                   mcptAttachment:
                    Begin
                     ms := TMemoryStream.Create;
                     ms.Position := 0;
                     NewDecoder := Decoder.ReadBody(ms, MsgEnd);
                     vDecoderHeaderList := TStringList.Create;
                     vDecoderHeaderList.Assign(Decoder.Headers);
                     sFile := ExtractFileName(Decoder.FileName);
                     FreeAndNil(Decoder);
                     Decoder := TRESTDWMessageDecoderMIME(NewDecoder);
                     If Decoder <> Nil Then
                      TRESTDWMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                     If Not Assigned(DWParams) Then
                      Begin
                       If (Params.Count = 0) Then
                        Begin
                         DWParams           := TRESTDWParams.Create;
                         DWParams.Encoding  := vEncoding;
                        End
                       Else
                        TRESTDWDataUtils.ParseWebFormsParams (Params, Url,
                                                          QueryParams,
                                                          vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, RequestType);
                      End;
                     JSONParam    := TJSONParam.Create(DWParams.Encoding);
                     JSONParam.ObjectDirection := odIN;
                     vObjectName  := '';
                     sContentType := '';
                     for I := 0 to vDecoderHeaderList.Count - 1 do
                      begin
                       tmp := vDecoderHeaderList.Strings[I];
                       if Pos('; name="', lowercase(tmp)) > 0 then
                        begin
                         vObjectName := Copy(lowercase(tmp),
                                             Pos('; name="', lowercase(tmp)) + length('; name="'),
                                             length(lowercase(tmp)));
                         vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                        end;
                       if Pos('content-type=', lowercase(tmp)) > 0 then
                        begin
                         sContentType := Copy(lowercase(tmp),
                                             Pos('content-type=', lowercase(tmp)) + length('content-type='),
                                             length(lowercase(tmp)));
                        end;
                      end;
                      // Correção de FORM-DATA / FILE criar parametros automaticos: ICO 20-09-2019
                      If (lowercase(vObjectName) = 'binarydata') then
                       Begin
                        DWParams.LoadFromStream(ms);
                        If Assigned(JSONParam) Then
                         FreeAndNil(JSONParam);
                        If (DWParams.ItemsString['dwwelcomemessage']     <> Nil) Then
                         vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                        If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
                         vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                        If (DWParams.ItemsString['datacompression']      <> Nil) Then
                         compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
                        If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
                         encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
                        If (DWParams.ItemsString['dwservereventname']    <> Nil) Then
                         Begin
                          If (vdwservereventname <> GetEventName(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
                           vdwservereventname := DWParams.ItemsString['dwservereventname'].AsString;
                         End;
                        If (DWParams.ItemsString['dwusecript']           <> Nil) Then
                         vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
                        If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
                         dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
                        If (DWParams.ItemsString['binaryrequest']        <> Nil) Then
                         vBinaryEvent          := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
                        If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
                         vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
                        if DWParams.ItemsString['dwConnectionDefs'] <> Nil then
                        begin
                         if not Assigned(vdwConnectionDefs) then
                          vdwConnectionDefs := TConnectionDefs.Create;
                         JSONValue           := TJSONValue.Create;
                         Try
                          JSONValue.Encoding := vEncoding;
                          JSONValue.Encoded  := True;
                          JSONValue.LoadFromJSON(DWParams.ItemsString['dwConnectionDefs'].ToJSON);
                          vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                         Finally
                          FreeAndNil(JSONValue);
                         End;
                        end;
                        If Assigned(vDecoderHeaderList) Then
                         FreeAndNil(vDecoderHeaderList);
                        If Assigned(ms) Then
                         FreeAndNil(ms);
                        FreeAndNil(Decoder);
                        Continue;
                       End
                      Else If (vObjectName <> '') Then
                       Begin
                        JSONParam.ParamName        := vObjectName;
                        tmp := StringReplace(StringReplace(TStringStream(ms).DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);//ms.DataString;
                        If Copy(tmp, Length(tmp) -1, 2) = sLineBreak Then
                         Delete(tmp, Length(tmp) -1, 2);
                        If vEncoding = esUtf8 Then
                         JSONParam.SetValue(utf8decode(tmp), JSONParam.Encoded)
                        Else
                         JSONParam.SetValue(tmp, JSONParam.Encoded);
                       End
                      Else
                       Begin
                        vObjectName := 'dwfilename';
                        If (sContentType = '') and (sFile <> '') then
                         vObjectName := TRESTDWMIMEType.GetMIMEType(sFile);
                        JSONParam.ParamName        := vObjectName;
                        JSONParam.ParamFileName    := sFile;
                        JSONParam.ParamContentType := sContentType;
                        If vEncoding = esUtf8 Then
                         JSONParam.SetValue(utf8decode(TStringStream(ms).DataString), JSONParam.Encoded)
                        Else If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(TStringStream(ms).DataString)) > 0) Then
                         JSONParam.FromJSON(TStringStream(ms).DataString)
                        Else
                         JSONParam.SetValue(TStringStream(ms).DataString, JSONParam.Encoded);
                       End;
                      DWParams.Add(JSONParam);
                     FreeAndNil(ms);
                     FreeAndNil(vDecoderHeaderList);
                    End;
                   mcptText :
                    begin
                     {$IFDEF FPC}
                     ms := TStringStream.Create('');
                     {$ELSE}
                     ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
                     {$ENDIF}
                     ms.Position := 0;
                     newdecoder  := Decoder.ReadBody(ms, msgEnd);
                     tmp         := Decoder.Headers.Text;
                     FreeAndNil(Decoder);
                     Decoder     := TRESTDWMessageDecoderMIME(newdecoder);
                     vObjectName := '';
                     If Decoder <> Nil Then
                      TRESTDWMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                     If pos('dwwelcomemessage', lowercase(tmp)) > 0      Then
                      vWelcomeMessage := DecodeStrings(TStringStream(ms).DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                     Else If pos('dwaccesstag', lowercase(tmp)) > 0      Then
                      vAccessTag := DecodeStrings(TStringStream(ms).DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                     Else If Pos('dwusecript', lowercase(tmp)) > 0       Then
                      vdwCriptKey  := StringToBoolean(TStringStream(ms).DataString)
                     Else If pos('datacompression', lowercase(tmp)) > 0  Then
                      compresseddata := StringToBoolean(TStringStream(ms).DataString)
                     Else If pos('dwencodestrings', lowercase(tmp)) > 0  Then
                      encodestrings  := StringToBoolean(TStringStream(ms).DataString)
                     Else If Pos('binaryrequest', lowercase(tmp)) > 0    Then
                      vBinaryEvent := StringToBoolean(TStringStream(ms).DataString)
                     Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                      dwassyncexec := StringToBoolean(TStringStream(ms).DataString)
                     Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                      Begin
                       vdwConnectionDefs   := TConnectionDefs.Create;
                       JSONValue           := TJSONValue.Create;
                       Try
                        JSONValue.Encoding  := vEncoding;
                        JSONValue.Encoded  := True;
                        JSONValue.LoadFromJSON(TStringStream(ms).DataString);
                        vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                       Finally
                        FreeAndNil(JSONValue);
                       End;
                      End
                     Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                      dwassyncexec := StringToBoolean(TStringStream(ms).DataString)
                     Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                      Begin
                       JSONValue            := TJSONValue.Create;
                       Try
                        JSONValue.Encoding  := vEncoding;
                        JSONValue.Encoded   := True;
                        JSONValue.LoadFromJSON(TStringStream(ms).DataString);
                        vdwservereventname := JSONValue.Value;
                        If Pos('.', vdwservereventname) > 0 Then
                         Begin
                          baseEventUnit       := Copy(vdwservereventname, InitStrPos, Pos('.', vdwservereventname) - 1 - FinalStrPos);
                          vdwservereventname := Copy(vUrlToExec, Pos('.', vdwservereventname) + 1, Length(vdwservereventname));
                         End;
                       Finally
                        FreeAndNil(JSONValue);
                       End;
                      End
                     Else
                      Begin
                       If DWParams = Nil Then
                        Begin
                         DWParams           := TRESTDWParams.Create;
                         DWParams.Encoding  := vEncoding;
                        End;
                       vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                       vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                       JSONParam   := TJSONParam.Create(DWParams.Encoding);
                       JSONParam.ObjectDirection := odIN;
                       If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(TStringStream(ms).DataString)) > 0) Then
                        JSONParam.FromJSON(TStringStream(ms).DataString)
                       Else
                        JSONParam.AsString := StringReplace(StringReplace(TStringStream(ms).DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                       JSONParam.ParamName := vObjectName;
                       DWParams.Add(JSONParam);
                      End;
                     {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                     FreeAndNil(ms);
                     FreeAndNil(newdecoder);
                    end;
                   mcptIgnore :
                    Begin
                     Try
                      If decoder <> Nil Then
                       FreeAndNil(decoder);
                     Finally
                     End;
                    End;

                    mcptEOF:
                     Begin
                      FreeAndNil(decoder);
                      msgEnd := True
                     End;

                  End;
                 Until (Decoder = Nil) Or (msgEnd);
                Finally
                 If decoder <> nil then
                  FreeAndNil(decoder);
                End;
              End
             Else If (Params.Count = 0)
                      {$IFNDEF FPC}
                       {$If (CompilerVersion > 23)}
                         And (QueryParams.Length = 0)
                       {$ELSE}
                        And (Length(QueryParams) = 0)
                       {$IFEND}
                      {$ENDIF}
                       Then
              Begin
               If vEncoding = esUtf8 Then
                TRESTDWDataUtils.ParseBodyRawToDWParam(utf8decode(TStringStream(mb).DataString), vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
               Else
                TRESTDWDataUtils.ParseBodyRawToDWParam(TStringStream(mb).DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
              End
             Else
              Begin
               If vEncoding = esUtf8 Then
                Begin
//                 TRESTDWDataUtils.ParseDWParamsURL(utf8decode(TStringStream(mb).DataString), vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 if DWParams.ItemsString['undefined'] = nil then
                  TRESTDWDataUtils.ParseBodyRawToDWParam(mb, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                End
               Else
                Begin
//                 TRESTDWDataUtils.ParseDWParamsURL(TStringStream(mb).DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 if DWParams.ItemsString['undefined'] = nil then
                  TRESTDWDataUtils.ParseBodyRawToDWParam(mb, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                End;
              End;
             {Fim alteração feita por Tiago Istuque - 28/12/2018}
            Finally
             mb.Free;
            End;
           End;
         End;
       End
      Else
       Begin
        aurlContext := vUrlToExec;
        If Not (RequestType In [rtPut, rtPatch, rtDelete]) Then
         Begin
          {$IFDEF FPC}
          If QueryParams <> '' Then
           Begin
            If Trim(QueryParams) <> '' Then
             Begin
              vRequestHeader.Add(Url + '?' + QueryParams + '&' + QueryParams);
              TRESTDWDataUtils.ParseRESTURL (Url + '?' + QueryParams + '&' + QueryParams, vEncoding, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams);
             End
            Else
             Begin
              vRequestHeader.Add(Url + '?' + QueryParams);
              TRESTDWDataUtils.ParseRESTURL (Url + '?' + QueryParams, vEncoding, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams);
              If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then  // Ico Menezes - Post Receber WelcomeMessage   - 20-12-2018
               vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
           End
          Else
           Begin
            vRequestHeader.Add(Params.Text);
            vRequestHeader.Add(Url);
            vRequestHeader.Add(QueryParams);

            TRESTDWDataUtils.ParseWebFormsParams (Params, Url,
                                              QueryParams,
                                              vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, RequestType);
           End;
          {$ELSE}
          If QueryParams <> '' Then
           Begin
            If Trim(QueryParams) <> '' Then
             Begin
              vRequestHeader.Add(Url + '?' + QueryParams);
              TRESTDWDataUtils.ParseRESTURL (Url + '?' + QueryParams, vEncoding, vmark, DWParams);
             End
            Else
             Begin
              vRequestHeader.Add(Url + '?' + QueryParams);
              TRESTDWDataUtils.ParseRESTURL (Url + '?' + QueryParams, vEncoding, vmark, DWParams);
              If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then  // Ico Menezes - Post Receber WelcomeMessage   - 20-12-2018
               vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
           End
           Else
            Begin
             vRequestHeader.Add(Params.Text);
             vRequestHeader.Add(Url);
             vRequestHeader.Add(QueryParams);
             If Not Assigned(DWParams) Then
              TRESTDWDataUtils.ParseWebFormsParams (Params, Url,
                                                QueryParams,
                                                vmark, vEncoding, DWParams, RequestType);
            End;
          {$ENDIF}
          If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
           vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         End
        Else
         Begin
          {$IFDEF FPC}
           vRequestHeader.Add(Params.Text);
           vRequestHeader.Add(Url);
           vRequestHeader.Add(QueryParams);
           TRESTDWDataUtils.ParseWebFormsParams (Params, Url,
                                             QueryParams,
                                             vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, RequestType);
          {$ELSE}
           vRequestHeader.Add(Params.Text);
           vRequestHeader.Add(Url);
           vRequestHeader.Add(QueryParams);
           If Not Assigned(DWParams) Then
            TRESTDWDataUtils.ParseWebFormsParams (Params, Url,
                                              QueryParams,
                                              vmark, vEncoding, DWParams, RequestType);
          {$ENDIF}
         End;
        If ((vUrlToExec = '') And (aurlContext <> '')) And
            (Not (RequestType In [rtGet, rtDelete])) Then
         vUrlToExec := aurlContext;
       End;
     End;
     WelcomeAccept         := True;
     tmp                   := '';
     vAuthenticationString := '';
     vToken                := '';
     vGettoken             := False;
     vAcceptAuth           := False;
     If (vDataRouteList.Count > 0) Then
      Begin
       If Not vDataRouteList.RouteExists(vUrlToExec) Then
        Begin
         vErrorCode := 400;
         JSONStr    := GetPairJSONInt(-5, cInvalidRequest);
        End
       Else
        Begin
         If (vUrlToExec <> '') Then
          Begin
           If Not vDataRouteList.GetServerMethodClass(vUrlToExec, vOldRequest, vServerMethod) Then
            Begin
             vErrorCode := 400;
             JSONStr    := GetPairJSONInt(-5, cInvalidDataContext);
            End;
          End
         Else
          Begin
           If Not vDataRouteList.GetServerMethodClass(vUrlToExec, vOldRequest, vServerMethod) Then
            Begin
             vErrorCode := 400;
             JSONStr    := GetPairJSONInt(-5, cInvalidDataContext);
            End;
          End;
        End;
      End
     Else
      vServerMethod := aServerMethod;
     If Assigned(vServerMethod) Then
      Begin
       If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
        vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
       If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
        vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
       Try
        vTempServerMethods  := vServerMethod.Create(Nil);
        If Not vCORS Then
         FreeAndNil(CORSCustomHeaders);
        If TServerMethodDataModule(vTempServerMethods).GetAction(vOldRequest, DWParams, CORSCustomHeaders) Then
         Begin
          If ((vCORS) And (RequestType = rtOption)) Then
           vErrorCode := 200;
         End;
        vUrlToExec := vOldRequest;
       Finally
       End;
       If (vTempServerMethods.ClassType = TServerMethodDatamodule)             Or
          (vTempServerMethods.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
        Begin
         If TServerMethodDatamodule(vTempServerMethods).QueuedRequest Then
          Begin
           {$IFNDEF FPC}
            {$IF CompilerVersion > 21}
             {$IFDEF WINDOWS}
              InitializeCriticalSection(vCriticalSection);
              EnterCriticalSection(vCriticalSection);
             {$ELSE}
              If Not Assigned(vCriticalSection) Then
               vCriticalSection := TCriticalSection.Create;
              vCriticalSection.Acquire;
             {$ENDIF}
            {$ELSE}
             If Not Assigned(vCriticalSection)  Then
              vCriticalSection := TCriticalSection.Create;
             vCriticalSection.Acquire;
            {$IFEND}
           {$ELSE}
            InitCriticalSection(vCriticalSection);
            EnterCriticalSection(vCriticalSection);
           {$ENDIF}
          End;
         vServerAuthOptions.CopyServerAuthParams(vRDWAuthOptionParam);
         TServerMethodDatamodule(vTempServerMethods).SetClientWelcomeMessage(vWelcomeMessage);
         If (vServerAuthOptions.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken]) Then
          Begin
           vAcceptAuth           := False;
           vErrorCode            := 401;
           vErrorMessage         := cInvalidAuth;
           Case vServerAuthOptions.AuthorizationOption Of
            rdwAOBasic  : Begin
                           vNeedAuthorization := False;
                           vTempEvent   := ReturnEventValidation(TServerMethodDatamodule(vTempServerMethods), vUrlToExec);
                           If vTempEvent = Nil Then
                            Begin
                             vTempContext := ReturnContextValidation(TServerMethodDatamodule(vTempServerMethods), vUrlToExec);
                             If vTempContext <> Nil Then
                              vNeedAuthorization := vTempContext.NeedAuthorization
                             Else
                              vNeedAuthorization := True;
                            End
                           Else
                            vNeedAuthorization := vTempEvent.NeedAuthorization;
                           If vNeedAuthorization Then
                            Begin

                             vAuthenticationString := DecodeStrings(StringReplace(RawHeaders.Values['Authorization'], 'Basic ', '', [rfReplaceAll]){$IFDEF FPC}, vDatabaseCharSet{$ENDIF});; //Authentication.Authentication;// RawHeaders.Values['Authorization'];
                             If (vAuthenticationString <> '') And
                                ((AuthUsername = '') And (AuthPassword = '')) Then
                              PrepareBasicAuth(vAuthenticationString, AuthUsername, AuthPassword);
                             If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserBasicAuth) Then
                              Begin
                               TServerMethodDatamodule(vTempServerMethods).OnUserBasicAuth(vWelcomeMessage, vAccessTag,
                                                                                           AuthUsername,
                                                                                           AuthPassword,
                                                                                           DWParams, vErrorCode, vErrorMessage, vAcceptAuth);
                               If Not vAcceptAuth Then
                                Begin
                                 AuthRealm    := cAuthRealm;
                                 WriteError;
                                 DestroyComponents;
                                 Exit;
                                End;
                              End
                             Else If Not ((AuthUsername = TRESTDWAuthOptionBasic(vServerAuthOptions.OptionParams).Username) And
                                          (AuthPassword = TRESTDWAuthOptionBasic(vServerAuthOptions.OptionParams).Password)) Then
                              Begin
                               AuthRealm := cAuthRealm;
                               WriteError;
                               DestroyComponents;
                               Exit;
                              End;
                            End;
                          End;
            rdwAOBearer : Begin
                           vUrlToken := Lowercase(vUrlToExec);
                           If Copy(vUrlToken, InitStrPos, 1) = '/' then
                            Delete(vUrlToken, InitStrPos, 1);
                           If vUrlToken =
                              Lowercase(TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenEvent) Then
                            Begin
                             vGettoken     := True;
                             vErrorCode    := 404;
                             vErrorMessage := cEventNotFound;
                             If (RequestTypeToRoute(RequestType) In TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Or
                                (crAll in TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Then
                              Begin
                               If Assigned(TServerMethodDatamodule(vTempServerMethods).OnGetToken) Then
                                Begin
                                 vTokenValidate := True;
                                 vAuthTokenParam := TRESTDWAuthOptionTokenServer.Create;
                                 vAuthTokenParam.Assign(TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                {$IFNDEF FPC}
                                 {$IF Defined(HAS_FMX)}
                                  {$IFDEF HAS_UTF8}
                                   If Trim(Token) <> '' Then
                                    vToken       := Token
                                   Else
                                    vToken       := RawHeaders.Values['Authorization'];
                                  {$ELSE}
                                   If Trim(Token) <> '' Then
                                    vToken       := Token
                                   Else
                                    vToken       := RawHeaders.Values['Authorization'];
                                  {$ENDIF}
                                 {$ELSE}
                                  If Trim(Token) <> '' Then
                                   vToken       := Token
                                  Else
                                   vToken       := RawHeaders.Values['Authorization'];
                                 {$IFEND}
                                {$ELSE}
                                 If Trim(Token) <> '' Then
                                   vToken       := Token
                                 Else
                                  vToken        := RawHeaders.Values['Authorization'];
                                {$ENDIF}
                                 If DWParams.ItemsString['RDWParams'] <> Nil Then
                                  Begin
                                   DWParamsD := TRESTDWParams.Create;
                                   if vCripto.Use then
                                     DWParamsD.FromJSON(vCripto.Decrypt(DWParams.ItemsString['RDWParams'].Value))
                                   else
                                     DWParamsD.FromJSON(DWParams.ItemsString['RDWParams'].Value);
                                   TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParamsD,
                                                                                          TRESTDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                          vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                   FreeAndNil(DWParamsD);
                                  End
                                 Else
                                  TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParams,
                                                                                         TRESTDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                         vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                 If Not vAcceptAuth Then
                                  Begin
                                   WriteError;
                                   DestroyComponents;
                                   Exit;
                                  End;
                                End
                               Else
                                Begin
                                 WriteError;
                                 DestroyComponents;
                                 Exit;
                                End;
                              End
                             Else
                              Begin
                               WriteError;
                               DestroyComponents;
                               Exit;
                              End;
                            End
                           Else
                            Begin
                             vErrorCode      := 401;
                             vErrorMessage   := cInvalidAuth;
                             vTokenValidate  := True;
                             vNeedAuthorization := False;
                             vTempEvent   := ReturnEventValidation(TServerMethodDatamodule(vTempServerMethods), vUrlToExec);
                             If vTempEvent = Nil Then
                              Begin
                               vTempContext := ReturnContextValidation(TServerMethodDatamodule(vTempServerMethods), vUrlToExec);
                               If vTempContext <> Nil Then
                                vNeedAuthorization := vTempContext.NeedAuthorization
                               Else
                                vNeedAuthorization := True;
                              End
                             Else
                              vNeedAuthorization := vTempEvent.NeedAuthorization;
                             If vNeedAuthorization Then
                              Begin
                               vAuthTokenParam := TRESTDWAuthOptionTokenServer.Create;
                               vAuthTokenParam.Assign(TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                               If DWParams.ItemsString[TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key] <> Nil Then
                                vToken         := DWParams.ItemsString[TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key].AsString
                               Else
                                Begin
                                {$IFNDEF FPC}
                                 {$IF Defined(HAS_FMX)}
                                  {$IFDEF HAS_UTF8}
                                   If Trim(Token) <> '' Then
                                    vToken       := Token
                                   Else
                                    vToken       := RawHeaders.Values['Authorization'];
                                   If Trim(vToken) <> '' Then
                                    Begin
                                     aToken      := GetTokenString(vToken);
                                     If aToken = '' Then
                                      aToken     := GetBearerString(vToken);
                                     If aToken = '' Then
                                      aToken     := Token;
                                     vToken      := aToken;
                                    End;
                                  {$ELSE}
                                   If Trim(Token) <> '' Then
                                    vToken       := Token
                                   Else
                                    vToken       := RawHeaders.Values['Authorization'];
                                   If Trim(vToken) <> '' Then
                                    Begin
                                     aToken      := GetTokenString(vToken);
                                     If aToken = '' Then
                                      aToken     := GetBearerString(vToken);
                                     If aToken = '' Then
                                      aToken     := Token;
                                     vToken      := aToken;
                                    End;
                                  {$ENDIF}
                                 {$ELSE}
                                  If Trim(Token) <> '' Then
                                   vToken       := Token
                                  Else
                                   vToken       := RawHeaders.Values['Authorization'];
                                  If Trim(vToken) <> '' Then
                                   Begin
                                    aToken      := GetTokenString(vToken);
                                    If aToken = '' Then
                                     aToken     := GetBearerString(vToken);
                                    If aToken = '' Then
                                     aToken     := Token;
                                    vToken      := aToken;
                                   End;
                                 {$IFEND}
                                {$ELSE}
                                 If Trim(Token) <> '' Then
                                  vToken       := Token
                                 Else
                                  vToken       := RawHeaders.Values['Authorization'];
                                 If Trim(vToken) <> '' Then
                                  Begin
                                   aToken      := GetTokenString(vToken);
                                   If aToken = '' Then
                                    aToken     := GetBearerString(vToken);
                                   If aToken = '' Then
                                    aToken     := Token;
                                   vToken      := aToken;
                                  End;
                                {$ENDIF}
                                End;
                               If Not vAuthTokenParam.FromToken(vToken) Then
                                Begin
                                 WriteError;
                                 DestroyComponents;
                                 Exit;
                                End
                               Else
                                vTokenValidate := False;
                               If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth) Then
                                Begin
                                 TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth(vWelcomeMessage, vAccessTag, DWParams,
                                                                                             TRESTDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                             vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                 vTokenValidate := Not(vAcceptAuth);
                                 If Not vAcceptAuth Then
                                  Begin
                                   WriteError;
                                   DestroyComponents;
                                   Exit;
                                  End;
                                End;
                              End
                             Else
                              vTokenValidate := False;
                            End;
                          End;
            rdwAOToken  : Begin
                           vUrlToken := Lowercase(vUrlToExec);
                           If vUrlToken =
                              Lowercase(TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenEvent) Then
                            Begin
                             vGettoken      := True;
                             vErrorCode     := 404;
                             vErrorMessage  := cEventNotFound;
                             If (RequestTypeToRoute(RequestType) In TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Or
                                (crAll in TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Then
                              Begin
                               If Assigned(TServerMethodDatamodule(vTempServerMethods).OnGetToken) Then
                                Begin
                                 vTokenValidate := True;
                                 vAuthTokenParam := TRESTDWAuthOptionTokenServer.Create;
                                 vAuthTokenParam.Assign(TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                {$IFNDEF FPC}
                                 {$IF Defined(HAS_FMX)}
                                  {$IFDEF HAS_UTF8}
                                   If Trim(Token) <> '' Then
                                    vToken       := Token
                                   Else
                                    vToken       := RawHeaders.Values['Authorization'];
                                  {$ELSE}
                                   If Trim(Token) <> '' Then
                                    vToken       := Token
                                   Else
                                    vToken       := RawHeaders.Values['Authorization'];
                                  {$ENDIF}
                                 {$ELSE}
                                  If Trim(Token) <> '' Then
                                   vToken       := Token
                                  Else
                                   vToken       := RawHeaders.Values['Authorization'];
                                 {$IFEND}
                                {$ELSE}
                                 If Trim(Token) <> '' Then
                                  vToken       := Token
                                 Else
                                  vToken       := RawHeaders.Values['Authorization'];
                                {$ENDIF}
                                 If DWParams.ItemsString['RDWParams'] <> Nil Then
                                  Begin
                                   DWParamsD := TRESTDWParams.Create;
                                   if vCripto.Use then
                                     DWParamsD.FromJSON(vCripto.Decrypt(DWParams.ItemsString['RDWParams'].Value))
                                   else
                                     DWParamsD.FromJSON(DWParams.ItemsString['RDWParams'].Value);
                                   TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParamsD,
                                                                                          TRESTDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                          vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                   FreeAndNil(DWParamsD);
                                  End
                                 Else
                                  TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParams,
                                                                                         TRESTDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                         vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                 If Not vAcceptAuth Then
                                  Begin
                                   WriteError;
                                   DestroyComponents;
                                   Exit;
                                  End;
                                End
                               Else
                                Begin
                                 WriteError;
                                 DestroyComponents;
                                 Exit;
                                End;
                              End
                             Else
                              Begin
                               WriteError;
                               DestroyComponents;
                               Exit;
                              End;
                            End
                           Else
                            Begin
                             vErrorCode      := 401;
                             vErrorMessage   := cInvalidAuth;
                             vTokenValidate  := True;
                             vNeedAuthorization := False;
                             vTempEvent   := ReturnEventValidation(TServerMethodDatamodule(vTempServerMethods), vUrlToExec);
                             If vTempEvent = Nil Then
                              Begin
                               vTempContext := ReturnContextValidation(TServerMethodDatamodule(vTempServerMethods), vUrlToExec);
                               If vTempContext <> Nil Then
                                vNeedAuthorization := vTempContext.NeedAuthorization
                               Else
                                vNeedAuthorization := True;
                              End
                             Else
                              vNeedAuthorization := vTempEvent.NeedAuthorization;
                             If vNeedAuthorization Then
                              Begin
                               vAuthTokenParam := TRESTDWAuthOptionTokenServer.Create;
                               vAuthTokenParam.Assign(TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                               If DWParams.ItemsString[TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key] <> Nil Then
                                vToken         := DWParams.ItemsString[TRESTDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key].AsString
                               Else
                                Begin
                                {$IFNDEF FPC}
                                 {$IF Defined(HAS_FMX)}
                                  {$IFDEF HAS_UTF8}
                                   If Trim(Token) <> '' Then
                                    vToken       := Token
                                   Else
                                    vToken       := RawHeaders.Values['Authorization'];
                                   If Trim(vToken) <> '' Then
                                    Begin
                                     aToken      := GetTokenString(vToken);
                                     If aToken = '' Then
                                      aToken     := GetBearerString(vToken);
                                     If aToken = '' Then
                                      aToken     := Token;
                                     vToken      := aToken;
                                    End;
                                  {$ELSE}
                                   If Trim(Token) <> '' Then
                                    vToken       := Token
                                   Else
                                    vToken       := RawHeaders.Values['Authorization'];
                                   If Trim(vToken) <> '' Then
                                    Begin
                                     aToken      := GetTokenString(vToken);
                                     If aToken = '' Then
                                      aToken     := GetBearerString(vToken);
                                     If aToken = '' Then
                                      aToken     := Token;
                                     vToken      := aToken;
                                    End;
                                  {$ENDIF}
                                 {$ELSE}
                                  If Trim(Token) <> '' Then
                                   vToken       := Token
                                  Else
                                   vToken       := RawHeaders.Values['Authorization'];
                                  If Trim(vToken) <> '' Then
                                   Begin
                                    aToken      := GetTokenString(vToken);
                                    If aToken = '' Then
                                     aToken     := GetBearerString(vToken);
                                    If aToken = '' Then
                                     aToken     := Token;
                                    vToken      := aToken;
                                   End;
                                 {$IFEND}
                                {$ELSE}
                                 If Trim(Token) <> '' Then
                                  vToken       := Token
                                 Else
                                  vToken       := RawHeaders.Values['Authorization'];
                                 If Trim(vToken) <> '' Then
                                  Begin
                                   aToken      := GetTokenString(vToken);
                                   If aToken = '' Then
                                    aToken     := GetBearerString(vToken);
                                   If aToken = '' Then
                                    aToken     := Token;
                                   vToken      := aToken;
                                  End;
                                {$ENDIF}
                                End;
                               If Not vAuthTokenParam.FromToken(vToken) Then
                                Begin
                                 WriteError;
                                 DestroyComponents;
                                 Exit;
                                End
                               Else
                                vTokenValidate := False;
                               If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth) Then
                                Begin
                                 TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth(vWelcomeMessage, vAccessTag, DWParams,
                                                                                             TRESTDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                             vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                 vTokenValidate := Not(vAcceptAuth);
                                 If Not vAcceptAuth Then
                                  Begin
                                   WriteError;
                                   DestroyComponents;
                                   Exit;
                                  End;
                                End;
                              End
                             Else
                              vTokenValidate := False;
                            End;
                          End;
           End;
           vErrorCode            := 200;
           vErrorMessage         := '';
          End;
         If Assigned(TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage) then
          TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage, vAccessTag, vdwConnectionDefs, WelcomeAccept, vContentType, vErrorMessage);
        End;
      End
     Else
      Begin
       If vErrorCode <> 400 Then
        Begin
         vErrorCode := 401;
         JSONStr    := GetPairJSONInt(-5, cServerMethodClassNotAssigned);
        End;
      End;
     Try
      If Assigned(vLastRequest) Then
       Begin
        Try
         If Assigned(vLastRequest) Then
          vLastRequest(UserAgent + sLineBreak +
                      RawHTTPCommand);
        Finally
        End;
       End;
      If (vUrlToExec = '') Then
       vUrlToExec := vOldMethod;
      vSpecialServer := False;
      If vTempServerMethods <> Nil Then
       Begin
        ContentType   := cDefaultContentType; //'text';//'application/octet-stream';
        If (vUrlToExec = '')  Or
           (vUrlToExec = '/') Then
         Begin
          If vDefaultPage.Count > 0 Then
           vReplyString  := vDefaultPage.Text
          Else
           vReplyString  := TServerStatusHTML;
          vErrorCode   := 200;
          ContentType  := 'text/html';
         End
        Else
         Begin
          If vEncoding = esUtf8 Then
           sCharSet       := 'utf-8'
          Else
           sCharSet       := 'ansi';
          If DWParams <> Nil Then
           Begin
            If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
             dwassyncexec := DWParams.ItemsString['dwassyncexec'].AsBoolean;
            If DWParams.ItemsString['dwusecript'] <> Nil Then
             vdwCriptKey  := DWParams.ItemsString['dwusecript'].AsBoolean;
           End;
          If dwassyncexec Then
           Begin
            StatusCode               := 200;
            vReplyString                           := AssyncCommandMSG;
            {$IFNDEF FPC}
             If compresseddata Then
              mb                                  := TStringStream(ZCompressStreamNew(vReplyString))
             Else
              mb                                  := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
             mb.Position                          := 0;
             If Not (Assigned(ResultStream)) Then
              ResultStream := TStringStream.Create('');
             WriteStream(mb, ResultStream);
             FreeAndNil(mb);
            {$ELSE}
             If compresseddata Then
              mb                                  := TStringStream(ZCompressStreamNew(vReplyString)) //TStringStream.Create(Utf8Encode(vReplyStringResult))
             Else
              mb                                  := TStringStream.Create(vReplyString);
             mb.Position                          := 0;
             If Not (Assigned(ResultStream)) Then
              ResultStream := TStringStream.Create('');
             WriteStream(mb, ResultStream);
             FreeAndNil(mb);
            {$ENDIF}
           End;
          If DWParams.itemsstring['binaryRequest']        <> Nil Then
           vBinaryEvent := DWParams.itemsstring['binaryRequest'].Value;
          If DWParams.itemsstring['BinaryCompatibleMode'] <> Nil Then
           vBinaryCompatibleMode := DWParams.itemsstring['BinaryCompatibleMode'].Value;
          If DWParams.itemsstring['MetadataRequest']      <> Nil Then
           vMetadata := DWParams.itemsstring['MetadataRequest'].value;
          If (Assigned(DWParams)) And (Assigned(vCripto))        Then
           DWParams.SetCriptOptions(vdwCriptKey, vCripto.Key);
          If (vTempServerMethods.ClassType = TServerMethodDatamodule)             Or
             (vTempServerMethods.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
           Begin
            vServerAuthOptions.CopyServerAuthParams(vRDWAuthOptionParam);
            TServerMethodDatamodule(vTempServerMethods).SetClientInfo(ClientIP, UserAgent, vUrlToExec, ClientPort);
           End;
          If (Not (vGettoken)) And (Not (vTokenValidate)) Then
           Begin
            If Not ServiceMethods(TComponent(vTempServerMethods), AContext, vUrlToExec, vdwservereventname, DWParams,
                                       JSONStr, DataMode, vErrorCode,  vContentType, vServerContextCall, ServerContextStream,
                                       vdwConnectionDefs,  EncodeStrings, vAccessTag, WelcomeAccept, RequestType, vMark,
                                       vRequestHeader, vBinaryEvent, vMetadata, vBinaryCompatibleMode, vCompareContext) Or (lowercase(vContentType) = 'application/php') Then
             Begin
              Result := False;
              If Not dwassyncexec Then
               Begin
                If Not vSpecialServer Then
                 Begin
                  If Url <> '' Then
                   sFile := GetFileOSDir(ExcludeTag(tmp + Url))
                  Else
                   sFile := GetFileOSDir(ExcludeTag(Cmd));
                  vFileExists := RESTDWFileExists(sFile, FRootPath);
                  If Not vFileExists Then
                   Begin
                    tmp := '';
//                      If Referer <> '' Then
//                       tmp := GetLastMethod(Referer);
                    If Url <> '' Then
                     sFile := GetFileOSDir(ExcludeTag(tmp + Url))
                    Else
                     sFile := GetFileOSDir(ExcludeTag(Cmd));
                    vFileExists := RESTDWFileExists(sFile, FRootPath);
                   End;
                  vTagReply := vFileExists or scripttags(ExcludeTag(Cmd));
                  If vTagReply Then
                   Begin
                    ContentType            := TRESTDWMIMEType.GetMIMEType(sFile);
                    If scripttags(ExcludeTag(Cmd)) and Not vFileExists Then
                     ContentStream         := TMemoryStream.Create
                    Else
                     ContentStream         := TRESTDWReadFileExclusiveStream.Create(sFile);
                    ContentStream.Position := 0;
                    StatusCode             := 200;
                    If Not (Assigned(ResultStream)) Then
                     ResultStream := TStringStream.Create('');
                    WriteStream(ContentStream, ResultStream);
                    FreeAndNil(ContentStream);
                    Result                 := True;
                   End;
                 End;
               End;
             End;
           End
          Else
           Begin
            JSONStr    := vToken;
            DataMode   := dmRAW;
            vErrorCode := 200;
            Result     := True;
           End;
         End;
       End;
      Try
       If Assigned(vRequestHeader) Then
        Begin
         vRequestHeader.Clear;
         FreeAndNil(vRequestHeader);
        End;
       If Assigned(vServerMethod) Then
        If Assigned(vTempServerMethods) Then
         Begin
          If TServerMethodDatamodule(vTempServerMethods).QueuedRequest Then
           Begin
            {$IFNDEF FPC}
             {$IF CompilerVersion > 21}
              {$IFDEF WINDOWS}
               If Assigned(vCriticalSection) Then
                Begin
                 LeaveCriticalSection(vCriticalSection);
                 DeleteCriticalSection(vCriticalSection);
                End;
              {$ELSE}
               If Assigned(vCriticalSection) Then
                Begin
                 vCriticalSection.Release;
//                 FreeAndNil(vCriticalSection);
                End;
              {$ENDIF}
             {$ELSE}
              If Assigned(vCriticalSection) Then
               Begin
                vCriticalSection.Release;
                FreeAndNil(vCriticalSection);
               End;
             {$IFEND}
            {$ELSE}
             LeaveCriticalSection(vCriticalSection);
             DoneCriticalSection(vCriticalSection);
            {$ENDIF}
           End;
          Try
           {$IFDEF POSIX} //no linux nao precisa libertar porque é [weak]
           vTempServerMethods.free;
           {$ELSE}
           vTempServerMethods.free;
           {$ENDIF}
           vTempServerMethods := Nil;
          Except
          End;
         End;
       If Not dwassyncexec Then
        Begin
         If (Not (vTagReply)) Then
          Begin
           If vEncoding = esUtf8 Then
            sCharSet := 'utf-8'
           Else
            sCharSet := 'ansi';
           If vContentType <> '' Then
            ContentType := vContentType;
           If Not vServerContextCall Then
            Begin
             If (vUrlToExec <> '') Then
              Begin
               If DataMode in [dmDataware] Then
                Begin
                 If Trim(JSONStr) <> '' Then
                  Begin
                   If Not(((Pos('{', JSONStr) > 0)   And
                           (Pos('}', JSONStr) > 0))  Or
                          ((Pos('[', JSONStr) > 0)   And
                           (Pos(']', JSONStr) > 0))) Then
                    Begin
                     If Not (WelcomeAccept) And (vErrorMessage <> '') Then
                       JSONStr := escape_chars(vErrorMessage)
                     Else If Not((JSONStr[InitStrPos] = '"')  And
                            (JSONStr[Length(JSONStr)] = '"')) Then
                      JSONStr := '"' + JSONStr + '"';
                    End;
                  End;
//                 vErrorCode   := 200;
                 If (RequestType <> rtOption) Then
                  Begin
                   If vBinaryEvent Then
                    vReplyString := JSONStr
                   Else
                    Begin
                     If Not(((vUrlToExec = '') Or (vUrlToExec = '/')) And (RequestType = rtGet)) Then
                      If Not (WelcomeAccept) And (vErrorMessage <> '') Then
                       Begin
                        If vEncode_Errors then
                         vReplyString := escape_chars(vErrorMessage)
                        Else
                         vReplyString := vErrorMessage;
                       End
                      Else
                       vReplyString := Format(TValueDisp, [GetParamsReturn(DWParams), JSONStr]);
                    End;
                  End;
                End
               Else If DataMode = dmRAW Then
                Begin
                 If (Trim(JSONStr) = '') And (WelcomeAccept) Then
                  vReplyString := '{}'
                 Else If Not (WelcomeAccept) And (vErrorMessage <> '') Then
                  vReplyString := escape_chars(vErrorMessage)
                 Else
                  vReplyString := JSONStr;
                End;
              End;
             If Assigned(DWParams) Then
              Begin
               If DWParams.RequestHeaders.Output.Count > 0 Then
                Begin
                 For I := 0 To DWParams.RequestHeaders.Output.Count -1 Do
                  RequestHeaders.Add(DWParams.RequestHeaders.Output[I]);
                End;
              End;
             StatusCode                 := vErrorCode;
             If Assigned(DWParams) And
               (Pos(DWParams.Url_Redirect, Cmd) = 0) And
               (DWParams.Url_Redirect <> '') Then
              Begin
               vUrlRedirect := DWParams.Url_Redirect;
               If Assigned(Redirect) Then
                Redirect(vUrlRedirect, AContext);
              End;
             If compresseddata Then
              Begin
               If vBinaryEvent Then
                Begin
                 ms := TMemoryStream.Create;
                 If vGettoken Then
                  Begin
                   DWParams.Clear;
                   DWParams.CreateParam('token', vReplyString);
                  End;
                 Try
                  If DWParams.ItemsString['MessageError'] = Nil Then
                  Begin
                   DWParams.CreateParam('MessageError');
                   DWParams.ItemsString['MessageError'].ObjectDirection := odOut;
                  End;
                  If ((JSONStr <> TReplyOK) and (JSONStr <> Trim(''))) then
                   Begin
                    If DWParams.ItemsString['MessageError'].AsString = '' Then
                     DWParams.ItemsString['MessageError'].AsString := JSONStr;
                   End
                  Else
                   DWParams.ItemsString['MessageError'].AsString := '';
                  DWParams.SaveToStream(ms, tdwpxt_OUT);
                  ZCompressStreamD(ms, ResultStream);
                 Finally
                  FreeAndNil(ms);
                 End;
                End
               Else
                Begin
                 If Assigned(ResultStream) Then
                  FreeAndNil(ResultStream);
                 ResultStream            := TStringStream(ZCompressStreamNew(vReplyString));
                End;
               If vErrorCode <> 200 Then
                ResponseString           := escape_chars(vReplyString)
              End
             Else
              Begin
               {$IFNDEF FPC}
                {$IF CompilerVersion > 21}
                 If vBinaryEvent Then
                  Begin
                   mb := TStringStream.Create('');
                   Try
                    DWParams.SaveToStream(mb, tdwpxt_OUT);
                   Finally
                   End;
                  End
                 Else
                  mb                                  := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                 mb.Position                          := 0;
                 If Not (Assigned(ResultStream)) Then
                  ResultStream := TStringStream.Create('');
                 WriteStream(mb, ResultStream);
                 FreeAndNil(mb);
                {$ELSE}
                 If vBinaryEvent Then
                  Begin
                   mb := TStringStream.Create('');
                   Try
                    DWParams.SaveToStream(mb, tdwpxt_OUT);
                   Finally
                   End;
                   If Not (Assigned(ResultStream)) Then
                    ResultStream := TStringStream.Create('');
                   WriteStream(mb, ResultStream);
                   FreeAndNil(mb);
                  End
                 Else
                  ResponseString := vReplyString;
                {$IFEND}
               {$ELSE}
                If vBinaryEvent Then
                 Begin
                  mb := TStringStream.Create('');
                  Try
                   DWParams.SaveToStream(mb, tdwpxt_OUT);
                  Finally
                  End;
                  If Not (Assigned(ResultStream)) Then
                   ResultStream := TStringStream.Create('');
                  WriteStream(mb, ResultStream);
                  FreeAndNil(mb);
                 End
                Else
                 Begin
                  If vEncoding = esUtf8 Then
                   mb                                   := TStringStream.Create(Utf8Encode(vReplyString))
                  Else
                   mb                                   := TStringStream.Create(vReplyString);
                  mb.Position                           := 0;
                  If Not (Assigned(ResultStream)) Then
                   ResultStream := TStringStream.Create('');
                  WriteStream(mb, ResultStream);
                  FreeAndNil(mb);
                 End;
               {$ENDIF}
              End;
            End
           Else
            Begin
             LocalDoc := '';
             If TEncodeSelect(vEncoding) = esUtf8 Then
              sCharset := 'utf-8'
             Else If TEncodeSelect(vEncoding) in [esANSI, esASCII] Then
              sCharset := 'ansi';
             If Not vSpecialServer Then
              Begin
               StatusCode             := vErrorCode;
               If ServerContextStream <> Nil Then
                Begin
                 If Not (Assigned(ResultStream)) Then
                  ResultStream := TStringStream.Create('');
                 WriteStream(ServerContextStream, ResultStream);
                 FreeAndNil(ServerContextStream);
                End
               Else
                Begin
                 {$IFDEF FPC}
                  If vEncoding = esUtf8 Then
                   mb                                  := TStringStream.Create(Utf8Encode(JSONStr))
                  Else
                   mb                                  := TStringStream.Create(JSONStr);
                  mb.Position                           := 0;
                  If Not (Assigned(ResultStream)) Then
                   ResultStream := TStringStream.Create('');                  WriteStream(mb, ResultStream);
                  FreeAndNil(mb);
                 {$ELSE}
                  {$IF CompilerVersion > 21}
                   mb                                   := TStringStream.Create(JSONStr{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                   mb.Position                          := 0;
                   If Not (Assigned(ResultStream)) Then
                    ResultStream := TStringStream.Create('');
                   WriteStream(mb, ResultStream);
                   FreeAndNil(mb);
                  {$ELSE}
                   ResponseString            := JSONStr;
                  {$IFEND}
                 {$ENDIF}
                End;
              End;
            End;
          End;
        End;
      Finally
//        FreeAndNil(mb);
      End;
      If Assigned(vLastResponse) Then
       Begin
        Try
         If vReplyString = '' Then
          vLastResponse(JSONStr)
         Else
          vLastResponse(vReplyString);
        Finally
        End;
       End;
     Finally
      If Assigned(vServerMethod) Then
       If Assigned(vTempServerMethods) Then
        Begin
         Try
          {$IFDEF POSIX} //no linux nao precisa libertar porque é [weak]
          {$ELSE}
          FreeAndNil(vTempServerMethods); //.free;
          {$ENDIF}
          vTempServerMethods := Nil;
         Except
         End;
        End;
     End;
   End;
 Finally
  DestroyComponents;
 End;
End;

Procedure TRESTServiceBase.SetActive(Value : Boolean);
Begin
 vActive := Value;
End;

Procedure TRESTServiceBase.SetCORSCustomHeader (Value : TStringList);
Var
 I : Integer;
Begin
 vCORSCustomHeaders.Clear;
 For I := 0 To Value.Count -1 do
  vCORSCustomHeaders.Add(Value[I]);
End;

Procedure TRESTServiceBase.SetDefaultPage (Value : TStringList);
Var
 I : Integer;
Begin
 vDefaultPage.Clear;
 For I := 0 To Value.Count -1 do
  vDefaultPage.Add(Value[I]);
End;

Procedure TRESTServiceBase.SetServerMethod(Value : TComponentClass);
Begin
 {$IFNDEF FPC}
  If (Value.InheritsFrom(TServerMethodDatamodule)) Or
     (Value            = TServerMethodDatamodule) Then
   aServerMethod := Value;
 {$ELSE}
  If (Value.ClassType.InheritsFrom(TServerMethodDatamodule)) Or
     (Value             = TServerMethodDatamodule) Then
   aServerMethod := Value;
 {$ENDIF}
End;

//Procedure TRESTServiceBase.Loaded;
//Begin
// Inherited;
// If Assigned(vOnCreate) Then
//  vOnCreate(Self);
//End;

//procedure TRESTServiceBase.Notification(AComponent: TComponent;
//  Operation: TOperation);
//begin
// If (Operation = opRemove) then
//  Begin
//  End;
// Inherited Notification(AComponent, Operation);
//end;

Procedure TRESTServiceBase.GetTableNames(ServerMethodsClass   : TComponent;
                                           Var Pooler           : String;
                                           Var DWParams         : TRESTDWParams;
                                           ConnectionDefs       : TConnectionDefs;
                                           hEncodeStrings       : Boolean;
                                           AccessTag            : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vStrings      : TStringList;
Begin
 // lazarus iniciando com sujeira de memoria vStrings
 vStrings := nil;

 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           vStrings := TStringList.Create;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.GetTableNames(vStrings, vError, vMessageError);
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              DWParams.ItemsString['Result'].CriptOptions.Use := False;
              DWParams.ItemsString['Result'].SetValue(vStrings.Text, DWParams.ItemsString['Result'].Encoded);
             End;
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           FreeAndNil(vStrings);
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceBase.GetFieldNames(ServerMethodsClass   : TComponent;
                                           Var Pooler           : String;
                                           Var DWParams         : TRESTDWParams;
                                           ConnectionDefs       : TConnectionDefs;
                                           hEncodeStrings       : Boolean;
                                           AccessTag            : String);
Var
 I             : Integer;
 vError        : Boolean;
 vTableName,
 vMessageError : String;
 vStrings      : TStringList;
Begin
 // lazarus iniciando com sujeira de memoria vStrings
 vStrings := nil;

 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           vStrings := TStringList.Create;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            DWParams.ItemsString['TableName'].CriptOptions.Use := False;
            vTableName := DWParams.ItemsString['TableName'].AsString;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.GetFieldNames(vTableName, vStrings, vError, vMessageError);
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              DWParams.ItemsString['Result'].CriptOptions.Use := False;
              DWParams.ItemsString['Result'].SetValue(vStrings.Text, DWParams.ItemsString['Result'].Encoded);
             End;
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           FreeAndNil(vStrings);
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceBase.GetKeyFieldNames(ServerMethodsClass      : TComponent;
                                              Var Pooler              : String;
                                              Var DWParams            : TRESTDWParams;
                                              ConnectionDefs          : TConnectionDefs;
                                              hEncodeStrings          : Boolean;
                                              AccessTag               : String);
Var
 I             : Integer;
 vError        : Boolean;
 vTableName,
 vMessageError : String;
 vStrings      : TStringList;
Begin
 // lazarus iniciando com sujeira de memoria vStrings
 vStrings := nil;

 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           vStrings := TStringList.Create;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            DWParams.ItemsString['TableName'].CriptOptions.Use := False;
            vTableName := DWParams.ItemsString['TableName'].AsString;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.GetKeyFieldNames(vTableName, vStrings, vError, vMessageError);
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              DWParams.ItemsString['Result'].CriptOptions.Use := False;
              DWParams.ItemsString['Result'].SetValue(vStrings.Text, DWParams.ItemsString['Result'].Encoded);
             End;
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           FreeAndNil(vStrings);
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceBase.GetPoolerList(ServerMethodsClass : TComponent;
                                           Var PoolerList     : String;
                                           AccessTag          : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
          Continue;
        End;
       If PoolerList = '' then
        PoolerList := Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])
       Else
        PoolerList := PoolerList + '|' + Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]);
      End;
    End;
  End;
End;

Function TRESTServiceBase.ServiceMethods(BaseObject              : TComponent;
                                         AContext                : TComponent;
                                         UrlToExec,
                                         Poolername              : String;
                                         Var DWParams            : TRESTDWParams;
                                         Var JSONStr             : String;
                                         Var DataMode            : TDataMode;
                                         Var ErrorCode           : Integer;
                                         Var ContentType         : String;
                                         Var ServerContextCall   : Boolean;
                                         Var ServerContextStream : TMemoryStream;
                                         ConnectionDefs          : TConnectionDefs;
                                         hEncodeStrings          : Boolean;
                                         AccessTag               : String;
                                         WelcomeAccept           : Boolean;
                                         Const RequestType       : TRequestType;
                                         mark                    : String;
                                         RequestHeader           : TStringList;
                                         BinaryEvent             : Boolean;
                                         Metadata                : Boolean;
                                         BinaryCompatibleMode    : Boolean;
                                         CompareContext          : Boolean) : Boolean;
Var
 vJsonMSG,
 vResult,
 vResultIP,
 vBaseUrl,
 vUrlMethod,
 vOldServerEvent :  String;
 vError,
 vInvalidTag     : Boolean;
 JSONParam       : TJSONParam;
 vByteStream     : TRESTDWBytes;
 aBinaryBlob     : TStream;
 Procedure ParseURL;
 Var
  I           : Integer;
  vTempString : String;
  vEvent      : Boolean;
 Begin
  vBaseUrl     := '';
  vUrlMethod   := '';
  vEvent       := True;
  vTempString  := UrlToExec;
  If Length(vTempString) > 0 Then
   Begin
    If (Copy(vTempString, Length(vTempString), 1) = '/') Or
       (Copy(vTempString, Length(vTempString), 1) = '?') Then
     vTempString := Copy(vTempString, 1, Length(vTempString) -1);
    For I := Length(vTempString) - FinalStrPos Downto InitStrPos Do
     Begin
      If vEvent Then
       Begin
        If vTempString[I] <> '/' Then
         vUrlMethod := vTempString[I] + vUrlMethod
        Else
         Begin
          vUrlMethod := UpperCase(vUrlMethod);
          vBaseUrl   := vTempString[I];
          vEvent     := False;
         End;
       End
      Else
       vBaseUrl   := vTempString[I] + vBaseUrl;
     End;
   End;
 End;
Begin
 Result       := False;
 ParseURL;
 If WelcomeAccept Then
  Begin
   If (vUrlMethod = UpperCase('GetPoolerList')) Then
    Begin
     Result     := True;
     GetPoolerList(BaseObject, vResult, AccessTag);
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResult,
                                             DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If (vUrlMethod = UpperCase('GetServerEventsList')) Then
    Begin
     Result     := True;
     GetServerEventsList(BaseObject, vResult, AccessTag);
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResult,
                                             DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If (vUrlMethod = UpperCase('EchoPooler')) Then
    Begin
     vJsonMSG := TReplyNOK;
     Result     := True;
     If DWParams.ItemsString['Pooler'] <> Nil Then
      Begin
       vResult    := '';
       vResult    := DWParams.ItemsString['Pooler'].Value;
       EchoPooler(BaseObject, AContext, vResult, vResultIP, AccessTag, vInvalidTag);
       If BinaryEvent Then
        Begin
         vByteStream := StringToBytes(vResultIP);
         BufferBase  := TRESTDWBufferBase.Create; //Cria Pacote Base
         aBinaryBlob := TMemoryStream.Create;
         Try
          BufferBase.InputBytes(vByteStream);
          SetLength(vByteStream, 0);
          BufferBase.SaveToStream(aBinaryBlob);
         Finally
          FreeAndNil(BufferBase);
          If DWParams.ItemsString['Result'] <> Nil Then
           DWParams.ItemsString['Result'].LoadFromStream(aBinaryBlob);
          FreeAndNil(aBinaryBlob);
         End;
        End
       Else
        Begin
         If DWParams.ItemsString['Result'] <> Nil Then
          DWParams.ItemsString['Result'].SetValue(vResultIP,
                                                  DWParams.ItemsString['Result'].Encoded);
        End;
      End
     Else
      Begin
       If DWParams.ItemsString['Error'] = Nil Then
        Begin
         JSONParam                 := TJSONParam.Create(DWParams.Encoding);
         JSONParam.ParamName       := 'Error';
         JSONParam.ObjectDirection := odOut;
         DWParams.Add(JSONParam);
        End;
       If DWParams.ItemsString['MessageError'] = Nil Then
        Begin
         JSONParam                 := TJSONParam.Create(DWParams.Encoding);
         JSONParam.ParamName       := 'MessageError';
         JSONParam.ObjectDirection := odOut;
         DWParams.Add(JSONParam);
        End;
       DWParams.ItemsString['MessageError'].AsString := cInvalidBlankPooler;
       DWParams.ItemsString['Error'].AsBoolean       := True;
      End;
     If vResultIP <> '' Then
      JSONStr    := TReplyOK
     Else
      Begin
       JSONStr    := TReplyInvalidPooler;
       ErrorCode   := 400;
      End;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandPureJSON') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandPureJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandPureJSONTB') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandPureJSONTB(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandJSON') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandJSONTB') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandJSONTB(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdatesJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, BinaryEvent, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdatesTB') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdatesJSONTB(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, BinaryEvent, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCache') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdates_MassiveCache(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCacheTB') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdates_MassiveCacheTB(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ProcessMassiveSQLCache') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ProcessMassiveSQLCache(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GetTableNames') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     GetTableNames(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GetFieldNames') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     GetFieldNames(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GetKeyFieldNames') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     GetKeyFieldNames(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID_PARAMS') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('OpenDatasets') Then
    Begin
     vResult     := DWParams.ItemsString['Pooler'].Value;
     OpenDatasets(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent, BinaryCompatibleMode);
     Result      := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GETEVENTS') Then
    Begin
     If DWParams.ItemsString['Error'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Error';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     If DWParams.ItemsString['MessageError'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'MessageError';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     GetEvents(BaseObject, Poolername, UrlToExec, DWParams);
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
     Result      := JSONStr = TReplyOK;
    End
   Else
    Begin
     If CompareContext Then
      Begin
       vOldServerEvent := UrlToExec;
       UrlToExec       := '';
      End;
     If PoolerName <> '' Then
      vBaseUrl := PoolerName;
     If ReturnEvent(BaseObject, vUrlMethod, vBaseUrl, vResult, DWParams, DataMode, ErrorCode, ContentType, Accesstag, RequestType, RequestHeader) Then
      Begin
       JSONStr := vResult;
       Result  := JSONStr <> '';
      End
     Else
      Begin
       ErrorCode := 200;
       If CompareContext Then
        UrlToExec := vOldServerEvent;
       Result  := ReturnContext(BaseObject, vUrlMethod, vBaseUrl, vResult, ContentType, ServerContextStream, vError, DWParams, RequestType, Mark, RequestHeader, ErrorCode);
       If Not (Result) Or (vError) Then
        Begin
         DataMode    := dmRAW;
         If Not WelcomeAccept Then
          Begin
           JSONStr     := TReplyInvalidWelcome;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 500;
          End
         Else
          Begin
           JSONStr    := vResult;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 404;
          End;
        End
       Else
        Begin
         ServerContextCall := True;
         DataMode  := dmRAW;
         JSONStr   := vResult;
        End;
      End;
    End;
  End
 Else If (vUrlMethod = UpperCase('GETEVENTS')) And (Not (vForceWelcomeAccess)) Then
  Begin
   If DWParams.ItemsString['Error'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'Error';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   If DWParams.ItemsString['MessageError'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'MessageError';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   If DWParams.ItemsString['Result'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'Result';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   GetEvents(BaseObject, vResult, UrlToExec, DWParams);
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      JSONStr   := DWParams.ItemsString['MessageError'].AsString
     Else
      Begin
       JSONStr   := TReplyNOK;
       ErrorCode  := 500;
      End;
    End;
   Result      := JSONStr = TReplyOK;
  End
 Else If (Not (vForceWelcomeAccess)) Then
  Begin
   If Not WelcomeAccept Then
    JSONStr := TReplyInvalidWelcome
   Else
    Begin
     If ReturnEvent(BaseObject, vUrlMethod, UrlToExec, vResult, DWParams, DataMode, ErrorCode, ContentType, Accesstag, RequestType, RequestHeader) Then
      Begin
       JSONStr := vResult;
       Result  := JSONStr <> '';
      End
     Else
      Begin
       ErrorCode := 200;
       Result  := ReturnContext(BaseObject, vUrlMethod, UrlToExec, vResult, ContentType, ServerContextStream, vError, DWParams, RequestType, Mark, RequestHeader, ErrorCode);
       If Not (Result) Or (vError) Then
        Begin
         DataMode   := dmRAW;
         If Not WelcomeAccept Then
          Begin
           JSONStr    := TReplyInvalidWelcome;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 500;
          End
         Else
          Begin
           JSONStr := vResult;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 404;
           Result  := False;
          End;
        End
       Else
        Begin
         DataMode  := dmRAW;
         JSONStr   := vResult;
         If (ErrorCode <= 0)  Or
            (ErrorCode > 299) Then
          ErrorCode := 200;
        End;
      End;
    End;
  End
 Else
  Begin
   If Not WelcomeAccept Then
    JSONStr := TReplyInvalidWelcome
   Else
    JSONStr := TReplyNOK;
   Result  := False;
   If DWParams.ItemsString['Error']        <> Nil Then
    DWParams.ItemsString['Error'].AsBoolean := True;
   If DWParams.ItemsString['MessageError'] <> Nil Then
    DWParams.ItemsString['MessageError'].AsString := cInvalidWelcomeMessage
   Else
    Begin
     If (ErrorCode <= 0)  Or
        (ErrorCode = 200) Then
      ErrorCode  := 500;
    End;
  End;
End;

Procedure TRESTServiceBase.ExecuteCommandPureJSON(ServerMethodsClass   : TComponent;
                                                    Var Pooler           : String;
                                                    Var DWParams         : TRESTDWParams;
                                                    ConnectionDefs       : TConnectionDefs;
                                                    hEncodeStrings       : Boolean;
                                                    AccessTag            : String;
                                                    BinaryEvent          : Boolean;
                                                    Metadata             : Boolean;
                                                    BinaryCompatibleMode : Boolean);
Var
 vRowsAffected,
 I             : Integer;
 vEncoded,
 vError,
 vExecute      : Boolean;
 vTempJSON,
 vMessageError : String;
 BinaryBlob    : TMemoryStream;
Begin
 vRowsAffected := 0;
 BinaryBlob    := Nil;
 Try
  vTempJSON := '';
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vExecute := DWParams.ItemsString['Execute'].AsBoolean;
            vError   := DWParams.ItemsString['Error'].AsBoolean;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                      vError,
                                                                                                      vMessageError,
                                                                                                      BinaryBlob,
                                                                                                      vRowsAffected,
                                                                                                      vExecute, BinaryEvent, Metadata,
                                                                                                      BinaryCompatibleMode);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean := vError;
            If DWParams.ItemsString['RowsAffected'] <> Nil Then
             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              vEncoded := DWParams.ItemsString['Result'].Encoded;
              If (BinaryEvent) And (Not (vError)) Then
               DWParams.ItemsString['Result'].LoadFromStream(TStream(BinaryBlob))
              Else If Not(vError) And (vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON, vEncoded)
              Else
               DWParams.ItemsString['Result'].SetValue('');
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.ExecuteCommandPureJSONTB(ServerMethodsClass   : TComponent;
                                                      Var Pooler           : String;
                                                      Var DWParams         : TRESTDWParams;
                                                      ConnectionDefs       : TConnectionDefs;
                                                      hEncodeStrings       : Boolean;
                                                      AccessTag            : String;
                                                      BinaryEvent          : Boolean;
                                                      Metadata             : Boolean;
                                                      BinaryCompatibleMode : Boolean);
Var
 vRowsAffected,
 I             : Integer;
 vEncoded,
 vError        : Boolean;
 vTempJSON,
 vTablename,
 vMessageError : String;
 BinaryBlob    : TMemoryStream;
Begin
 vRowsAffected := 0;
 BinaryBlob    := Nil;
 Try
  vTempJSON := '';
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vError     := DWParams.ItemsString['Error'].AsBoolean;
            vTablename := DWParams.ItemsString['rdwtablename'].AsString;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, vError,
                                                                                                        vMessageError,
                                                                                                        BinaryBlob,
                                                                                                        vRowsAffected,
                                                                                                        BinaryEvent, Metadata,
                                                                                                        BinaryCompatibleMode);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean := vError;
            If DWParams.ItemsString['RowsAffected'] <> Nil Then
             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              vEncoded := DWParams.ItemsString['Result'].Encoded;
              If (BinaryEvent) And (Not (vError)) Then
               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
              Else If Not(vError) And (vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON, vEncoded)
              Else
               DWParams.ItemsString['Result'].SetValue('');
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.ExecuteCommandJSON(ServerMethodsClass   : TComponent;
                                                Var Pooler           : String;
                                                Var DWParams         : TRESTDWParams;
                                                ConnectionDefs       : TConnectionDefs;
                                                hEncodeStrings       : Boolean;
                                                AccessTag            : String;
                                                BinaryEvent          : Boolean;
                                                Metadata             : Boolean;
                                                BinaryCompatibleMode : Boolean);
Var
 vRowsAffected,
 I             : Integer;
 vError,
 vExecute      : Boolean;
 vTempJSON,
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
 BinaryBlob    : TMemoryStream;
Begin
 DWParamsD     := Nil;
 BinaryBlob    := Nil;
 vTempJSON     := '';
 vRowsAffected := 0;
 Try
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vExecute := DWParams.ItemsString['Execute'].AsBoolean;
            vError   := DWParams.ItemsString['Error'].AsBoolean;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            If DWParams.ItemsString['Params'] <> Nil Then
             Begin
              DWParamsD := TRESTDWParams.Create;
              DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
             End;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             If DWParamsD <> Nil Then
              Begin
               vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                        DWParamsD, vError, vMessageError,
                                                                                                        BinaryBlob,
                                                                                                        vRowsAffected,
                                                                                                        vExecute, BinaryEvent, Metadata,
                                                                                                        BinaryCompatibleMode);
               DWParamsD.Free;
              End
             Else
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                       vError,
                                                                                                       vMessageError,
                                                                                                       BinaryBlob,
                                                                                                       vRowsAffected,
                                                                                                       vExecute, BinaryEvent, Metadata);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean        := vError;
            If DWParams.ItemsString['RowsAffected'] <> Nil Then
             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              If (BinaryEvent) And (Not (vError)) Then
               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
              Else If Not(vError) And(vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON, DWParams.ItemsString['Result'].Encoded)
              Else
               DWParams.ItemsString['Result'].SetValue('');
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.ExecuteCommandJSONTB(ServerMethodsClass   : TComponent;
                                                  Var Pooler           : String;
                                                  Var DWParams         : TRESTDWParams;
                                                  ConnectionDefs       : TConnectionDefs;
                                                  hEncodeStrings       : Boolean;
                                                  AccessTag            : String;
                                                  BinaryEvent          : Boolean;
                                                  Metadata             : Boolean;
                                                  BinaryCompatibleMode : Boolean);
Var
 vRowsAffected,
 I             : Integer;
 vError        : Boolean;
 vTempJSON,
 vTablename,
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
 BinaryBlob    : TMemoryStream;
Begin
 DWParamsD     := Nil;
 BinaryBlob    := Nil;
 vTempJSON     := '';
 vRowsAffected := 0;
 Try
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vError     := DWParams.ItemsString['Error'].AsBoolean;
            vTablename := DWParams.ItemsString['rdwtablename'].AsString;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            If DWParams.ItemsString['Params'] <> Nil Then
             Begin
              DWParamsD := TRESTDWParams.Create;
              DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
             End;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             If DWParamsD <> Nil Then
              Begin
               vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, DWParamsD, vError, vMessageError,
                                                                                                          BinaryBlob,
                                                                                                          vRowsAffected,
                                                                                                          BinaryEvent, Metadata,
                                                                                                          BinaryCompatibleMode);
               DWParamsD.Free;
              End
             Else
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, vError,
                                                                                                         vMessageError,
                                                                                                         BinaryBlob,
                                                                                                         vRowsAffected,
                                                                                                         BinaryEvent, Metadata);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean        := vError;
            If DWParams.ItemsString['RowsAffected'] <> Nil Then
             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              If (BinaryEvent) And (Not (vError)) Then
               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
              Else If Not(vError) And(vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON, DWParams.ItemsString['Result'].Encoded)
              Else
               DWParams.ItemsString['Result'].SetValue('');
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.InsertMySQLReturnID(ServerMethodsClass : TComponent;
                                                 Var Pooler         : String;
                                                 Var DWParams       : TRESTDWParams;
                                                 ConnectionDefs     : TConnectionDefs;
                                                 hEncodeStrings     : Boolean;
                                                 AccessTag          : String);
Var
 I,
 vTempJSON     : Integer;
 vError        : Boolean;
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
Begin
 DWParamsD := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TRESTDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            If DWParamsD <> Nil Then
             Begin
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
                                                                                                            DWParamsD, vError, vMessageError);
              DWParamsD.Free;
             End
            Else
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
                                                                                                           vError,
                                                                                                           vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> -1 Then
              DWParams.ItemsString['Result'].SetValue(IntToStr(vTempJSON), DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('-1');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceBase.ApplyUpdatesJSON(ServerMethodsClass : TComponent;
                                              Var Pooler         : String;
                                              Var DWParams       : TRESTDWParams;
                                              ConnectionDefs     : TConnectionDefs;
                                              hEncodeStrings,
                                              BinaryEvent        : Boolean;
                                              AccessTag          : String);
Var
 vRowsAffected,
 I             : Integer;
 vTempJSON     : TJSONValue;
 vBufferStream : TStream;
 vError        : Boolean;
 vSQL,
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
Begin
 DWParamsD     := Nil;
 vTempJSON     := Nil;
 vRowsAffected := 0;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TRESTDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           If DWParams.ItemsString['SQL'] <> Nil Then
            vSQL := DWParams.ItemsString['SQL'].Value;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            DWParams.ItemsString['Massive'].CriptOptions.Use := False;
            If BinaryEvent Then
             Begin
              vBufferStream := TMemoryStream.Create;
              Try
               DWParams.ItemsString['Massive'].SaveToStream(vBufferStream);
               vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates(vBufferStream,
                                                                                                      vSQL,
                                                                                                      DWParamsD, vError, vMessageError, vRowsAffected);
              Finally
               FreeAndNil(vBufferStream);
              End;
             End
            Else
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates(DWParams.ItemsString['Massive'].AsString,
                                                                                                    vSQL,
                                                                                                    DWParamsD, vError, vMessageError, vRowsAffected);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If DWParamsD <> Nil Then
            DWParamsD.Free;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['RowsAffected'] <> Nil) Then
            DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             DWParams.ItemsString['Result'].CriptOptions.Use := False;
             If vTempJSON <> Nil Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.ApplyUpdatesJSONTB(ServerMethodsClass : TComponent;
                                                Var Pooler         : String;
                                                Var DWParams       : TRESTDWParams;
                                                ConnectionDefs     : TConnectionDefs;
                                                hEncodeStrings,
                                                BinaryEvent        : Boolean;
                                                AccessTag          : String);
Var
 vRowsAffected,
 I             : Integer;
 vTempJSON     : TJSONValue;
 vError        : Boolean;
 vSQL,
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
Begin
 DWParamsD     := Nil;
 vTempJSON     := Nil;
 vRowsAffected := 0;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TRESTDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           If DWParams.ItemsString['SQL'] <> Nil Then
            vSQL := DWParams.ItemsString['SQL'].Value;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            DWParams.ItemsString['Massive'].CriptOptions.Use := False;
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdatesTB(DWParams.ItemsString['Massive'].AsString,
                                                                                                     DWParamsD, vError, vMessageError, vRowsAffected);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If DWParamsD <> Nil Then
            DWParamsD.Free;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['RowsAffected'] <> Nil) Then
            DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             DWParams.ItemsString['Result'].CriptOptions.Use := False;
             If vTempJSON <> Nil Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.OpenDatasets(ServerMethodsClass   : TComponent;
                                        Var Pooler           : String;
                                        Var DWParams         : TRESTDWParams;
                                        ConnectionDefs       : TConnectionDefs;
                                        hEncodeStrings       : Boolean;
                                        AccessTag            : String;
                                        BinaryRequest        : Boolean;
                                        BinaryCompatible     : Boolean);
Var
 I             : Integer;
 vTempJSON     : TJSONValue;
 vError        : Boolean;
 vMessageError : String;
 aDataPack     : TStream;
 BinaryBlob    : TMemoryStream;
Begin
 BinaryBlob    := Nil;
 vTempJSON     := Nil;
 aDataPack     := Nil;
 Try
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vError   := DWParams.ItemsString['Error'].AsBoolean;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             If Not BinaryRequest Then
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.OpenDatasets(DWParams.ItemsString['LinesDataset'].Value,
                                                                                                     vError, vMessageError, BinaryBlob)
             Else
              Begin
               DWParams.ItemsString['DatasetStream'].SaveToStream(aDataPack);
               BinaryBlob := TMemoryStream(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.OpenDatasets(aDataPack,  vError,        vMessageError,
                                                                                                                     BinaryBlob, BinaryRequest, BinaryCompatible));
               FreeAndNil(aDataPack);
               If Assigned(BinaryBlob) Then
                DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
               Else
                DWParams.ItemsString['Result'].SetValue('');
               If Assigned(BinaryBlob) Then
                FreeAndNil(BinaryBlob);
              End;
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean        := vError;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              If Not BinaryRequest Then
               Begin
                If Not vTempJSON.IsNull Then //vTempJSON <> Nil Then
                 DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON)
                Else
                 DWParams.ItemsString['Result'].SetValue('');
                FreeAndNil(vTempJSON);
               End;
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                                       Var Pooler         : String;
                                                       Var DWParams       : TRESTDWParams;
                                                       ConnectionDefs     : TConnectionDefs;
                                                       hEncodeStrings     : Boolean;
                                                       AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
 vBufferStream : TStream;
Begin
 vTempJSON     := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            vBufferStream := TMemoryStream.Create;
            Try
             DWParams.ItemsString['MassiveCache'].SaveToStream(vBufferStream);
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCache(vBufferStream, vError, vMessageError);
            Finally
             FreeAndNil(vBufferStream);
            End;
//            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCache(DWParams.ItemsString['MassiveCache'].AsString,
//                                                                                                   vError,  vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             If Assigned(vTempJSON) Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.Value, DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.ApplyUpdates_MassiveCacheTB(ServerMethodsClass : TComponent;
                                                         Var Pooler         : String;
                                                         Var DWParams       : TRESTDWParams;
                                                         ConnectionDefs     : TConnectionDefs;
                                                         hEncodeStrings     : Boolean;
                                                         AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
Begin
 vTempJSON     := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            DWParams.ItemsString['MassiveCache'].CriptOptions.Use := False;
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCacheTB(DWParams.ItemsString['MassiveCache'].AsString,
                                                                                                                  vError,  vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             If Assigned(vTempJSON) Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.Value, DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.ProcessMassiveSQLCache(ServerMethodsClass      : TComponent;
                                                    Var Pooler              : String;
                                                    Var DWParams            : TRESTDWParams;
                                                    ConnectionDefs          : TConnectionDefs;
                                                    hEncodeStrings          : Boolean;
                                                    AccessTag               : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
Begin
 vTempJSON     := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := cInvalidAccessTag;
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ProcessMassiveSQLCache(DWParams.ItemsString['MassiveSQLCache'].AsString,
                                                                                                   vError,  vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].SetValue(vTempJSON.Value, DWParams.ItemsString['Result'].Encoded);
               FreeAndNil(vTempJSON);
              End
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.GetEvents(ServerMethodsClass : TComponent;
                                     Pooler,
                                     urlContext         : String;
                                     Var DWParams       : TRESTDWParams);
Var
 I         : Integer;
 vError    : Boolean;
 vTempJSON : String;
 iContSE   : Integer;
Begin
 vTempJSON := '';
 If ServerMethodsClass <> Nil Then
  Begin
   iContSE := 0;
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ((ServerMethodsClass.Components[i].InheritsFrom(TRESTDWServerEvents)) Or
         (ServerMethodsClass.Components[i] is TRESTDWServerEvents)) Then
      Begin
       iContSE := iContSE + 1;
       If (LowerCase(urlContext) = LowerCase(TRESTDWServerEvents(ServerMethodsClass.Components[i]).DefaultEvent)) or
          (LowerCase(Pooler)     = LowerCase(ServerMethodsClass.Components[i].Name)) Or
          (LowerCase(Pooler)     = LowerCase(Format('%s.%s', [ServerMethodsClass.Classname, ServerMethodsClass.Components[i].Name])))  Then
        Begin
         If vTempJSON = '' Then
          vTempJSON := Format('%s', [TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
         Else
          vTempJSON := vTempJSON + Format(', %s', [TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON]);
         Break;
        End;
      End;
    End;
   vError := vTempJSON = '';
   If vError Then
    Begin
     DWParams.ItemsString['MessageError'].AsString := cEventNotFound;
     If iContSE > 1 then
      DWParams.ItemsString['MessageError'].AsString := cMultipleServerEvents;
    End;
   DWParams.ItemsString['Error'].AsBoolean        := vError;
   If DWParams.ItemsString['Result'] <> Nil Then
    Begin
     If vTempJSON <> '' Then
      DWParams.ItemsString['Result'].SetValue(Format('[%s]', [vTempJSON]), DWParams.ItemsString['Result'].Encoded)
     Else
      DWParams.ItemsString['Result'].SetValue('');
    End;
  End;
End;

Function TRESTServiceBase.ReturnEvent(ServerMethodsClass : TComponent;
                                      Pooler,
                                      urlContext          : String;
                                      Var vResult         : String;
                                      Var DWParams        : TRESTDWParams;
                                      Var DataMode        : TDataMode;
                                      Var ErrorCode       : Integer;
                                      Var ContentType,
                                      AccessTag           : String;
                                      Const RequestType   : TRequestType;
                                      Var   RequestHeader : TStringList) : Boolean;
Var
 I, B               : Integer;
 vRejected,
 vTagService        : Boolean;
 vErrorMessage,
 vStrAcceptedRoutes : String;
 vDWRoutes          : TRESTDWRoutes;
Begin
 Result        := False;
 vRejected     := False;
 vTagService   := Result;
 vErrorMessage := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWServerEvents Then
      Begin
       vTagService := False;
       For B := 0 To TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.Count -1 Do
        Begin
         If (LowerCase(urlContext) = LowerCase(TRESTDWServerEvents(ServerMethodsClass.Components[i]).DefaultEvent)) Or
            (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) or
            (LowerCase(urlContext) = LowerCase(ServerMethodsClass.classname + '.' +
                                               ServerMethodsClass.Components[i].Name)) Then
          vTagService := TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil
         Else
          Begin
           If LowerCase(urlContext) = LowerCase(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events[B].BaseURL) Then
            vTagService := LowerCase(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events[B].EventName) = LowerCase(Pooler);
          End;
         If vTagService Then
          Break;
        End;
       If vTagService Then
        Begin
         Result   := True;
         DataMode := dmRAW;
         If Trim(TRESTDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             If DWParams.ItemsString['dwencodestrings'] <> Nil Then
              vResult := EncodeStrings(cInvalidAccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
             Else
              vResult := cInvalidAccessTag;
             ErrorCode := 401;
             Result  := True;
             Break;
            End;
          End;
         If (RequestTypeToRoute(RequestType) In TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Or
            (crAll in TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Then
          Begin
           vResult := '';
           TRESTDWServerEvents(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
           If Assigned(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest) Then
            TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage, ErrorCode, RequestHeader);
           If Not vRejected Then
            Begin
             TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].CompareParams(DWParams);
             Try
              If RequestType <> rtOption Then
               Begin
                If Assigned(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute) Then
                 TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler]);
                If Assigned(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType) Then
                 TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType(DWParams, vResult, RequestType, ErrorCode, RequestHeader)
                Else If Assigned(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent) Then
                 TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent(DWParams, vResult);
               End;
              DataMode := TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].DataMode;
              ContentType := TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].defaultcontenttype;
              If Trim(ContentType) = '' Then
               ContentType := cDefaultContentType;
             Except
              On E : Exception Do
               Begin
                If DWParams.ItemsString['dwencodestrings'] <> Nil Then
                 vResult := EncodeStrings(e.Message{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                Else
                 vResult := e.Message;
                Result  := True;
                If (ErrorCode <= 0)  Or
                   (ErrorCode = 200) Then
                 ErrorCode := 500;
               End;
             End;
            End
           Else
            Begin
             If vErrorMessage <> '' Then
              Begin
               ContentType := 'text/html';
               vResult     := vErrorMessage;
              End
             Else
              vResult   := cRequestRejected;
             If (ErrorCode <= 0)  Or
                (ErrorCode = 200) Then
              ErrorCode := 401;
            End;
           If Trim(vResult) = '' Then
            vResult := TReplyOK;
          End
         Else
          Begin
           vStrAcceptedRoutes := '';
           vDWRoutes := TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes;
           If crGet in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', GET'
             Else
              vStrAcceptedRoutes := 'GET';
            End;
           If crPost in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', POST'
             Else
              vStrAcceptedRoutes := 'POST';
            End;
           If crPut in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', PUT'
             Else
              vStrAcceptedRoutes := 'PUT';
            End;
           If crPatch in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', PATCH'
             Else
              vStrAcceptedRoutes := 'PATCH';
            End;
           If crDelete in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', DELETE'
             Else
              vStrAcceptedRoutes := 'DELETE';
            End;
           If crOption in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', OPTION'
             Else
              vStrAcceptedRoutes := 'OPTION';
            End;
           If vStrAcceptedRoutes <> '' then
            Begin
             vResult   := cRequestRejectedMethods + vStrAcceptedRoutes;
             ErrorCode := 403;
            End
           Else
            Begin
             vResult   := cRequestAcceptableMethods;
             ErrorCode := 500;
            End;
          End;
         Break;
        End
       Else
        vResult := cEventNotFound;
      End;
    End;
  End;
 If Not vTagService Then
  If (ErrorCode <= 0)  Or
     (ErrorCode = 200) Then
   ErrorCode := 404;
End;

Procedure TRESTServiceBase.GetServerEventsList(ServerMethodsClass   : TComponent;
                                                 Var ServerEventsList : String;
                                                 AccessTag            : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWServerEvents Then
      Begin
       If Trim(TRESTDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TRESTDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
          Continue;
        End;
       If ServerEventsList = '' then
        ServerEventsList := Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])
       Else
        ServerEventsList := ServerEventsList + '|' + Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]);
      End;
    End;
  End;
End;

Function TRESTServiceBase.ReturnContext(ServerMethodsClass      : TComponent;
                                          Pooler,
                                          urlContext              : String;
                                          Var vResult,
                                          ContentType             : String;
                                          Var ServerContextStream : TMemoryStream;
                                          Var Error               : Boolean;
                                          Var   DWParams          : TRESTDWParams;
                                          Const RequestType       : TRequestType;
                                          mark                    : String;
                                          RequestHeader           : TStringList;
                                          Var ErrorCode           : Integer) : Boolean;
Var
 I, B               : Integer;
 vRejected,
 vTagService,
 vDefaultPageB      : Boolean;
 vErrorMessage,
 vBaseHeader,
 vRootContext,
 vStrAcceptedRoutes : String;
 vDWRoutes          : TRESTDWRoutes;
Begin
 Result         := False;
 vDefaultPageB  := False;
 vRejected      := False;
 Error          := False;
 vTagService    := Result;
 vRootContext   := '';
 vErrorMessage  := '';
 If (Pooler <> '') And (urlContext = '') Then
  Begin
   urlContext := Pooler;
   Pooler     := '';
  End;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWServerContext Then
      Begin
       vTagService := False;
       For B := 0 To TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.Count -1 Do
        Begin
         If LowerCase(urlContext) = LowerCase(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList[B].BaseURL) Then
          vTagService := LowerCase(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList[B].ContextName) = LowerCase(Pooler);
         If vTagService Then
          Break;
        End;
       If Not vTagService Then
        Begin
         Error   := True;
         vResult := cInvalidRequest;
        End
       Else
        Begin
         Result   := False;
         If (RequestTypeToRoute(RequestType) In TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Or
            (crAll in TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Then
          Begin
           If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest) Then
            TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage, ErrorCode, RequestHeader);
           If RequestType <> rtOption Then
            Begin
             If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer) Then
              TRESTDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer(ServerMethodsClass.Components[i]);
             If Not vRejected Then
              Begin
               Result  := True;
               vResult := '';
               TRESTDWServerContext(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
               TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].CompareParams(DWParams);
               Try
                ContentType := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContentType;
                If mark <> '' Then
                 Begin
                  vResult    := '';
                  Result     := Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules);
                  If Result Then
                   Begin
                    Result   := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark] <> Nil;
                    If Result Then
                     Begin
                      Result := Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute);
                      If Result Then
                       Begin
                        ContentType := cDefaultContentType;
                        TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute(DWParams, ContentType, vResult);
                       End;
                     End;
                   End;
                 End
                Else If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules) Then
                 Begin
                  vBaseHeader := '';
                  ContentType := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.ContentType;
                  vResult := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.BuildContext(TRESTDWServerContext(ServerMethodsClass.Components[i]).BaseHeader,
                                                                                                                                            TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].IgnoreBaseHeader);
                 End
                Else
                 Begin
                  If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall) Then
                   TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler]);
                  vDefaultPageB := Not Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest);
                  If Not vDefaultPageB Then
                   TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest(DWParams, ContentType, vResult, RequestType);
                  If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream) Then
                   Begin
                    vDefaultPageB := False;
                    ServerContextStream := TMemoryStream.Create;
                    Try
                     TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream(DWParams, ContentType, ServerContextStream, RequestType, ErrorCode);
                    Finally
                     If ServerContextStream.Size = 0 Then
                      FreeAndNil(ServerContextStream);
                    End;
                   End;
                  If vDefaultPageB Then
                   Begin
                    vBaseHeader := '';
                    If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).BaseHeader) Then
                     vBaseHeader := TRESTDWServerContext(ServerMethodsClass.Components[i]).BaseHeader.Text;
                    vResult := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].DefaultHtml.Text;
                    If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer) Then
                     TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer(vBaseHeader, ContentType, vResult, RequestType);
                   End;
                 End;
               Except
                On E : Exception Do
                 Begin
                  If DWParams.ItemsString['dwencodestrings'] <> Nil Then
                   vResult := EncodeStrings(e.Message{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                  Else
                   vResult := e.Message;
                  Error   := True;
                  Exit;
                 End;
               End;
              End
             Else
              Begin
               If vErrorMessage <> '' Then
                Begin
                 ContentType := 'text/html';
                 vResult     := vErrorMessage;
                End
               Else
                vResult   := cRequestRejected;
              End;
            End;
           If Trim(vResult) = '' Then
            vResult := TReplyOK;
          End
         Else
          Begin
           vStrAcceptedRoutes := '';
           vDWRoutes := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes;
           If crGet in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', GET'
             Else
              vStrAcceptedRoutes := 'GET';
            End;
           If crPost in vDWRoutes Then
            Begin
               If vStrAcceptedRoutes <> '' Then
                vStrAcceptedRoutes := vStrAcceptedRoutes + ', POST'
               Else
                vStrAcceptedRoutes := 'POST';
            End;
           If crPut in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', PUT'
             Else
              vStrAcceptedRoutes := 'PUT';
            End;
           If crPatch in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', PATCH'
             Else
              vStrAcceptedRoutes := 'PATCH';
            End;
           If crDelete in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', DELETE'
             Else
              vStrAcceptedRoutes := 'DELETE';
            End;
           If crOption in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', OPTION'
             Else
              vStrAcceptedRoutes := 'OPTION';
            End;
           If vStrAcceptedRoutes <> '' Then
            Begin
             vResult   := cRequestRejectedMethods + vStrAcceptedRoutes;
             ErrorCode := 403;
            End
           Else
            Begin
             vResult   := cRequestAcceptableMethods;
             ErrorCode := 500;
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceBase.SetServerAuthOptions(AuthenticationOptions : TRESTDWServerAuthOptionParams);
Begin
 If Assigned(AuthenticationOptions) Then
  vServerAuthOptions := AuthenticationOptions;
End;

Procedure TRESTServiceBase.ClearDataRoute;
Begin
 vDataRouteList.ClearList;
End;

Procedure TRESTServiceBase.AddDataRoute(DataRoute : String; MethodClass : TComponentClass);
Var
 vDataRoute : TRESTDWDataRoute;
Begin
 vDataRoute                   := TRESTDWDataRoute.Create;
 vDataRoute.DataRoute         := DataRoute;
 vDataRoute.ServerMethodClass := MethodClass;
 vDataRouteList.Add(vDataRoute);
End;

Function TRESTServiceBase.GetDataRouteCount: integer;
Begin
  Result := vDataRouteList.Count;
End;

Constructor TRESTServiceBase.Create(AOwner: TComponent);
Begin
 Inherited;
 vProxyOptions                          := TProxyConnectionInfo.Create;
 vDefaultPage                           := TStringList.Create;
 vCORSCustomHeaders                     := TStringList.Create;
 vDataRouteList                         := TRESTDWDataRouteList.Create;
 vCORSCustomHeaders.Add('Access-Control-Allow-Origin=*');
 vCORSCustomHeaders.Add('Access-Control-Allow-Headers=Content-Type, Origin, Accept, Authorization, X-CUSTOM-HEADER');
// vCORSCustomHeaders.Add('Access-Control-Allow-Credentials=true');
 vCripto                                := TCripto.Create;
 {$IFDEF FPC}
 vDatabaseCharSet                       := csUndefined;
 {$ELSE}
 {$ENDIF}
 vServerAuthOptions                     := TRESTDWServerAuthOptionParams.Create(Self);
 vActive                                := False;
 vEncode_Errors                         := False;
 vEncoding                              := esUtf8;
 vServicePort                           := 8082;
 vForceWelcomeAccess                    := False;
 vCORS                                  := False;
 vPathTraversalRaiseError               := True;
 FRootPath                              := '/';
 aDefaultUrl                            := '';
 vServiceTimeout                        := -1;

 vServerIpVersionConfig := TRESTDWServerIpVersionConfig.Create;
End;

Destructor TRESTServiceBase.Destroy;
Begin
 If Assigned(vProxyOptions)          Then
  FreeAndNil(vProxyOptions);
 If Assigned(vCripto)                Then
  FreeAndNil(vCripto);
 If Assigned(vDefaultPage)           Then
  FreeAndNil(vDefaultPage);
 If Assigned(vCORSCustomHeaders)     Then
  FreeAndNil(vCORSCustomHeaders);
 If Assigned(vDataRouteList)         Then
  FreeAndNil(vDataRouteList);
 If Assigned(vServerAuthOptions)     Then
  FreeAndNil(vServerAuthOptions);
 If Assigned(vServerIpVersionConfig) Then
  FreeAndNil(vServerIpVersionConfig);
 Inherited;
End;

{ TRESTServiceShareBase }

Constructor TRESTServiceShareBase.Create(AOwner  : TComponent);
Begin
 Inherited;
 Active      := True;
 ServicePort := 0;
End;

Constructor TRESTShellServicesBase.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
End;

Destructor TRESTShellServicesBase.Destroy;
Begin
 Inherited Destroy;
End;

Procedure TRESTShellServicesBase.Loaded;
Begin
 Inherited;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;

Procedure TRESTShellServicesBase.Notification(AComponent : TComponent;
                                              Operation  : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
End;

{ TRESTDWServerIpVersionConfig }

constructor TRESTDWServerIpVersionConfig.Create;
begin
  vServerIpVersion := sivIPv4;

  vIPv4Address := '0.0.0.0';

  vIPv6Address := '::';
end;

destructor TRESTDWServerIpVersionConfig.Destroy;
begin
  //
end;

end.
