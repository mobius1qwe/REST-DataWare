unit uRESTDWBasicDB;

{$I ..\..\Source\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

Uses
 {$IFDEF RESTDWLAZARUS}memds,{$ENDIF}
 {$IFDEF RESTDWFMX}System.UITypes, {$ENDIF}
 SysUtils, Classes, Db, SyncObjs, Variants,
 uRESTDWDataUtils, uRESTDWBasicTypes, uRESTDWProtoTypes,
 uRESTDWPoolermethod, uRESTDWComponentEvents, uRESTDWAbout, uRESTDWConsts,
 uRESTDWResponseTranslator, uRESTDWBasicClass, uRESTDWJSONObject, uRESTDWParams,
 uRESTDWBasic, uRESTDWMassiveBuffer, uRESTDWMasterDetailData,
 uRESTDWMemoryDataset, uRESTDWBufferBase, uRESTDWDriverBase, uRESTDWTools;

Type
 TOnExecuteData           = Procedure                                        Of Object;
 TOnThreadRequestError    = Procedure (ErrorCode          : Integer;
                                       MessageError       : String)          Of Object;
 TOnEventDB               = Procedure (DataSet            : TDataSet)        Of Object;
 TOnFiltered              = Procedure (Var Filtered       : Boolean;
                                       Var Filter         : String)          Of Object;
 TOnAfterScroll           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnBeforeRefresh         = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterRefresh          = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterOpen             = Procedure (DataSet            : TDataSet)        Of Object;
 TOnBeforeClose           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterClose            = Procedure (DataSet            : TDataSet)        Of Object;
 TOnCalcFields            = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterCancel           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterInsert           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnBeforeDelete          = Procedure (DataSet            : TDataSet)        Of Object;
 TOnBeforePost            = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterPost             = Procedure (DataSet            : TDataSet)        Of Object;
 TOnAfterDelete           = Procedure (DataSet            : TDataSet)        Of Object;
 TOnEventConnection       = Procedure (Sucess             : Boolean;
                                       Const Error        : String)          Of Object;
 TOnEventBeforeConnection = Procedure (Sender             : TComponent)      Of Object;
 TOnEventTimer            = Procedure                                        Of Object;
 TBeforeGetRecords        = Procedure (Sender             : TObject;
                                       Var OwnerData      : OleVariant)      Of Object;
 TOnPrepareConnection     = Procedure (Var ConnectionDefs : TConnectionDefs) Of Object;
 TOnFieldGetValue         = Procedure (Value              : Variant)         Of Object;
 TOnTableBeforeOpen       = Procedure (Var Dataset        : TDataset;
                                       Params             : TRESTDWParams;
                                       Tablename          : String)          Of Object;
 TOnQueryBeforeOpen       = Procedure (Var Dataset        : TDataset;
                                       Params             : TRESTDWParams)       Of Object;
 TOnQueryException        = Procedure (Var Dataset        : TDataset;
                                       Params             : TRESTDWParams;
                                       Error              : String)       Of Object;

Type
 TTimerData = Class(TThread)
 Private
  FValue : Integer;          //Milisegundos para execução
  FLock  : TCriticalSection; //Seção crítica
  vEvent : TOnEventTimer;    //Evento a ser executado
 Public
  Property OnEventTimer : TOnEventTimer Read vEvent Write vEvent; //Evento a ser executado
 Protected
  Constructor Create(AValue: Integer; ALock: TCriticalSection);   //Construtor do Evento
  Procedure   Execute; Override;                                  //Procedure de Execução automática
End;

Type
 TAutoCheckData = Class(TPersistent)
 Private
  vAutoCheck : Boolean;                            //Se tem Autochecagem
  vInTime    : Integer;                            //Em milisegundos o timer
  Timer      : TTimerData;                         //Thread do temporizador
  vEvent     : TOnEventTimer;                      //Evento a executar
  FLock      : TCriticalSection;                   //CriticalSection para execução segura
  Procedure  SetState(Value : Boolean);            //Ativa ou desativa a classe
  Procedure  SetInTime(Value : Integer);           //Diz o Timeout
  Procedure  SetEventTimer(Value : TOnEventTimer); //Seta o Evento a ser executado
 Public
  Constructor Create; //Cria o Componente
  Destructor  Destroy;Override;//Destroy a Classe
  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property AutoCheck    : Boolean       Read vAutoCheck Write SetState;      //Se tem Autochecagem
  Property InTime       : Integer       Read vInTime    Write SetInTime;     //Em milisegundos o timer
  Property OnEventTimer : TOnEventTimer Read vEvent     Write SetEventTimer; //Evento a executar
End;

 TProxyOptions = Class(TPersistent)
 Private
  vServer,              //Servidor Proxy na Rede
  vLogin,               //Login do Servidor Proxy
  vPassword : String;   //Senha do Servidor Proxy
  vPort     : Integer;  //Porta do Servidor Proxy
 Public
  Constructor Create;
  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property Server   : String  Read vServer   Write vServer;   //Servidor Proxy na Rede
  Property Port     : Integer Read vPort     Write vPort;     //Porta do Servidor Proxy
  Property Login    : String  Read vLogin    Write vLogin;    //Login do Servidor Proxy
  Property Password : String  Read vPassword Write vPassword; //Senha do Servidor Proxy
End;

Type
 TClientConnectionDefs = Class(TPersistent)
 Private
  FOwner  : TPersistent;
  vActive : Boolean;
  vConnectionDefs : TConnectionDefs;
  Procedure DestroyParam;
  Procedure SetClientConnectionDefs(Value : Boolean);
  Procedure SetConnectionDefs(Value : TConnectionDefs);
 Protected
  Function    GetOwner            : TPersistent; Override;
 Public
  Constructor Create(AOwner         : TPersistent); //Cria o Componente
  Destructor  Destroy;Override;//Destroy a Classe
 Published
  Property Active         : Boolean         Read vActive         Write SetClientConnectionDefs;
  Property ConnectionDefs : TConnectionDefs Read vConnectionDefs Write SetConnectionDefs;
End;

Type
 TRESTDWConnectionParams = Class(TPersistent)
 Private
  vBinaryRequest,
  vEncodeStrings,
  vCompression,
  vActive,
  vProxy                : Boolean;
  vTimeOut,
  vPoolerPort           : Integer;
  vAccessTag,
  vWelcomeMessage,
  vRestPooler,
  vDataRoute,
  vRestWebService,
  vPassword,
  vLogin                : String;
  vPoolerList           : TStringList;
  vProxyOptions         : TProxyOptions;
  vEncoding             : TEncodeSelect;
  {$IFDEF RESTDWLAZARUS}
  vDatabaseCharSet      : TDatabaseCharSet;
  {$ENDIF}
  vTypeRequest          : TTypeRequest;
  vClientConnectionDefs : TClientConnectionDefs;
  vAuthOptionParams     : TRESTDWClientAuthOptionParams;
  Function    GetPoolerList     : TStringList;
 Public
  Constructor Create;
  Destructor  Destroy;Override;//Destroy a Classe
  Property    PoolerList         : TStringList                Read GetPoolerList;
 Published
  Property Active                : Boolean                    Read vActive               Write vActive;            //Seta o Estado da Conexão
  Property BinaryRequest         : Boolean                    Read vBinaryRequest        Write vBinaryRequest;
  Property Compression           : Boolean                    Read vCompression          Write vCompression;       //Compressão de Dados
  Property Login                 : String                     Read vLogin                Write vLogin;             //Login do Usuário caso haja autenticação
  Property Password              : String                     Read vPassword             Write vPassword;          //Senha do Usuário caso haja autenticação
  Property Proxy                 : Boolean                    Read vProxy                Write vProxy;             //Diz se tem servidor Proxy
  Property ProxyOptions          : TProxyOptions              Read vProxyOptions         Write vProxyOptions;      //Se tem Proxy diz quais as opções
  Property PoolerService         : String                     Read vRestWebService       Write vRestWebService;    //Host do WebService REST
  Property DataRoute             : String                     Read vDataRoute            Write vDataRoute;           //URL do WebService REST
  Property PoolerPort            : Integer                    Read vPoolerPort           Write vPoolerPort;        //A Porta do Pooler do DataSet
  Property PoolerName            : String                     Read vRestPooler           Write vRestPooler;        //Qual o Pooler de Conexão ligado ao componente
  Property RequestTimeOut        : Integer                    Read vTimeOut              Write vTimeOut;           //Timeout da Requisição
  Property EncodeStrings         : Boolean                    Read vEncodeStrings        Write vEncodeStrings;
  Property Encoding              : TEncodeSelect              Read vEncoding             Write vEncoding;          //Encoding da string
  Property WelcomeMessage        : String                     Read vWelcomeMessage       Write vWelcomeMessage;
  {$IFDEF RESTDWLAZARUS}
  Property DatabaseCharSet       : TDatabaseCharSet           Read vDatabaseCharSet      Write vDatabaseCharSet;
  {$ENDIF}
  Property AccessTag             : String                     Read vAccessTag            Write vAccessTag;
  Property TypeRequest           : TTypeRequest               Read vTypeRequest          Write vTypeRequest       Default trHttp;
  Property AuthenticationOptions : TRESTDWClientAuthOptionParams Read vAuthOptionParams     Write vAuthOptionParams;
  Property ClientConnectionDefs  : TClientConnectionDefs      Read vClientConnectionDefs Write vClientConnectionDefs;
End;

Type
 TRESTDWConnectionServer = Class(TCollectionItem)
 Private
  vBinaryRequest,
  vEncodeStrings,
  vCompression,
  vActive,
  vProxy                : Boolean;
  vTimeOut,
  vConnectTimeOut,
  vPoolerPort           : Integer;
  vPoolerList           : TStringList;
  vAuthOptionParams     : TRESTDWClientAuthOptionParams;
  vDataRoute,
  vListName,
  vAccessTag,
  vWelcomeMessage,
  vRestPooler,
  vRestWebService       : String;
  vProxyOptions         : TProxyOptions;
  vEncoding             : TEncodeSelect;
  {$IFDEF RESTDWLAZARUS}
  vDatabaseCharSet      : TDatabaseCharSet;
  {$ENDIF}
  vTypeRequest          : TTypeRequest;
  vClientConnectionDefs : TClientConnectionDefs;
  Function    GetPoolerList     : TStringList;
 Public
  Function    GetDisplayName             : String;      Override;
  Procedure   SetDisplayName(Const Value : String);     Override;
  Constructor Create        (aCollection : TCollection);Override;
  Destructor  Destroy;Override;//Destroy a Classe
  Property    PoolerList        : TStringList                 Read GetPoolerList;
 Published
  Property Active                : Boolean                    Read vActive               Write vActive;            //Seta o Estado da Conexão
  Property BinaryRequest         : Boolean                    Read vBinaryRequest        Write vBinaryRequest;
  Property Compression           : Boolean                    Read vCompression          Write vCompression;       //Compressão de Dados
  Property AuthenticationOptions : TRESTDWClientAuthOptionParams Read vAuthOptionParams     Write vAuthOptionParams;
  Property Proxy                 : Boolean                    Read vProxy                Write vProxy;             //Diz se tem servidor Proxy
  Property ProxyOptions          : TProxyOptions              Read vProxyOptions         Write vProxyOptions;      //Se tem Proxy diz quais as opções
  Property PoolerService         : String                     Read vRestWebService       Write vRestWebService;    //Host do WebService REST
  Property PoolerPort            : Integer                    Read vPoolerPort           Write vPoolerPort;        //A Porta do Pooler do DataSet
  Property PoolerName            : String                     Read vRestPooler           Write vRestPooler;        //Qual o Pooler de Conexão ligado ao componente
  Property RequestTimeOut        : Integer                    Read vTimeOut              Write vTimeOut;           //Timeout da Requisição
  Property ConnectTimeOut        : Integer                    Read vConnectTimeOut       Write vConnectTimeOut;
  Property EncodeStrings         : Boolean                    Read vEncodeStrings        Write vEncodeStrings;
  Property Encoding              : TEncodeSelect              Read vEncoding             Write vEncoding;          //Encoding da string
  Property WelcomeMessage        : String                     Read vWelcomeMessage       Write vWelcomeMessage;
  Property DataRoute             : String                     Read vDataRoute            Write vDataRoute;         //URL do WebService REST
  {$IFDEF RESTDWLAZARUS}
  Property DatabaseCharSet      : TDatabaseCharSet            Read vDatabaseCharSet      Write vDatabaseCharSet;
  {$ENDIF}
  Property Name                 : String                      Read vListName             Write vListName;
  Property AccessTag            : String                      Read vAccessTag            Write vAccessTag;
  Property TypeRequest          : TTypeRequest                Read vTypeRequest          Write vTypeRequest       Default trHttp;
  Property ClientConnectionDefs : TClientConnectionDefs       Read vClientConnectionDefs Write vClientConnectionDefs;
End;

Type
 TOnBuildConnection       = Procedure (DataBase: TRESTDWComponent) Of Object;
 TOnFailOverExecute       = Procedure (ConnectionServer   : TRESTDWConnectionServer) Of Object;
 TOnFailOverError         = Procedure (ConnectionServer   : TRESTDWConnectionServer;
                                       MessageError       : String)                  Of Object;

Type
 TListDefConnections = Class(TRESTDWOwnedCollection)
 Private
  fOwner      : TPersistent;
  Function    GetOwner: TPersistent; override;
  Function    GetRec     (Index       : Integer) : TRESTDWConnectionServer;  Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TRESTDWConnectionServer);            Overload;
  Function    GetRecName(Index        : String)  : TRESTDWConnectionServer;  Overload;
  Procedure   PutRecName(Index        : String;
                         Item         : TRESTDWConnectionServer);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create     (AOwner      : TPersistent;
                          aItemClass  : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    Add                     : TCollectionItem;
  Procedure   Delete     (Index       : Integer);  Overload;
  Procedure   Delete     (Index       : String);   Overload;
  Property    Items      [Index       : Integer] : TRESTDWConnectionServer Read GetRec     Write PutRec; Default;
  Property    ItemsByName[Index       : String ] : TRESTDWConnectionServer Read GetRecName Write PutRecName;
End;

Type
 TRESTDWDatabasebaseBase = Class(TRESTDWComponent)
 Private
  vOnBuildConnection    : TOnBuildConnection;
  vClientIpVersion      : TRESTDWClientIpVersions;
  vSSLVersions          : TRESTDWSSLVersions;
  vOnWorkBegin,
  vOnWork               : TOnWork;
  vOnWorkEnd            : TOnWorkEnd;
  vOnStatus             : TOnStatus;
  vOnFailOverExecute    : TOnFailOverExecute;
  vOnFailOverError      : TOnFailOverError;
  vOnBeforeGetToken     : TOnBeforeGetToken;
  vCripto               : TCripto;
  vRestPoolers          : TStringList;
  vAuthOptionParams     : TRESTDWClientAuthOptionParams;
  vCharset,
  vContentEncoding,
  vAccept,
  vAcceptEncoding,
  vContentType,
  vContentex,
  vUserAgent,
  vAccessTag,
  vWelcomeMessage,
  vDataRoute,                                        //URL do WebService REST
  vPoolerNotFoundMessage,
  vRestWebService,                                   //Rest WebService para consultas
  vMyIP,                                             //Meu IP vindo do Servidor
  vRestPooler           : String;                    //Qual o Pooler de Conexão do DataSet
  vRedirectMaximum,
  vPoolerPort           : Integer;                   //A Porta do Pooler
  vClientConnectionDefs : TClientConnectionDefs;
  vProxyOptions         : TProxyOptions;             //Se tem Proxy diz quais as opções
  vOnEventConnection    : TOnEventConnection;        //Evento de Estado da Conexão
  vOnBeforeConnection   : TOnEventBeforeConnection;  //Evento antes de Connectar o Database
  vAutoCheckData        : TAutoCheckData;            //Autocheck de Conexão
  vTimeOut              : Integer;
  vConnectTimeOut       : Integer;
  vEncoding             : TEncodeSelect;             //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vUseSSL,
  vHandleRedirects,
  vFailOver,
  vProxy,                                            //Diz se tem servidor Proxy
  vFailOverReplaceDefaults,
  vEncodeStrings,
  vCompression,                                      //Se Vai haver compressão de Dados
  vConnected,                                        //Diz o Estado da Conexão
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vIgnoreEchoPooler,
  vParamCreate          : Boolean;
  vTypeRequest          : Ttyperequest;
  vFailOverConnections  : TListDefConnections;
  vRESTClientPooler     : TRESTClientPoolerBase;
  Procedure SetIpVersion            (IpV: TRESTDWClientIpVersions);
  Procedure CopyParams              (ConnectionDB           : TRESTDWPoolerMethodClient;
                                     Var RESTClientPooler   : TRESTClientPoolerBase);
  Function  RenewToken              (Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                     Var Params             : TRESTDWParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String) : String;
  Procedure SetOnWork               (Value                  : TOnWork);
  Procedure SetOnWorkBegin          (Value                  : TOnWork);
  Procedure SetOnWorkEnd            (Value                  : TOnWorkEnd);
  Procedure SetOnStatus             (Value                  : TOnStatus);
  Procedure SetRestPooler           (Value                  : String);                             //Seta o Restpooler a ser utilizado
  Procedure SetPoolerPort           (Value                  : Integer);                            //Seta a Porta do Pooler a ser usada
  Function  TryConnect              (Connection             : TRESTDWPoolerMethodClient;
                                     aBinaryRequest         : Boolean = False) : Boolean;//Tenta Conectar o Servidor para saber se posso executar comandos
  Function  GetStateDB : Boolean;
  Procedure SetMyIp(Value : String);
  Procedure ReconfigureConnection   (Var Connection         : TRESTDWPoolerMethodClient;
                                     Var ConnectionExec     : TRESTClientPoolerBase;
                                     TypeRequest            : Ttyperequest;
                                     WelcomeMessage,
                                     Host                   : String;
                                     Port                   : Integer;
                                     Compression,
                                     EncodeStrings          : Boolean;
                                     Encoding               : TEncodeSelect;
                                     AccessTag              : String;
                                     AuthenticationOptions  : TRESTDWClientAuthOptionParams);
  Function  GetRestPoolers                                  : TStringList;          //Retorna a Lista de DataSet Sources do Pooler
  Procedure SetDataRoute            (Value                  : String);
  Function  BuildConnection         (aBinaryRequest         : Boolean) : TRESTDWPoolerMethodClient;
  Procedure SetConnectionProp       (Value                  : Boolean);
 Protected
  Procedure Loaded; override;
 Public
  Function  IsServerLive            (Aip                    : String;
                                     Aport                  : Integer;
                                     AMessageErro           : String): Boolean; Virtual;

  Procedure SetConnection           (Value                  : Boolean;
                                     aBinaryRequest         : Boolean = False);                    //Seta o Estado da Conexão
  Procedure DestroyClientPooler;
  Procedure ExecuteCommand          (Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                     Var SQL                : TStringList;
                                     Var Params             : TParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String;
                                     Var Result             : TJSONValue;
                                     Var RowsAffected       : Integer;
                                     Execute                : Boolean = False;
                                     BinaryRequest          : Boolean = False;
                                     BinaryCompatibleMode   : Boolean = False;
                                     Metadata               : Boolean = False;
                                     RESTClientPooler       : TRESTClientPoolerBase     = Nil);
  Procedure ExecuteCommandTB        (Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                     Tablename              : String;
                                     Var Params             : TParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String;
                                     Var Result             : TJSONValue;
                                     Var RowsAffected       : Integer;
                                     BinaryRequest          : Boolean = False;
                                     BinaryCompatibleMode   : Boolean = False;
                                     Metadata               : Boolean = False;
                                     RESTClientPooler       : TRESTClientPoolerBase     = Nil);
  Procedure ExecuteProcedure        (Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                     ProcName               : String;
                                     Params                 : TParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String);
  Function InsertMySQLReturnID      (Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                     Var SQL                : TStringList;
                                     Var Params             : TParams;
                                     Var Error              : Boolean;
                                     Var MessageError       : String;
                                     RESTClientPooler       : TRESTClientPoolerBase = Nil) : Integer;
  Procedure ApplyUpdates            (Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                     Massive                : TMassiveDatasetBuffer;
                                     SQL                    : TStringList;
                                     Var Params             : TParams;
                                     Var Error,
                                     hBinaryRequest         : Boolean;
                                     Var MessageError       : String;
                                     Var Result             : TJSONValue;
                                     Var RowsAffected       : Integer;
                                     RESTClientPooler       : TRESTClientPoolerBase = Nil);Overload;
  Procedure ApplyUpdatesTB          (Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                     Massive                : TMassiveDatasetBuffer;
                                     Var Params             : TParams;
                                     Var Error,
                                     hBinaryRequest         : Boolean;
                                     Var MessageError       : String;
                                     Var Result             : TJSONValue;
                                     Var RowsAffected       : Integer;
                                     RESTClientPooler       : TRESTClientPoolerBase = Nil);Overload;
  Function    GetServerEvents                               : TStringList;
  Constructor Create                (AOwner                 : TComponent);Override; //Cria o Componente
  Destructor  Destroy; Override;                      //Destroy a Classe
  Procedure   Close;
  Procedure   Open;
  Procedure   ApplyUpdates          (Var MassiveCache       : TRESTDWMassiveCache);Overload;
  Procedure   ApplyUpdates          (Var MassiveCache       : TRESTDWMassiveCache;
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String);Overload;
  Procedure   ApplyUpdates          (Datasets               : Array of {$IFDEF RESTDWLAZARUS}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String);Overload;
  Procedure   ProcessMassiveSQLCache(Var MassiveSQLCache    : TRESTDWMassiveSQLCache;
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String);Overload;
  Procedure   ProcessMassiveSQLCache(Var MassiveSQLCache    : TRESTDWMassiveCacheSQLList;
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String);Overload;
  Procedure   OpenDatasets          (Datasets               : Array of {$IFDEF RESTDWLAZARUS}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                     Var   Error            : Boolean;
                                     Var   MessageError     : String;
                                     BinaryRequest          : Boolean = True;
                                     BinaryCompatible       : Boolean = False);Overload;
  Function    GetTableNames         (Var   TableNames       : TStringList)  : Boolean;
  Function    GetFieldNames         (TableName              : String;
                                     Var FieldNames         : TStringList)  : Boolean;
  Function    GetKeyFieldNames      (TableName              : String;
                                     Var FieldNames         : TStringList)  : Boolean;
  Procedure   OpenDatasets          (Datasets               : Array of {$IFDEF RESTDWLAZARUS}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                     BinaryCompatible       : Boolean = False);Overload;
  Property    Connected            : Boolean                    Read GetStateDB               Write SetConnectionProp;
  Property    PoolerList           : TStringList                Read GetRestPoolers;
  Property    RESTClientPooler     : TRESTClientPoolerBase      Read vRESTClientPooler        Write vRESTClientPooler;
 Published
  Property Accept                  : String                     Read vAccept                  Write vAccept;
  Property AcceptEncoding          : String                     Read vAcceptEncoding          Write vAcceptEncoding;
  Property ContentType             : String                     Read vContentType             Write vContentType;
  Property Charset                 : String                     Read vCharset                 Write vCharset;
  Property ContentEncoding         : String                     Read vContentEncoding         Write vContentEncoding;
  Property OnConnection            : TOnEventConnection         Read vOnEventConnection       Write vOnEventConnection;  //Evento relativo a tudo que acontece quando tenta conectar ao Servidor
  Property OnBeforeConnect         : TOnEventBeforeConnection   Read vOnBeforeConnection      Write vOnBeforeConnection; //Evento antes de Connectar o Database
  Property Active                  : Boolean                    Read vConnected               Write SetConnectionProp;   //Seta o Estado da Conexão
  Property Compression             : Boolean                    Read vCompression             Write vCompression;        //Compressão de Dados
  Property CriptOptions            : TCripto                    Read vCripto                  Write vCripto;
  Property DataRoute               : String                     Read vDataRoute               Write SetDataRoute;
  Property MyIP                    : String                     Read vMyIP                    Write SetMyIp;
  Property IgnoreEchoPooler        : Boolean                    Read vIgnoreEchoPooler        Write vIgnoreEchoPooler;
  Property AuthenticationOptions   : TRESTDWClientAuthOptionParams Read vAuthOptionParams     Write vAuthOptionParams;
  Property Proxy                   : Boolean                    Read vProxy                   Write vProxy;             //Diz se tem servidor Proxy
  Property ProxyOptions            : TProxyOptions              Read vProxyOptions            Write vProxyOptions;      //Se tem Proxy diz quais as opções
  Property PoolerService           : String                     Read vRestWebService          Write vRestWebService;    //Host do WebService REST
  Property PoolerPort              : Integer                    Read vPoolerPort              Write SetPoolerPort;      //A Porta do Pooler do DataSet
  Property PoolerName              : String                     Read vRestPooler              Write SetRestPooler;      //Qual o Pooler de Conexão ligado ao componente
  Property StateConnection         : TAutoCheckData             Read vAutoCheckData           Write vAutoCheckData;     //Autocheck da Conexão
  Property RequestTimeOut          : Integer                    Read vTimeOut                 Write vTimeOut;           //Timeout da Requisição
  Property ConnectTimeOut          : Integer                    Read vConnectTimeOut          Write vConnectTimeOut;
  Property EncodedStrings          : Boolean                    Read vEncodeStrings           Write vEncodeStrings;
  Property Encoding                : TEncodeSelect              Read vEncoding                Write vEncoding;          //Encoding da string
  Property Context                 : String                     Read vContentex               Write vContentex;         //Contexto
  Property StrsTrim                : Boolean                    Read vStrsTrim                Write vStrsTrim;
  Property StrsEmpty2Null          : Boolean                    Read vStrsEmpty2Null          Write vStrsEmpty2Null;
  Property StrsTrim2Len            : Boolean                    Read vStrsTrim2Len            Write vStrsTrim2Len;
  Property PoolerNotFoundMessage   : String                     Read vPoolerNotFoundMessage   Write vPoolerNotFoundMessage;
  Property WelcomeMessage          : String                     Read vWelcomeMessage          Write vWelcomeMessage;
  Property HandleRedirects         : Boolean                    Read vHandleRedirects         Write vHandleRedirects;
  Property RedirectMaximum         : Integer                    Read vRedirectMaximum         Write vRedirectMaximum;
  Property OnWork                  : TOnWork                    Read vOnWork                  Write SetOnWork;
  Property OnWorkBegin             : TOnWork                    Read vOnWorkBegin             Write SetOnWorkBegin;
  Property OnWorkEnd               : TOnWorkEnd                 Read vOnWorkEnd               Write SetOnWorkEnd;
  Property OnStatus                : TOnStatus                  Read vOnStatus                Write SetOnStatus;
  Property OnFailOverExecute       : TOnFailOverExecute         Read vOnFailOverExecute       Write vOnFailOverExecute;
  Property OnFailOverError         : TOnFailOverError           Read vOnFailOverError         Write vOnFailOverError;
  Property OnBeforeGetToken        : TOnBeforeGetToken          Read vOnBeforeGetToken        Write vOnBeforeGetToken;
  Property AccessTag               : String                     Read vAccessTag               Write vAccessTag;
  Property ParamCreate             : Boolean                    Read vParamCreate             Write vParamCreate;
  Property TypeRequest             : TTypeRequest               Read vTypeRequest             Write vTypeRequest       Default trHttp;
  Property FailOver                : Boolean                    Read vFailOver                Write vFailOver;
  Property FailOverConnections     : TListDefConnections        Read vFailOverConnections     Write vFailOverConnections;
  Property FailOverReplaceDefaults : Boolean                    Read vFailOverReplaceDefaults Write vFailOverReplaceDefaults;
  Property ClientConnectionDefs    : TClientConnectionDefs      Read vClientConnectionDefs    Write vClientConnectionDefs;
  Property UseSSL                  : Boolean                    Read vUseSSL                  Write vUseSSL;
  Property SSLVersions             : TRESTDWSSLVersions         Read vSSLVersions             Write vSSLVersions;
  Property UserAgent               : String                     Read vUserAgent               Write vUserAgent;
  Property ClientIpVersion         : TRESTDWClientIpVersions    Read vClientIpVersion         Write SetIpVersion default civIPv4;
  Property OnBuildConnection       : TOnBuildConnection         Read vOnBuildConnection       Write vOnBuildConnection;
End;

Type
 TRESTDWUpdateSQL = Class(TRESTDWComponent) //Classe com as funcionalidades de um DBQuery
 Protected
  Procedure Notification(AComponent : TComponent;
                         Operation  : TOperation); override;
 Private
  vEncoding            : TEncodeSelect;
  vMassiveCacheSQLList : TRESTDWMassiveCacheSQLList;
  vClientSQLBase       : TRESTDWClientSQLBase;
  vSQLInsert,
  vSQLDelete,
  vSQLUpdate,
  vSQLLock,
  vSQLUnlock,
  vSQLRefresh          : TStringList;
  fsAbout              : TRESTDWAboutInfo;
  Function  GetVersionInfo      : String;
  Function  getClientSQLB       : TRESTDWClientSQLBase;
  Procedure setClientSQLB(Value : TRESTDWClientSQLBase);
  Procedure SetSQLDelete (Value : TStringList);
  Procedure SetSQLInsert (Value : TStringList);
  Procedure SetSQLLock   (Value : TStringList);
  Procedure SetSQLUnlock (Value : TStringList);
  Procedure SetSQLRefresh(Value : TStringList);
  Procedure SetSQLUpdate (Value : TStringList);
 Public
  Procedure Clear;
  Function  MassiveCount      : Integer;
  Function  ToJSON            : String;
  Procedure SetClientSQL(Value  : TRESTDWClientSQLBase);
  Procedure Store     (SQL                  : String;
                       Dataset              : TDataset;
                       DeleteCommand        : Boolean = False);
  Constructor Create  (AOwner : TComponent);Override;//Cria o Componente
  Destructor  Destroy;Override;                                                   //Destroy a Classe
  Property    VersionInfo : String Read GetVersionInfo;
 Published
  Property Dataset        : TRESTDWClientSQLBase Read getClientSQLB  Write setClientSQLB;
  Property Encoding       : TEncodeSelect        Read vEncoding      Write vEncoding;
  Property DeleteSQL      : TStringList          Read vSQLDelete     Write SetSQLDelete;
  Property InsertSQL      : TStringList          Read vSQLInsert     Write SetSQLInsert;
  Property LockSQL        : TStringList          Read vSQLLock       Write SetSQLLock;
  Property UnlockSQL      : TStringList          Read vSQLUnlock     Write SetSQLUnlock;
  Property FetchRowSQL    : TStringList          Read vSQLRefresh    Write SetSQLRefresh;
  Property ModifySQL      : TStringList          Read vSQLUpdate     Write SetSQLUpdate;
  Property AboutInfo      : TRESTDWAboutInfo     Read fsAbout        Write fsAbout Stored False;
End;

Type
 TRESTDWThreadRequest = Class(TThread)
 Protected
  Procedure ProcessMessages;
  Procedure Execute;Override;
 Private
  vSelf                             : TComponent;
  vOnExecuteData,
  vAbortData                        : TOnExecuteData;
  vOnThreadRequestError             : TOnThreadRequestError;
 Public
  Procedure   Kill;
  Destructor  Destroy; Override;
  Constructor Create(aSelf                : TComponent;
                     OnExecuteData,
                     AbortData            : TOnExecuteData;
                     OnThreadRequestError : TOnThreadRequestError);
End;

type
  IRESTDWPlus = interface
    procedure loadStream(stream : TStream);
    function findFieldName(name : string) : TField;
    function getDataset : TDataSet;
  end;

Type
 TRESTDWClientSQL = Class (TRESTDWClientSQLBase) //Classe com as funcionalidades de um DBQuery
 Private
  vActualPoolerMethodClient : TRESTDWPoolerMethodClient;
  vOldState             : TDatasetState;
  vOldCursor,
//  {$IFNDEF RESTDWAndroidService}
//  vActionCursor         : TCursor;
//  {$ENDIF}
  vDWResponseTranslator : TRESTDWResponseTranslator;
  vUpdateSQL            : TRESTDWUpdateSQL;
  vMasterDetailItem     : TMasterDetailItem;
  vFieldsList           : TFieldsList;
  vMassiveCache         : TRESTDWMassiveCache;
  vOldStatus            : TDatasetState;
  vDataSource           : TDataSource;
  vOnFiltered           : TOnFiltered;
  vOnAfterScroll        : TOnAfterScroll;
  vOnAfterOpen          : TOnAfterOpen;
  vOnBeforeClose        : TOnBeforeClose;
  vOnAfterClose         : TOnAfterClose;
  vOnBeforeRefresh      : TOnBeforeRefresh;
  vOnAfterRefresh       : TOnAfterRefresh;
  vOnCalcFields         : TDatasetEvents;
  vThreadRequest        : TRESTDWThreadRequest;
  vNewRecord,
  vBeforeOpen,
  vOnBeforeScroll,
  vBeforeEdit,
  vBeforeInsert,
  vBeforePost,
  vBeforeDelete,
  vAfterDelete,
  vAfterEdit,
  vAfterInsert,
  vAfterPost,
  vAfterCancel          : TDatasetEvents;
  vMassiveMode          : TMassiveType;
  vRowsAffected,
  vOldRecordCount,
  vDatapacks,
  vJsonCount,
  vActualRec            : Integer;
  vActualJSON,
  vOldSQL,
  vMasterFields,
  vUpdateTableName      : String;                            //Tabela que será feito Update no Servidor se for usada Reflexão de Dados
  vInitDataset,
  vInternalLast,
  vFiltered,
  vActiveCursor,
  vOnOpenCursor,
  vCacheUpdateRecords,
  vReadData,
  vOnPacks,
  vCascadeDelete,
  vBeforeClone,
  vDataCache,                                               //Se usa cache local
  vConnectedOnce,                                           //Verifica se foi conectado ao Servidor
  vCommitUpdates,
  vCreateDS,
  GetNewData,
  vErrorBefore,
  vNotRepage,
  vBinaryRequest,
  vRaiseError,
  vReflectChanges,
  vInDesignEvents,
  vAutoCommitData,
  vAutoRefreshAfterCommit,
  vPropThreadRequest,
  vInRefreshData,
  vInBlockEvents        : Boolean;
  vRelationFields,
  vSQL                  : TStringList;                       //SQL a ser utilizado na conexão
  vParams               : TParams;                           //Parametros de Dataset
  vCacheDataDB          : TDataset;                          //O Cache de Dados Salvo para utilização rápida
  vOnGetDataError       : TOnEventConnection;                //Se deu erro na hora de receber os dados ou não
  vOnThreadRequestError : TOnThreadRequestError;
  vRESTDataBase         : TRESTDWDatabasebaseBase;                   //RESTDataBase do Dataset
  FieldDefsUPD          : TFieldDefs;
  vMasterDataSet        : TRESTDWClientSQL;
  vMasterDetailList     : TMasterDetailList;                 //DataSet MasterDetail Function
  vMassiveDataset       : TMassiveDataset;
  vLastOpen             : Integer;
  Procedure CloneDefinitions     (Source  : TRESTDWMemtable;
                                  aSelf   : TRESTDWMemtable); //Fields em Definições
  Procedure   OnChangingSQL      (Sender  : TObject);       //Quando Altera o SQL da Lista
  Procedure   OnBeforeChangingSQL(Sender  : TObject);
  Procedure   SetActiveDB        (Value   : Boolean);       //Seta o Estado do Dataset
  Procedure   SetSQL             (Value     : TStringList);   //Seta o SQL a ser usado
  Procedure   CreateParams;                                 //Cria os Parametros na lista de Dataset
  Procedure   SetDataBase        (Value     : TRESTDWDatabasebaseBase); //Diz o REST Database
  Procedure   ExecuteOpen;
  Function    GetData            (DataSet   : TJSONValue = Nil) : Boolean;//Recebe os Dados da Internet vindo do Servidor REST
  Procedure   SetUpdateTableName (Value     : String);        //Diz qual a tabela que será feito Update no Banco
  Procedure   OldAfterPost       (DataSet   : TDataSet);      //Eventos do Dataset para realizar o AfterPost
  Procedure   OldAfterDelete     (DataSet   : TDataSet);      //Eventos do Dataset para realizar o AfterDelete
  Procedure   SetMasterDataSet   (Value     : TRESTDWClientSQL);
  Procedure   SetUpdateSQL       (Value     : TRESTDWUpdateSQL);
  Function    GetUpdateSQL                  : TRESTDWUpdateSQL;
  Procedure   SetCacheUpdateRecords(Value   : Boolean);
  Function    FirstWord          (Value     : String) : String;
  Procedure   ProcBeforeScroll   (DataSet   : TDataSet);
  Procedure   ProcAfterScroll    (DataSet   : TDataSet);
  Procedure   ProcBeforeOpen     (DataSet   : TDataSet);
  Procedure   ProcAfterOpen      (DataSet   : TDataSet);
  Procedure   ProcBeforeClose    (DataSet   : TDataSet);
  Procedure   ProcAfterClose     (DataSet   : TDataSet);
  Procedure   ProcBeforeRefresh  (DataSet   : TDataSet);
  Procedure   ProcAfterRefresh   (DataSet   : TDataSet);
  Procedure   ProcBeforeInsert   (DataSet   : TDataSet);
  Procedure   ProcAfterInsert    (DataSet   : TDataSet);
  Procedure   ProcNewRecord      (DataSet   : TDataSet);
  Procedure   ProcBeforeDelete   (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcBeforeEdit     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterEdit      (DataSet   : TDataSet);
  Procedure   ProcBeforePost     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterCancel    (DataSet   : TDataSet);
  Procedure   ProcCalcFields     (DataSet   : TDataSet);
  Procedure   ProcBeforeExec     (DataSet   : TDataSet);
  procedure   CreateMassiveDataset;
  procedure   SetParams(const Value: TParams);
  Procedure   CleanFieldList;
//  Procedure   GetTmpCursor;
//  Procedure   SetCursor;
//  Procedure   SetOldCursor;
//  Procedure   ChangeCursor(OldCursor : Boolean = False);
  Procedure   SetDatapacks(Value : Integer);
  Procedure   SetReflectChanges(Value       : Boolean);
  Procedure   SetAutoRefreshAfterCommit(Value : Boolean);
  Function    ProcessChanges   (MassiveJSON : String): Boolean;
  function    GetMassiveCache: TRESTDWMassiveCache;
  procedure   SetMassiveCache(const Value: TRESTDWMassiveCache);
  Function    GetDWResponseTranslator: TRESTDWResponseTranslator;
  Procedure   SetDWResponseTranslator(const Value: TRESTDWResponseTranslator);
  Function    GetReadData                   : Boolean;
  Property    MasterFields                  : String   Read vMasterFields  Write vMasterFields;
  Procedure   InternalClose;override;
 Protected
  vBookmark : Integer;
  vActive,
  vInactive : Boolean;
  Procedure   InternalPost; override; // Gilberto Rocha 12/04/2019 - usado para poder fazer datasource.dataset.Post
  procedure   InternalOpen; override; // Gilberto Rocha 03/09/2021 - usado para poder fazer datasource.dataset.Open
  Function    GetRecordCount : Integer; Override;
  procedure   InternalRefresh; override; // Gilberto Rocha 03/09/2021 - usado para poder fazer datasource.dataset.Refresh
  procedure   CloseCursor; override; // Gilberto Rocha 03/09/2021 - usado para poder fazer datasource.dataset.Close
  Procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
  Procedure   ThreadStart(ExecuteData : TOnExecuteData);
  Procedure   ThreadDestroy;
  Procedure   AbortData;
 Public
  //Métodos
  Procedure   SetInactive      (Const Value            : Boolean);
  Procedure   Post; Override;
  Function    OpenJson         (JsonValue              : String = '';
                                Const ElementRoot      : String = '';
                                Const Utf8SpecialChars : Boolean = False) : Boolean;
  Procedure   SetInBlockEvents (Const Value            : Boolean);Override;
  Procedure   SetInitDataset   (Const Value            : Boolean);Override;
  Procedure   SetInDesignEvents(Const Value            : Boolean);Overload;
  Function    GetInBlockEvents  : Boolean;
  Function    GetInDesignEvents : Boolean;
  Procedure   NewFieldList;
  Function    GetFieldListByName(aName : String) : TFieldDefinition;
  Procedure   NewDataField(Value : TFieldDefinition);
  Function    FieldListCount    : Integer;
  Procedure   Newtable;
  Procedure   PrepareDetailsNew; Override;
  Procedure   PrepareDetails     (ActiveMode : Boolean);Override;
  Procedure   FieldDefsToFields;
  Procedure   RebuildMassiveDataset;
  Class Function FieldDefExist   (Const Dataset : TDataset;
                                  Value   : String) : TFieldDef;
  Function    FieldExist         (Value   : String) : TField;
  Procedure   Open; Overload; //Virtual;                     //Método Open que será utilizado no Componente
  Procedure   Open               (strSQL  : String);Overload; Virtual;//Método Open que será utilizado no Componente
  Procedure   ExecOrOpen;                                        //Método Open que será utilizado no Componente
  Procedure   Close; Virtual;                                    //Método Close que será utilizado no Componente
  Procedure   CreateDataSet;
  Class Procedure CreateEmptyDataset(Const Dataset : TDataset);
  Procedure   CreateDatasetFromList;
  Procedure   ExecSQL;Overload;                                        //Método ExecSQL que será utilizado no Componente
  Function    ExecSQL          (Var Error : String) : Boolean;Overload;//Método ExecSQL que será utilizado no Componente
  Function    InsertMySQLReturnID : Integer;                     //Método de ExecSQL com retorno de Incremento
  Function    ParamByName          (Value : String) : TParam;    //Retorna o Parametro de Acordo com seu nome
  Procedure   ApplyUpdates;Overload; Virtual;
  Function    ApplyUpdates     (Var Error : String; ReleaseCache : Boolean = True) : Boolean;Overload;//Aplica Alterações no Banco de Dados
  Constructor Create              (AOwner : TComponent);Override;//Cria o Componente
  Destructor  Destroy;Override;                                  //Destroy a Classe
  Procedure   Loaded; Override;
  procedure   OpenCursor       (InfoQuery : Boolean); Override;  //Subscrevendo o OpenCursor para não ter erros de ADD Fields em Tempo de Design
  Procedure   GotoRec       (Const aRecNo : Integer);
  Function    ParamCount            : Integer;
  Procedure   DynamicFilter(cFields : Array of String;
                            Value   : String;
                            InText  : Boolean;
                            AndOrOR : String);
  Procedure   Refresh;
  Procedure   SaveToStream    (Var Stream : TMemoryStream);
  Procedure   LoadFromStream      (Stream : TMemoryStream);
  Procedure   ClearMassive;
  Function    MassiveCount  : Integer;
  Function    MassiveToJSON : String; //Transporte de MASSIVE em formato JSON
  Procedure   DWParams        (Var Value  : TRESTDWParams);
  Procedure   RestoreDatasetPosition;
  Procedure   SetFilteredB(aValue  : Boolean);
  Procedure   InternalLast;Override;
  Procedure   Setnotrepage (Value : Boolean);
  Procedure   SetRecordCount(aJsonCount, aRecordCount : Integer);
  Property    RowsAffected         : Integer               Read vRowsAffected;
  Property    ServerFieldList      : TFieldsList           Read vFieldsList;
  Property    Inactive             : Boolean               Read vInactive                 Write vInactive;
  Property    LastOpen             : Integer               Read vLastOpen                 Write vLastOpen;
  Property    FieldDefs;
  Property    ReadData             : Boolean               Read GetReadData;
  Property    MasterDetailList     : TMasterDetailList     Read vMasterDetailList         Write vMasterDetailList;
 Published
  Property MasterDataSet           : TRESTDWClientSQL      Read vMasterDataSet            Write SetMasterDataSet;
  {$IFDEF RESTDWLAZARUS}
  Property DatabaseCharSet;
  {$ENDIF}
//  Property BinaryCompatibleMode;
  Property MasterCascadeDelete     : Boolean               Read vCascadeDelete            Write vCascadeDelete;
  Property BinaryRequest           : Boolean               Read vBinaryRequest            Write vBinaryRequest;
  Property Datapacks               : Integer               Read vDatapacks                Write SetDatapacks;
  Property OnGetDataError          : TOnEventConnection    Read vOnGetDataError           Write vOnGetDataError;         //Recebe os Erros de ExecSQL ou de GetData
  Property AfterScroll             : TOnAfterScroll        Read vOnAfterScroll            Write vOnAfterScroll;
  Property AfterOpen               : TOnAfterOpen          Read vOnAfterOpen              Write vOnAfterOpen;
  Property BeforeClose             : TOnBeforeClose        Read vOnBeforeClose            Write vOnBeforeClose;
  Property AfterClose              : TOnAfterClose         Read vOnAfterClose             Write vOnAfterClose;
  Property BeforeRefresh           : TOnBeforeRefresh      Read vOnBeforeRefresh          Write vOnBeforeRefresh;
  Property AfterRefresh            : TOnAfterRefresh       Read vOnAfterRefresh           Write vOnAfterRefresh;
  Property OnFiltered              : TOnFiltered           Read vOnFiltered               Write vOnFiltered;
  Property Active                  : Boolean               Read vActive                   Write SetActiveDB;             //Estado do Dataset
  Property DataCache               : Boolean               Read vDataCache                Write vDataCache;              //Diz se será salvo o último Stream do Dataset
  Property MassiveType             : TMassiveType          Read vMassiveMode              Write vMassiveMode;
  Property Params                  : TParams               Read vParams                   Write SetParams;                 //Parametros de Dataset
  Property DataBase                : TRESTDWDatabasebaseBase   Read vRESTDataBase             Write SetDataBase;             //Database REST do Dataset
  Property ResponseTranslator      : TRESTDWResponseTranslator Read GetDWResponseTranslator   Write SetDWResponseTranslator;
  Property SQL                     : TStringList           Read vSQL                      Write SetSQL;                  //SQL a ser Executado
  Property RelationFields          : TStringList           Read vRelationFields           Write vRelationFields;
  Property UpdateTableName         : String                Read vUpdateTableName          Write SetUpdateTableName;      //Tabela que será usada para Reflexão de Dados
  Property CacheUpdateRecords      : Boolean               Read vCacheUpdateRecords       Write SetCacheUpdateRecords;
  Property AutoCommitData          : Boolean               Read vAutoCommitData           Write vAutoCommitData;
  Property AutoRefreshAfterCommit  : Boolean               Read vAutoRefreshAfterCommit   Write SetAutoRefreshAfterCommit;
  Property ThreadRequest           : Boolean               Read vPropThreadRequest        Write vPropThreadRequest;
  Property RaiseErrors             : Boolean               Read vRaiseError               Write vRaiseError;
  Property BeforeOpen              : TDatasetEvents        Read vBeforeOpen               Write vBeforeOpen;
  Property BeforeEdit              : TDatasetEvents        Read vBeforeEdit               Write vBeforeEdit;
  Property BeforeScroll            : TDatasetEvents        Read vOnBeforeScroll           Write vOnBeforeScroll;
  Property BeforeInsert            : TDatasetEvents        Read vBeforeInsert             Write vBeforeInsert;
  Property BeforePost              : TDatasetEvents        Read vBeforePost               Write vBeforePost;
  Property BeforeDelete            : TDatasetEvents        Read vBeforeDelete             Write vBeforeDelete;
  Property AfterDelete             : TDatasetEvents        Read vAfterDelete              Write vAfterDelete;
  Property AfterEdit               : TDatasetEvents        Read vAfterEdit                Write vAfterEdit;
  Property AfterInsert             : TDatasetEvents        Read vAfterInsert              Write vAfterInsert;
  Property AfterPost               : TDatasetEvents        Read vAfterPost                Write vAfterPost;
  Property AfterCancel             : TDatasetEvents        Read vAfterCancel              Write vAfterCancel;
  Property OnThreadRequestError    : TOnThreadRequestError Read vOnThreadRequestError     Write vOnThreadRequestError;
  Property UpdateSQL               : TRESTDWUpdateSQL      Read GetUpdateSQL              Write SetUpdateSQL;
  Property OnCalcFields            : TDatasetEvents        Read vOnCalcFields             Write vOnCalcFields;
  Property OnNewRecord             : TDatasetEvents        Read vNewRecord                Write vNewRecord;
  Property MassiveCache            : TRESTDWMassiveCache   Read GetMassiveCache           Write SetMassiveCache;
  Property Filtered                : Boolean               Read vFiltered                 Write SetFilteredB;
//  Property ActionCursor            : TCursor               Read vActionCursor             Write vActionCursor;
  Property ReflectChanges          : Boolean               Read vReflectChanges           Write SetReflectChanges;
End;


Type
 TRESTDWTable  = Class(TRESTDWClientSQLBase) //Classe com as funcionalidades de um DBTable
 Private
  vActualPoolerMethodClient : TRESTDWPoolerMethodClient;
  vOldState             : TDatasetState;
//  vOldCursor,
//  vActionCursor         : TCursor;
  vDWResponseTranslator : TRESTDWResponseTranslator;
  vUpdateSQL            : TRESTDWUpdateSQL;
  vMasterDetailItem     : TMasterDetailItem;
  vFieldsList           : TFieldsList;
  vMassiveCache         : TRESTDWMassiveCache;
  vOldStatus            : TDatasetState;
  vDataSource           : TDataSource;
  vOnFiltered           : TOnFiltered;
  vOnAfterScroll        : TOnAfterScroll;
  vOnAfterOpen          : TOnAfterOpen;
  vOnBeforeClose        : TOnBeforeClose;
  vOnAfterClose         : TOnAfterClose;
  vOnBeforeRefresh      : TOnBeforeRefresh;
  vOnAfterRefresh       : TOnAfterRefresh;
  vOnCalcFields         : TDatasetEvents;
  vMassiveMode          : TMassiveType;
  vNewRecord,
  vBeforeOpen,
  vOnBeforeScroll,
  vBeforeEdit,
  vBeforeInsert,
  vBeforePost,
  vBeforeDelete,
  vAfterDelete,
  vAfterEdit,
  vAfterInsert,
  vAfterPost,
  vAfterCancel          : TDatasetEvents;
  vRowsAffected,
  vOldRecordCount,
  vDatapacks,
  vJsonCount,
  vActualRec            : Integer;
  vActualJSON,
  vMasterFields,
  vTableName            : String;                            //Tabela que será feito Update no Servidor se for usada Reflexão de Dados
  vInitDataset,
  vInternalLast,
  vFiltered,
  vActiveCursor,
  vOnOpenCursor,
  vCacheUpdateRecords,
  vReadData,
  vOnPacks,
  vCascadeDelete,
  vBeforeClone,
  vDataCache,                                               //Se usa cache local
  vConnectedOnce,                                           //Verifica se foi conectado ao Servidor
  vCommitUpdates,
  vCreateDS,
  GetNewData,
  vErrorBefore,
  vNotRepage,
  vBinaryRequest,
  vRaiseError,
  vInDesignEvents,
  vAutoCommitData,
  vAutoRefreshAfterCommit,
  vInRefreshData,
  vInBlockEvents        : Boolean;
  vRelationFields       : TStringList;                       //SQL a ser utilizado na conexão
  vParams               : TParams;                           //Parametros de Dataset
  vCacheDataDB          : TDataset;                          //O Cache de Dados Salvo para utilização rápida
  vOnGetDataError       : TOnEventConnection;                //Se deu erro na hora de receber os dados ou não
  vRESTDataBase         : TRESTDWDatabasebaseBase;                   //RESTDataBase do Dataset
  FieldDefsUPD          : TFieldDefs;
  vMasterDataSet        : TRESTDWClientSQLBase;
  vMasterDetailList     : TMasterDetailList;                 //DataSet MasterDetail Function
  vMassiveDataset       : TMassiveDataset;
  vLastOpen             : Integer;
  Procedure   SetActiveDB        (Value     : Boolean);       //Seta o Estado do Dataset
  Procedure   SetDataBase        (Value     : TRESTDWDatabasebaseBase); //Diz o REST Database
  Function    GetData            (DataSet   : TJSONValue = Nil) : Boolean;//Recebe os Dados da Internet vindo do Servidor REST
  Procedure   OldAfterPost       (DataSet   : TDataSet);      //Eventos do Dataset para realizar o AfterPost
  Procedure   OldAfterDelete     (DataSet   : TDataSet);      //Eventos do Dataset para realizar o AfterDelete
  Procedure   SetMasterDataSet   (Value     : TRESTDWClientSQLBase);
  Procedure   SetUpdateSQL       (Value     : TRESTDWUpdateSQL);
  Function    GetUpdateSQL                  : TRESTDWUpdateSQL;
  Procedure   SetCacheUpdateRecords(Value   : Boolean);
  Function    FirstWord          (Value     : String) : String;
  Procedure   ProcBeforeScroll   (DataSet   : TDataSet);
  Procedure   ProcAfterScroll    (DataSet   : TDataSet);
  Procedure   ProcBeforeOpen     (DataSet   : TDataSet);
  Procedure   ProcAfterOpen      (DataSet   : TDataSet);
  Procedure   ProcBeforeClose    (DataSet   : TDataSet);
  Procedure   ProcAfterClose     (DataSet   : TDataSet);
  Procedure   ProcBeforeRefresh  (DataSet   : TDataSet);
  Procedure   ProcAfterRefresh   (DataSet   : TDataSet);
  Procedure   ProcBeforeInsert   (DataSet   : TDataSet);
  Procedure   ProcAfterInsert    (DataSet   : TDataSet);
  Procedure   ProcNewRecord      (DataSet   : TDataSet);
  Procedure   ProcBeforeDelete   (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcBeforeEdit     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterEdit      (DataSet   : TDataSet);
  Procedure   ProcBeforePost     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterCancel    (DataSet   : TDataSet);
  Procedure   ProcCalcFields     (DataSet: TDataSet);
  procedure   CreateMassiveDataset;
  procedure   SetParams(const Value: TParams);
  Procedure   CleanFieldList;
//  Procedure   GetTmpCursor;
//  Procedure   SetCursor;
//  Procedure   SetOldCursor;
//  Procedure   ChangeCursor(OldCursor : Boolean = False);
  Procedure   SetDatapacks(Value : Integer);
  Procedure   SetAutoRefreshAfterCommit(Value : Boolean);
  Function    ProcessChanges   (MassiveJSON : String): Boolean;
  Function    GetMassiveCache: TRESTDWMassiveCache;
  Procedure   SetMassiveCache(const Value: TRESTDWMassiveCache);
  Function    GetDWResponseTranslator: TRESTDWResponseTranslator;
  Procedure   SetDWResponseTranslator(const Value: TRESTDWResponseTranslator);
  Property    MasterFields                  : String   Read vMasterFields  Write vMasterFields;
//  Procedure   InternalDeferredPost;override; // Gilberto Rocha 12/04/2019 - usado para poder fazer datasource.dataset.Post
  Procedure   SetTablename(Value : String);
 Protected
  vBookmark : Integer;
  vActive,
  vInactive : Boolean;
  Procedure   InternalPost; override; // Gilberto Rocha 12/04/2019 - usado para poder fazer datasource.dataset.Post
  procedure   InternalOpen; override; // Gilberto Rocha 07/09/2020 - usado para poder fazer datasource.dataset.Open
  Function  GetRecordCount : Integer; Override;
  procedure InternalRefresh; override; // Gilberto Rocha 07/09/2020 - usado para poder fazer datasource.dataset.Refresh
  procedure CloseCursor; override; // Gilberto Rocha 07/09/2020 - usado para poder fazer datasource.dataset.Close
  Procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  //Métodos
  Procedure   Post; Override;
  Function    OpenJson         (JsonValue              : String = '';
                                Const ElementRoot      : String = '';
                                Const Utf8SpecialChars : Boolean = False) : Boolean;
  Procedure   SetInBlockEvents (Const Value            : Boolean);Override;
  Procedure   SetInitDataset   (Const Value            : Boolean);Override;
  Procedure   SetInDesignEvents(Const Value            : Boolean);Overload;
  Function    GetInBlockEvents  : Boolean;
  Function    GetInDesignEvents : Boolean;
  Procedure   NewFieldList;
  Function    GetFieldListByName(aName : String) : TFieldDefinition;
  Procedure   NewDataField(Value : TFieldDefinition);
  Function    FieldListCount    : Integer;
  Procedure   Newtable;
  Procedure   PrepareDetailsNew; Override;
  Procedure   PrepareDetails     (ActiveMode : Boolean);Override;
  Procedure   FieldDefsToFields;
  Procedure   RebuildMassiveDataset;
  Class Function FieldDefExist   (Const Dataset : TDataset;
                                  Value   : String) : TFieldDef;
  Function    FieldExist         (Value   : String) : TField;
  Procedure   Open; Overload; //Virtual;                     //Método Open que será utilizado no Componente
  Procedure   Close; Virtual;                                    //Método Close que será utilizado no Componente
  Procedure   CreateDataSet;
  Class Procedure CreateEmptyDataset(Const Dataset : TDataset);
  Procedure   CreateDatasetFromList;
  Function    ParamByName          (Value : String) : TParam;    //Retorna o Parametro de Acordo com seu nome
  Procedure   ApplyUpdates;Overload;
  Function    ApplyUpdates     (Var Error : String; ReleaseCache : Boolean = True) : Boolean;Overload;//Aplica Alterações no Banco de Dados
  Constructor Create              (AOwner : TComponent);Override;//Cria o Componente
  Destructor  Destroy;Override;                                  //Destroy a Classe
  Procedure   Loaded; Override;
  procedure   OpenCursor       (InfoQuery : Boolean); Override;  //Subscrevendo o OpenCursor para não ter erros de ADD Fields em Tempo de Design
  Procedure   GotoRec       (Const aRecNo : Integer);
  Function    ParamCount            : Integer;
  Procedure   DynamicFilter(cFields : Array of String;
                            Value   : String;
                            InText  : Boolean;
                            AndOrOR : String);
  Procedure   Refresh;
  Procedure   SaveToStream    (Var Stream : TMemoryStream);
  Procedure   LoadFromStream      (Stream : TMemoryStream);
  Procedure   ClearMassive;
  Function    MassiveCount  : Integer;
  Function    MassiveToJSON : String; //Transporte de MASSIVE em formato JSON
  Procedure   DWParams        (Var Value  : TRESTDWParams);
  Procedure   RestoreDatasetPosition;
  Procedure   SetFilteredB(aValue  : Boolean);
  Procedure   InternalLast;Override;
  Procedure   Setnotrepage (Value : Boolean);
  Procedure   SetRecordCount(aJsonCount, aRecordCount : Integer);
  Property    RowsAffected         : Integer               Read vRowsAffected;
  Property    ServerFieldList      : TFieldsList           Read vFieldsList;
  Property    Inactive             : Boolean               Read vInactive                 Write vInactive;
  Property    LastOpen             : Integer               Read vLastOpen                 Write vLastOpen;
  Property    FieldDefs;
 Published
  Property MasterDataSet           : TRESTDWClientSQLBase  Read vMasterDataSet            Write SetMasterDataSet;
  {$IFDEF RESTDWLAZARUS}
  Property DatabaseCharSet;
  {$ENDIF}
//  Property BinaryCompatibleMode;
  Property MasterCascadeDelete     : Boolean               Read vCascadeDelete            Write vCascadeDelete;
  Property BinaryRequest           : Boolean               Read vBinaryRequest            Write vBinaryRequest;
  Property Datapacks               : Integer               Read vDatapacks                Write SetDatapacks;
  Property OnGetDataError          : TOnEventConnection    Read vOnGetDataError           Write vOnGetDataError;         //Recebe os Erros de ExecSQL ou de GetData
  Property AfterScroll             : TOnAfterScroll        Read vOnAfterScroll            Write vOnAfterScroll;
  Property AfterOpen               : TOnAfterOpen          Read vOnAfterOpen              Write vOnAfterOpen;
  Property BeforeClose             : TOnBeforeClose        Read vOnBeforeClose            Write vOnBeforeClose;
  Property AfterClose              : TOnAfterClose         Read vOnAfterClose             Write vOnAfterClose;
  Property BeforeRefresh           : TOnBeforeRefresh      Read vOnBeforeRefresh          Write vOnBeforeRefresh;
  Property AfterRefresh            : TOnAfterRefresh       Read vOnAfterRefresh           Write vOnAfterRefresh;
  Property OnFiltered              : TOnFiltered           Read vOnFiltered               Write vOnFiltered;
  Property Active                  : Boolean               Read vActive                   Write SetActiveDB;             //Estado do Dataset
  Property DataCache               : Boolean               Read vDataCache                Write vDataCache;              //Diz se será salvo o último Stream do Dataset
  Property MassiveType             : TMassiveType          Read vMassiveMode              Write vMassiveMode;
  Property Params                  : TParams               Read vParams                   Write SetParams;                 //Parametros de Dataset
  Property DataBase                : TRESTDWDatabasebaseBase       Read vRESTDataBase             Write SetDataBase;             //Database REST do Dataset
  Property RelationFields          : TStringList           Read vRelationFields           Write vRelationFields;
  Property TableName               : String                Read vTableName                Write SetTableName;      //Tabela que será usada para Reflexão de Dados
  Property CacheUpdateRecords      : Boolean               Read vCacheUpdateRecords       Write SetCacheUpdateRecords;
  Property AutoCommitData          : Boolean               Read vAutoCommitData           Write vAutoCommitData;
  Property AutoRefreshAfterCommit  : Boolean               Read vAutoRefreshAfterCommit   Write SetAutoRefreshAfterCommit;
  Property RaiseErrors             : Boolean               Read vRaiseError               Write vRaiseError;
  Property BeforeOpen              : TDatasetEvents        Read vBeforeOpen               Write vBeforeOpen;
  Property BeforeEdit              : TDatasetEvents        Read vBeforeEdit               Write vBeforeEdit;
  Property BeforeScroll            : TDatasetEvents        Read vOnBeforeScroll           Write vOnBeforeScroll;
  Property BeforeInsert            : TDatasetEvents        Read vBeforeInsert             Write vBeforeInsert;
  Property BeforePost              : TDatasetEvents        Read vBeforePost               Write vBeforePost;
  Property BeforeDelete            : TDatasetEvents        Read vBeforeDelete             Write vBeforeDelete;
  Property AfterDelete             : TDatasetEvents        Read vAfterDelete              Write vAfterDelete;
  Property AfterEdit               : TDatasetEvents        Read vAfterEdit                Write vAfterEdit;
  Property AfterInsert             : TDatasetEvents        Read vAfterInsert              Write vAfterInsert;
  Property AfterPost               : TDatasetEvents        Read vAfterPost                Write vAfterPost;
  Property AfterCancel             : TDatasetEvents        Read vAfterCancel              Write vAfterCancel;
  Property UpdateSQL               : TRESTDWUpdateSQL      Read GetUpdateSQL              Write SetUpdateSQL;
  Property OnCalcFields            : TDatasetEvents        Read vOnCalcFields             Write vOnCalcFields;
  Property OnNewRecord             : TDatasetEvents        Read vNewRecord                Write vNewRecord;
  Property MassiveCache            : TRESTDWMassiveCache       Read GetMassiveCache           Write SetMassiveCache;
  Property Filtered                : Boolean               Read vFiltered                 Write SetFilteredB;
  Property ResponseTranslator      : TRESTDWResponseTranslator Read GetDWResponseTranslator   Write SetDWResponseTranslator;
//  Property ActionCursor            : TCursor               Read vActionCursor             Write vActionCursor;
End;


Type
 TDWFieldKind          = (dwfk_Keyfield, dwfk_Autoinc, dwfk_NotNull);
 TDWFieldType          = Set of TDWFieldKind;
 TRESTDWBatchFieldItem = Class(TCollectionItem)
 Private
  vListName,
  vSourceField,
  vDestField,
  vDefaultValue    : String;
  vFieldConfig     : TDWFieldType;
  vOnFieldGetValue : TOnFieldGetValue;
 Public
  Function    GetDisplayName             : String;      Override;
  Procedure   SetDisplayName(Const Value : String);     Override;
  Constructor Create        (aCollection : TCollection);Override;
  Destructor  Destroy;Override;//Destroy a Classe
 Published
  Property    SourceField     : String           Read vSourceField     Write vSourceField;
  Property    DestField       : String           Read vDestField       Write vDestField;
  Property    DefaultValue    : String           Read vDefaultValue    Write vDefaultValue;
  Property    FieldConfig     : TDWFieldType     Read vFieldConfig     Write vFieldConfig;
  Property    FieldRuleName   : String           Read vListName        Write vListName;
  Property    OnFieldGetValue : TOnFieldGetValue Read vOnFieldGetValue Write vOnFieldGetValue;
End;

Type
 TRESTDWBatchFieldsDefs = Class(TRESTDWOwnedCollection)
 Private
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec     (Index       : Integer) : TRESTDWBatchFieldItem;  Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TRESTDWBatchFieldItem);            Overload;
  Function    GetRecName(Index        : String)  : TRESTDWBatchFieldItem;  Overload;
  Procedure   PutRecName(Index        : String;
                         Item         : TRESTDWBatchFieldItem);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create     (AOwner      : TPersistent;
                          aItemClass  : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    Add                     : TCollectionItem;
  Procedure   Delete     (Index       : Integer);  Overload;
  Procedure   Delete     (Index       : String);   Overload;
  Property    Items      [Index       : Integer] : TRESTDWBatchFieldItem Read GetRec     Write PutRec; Default;
  Property    ItemsByName[Index       : String ] : TRESTDWBatchFieldItem Read GetRecName Write PutRecName;
End;

Type
 TRESTDWBatchMoveActionType = (bmat_Insert, bmat_Update,
                               bmat_Delete, bmat_InsertUpdate);
 TRESTDWProcessSide         = (psClient, psServer);
 TOnLineProcess             = Procedure (Source   : TRESTDWClientSQL;
                                         Var Dest : TRESTDWClientSQL) Of Object;
 TOnProcessError            = Procedure (Connection : TRESTDWConnectionServer;
                                         ActualReg,
                                         RegsCount  : Integer;
                                         Action     : TRESTDWBatchMoveActionType;
                                         Error      : String)  Of Object;
 TOnProcess                 = Procedure (RegsCount  : Integer) Of Object;
 TOnActProcess              = Procedure (ActualReg,
                                         RegsCount  : Integer) Of Object;
 TRESTDWBatchMove = Class(TRESTDWComponent)
 Private
  vOnLineProcess         : TOnLineProcess;
  vSourceSQLCommand,
  vDestSQLCommand        : String;
  vCommitOnRecs          : Integer;
  vDestConnections       : TListDefConnections;
  vSourceConnection      : TRESTDWConnectionParams;
  vRESTDWBatchFieldsDefs : TRESTDWBatchFieldsDefs;
  vOnProcessError        : TOnProcessError;
  vOnBeginProcess,
  vOnEndProcess          : TOnProcess;
  vOnProcess             : TOnActProcess;
  vSourceClient,
  vDestClient            : TRESTDWClientSQL;
  vRESTDWProcessSide     : TRESTDWProcessSide;
 Public
  Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;
  Function    Start(Action : TRESTDWBatchMoveActionType = bmat_InsertUpdate) : Integer;Overload;
  Function    Start(Source : TRESTDWClientSQL;
                    Action : TRESTDWBatchMoveActionType = bmat_InsertUpdate) : Integer;Overload;
 Published
  Property CommitOnRecs       : Integer                  Read vCommitOnRecs          Write vCommitOnRecs;
  Property DestCommand        : String                   Read vDestSQLCommand        Write vDestSQLCommand;
  Property DestConnections    : TListDefConnections      Read vDestConnections       Write vDestConnections;
  Property FieldsDefs         : TRESTDWBatchFieldsDefs   Read vRESTDWBatchFieldsDefs Write vRESTDWBatchFieldsDefs;
  Property SourceCommand      : String                   Read vSourceSQLCommand      Write vSourceSQLCommand;
  Property SourceConnection   : TRESTDWConnectionParams  Read vSourceConnection      Write vSourceConnection;
  Property OnLineProcess      : TOnLineProcess           Read vOnLineProcess         Write vOnLineProcess;
  Property OnProcessError     : TOnProcessError          Read vOnProcessError        Write vOnProcessError;
  Property OnBeginProcess     : TOnProcess               Read vOnBeginProcess        Write vOnBeginProcess;
  Property OnProcess          : TOnActProcess            Read vOnProcess             Write vOnProcess;
  Property OnEndProcess       : TOnProcess               Read vOnEndProcess          Write vOnEndProcess;
  Property ProcessSide        : TRESTDWProcessSide       Read vRESTDWProcessSide     Write vRESTDWProcessSide;
End;

Type
 TRESTDWStoredProcedure = Class(TRESTDWClientSQLBase)
 Private
  vActualPoolerMethodClient : TRESTDWPoolerMethodClient;
  vParams        : TParams;
  vBinaryRequest : Boolean;
  vFieldsList    : TFieldsList;
  vActualRec     : Integer;
  vSchemaName,
  vProcName      : String;
  vUpdateSQL     : TRESTDWUpdateSQL;
  vRESTDataBase  : TRESTDWDatabasebaseBase;
  Procedure SetDataBase (Const Value : TRESTDWDatabasebaseBase);
  Procedure Notification(AComponent  : TComponent;
                         Operation   : TOperation); override;
  Procedure SetUpdateSQL  (Value     : TRESTDWUpdateSQL);
  Function  GetUpdateSQL             : TRESTDWUpdateSQL;
 Public
  Constructor Create   (AOwner       : TComponent);Override; //Cria o Componente
  Function    ExecProc (Var Error    : String) : Boolean;
  Destructor  Destroy;Override;                             //Destroy a Classe
  Function    ParamByName(Value      : String) : TParam;
 Published
  Property DataBase            : TRESTDWDatabasebaseBase     Read vRESTDataBase      Write SetDataBase;             //Database REST do Dataset
  Property Params              : TParams             Read vParams            Write vParams;                 //Parametros de Dataset
  Property UpdateSQL           : TRESTDWUpdateSQL    Read GetUpdateSQL       Write SetUpdateSQL;
  Property SchemaName          : String              Read vSchemaName        Write vSchemaName;             //SchemaName
  Property StoredProcName      : String              Read vProcName          Write vProcName;               //Procedure a ser Executada
End;

Type
  TRESTDWPoolerListBase = Class(TRESTDWComponent)
  Private
    vEncoding            : TEncodeSelect;
    vUserAgent,
    vAccessTag,
    vWelcomeMessage,
    vPoolerPrefix,                                     //Prefixo do WS
    vDataRoute,
    vRestWebService,                                   //Rest WebService para consultas
    vPoolerNotFoundMessage,
    vRestURL             : String;                     //Qual o Pooler de Conexão do DataSet
    vTimeOut,
    vConnectTimeOut,
    vRedirectMaximum,
    vPoolerPort          : Integer;                    //A Porta do Pooler
    vCompression,
    vHandleRedirects,
    vConnected,
    vProxy               : Boolean;                    //Diz se tem servidor Proxy
    vProxyOptions        : TProxyOptions;              //Se tem Proxy diz quais as opções
    vPoolerList          : TStringList;
    vAuthOptionParams    : TRESTDWClientAuthOptionParams;
    vCripto              : TCripto;
    vTypeRequest         : TTypeRequest;
    {$IFDEF RESTDWLAZARUS}
    vDatabaseCharSet      : TDatabaseCharSet;
    {$ENDIF}
    Procedure SetConnection(Value : Boolean);          //Seta o Estado da Conexão
    Procedure SetPoolerPort(Value : Integer);          //Seta a Porta do Pooler a ser usada
    Function  TryConnect : Boolean;                    //Tenta Conectar o Servidor para saber se posso executar comandos
    Function  GetPoolerList: TStringList;              // Listar os Poolers
  //  Procedure SetConnectionOptions(Var Value : TRESTClientPoolerBase); //Seta as Opções de Conexão
  Public
    RESTClientPooler: TRESTClientPoolerBase;           //Pooler
    Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
    Destructor  Destroy;Override;                      //Destroy a Classe
  Published
    Property Active                : Boolean                    Read vConnected          Write SetConnection;      //Seta o Estado da Conexão
    Property WelcomeMessage        : String                     Read vWelcomeMessage     Write vWelcomeMessage;    //Welcome Message Event
    Property Proxy                 : Boolean                    Read vProxy              Write vProxy;             //Diz se tem servidor Proxy
    Property Compression           : Boolean                    Read vCompression        Write vCompression;       //Compressão de Dados
    Property DataRoute             : String                     Read vDataRoute          Write vDataRoute;
    Property RequestTimeOut        : Integer                    Read vTimeOut            Write vTimeOut;           //Timeout da Requisição
    Property ConnectTimeOut        : Integer                    Read vConnectTimeOut     Write vConnectTimeOut;
    Property AuthenticationOptions : TRESTDWClientAuthOptionParams Read vAuthOptionParams   Write vAuthOptionParams;
    Property CriptOptions          : TCripto                    Read vCripto             Write vCripto;
    Property ProxyOptions          : TProxyOptions              Read vProxyOptions       Write vProxyOptions;      //Se tem Proxy diz quais as opções
    Property PoolerService         : String                     Read vRestWebService     Write vRestWebService;    //Host do WebService REST
    Property PoolerURL             : String                     Read vRestURL            Write vRestURL;           //URL do WebService REST
    Property PoolerPort            : Integer                    Read vPoolerPort         Write SetPoolerPort;      //A Porta do Pooler do DataSet
    Property PoolerPrefix          : String                     Read vPoolerPrefix       Write vPoolerPrefix;      //Prefixo do WebService REST
    Property Poolers               : TStringList                Read vPoolerList;
    Property HandleRedirects       : Boolean                    Read vHandleRedirects    Write vHandleRedirects;
    Property RedirectMaximum       : Integer                    Read vRedirectMaximum    Write vRedirectMaximum;
    Property AccessTag             : String                     Read vAccessTag          Write vAccessTag;
    Property Encoding              : TEncodeSelect              Read vEncoding           Write vEncoding;          //Encoding da string
    Property UserAgent             : String                     Read vUserAgent          Write vUserAgent;
    Property PoolerNotFoundMessage : String                     Read vPoolerNotFoundMessage Write vPoolerNotFoundMessage;
    Property TypeRequest           : TTypeRequest               Read vTypeRequest        Write vTypeRequest       Default trHttp;
    {$IFDEF RESTDWLAZARUS}
    Property DatabaseCharSet       : TDatabaseCharSet           Read vDatabaseCharSet      Write vDatabaseCharSet;
    {$ENDIF}
   End;

Type
 PRESTDWValueKey = ^TRESTDWValueKey;
 TRESTDWValueKey = Class
 Private
  vKeyname             : String;
  vValue               : Variant;
  vIsStream,
  vIsNull              : Boolean;
  vObjectValue         : TObjectValue;
  vStreamValue         : TMemoryStream;
 Public
  Constructor Create;
  Property Keyname     : String       Read vKeyname     Write vKeyname;
  Property Value       : Variant      Read vValue       Write vValue;
  Property IsStream    : Boolean      Read vIsStream    Write vIsStream;
  Property IsNull      : Boolean      Read vIsNull      Write vIsNull;
  Property ObjectValue : TObjectValue Read vObjectValue Write vObjectValue;
End;

Type
 TRESTDWValueKeys = Class(TList)
 Private
 Private
  Function    GetRec     (Index       : Integer) : TRESTDWValueKey;  Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TRESTDWValueKey);            Overload;
  Function    GetRecName(Index        : String)  : TRESTDWValueKey;  Overload;
  Procedure   PutRecName(Index        : String;
                         Item         : TRESTDWValueKey);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Function    BuildArrayValues        : TArrayData;
  Function    BuildKeyNames           : String;
  Function    Add        (Item        : TRESTDWValueKey) : Integer;  Overload;
  Procedure   Delete     (Index       : Integer);  Overload;
  Procedure   Delete     (Index       : String);   Overload;
  Property    Items      [Index       : Integer] : TRESTDWValueKey Read GetRec     Write PutRec; Default;
  Property    ItemsByName[Index       : String ] : TRESTDWValueKey Read GetRecName Write PutRecName;
End;

//PoolerDB Control
Type
 TRESTDWPoolerDBP = ^TRESTDWComponent;
 TRESTDWPoolerDB  = Class(TRESTDWComponent)
 Private
//  FLock          : TCriticalSection;
  vRESTDriver    : TRESTDWDriverBase;
  vActive,
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vCompression   : Boolean;
  vEncoding      : TEncodeSelect;
  vAccessTag,
  vMessagePoolerOff : String;
  vParamCreate   : Boolean;
  Procedure SetConnection(Value : TRESTDWDriverBase);
  Function  GetConnection  : TRESTDWDriverBase;
 protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  Function ExecuteCommand(SQL              : String;
                          Var Error        : Boolean;
                          Var MessageError : String;
                          Var BinaryBlob   : TMemoryStream;
                          Var RowsAffected : Integer;
                          Execute          : Boolean = False) : String;Overload;
  Function ExecuteCommand(SQL              : String;
                          Params           : TRESTDWParams;
                          Var Error        : Boolean;
                          Var MessageError : String;
                          Var BinaryBlob   : TMemoryStream;
                          Var RowsAffected : Integer;
                          Execute          : Boolean = False) : String;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Params           : TRESTDWParams;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Procedure ExecuteProcedure  (ProcName         : String;
                               Params           : TRESTDWParams;
                               Var Error        : Boolean;
                               Var MessageError : String);
  Procedure ExecuteProcedurePure(ProcName         : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String);
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                     //Destroy a Classe
 Published
  Property    RESTDriver       : TRESTDWDriverBase Read GetConnection     Write SetConnection;
  Property    Compression      : Boolean           Read vCompression      Write vCompression;
  Property    Encoding         : TEncodeSelect     Read vEncoding         Write vEncoding;
  Property    StrsTrim         : Boolean           Read vStrsTrim         Write vStrsTrim;
  Property    StrsEmpty2Null   : Boolean           Read vStrsEmpty2Null   Write vStrsEmpty2Null;
  Property    StrsTrim2Len     : Boolean           Read vStrsTrim2Len     Write vStrsTrim2Len;
  Property    Active           : Boolean           Read vActive           Write vActive;
  Property    PoolerOffMessage : String            Read vMessagePoolerOff Write vMessagePoolerOff;
  Property    AccessTag        : String            Read vAccessTag        Write vAccessTag;
  Property    ParamCreate      : Boolean           Read vParamCreate      Write vParamCreate;
End;

 Function GeTRESTDWParams(Params : TParams; Encondig : TEncodeSelect) : TRESTDWParams;

Var
 BufferBase : TRESTDWBufferBase; //Pacote Saida

implementation

Uses uRESTDWJSONInterface;

Function GeTRESTDWParams(Params : TParams; Encondig : TEncodeSelect) : TRESTDWParams;
Var
 I, A      : Integer;
 JSONParam : TJSONParam;
Begin
 Result := Nil;
 If Params <> Nil Then
  Begin
   If Params.Count > 0 Then
    Begin
     Result := TRESTDWParams.Create;
     Result.Encoding := Encondig;
     For I := 0 To Params.Count -1 Do
      Begin
       JSONParam         := TJSONParam.Create(Result.Encoding);
       JSONParam.ParamName := Params[I].Name;
       JSONParam.Encoded   := True;
       JSONParam.LoadFromParam(Params[I]);
       Result.Add(JSONParam);
      End;
    End;
  End;
End;

Constructor TRESTDWBatchMove.Create(AOwner : TComponent);
Begin
 Inherited;
 vDestConnections       := TListDefConnections.Create(Self, TRESTDWConnectionServer);
 vSourceConnection      := TRESTDWConnectionParams.Create;
 vRESTDWBatchFieldsDefs := TRESTDWBatchFieldsDefs.Create(Self, TRESTDWBatchFieldItem);
 vCommitOnRecs          := 100;
 vSourceClient          := TRESTDWClientSQL.Create(Nil);
 vDestClient            := TRESTDWClientSQL.Create(Nil);
 vRESTDWProcessSide     := psClient;
End;

Destructor TRESTDWBatchMove.Destroy;
Begin
 FreeAndNil(vSourceClient);
 FreeAndNil(vDestClient);
 FreeAndNil(vDestConnections);
 FreeAndNil(vSourceConnection);
 FreeAndNil(vRESTDWBatchFieldsDefs);
 Inherited;
End;

Function   TRESTDWBatchMove.Start(Source : TRESTDWClientSQL;
                                  Action : TRESTDWBatchMoveActionType = bmat_InsertUpdate) : Integer;
Begin
 Result := 0;

End;

Function   TRESTDWBatchMove.Start(Action : TRESTDWBatchMoveActionType = bmat_InsertUpdate) : Integer;
Begin
 Result := 0;

End;

Function  TRESTDWConnectionServer.GetDisplayName             : String;
Begin
 Result := vListName;
End;

Procedure TRESTDWConnectionServer.SetDisplayName(Const Value : String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidConnectionName)
 Else
  Begin
   vListName := Trim(Value);
   Inherited;
  End;
End;

Procedure TAutoCheckData.Assign(Source: TPersistent);
Var
 Src : TAutoCheckData;
Begin
 If Source is TAutoCheckData Then
  Begin
   Src        := TAutoCheckData(Source);
   vAutoCheck := Src.AutoCheck;
   vInTime    := Src.InTime;
//   vEvent     := Src.OnEventTimer;
  End
 Else
  Inherited;
End;

Procedure TProxyOptions.Assign(Source: TPersistent);
Var
 Src : TProxyOptions;
Begin
 If Source is TProxyOptions Then
  Begin
   Src := TProxyOptions(Source);
   vServer := Src.Server;
   vLogin  := Src.Login;
   vPassword := Src.Password;
   vPort     := Src.Port;
  End
 Else
  Inherited;
End;

Function  TRESTDWPoolerDB.GetConnection : TRESTDWDriverBase;
Begin
 Result := vRESTDriver;
End;

Procedure TRESTDWPoolerDB.SetConnection(Value : TRESTDWDriverBase);
Begin
 If vRESTDriver <> Value Then
  vRESTDriver := Value;
 If vRESTDriver <> Nil   Then
  vRESTDriver.FreeNotification(Self);
End;

Function TRESTDWPoolerDB.InsertMySQLReturnID(SQL              : String;
                                           Var Error        : Boolean;
                                           Var MessageError : String) : Integer;
Begin
 Result := -1;
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.StrsTrim          := vStrsTrim;
   vRESTDriver.StrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.StrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.Compression       := vCompression;
   vRESTDriver.Encoding          := vEncoding;
   vRESTDriver.ParamCreate       := vParamCreate;
   Result := vRESTDriver.InsertMySQLReturnID(SQL, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := cErrorDriverNotSet;
  End;
End;

Function TRESTDWPoolerDB.InsertMySQLReturnID(SQL              : String;
                                           Params           : TRESTDWParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String) : Integer;
Begin
 Result := -1;
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.StrsTrim          := vStrsTrim;
   vRESTDriver.StrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.StrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.Compression       := vCompression;
   vRESTDriver.Encoding          := vEncoding;
   vRESTDriver.ParamCreate       := vParamCreate;
   Result := vRESTDriver.InsertMySQLReturnID(SQL, Params, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := cErrorDriverNotSet;
  End;
End;

Procedure TRESTDWPoolerDB.Notification(AComponent: TComponent; Operation: TOperation);
Begin
 If (Operation  = opRemove)    And
    (AComponent = vRESTDriver) Then
  vRESTDriver := Nil;
 Inherited Notification(AComponent, Operation);
End;

Function TRESTDWPoolerDB.ExecuteCommand(SQL              : String;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Var BinaryBlob   : TMemoryStream;
                                        Var RowsAffected : Integer;
                                        Execute          : Boolean = False) : String;
Begin
  Result := '';
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.StrsTrim          := vStrsTrim;
   vRESTDriver.StrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.StrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.Compression       := vCompression;
   vRESTDriver.Encoding          := vEncoding;
   vRESTDriver.ParamCreate       := vParamCreate;
   Result := vRESTDriver.ExecuteCommand(SQL, Error, MessageError, BinaryBlob, RowsAffected, Execute);
  End
 Else
  Begin
   Error        := True;
   MessageError := cErrorDriverNotSet;
  End;
End;

Function TRESTDWPoolerDB.ExecuteCommand(SQL              : String;
                                        Params           : TRESTDWParams;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Var BinaryBlob   : TMemoryStream;
                                        Var RowsAffected : Integer;
                                        Execute          : Boolean = False) : String;
Begin
 Result := '';
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.StrsTrim          := vStrsTrim;
   vRESTDriver.StrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.StrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.Compression       := vCompression;
   vRESTDriver.Encoding          := vEncoding;
   vRESTDriver.ParamCreate       := vParamCreate;
   Result := vRESTDriver.ExecuteCommand(SQL, Params, Error, MessageError, BinaryBlob, RowsAffected, Execute);
  End
 Else
  Begin
   Error        := True;
   MessageError := cErrorDriverNotSet;
  End;
End;

Procedure TRESTDWPoolerDB.ExecuteProcedure(ProcName         : String;
                                         Params           : TRESTDWParams;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Begin
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.StrsTrim          := vStrsTrim;
   vRESTDriver.StrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.StrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.Compression       := vCompression;
   vRESTDriver.Encoding          := vEncoding;
   vRESTDriver.ParamCreate       := vParamCreate;
   vRESTDriver.ExecuteProcedure(ProcName, Params, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := cErrorDriverNotSet;
  End;
End;

Procedure TRESTDWPoolerDB.ExecuteProcedurePure(ProcName         : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String);
Begin
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.StrsTrim          := vStrsTrim;
   vRESTDriver.StrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.StrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.Compression       := vCompression;
   vRESTDriver.Encoding          := vEncoding;
   vRESTDriver.ParamCreate       := vParamCreate;
   vRESTDriver.ExecuteProcedurePure(ProcName, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := cErrorDriverNotSet;
  End;
End;

Constructor TRESTDWPoolerDB.Create(AOwner : TComponent);
Begin
 Inherited;
 //{$IFNDEF FPC}
 //FLock             := TCriticalSection.Create;
 //FLock.Acquire;
 //{$ENDIF}
 vCompression      := True;
 vStrsTrim         := False;
 vStrsEmpty2Null   := False;
 vStrsTrim2Len     := True;
 vActive           := True;
 {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
 vEncoding         := esUtf8;
 {$ELSE}
 vEncoding         := esAscii;
 {$IFEND}
 vMessagePoolerOff := 'RESTPooler not active.';
 vParamCreate      := True;
End;

Destructor  TRESTDWPoolerDB.Destroy;
Begin
 //If Assigned(FLock) Then
 // Begin
 //  {.$IFNDEF POSIX}
 //  FLock.Release;
 //  {.$ENDIF}
 //  FreeAndNil(FLock);
 // End;
 Inherited;
End;

Constructor TAutoCheckData.Create;
Begin
 Inherited;
 vAutoCheck := False;
 vInTime    := 1000;
 vEvent     := Nil;
 Timer      := Nil;
// FLock      := TCriticalSection.Create;
End;

Destructor  TAutoCheckData.Destroy;
Begin
 SetState(False);
 //FLock.Release;
 //FLock.Free;
 Inherited;
End;

Procedure  TAutoCheckData.SetState(Value : Boolean);
Begin
 vAutoCheck := Value;
 If vAutoCheck Then
  Begin
   If Timer <> Nil Then
    Begin
     Timer.Terminate;
     Timer := Nil;
    End;
   Timer              := TTimerData.Create(vInTime, FLock);
   Timer.OnEventTimer := vEvent;
  End
 Else
  Begin
   If Timer <> Nil Then
    Begin
     Timer.Terminate;
     Timer := Nil;
    End;
  End;
End;

Procedure  TAutoCheckData.SetInTime(Value : Integer);
Begin
 vInTime    := Value;
 SetState(vAutoCheck);
End;

Procedure  TAutoCheckData.SetEventTimer(Value : TOnEventTimer);
Begin
 vEvent := Value;
 SetState(vAutoCheck);
End;

Constructor TTimerData.Create(AValue: Integer; ALock: TCriticalSection);
Begin
 FValue := AValue;
 FLock := ALock;
 Inherited Create(False);
End;

Procedure TTimerData.Execute;
Begin
 While Not Terminated do
  Begin
   Sleep(FValue);
   //If Assigned(FLock) then
   // FLock.Acquire;
   if Assigned(vEvent) then
    vEvent;
   //If Assigned(FLock) then
   // FLock.Release;
  End;
End;

Constructor TProxyOptions.Create;
Begin
 Inherited;
 vServer   := '';
 vLogin    := vServer;
 vPassword := vLogin;
 vPort     := 8888;
End;

Procedure TRESTDWDatabasebaseBase.SetOnStatus(Value : TOnStatus);
Begin
  vOnStatus            := Value;
End;

Function  TRESTDWDatabasebaseBase.RenewToken(Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                             Var Params             : TRESTDWParams;
                                             Var Error              : Boolean;
                                             Var MessageError       : String) : String;
Var
 I                    : Integer;
 vTempSend            : String;
 vConnection          : TRESTDWPoolerMethodClient;
Begin
 //Atualização de Token na autenticação
 Result                       := '';
 vConnection                  := PoolerMethodClient;
 vConnection.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vConnection.HandleRedirects  := vHandleRedirects;
 vConnection.RedirectMaximum  := vRedirectMaximum;
 vConnection.UserAgent        := vUserAgent;
 vConnection.TypeRequest      := vTypeRequest;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vRestWebService;
 vConnection.Port             := vPoolerPort;
 vConnection.Compression      := vCompression;
 vConnection.EncodeStrings    := EncodedStrings;
 vConnection.Encoding         := Encoding;
 vConnection.AccessTag        := vAccessTag;
 vConnection.CriptOptions.Use := vCripto.Use;
 vConnection.CriptOptions.Key := vCripto.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFNDEF RESTDWLAZARUS}
  vConnection.Encoding      := vEncoding;
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
                                                       MessageError, vTimeOut,
                                                       vConnectTimeOut, Nil,
                                                       vRESTClientPooler);
                     vTempSend                                           := GettokenValue(vTempSend);
                     TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
      rdwAOToken  : Begin
                     vTempSend := vConnection.GetToken(vDataRoute,
                                                       Params,          Error,
                                                       MessageError,    vTimeOut,
                                                       vConnectTimeOut, Nil,
                                                       vRESTClientPooler);
                     vTempSend                                          := GettokenValue(vTempSend);
                     TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
     End;
     Result      := vTempSend;
     If csDesigning in ComponentState Then
      If Error Then Raise Exception.Create(PChar(cAuthenticationError));
     If Error Then
      Begin
       Result      := '';
       If vFailOver Then
        Begin
         If vFailOverConnections.Count = 0 Then
          Begin
           Result      := '';
           vMyIP       := '';
           If csDesigning in ComponentState Then
            Raise Exception.Create(PChar(cInvalidConnection));
           If Assigned(vOnEventConnection) Then
            vOnEventConnection(False, cInvalidConnection)
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
                   (vFailOverConnections[I].EncodeStrings   = vConnection.EncodeStrings)  And
                   (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                   (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
                   (vFailOverConnections[I].vRestPooler     = vRestPooler)                And
                   (vFailOverConnections[I].vDataRoute      = vDataRoute))                Or
                 (Not (vFailOverConnections[I].Active))                                   Then
               Continue;
              End;
             If Assigned(vOnFailOverExecute) Then
              vOnFailOverExecute(vFailOverConnections[I]);
             ReconfigureConnection(vConnection,
                                   vRESTClientPooler,
                                   vFailOverConnections[I].vTypeRequest,
                                   vFailOverConnections[I].vWelcomeMessage,
                                   vFailOverConnections[I].vRestWebService,
                                   vFailOverConnections[I].vPoolerPort,
                                   vFailOverConnections[I].vCompression,
                                   vFailOverConnections[I].EncodeStrings,
                                   vFailOverConnections[I].Encoding,
                                   vFailOverConnections[I].vAccessTag,
                                   vFailOverConnections[I].AuthenticationOptions);
             Try
              Case vAuthOptionParams.AuthorizationOption Of
               rdwAOBearer : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vDataRoute,
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,vConnectTimeOut,
                                                                Nil, vRESTClientPooler);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vDataRoute,
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,vConnectTimeOut,
                                                                Nil,          vRESTClientPooler);
                              vTempSend                                         := GettokenValue(vTempSend);
                              TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
              End;
              Result      := vTempSend;
              If Not(Error) Then
               Begin
                If vFailOverReplaceDefaults Then
                 Begin
                  vTypeRequest      := vConnection.TypeRequest;
                  vWelcomeMessage   := vConnection.WelcomeMessage;
                  vRestWebService   := vConnection.Host;
                  vPoolerPort       := vConnection.Port;
                  vCompression      := vConnection.Compression;
                  vEncodeStrings    := vConnection.EncodeStrings;
                  vEncoding         := vConnection.Encoding;
                  vAccessTag        := vConnection.AccessTag;
                  vDataRoute        := vFailOverConnections[I].vDataRoute;
                  vRestPooler       := vFailOverConnections[I].vRestPooler;
                  vTimeOut          := vFailOverConnections[I].vTimeOut;
                  vConnectTimeOut   := vFailOverConnections[I].vConnectTimeOut;
                  vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
                 End;
               End;
              If csDesigning in ComponentState Then
               If Error Then
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
        End
       Else
        Begin
         If Assigned(vOnEventConnection) Then
          vOnEventConnection(False, cAuthenticationError);
        End;
      End;
    Except
     On E : Exception do
      Begin
       //DestroyComponents;
       If vFailOver Then
        Begin
         If vFailOverConnections.Count > 0 Then
          Begin
           If Assigned(vFailOverConnections) Then
           For I := 0 To vFailOverConnections.Count -1 Do
            Begin
             //DestroyComponents;
             If I = 0 Then
              Begin
               If ((vFailOverConnections[I].vTypeRequest    = vConnection.TypeRequest)    And
                   (vFailOverConnections[I].vWelcomeMessage = vConnection.WelcomeMessage) And
                   (vFailOverConnections[I].vRestWebService = vConnection.Host)           And
                   (vFailOverConnections[I].vPoolerPort     = vConnection.Port)           And
                   (vFailOverConnections[I].vCompression    = vConnection.Compression)    And
                   (vFailOverConnections[I].EncodeStrings   = vConnection.EncodeStrings)  And
                   (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                   (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
                   (vFailOverConnections[I].vRestPooler     = vRestPooler)                And
                   (vFailOverConnections[I].vDataRoute      = vDataRoute))                Or
                   (Not (vFailOverConnections[I].Active))                                 Then
               Continue;
              End;
             If Assigned(vOnFailOverExecute) Then
              vOnFailOverExecute(vFailOverConnections[I]);
             ReconfigureConnection(vConnection,
                                   vRESTClientPooler,
                                   vFailOverConnections[I].vTypeRequest,
                                   vFailOverConnections[I].vWelcomeMessage,
                                   vFailOverConnections[I].vRestWebService,
                                   vFailOverConnections[I].vPoolerPort,
                                   vFailOverConnections[I].vCompression,
                                   vFailOverConnections[I].EncodeStrings,
                                   vFailOverConnections[I].Encoding,
                                   vFailOverConnections[I].vAccessTag,
                                   vFailOverConnections[I].AuthenticationOptions);
             Try
              Case vAuthOptionParams.AuthorizationOption Of
               rdwAOBearer : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vDataRoute,
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,vConnectTimeOut,
                                                                Nil, vRESTClientPooler);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vDataRoute,
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,vConnectTimeOut,
                                                                Nil, vRESTClientPooler);
                              vTempSend                                         := GettokenValue(vTempSend);
                              TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
              End;
              Result      := vTempSend;
              If Not(Error) Then
               Begin
                If vFailOverReplaceDefaults Then
                 Begin
                  vTypeRequest      := vConnection.TypeRequest;
                  vWelcomeMessage   := vConnection.WelcomeMessage;
                  vRestWebService   := vConnection.Host;
                  vPoolerPort       := vConnection.Port;
                  vCompression      := vConnection.Compression;
                  vEncodeStrings    := vConnection.EncodeStrings;
                  vEncoding         := vConnection.Encoding;
                  vAccessTag        := vConnection.AccessTag;
                  vDataRoute        := vFailOverConnections[I].vDataRoute;
                  vRestPooler       := vFailOverConnections[I].vRestPooler;
                  vTimeOut          := vFailOverConnections[I].vTimeOut;
                  vConnectTimeOut   := vFailOverConnections[I].vConnectTimeOut;
                  vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
                 End;
               End;
              If csDesigning in ComponentState Then
               If Error Then
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
            Raise Exception.Create(PChar(E.Message));
           If Assigned(vOnEventConnection) Then
            vOnEventConnection(False, E.Message)
           Else
            Raise Exception.Create(E.Message);
          End;
        End
       Else
        Begin
         Result      := '';
         If csDesigning in ComponentState Then
          Raise Exception.Create(PChar(E.Message));
         If Assigned(vOnEventConnection) Then
          vOnEventConnection(False, E.Message)
         Else
          Raise Exception.Create(E.Message);
        End;
      End;
    End;
   Finally
    //DestroyComponents;
   End;
  End;
End;

Procedure TRESTDWDatabasebaseBase.SetOnWork(Value : TOnWork);
Begin
  vOnWork := Value;
End;

Procedure TRESTDWDatabasebaseBase.SetOnWorkBegin(Value : TOnWork);
Begin
  vOnWorkBegin := Value;
End;

Procedure TRESTDWDatabasebaseBase.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
  vOnWorkEnd := Value;
End;

Procedure TRESTDWDatabasebaseBase.ApplyUpdatesTB(Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                         Massive                : TMassiveDatasetBuffer;
                                         Var Params             : TParams;
                                         Var Error,
                                         hBinaryRequest         : Boolean;
                                         Var MessageError       : String;
                                         Var Result             : TJSONValue;
                                         Var RowsAffected       : Integer;
                                         RESTClientPooler       : TRESTClientPoolerBase = Nil);
Var
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 LDataSetList         : TJSONValue;
 DWParams             : TRESTDWParams;
 SocketError          : Boolean;
 I                    : Integer;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
  If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 SocketError := False;
 RESTClientPoolerExec := nil;
 if vRestPooler = '' then
  Exit;
 ParseParams;
 vRESTConnectionDB  := BuildConnection(hBinaryRequest);
 PoolerMethodClient := vRESTConnectionDB;
 vRESTConnectionDB.SSLVersions := SSLVersions;
 CopyParams(vRESTConnectionDB, vRESTClientPooler);
 Try
  If Params.Count > 0 Then
   DWParams     := GeTRESTDWParams(Params, vEncoding)
  Else
   DWParams     := Nil;
  For I := 0 To 1 Do
   Begin
    LDataSetList := vRESTConnectionDB.ApplyUpdatesTB(Massive,      vRestPooler,
                                                     vDataRoute,
                                                     DWParams,     Error,
                                                     MessageError, SocketError, RowsAffected, vTimeOut, vConnectTimeOut, '',
                                                     vClientConnectionDefs.vConnectionDefs,
                                                     vRESTClientPooler);
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      If Assigned(LDataSetList) Then
       FreeAndNil(LDataSetList);
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        LDataSetList := vRESTConnectionDB.ApplyUpdatesTB(Massive,
                                                         vFailOverConnections[I].vRestPooler,
                                                         vFailOverConnections[I].vDataRoute,
                                                         DWParams,     Error,
                                                         MessageError, SocketError, RowsAffected, vTimeOut, vConnectTimeOut, '',
                                                         vClientConnectionDefs.vConnectionDefs,
                                                         vRESTClientPooler);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vDataRoute      := vFailOverConnections[I].vDataRoute;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If Params.Count > 0 Then
   If DWParams <> Nil Then
    FreeAndNil(DWParams);
  If (LDataSetList <> Nil) Then
   Begin
    Result := Nil;
    Error  := Trim(MessageError) <> '';
    If (LDataSetList <> Nil) And
       (Not (Error))        Then
     Begin
      Try
       Result          := TJSONValue.Create;
       Result.Encoding := LDataSetList.Encoding;
       Result.SetValue(LDataSetList.value);
      Finally
      End;
     End;
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'ApplyUpdates Ok');
     End
    Else
     Begin
      Error        := MessageError <> '';
      MessageError := MessageError;
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError);
     End;
   End
  Else
   Begin
    Error        := MessageError <> '';
    MessageError := MessageError;
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    Error        := E.Message <> '';
    MessageError := E.Message;
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, E.Message);
   End;
 End;
 FreeAndNil(vRESTConnectionDB);
 If Assigned(LDataSetList) then
  FreeAndNil(LDataSetList);
End;

Procedure TRESTDWDatabasebaseBase.ApplyUpdates(Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                               Massive                : TMassiveDatasetBuffer;
                                               SQL                    : TStringList;
                                               Var Params             : TParams;
                                               Var Error,
                                               hBinaryRequest         : Boolean;
                                               Var MessageError       : String;
                                               Var Result             : TJSONValue;
                                               Var RowsAffected       : Integer;
                                               RESTClientPooler       : TRESTClientPoolerBase = Nil);
Var
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 LDataSetList         : TJSONValue;
 DWParams             : TRESTDWParams;
 SocketError          : Boolean;
 I                    : Integer;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
  If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 SocketError := False;
 RESTClientPoolerExec := Nil;
 If vRestPooler = '' Then
  Exit;
 ParseParams;
 vRESTConnectionDB             := BuildConnection(hBinaryRequest);
 PoolerMethodClient            := vRESTConnectionDB;
 vRESTConnectionDB.SSLVersions := SSLVersions;
 CopyParams(vRESTConnectionDB, vRESTClientPooler);
 Try
  If Params.Count > 0 Then
   DWParams     := GeTRESTDWParams(Params, vEncoding)
  Else
   DWParams     := Nil;
  For I := 0 To 1 Do
   Begin
    LDataSetList := vRESTConnectionDB.ApplyUpdates(Massive,      vRestPooler,
                                                   vDataRoute,   GetLineSQL(SQL),
                                                   DWParams,     Error,
                                                   MessageError, SocketError, RowsAffected, vTimeOut, vConnectTimeOut, '',
                                                   vClientConnectionDefs.vConnectionDefs,
                                                   vRESTClientPooler);
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      If Assigned(LDataSetList) Then
       FreeAndNil(LDataSetList);
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        LDataSetList := vRESTConnectionDB.ApplyUpdates(Massive,
                                                       vFailOverConnections[I].vRestPooler,
                                                       vFailOverConnections[I].vDataRoute,
                                                       GetLineSQL(SQL), DWParams,     Error,
                                                       MessageError, SocketError, RowsAffected, vTimeOut, vConnectTimeOut, '',
                                                       vClientConnectionDefs.vConnectionDefs,
                                                       vRESTClientPooler);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vDataRoute      := vFailOverConnections[I].vDataRoute;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If Params.Count > 0 Then
   If DWParams <> Nil Then
    FreeAndNil(DWParams);
  If (LDataSetList <> Nil) Then
   Begin
    Result := Nil;
    Error  := Trim(MessageError) <> '';
    If (LDataSetList <> Nil) And
       (Not (Error))        Then
     Begin
      Try
       Result          := TJSONValue.Create;
       Result.Encoding := LDataSetList.Encoding;
       Result.SetValue(LDataSetList.value);
      Finally
      End;
     End;
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'ApplyUpdates Ok');
     End
    Else
     Begin
      Error        := MessageError <> '';
      MessageError := MessageError;
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError);
     End;
   End
  Else
   Begin
    Error        := MessageError <> '';
    MessageError := MessageError;
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    Error        := E.Message <> '';
    MessageError := E.Message;
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, E.Message);
   End;
 End;
 FreeAndNil(vRESTConnectionDB);
 If Assigned(LDataSetList) then
  FreeAndNil(LDataSetList);
End;

Function TRESTDWDatabasebaseBase.InsertMySQLReturnID(Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                             Var SQL                : TStringList;
                                             Var Params             : TParams;
                                             Var Error              : Boolean;
                                             Var MessageError       : String;
                                             RESTClientPooler       : TRESTClientPoolerBase = Nil) : Integer;
Var
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 I, LDataSetList      : Integer;
 DWParams             : TRESTDWParams;
 SocketError          : Boolean;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
  If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 SocketError := False;
 RESTClientPoolerExec := Nil;
 Result := -1;
 if vRestPooler = '' then
  Exit;
 ParseParams;
 vRESTConnectionDB             := BuildConnection(False);
 PoolerMethodClient            := vRESTConnectionDB;
 vRESTConnectionDB.SSLVersions := SSLVersions;
 CopyParams(vRESTConnectionDB, vRESTClientPooler);
 Try
  For I := 0 To 1 Do
   Begin
    If Params.Count > 0 Then
     Begin
      DWParams     := GeTRESTDWParams(Params, vEncoding);
      LDataSetList := vRESTConnectionDB.InsertValue(vRestPooler,
                                                    vDataRoute, GetLineSQL(SQL),
                                                    DWParams, Error,
                                                    MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                    vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
      FreeAndNil(DWParams);
     End
    Else
     LDataSetList := vRESTConnectionDB.InsertValuePure (vRestPooler,
                                                        vDataRoute,
                                                        GetLineSQL(SQL), Error,
                                                        MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                        vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      LDataSetList := -1;
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        If Params.Count > 0 Then
         Begin
          DWParams     := GeTRESTDWParams(Params, vEncoding);
          LDataSetList := vRESTConnectionDB.InsertValue(vFailOverConnections[I].vRestPooler,
                                                        vFailOverConnections[I].vDataRoute, GetLineSQL(SQL),
                                                        DWParams, Error,
                                                        MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                        vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
          FreeAndNil(DWParams);
         End
        Else
         LDataSetList := vRESTConnectionDB.InsertValuePure (vFailOverConnections[I].vRestPooler,
                                                            vFailOverConnections[I].vDataRoute,
                                                            GetLineSQL(SQL), Error,
                                                            MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                            vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vDataRoute      := vFailOverConnections[I].vDataRoute;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If (LDataSetList <> -1) Then
   Begin
//    If Not Assigned(Result) Then //Correção fornecida por romyllldo no Forum
    Result := -1;
    Error  := Trim(MessageError) <> '';
    If (LDataSetList <> -1) And
       (Not (Error))        Then
     Begin
      Try
       Result := LDataSetList;
      Finally
      End;
     End;
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'InsertValue Ok');
     End
    Else
     Begin
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError)
      Else
       Raise Exception.Create(PChar(MessageError));
     End;
   End
  Else
   Begin
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 FreeAndNil(vRESTConnectionDB);
End;

function TRESTDWDatabasebaseBase.IsServerLive(Aip: String; Aport: Integer; AMessageErro: String): Boolean;
begin
  {Brito}
end;

procedure TRESTDWDatabasebaseBase.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then
    SetConnection(False);
end;

Procedure TRESTDWDatabasebaseBase.Open;
Begin
 SetConnection(True);
End;

Function TRESTDWDatabasebaseBase.GetTableNames(Var TableNames         : TStringList)  : Boolean;
Var
 I                    : Integer;
 MessageError,
 vUpdateLine          : String;
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 SocketError          : Boolean;
Begin
 SocketError := False;
 RESTClientPoolerExec := Nil;
 Result := False;
 If Not Assigned(TableNames) Then
  TableNames := TStringList.Create;
 If vRestPooler = '' Then
  Exit;
 If Not vConnected Then
  SetConnection(True);
 If vConnected Then
  Begin
   vRESTConnectionDB             := BuildConnection(False);
   vRESTConnectionDB.SSLVersions := SSLVersions;
   CopyParams(vRESTConnectionDB, vRESTClientPooler);
   Try
    Result := vRESTConnectionDB.GetTableNames(vRestPooler, vDataRoute, TableNames,
                                              Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                              vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
    If SocketError Then
     Begin
      If vFailOver Then
       Begin
        For I := 0 To vFailOverConnections.Count -1 Do
         Begin
          If I = 0 Then
           Begin
            If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
                (Not (vFailOverConnections[I].Active))                                       Then
            Continue;
           End;
          If Assigned(vOnFailOverExecute) Then
           vOnFailOverExecute(vFailOverConnections[I]);
          If Not Assigned(RESTClientPoolerExec) Then
           RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
          RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
          ReconfigureConnection(vRESTConnectionDB,
                                RESTClientPoolerExec,
                                vFailOverConnections[I].vTypeRequest,
                                vFailOverConnections[I].vWelcomeMessage,
                                vFailOverConnections[I].vRestWebService,
                                vFailOverConnections[I].vPoolerPort,
                                vFailOverConnections[I].vCompression,
                                vFailOverConnections[I].EncodeStrings,
                                vFailOverConnections[I].Encoding,
                                vFailOverConnections[I].vAccessTag,
                                vFailOverConnections[I].AuthenticationOptions);
          Result := vRESTConnectionDB.GetTableNames(vFailOverConnections[I].vRestPooler,
                                                    vFailOverConnections[I].vDataRoute, TableNames,
                                                    Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                    vClientConnectionDefs.vConnectionDefs);
          If Not SocketError Then
           Begin
            If vFailOverReplaceDefaults Then
             Begin
              vTypeRequest    := vRESTConnectionDB.TypeRequest;
              vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
              vRestWebService := vRESTConnectionDB.Host;
              vPoolerPort     := vRESTConnectionDB.Port;
              vCompression    := vRESTConnectionDB.Compression;
              vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
              vEncoding       := vRESTConnectionDB.Encoding;
              vAccessTag      := vRESTConnectionDB.AccessTag;
              vDataRoute      := vFailOverConnections[I].vDataRoute;
              vRestPooler     := vFailOverConnections[I].vRestPooler;
              vTimeOut        := vFailOverConnections[I].vTimeOut;
              vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
              vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
             End;
            Break;
           End;
         End;
       End;
     End;
   Finally
    FreeAndNil(vRESTConnectionDB);
   End;
  End;
End;

Function TRESTDWDatabasebaseBase.GetFieldNames(TableName              : String;
                                               Var FieldNames         : TStringList)  : Boolean;
Var
 I                    : Integer;
 MessageError,
 vUpdateLine          : String;
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 SocketError          : Boolean;
Begin
 SocketError := False;
 RESTClientPoolerExec := Nil;
 Result := False;
 If Not Assigned(FieldNames) Then
  FieldNames := TStringList.Create;
 If vRestPooler = '' Then
  Exit;
 If Not vConnected Then
  SetConnection(True);
 If vConnected Then
  Begin
   vRESTConnectionDB             := BuildConnection(False);
   vRESTConnectionDB.SSLVersions := SSLVersions;
   CopyParams(vRESTConnectionDB, vRESTClientPooler);
   Try
    Result := vRESTConnectionDB.GetFieldNames(vRestPooler, vDataRoute, TableName, FieldNames,
                                              Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                              vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
    If SocketError Then
     Begin
      If vFailOver Then
       Begin
        For I := 0 To vFailOverConnections.Count -1 Do
         Begin
          If I = 0 Then
           Begin
            If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
                (Not (vFailOverConnections[I].Active))                                       Then
            Continue;
           End;
          If Assigned(vOnFailOverExecute) Then
           vOnFailOverExecute(vFailOverConnections[I]);
          If Not Assigned(RESTClientPoolerExec) Then
           RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
          RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
          ReconfigureConnection(vRESTConnectionDB,
                                RESTClientPoolerExec,
                                vFailOverConnections[I].vTypeRequest,
                                vFailOverConnections[I].vWelcomeMessage,
                                vFailOverConnections[I].vRestWebService,
                                vFailOverConnections[I].vPoolerPort,
                                vFailOverConnections[I].vCompression,
                                vFailOverConnections[I].EncodeStrings,
                                vFailOverConnections[I].Encoding,
                                vFailOverConnections[I].vAccessTag,
                                vFailOverConnections[I].AuthenticationOptions);
          Result := vRESTConnectionDB.GetFieldNames(vFailOverConnections[I].vRestPooler,
                                                    vFailOverConnections[I].vDataRoute, TableName, FieldNames,
                                                    Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                    vClientConnectionDefs.vConnectionDefs);
          If Not SocketError Then
           Begin
            If vFailOverReplaceDefaults Then
             Begin
              vTypeRequest    := vRESTConnectionDB.TypeRequest;
              vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
              vRestWebService := vRESTConnectionDB.Host;
              vPoolerPort     := vRESTConnectionDB.Port;
              vCompression    := vRESTConnectionDB.Compression;
              vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
              vEncoding       := vRESTConnectionDB.Encoding;
              vAccessTag      := vRESTConnectionDB.AccessTag;
              vDataRoute      := vFailOverConnections[I].vDataRoute;
              vRestPooler     := vFailOverConnections[I].vRestPooler;
              vTimeOut        := vFailOverConnections[I].vTimeOut;
              vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
              vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
             End;
            Break;
           End;
         End;
       End;
     End;
   Finally
    FreeAndNil(vRESTConnectionDB);
   End;
  End;
End;

Function TRESTDWDatabasebaseBase.GetKeyFieldNames(TableName              : String;
                                                  Var FieldNames         : TStringList)  : Boolean;
Var
 I                    : Integer;
 MessageError,
 vUpdateLine          : String;
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 SocketError          : Boolean;
Begin
 SocketError := False;
 RESTClientPoolerExec := Nil;
 Result := False;
 If Not Assigned(FieldNames) Then
  FieldNames := TStringList.Create;
 If vRestPooler = '' Then
  Exit;
 If Not vConnected Then
  SetConnection(True);
 If vConnected Then
  Begin
   vRESTConnectionDB             := BuildConnection(False);
   vRESTConnectionDB.SSLVersions := SSLVersions;
   CopyParams(vRESTConnectionDB, vRESTClientPooler);
   Try
    FieldNames.Clear;
    Result := vRESTConnectionDB.GetKeyFieldNames(vRestPooler, vDataRoute, TableName, FieldNames,
                                                 Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                 vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
    If SocketError Then
     Begin
      If vFailOver Then
       Begin
        For I := 0 To vFailOverConnections.Count -1 Do
         Begin
          If I = 0 Then
           Begin
            If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
                (Not (vFailOverConnections[I].Active))                                       Then
            Continue;
           End;
          If Assigned(vOnFailOverExecute) Then
           vOnFailOverExecute(vFailOverConnections[I]);
          If Not Assigned(RESTClientPoolerExec) Then
           RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
          RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
          ReconfigureConnection(vRESTConnectionDB,
                                RESTClientPoolerExec,
                                vFailOverConnections[I].vTypeRequest,
                                vFailOverConnections[I].vWelcomeMessage,
                                vFailOverConnections[I].vRestWebService,
                                vFailOverConnections[I].vPoolerPort,
                                vFailOverConnections[I].vCompression,
                                vFailOverConnections[I].EncodeStrings,
                                vFailOverConnections[I].Encoding,
                                vFailOverConnections[I].vAccessTag,
                                vFailOverConnections[I].AuthenticationOptions);
          Result := vRESTConnectionDB.GetKeyFieldNames(vFailOverConnections[I].vRestPooler,
                                                       vFailOverConnections[I].vDataRoute, TableName, FieldNames,
                                                       Result,      MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                       vClientConnectionDefs.vConnectionDefs);
          If Not SocketError Then
           Begin
            If vFailOverReplaceDefaults Then
             Begin
              vTypeRequest    := vRESTConnectionDB.TypeRequest;
              vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
              vRestWebService := vRESTConnectionDB.Host;
              vPoolerPort     := vRESTConnectionDB.Port;
              vCompression    := vRESTConnectionDB.Compression;
              vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
              vEncoding       := vRESTConnectionDB.Encoding;
              vAccessTag      := vRESTConnectionDB.AccessTag;
              vDataRoute      := vFailOverConnections[I].vDataRoute;
              vRestPooler     := vFailOverConnections[I].vRestPooler;
              vTimeOut        := vFailOverConnections[I].vTimeOut;
              vConnectTimeOut        := vFailOverConnections[I].vConnectTimeOut;
              vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
             End;
            Break;
           End;
         End;
       End;
     End;
   Finally
    FreeAndNil(vRESTConnectionDB);
   End;
  End;
End;

Procedure TRESTDWDatabasebaseBase.OpenDatasets(Datasets         : Array of {$IFDEF RESTDWLAZARUS}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                               BinaryCompatible : Boolean = False);
Var
 Error        : Boolean;
 MessageError : String;
Begin
 OpenDatasets(Datasets, Error, MessageError, True, BinaryCompatible);
 If Error Then
  Raise Exception.Create(PChar(MessageError));
End;

Procedure TRESTDWDatabasebaseBase.OpenDatasets(Datasets         : Array of {$IFDEF RESTDWLAZARUS}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                               Var Error        : Boolean;
                                               Var MessageError : String;
                                               BinaryRequest    : Boolean = True;
                                               BinaryCompatible : Boolean = False);
Var
 vJsonLine,
 vLinesDS             : String;
 vJsonCount,
 I                    : Integer;
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 vJSONValue           : TJSONValue;
 vJsonValueB          : TRESTDWJSONInterfaceBase;
 vJsonArray           : TRESTDWJSONInterfaceArray;
 vJsonOBJ             : TRESTDWJSONInterfaceObject;
 SocketError          : Boolean;
 vPackStream,
 vStream              : TStream;
 BufferStream         : TRESTDWBufferBase; //Pacote Saida
 Function DatasetRequestToJSON(Value : TRESTDWClientSQLBase) : String;
 Var
  vDWParams    : TRESTDWParams;
  vTempLineParams,
  vTempLineSQL : String;
 Begin
  vTempLineParams := '';
  vTempLineSQL    := vTempLineParams;
  Result          := vTempLineSQL;
  If Value <> Nil Then
   Begin
    TRESTDWClientSQL(Value).DWParams(vDWParams);
    If vDWParams <> Nil Then
     Begin
      {$IFDEF RESTDWLAZARUS}
      vTempLineParams := EncodeStrings(vDWParams.ToJSON, TRESTDWClientSQL(Value).DatabaseCharSet);
      {$ELSE}
      vTempLineParams := EncodeStrings(vDWParams.ToJSON);
      {$ENDIF}
      FreeAndNil(vDWParams);
     End;
    {$IFDEF RESTDWLAZARUS}
    vTempLineSQL      := EncodeStrings(TRESTDWClientSQL(Value).SQL.Text, TRESTDWClientSQL(Value).DatabaseCharSet);
    {$ELSE}
    vTempLineSQL      := EncodeStrings(TRESTDWClientSQL(Value).SQL.Text);
    {$ENDIF}
    Result            := Format(TDatasetRequestJSON, [vTempLineSQL, vTempLineParams,
                                                      BooleanToString(TRESTDWClientSQL(Value).BinaryRequest),
                                                      BooleanToString(TRESTDWClientSQL(Value).Fields.Count = 0),
                                                      BooleanToString(True)]);
   End;
 End;
 Procedure DatasetRequestToStream(Value : TRESTDWClientSQLBase);
 Var
  vDWParams     : TRESTDWParams;
  vSqlStream    : TRESTDWBytes;      //SQL Stream
  vParamsStream,                     //Params Stream
  vPackStream   : TStream;           //Pacote do BufferBase de Saida
 Begin
  vPackStream   := Nil;
  If Value <> Nil Then
   Begin
    Try
     BufferBase   := TRESTDWBufferBase.Create; //Cria Pacote Base
     TRESTDWClientSQL(Value).DWParams(vDWParams);
     vSqlStream     := StringToBytes(TRESTDWClientSQL(Value).SQL.Text);
     vParamsStream  := TMemoryStream.Create;
     Try
      If vDWParams <> Nil Then
       Begin
        vDWParams.SaveToStream(vParamsStream);
        FreeAndNil(vDWParams);
       End;
     Finally
      BufferBase.InputBytes(vSqlStream);   //Criando Stream do SQL no Pacote Base
      SetLength(vSqlStream, 0);
      BufferBase.InputStream(vParamsStream);//Criando Stream dos Params no Pacote Base
      FreeAndNil(vParamsStream);
     End;
    Finally
     BufferBase.SaveToStream  (vPackStream);//Salvando o Pacote Base para o Stream do Pacote
     FreeAndNil(BufferBase);
     BufferStream.InputStream (vPackStream);//Lendo Stream do Pacote para um Bloco do Stream Principal de Base
     FreeAndNil(vPackStream);
    End;
   End;
 End;
Begin
 SocketError := False;
 RESTClientPoolerExec := Nil;
 vPackStream          := Nil;
 vStream              := Nil;
 vLinesDS := '';
 If BinaryRequest Then
  BufferStream := TRESTDWBufferBase.Create; //Cria Pacote Saida
 For I := 0 To Length(Datasets) -1 Do
  Begin
   TRESTDWClientSQL(Datasets[I]).ProcBeforeOpen(TRESTDWClientSQL(Datasets[I]));
   If Not BinaryRequest Then
    Begin
     If I = 0 Then
      vLinesDS := DatasetRequestToJSON(TRESTDWClientSQL(Datasets[I]))
     Else
      vLinesDS := Format('%s, %s', [vLinesDS, DatasetRequestToJSON(TRESTDWClientSQL(Datasets[I]))]);
    End
   Else
    DatasetRequestToStream(TRESTDWClientSQL(Datasets[I]));
  End;
 If BinaryRequest Then
  Begin
   vPackStream := TMemoryStream.Create;
   BufferStream.SaveToStream(vPackStream);     //Criando Stream do Pacote de Saida
   FreeAndNil(BufferStream);
   vLinesDS := '[]';
  End
 Else
  Begin
   If vLinesDS <> '' Then
    vLinesDS := Format('[%s]', [vLinesDS])
   Else
    vLinesDS := '[]';
  End;
 If vRestPooler = '' Then
  Exit;
 If Not vConnected Then
  SetConnection(True, BinaryRequest);
 vRESTConnectionDB             := BuildConnection(BinaryRequest);
 vRESTConnectionDB.SSLVersions := SSLVersions;
 CopyParams(vRESTConnectionDB, vRESTClientPooler);
 Try
  For I := 0 To 1 Do
   Begin
    If Not BinaryRequest Then
     vLinesDS := vRESTConnectionDB.OpenDatasets(vLinesDS, vRestPooler,  vDataRoute,
                                                Error,    MessageError, SocketError,
                                                vTimeOut, vConnectTimeOut,
                                                vClientConnectionDefs.vConnectionDefs, vRESTClientPooler)
    Else
     Begin
      vStream  := vRESTConnectionDB.OpenDatasets(vPackStream, vRestPooler,  vDataRoute,
                                                 Error,    MessageError, SocketError,
                                                 BinaryRequest, BinaryCompatible, vTimeOut,
                                                 vConnectTimeOut, vClientConnectionDefs.vConnectionDefs,
                                                 vRESTClientPooler);
      FreeAndNil(vPackStream);
     End;
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      vLinesDS := '';
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        If Not BinaryRequest Then
         vLinesDS := vRESTConnectionDB.OpenDatasets(vLinesDS, vFailOverConnections[I].vRestPooler,  vFailOverConnections[I].vDataRoute,
                                                    Error,    MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                    vClientConnectionDefs.vConnectionDefs)
        Else
         Begin
          vStream  := vRESTConnectionDB.OpenDatasets(vPackStream,     vFailOverConnections[I].vRestPooler,
                                                     vFailOverConnections[I].vDataRoute, Error,
                                                     MessageError,    SocketError,
                                                     BinaryRequest,   BinaryCompatible,
                                                     vTimeOut,        vConnectTimeOut,
                                                     vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
          FreeAndNil(vPackStream);
         End;
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vDataRoute      := vFailOverConnections[I].vDataRoute;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If Not Error Then
   Begin
    If Not BinaryRequest Then
     Begin
      vJSONValue := TJSONValue.Create;
      Try
       vJSONValue.Encoded  := True;
       vJSONValue.Encoding := vEncoding;
       vJSONValue.LoadFromJSON(vLinesDS);
       vJsonLine := vJSONValue.value;
      Finally
       FreeAndNil(vJSONValue);
      End;
      vJsonOBJ := TRESTDWJSONInterfaceObject.Create(vJsonLine);
      vJsonArray     := TRESTDWJSONInterfaceArray(vJsonOBJ);
      Try
       For I := 0 To vJsonArray.ElementCount -1 do
        Begin
         vJsonValueB := vJsonArray.GetObject(I);
         vJsonCount  := 0;
         vJSONValue  := TJSONValue.Create;
         vJSONValue.Utf8SpecialChars := True;
         Try
          vJSONValue.Encoding := vEncoding;
          If Not TRESTDWClientSQL(Datasets[I]).BinaryRequest Then
           Begin
            vJSONValue.LoadFromJSON(TRESTDWJSONInterfaceObject(vJsonValueB).ToJson);
            vJSONValue.Encoded := True;
            vJSONValue.OnWriterProcess := TRESTDWClientSQL(Datasets[I]).OnWriterProcess;
            vJSONValue.ServerFieldList := TRESTDWClientSQL(Datasets[I]).ServerFieldList;
            {$IFDEF RESTDWLAZARUS}
             vJSONValue.DatabaseCharSet := TRESTDWClientSQL(Datasets[I]).DatabaseCharSet;
             vJSONValue.NewFieldList    := @TRESTDWClientSQL(Datasets[I]).NewFieldList;
             vJSONValue.NewDataField    := @TRESTDWClientSQL(Datasets[I]).NewDataField;
             vJSONValue.SetInitDataset  := @TRESTDWClientSQL(Datasets[I]).SetInitDataset;
             vJSONValue.SetRecordCount     := @TRESTDWClientSQL(Datasets[I]).SetRecordCount;
             vJSONValue.Setnotrepage       := @TRESTDWClientSQL(Datasets[I]).Setnotrepage;
             vJSONValue.SetInDesignEvents  := @TRESTDWClientSQL(Datasets[I]).SetInDesignEvents;
             vJSONValue.SetInBlockEvents   := @TRESTDWClientSQL(Datasets[I]).SetInBlockEvents;
             vJSONValue.SetInactive        := @TRESTDWClientSQL(Datasets[I]).SetInactive;
             vJSONValue.FieldListCount     := @TRESTDWClientSQL(Datasets[I]).FieldListCount;
             vJSONValue.GetInDesignEvents  := @TRESTDWClientSQL(Datasets[I]).GetInDesignEvents;
             vJSONValue.PrepareDetailsNew  := @TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew;
             vJSONValue.PrepareDetails     := @TRESTDWClientSQL(Datasets[I]).PrepareDetails;
            {$ELSE}
             vJSONValue.NewFieldList    := TRESTDWClientSQL(Datasets[I]).NewFieldList;
             vJSONValue.CreateDataSet   := TRESTDWClientSQL(Datasets[I]).CreateDataSet;
             vJSONValue.NewDataField    := TRESTDWClientSQL(Datasets[I]).NewDataField;
             vJSONValue.SetInitDataset  := TRESTDWClientSQL(Datasets[I]).SetInitDataset;
             vJSONValue.SetRecordCount     := TRESTDWClientSQL(Datasets[I]).SetRecordCount;
             vJSONValue.Setnotrepage       := TRESTDWClientSQL(Datasets[I]).Setnotrepage;
             vJSONValue.SetInDesignEvents  := TRESTDWClientSQL(Datasets[I]).SetInDesignEvents;
             vJSONValue.SetInBlockEvents   := TRESTDWClientSQL(Datasets[I]).SetInBlockEvents;
             vJSONValue.SetInactive        := TRESTDWClientSQL(Datasets[I]).SetInactive;
             vJSONValue.FieldListCount     := TRESTDWClientSQL(Datasets[I]).FieldListCount;
             vJSONValue.GetInDesignEvents  := TRESTDWClientSQL(Datasets[I]).GetInDesignEvents;
             vJSONValue.PrepareDetailsNew  := TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew;
             vJSONValue.PrepareDetails     := TRESTDWClientSQL(Datasets[I]).PrepareDetails;
            {$ENDIF}
            vJSONValue.WriteToDataset(dtFull, vJSONValue.ToJSON, TRESTDWClientSQL(Datasets[I]),
                                     vJsonCount, TRESTDWClientSQL(Datasets[I]).Datapacks);
            TRESTDWClientSQL(Datasets[I]).vActualJSON := vJSONValue.ToJSON;
            TRESTDWClientSQLBase(Datasets[I]).SetInBlockEvents(False);
            If TRESTDWClientSQL(Datasets[I]).Active Then
             If TRESTDWClientSQL(Datasets[I]).BinaryRequest Then
              TRESTDWClientSQL(Datasets[I]).ProcAfterOpen(TRESTDWClientSQL(Datasets[I]));
           End
          Else
           Begin
            vStream := DecodeStream(TRESTDWJSONInterfaceObject(vJsonValueB).pairs[0].value);
            TRESTDWClientSQLBase(Datasets[I]).SetInBlockEvents(True);
            Try
             TRESTDWClientSQLBase(Datasets[I]).LoadFromStream(TMemoryStream(vStream));
            Finally
             TRESTDWClientSQLBase(Datasets[I]).SetInBlockEvents(False);
             If TRESTDWClientSQL(Datasets[I]).Active Then
              If TRESTDWClientSQL(Datasets[I]).BinaryRequest Then
               TRESTDWClientSQL(Datasets[I]).ProcAfterOpen(TRESTDWClientSQL(Datasets[I]));
            End;
            TRESTDWClientSQL(Datasets[I]).DisableControls;
            Try
             TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(True); // Novavix
             TRESTDWClientSQL(Datasets[I]).Last;
             TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(False); // Novavix
             vJsonCount := TRESTDWClientSQLBase(Datasets[I]).RecNo;
             //A Linha a baixo e pedido do Tiago Istuque que não mostrava o recordcount com BN
             TRESTDWClientSQL(Datasets[I]).SetRecordCount(vJsonCount, vJsonCount);
             TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(True); // Novavix
             TRESTDWClientSQL(Datasets[I]).First;
             TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(False); // Novavix
            Finally
             TRESTDWClientSQL(Datasets[I]).EnableControls;
             If Assigned(vStream) Then
              vStream.Free;
             If TRESTDWClientSQL(Datasets[I]).State = dsBrowse Then
              Begin
               If TRESTDWClientSQL(Datasets[I]).RecordCount = 0 Then
                TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew
               Else
                TRESTDWClientSQL(Datasets[I]).PrepareDetails(True);
              End;
            End;
           End;
          TRESTDWClientSQL(Datasets[I]).CreateMassiveDataset;
         Finally
          FreeAndNil(vJSONValue);
          FreeAndNil(vJsonValueB);
         End;
        End;
      Finally
       FreeAndNil(vJsonArray);
      End;
     End
    Else
     Begin
      BufferStream := TRESTDWBufferBase.Create;
      Try
       If Assigned(vStream) Then
        Begin
         BufferStream.LoadToStream(vStream);
         FreeAndNil(vStream);
         I := 0;
         While Not BufferStream.Eof Do
          Begin
           vStream := BufferStream.ReadStream;
           Try
            TRESTDWClientSQLBase(Datasets[I]).SetInBlockEvents(True);
            Try
             TRESTDWClientSQLBase(Datasets[I]).LoadFromStream(TMemoryStream(vStream));
            Finally
             TRESTDWClientSQLBase(Datasets[I]).SetInBlockEvents(False);
             If TRESTDWClientSQL(Datasets[I]).Active Then
              If BinaryRequest Then
               TRESTDWClientSQL(Datasets[I]).ProcAfterOpen(TRESTDWClientSQL(Datasets[I]));
            End;
            TRESTDWClientSQL(Datasets[I]).DisableControls;
            Try
             TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(True);
             TRESTDWClientSQL(Datasets[I]).Last;
             TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(False);
             vJsonCount := TRESTDWClientSQLBase(Datasets[I]).RecNo;
             TRESTDWClientSQL(Datasets[I]).SetRecordCount(vJsonCount, vJsonCount);
             TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(True);
             TRESTDWClientSQL(Datasets[I]).First;
             TRESTDWClientSQL(Datasets[I]).SetInBlockEvents(False);
            Finally
             TRESTDWClientSQL(Datasets[I]).EnableControls;
             If TRESTDWClientSQL(Datasets[I]).State = dsBrowse Then
              Begin
               If TRESTDWClientSQL(Datasets[I]).RecordCount = 0 Then
                TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew
               Else
                TRESTDWClientSQL(Datasets[I]).PrepareDetails(True);
              End;
            End;
            TRESTDWClientSQL(Datasets[I]).CreateMassiveDataset;
           Finally
            If Assigned(vStream) Then
             FreeAndNil(vStream);
            Inc(I);
           End;
          End;
        End;
      Finally
       If Assigned(vStream) Then
        FreeAndNil(vStream);
       If Assigned(BufferStream) Then
        FreeAndNil(BufferStream);
      End;
     End;
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDatabasebaseBase.ExecuteCommandTB(Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                           Tablename              : String;
                                           Var Params             : TParams;
                                           Var Error              : Boolean;
                                           Var MessageError       : String;
                                           Var Result             : TJSONValue;
                                           Var RowsAffected       : Integer;
                                           BinaryRequest          : Boolean = False;
                                           BinaryCompatibleMode   : Boolean = False;
                                           Metadata               : Boolean = False;
                                           RESTClientPooler       : TRESTClientPoolerBase = Nil);
Var
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 LDataSetList         : TJSONValue;
 DWParams             : TRESTDWParams;
 vSQL,
 vTempValue           : String;
 SocketError          : Boolean;
 I                    : Integer;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
 If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 LDataSetList         := Nil;
 RESTClientPoolerExec := Nil;
 SocketError          := False;
 If vRestPooler = '' Then
  Exit;
 ParseParams;
 vRESTConnectionDB             := BuildConnection(BinaryRequest);
 PoolerMethodClient            := vRESTConnectionDB;
 vRESTConnectionDB.SSLVersions := SSLVersions;
 CopyParams(vRESTConnectionDB, vRESTClientPooler);
 Try
  If Params.Count > 0 Then
   Begin
    DWParams     := GeTRESTDWParams(Params, vEncoding);
    LDataSetList := vRESTConnectionDB.ExecuteCommandJSONTB(vRestPooler,
                                                           vDataRoute,
                                                           Tablename,
                                                           DWParams, Error,
                                                           MessageError, SocketError, RowsAffected, BinaryRequest, BinaryCompatibleMode,
                                                           Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
    FreeAndNil(DWParams);
   End
  Else
   LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSONTB(vRestPooler,
                                                              vDataRoute,
                                                              Tablename,
                                                              Error,
                                                              MessageError, SocketError, RowsAffected, BinaryRequest, BinaryCompatibleMode,
                                                              Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      If Assigned(LDataSetList) Then
       FreeAndNil(LDataSetList);
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        If Params.Count > 0 Then
         Begin
          DWParams     := GeTRESTDWParams(Params, vEncoding);
          LDataSetList := vRESTConnectionDB.ExecuteCommandJSONTB(vFailOverConnections[I].vRestPooler,
                                                                 vFailOverConnections[I].vDataRoute,
                                                                 Tablename,
                                                                 DWParams, Error,
                                                                 MessageError, SocketError, RowsAffected, BinaryRequest, BinaryCompatibleMode,
                                                                 Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
          FreeAndNil(DWParams);
         End
        Else
         LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSONTB(vFailOverConnections[I].vRestPooler,
                                                                    vFailOverConnections[I].vDataRoute,
                                                                    Tablename,
                                                                    Error,
                                                                    MessageError, SocketError, RowsAffected, BinaryRequest, BinaryCompatibleMode,
                                                                    Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vDataRoute      := vFailOverConnections[I].vDataRoute;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If (LDataSetList <> Nil) Then
   Begin
    Result := TJSONValue.Create;
    Result.Encoding := vRESTConnectionDB.Encoding;
    Error  := Trim(MessageError) <> '';
    If Not BinaryRequest Then
     Begin
      If Not LDataSetList.IsNull Then
       vTempValue := LDataSetList.ToJSON;
     End
    Else
     Begin
      If Not LDataSetList.IsNull Then
       vTempValue := LDataSetList.Value;
     End;
    If (Trim(vTempValue) <> '{}') And
       (Trim(vTempValue) <> '')    And
       (Not (Error))                       Then
     Begin
      Try
       {$IFDEF RESTDWANDROID}
       Result.Clear;
       If Not BinaryRequest Then
        Begin
         Result.Encoded := False;
         Result.LoadFromJSON(vTempValue);
        End
       Else
        Result.SetValue(LDataSetList.Value, False);
       {$ELSE}
        If Not BinaryRequest Then
         Result.LoadFromJSON(vTempValue)
        Else
         Begin
          If vTempValue <> '' Then
           Result.SetValue(vTempValue, False)
          Else
           Begin
            If Not LDataSetList.IsNull Then
             vTempValue := LDataSetList.ToJSON
           End;
         End;
       {$ENDIF}
      Finally
      End;
     End;
    vTempValue := '';
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'ExecuteCommand Ok');
     End
    Else
     Begin
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError)
      Else
       Raise Exception.Create(PChar(MessageError));
     End;
   End
  Else
   Begin
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 If LDataSetList <> Nil Then
  FreeAndNil(LDataSetList);
 FreeAndNil(vRESTConnectionDB);
End;

Procedure TRESTDWDatabasebaseBase.ExecuteCommand(Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                                 Var SQL                : TStringList;
                                                 Var Params             : TParams;
                                                 Var Error              : Boolean;
                                                 Var MessageError       : String;
                                                 Var Result             : TJSONValue;
                                                 Var RowsAffected       : Integer;
                                                 Execute                : Boolean = False;
                                                 BinaryRequest          : Boolean = False;
                                                 BinaryCompatibleMode   : Boolean = False;
                                                 Metadata               : Boolean = False;
                                                 RESTClientPooler       : TRESTClientPoolerBase     = Nil);
Var
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 vStream              : TStream;
 LDataSetList         : TJSONValue;
 DWParams             : TRESTDWParams;
 vSQL,
 vTempValue           : String;
 vLocalClient,
 SocketError          : Boolean;
 I                    : Integer;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
 If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If (Params[I].DataType = ftUnknown) then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 LDataSetList         := Nil;
 RESTClientPoolerExec := Nil;
 SocketError          := False;
 vLocalClient         := False;
 If vRestPooler = '' Then
  Exit;
 ParseParams;
 vRESTConnectionDB             := BuildConnection(BinaryRequest);
 PoolerMethodClient            := vRESTConnectionDB;
 vRESTConnectionDB.SSLVersions := SSLVersions;
 CopyParams(vRESTConnectionDB, vRESTClientPooler);
 Try
   Try
    vSQL           := SQL.Text;
    If Params.Count > 0 Then
     Begin
      DWParams     := GeTRESTDWParams(Params, vEncoding);
      LDataSetList := vRESTConnectionDB.ExecuteCommandJSON(vRestPooler,
                                                           vDataRoute, vSQL,
                                                           DWParams, Error,
                                                           MessageError, SocketError, RowsAffected, Execute, BinaryRequest, BinaryCompatibleMode,
                                                           Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
      FreeAndNil(DWParams);
     End
    Else
     LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSON(vRestPooler,
                                                              vDataRoute,
                                                              vSQL, Error,
                                                              MessageError, SocketError, RowsAffected, Execute, BinaryRequest, BinaryCompatibleMode,
                                                              Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
    If SocketError Then
     Begin
      If vFailOver Then
       Begin
        If Assigned(LDataSetList) Then
         FreeAndNil(LDataSetList);
        For I := 0 To vFailOverConnections.Count -1 Do
         Begin
          If I = 0 Then
           Begin
            If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
               (Not (vFailOverConnections[I].Active))                                        Then
            Continue;
           End;
          If Assigned(vOnFailOverExecute) Then
           vOnFailOverExecute(vFailOverConnections[I]);
          If Not Assigned(RESTClientPoolerExec) Then
           Begin
            vLocalClient := True;
            RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
           End;
          RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
          ReconfigureConnection(vRESTConnectionDB,
                                RESTClientPoolerExec,
                                vFailOverConnections[I].vTypeRequest,
                                vFailOverConnections[I].vWelcomeMessage,
                                vFailOverConnections[I].vRestWebService,
                                vFailOverConnections[I].vPoolerPort,
                                vFailOverConnections[I].vCompression,
                                vFailOverConnections[I].EncodeStrings,
                                vFailOverConnections[I].Encoding,
                                vFailOverConnections[I].vAccessTag,
                                vFailOverConnections[I].AuthenticationOptions);
          If Params.Count > 0 Then
           Begin
            DWParams     := GeTRESTDWParams(Params, vEncoding);
            LDataSetList := vRESTConnectionDB.ExecuteCommandJSON(vFailOverConnections[I].vRestPooler,
                                                                 vFailOverConnections[I].vDataRoute, GetLineSQL(SQL),
                                                                 DWParams, Error,
                                                                 MessageError, SocketError, RowsAffected, Execute, BinaryRequest, BinaryCompatibleMode,
                                                                 Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
            FreeAndNil(DWParams);
           End
          Else
           LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSON(vFailOverConnections[I].vRestPooler,
                                                                    vFailOverConnections[I].vDataRoute,
                                                                    GetLineSQL(SQL), Error,
                                                                    MessageError, SocketError, RowsAffected, Execute, BinaryRequest, BinaryCompatibleMode,
                                                                    Metadata, vTimeOut, vConnectTimeOut, vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
          If Not SocketError Then
           Begin
            If vFailOverReplaceDefaults Then
             Begin
              vTypeRequest    := vRESTConnectionDB.TypeRequest;
              vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
              vRestWebService := vRESTConnectionDB.Host;
              vPoolerPort     := vRESTConnectionDB.Port;
              vCompression    := vRESTConnectionDB.Compression;
              vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
              vEncoding       := vRESTConnectionDB.Encoding;
              vAccessTag      := vRESTConnectionDB.AccessTag;
              vDataRoute      := vFailOverConnections[I].vDataRoute;
              vRestPooler     := vFailOverConnections[I].vRestPooler;
              vTimeOut        := vFailOverConnections[I].vTimeOut;
              vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
              vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
             End;
            Break;
           End;
         End;
       End;
     End;
    If (LDataSetList <> Nil) Then
     Begin
      Result := TJSONValue.Create;
      Result.Encoding := vRESTConnectionDB.Encoding;
      Error  := Trim(MessageError) <> '';
      If Not BinaryRequest Then
       Begin
        If Not LDataSetList.IsNull Then
         vTempValue := LDataSetList.ToJSON;
       End;
      If ((Trim(vTempValue) <> '{}') And
          (Trim(vTempValue) <> '')   And
          (Not (Error)))             And
           Not(BinaryRequest)        Then
       Begin
        Try
         {$IFDEF RESTDWANDROID}
         Result.Clear;
         If Not BinaryRequest Then
          Begin
           Result.Encoded := False;
           Result.LoadFromJSON(vTempValue);
          End
         Else
          Result.SetValue(LDataSetList.Value, False);
         {$ELSE}
          If Not BinaryRequest Then
           Result.LoadFromJSON(vTempValue)
          Else
           Begin
            If vTempValue <> '' Then
             Result.SetValue(vTempValue, False)
            Else
             Begin
              If Not LDataSetList.IsNull Then
               vTempValue := LDataSetList.ToJSON
             End;
           End;
         {$ENDIF}
        Finally
        End;
       End
      Else If BinaryRequest Then
       Begin
        vStream := TMemoryStream.Create;
        Try
         LDataSetList.SaveToStream(vStream);
         Result.LoadFromStream(vStream);
        Finally
         vStream.Free;
        End;
       End;
      vTempValue := '';
      If (Not (Error)) Then
       Begin
        If Assigned(vOnEventConnection) Then
         vOnEventConnection(True, 'ExecuteCommand Ok');
       End
      Else
       Begin
        If Assigned(Result) then
          FreeAndNil(Result);
        If Assigned(vOnEventConnection) then
         vOnEventConnection(False, MessageError)
        Else
         Raise Exception.Create(PChar(MessageError));
       End;
     End
    Else
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(False, MessageError);
     End;
   Except
    On E : Exception do
     Begin
      if Assigned(vOnEventConnection) then
       vOnEventConnection(False, E.Message);
     End;
   End;
 Finally
  If LDataSetList <> Nil Then
   FreeAndNil(LDataSetList);
  FreeAndNil(vRESTConnectionDB);
  If Assigned(RESTClientPoolerExec) And (vLocalClient) Then
   FreeAndNil(RESTClientPoolerExec);
 End;
End;

Procedure TRESTDWDatabasebaseBase.ExecuteProcedure(Var PoolerMethodClient : TRESTDWPoolerMethodClient;
                                                   ProcName               : String;
                                                   Params                 : TParams;
                                                   Var Error              : Boolean;
                                                   Var MessageError       : String);
Begin

End;

Function TRESTDWDatabasebaseBase.GetRestPoolers : TStringList;
Var
 vConnection : TRESTDWPoolerMethodClient;
 I           : Integer;
Begin
 Result                       := TStringList.Create;
 vConnection                  := TRESTDWPoolerMethodClient.Create(Nil);
 vConnection.PoolerNotFoundMessage := PoolerNotFoundMessage;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 vConnection.HandleRedirects  := HandleRedirects;
 vConnection.RedirectMaximum  := RedirectMaximum;
 vConnection.UserAgent        := UserAgent;
 vConnection.WelcomeMessage   := WelcomeMessage;
 vConnection.Host             := PoolerService;
 vConnection.Port             := PoolerPort;
 vConnection.Compression      := Compression;
 vConnection.TypeRequest      := TypeRequest;
 vConnection.BinaryRequest    := False;
 vConnection.Encoding         := Encoding;
 vConnection.EncodeStrings    := EncodedStrings;
 vConnection.OnWork           := OnWork;
 vConnection.OnWorkBegin      := OnWorkBegin;
 vConnection.OnWorkEnd        := OnWorkEnd;
 vConnection.OnStatus         := OnStatus;
 vConnection.AccessTag        := AccessTag;
 vConnection.CriptOptions.Use := CriptOptions.Use;
 vConnection.CriptOptions.Key := CriptOptions.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.Accept           := Accept;
 vConnection.AcceptEncoding   := AcceptEncoding;
 vConnection.ContentType      := ContentType;
 vConnection.ContentEncoding  := ContentEncoding;
 {$IFDEF RESTDWLAZARUS}
  vConnection.DatabaseCharSet := csUndefined;
 {$ENDIF}
 CopyParams(vConnection, vRESTClientPooler);
 Try
  If Assigned(vRestPoolers) Then
   FreeAndNil(vRestPoolers);
  vRestPoolers := vConnection.GetPoolerList(vDataRoute, vTimeOut, vConnectTimeOut, vRESTClientPooler);
  Try
   If Assigned(vRestPoolers) Then
    Begin
     For I := 0 To vRestPoolers.Count -1 Do
      Result.Add(vRestPoolers[I]);
    End;
   If Assigned(vOnEventConnection) Then
    vOnEventConnection(True, 'GetRestPoolers Ok');
  Finally
   If Assigned(vConnection) Then
    FreeAndNil(vConnection);
  End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 If Assigned(vConnection) Then
  FreeAndNil(vConnection);
End;

Function TRESTDWDatabasebaseBase.GetServerEvents : TStringList;
Var
 vTempList   : TStringList;
 vConnection : TRESTDWPoolerMethodClient;
 I           : Integer;
Begin
 vConnection             := BuildConnection(False);
 vConnection.SSLVersions := SSLVersions;
 CopyParams(vConnection, vRESTClientPooler);
 Result := TStringList.Create;
 Try
  vTempList := vConnection.GetServerEvents(vDataRoute, vTimeOut, vConnectTimeOut, vRESTClientPooler);
  Try
   If Assigned(vTempList) Then
    For I := 0 To vTempList.Count -1 do
     Result.Add(vTempList[I]);
   If Assigned(vOnEventConnection) Then
    vOnEventConnection(True, 'GetServerEvents Ok');
  Finally
   If Assigned(vTempList) Then
    FreeAndNil(vTempList);
  End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 If Assigned(vConnection) Then
  FreeAndNil(vConnection);
End;

Function TRESTDWDatabasebaseBase.GetStateDB: Boolean;
Begin
 Result := vConnected;
End;

Constructor TRESTDWDatabasebaseBase.Create(AOwner : TComponent);
Begin
 Inherited;
 vIgnoreEchoPooler         := False;
 vRESTClientPooler         := Nil;
 vUseSSL                   := False;
 vHandleRedirects          := False;
 vRedirectMaximum          := 0;
 vConnected                := False;
 vPoolerNotFoundMessage    := cPoolerNotFound;
 vAuthOptionParams         := TRESTDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vDataRoute                := '';
 vMyIP                     := '0.0.0.0';
 vRestWebService           := '127.0.0.1';
 vCompression              := True;
 vRestPooler               := '';
 vPoolerPort               := 8082;
 vProxy                    := False;
 vEncodeStrings            := True;
 vFailOver                 := False;
 vFailOverReplaceDefaults  := False;
 vRestPoolers              := Nil;
 vProxyOptions             := TProxyOptions.Create;
 vCripto                   := TCripto.Create;
 vAutoCheckData            := TAutoCheckData.Create;
 vClientConnectionDefs     := TClientConnectionDefs.Create(Self);
 vFailOverConnections      := TListDefConnections.Create(Self, TRESTDWConnectionServer);
 vAutoCheckData.vAutoCheck := False;
 vAutoCheckData.vInTime    := 1000;
 vTimeOut                  := 10000;
 vConnectTimeOut           := 3000;
 vUserAgent                := cUserAgent;
 vContentType              := 'application/json';
 vContentEncoding          := 'multipart/form-data';
 vAccept                   := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
 vAcceptEncoding           := '';
 vCharset                  := 'utf8';
 {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
 vEncoding                := esUtf8;
 {$ELSE}
 vEncoding                := esAscii;
 {$IFEND}
 vContentex                := '';
 vStrsTrim                 := False;
 vStrsEmpty2Null           := False;
 vStrsTrim2Len             := True;
 vParamCreate              := True;
 vClientIpVersion          := civIPv4;
End;

Destructor  TRESTDWDatabasebaseBase.Destroy;
Begin
 vAutoCheckData.vAutoCheck := False;
 If Assigned(vRestPoolers) Then
  FreeAndNil(vRestPoolers);
 FreeAndNil(vProxyOptions);
 FreeAndNil(vAutoCheckData);
 FreeAndNil(vClientConnectionDefs);
 FreeAndNil(vFailOverConnections);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 FreeAndNil(vCripto);
 Inherited;
End;

Procedure TRESTDWDatabasebaseBase.DestroyClientPooler;
Begin
 If Assigned(vRESTClientPooler) Then
  FreeAndNil(vRESTClientPooler);
End;

Procedure TRESTDWDatabasebaseBase.ProcessMassiveSQLCache(Var MassiveSQLCache    : TRESTDWMassiveCacheSQLList;
                                                         Var Error              : Boolean;
                                                         Var MessageError       : String);
Var
 I                    : Integer;
 vUpdateLine          : String;
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 ResultData           : TJSONValue;
 SocketError          : Boolean;
Begin
 SocketError := False;
 RESTClientPoolerExec := nil;
 If MassiveSQLCache.Count > 0 Then
  Begin
   vUpdateLine := MassiveSQLCache.ToJSON;
   If vRestPooler = '' Then
    Exit;
   If Not vConnected Then
    SetConnection(True);
   If vConnected Then
    Begin
     vRESTConnectionDB  := BuildConnection(False);
     vRESTConnectionDB.SSLVersions := SSLVersions;
     CopyParams(vRESTConnectionDB, vRESTClientPooler);
     Try
      For I := 0 To 1 Do
       Begin
        ResultData := vRESTConnectionDB.ProcessMassiveSQLCache(vUpdateLine, vRestPooler,  vDataRoute,
                                                               Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                               vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
        If Not(Error) or (MessageError <> cInvalidAuth) Then
         Break
        Else
         Begin
          Case AuthenticationOptions.AuthorizationOption Of
           rdwAOBearer : Begin
                          If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                               (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                             TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect(vRESTConnectionDB);
                           End;
                         End;
           rdwAOToken  : Begin
                          If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                               (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                             TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect(vRESTConnectionDB);
                           End;
                         End;
          End;
         End;
       End;
      If SocketError Then
       Begin
        If vFailOver Then
         Begin
          If Assigned(ResultData) Then
           FreeAndNil(ResultData);
          For I := 0 To vFailOverConnections.Count -1 Do
           Begin
            If I = 0 Then
             Begin
              If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                  (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                  (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                  (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                  (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                  (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                  (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                  (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                  (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                  (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
                  (Not (vFailOverConnections[I].Active))                                       Then
              Continue;
             End;
            If Assigned(vOnFailOverExecute) Then
             vOnFailOverExecute(vFailOverConnections[I]);
            If Not Assigned(RESTClientPoolerExec) Then
             RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
            RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
            ReconfigureConnection(vRESTConnectionDB,
                                  RESTClientPoolerExec,
                                  vFailOverConnections[I].vTypeRequest,
                                  vFailOverConnections[I].vWelcomeMessage,
                                  vFailOverConnections[I].vRestWebService,
                                  vFailOverConnections[I].vPoolerPort,
                                  vFailOverConnections[I].vCompression,
                                  vFailOverConnections[I].EncodeStrings,
                                  vFailOverConnections[I].Encoding,
                                  vFailOverConnections[I].vAccessTag,
                                  vFailOverConnections[I].AuthenticationOptions);
            ResultData := vRESTConnectionDB.ProcessMassiveSQLCache(vUpdateLine,
                                                                   vFailOverConnections[I].vRestPooler,
                                                                   vFailOverConnections[I].vDataRoute,
                                                                   Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                                   vClientConnectionDefs.vConnectionDefs);
            If Not SocketError Then
             Begin
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := vRESTConnectionDB.TypeRequest;
                vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
                vRestWebService := vRESTConnectionDB.Host;
                vPoolerPort     := vRESTConnectionDB.Port;
                vCompression    := vRESTConnectionDB.Compression;
                vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
                vEncoding       := vRESTConnectionDB.Encoding;
                vAccessTag      := vRESTConnectionDB.AccessTag;
                vDataRoute      := vFailOverConnections[I].vDataRoute;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
              Break;
             End;
           End;
         End;
       End;
     Finally
      If Not Error Then
       MassiveSQLCache.Clear;
//      If Assigned(ResultData) Then
//       If (ResultData.Value <> '') Then
//        MassiveSQLCache.ProcessChanges(ResultData.Value);
      If Assigned(ResultData) Then
       FreeAndNil(ResultData);
      FreeAndNil(vRESTConnectionDB);
     End;
    End;
  End;
End;

Procedure TRESTDWDatabasebaseBase.ProcessMassiveSQLCache(Var MassiveSQLCache    : TRESTDWMassiveSQLCache;
                                                         Var Error              : Boolean;
                                                         Var MessageError       : String);
Var
 I                    : Integer;
 vUpdateLine          : String;
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 ResultData           : TJSONValue;
 SocketError          : Boolean;
Begin
 SocketError := False;
 RESTClientPoolerExec := nil;
 If MassiveSQLCache.MassiveCount > 0 Then
  Begin
   vUpdateLine := MassiveSQLCache.ToJSON;
   If vRestPooler = '' Then
    Exit;
   If Not vConnected Then
    SetConnection(True);
   If vConnected Then
    Begin
     vRESTConnectionDB  := BuildConnection(False);
     vRESTConnectionDB.SSLVersions := SSLVersions;
     CopyParams(vRESTConnectionDB, vRESTClientPooler);
     Try
      For I := 0 To 1 Do
       Begin
        ResultData := vRESTConnectionDB.ProcessMassiveSQLCache(vUpdateLine, vRestPooler,  vDataRoute,
                                                               Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                               vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
        If Not(Error) or (MessageError <> cInvalidAuth) Then
         Break
        Else
         Begin
          Case AuthenticationOptions.AuthorizationOption Of
           rdwAOBearer : Begin
                          If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                               (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                             TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect(vRESTConnectionDB);
                           End;
                         End;
           rdwAOToken  : Begin
                          If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                               (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                             TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect(vRESTConnectionDB);
                           End;
                         End;
          End;
         End;
       End;
      If SocketError Then
       Begin
        If vFailOver Then
         Begin
          If Assigned(ResultData) Then
           FreeAndNil(ResultData);
          For I := 0 To vFailOverConnections.Count -1 Do
           Begin
            If I = 0 Then
             Begin
              If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                  (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                  (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                  (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                  (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                  (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                  (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                  (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                  (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                  (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
                  (Not (vFailOverConnections[I].Active))                                       Then
              Continue;
             End;
            If Assigned(vOnFailOverExecute) Then
             vOnFailOverExecute(vFailOverConnections[I]);
            If Not Assigned(RESTClientPoolerExec) Then
             RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
            RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
            ReconfigureConnection(vRESTConnectionDB,
                                  RESTClientPoolerExec,
                                  vFailOverConnections[I].vTypeRequest,
                                  vFailOverConnections[I].vWelcomeMessage,
                                  vFailOverConnections[I].vRestWebService,
                                  vFailOverConnections[I].vPoolerPort,
                                  vFailOverConnections[I].vCompression,
                                  vFailOverConnections[I].EncodeStrings,
                                  vFailOverConnections[I].Encoding,
                                  vFailOverConnections[I].vAccessTag,
                                  vFailOverConnections[I].AuthenticationOptions);
            ResultData := vRESTConnectionDB.ProcessMassiveSQLCache(vUpdateLine,
                                                                   vFailOverConnections[I].vRestPooler,
                                                                   vFailOverConnections[I].vDataRoute,
                                                                   Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                                   vClientConnectionDefs.vConnectionDefs);
            If Not SocketError Then
             Begin
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := vRESTConnectionDB.TypeRequest;
                vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
                vRestWebService := vRESTConnectionDB.Host;
                vPoolerPort     := vRESTConnectionDB.Port;
                vCompression    := vRESTConnectionDB.Compression;
                vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
                vEncoding       := vRESTConnectionDB.Encoding;
                vAccessTag      := vRESTConnectionDB.AccessTag;
                vDataRoute      := vFailOverConnections[I].vDataRoute;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
              Break;
             End;
           End;
         End;
       End;
     Finally
      If Not Error Then
       MassiveSQLCache.Clear;
//      If Assigned(ResultData) Then
//       If (ResultData.Value <> '') Then
//        MassiveSQLCache.ProcessChanges(ResultData.Value);
      If Assigned(ResultData) Then
       FreeAndNil(ResultData);
      FreeAndNil(vRESTConnectionDB);
     End;
    End;
  End;
End;

Procedure TRESTDWDatabasebaseBase.ApplyUpdates(Datasets               : Array of {$IFDEF FPC}TRESTDWClientSQLBase{$ELSE}TObject{$ENDIF};
                                               Var Error              : Boolean;
                                               Var MessageError       : String);
Var
 vJsonLine,
 vLinesDS             : String;
 vJsonCount,
 I                    : Integer;
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 vJSONValue           : TJSONValue;
 vJsonValueB          : TRESTDWJSONInterfaceBase;
 vJsonArray           : TRESTDWJSONInterfaceArray;
 vJsonOBJ             : TRESTDWJSONInterfaceObject;
 SocketError          : Boolean;
 vStream              : TMemoryStream;
Begin
 vStream := Nil;
 vLinesDS  := '';
 vJsonLine := '';
 For I := 0 To Length(Datasets) -1 Do
  Begin
   vJsonLine := TRESTDWClientSQL(Datasets[I]).UpdateSQL.ToJSON;
   If (vLinesDS = '') And (vJsonLine <> '') Then
    vLinesDS := vJsonLine
   Else If (vJsonLine <> '') Then
    vLinesDS := Format('%s, %s', [vLinesDS, vJsonLine]);
  End;
 If vLinesDS <> '' Then
  vLinesDS := Format('[%s]', [vLinesDS])
 Else
  vLinesDS := '[]';
 vJsonLine := '';
 if vRestPooler = '' then
  Exit;
 vRESTConnectionDB  := BuildConnection(False);
 vRESTConnectionDB.SSLVersions := SSLVersions;
 CopyParams(vRESTConnectionDB, vRESTClientPooler);
 Try
  For I := 0 To 1 Do
   Begin
    vLinesDS := vRESTConnectionDB.ApplyUpdates(vLinesDS, vRestPooler,  vDataRoute,
                                               Error,    MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                               vClientConnectionDefs.vConnectionDefs, vRESTClientPooler);
    If Not(Error) or (MessageError <> cInvalidAuth) Then
     Break
    Else
     Begin
      Case AuthenticationOptions.AuthorizationOption Of
       rdwAOBearer : Begin
                      If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                         TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
       rdwAOToken  : Begin
                      If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                       Begin
                        If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                         TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                        TryConnect(vRESTConnectionDB);
                       End;
                     End;
      End;
     End;
   End;
  If SocketError Then
   Begin
    If vFailOver Then
     Begin
      vLinesDS := '';
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
              (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
              (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
              (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
              (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
              (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
              (vFailOverConnections[I].vDataRoute      = vDataRoute))                        Or
             (Not (vFailOverConnections[I].Active))                                        Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        If Not Assigned(RESTClientPoolerExec) Then
         RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
        RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
        ReconfigureConnection(vRESTConnectionDB,
                              RESTClientPoolerExec,
                              vFailOverConnections[I].vTypeRequest,
                              vFailOverConnections[I].vWelcomeMessage,
                              vFailOverConnections[I].vRestWebService,
                              vFailOverConnections[I].vPoolerPort,
                              vFailOverConnections[I].vCompression,
                              vFailOverConnections[I].EncodeStrings,
                              vFailOverConnections[I].Encoding,
                              vFailOverConnections[I].vAccessTag,
                              vFailOverConnections[I].AuthenticationOptions);
        vLinesDS := vRESTConnectionDB.ApplyUpdates(vLinesDS, vFailOverConnections[I].vRestPooler,  vFailOverConnections[I].vDataRoute,
                                                   Error,    MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                   vClientConnectionDefs.vConnectionDefs);
        If Not SocketError Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vRESTConnectionDB.TypeRequest;
            vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
            vRestWebService := vRESTConnectionDB.Host;
            vPoolerPort     := vRESTConnectionDB.Port;
            vCompression    := vRESTConnectionDB.Compression;
            vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
            vEncoding       := vRESTConnectionDB.Encoding;
            vAccessTag      := vRESTConnectionDB.AccessTag;
            vDataRoute      := vFailOverConnections[I].vDataRoute;
            vRestPooler     := vFailOverConnections[I].vRestPooler;
            vTimeOut        := vFailOverConnections[I].vTimeOut;
            vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
            vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
           End;
          Break;
         End;
       End;
     End;
   End;
  If Not Error Then
   Begin
    vJSONValue := TJSONValue.Create;
    vJSONValue.Encoded  := True;
    vJSONValue.Encoding := vEncoding;
    vJSONValue.LoadFromJSON(vLinesDS);
    vJsonLine := vJSONValue.value;
    FreeAndNil(vJSONValue);
    vJsonOBJ   := TRESTDWJSONInterfaceObject.Create(vJsonLine);
    vJsonArray := TRESTDWJSONInterfaceArray(vJsonOBJ);
    Try
     For I := 0 To vJsonArray.ElementCount -1 do
      Begin
       vJsonValueB  := vJsonArray.GetObject(I);
       vJsonCount := 0;
       vJSONValue := TJSONValue.Create;
       vJSONValue.Utf8SpecialChars := True;
       Try
        vJSONValue.Encoding := vEncoding;
        If Not TRESTDWClientSQL(Datasets[I]).BinaryRequest Then
         Begin
          vJSONValue.LoadFromJSON(TRESTDWJSONInterfaceObject(vJsonValueB).ToJson);
          vJSONValue.Encoded := True;
          vJSONValue.OnWriterProcess := TRESTDWClientSQL(Datasets[I]).OnWriterProcess;
          vJSONValue.ServerFieldList := TRESTDWClientSQL(Datasets[I]).ServerFieldList;
          {$IFDEF RESTDWLAZARUS}
           vJSONValue.DatabaseCharSet := TRESTDWClientSQL(Datasets[I]).DatabaseCharSet;
           vJSONValue.NewFieldList    := @TRESTDWClientSQL(Datasets[I]).NewFieldList;
           vJSONValue.CreateDataSet   := @TRESTDWClientSQL(Datasets[I]).CreateDataSet;
           vJSONValue.NewDataField    := @TRESTDWClientSQL(Datasets[I]).NewDataField;
           vJSONValue.SetInitDataset  := @TRESTDWClientSQL(Datasets[I]).SetInitDataset;
           vJSONValue.SetRecordCount     := @TRESTDWClientSQL(Datasets[I]).SetRecordCount;
           vJSONValue.Setnotrepage       := @TRESTDWClientSQL(Datasets[I]).Setnotrepage;
           vJSONValue.SetInDesignEvents  := @TRESTDWClientSQL(Datasets[I]).SetInDesignEvents;
           vJSONValue.SetInBlockEvents   := @TRESTDWClientSQL(Datasets[I]).SetInBlockEvents;
           vJSONValue.SetInactive        := @TRESTDWClientSQL(Datasets[I]).SetInactive;
           vJSONValue.FieldListCount     := @TRESTDWClientSQL(Datasets[I]).FieldListCount;
           vJSONValue.GetInDesignEvents  := @TRESTDWClientSQL(Datasets[I]).GetInDesignEvents;
           vJSONValue.PrepareDetailsNew  := @TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew;
           vJSONValue.PrepareDetails     := @TRESTDWClientSQL(Datasets[I]).PrepareDetails;
          {$ELSE}
           vJSONValue.NewFieldList    := TRESTDWClientSQL(Datasets[I]).NewFieldList;
           vJSONValue.CreateDataSet   := TRESTDWClientSQL(Datasets[I]).CreateDataSet;
           vJSONValue.NewDataField    := TRESTDWClientSQL(Datasets[I]).NewDataField;
           vJSONValue.SetInitDataset  := TRESTDWClientSQL(Datasets[I]).SetInitDataset;
           vJSONValue.SetRecordCount     := TRESTDWClientSQL(Datasets[I]).SetRecordCount;
           vJSONValue.Setnotrepage       := TRESTDWClientSQL(Datasets[I]).Setnotrepage;
           vJSONValue.SetInDesignEvents  := TRESTDWClientSQL(Datasets[I]).SetInDesignEvents;
           vJSONValue.SetInBlockEvents   := TRESTDWClientSQL(Datasets[I]).SetInBlockEvents;
           vJSONValue.SetInactive        := TRESTDWClientSQL(Datasets[I]).SetInactive;
           vJSONValue.FieldListCount     := TRESTDWClientSQL(Datasets[I]).FieldListCount;
           vJSONValue.GetInDesignEvents  := TRESTDWClientSQL(Datasets[I]).GetInDesignEvents;
           vJSONValue.PrepareDetailsNew  := TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew;
           vJSONValue.PrepareDetails     := TRESTDWClientSQL(Datasets[I]).PrepareDetails;
          {$ENDIF}
          vJSONValue.WriteToDataset(dtDiff, vJSONValue.ToJSON, TRESTDWClientSQL(Datasets[I]),
                                   vJsonCount, TRESTDWClientSQL(Datasets[I]).Datapacks); //TODO Somente esse Registro
          TRESTDWClientSQL(Datasets[I]).vActualJSON := vJSONValue.ToJSON;
         End
        Else
         Begin
          {   //TODO
          vStream := Decodeb64Stream(TRESTDWJSONInterfaceObject(vJsonValueB).pairs[0].value);
          TRESTDWClientSQLBase(Datasets[I]).LoadFromStream(vStream);
          TRESTDWClientSQL(Datasets[I]).DisableControls;
          Try
           TRESTDWClientSQL(Datasets[I]).Last;
           vJsonCount := TRESTDWClientSQLBase(Datasets[I]).RecNo;
           TRESTDWClientSQL(Datasets[I]).First;
          Finally
           TRESTDWClientSQL(Datasets[I]).EnableControls;
           If Assigned(vStream) Then
            vStream.Free;
           If TRESTDWClientSQL(Datasets[I]).State = dsBrowse Then
            Begin
             If TRESTDWClientSQL(Datasets[I]).RecordCount = 0 Then
              TRESTDWClientSQL(Datasets[I]).PrepareDetailsNew
             Else
              TRESTDWClientSQL(Datasets[I]).PrepareDetails(True);
            End;
          End;
          }
         End;
        TRESTDWClientSQL(Datasets[I]).CreateMassiveDataset;
       Finally
        FreeAndNil(vJSONValue);
        FreeAndNil(vJsonValueB);
       End;
      End;
    Finally
     FreeAndNil(vJsonArray);
    End;
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDatabasebaseBase.ApplyUpdates(Var MassiveCache : TRESTDWMassiveCache);
Var
 vError        : Boolean;
 vMessageError : String;
Begin
 vError := False;
 vMessageError := '';
 ApplyUpdates(MassiveCache, vError, vMessageError);
 If (vError) Or (vMessageError <> '') Then
  Raise Exception.Create(PChar(vMessageError));
End;

Procedure TRESTDWDatabasebaseBase.ApplyUpdates(Var MassiveCache       : TRESTDWMassiveCache;
                                               Var Error              : Boolean;
                                               Var MessageError       : String);
Var
 I                    : Integer;
 vUpdateLine          : TStream;
 vRESTConnectionDB    : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 ResultData           : TJSONValue;
 vLocalClient,
 SocketError          : Boolean;
Begin
 vLocalClient := False;
 SocketError := False;
 RESTClientPoolerExec := Nil;
 vUpdateLine          := Nil;
 If MassiveCache.MassiveCount > 0 Then
  Begin
   vUpdateLine := TMemoryStream.Create;
   MassiveCache.SaveToStream(vUpdateLine);
   If vRestPooler = '' Then
    Exit;
   If Not vConnected Then
    SetConnection(True);
   If vConnected Then
    Begin
     vRESTConnectionDB  := BuildConnection(False);
     vRESTConnectionDB.SSLVersions := SSLVersions;
     CopyParams(vRESTConnectionDB, vRESTClientPooler);
     Try
      For I := 0 To 1 Do
       Begin
        ResultData := vRESTConnectionDB.ApplyUpdates_MassiveCache(vUpdateLine, vRestPooler,  vDataRoute,
                                                                  Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                                  vClientConnectionDefs.vConnectionDefs,
                                                                  True,        vRESTClientPooler);
        If Not(Error) or (MessageError <> cInvalidAuth) Then
         Break
        Else
         Begin
          Case AuthenticationOptions.AuthorizationOption Of
           rdwAOBearer : Begin
                          If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                               (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                             TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect(vRESTConnectionDB);
                           End;
                         End;
           rdwAOToken  : Begin
                          If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoRenewToken) Then
                           Begin
                            If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                               (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                             TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                            TryConnect(vRESTConnectionDB);
                           End;
                         End;
          End;
         End;
       End;
      If SocketError Then
       Begin
        If vFailOver Then
         Begin
          If Assigned(ResultData) Then
           FreeAndNil(ResultData);
          For I := 0 To vFailOverConnections.Count -1 Do
           Begin
            If I = 0 Then
             Begin
              If ((vFailOverConnections[I].vTypeRequest    = vRESTConnectionDB.TypeRequest)    And
                  (vFailOverConnections[I].vWelcomeMessage = vRESTConnectionDB.WelcomeMessage) And
                  (vFailOverConnections[I].vRestWebService = vRESTConnectionDB.Host)           And
                  (vFailOverConnections[I].vPoolerPort     = vRESTConnectionDB.Port)           And
                  (vFailOverConnections[I].vCompression    = vRESTConnectionDB.Compression)    And
                  (vFailOverConnections[I].EncodeStrings   = vRESTConnectionDB.EncodeStrings)  And
                  (vFailOverConnections[I].Encoding        = vRESTConnectionDB.Encoding)       And
                  (vFailOverConnections[I].vAccessTag      = vRESTConnectionDB.AccessTag)      And
                  (vFailOverConnections[I].vRestPooler     = vRestPooler)                      And
                  (vFailOverConnections[I].vDataRoute      = vDataRoute))                      Or
                  (Not (vFailOverConnections[I].Active))                                       Then
              Continue;
             End;
            If Assigned(vOnFailOverExecute) Then
             vOnFailOverExecute(vFailOverConnections[I]);
            If Not Assigned(RESTClientPoolerExec) Then
             Begin
              vLocalClient := True;
              RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
             End;
            RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
            ReconfigureConnection(vRESTConnectionDB,
                                  RESTClientPoolerExec,
                                  vFailOverConnections[I].vTypeRequest,
                                  vFailOverConnections[I].vWelcomeMessage,
                                  vFailOverConnections[I].vRestWebService,
                                  vFailOverConnections[I].vPoolerPort,
                                  vFailOverConnections[I].vCompression,
                                  vFailOverConnections[I].EncodeStrings,
                                  vFailOverConnections[I].Encoding,
                                  vFailOverConnections[I].vAccessTag,
                                  vFailOverConnections[I].AuthenticationOptions);
            If Assigned(ResultData) Then
             FreeAndNil(ResultData);
            ResultData := vRESTConnectionDB.ApplyUpdates_MassiveCache(vUpdateLine,
                                                                      vFailOverConnections[I].vRestPooler,
                                                                      vFailOverConnections[I].vDataRoute,
                                                                      Error,       MessageError, SocketError, vTimeOut, vConnectTimeOut,
                                                                      vClientConnectionDefs.vConnectionDefs,
                                                                      True);
            If Not SocketError Then
             Begin
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := vRESTConnectionDB.TypeRequest;
                vWelcomeMessage := vRESTConnectionDB.WelcomeMessage;
                vRestWebService := vRESTConnectionDB.Host;
                vPoolerPort     := vRESTConnectionDB.Port;
                vCompression    := vRESTConnectionDB.Compression;
                vEncodeStrings  := vRESTConnectionDB.EncodeStrings;
                vEncoding       := vRESTConnectionDB.Encoding;
                vAccessTag      := vRESTConnectionDB.AccessTag;
                vDataRoute      := vFailOverConnections[I].vDataRoute;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
              Break;
             End;
           End;
         End;
       End;
     Finally
      MassiveCache.Clear;
      If Assigned(ResultData) Then
       If Not(ResultData.IsNull) Then
        MassiveCache.ProcessChanges(ResultData.Value);
      If Assigned(ResultData) Then
       FreeAndNil(ResultData);
      If Assigned(vUpdateLine) Then
       FreeAndNil(vUpdateLine);
      FreeAndNil(vRESTConnectionDB);
      If Not Error Then
       Error := MessageError <> '';
     End;
    End;
  End;
 If Assigned(RESTClientPoolerExec) And (vLocalClient) Then
  FreeAndNil(RESTClientPoolerExec);
End;

Procedure TRESTDWDatabasebaseBase.Close;
Begin
 SetConnection(False);
End;

Procedure TRESTDWDatabasebaseBase.ReconfigureConnection(Var Connection        : TRESTDWPoolerMethodClient;
                                                        Var ConnectionExec    : TRESTClientPoolerBase;
                                                        TypeRequest           : Ttyperequest;
                                                        WelcomeMessage,
                                                        Host                  : String;
                                                        Port                  : Integer;
                                                        Compression,
                                                        EncodeStrings         : Boolean;
                                                        Encoding              : TEncodeSelect;
                                                        AccessTag             : String;
                                                        AuthenticationOptions : TRESTDWClientAuthOptionParams);
Begin
 Connection.TypeRequest               := TypeRequest;
 Connection.WelcomeMessage            := WelcomeMessage;
 Connection.Host                      := Host;
 Connection.Port                      := Port;
 Connection.Compression               := Compression;
 Connection.EncodeStrings             := EncodeStrings;
 Connection.Encoding                  := Encoding;
 Connection.AccessTag                 := AccessTag;
 If assigned(ConnectionExec) Then
  Begin
   ConnectionExec.Host                  := Connection.Host;
   ConnectionExec.Port                  := Connection.Port;
   ConnectionExec.DataCompression       := Connection.Compression;
   ConnectionExec.TypeRequest           := Connection.TypeRequest;
   ConnectionExec.WelcomeMessage        := Connection.WelcomeMessage;
   ConnectionExec.EncodedStrings        := Connection.EncodeStrings;
   ConnectionExec.SetAccessTag(Connection.AccessTag);
   ConnectionExec.Encoding              := Connection.Encoding;
   ConnectionExec.AuthenticationOptions.Assign(AuthenticationOptions);
   {$IFDEF RESTDWLAZARUS}
    ConnectionExec.DatabaseCharSet := csUndefined;
   {$ENDIF}
  End;
End;

Function  TRESTDWDatabasebaseBase.TryConnect(Connection     : TRESTDWPoolerMethodClient;
                                             aBinaryRequest : Boolean = False) : Boolean;
Var
 vErrorBoolean        : Boolean;
 I                    : Integer;
 vMessageError,
 vToken,
 vTempSend            : String;
 DWParams             : TRESTDWParams;
 Procedure TokenValidade;
 Begin
  DWParams := TRESTDWParams.Create;
  Try
   DWParams.Encoding := Encoding;
   If Connection.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
    Begin
     Case Connection.AuthenticationOptions.AuthorizationOption Of
      rdwAOBearer : Begin
                     If (TRESTDWAuthOptionBearerClient(Connection.AuthenticationOptions.OptionParams).AutoGetToken) And
                        (TRESTDWAuthOptionBearerClient(Connection.AuthenticationOptions.OptionParams).Token = '') Then
                      Begin
                       If Assigned(OnBeforeGetToken) Then
                        OnBeforeGetToken(Connection.WelcomeMessage,
                                         Connection.AccessTag, DWParams);
                       vToken :=  RenewToken(Connection, DWParams, vErrorBoolean, vMessageError);
                       If Not vErrorBoolean Then
                        TRESTDWAuthOptionBearerClient(Connection.AuthenticationOptions.OptionParams).Token := vToken;
                      End;
                    End;
      rdwAOToken  : Begin
                     If (TRESTDWAuthOptionTokenClient(Connection.AuthenticationOptions.OptionParams).AutoGetToken) And
                        (TRESTDWAuthOptionTokenClient(Connection.AuthenticationOptions.OptionParams).Token = '') Then
                      Begin
                       If Assigned(OnBeforeGetToken) Then
                        OnBeforeGetToken(Connection.WelcomeMessage,
                                         Connection.AccessTag, DWParams);
                       vToken :=  RenewToken(Connection, DWParams, vErrorBoolean, vMessageError);
                       If Not vErrorBoolean Then
                        TRESTDWAuthOptionTokenClient(Connection.AuthenticationOptions.OptionParams).Token := vToken;
                      End;
                    End;
     End;
     If Assigned(vRESTClientPooler) Then
      vRESTClientPooler.AuthenticationOptions.Assign(AuthenticationOptions);
    End;
  Finally
   FreeAndNil(DWParams);
  End;
 End;
Begin
 vErrorBoolean                := False;
 vMessageError                := '';
 Try
  Try
   If Assigned(vRESTClientPooler) Then
    vRESTClientPooler.AuthenticationOptions.Assign(AuthenticationOptions);
   vRESTClientPooler.BinaryRequest := aBinaryRequest;
   Connection.BinaryRequest        := vRESTClientPooler.BinaryRequest;
   TokenValidade;
   If Not(vErrorBoolean) Then
    If vIgnoreEchoPooler Then
     vTempSend := '127.0.0.1'
    else
     vTempSend  := Connection.EchoPooler(vDataRoute, vRestPooler, vTimeOut, vConnectTimeOut, vRESTClientPooler);
   Result      := Trim(vTempSend) <> '';
   If Result Then
    vMyIP       := vTempSend
   Else
    vMyIP       := '';
   If csDesigning in ComponentState Then
    If Not Result Then Raise Exception.Create(PChar(cAuthenticationError));
   If Trim(vMyIP) = '' Then
    Begin
     Result      := False;
     If vFailOver Then
      Begin
       If vFailOverConnections.Count = 0 Then
        Begin
         Result      := False;
         vMyIP       := '';
         If csDesigning in ComponentState Then
          Raise Exception.Create(PChar(cInvalidConnection));
         If Assigned(vOnEventConnection) Then
          vOnEventConnection(False, cInvalidConnection)
         Else
          Raise Exception.Create(cInvalidConnection);
        End
       Else
        Begin
         For I := 0 To vFailOverConnections.Count -1 Do
          Begin
           If I = 0 Then
            Begin
             If ((vFailOverConnections[I].vTypeRequest    = Connection.TypeRequest)    And
                 (vFailOverConnections[I].vWelcomeMessage = Connection.WelcomeMessage) And
                 (vFailOverConnections[I].vRestWebService = Connection.Host)           And
                 (vFailOverConnections[I].vPoolerPort     = Connection.Port)           And
                 (vFailOverConnections[I].vCompression    = Connection.Compression)    And
                 (vFailOverConnections[I].EncodeStrings   = Connection.EncodeStrings)  And
                 (vFailOverConnections[I].Encoding        = Connection.Encoding)       And
                 (vFailOverConnections[I].vAccessTag      = Connection.AccessTag)      And
                 (vFailOverConnections[I].vRestPooler     = vRestPooler)               And
                 (vFailOverConnections[I].vDataRoute      = vDataRoute))               Or
               (Not (vFailOverConnections[I].Active))                                  Then
             Continue;
            End;
           If Assigned(vOnFailOverExecute) Then
            vOnFailOverExecute(vFailOverConnections[I]);
           ReconfigureConnection(Connection,
                                 vRESTClientPooler,
                                 vFailOverConnections[I].vTypeRequest,
                                 vFailOverConnections[I].vWelcomeMessage,
                                 vFailOverConnections[I].vRestWebService,
                                 vFailOverConnections[I].vPoolerPort,
                                 vFailOverConnections[I].vCompression,
                                 vFailOverConnections[I].EncodeStrings,
                                 vFailOverConnections[I].Encoding,
                                 vFailOverConnections[I].vAccessTag,
                                 vFailOverConnections[I].AuthenticationOptions);
           Try
            TokenValidade;
            If Not(vErrorBoolean) Then
             If vIgnoreEchoPooler Then
              vTempSend := '127.0.0.1'
             else
              vTempSend   := Connection.EchoPooler(vFailOverConnections[I].vDataRoute,
                                                   vFailOverConnections[I].vRestPooler,
                                                   vFailOverConnections[I].vTimeOut,
                                                   vFailOverConnections[I].vConnectTimeOut,
                                                   vRESTClientPooler);
            Result      := Trim(vTempSend) <> '';
            If Result Then
             Begin
              vMyIP     := vTempSend;
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := Connection.TypeRequest;
                vWelcomeMessage := Connection.WelcomeMessage;
                vRestWebService := Connection.Host;
                vPoolerPort     := Connection.Port;
                vCompression    := Connection.Compression;
                vEncodeStrings  := Connection.EncodeStrings;
                vEncoding       := Connection.Encoding;
                vAccessTag      := Connection.AccessTag;
                vDataRoute      := vFailOverConnections[I].vDataRoute;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
             End
            Else
             vMyIP       := '';
            If csDesigning in ComponentState Then
             If Not Result Then Raise Exception.Create(PChar(cAuthenticationError));
            If Trim(vMyIP) = '' Then
             Begin
              If Assigned(vOnFailOverError) Then
               vOnFailOverError(vFailOverConnections[I], cAuthenticationError);
             End
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
      End
     Else
      Begin
       If Assigned(vOnEventConnection) Then
        vOnEventConnection(False, cAuthenticationError);
       // Eloy
       If vErrorBoolean then
        raise Exception.Create(vMessageError);
      End;
    End;
  Except
   On E : Exception do
    Begin
     If vFailOver Then
      Begin
       If vFailOverConnections.Count > 0 Then
        Begin
         If Assigned(vFailOverConnections) Then
         For I := 0 To vFailOverConnections.Count -1 Do
          Begin
           If I = 0 Then
            Begin
             If ((vFailOverConnections[I].vTypeRequest    = Connection.TypeRequest)    And
                 (vFailOverConnections[I].vWelcomeMessage = Connection.WelcomeMessage) And
                 (vFailOverConnections[I].vRestWebService = Connection.Host)           And
                 (vFailOverConnections[I].vPoolerPort     = Connection.Port)           And
                 (vFailOverConnections[I].vCompression    = Connection.Compression)    And
                 (vFailOverConnections[I].EncodeStrings   = Connection.EncodeStrings)  And
                 (vFailOverConnections[I].Encoding        = Connection.Encoding)       And
                 (vFailOverConnections[I].vAccessTag      = Connection.AccessTag)      And
                 (vFailOverConnections[I].vRestPooler     = vRestPooler)               And
                 (vFailOverConnections[I].vDataRoute      = vDataRoute))               Or
                 (Not (vFailOverConnections[I].Active))                                Then
             Continue;
            End;
           If Assigned(vOnFailOverExecute) Then
            vOnFailOverExecute(vFailOverConnections[I]);
           ReconfigureConnection(Connection,
                                 vRESTClientPooler,
                                 vFailOverConnections[I].vTypeRequest,
                                 vFailOverConnections[I].vWelcomeMessage,
                                 vFailOverConnections[I].vRestWebService,
                                 vFailOverConnections[I].vPoolerPort,
                                 vFailOverConnections[I].vCompression,
                                 vFailOverConnections[I].EncodeStrings,
                                 vFailOverConnections[I].Encoding,
                                 vFailOverConnections[I].vAccessTag,
                                 vFailOverConnections[I].AuthenticationOptions);
           Try
            TokenValidade;
            If Not(vErrorBoolean) Then
             If vIgnoreEchoPooler Then
              vTempSend := '127.0.0.1'
             else
              vTempSend   := Connection.EchoPooler(vFailOverConnections[I].vDataRoute,
                                                   vFailOverConnections[I].vRestPooler,
                                                   vFailOverConnections[I].vTimeOut,
                                                   vFailOverConnections[I].vConnectTimeOut,
                                                   vRESTClientPooler);
            Result      := Trim(vTempSend) <> '';
            If Result Then
             Begin
              vMyIP       := vTempSend;
              If vFailOverReplaceDefaults Then
               Begin
                vTypeRequest    := Connection.TypeRequest;
                vWelcomeMessage := Connection.WelcomeMessage;
                vRestWebService := Connection.Host;
                vPoolerPort     := Connection.Port;
                vCompression    := Connection.Compression;
                vEncodeStrings  := Connection.EncodeStrings;
                vEncoding       := Connection.Encoding;
                vAccessTag      := Connection.AccessTag;
                vDataRoute      := vFailOverConnections[I].vDataRoute;
                vRestPooler     := vFailOverConnections[I].vRestPooler;
                vTimeOut        := vFailOverConnections[I].vTimeOut;
                vConnectTimeOut := vFailOverConnections[I].vConnectTimeOut;
                vAuthOptionParams.Assign(vFailOverConnections[I].AuthenticationOptions);
               End;
             End
            Else
             vMyIP       := '';
            If csDesigning in ComponentState Then
             If Not Result Then Raise Exception.Create(PChar(cAuthenticationError));
            If Trim(vMyIP) = '' Then
             Begin
              If Assigned(vOnFailOverError) Then
               vOnFailOverError(vFailOverConnections[I], cAuthenticationError);
             End
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
         Result      := False;
         vMyIP       := '';
         If csDesigning in ComponentState Then
          Raise Exception.Create(PChar(E.Message));
         If Assigned(vOnEventConnection) Then
          vOnEventConnection(False, E.Message)
         Else
          Raise Exception.Create(E.Message);
        End;
      End
     Else
      Begin
       Result      := False;
       vMyIP       := '';
       If csDesigning in ComponentState Then
        Raise Exception.Create(PChar(E.Message));
       If Assigned(vOnEventConnection) Then
        vOnEventConnection(False, E.Message)
       Else
        Raise Exception.Create(E.Message);
      End;
    End;
  End;
 Finally
  //DestroyComponents;
 End;
End;

Procedure TRESTDWDatabasebaseBase.CopyParams(ConnectionDB         : TRESTDWPoolerMethodClient;
                                             Var RESTClientPooler : TRESTClientPoolerBase);
Begin
 If Assigned(RESTClientPooler) And
    Assigned(ConnectionDB)     Then
  Begin
   RESTClientPooler.Host            := ConnectionDB.Host;
   RESTClientPooler.Port            := ConnectionDB.Port;
   RESTClientPooler.Accept          := ConnectionDB.Accept;
   RESTClientPooler.AcceptEncoding  := ConnectionDB.AcceptEncoding;
   RESTClientPooler.AccessTag       := ConnectionDB.AccessTag;
   RESTClientPooler.ContentType     := ConnectionDB.ContentType;
   RESTClientPooler.TypeRequest     := ConnectionDB.TypeRequest;
   RESTClientPooler.ContentEncoding := ConnectionDB.ContentEncoding;
   RESTClientPooler.AuthenticationOptions.Assign(ConnectionDB.AuthenticationOptions);
   RESTClientPooler.SSLVersions     := ConnectionDB.SSLVersions;
   RESTClientPooler.UseSSL          := UseSSL;
   RESTClientPooler.WelcomeMessage  := ConnectionDB.WelcomeMessage;
  End;
End;

Function TRESTDWDatabasebaseBase.BuildConnection(aBinaryRequest : Boolean) : TRESTDWPoolerMethodClient;
Begin
 Result                       := nil;

 if Assigned(vOnBuildConnection) then
  vOnBuildConnection(Self);

 Result                       := TRESTDWPoolerMethodClient.Create(Nil);
 Result.PoolerNotFoundMessage := PoolerNotFoundMessage;
 Result.AuthenticationOptions.Assign(AuthenticationOptions);
 Result.HandleRedirects       := HandleRedirects;
 Result.BinaryRequest         := aBinaryRequest;
 Result.RedirectMaximum       := RedirectMaximum;
 Result.UserAgent             := UserAgent;
 Result.WelcomeMessage        := WelcomeMessage;
 Result.Host                  := PoolerService;
 Result.Port                  := PoolerPort;
 Result.Compression           := Compression;
 Result.TypeRequest           := TypeRequest;
 Result.Encoding              := Encoding;
 Result.EncodeStrings         := EncodedStrings;
 Result.OnWork                := OnWork;
 Result.OnWorkBegin           := OnWorkBegin;
 Result.OnWorkEnd             := OnWorkEnd;
 Result.OnStatus              := OnStatus;
 Result.AccessTag             := AccessTag;
 Result.CriptOptions.Use      := CriptOptions.Use;
 Result.CriptOptions.Key      := CriptOptions.Key;
 Result.DataRoute             := DataRoute;
 Result.Accept                := Accept;
 Result.AcceptEncoding        := AcceptEncoding;
 Result.ContentType           := ContentType;
 Result.ContentEncoding       := ContentEncoding;
 {$IFDEF RESTDWLAZARUS}
  Result.DatabaseCharSet      := csUndefined;
 {$ENDIF}
End;

Procedure TRESTDWDatabasebaseBase.SetConnection(Value          : Boolean;
                                                aBinaryRequest : Boolean = False);
Var
 vRESTConnectionDB : TRESTDWPoolerMethodClient;
Begin
 vRESTConnectionDB := nil;

 If (csLoading in ComponentState) then
  Value := False;
 If (Value) And Not(vConnected) then
  If Assigned(vOnBeforeConnection) Then
   vOnBeforeConnection(Self);
 If Not(vConnected) And (Value) Then
  Begin
   If Value then
    Begin
     Try
      vRESTConnectionDB := BuildConnection(aBinaryRequest);
      vRESTConnectionDB.SSLVersions := SSLVersions;
      CopyParams(vRESTConnectionDB, vRESTClientPooler);
      vConnected := TryConnect(vRESTConnectionDB, aBinaryRequest);
     Finally
      If Assigned(vRESTConnectionDB) Then
       FreeAndNil(vRESTConnectionDB);
     End;
    End
   Else
    vMyIP := '';
  End
 Else If Not (Value) Then
  Begin
   vConnected := Value;
   vMyIP := '';
   If (Assigned(vAuthOptionParams)) and
      (vAuthOptionParams.AuthorizationOption in [rdwAOBearer, rdwAOToken]) Then
    Begin
     Case vAuthOptionParams.AuthorizationOption Of
      rdwAOBearer : TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Token := '';
      rdwAOToken  : TRESTDWAuthOptionTokenClient (vAuthOptionParams.OptionParams).Token := '';
     End;
    End;
  End;
End;

Procedure TRESTDWDatabasebaseBase.SetConnectionProp(Value : Boolean);
Begin
 SetConnection(Value, False);
End;

Procedure TRESTDWDatabasebaseBase.SetDataRoute(Value: String);
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

procedure TRESTDWDatabasebaseBase.SetIpVersion(IpV: TRESTDWClientIpVersions);
begin
 vClientIpVersion := IpV;

 if Assigned(RESTClientPooler) then
  RESTClientPooler.ClientIpVersion := IpV;

end;

Procedure TRESTDWDatabasebaseBase.SetPoolerPort(Value : Integer);
Begin
 vPoolerPort := Value;
End;

Procedure TRESTDWDatabasebaseBase.SetRestPooler(Value : String);
Begin
 vRestPooler := Value;
End;

procedure TRESTDWTable.SetDataBase(Value: TRESTDWDatabasebaseBase);
Begin
 If Value is TRESTDWDatabasebaseBase Then
  Begin
   vRESTDataBase   := Value;
   TMassiveDatasetBuffer(vMassiveDataset).Encoding := TRESTDWDatabasebaseBase(Value).Encoding;
  End
 Else
  vRESTDataBase := Nil;
End;

procedure TRESTDWClientSQL.SetDataBase(Value: TRESTDWDatabasebaseBase);
Begin
 If Value is TRESTDWDatabasebaseBase Then
  Begin
   vRESTDataBase   := Value;
   TMassiveDatasetBuffer(vMassiveDataset).Encoding := TRESTDWDatabasebaseBase(Value).Encoding;
  End
 Else
  vRESTDataBase := Nil;
End;

Procedure TRESTDWTable.SetDatapacks(Value: Integer);
Begin
 vDatapacks := Value;
 If vDatapacks = 0 Then
  vDatapacks := -1;
End;

Procedure TRESTDWClientSQL.SetDatapacks(Value: Integer);
Begin
 vDatapacks := Value;
 If vDatapacks = 0 Then
  vDatapacks := -1;
End;

Function TRESTDWClientSQL.GetReadData : Boolean;
Begin
 Result := vReadData;
End;

Procedure TRESTDWClientSQL.SetDWResponseTranslator(Const Value : TRESTDWResponseTranslator);
Begin
 If vDWResponseTranslator <> Value then
  vDWResponseTranslator := Value;
 If vDWResponseTranslator <> nil then
  vDWResponseTranslator.FreeNotification(Self);
End;

Procedure TRESTDWTable.SetDWResponseTranslator(Const Value : TRESTDWResponseTranslator);
Begin
 If vDWResponseTranslator <> Value then
  vDWResponseTranslator := Value;
 If vDWResponseTranslator <> nil then
  vDWResponseTranslator.FreeNotification(Self);
End;

Procedure TRESTDWTable.SetFilteredB(aValue: Boolean);
Var
 vFilter   : String;
Begin
 vFiltered := aValue;
 vFilter   := Filter;
 If Assigned(vOnFiltered) Then
  vOnFiltered(vFiltered, vFilter);
 TDataset(Self).Filter   := vFilter;
 TDataset(Self).Filtered := vFiltered;
 If vFiltered Then
  ProcAfterScroll(Self);
End;

Procedure TRESTDWClientSQL.SetFilteredB(aValue: Boolean);
Var
 vFilter   : String;
Begin
 vFiltered := aValue;
 vFilter   := Filter;
 If Assigned(vOnFiltered) Then
  vOnFiltered(vFiltered, vFilter);
 TDataset(Self).Filter   := vFilter;
 TDataset(Self).Filtered := vFiltered;
 If vFiltered Then
  ProcAfterScroll(Self);
End;

procedure TRESTDWTable.SetInBlockEvents(const Value: Boolean);
begin
 vInBlockEvents := Value;
end;

procedure TRESTDWClientSQL.SetInBlockEvents(const Value: Boolean);
begin
 vInBlockEvents := Value;
end;

procedure TRESTDWTable.SetInDesignEvents(const Value: Boolean);
begin
 vInDesignEvents := Value;
end;

procedure TRESTDWClientSQL.SetInDesignEvents(const Value: Boolean);
begin
 vInDesignEvents := Value;
end;

procedure TRESTDWTable.SetInitDataset(const Value: Boolean);
begin
 vInitDataset := Value;
end;

procedure TRESTDWClientSQL.SetInitDataset(const Value: Boolean);
begin
 vInitDataset := Value;
end;

Function TRESTDWUpdateSQL.ToJSON       : String;
Var
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
   vDWParams     := GeTRESTDWParams(vMassiveCacheSQLList[A].Params, vEncoding);
   If Assigned(vDWParams) Then
    vParamsString := EncodeStrings(vDWParams.ToJSON{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
   vTempJSON  := Format(cJSONValue, [MassiveSQLMode(msqlExecute),
                                     EncodeStrings(vMassiveCacheSQLList[A].SQL.Text{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                                     vParamsString,
                                     EncodeStrings(vMassiveCacheSQLList[A].Bookmark{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                                     BooleanToString(vMassiveCacheSQLList[A].BinaryRequest),
                                     EncodeStrings(vMassiveCacheSQLList[A].FetchRowSQL.Text{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}),
                                     EncodeStrings(vMassiveCacheSQLList[A].LockSQL.Text{$IFDEF RESTDWLAZARUS},     csUndefined{$ENDIF}),
                                     EncodeStrings(vMassiveCacheSQLList[A].UnlockSQL.Text{$IFDEF RESTDWLAZARUS},   csUndefined{$ENDIF})]);
   If vJSONValue = '' Then
    vJSONValue := vTempJSON
   Else
    vJSONValue := vJSONValue + ', ' + vTempJSON;
  End;
 If vJSONValue <> '' Then
  Result       := Format('[%s]', [vJSONValue]);
End;

Function  TRESTDWUpdateSQL.getClientSQLB       : TRESTDWClientSQLBase;
Begin
 Result := vClientSQLBase;
End;

Procedure TRESTDWUpdateSQL.SetSQLDelete (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLDelete.Clear;
 For I := 0 To Value.Count -1 do
  vSQLDelete.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLInsert (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLInsert.Clear;
 For I := 0 To Value.Count -1 do
  vSQLInsert.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLLock   (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLLock.Clear;
 For I := 0 To Value.Count -1 do
  vSQLLock.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLUnlock (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLUnlock.Clear;
 For I := 0 To Value.Count -1 do
  vSQLUnlock.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLRefresh(Value : TStringList);
Var
 I : Integer;
Begin
 vSQLRefresh.Clear;
 For I := 0 To Value.Count -1 do
  vSQLRefresh.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.SetSQLUpdate (Value : TStringList);
Var
 I : Integer;
Begin
 vSQLUpdate.Clear;
 For I := 0 To Value.Count -1 do
  vSQLUpdate.Add(Value[I]);
End;

Procedure TRESTDWUpdateSQL.setClientSQLB(Value : TRESTDWClientSQLBase);
Begin
 If Value is TRESTDWClientSQL Then
  Begin
   If Assigned(vClientSQLBase) Then
    TRESTDWClientSQL(vClientSQLBase).UpdateSQL := Nil;
   vClientSQLBase := Value;
   TRESTDWClientSQL (vClientSQLBase).UpdateSQL := Self;
  End
 Else If Value is TRESTDWTable Then
  Begin
   If Assigned(vClientSQLBase) Then
    TRESTDWTable(vClientSQLBase).UpdateSQL := Nil;
   vClientSQLBase := Value;
   TRESTDWTable (vClientSQLBase).UpdateSQL := Self;
  End
 Else If Value is TRESTDWStoredProcedure Then
  Begin
   If Assigned(vClientSQLBase) Then
    TRESTDWStoredProcedure(vClientSQLBase).UpdateSQL := Nil;
   vClientSQLBase := Value;
   TRESTDWStoredProcedure (vClientSQLBase).UpdateSQL := Self;
  End
 Else
  Begin
   If Assigned(vClientSQLBase) Then
    TRESTDWClientSQL(vClientSQLBase).UpdateSQL := Nil;
   vClientSQLBase := Nil;
  End;
End;

Function TRESTDWUpdateSQL.GetVersionInfo : String;
Begin
 Result := Format('%s%s', [RESTDWVersionINFO, RESTDWRelease]);
End;

Function TRESTDWUpdateSQL.MassiveCount : Integer;
Begin
 Result := vMassiveCacheSQLList.Count;
End;

Procedure TRESTDWUpdateSQL.Store(SQL           : String;
                                 Dataset       : TDataset;
                                 DeleteCommand : Boolean = False);
Var
 I                     : Integer;
 vMassiveCacheSQLValue : TRESTDWMassiveCacheSQLValue;
Begin
 If Not Dataset.IsEmpty Then
  Begin
   vMassiveCacheSQLValue                   := TRESTDWMassiveCacheSQLValue(vMassiveCacheSQLList.Add);
   vMassiveCacheSQLValue.MassiveSQLMode    := msqlExecute;
   vMassiveCacheSQLValue.SQL.Text          := SQL;
   If Not (DeleteCommand) Then
    vMassiveCacheSQLValue.FetchRowSQL.Text := vSQLRefresh.Text
   Else
    vMassiveCacheSQLValue.FetchRowSQL.Text := '';
   vMassiveCacheSQLValue.LockSQL.Text      := vSQLLock.Text;
   vMassiveCacheSQLValue.UnlockSQL.Text    := vSQLUnlock.Text;
   For I := 0 To vMassiveCacheSQLValue.Params.Count -1 Do
    Begin
     If TRESTDWClientSQL(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name) <> Nil Then
      vMassiveCacheSQLValue.Params[I].AssignField(TRESTDWClientSQL(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name)); // .AssignValues(TRESTDWClientSQL(Dataset).Params);
    End;
  End;
End;

Procedure TRESTDWUpdateSQL.Notification(AComponent : TComponent;
                                        Operation  : TOperation);
Begin
 If (Operation = opRemove) and (AComponent = vClientSQLBase) Then
  vClientSQLBase := Nil;
 Inherited Notification(AComponent, Operation);
End;

procedure TRESTDWUpdateSQL.Clear;
begin
 vMassiveCacheSQLList.Clear;
end;

Destructor  TRESTDWUpdateSQL.Destroy;
Begin
 FreeAndNil(vMassiveCacheSQLList);
 FreeAndNil(vSQLInsert);
 FreeAndNil(vSQLDelete);
 FreeAndNil(vSQLUpdate);
 FreeAndNil(vSQLRefresh);
 FreeAndNil(vSQLLock);
 FreeAndNil(vSQLUnlock);
 Inherited;
End;

Constructor TRESTDWUpdateSQL.Create    (AOwner : TComponent);
Begin
 Inherited;
 vClientSQLBase := Nil;
 {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
 vEncoding         := esUtf8;
 {$ELSE}
 vEncoding         := esAscii;
 {$IFEND}
 vMassiveCacheSQLList := TRESTDWMassiveCacheSQLList.Create(Self, TRESTDWMassiveCacheSQLValue);
 vSQLInsert           := TStringList.Create;
 vSQLDelete           := TStringList.Create;
 vSQLUpdate           := TStringList.Create;
 vSQLRefresh          := TStringList.Create;
 vSQLLock             := TStringList.Create;
 vSQLUnlock           := TStringList.Create;
End;

Procedure TRESTDWUpdateSQL.SetClientSQL(Value  : TRESTDWClientSQLBase);
Begin
 If (Assigned(vClientSQLBase)) And
    (vClientSQLBase <> Value)  And
    (Value <> Nil)             Then
  Begin
   If vClientSQLBase.ClassType     = TRESTDWClientSQL Then
    TRESTDWClientSQL(vClientSQLBase).UpdateSQL := Nil
   Else If vClientSQLBase.ClassType = TRESTDWStoredProcedure Then
    TRESTDWStoredProcedure(vClientSQLBase).UpdateSQL := Nil;
  End;
 vClientSQLBase := Value;
End;
Procedure TRESTDWTable.SetUpdateSQL(Value : TRESTDWUpdateSQL);
Begin
 If (Assigned(vUpdateSQL)) And
    (vUpdateSQL <> Value)  Then
  Begin
   vUpdateSQL.SetClientSQL(Nil);
   vUpdateSQL := Nil;
  End;
 If vUpdateSQL <> Value Then
  vUpdateSQL := Value;
 If vUpdateSQL <> Nil   Then
  Begin
   SetMassiveCache(Nil);
   vUpdateSQL.SetClientSQL(Self);
   vUpdateSQL.FreeNotification(Self);
  End;
End;

Procedure TRESTDWClientSQL.SetUpdateSQL(Value : TRESTDWUpdateSQL);
Begin
 If (Assigned(vUpdateSQL)) And
    (vUpdateSQL <> Value)  Then
  Begin
   vUpdateSQL.SetClientSQL(Nil);
   vUpdateSQL := Nil;
  End;
 If vUpdateSQL <> Value Then
  vUpdateSQL := Value;
 If vUpdateSQL <> Nil   Then
  Begin
   SetMassiveCache(Nil);
   vUpdateSQL.SetClientSQL(Self);
   vUpdateSQL.FreeNotification(Self);
  End;
End;

Function TRESTDWTable.GetUpdateSQL : TRESTDWUpdateSQL;
Begin
 Result := vUpdateSQL;
End;

Function TRESTDWClientSQL.GetUpdateSQL : TRESTDWUpdateSQL;
Begin
 Result := vUpdateSQL;
End;

Procedure TRESTDWTable.SetMassiveCache(Const Value : TRESTDWMassiveCache);
Begin
 If vMassiveCache <> Value Then
  Begin
   If (Value = Nil) Then
    vMassiveCache.Clear;
   vMassiveCache := Value;
  End;
 If vMassiveCache <> Nil Then
  Begin
   SetUpdateSQL(Nil);
   vMassiveCache.FreeNotification(Self);
  End;
End;

Procedure TRESTDWClientSQL.SetMassiveCache(Const Value : TRESTDWMassiveCache);
Begin
 If vMassiveCache <> Value Then
  Begin
   If (Value = Nil) Then
    vMassiveCache.Clear;
   vMassiveCache := Value;
  End;
 If vMassiveCache <> Nil Then
  Begin
   SetUpdateSQL(Nil);
   vMassiveCache.FreeNotification(Self);
  End;
End;

procedure TRESTDWTable.SetMasterDataSet(Value: TRESTDWClientSQLBase);
Begin
 If (vMasterDataSet <> Nil) Then
  TRESTDWTable(vMasterDataSet).vMasterDetailList.DeleteDS(TRESTClient(Self));
 If (Value = Self) And (Value <> Nil) Then
  Begin
   vMasterDataSet := Nil;
   MasterFields   := '';
   Exit;
  End;
 vMasterDataSet := Value;
 If (vMasterDataSet <> Nil) Then
  Begin
   If vMasterDetailItem = Nil Then
    FreeAndNil(vMasterDetailItem);
   vMasterDetailItem    := TMasterDetailItem.Create;
   vMasterDetailItem.DataSet := TRESTClient(Self);
   TRESTDWTable(vMasterDataSet).vMasterDetailList.Add(vMasterDetailItem);
   vDataSource.DataSet := Value;
  End
 Else
  Begin
   MasterFields := '';
  End;
End;

procedure TRESTDWClientSQL.SetMasterDataSet(Value: TRESTDWClientSQL);
Begin
 If (vMasterDataSet <> Nil) Then
  TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(TRESTClient(Self));
 If (Value = Self) And (Value <> Nil) Then
  Begin
   vMasterDataSet := Nil;
   MasterFields   := '';
   Exit;
  End;
 vMasterDataSet := Value;
 If (vMasterDataSet <> Nil) Then
  Begin
   If vMasterDetailItem = Nil Then
    FreeAndNil(vMasterDetailItem);
//    Begin
   vMasterDetailItem    := TMasterDetailItem.Create;
   vMasterDetailItem.DataSet := TRESTClient(Self);
   TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.Add(vMasterDetailItem);
//    End;
   vDataSource.DataSet := Value;
  End
 Else
  Begin
   MasterFields := '';
  End;
End;

Procedure TRESTDWTable.Setnotrepage(Value: Boolean);
Begin
 vNotRepage := Value;
End;

Procedure TRESTDWClientSQL.Setnotrepage(Value: Boolean);
Begin
 vNotRepage := Value;
End;

Procedure TRESTDWTable.SetParams(const Value: TParams);
begin
 vParams.Assign(Value);
end;

procedure TRESTDWClientSQL.SetParams(const Value: TParams);
begin
 vParams.Assign(Value);
end;

Procedure TRESTDWTable.SetRecordCount(aJsonCount, aRecordCount : Integer);
begin
 vJsonCount      := aJsonCount;
 vOldRecordCount := aRecordCount;
end;

Procedure TRESTDWClientSQL.SetRecordCount(aJsonCount, aRecordCount : Integer);
begin
 vJsonCount      := aJsonCount;
 vOldRecordCount := aRecordCount;
end;

Procedure TRESTDWClientSQL.SetReflectChanges(Value: Boolean);
Begin
 vReflectChanges := Value;
 If Value Then
  vAutoRefreshAfterCommit := False;
 TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges := vReflectChanges;
End;

Constructor TRESTDWTable.Create(AOwner: TComponent);
Begin
 Inherited;
 vJsonCount                        := 0;
 vRowsAffected                     := 0;
 vOldRecordCount                   := -1;
 vActualJSON                       := '';
 vMassiveMode                      := mtMassiveCache;
 vFiltered                         := False;
 vBinaryRequest                    := False;
 vInitDataset                      := False;
 vOnPacks                          := False;
 vInternalLast                     := False;
 vNotRepage                        := False;
 vInactive                         := False;
 vInBlockEvents                    := False;
 vOnOpenCursor                     := False;
 vDataCache                        := False;
 vAutoCommitData                   := False;
 vAutoRefreshAfterCommit           := False;
 vFiltered                         := False;
 OnLoadStream                      := False;
 vRaiseError                       := True;
 vConnectedOnce                    := True;
 GetNewData                        := True;
 vActive                           := False;
 vCacheUpdateRecords               := True;
 vBeforeClone                      := False;
 vReadData                         := False;
 vActiveCursor                     := False;
 vInDesignEvents                   := False;
 vDatapacks                        := -1;
 vCascadeDelete                    := True;
 vRelationFields                   := TStringList.Create;
 vParams                           := TParams.Create(Self);
 vTableName                        := '';
 FieldDefsUPD                      := TFieldDefs.Create(Self);
 FieldDefs                         := FieldDefsUPD;
 vMasterDetailList                 := TMasterDetailList.Create;
 vMasterDataSet                    := Nil;
 vDataSource                       := TDataSource.Create(Nil);
 {$IFDEF RESTDWLAZARUS}
 TDataset(Self).AfterScroll        := @ProcAfterScroll;
 TDataset(Self).BeforeScroll       := @ProcBeforeScroll;
 TDataset(Self).BeforeOpen         := @ProcBeforeOpen;
 TDataset(Self).AfterOpen          := @ProcAfterOpen;
 TDataset(Self).BeforeClose        := @ProcBeforeClose;
 TDataset(Self).AfterClose         := @ProcAfterClose;
 TDataset(Self).BeforeRefresh      := @ProcBeforeRefresh;
 TDataset(Self).AfterRefresh       := @ProcAfterRefresh;
 TDataset(Self).BeforeInsert       := @ProcBeforeInsert;
 TDataset(Self).AfterInsert        := @ProcAfterInsert;
 TDataset(Self).BeforeEdit         := @ProcBeforeEdit;
 TDataset(Self).AfterEdit          := @ProcAfterEdit;
 TDataset(Self).BeforePost         := @ProcBeforePost;
 TDataset(Self).AfterCancel        := @ProcAfterCancel;
 TDataset(Self).BeforeDelete       := @ProcBeforeDelete;
 TDataset(Self).OnNewRecord        := @ProcNewRecord;
 TDataset(Self).OnCalcFields       := @ProcCalcFields;
// TDataset(Self).Last               := @Last;
 Inherited AfterPost               := @OldAfterPost;
 Inherited AfterDelete             := @OldAfterDelete;
 {$ELSE}
 TDataset(Self).AfterScroll        := ProcAfterScroll;
 TDataset(Self).BeforeScroll       := ProcBeforeScroll;
 TDataset(Self).BeforeOpen         := ProcBeforeOpen;
 TDataset(Self).AfterOpen          := ProcAfterOpen;
 TDataset(Self).BeforeClose        := ProcBeforeClose;
 TDataset(Self).AfterClose         := ProcAfterClose;
 TDataset(Self).BeforeRefresh      := ProcBeforeRefresh;
 TDataset(Self).AfterRefresh       := ProcAfterRefresh;
 TDataset(Self).BeforeInsert       := ProcBeforeInsert;
 TDataset(Self).AfterInsert        := ProcAfterInsert;
 TDataset(Self).BeforeEdit         := ProcBeforeEdit;
 TDataset(Self).AfterEdit          := ProcAfterEdit;
 TDataset(Self).BeforePost         := ProcBeforePost;
 TDataset(Self).BeforeDelete       := ProcBeforeDelete;
 TDataset(Self).AfterCancel        := ProcAfterCancel;
 TDataset(Self).OnNewRecord        := ProcNewRecord;
 TDataset(Self).OnCalcFields       := ProcCalcFields;
 Inherited AfterPost               := OldAfterPost;
 Inherited AfterDelete             := OldAfterDelete;
 {$ENDIF}
 vMassiveDataset                   := TMassiveDatasetBuffer.Create(Self);
// vActionCursor                     := crHourGlass;
 vUpdateSQL                        := Nil;
 SetComponentTAG;
End;


Constructor TRESTDWClientSQL.Create(AOwner: TComponent);
Begin
 Inherited;
 vJsonCount                        := 0;
 vRowsAffected                     := 0;
 vOldRecordCount                   := -1;
 vActualJSON                       := '';
 vMassiveMode                      := mtMassiveCache;
 vFiltered                         := False;
 vBinaryRequest                    := False;
 vInitDataset                      := False;
 vOnPacks                          := False;
 vInternalLast                     := False;
 vNotRepage                        := False;
 vInactive                         := False;
 vInBlockEvents                    := False;
 vOnOpenCursor                     := False;
 vDataCache                        := False;
 vAutoCommitData                   := False;
 vAutoRefreshAfterCommit           := False;
 vFiltered                         := False;
 OnLoadStream                      := False;
 vPropThreadRequest                := False;
 vRaiseError                       := True;
 vConnectedOnce                    := True;
 GetNewData                        := True;
 vReflectChanges                   := False;
 vActive                           := False;
 vCacheUpdateRecords               := True;
 vBeforeClone                      := False;
 vReadData                         := False;
 vActiveCursor                     := False;
 vInDesignEvents                   := False;
 vDatapacks                        := -1;
 vCascadeDelete                    := True;
 vSQL                              := TStringList.Create;
 vRelationFields                   := TStringList.Create;
 {$IFDEF RESTDWLAZARUS}
  vSQL.OnChanging                  := @OnBeforeChangingSQL;
  vSQL.OnChange                    := @OnChangingSQL;
 {$ELSE}
  vSQL.OnChanging                  := OnBeforeChangingSQL;
  vSQL.OnChange                    := OnChangingSQL;
 {$ENDIF}
 vParams                           := TParams.Create(Self);
 vUpdateTableName                  := '';
 FieldDefsUPD                      := TFieldDefs.Create(Self);
 FieldDefs                         := FieldDefsUPD;
 vMasterDetailList                 := TMasterDetailList.Create;
 vMasterDataSet                    := Nil;
 vDataSource                       := TDataSource.Create(Nil);
 {$IFDEF RESTDWLAZARUS}
 TDataset(Self).AfterScroll        := @ProcAfterScroll;
 TDataset(Self).BeforeScroll       := @ProcBeforeScroll;
 TDataset(Self).BeforeOpen         := @ProcBeforeOpen;
 TDataset(Self).AfterOpen          := @ProcAfterOpen;
 TDataset(Self).BeforeClose        := @ProcBeforeClose;
 TDataset(Self).AfterClose         := @ProcAfterClose;
 TDataset(Self).BeforeRefresh      := @ProcBeforeRefresh;
 TDataset(Self).AfterRefresh       := @ProcAfterRefresh;
 TDataset(Self).BeforeInsert       := @ProcBeforeInsert;
 TDataset(Self).AfterInsert        := @ProcAfterInsert;
 TDataset(Self).BeforeEdit         := @ProcBeforeEdit;
 TDataset(Self).AfterEdit          := @ProcAfterEdit;
 TDataset(Self).BeforePost         := @ProcBeforePost;
 TDataset(Self).AfterCancel        := @ProcAfterCancel;
 TDataset(Self).BeforeDelete       := @ProcBeforeDelete;
 TDataset(Self).OnNewRecord        := @ProcNewRecord;
 TDataset(Self).OnCalcFields       := @ProcCalcFields;
// TDataset(Self).Last               := @Last;
 Inherited AfterPost               := @OldAfterPost;
 Inherited AfterDelete             := @OldAfterDelete;
 {$ELSE}
 TDataset(Self).AfterScroll        := ProcAfterScroll;
 TDataset(Self).BeforeScroll       := ProcBeforeScroll;
 TDataset(Self).BeforeOpen         := ProcBeforeOpen;
 TDataset(Self).AfterOpen          := ProcAfterOpen;
 TDataset(Self).BeforeClose        := ProcBeforeClose;
 TDataset(Self).AfterClose         := ProcAfterClose;
 TDataset(Self).BeforeRefresh      := ProcBeforeRefresh;
 TDataset(Self).AfterRefresh       := ProcAfterRefresh;
 TDataset(Self).BeforeInsert       := ProcBeforeInsert;
 TDataset(Self).AfterInsert        := ProcAfterInsert;
 TDataset(Self).BeforeEdit         := ProcBeforeEdit;
 TDataset(Self).AfterEdit          := ProcAfterEdit;
 TDataset(Self).BeforePost         := ProcBeforePost;
 TDataset(Self).BeforeDelete       := ProcBeforeDelete;
 TDataset(Self).AfterCancel        := ProcAfterCancel;
 TDataset(Self).OnNewRecord        := ProcNewRecord;
 TDataset(Self).OnCalcFields       := ProcCalcFields;
 Inherited AfterPost               := OldAfterPost;
 Inherited AfterDelete             := OldAfterDelete;
 {$ENDIF}
 vMassiveDataset                   := TMassiveDatasetBuffer.Create(Self);
// vActionCursor                     := crHourGlass;
 vUpdateSQL                        := Nil;
 SetComponentTAG;
End;

Destructor TRESTDWTable.Destroy;
Begin
 FreeAndNil(vRelationFields);
 FreeAndNil(vParams);
 FreeAndNil(FieldDefsUPD);
 If (vMasterDataSet <> Nil) Then
  If vMasterDetailItem <> Nil Then
   TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(vMasterDetailItem.DataSet);
 FreeAndNil(vDataSource);
 If Assigned(vCacheDataDB) Then
  FreeAndNil(vCacheDataDB);
 vInactive := False;
 FreeAndNil(vMassiveDataset);
 If Assigned(vMasterDetailList) Then
  FreeAndNil(vMasterDetailList);
 NewFieldList;
 Inherited;
End;

Destructor TRESTDWClientSQL.Destroy;
Begin
 If Assigned(vThreadRequest) Then
  ThreadDestroy;
 FreeAndNil(vSQL);
 FreeAndNil(vRelationFields);
 FreeAndNil(vParams);
 FreeAndNil(FieldDefsUPD);
 If (vMasterDataSet <> Nil) Then
  If vMasterDetailItem <> Nil Then
   TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(vMasterDetailItem.DataSet);
 FreeAndNil(vDataSource);
 If Assigned(vCacheDataDB) Then
  FreeAndNil(vCacheDataDB);
 vInactive := False;
 FreeAndNil(vMassiveDataset);
 If Assigned(vMasterDetailList) Then
  FreeAndNil(vMasterDetailList);
 NewFieldList;
 Inherited;
End;

Procedure TRESTDWTable.DWParams(Var Value: TRESTDWParams);
Begin
 Value := Nil;
 If vRESTDataBase <> Nil Then
  If ParamCount > 0 Then
    Value := GeTRESTDWParams(vParams, vRESTDataBase.Encoding);
End;

Procedure TRESTDWClientSQL.DWParams(Var Value: TRESTDWParams);
Begin
 Value := Nil;
 If vRESTDataBase <> Nil Then
  If ParamCount > 0 Then
    Value := GeTRESTDWParams(vParams, vRESTDataBase.Encoding);
End;

Procedure TRESTDWTable.DynamicFilter(cFields: array of String;
  Value: String; InText: Boolean; AndOrOR: String);
Var
 I : Integer;
begin
 Open;
 Filter := '';
 If vActive Then
  Begin
   If Length(Value) > 0 Then
    Begin
     Filtered := False;
     For I := 0 to High(cFields) do
      Begin
       If I = High(cFields) Then
        AndOrOR := '';
       If InText Then
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], '%' + Value + '%', AndOrOR])
       Else
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], Value + '%', AndOrOR]);
      End;
     If Not (Filtered) Then
      Filtered := True;
    End
   Else
    Begin
     Filter   := '';
     Filtered := False;
    End;
  End;
End;

Procedure TRESTDWClientSQL.DynamicFilter(cFields: array of String;
  Value: String; InText: Boolean; AndOrOR: String);
Var
 I : Integer;
begin
 ExecOrOpen;
 Filter := '';
 If vActive Then
  Begin
   If Length(Value) > 0 Then
    Begin
     Filtered := False;
     For I := 0 to High(cFields) do
      Begin
       If I = High(cFields) Then
        AndOrOR := '';
       If InText Then
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], '%' + Value + '%', AndOrOR])
       Else
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], Value + '%', AndOrOR]);
      End;
     If Not (Filtered) Then
      Filtered := True;
    End
   Else
    Begin
     Filter   := '';
     Filtered := False;
    End;
  End;
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

procedure TRESTDWClientSQL.CreateParams;
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
 Var
  FieldDef : TField;
 Begin
  FieldDef := FindField(Value);
  If FieldDef <> Nil Then
   Begin
    If Not (ParamSeek(Value)) Then
     Begin
      vParams.CreateParam(FieldDef.DataType, Value, ptInput);
      vParams.ParamByName(Value).Size := FieldDef.Size;
     End
    Else
     vParams.ParamByName(Value).DataType := FieldDef.DataType;
   End
  Else If Not(ParamSeek(Value)) Then
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
 If Not CompareParams(ParamsListAtual, ParamList) Then
  vParams.Clear;
 If ParamList <> Nil Then
 For I := 0 to ParamList.Count -1 Do
  CreateParam(ParamList[I]);
 ParamList.Free;
 If Assigned(ParamsListAtual) then
  FreeAndNil(ParamsListAtual);
End;

Procedure TRESTDWTable.ProcCalcFields(DataSet: TDataSet);
Begin
 If (vInBlockEvents) Then
  Exit;
 If Assigned(vOnCalcFields) Then
  vOnCalcFields(Dataset);
End;

procedure TRESTDWClientSQL.ProcCalcFields(DataSet: TDataSet);
Begin
 If (vInBlockEvents) Then
  Exit;
 If Assigned(vOnCalcFields) Then
  vOnCalcFields(Dataset);
End;

Procedure TRESTDWTable.ProcAfterScroll(DataSet: TDataSet);
Var
 JSONValue    : TJSONValue;
 vRecordCount : Integer;
Begin
 If vInBlockEvents Then
  Exit;
 If State = dsBrowse Then
  Begin
   If Not Active Then
    PrepareDetailsNew
   Else
    Begin
     vActualRec      := Recno;
     vRecordCount    := vOldRecordCount;
     If Not vNotRepage Then
      Begin
       If (vRESTDataBase <> Nil)                  And
          ((vDatapacks > -1) And (vActualRec > 0) And
           (vActualRec = vRecordCount)            And
           (vRecordCount < vJsonCount))           Then
        Begin
         vOnPacks := True;
         JSONValue := TJSONValue.Create;
         Try
          JSONValue.Encoding := vRESTDataBase.Encoding;
          JSONValue.Encoded  := vRESTDataBase.EncodedStrings;
          {$IFDEF RESTDWLAZARUS}
          JSONValue.DatabaseCharSet := DatabaseCharSet;
          {$ENDIF}
          JSONValue.Utf8SpecialChars := True;
          If vInternalLast Then
           Begin
            vInternalLast := False;
            JSONValue.OnWriterProcess := OnWriterProcess;
            JSONValue.ServerFieldList := ServerFieldList;
            {$IFDEF RESTDWLAZARUS}
             JSONValue.NewFieldList       := @NewFieldList;
             JSONValue.CreateDataSet      := @CreateDataSet;
             JSONValue.NewDataField       := @NewDataField;
             JSONValue.SetInitDataset     := @SetInitDataset;
             JSONValue.SetRecordCount     := @SetRecordCount;
             JSONValue.Setnotrepage       := @Setnotrepage;
             JSONValue.SetInDesignEvents  := @SetInDesignEvents;
             JSONValue.SetInBlockEvents   := @SetInBlockEvents;
             JSONValue.FieldListCount     := @FieldListCount;
             JSONValue.GetInDesignEvents  := @GetInDesignEvents;
             JSONValue.PrepareDetailsNew  := @PrepareDetailsNew;
             JSONValue.PrepareDetails     := @PrepareDetails;
            {$ELSE}
             JSONValue.NewFieldList       := NewFieldList;
             JSONValue.CreateDataSet      := CreateDataSet;
             JSONValue.NewDataField       := NewDataField;
             JSONValue.SetInitDataset     := SetInitDataset;
             JSONValue.SetRecordCount     := SetRecordCount;
             JSONValue.Setnotrepage       := Setnotrepage;
             JSONValue.SetInDesignEvents  := SetInDesignEvents;
             JSONValue.SetInBlockEvents   := SetInBlockEvents;
             JSONValue.FieldListCount     := FieldListCount;
             JSONValue.GetInDesignEvents  := GetInDesignEvents;
             JSONValue.PrepareDetailsNew  := PrepareDetailsNew;
             JSONValue.PrepareDetails     := PrepareDetails;
            {$ENDIF}
            JSONValue.WriteToDataset(dtFull, vActualJSON, Self, vJsonCount, vJsonCount - vActualRec, vActualRec);
            vOldRecordCount := vJsonCount;
            Last;
           End
          Else
           Begin
            JSONValue.OnWriterProcess := OnWriterProcess;
            JSONValue.ServerFieldList := ServerFieldList;
            {$IFDEF RESTDWLAZARUS}
             JSONValue.NewFieldList   := @NewFieldList;
             JSONValue.CreateDataSet  := @CreateDataSet;
             JSONValue.NewDataField   := @NewDataField;
             JSONValue.SetInitDataset := @SetInitDataset;
             JSONValue.SetRecordCount     := @SetRecordCount;
             JSONValue.Setnotrepage       := @Setnotrepage;
             JSONValue.SetInDesignEvents  := @SetInDesignEvents;
             JSONValue.SetInBlockEvents   := @SetInBlockEvents;
             JSONValue.FieldListCount     := @FieldListCount;
             JSONValue.GetInDesignEvents  := @GetInDesignEvents;
             JSONValue.PrepareDetailsNew  := @PrepareDetailsNew;
             JSONValue.PrepareDetails     := @PrepareDetails;
            {$ELSE}
             JSONValue.NewFieldList   := NewFieldList;
             JSONValue.CreateDataSet  := CreateDataSet;
             JSONValue.NewDataField   := NewDataField;
             JSONValue.SetInitDataset := SetInitDataset;
             JSONValue.SetRecordCount     := SetRecordCount;
             JSONValue.Setnotrepage       := Setnotrepage;
             JSONValue.SetInDesignEvents  := SetInDesignEvents;
             JSONValue.SetInBlockEvents   := SetInBlockEvents;
             JSONValue.FieldListCount     := FieldListCount;
             JSONValue.GetInDesignEvents  := GetInDesignEvents;
             JSONValue.PrepareDetailsNew  := PrepareDetailsNew;
             JSONValue.PrepareDetails     := PrepareDetails;
            {$ENDIF}
            JSONValue.WriteToDataset(dtFull, vActualJSON, Self, vJsonCount, vDatapacks, vActualRec);
            vOldRecordCount := Recno + vDatapacks;
            If vOldRecordCount > vJsonCount Then
             vOldRecordCount := vJsonCount;
           End;
         Finally
          JSONValue.Free;
          vOnPacks := False;
         End;
        End;
      End;
     vNotRepage := False;
     If RecordCount = 0 Then
      PrepareDetailsNew
     Else
      PrepareDetails(True)
    End;
  End
 Else If State = dsInactive Then
  PrepareDetails(False)
 Else If State = dsInsert Then
  PrepareDetailsNew;
 If Not ((vOnPacks) or (vInitDataset)) Then
  If Assigned(vOnAfterScroll) Then
   vOnAfterScroll(Dataset);
End;

procedure TRESTDWClientSQL.ProcAfterScroll(DataSet: TDataSet);
Var
 JSONValue    : TJSONValue;
 vRecordCount : Integer;
Begin
 If vInBlockEvents Then
  Exit;
 If State = dsBrowse Then
  Begin
   If Not Active Then
    PrepareDetailsNew
   Else
    Begin
     vActualRec      := Recno;
     vRecordCount    := vOldRecordCount;
     If Not vNotRepage Then
      Begin
       If (vRESTDataBase <> Nil)                  And
          ((vDatapacks > -1) And (vActualRec > 0) And
           (vActualRec = vRecordCount)            And
           (vRecordCount < vJsonCount))           Then
        Begin
         vOnPacks := True;
         JSONValue := TJSONValue.Create;
         Try
          JSONValue.Encoding := vRESTDataBase.Encoding;
          JSONValue.Encoded  := vRESTDataBase.EncodedStrings;
          JSONValue.ServerFieldList := ServerFieldList;
          {$IFDEF RESTDWLAZARUS}
           JSONValue.DatabaseCharSet := DatabaseCharSet;
           JSONValue.NewFieldList    := @NewFieldList;
           JSONValue.CreateDataSet   := @CreateDataSet;
           JSONValue.NewDataField    := @NewDataField;
           JSONValue.SetInitDataset  := @SetInitDataset;
           JSONValue.SetRecordCount     := @SetRecordCount;
           JSONValue.Setnotrepage       := @Setnotrepage;
           JSONValue.SetInDesignEvents  := @SetInDesignEvents;
           JSONValue.SetInBlockEvents   := @SetInBlockEvents;
           JSONValue.SetInactive        := @SetInactive;
           JSONValue.FieldListCount     := @FieldListCount;
           JSONValue.GetInDesignEvents  := @GetInDesignEvents;
           JSONValue.PrepareDetailsNew  := @PrepareDetailsNew;
           JSONValue.PrepareDetails     := @PrepareDetails;
          {$ELSE}
           JSONValue.NewFieldList   := NewFieldList;
           JSONValue.CreateDataSet  := CreateDataSet;
           JSONValue.NewDataField   := NewDataField;
           JSONValue.SetInitDataset := SetInitDataset;
           JSONValue.SetRecordCount     := SetRecordCount;
           JSONValue.Setnotrepage       := Setnotrepage;
           JSONValue.SetInDesignEvents  := SetInDesignEvents;
           JSONValue.SetInBlockEvents   := SetInBlockEvents;
           JSONValue.SetInactive        := SetInactive;
           JSONValue.FieldListCount     := FieldListCount;
           JSONValue.GetInDesignEvents  := GetInDesignEvents;
           JSONValue.PrepareDetailsNew  := PrepareDetailsNew;
           JSONValue.PrepareDetails     := PrepareDetails;
          {$ENDIF}
          JSONValue.Utf8SpecialChars := True;
          If vInternalLast Then
           Begin
            vInternalLast := False;
            JSONValue.OnWriterProcess := OnWriterProcess;
            JSONValue.WriteToDataset(dtFull, vActualJSON, Self, vJsonCount, vJsonCount - vActualRec, vActualRec);
            vOldRecordCount := vJsonCount;
            Last;
           End
          Else
           Begin
            JSONValue.OnWriterProcess := OnWriterProcess;
            JSONValue.WriteToDataset(dtFull, vActualJSON, Self, vJsonCount, vDatapacks, vActualRec);
            vOldRecordCount := Recno + vDatapacks;
            If vOldRecordCount > vJsonCount Then
             vOldRecordCount := vJsonCount;
           End;
         Finally
          JSONValue.Free;
          vOnPacks := False;
         End;
        End;
      End;
     vNotRepage := False;
     If RecordCount = 0 Then
      PrepareDetailsNew
     Else
      PrepareDetails(True)
    End;
  End
 Else If State = dsInactive Then
  PrepareDetails(False)
 Else If State = dsInsert Then
  PrepareDetailsNew;
 If Not ((vOnPacks) or (vInitDataset)) Then
  If Assigned(vOnAfterScroll) Then
   vOnAfterScroll(Dataset);
End;

Procedure TRESTDWTable.GotoRec(const aRecNo: Integer);
Var
 ActiveRecNo,
 Distance     : Integer;
Begin
 If (aRecNo > 0) Then
  Begin
   ActiveRecNo := Self.RecNo;
   If (aRecNo <> ActiveRecNo) Then
    Begin
     Self.DisableControls;
     Try
      Distance := aRecNo - ActiveRecNo;
      Self.MoveBy(Distance);
     Finally
      Self.EnableControls;
     End;
    End;
  End;
End;

Procedure TRESTDWClientSQL.GotoRec(const aRecNo: Integer);
Var
 ActiveRecNo,
 Distance     : Integer;
Begin
 If (aRecNo > 0) Then
  Begin
   ActiveRecNo := Self.RecNo;
   If (aRecNo <> ActiveRecNo) Then
    Begin
     Self.DisableControls;
     Try
      Distance := aRecNo - ActiveRecNo;
      Self.MoveBy(Distance);
     Finally
      Self.EnableControls;
     End;
    End;
  End;
End;

Procedure TRESTDWTable.ProcBeforeDelete(DataSet: TDataSet);
Var
 I             : Integer;
 vDetailClient : TRESTDWClientSQLBase;
 vStream       : TStream;
Begin
 If Not vReadData Then
  Begin
   vReadData := True;
   vOldStatus   := State;
   Try
    vActualRec   := RecNo;
   Except
    vActualRec   := -1;
   End;
   Try
    If vCascadeDelete Then
     Begin
      For I := 0 To vMasterDetailList.Count -1 Do
       Begin
        vMasterDetailList.Items[I].ParseFields(TRESTDWTable(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
        vDetailClient        := TRESTDWTable(vMasterDetailList.Items[I].DataSet);
        If vDetailClient <> Nil Then
         Begin
          Try
           vDetailClient.First;
           While Not vDetailClient.Eof Do
            vDetailClient.Delete;
          Finally
           vReadData := False;
          End;
         End;
       End;
     End;
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If Assigned(vBeforeDelete) Then
       vBeforeDelete(DataSet);
      SetRecordCount(RecordCount - 1, RecordCount - 1);
      If (Trim(vTableName) <> '') Or (vUpdateSQL <> Nil) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLDelete.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmDelete,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vStream := TMemoryStream.Create;
            Try
             TMassiveDatasetBuffer(vMassiveDataset).SaveToStream(vStream, TMassiveDatasetBuffer(vMassiveDataset));
             vMassiveCache.Add(vStream, Self);
            Finally
             //FreeAndNil(vStream);
             TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
            End;
           End;
         End;
       End;
     End;
    vReadData := False;
   Except
    On e : EAbort Do
     Begin
      vReadData := False;
      Abort;
     End;
    On E : Exception do
     begin
      vReadData := False;
      Raise Exception.Create(e.Message);
      Abort;
     End;
   End;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeDelete(DataSet: TDataSet);
Var
 I             : Integer;
 vDetailClient : TRESTDWClientSQL;
 vStream       : TStream;
Begin
 If Not vReadData Then
  Begin
   vReadData := True;
   vOldStatus   := State;
   Try
    vActualRec   := RecNo;
   Except
    vActualRec   := -1;
   End;
   Try
//    SaveToStream(OldData);
    If vCascadeDelete Then
     Begin
      For I := 0 To vMasterDetailList.Count -1 Do
       Begin
        vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
        vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
        If vDetailClient <> Nil Then
         Begin
          Try
           vDetailClient.First;
           While Not vDetailClient.Eof Do
            vDetailClient.Delete;
          Finally
           vReadData := False;
          End;
         End;
       End;
     End;
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If Assigned(vBeforeDelete) Then
       vBeforeDelete(DataSet);
      SetRecordCount(RecordCount - 1, RecordCount - 1);
      If (Trim(vUpdateTableName) <> '') Or (vUpdateSQL <> Nil) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLDelete.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).MassiveMode := mmDelete;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmDelete,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vStream := TMemoryStream.Create;
            Try
             TMassiveDatasetBuffer(vMassiveDataset).SaveToStream(vStream, TMassiveDatasetBuffer(vMassiveDataset));
             vMassiveCache.Add(vStream, Self);
            Finally
             //FreeAndNil(vStream);
             TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
            End;
           End;
         End;
       End;
     End;
    vReadData := False;
   Except
    On e : EAbort Do
     Begin
      vReadData := False;
      Abort;
     End;
    On E : Exception do
     begin
      vReadData := False;
      Raise Exception.Create(e.Message);
      Abort;
     End;
   End;
  End;
End;

Procedure TRESTDWTable.ProcBeforeEdit(DataSet: TDataSet);
Begin
 If Not((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vTableName) <> '') And (vUpdateSQL = Nil) Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
     TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer  (Self, mmUpdate, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmUpdate, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
    End;
   If Assigned(vBeforeEdit) Then
    vBeforeEdit(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeEdit(DataSet: TDataSet);
Begin
 If Not((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vUpdateTableName) <> '') And (vUpdateSQL = Nil) Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
     TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
     TMassiveDatasetBuffer(vMassiveDataset).MassiveMode := mmUpdate;
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer  (Self,
                                                        TMassiveDatasetBuffer(vMassiveDataset).MassiveMode,
                                                        TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self,
                                                        TMassiveDatasetBuffer(vMassiveDataset).MassiveMode,
                                                        TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
    End;
   If Assigned(vBeforeEdit) Then
    vBeforeEdit(Dataset);
  End;
End;

procedure TRESTDWTable.ProcBeforeInsert(DataSet: TDataSet);
Begin
 If Not((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If Assigned(vBeforeInsert) Then
    vBeforeInsert(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeInsert(DataSet: TDataSet);
Begin
 If Not((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If Assigned(vBeforeInsert) Then
    vBeforeInsert(Dataset);
  End;
End;

Procedure TRESTDWTable.ProcBeforeOpen(DataSet: TDataSet);
Begin
 MasterFields := '';
 If Not((vInBlockEvents) or (vInitDataset) or (vInRefreshData)) Then
  Begin
   If Assigned(vBeforeOpen) Then
   vBeforeOpen(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeOpen(DataSet: TDataSet);
Begin
 MasterFields := '';
 If Not((vInBlockEvents) or (vInitDataset) or (vInRefreshData)) Then
  Begin
   If Assigned(vBeforeOpen) Then
   vBeforeOpen(Dataset);
  End;
End;

Procedure TRESTDWTable.ProcBeforePost(DataSet: TDataSet);
Var
 vStream : TStream;
Begin
 If Not vReadData Then
  Begin
   vActualRec    := -1;
   vReadData     := True;
   vOldState     := State;
   vOldStatus    := State;
   Try
    If vOldState = dsInsert then
     vActualRec  := RecNo + 1
    Else
     vActualRec  := RecNo;
    Edit;
    vReadData     := False;
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If vOldState = dsInsert then
       SetRecordCount(RecordCount + 1, RecordCount + 1);
      If Assigned(vBeforePost) Then
       vBeforePost(DataSet);
      If ((Trim(vTableName) <> '') Or (vUpdateSQL <> Nil)) And (vOldState = dsEdit) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLUpdate.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, DatasetStateToMassiveType(vOldState),
                                                             vOldState = dsEdit,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vOldState = dsEdit Then
           Begin
            If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer <> Nil Then
             Begin
              If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges <> Nil Then
               Begin
                If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges.Count = 0 Then
                 TMassiveDatasetBuffer(vMassiveDataset).ClearLine
                Else
                 TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
               End
              Else
               TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
             End
            Else
             TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
           End
          Else
           TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vStream := TMemoryStream.Create;
            Try
             TMassiveDatasetBuffer(vMassiveDataset).SaveToStream(vStream, TMassiveDatasetBuffer(vMassiveDataset));
             vMassiveCache.Add(vStream, Self);
            Finally
             //FreeAndNil(vStream);
             TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
            End;
           End;
         End;
       End;
     End;
   Except
    On e : EAbort Do
     Begin
      vActualRec   := -1;
      vReadData    := False;
      Abort;
     End;
    On E : Exception Do
     Begin
      vActualRec   := -1;
      vReadData    := False;
      Raise Exception.Create(e.Message);
      Abort;
     End;
   End;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforePost(DataSet: TDataSet);
Var
 vStream : TStream;
Begin
 If Not vReadData Then
  Begin
   vActualRec    := -1;
   vReadData     := True;
   vOldState     := State;
   vOldStatus    := State;
   Try
    If vOldState = dsInsert then
     vActualRec  := RecNo + 1
    Else
     vActualRec  := RecNo;
    Edit;
    vReadData     := False;
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If vOldState = dsInsert then
       SetRecordCount(RecordCount + 1, RecordCount + 1);
      If Assigned(vBeforePost) Then
       vBeforePost(DataSet);
      If ((Trim(vUpdateTableName) <> '') Or (vUpdateSQL <> Nil)) And (vOldState = dsEdit) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLUpdate.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, DatasetStateToMassiveType(vOldState),
                                                             vOldState = dsEdit, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vOldState = dsEdit Then
           Begin
            If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer <> Nil Then
             Begin
              If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges <> Nil Then
               Begin
                If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges.Count = 0 Then
                 TMassiveDatasetBuffer(vMassiveDataset).ClearLine
                Else
                 TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
               End
              Else
               TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
             End
            Else
             TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
           End
          Else
           TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vStream := TMemoryStream.Create;
            Try
             TMassiveDatasetBuffer(vMassiveDataset).SaveToStream(vStream, TMassiveDatasetBuffer(vMassiveDataset));
             vMassiveCache.Add(vStream, Self);
            Finally
             //FreeAndNil(vStream);
             TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
            End;
           End;
         End;
       End;
     End;
   Except
    On e : EAbort Do
     Begin
      vActualRec   := -1;
      vReadData    := False;
      Abort;
     End;
    On E : Exception Do
     Begin
      vActualRec   := -1;
      vReadData    := False;
      Raise Exception.Create(e.Message);
      Abort;
     End;
   End;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeExec(DataSet: TDataSet);
Var
 vStream : TStream;
Begin
 If Not vReadData Then
  Begin
   vReadData     := True;
   Try
    If MassiveType = mtMassiveObject Then
     Begin
      Try
       If Not((vInBlockEvents) or (vInitDataset)) Then
        Begin
         If (vUpdateSQL <> Nil) Then
          vUpdateSQL.Store(vUpdateSQL.vSQLUpdate.Text, Self)
         Else
          Begin
           TMassiveDatasetBuffer(vMassiveDataset).MassiveMode   := mmExec;
           TMassiveDatasetBuffer(vMassiveDataset).MassiveType   := MassiveType;
           TMassiveDatasetBuffer(vMassiveDataset).LastOpen      := vLastOpen;
           TMassiveDatasetBuffer(vMassiveDataset).Dataexec.Text := vSQL.Text;
           TMassiveDatasetBuffer(vMassiveDataset).Params.LoadFromParams(Params);
           TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self,  TMassiveDatasetBuffer(vMassiveDataset).MassiveMode,
                                                              False, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
           TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer (Self,  TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
           If vMassiveCache <> Nil Then
            Begin
             vMassiveCache.MassiveType                          := MassiveType;
             vStream := TMemoryStream.Create;
             Try
              TMassiveDatasetBuffer(vMassiveDataset).SaveToStream(vStream, TMassiveDatasetBuffer(vMassiveDataset));
              vMassiveCache.Add(vStream, Self);
             Finally
              //FreeAndNil(vStream);
              TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
             End;
            End;
          End;
        End;
      Except
       On E : Exception Do
        Begin
         Raise Exception.Create(e.Message);
         Abort;
        End;
      End;
     End;
   Finally
    vReadData := False;
   End;
  End;
End;

Procedure TRESTDWTable.ProcBeforeScroll(DataSet: TDataSet);
Begin
 If ((vInBlockEvents) or (vInitDataset)) Then
  Exit;
 If Not vOnPacks Then
  If Assigned(vOnBeforeScroll) Then
   vOnBeforeScroll(Dataset);
End;

Procedure TRESTDWClientSQL.ProcBeforeScroll(DataSet: TDataSet);
Begin
 If ((vInBlockEvents) or (vInitDataset)) Then
  Exit;
 If Not vOnPacks Then
  If Assigned(vOnBeforeScroll) Then
   vOnBeforeScroll(Dataset);
End;

Procedure TRESTDWTable.ProcNewRecord(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If Assigned(vNewRecord) Then
    vNewRecord(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcNewRecord(DataSet: TDataSet);
begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If Assigned(vNewRecord) Then
    vNewRecord(Dataset);
  End;
end;

Procedure TRESTDWTable.RebuildMassiveDataset;
Begin
 CreateMassiveDataset;
End;

procedure TRESTDWClientSQL.RebuildMassiveDataset;
Begin
 CreateMassiveDataset;
End;

Procedure TRESTDWTable.Refresh;
Var
 Cursor : Integer;
Begin
 Cursor := 0;
 If Active then
  Begin
   If RecordCount > 0 then
    Cursor := Self.CurrentRecord;
   Close;
   Open;
   If Active then
    Begin
     If RecordCount > 0 Then
      MoveBy(Cursor);
    End;
  End;
End;

Procedure TRESTDWClientSQL.Refresh;
Var
 Cursor : Integer;
Begin
 Cursor := 0;
 If Active then
  Try
   ProcBeforeRefresh(Self);
   vInRefreshData := True;
   If RecordCount > 0 then
    Cursor := Self.CurrentRecord;
   Close;
   Open;
   If Active then
    Begin
     If RecordCount > 0 Then
      MoveBy(Cursor);
    End;
   ProcAfterRefresh(Self);
  Finally
    vInRefreshData := False;
  End;
End;

Procedure TRESTDWTable.RestoreDatasetPosition;
begin
 vInBlockEvents := False;
 TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
 RebuildMassiveDataset;
 vInBlockEvents := False;
end;

procedure TRESTDWClientSQL.RestoreDatasetPosition;
begin
 vInBlockEvents := False;
 TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
 RebuildMassiveDataset;
 vInBlockEvents := False;
end;

procedure TRESTDWTable.ProcBeforeClose(DataSet: TDataSet);
Begin
 If (Assigned(vOnBeforeClose) and not vInBlockEvents and not vInRefreshData) then
  vOnBeforeClose(Dataset);
End;

procedure TRESTDWTable.ProcAfterClose(DataSet: TDataSet);
Var
 I : Integer;
 vDetailClient : TRESTDWClientSQLBase;
Begin
 vActualJSON   := '';
 If (Assigned(vOnAfterClose) and not vInBlockEvents and not vInRefreshData) then
  vOnAfterClose(Dataset);
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWTable(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWTable(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    vDetailClient.Close;
  End;
End;

procedure TRESTDWTable.ProcBeforeRefresh(DataSet: TDataSet);
Begin
  If (Assigned(vOnBeforeRefresh) and not vInBlockEvents) Then
   vOnBeforeRefresh(DataSet);
End;

procedure TRESTDWTable.ProcAfterRefresh(DataSet: TDataSet);
Begin
  If (Assigned(vOnAfterRefresh) and not vInBlockEvents) Then
   vOnAfterRefresh(DataSet);
End;

procedure TRESTDWClientSQL.ProcBeforeClose(DataSet: TDataSet);
Begin
 If (Assigned(vOnBeforeClose) and not vInBlockEvents and not vInRefreshData) then
  vOnBeforeClose(Dataset);
End;

procedure TRESTDWClientSQL.ProcAfterClose(DataSet: TDataSet);
Var
 I : Integer;
 vDetailClient : TRESTDWClientSQL;
Begin
 vActualJSON   := '';
 If (Assigned(vOnAfterClose) and not vInBlockEvents and not vInRefreshData) then
  vOnAfterClose(Dataset);
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    vDetailClient.Close;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeRefresh(DataSet: TDataSet);
Begin
  If (Assigned(vOnBeforeRefresh) and not vInBlockEvents) Then
   vOnBeforeRefresh(DataSet);
End;

procedure TRESTDWClientSQL.ProcAfterRefresh(DataSet: TDataSet);
Begin
  If (Assigned(vOnAfterRefresh) and not vInBlockEvents) Then
   vOnAfterRefresh(DataSet);
End;

Procedure TRESTDWTable.ProcAfterEdit(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  If Assigned(vAfterEdit) Then
   vAfterEdit(Dataset);
End;

procedure TRESTDWClientSQL.ProcAfterEdit(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  If Assigned(vAfterEdit) Then
   vAfterEdit(Dataset);
End;

Procedure TRESTDWTable.ProcAfterInsert(DataSet: TDataSet);
Var
 I             : Integer;
 vFieldA,
 vFieldD       : String;
 vFields       : TStringList;
 vDetailClient : TRESTDWClientSQLBase;
 Procedure CloneDetails(Value : TRESTDWClientSQLBase; FieldName, FieldNameDest : String);
 Begin
  If (FindField(FieldNameDest) <> Nil) And (Value.FindField(FieldName) <> Nil) Then
   FindField(FieldNameDest).Value := Value.FindField(FieldName).Value;
 End;
 Procedure ParseFields(Value : String);
 Var
  I           : Integer;
  vTempFields : TStringList;
 Begin
  vFields.Clear;
  vTempFields      := TStringList.Create;
  vTempFields.Text := Value;
  Try
   For I := vTempFields.Count -1 DownTo 0 Do
    Begin
     If Pos(';', vTempFields[I]) > 0 Then
      Begin
       vFields.Add(UpperCase(Trim(Copy(vTempFields[I], 1, Pos(';', vTempFields[I]) -1))));
       vTempFields.Delete(I);
      End
     Else
      Begin
       vFields.Add(UpperCase(Trim(vTempFields[I])));
       vTempFields.Clear;
      End;
    End;
  Finally
   FreeAndNil(vTempFields);
  End;
 End;
Begin
 vDetailClient := vMasterDataSet;
 If (vDetailClient <> Nil) And (Fields.Count > 0) Then
  Begin
   vFields      := TStringList.Create;
   vFields.Text := RelationFields.Text;
   For I := 0 To vFields.Count -1 Do
    Begin
     vFieldA := Copy(vFields[I], InitStrPos, (Pos('=', vFields[I]) -1) - FinalStrPos);
     vFieldD := Copy(vFields[I], (Pos('=', vFields[I]) - FinalStrPos) + 1, Length(vFields[I]));
     If vDetailClient.FindField(vFieldA) <> Nil Then
      CloneDetails(vDetailClient, vFieldA, vFieldD);
    End;
   vFields.Free;
  End;
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vTableName) <> '') And (vUpdateSQL = Nil) Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
     TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer  (Self, mmInsert, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmInsert, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
    End;
   If Assigned(vAfterInsert) Then
    vAfterInsert(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcAfterInsert(DataSet: TDataSet);
Var
 I             : Integer;
 vFieldA,
 vFieldD       : String;
 vFields       : TStringList;
 vDetailClient : TRESTDWClientSQL;
 Procedure CloneDetails(Value : TRESTDWClientSQL; FieldName, FieldNameDest : String);
 Begin
  If (FindField(FieldNameDest) <> Nil) And (Value.FindField(FieldName) <> Nil) Then
   FindField(FieldNameDest).Value := Value.FindField(FieldName).Value;
 End;
 Procedure ParseFields(Value : String);
 Var
  I           : Integer;
  vTempFields : TStringList;
 Begin
  vFields.Clear;
  vTempFields      := TStringList.Create;
  vTempFields.Text := Value;
  Try
   For I := vTempFields.Count -1 DownTo 0 Do
    Begin
     If Pos(';', vTempFields[I]) > 0 Then
      Begin
       vFields.Add(UpperCase(Trim(Copy(vTempFields[I], 1, Pos(';', vTempFields[I]) -1))));
       vTempFields.Delete(I);
      End
     Else
      Begin
       vFields.Add(UpperCase(Trim(vTempFields[I])));
       vTempFields.Clear;
      End;
    End;
  Finally
   FreeAndNil(vTempFields);
  End;
 End;
Begin
 vDetailClient := vMasterDataSet;
 If (vDetailClient <> Nil) And (Fields.Count > 0) Then
  Begin
   vFields      := TStringList.Create;
   vFields.Text := RelationFields.Text;
   For I := 0 To vFields.Count -1 Do
    Begin
     vFieldA := Copy(vFields[I], InitStrPos, (Pos('=', vFields[I]) -1) - FinalStrPos);
     vFieldD := Copy(vFields[I], (Pos('=', vFields[I]) - FinalStrPos) + 1, Length(vFields[I]));
     If vDetailClient.FindField(vFieldA) <> Nil Then
      CloneDetails(vDetailClient, vFieldA, vFieldD);
    End;
   vFields.Free;
  End;
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vUpdateTableName) <> '') And (vUpdateSQL = Nil) Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).SequenceName  := SequenceName;
     TMassiveDatasetBuffer(vMassiveDataset).SequenceField := SequenceField;
     TMassiveDatasetBuffer(vMassiveDataset).MassiveType   := MassiveType;
     TMassiveDatasetBuffer(vMassiveDataset).LastOpen      := vLastOpen;
     TMassiveDatasetBuffer(vMassiveDataset).MassiveMode   := mmInsert;
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer  (Self, mmInsert, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmInsert, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
    End;
   If Assigned(vAfterInsert) Then
    vAfterInsert(Dataset);
  End;
End;

procedure TRESTDWTable.ProcAfterOpen(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset) or (vInRefreshData)) Then
  Begin
   If Assigned(vOnAfterOpen) Then
    vOnAfterOpen(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcAfterOpen(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset) or (vInRefreshData)) Then
  Begin
   If Assigned(vOnAfterOpen) Then
    vOnAfterOpen(Dataset);
  End;
End;

Procedure TRESTDWTable.ProcAfterCancel(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vTableName) <> '') And (vUpdateSQL = Nil) Then
    TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
   If Assigned(vAfterCancel) Then
    vAfterCancel(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcAfterCancel(DataSet: TDataSet);
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   If (Trim(vUpdateTableName) <> '') And (vUpdateSQL = Nil) Then
    TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
   If Assigned(vAfterCancel) Then
    vAfterCancel(Dataset);
  End;
End;

Function TRESTDWTable.ProcessChanges(MassiveJSON : String) : Boolean;
Var
 I, A,
 vActualRecB   : Integer;
 bJsonValueC,
 bJsonValueB   : TRESTDWJSONInterfaceBase;
 bJsonArray,
 bJsonOBJ      : TRESTDWJSONInterfaceArray;
 bJsonValue    : TRESTDWJSONInterfaceObject;
 vOldReadOnly  : Boolean;
 vLastTimeB,
 vValue        : String;
 vStringStream : TMemoryStream;
 Function DecodeREC(BookmarkSTR  : String;
                    Var LastTime : String) : Integer;
 Var
  vTempString : String;
 Begin
  Result := -1;
  vTempString := BookmarkSTR;
  If Pos('|', vTempString) > 0 Then
   Begin
    Result := StrToInt(Copy(vTempString, InitStrPos, Pos('|', vTempString) -1));
    vTempString := Copy(vTempString, Pos('|', vTempString) +1, Length(vTempString));
    LastTime := DecodeStrings(vTempString{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
   End;
 End;
Begin
 Result       := False;
 vStringStream := Nil;
 bJsonValueC   := Nil;
 bJsonValueB   := Nil;
 bJsonArray    := Nil;
 bJsonOBJ      := Nil;
 bJsonValue    := Nil;
 If Trim(MassiveJSON) = '' Then
  Exit;
 bJsonValue   := TRESTDWJSONInterfaceObject.Create(StringReplace(MassiveJSON, #$FEFF, '', [rfReplaceAll]));
 bJsonOBJ     := TRESTDWJSONInterfaceArray(bJsonValue);
 Try
  For I := 0 To bJsonOBJ.ElementCount -1 do
   Begin
    bJsonValueB  := bJsonOBJ.GetObject(I);
    Try
     vValue := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     Try
      vActualRecB := DecodeREC(vValue, vLastTimeB);
      If (vActualRecB > -1) Then
       Begin
        Self.GotoBookmark(TBookMark(HexToBookmark(vLastTimeB)));
        bJsonArray := TRESTDWJSONInterfaceObject(bJsonValueB).OpenArray('reflectionlines');
        Self.Edit;
        For A := 0 To bJsonArray.ElementCount -1 Do
         Begin
          bJsonValueC := bJsonArray.GetObject(A);
          Try
           If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name) <> Nil Then
            Begin
             vOldReadOnly := Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly;
             Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly := False;
             If (TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value = 'null') Or
                (Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly) Then
              Begin
               If Not (Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly) Then
                Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
               Continue;
              End;
             If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType
                in [{$IFDEF DELPHIXEUP}ftFixedChar, ftFixedWideChar,{$ENDIF}
                    ftString, ftWideString, ftMemo, ftFmtMemo
                    {$IFDEF DELPHIXEUP}, ftWideMemo{$ENDIF}] Then
              Begin
               If (TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value <> Null) And
                  (Trim(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value) <> 'null') Then
                Begin
                 vValue := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}); //TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value;
                 {$IFNDEF DELPHI2006UP}
                 vValue := utf8Decode(vValue);
                 {$ENDIF}
                 If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Size > 0 Then
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsString := Copy(vValue, 1, Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Size)
                 Else
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsString := vValue;
                End
               Else
                Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
              End
             Else
              Begin
               If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftInteger, ftSmallInt, ftWord, {$IFDEF DELPHIXEUP}ftLongWord,{$ENDIF} ftLargeint] Then
                Begin
                 If Not TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull Then
                  Begin
                   If TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value <> Null Then
                    Begin
                     If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [{$IFDEF DELPHIXEUP}ftLongWord,{$ENDIF}ftLargeint] Then
                      Begin
                        {$IF Defined(RESTDWLAZARUS)}
                        Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsLargeInt := StrToInt64(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value, csUndefined));
                        {$ELSEIF Defined(DELPHIXEUP)}
                        Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsLargeInt := StrToInt64(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value));
                        {$ELSE}
                        Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsInteger  := StrToInt(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value));
                        {$IFEND}
                      End
                     Else
                      Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsInteger  := StrToInt(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));
                    End;
                  End
                 Else
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
                End
               Else If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFDEF DELPHIXEUP}, ftSingle{$ENDIF}] Then
                Begin
                 If Not TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull Then
                  Begin
                   {$IFNDEF RESTDWLAZARUS}
                    Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Value   := StrToFloat(BuildFloatString(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value));
                   {$ELSE}
                    Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsFloat := StrToFloat(BuildFloatString(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value));
                   {$ENDIF}
                  End
                 Else
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
                End
               Else If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull)) Then
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsDateTime  := UnixToDateTime(StrToInt64(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value))
                 Else
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
                End  //Tratar Blobs de Parametros...
               Else If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 Try
                  If Not TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull Then
                   Begin
                    vStringStream := DecodeStream(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value);
                    vStringStream.Position := 0;
                    TBlobfield(Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name)).LoadFromStream(vStringStream);
                   End
                  Else
                   Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
                 Finally
                  If Assigned(vStringStream) Then
                   FreeAndNil(vStringStream);
                 End;
                End
               Else If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftBoolean] Then
                 Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsBoolean := StringToBoolean(vValue)
               Else If Not TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull Then
                Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Value := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF})
               Else
                Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
              End;
             Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly := vOldReadOnly;
            End;
          Finally
           FreeAndNil(bJsonValueC);
          End;
         End;
        Self.Post;
       End;
     Except
      If Assigned(bJsonValueC) then
       FreeAndNil(bJsonValueC);
      If Assigned(bJsonValueB) then
       FreeAndNil(bJsonValueB);
     End;
    Finally
     FreeAndNil(bJsonArray);
     FreeAndNil(bJsonValueB);
    End;
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Function TRESTDWClientSQL.ProcessChanges(MassiveJSON : String) : Boolean;
Var
 I, A,
 vActualRecB   : Integer;
 bJsonValueC,
 bJsonValueB   : TRESTDWJSONInterfaceBase;
 bJsonArray,
 bJsonOBJ      : TRESTDWJSONInterfaceArray;
 bJsonValue    : TRESTDWJSONInterfaceObject;
 vOldReadOnly  : Boolean;
 vLastTimeB,
 vValue        : String;
 vBookmarkD    : Integer;
 vStringStream : TMemoryStream;
 Function DecodeREC(BookmarkSTR  : String;
                    Var LastTime : String) : Integer;
 Var
  vTempString : String;
 Begin
  Result := -1;
  vTempString := BookmarkSTR;
  If Pos('|', vTempString) > 0 Then
   Begin
    Result := StrToInt(Copy(vTempString, InitStrPos, Pos('|', vTempString) -1));
    vTempString := Copy(vTempString, Pos('|', vTempString) +1, Length(vTempString));
    LastTime := DecodeStrings(vTempString{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
   End;
 End;
Begin
 Result       := False;
 vStringStream := Nil;
 bJsonValueC   := Nil;
 bJsonValueB   := Nil;
 bJsonArray    := Nil;
 bJsonOBJ      := Nil;
 bJsonValue    := Nil;
 If Trim(MassiveJSON) = '' Then
  Exit;
 bJsonValue   := TRESTDWJSONInterfaceObject.Create(StringReplace(MassiveJSON, #$FEFF, '', [rfReplaceAll]));
 bJsonOBJ     := TRESTDWJSONInterfaceArray(bJsonValue);
 Try
  For I := 0 To bJsonOBJ.ElementCount -1 do
   Begin
    bJsonValueB  := bJsonOBJ.GetObject(I);
    Try
     vValue := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).Pairs[0].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     Try
      vActualRecB := DecodeREC(vValue, vLastTimeB);
      If (vActualRecB > -1) Then
       Begin
        Self.GotoBookmark(TBookmark(HexToBookmark(vLastTimeB)));
//        Self.RecNo := vActualRecB;
        bJsonArray := TRESTDWJSONInterfaceObject(bJsonValueB).OpenArray('reflectionlines');
        Self.Edit;
        For A := 0 To bJsonArray.ElementCount -1 Do
         Begin
          bJsonValueC := bJsonArray.GetObject(A);
          Try
           If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name) <> Nil Then
            Begin
             vOldReadOnly := Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly;
             Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly := False;
             If (TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value = 'null') Or
                (Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly) Then
              Begin
               If Not (Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly) Then
                Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
               Continue;
              End;
             If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType
                in [{$IFDEF DELPHIXEUP}ftFixedChar, ftFixedWideChar,{$ENDIF}
                    ftString, ftWideString, ftMemo, ftFmtMemo
                    {$IFDEF DELPHIXEUP}, ftWideMemo{$ENDIF}] Then
              Begin
               If (TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value <> Null) And
                  (Trim(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value) <> 'null') Then
                Begin
                 vValue := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}); //TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value;
                 {$IFNDEF DELPHI2006UP}
                 vValue := utf8Decode(vValue);
                 {$ENDIF}
                 If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Size > 0 Then
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsString := Copy(vValue, 1, Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Size)
                 Else
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsString := vValue;
                End
               Else
                Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
              End
             Else
              Begin
               If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If Not TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull Then
                  Begin
                   If TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value <> Null Then
                    Begin
                     If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                      Begin
                        {$IF Defined(RESTDWLAZARUS)}
                        Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsLargeInt := StrToInt64(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value, csUndefined));
                        {$ELSEIF Defined(DELPHIXEUP)}
                        Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsLargeInt := StrToInt64(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value));
                        {$ELSE}
                        Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsInteger  := StrToInt(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value));
                        {$IFEND}
                      End
                     Else
                      Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsInteger  := StrToInt(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}));
                    End;
                  End
                 Else
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
                End
               Else If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFDEF DELPHIXEUP}, ftSingle{$ENDIF}] Then
                Begin
                 If Not TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull Then
                  Begin
                   {$IFNDEF RESTDWLAZARUS}
                    Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Value   := StrToFloat(BuildFloatString(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value));
                   {$ELSE}
                    Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsFloat := StrToFloat(BuildFloatString(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value));
                   {$ENDIF}
                  End
                 Else
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
                End
               Else If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull)) Then
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsDateTime  := UnixToDateTime(StrToInt64(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value))
                 Else
                  Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
                End  //Tratar Blobs de Parametros...
               Else If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 Try
                  If Not TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull Then
                   Begin
                    vStringStream := DecodeStream(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value);
                    vStringStream.Position := 0;
                    TBlobfield(Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name)).LoadFromStream(vStringStream);
                   End
                  Else
                   Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
                 Finally
                  If Assigned(vStringStream) Then
                   FreeAndNil(vStringStream);
                 End;
                End
               Else If Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).DataType in [ftBoolean] Then
                Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).AsBoolean := StringToBoolean(vValue)
               Else If Not TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].isnull Then
                Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Value := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF})
               Else
                Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).Clear;
              End;
             Self.FindField(TRESTDWJSONInterfaceObject(bJsonValueC).Pairs[0].Name).ReadOnly := vOldReadOnly;
            End;
          Finally
           FreeAndNil(bJsonValueC);
          End;
         End;
        Self.Post;
       End;
     Except
      If Assigned(bJsonValueC) then
       FreeAndNil(bJsonValueC);
      If Assigned(bJsonValueB) then
       FreeAndNil(bJsonValueB);
     End;
    Finally
     FreeAndNil(bJsonArray);
     FreeAndNil(bJsonValueB);
    End;
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Procedure TRESTDWTable.ApplyUpdates;
Var
 vError : String;
Begin
 ApplyUpdates(vError);
 If vError <> '' Then
  Raise Exception.Create(PChar(vError));
End;

Procedure TRESTDWClientSQL.ApplyUpdates;
Var
 vError : String;
Begin
 ApplyUpdates(vError);
 If vError <> '' Then
  Raise Exception.Create(PChar(vError));
End;

Function TRESTDWTable.ApplyUpdates(Var Error: String; ReleaseCache : Boolean = True): Boolean;
Var
 vError        : Boolean;
 vErrorMSG,
 vMassiveJSON  : String;
 vResult       : TJSONValue;
 vActualReg    : TBookmark;
Begin
 Result  := False;
 vError  := False;
 vResult := Nil;
 If (vUpdateSQL <> Nil) Then
  Begin
   If vUpdateSQL.MassiveCount = 0 Then
    Error := cInvalidDataToApply
   Else
    Begin
     vRESTDataBase.ProcessMassiveSQLCache(vUpdateSQL.vMassiveCacheSQLList, vError, vErrorMSG);
     If vError Then
      Error := vErrorMSG;
     Result := Not (vError);
    End;
  End
 Else
  Begin
   If TMassiveDatasetBuffer(vMassiveDataset).RecordCount = 0 Then
    Error := cInvalidDataToApply
   Else
    Begin
     vMassiveJSON := TMassiveDatasetBuffer(vMassiveDataset).ToJSON;
     Result       := vMassiveJSON <> '';
     If Result Then
      Begin
       Result     := False;
       If vRESTDataBase <> Nil Then
        Begin
         If vAutoRefreshAfterCommit Then
          vRESTDataBase.ApplyUpdatesTB(vActualPoolerMethodClient, TMassiveDatasetBuffer(vMassiveDataset), vParams, vError, vBinaryRequest, vErrorMSG, vResult, vRowsAffected, Nil)
         Else
          vRESTDataBase.ApplyUpdatesTB(vActualPoolerMethodClient, TMassiveDatasetBuffer(vMassiveDataset), vParams, vError, vBinaryRequest, vErrorMSG, vResult, vRowsAffected, Nil);
         Result := Not vError;
         Error  := vErrorMSG;
         If (Assigned(vResult) And (vAutoRefreshAfterCommit)) And
            (Not (TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges)) Then
          Begin
           Try
            vActive := False;
            ProcBeforeOpen(Self);
            vInBlockEvents := True;
            Filter         := '';
            Filtered       := False;
            vActive        := GetData(vResult);
            If State = dsBrowse Then
             Begin
              If Trim(vTableName) <> '' Then
               TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vTableName));
              PrepareDetails(True);
             End
            Else If State = dsInactive Then
             PrepareDetails(False);
            vInBlockEvents := False;
           Except
            On E : Exception do
             Begin
              vInBlockEvents := False;
              If csDesigning in ComponentState Then
               Raise Exception.Create(PChar(E.Message))
              Else
               Begin
                If Assigned(vOnGetDataError) Then
                 vOnGetDataError(False, E.Message);
                If vRaiseError Then
                 Raise Exception.Create(PChar(E.Message));
               End;
             End;
           End;
          End
         Else If Assigned(vResult) And
                         (TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges) Then
          Begin
           //Edit Dataset with values back.
           vActualReg     := GetBookmark;
           vInBlockEvents := True;
           If Not vResult.isnull Then
            Begin
             ProcessChanges(vResult.Value);
             GotoBookmark(vActualReg);
            End;
           vInBlockEvents := False;
           If State = dsBrowse Then
            Begin
             If Trim(vTableName) <> '' Then
              TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vTableName));
            End
           Else If State = dsInactive Then
            PrepareDetails(False);
          End
         Else
          Begin
           If vError Then
            Begin
             vInBlockEvents := False;
             If ReleaseCache Then
              Begin
               TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
               RebuildMassiveDataset;
              End;
             If Assigned(vOnGetDataError) Then
              vOnGetDataError(False, vErrorMSG);
             If vRaiseError Then
              Raise Exception.Create(PChar(vErrorMSG));
            End;
          End;
         If Assigned(vResult) Then
          FreeAndNil(vResult);
        End
       Else
        Error := cEmptyDBName;
      End;
     If Result Then
      Begin
       If ReleaseCache Then
        TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
      End
     Else
      Error := vErrorMSG;
    End;
  End;
End;

Function TRESTDWClientSQL.ApplyUpdates(Var Error: String; ReleaseCache : Boolean = True): Boolean;
Var
 vError         : Boolean;
 vErrorMSG      : String;
 vResult        : TJSONValue;
 vActualReg     : TBookmark;
Begin
 Result  := False;
 vError  := False;
 vResult := Nil;
 If (vUpdateSQL <> Nil) Then
  Begin
   If vUpdateSQL.MassiveCount = 0 Then
    Error := cInvalidDataToApply
   Else
    Begin
     vRESTDataBase.ProcessMassiveSQLCache(vUpdateSQL.vMassiveCacheSQLList, vError, vErrorMSG);
     If vError Then
      Error := vErrorMSG;
     Result := Not (vError);
    End;
  End
 Else
  Begin
   If TMassiveDatasetBuffer(vMassiveDataset).RecordCount = 0 Then
    Error := cInvalidDataToApply
   Else
    Begin
     Result     := False;
     If vRESTDataBase <> Nil Then
      Begin
       If vAutoRefreshAfterCommit Then
        vRESTDataBase.ApplyUpdates(vActualPoolerMethodClient, TMassiveDatasetBuffer(vMassiveDataset), vSQL, vParams, vError, vBinaryRequest, vErrorMSG, vResult, vRowsAffected, Nil)
       Else
        vRESTDataBase.ApplyUpdates(vActualPoolerMethodClient, TMassiveDatasetBuffer(vMassiveDataset), Nil,  vParams, vError, vBinaryRequest, vErrorMSG, vResult, vRowsAffected, Nil);
       Result := Not vError;
       Error  := vErrorMSG;
       If (Assigned(vResult) And (vAutoRefreshAfterCommit)) And
          (Not (TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges)) Then
        Begin
         Try
          vActive := False;
          ProcBeforeOpen(Self);
          vInBlockEvents := True;
          Filter         := '';
          Filtered       := False;
          vActive        := GetData(vResult);
          If State = dsBrowse Then
           Begin
            If Trim(vUpdateTableName) <> '' Then
             TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vUpdateTableName));
            PrepareDetails(True);
           End
          Else If State = dsInactive Then
           PrepareDetails(False);
          vInBlockEvents := False;
         Except
          On E : Exception do
           Begin
            vInBlockEvents := False;
            If csDesigning in ComponentState Then
             Raise Exception.Create(PChar(E.Message))
            Else
             Begin
              If Assigned(vOnGetDataError) Then
               vOnGetDataError(False, E.Message);
              If vRaiseError Then
               Raise Exception.Create(PChar(E.Message));
             End;
           End;
         End;
        End
       Else If Assigned(vResult) And
                       (TMassiveDatasetBuffer(vMassiveDataset).ReflectChanges) Then
        Begin
         //Edit Dataset with values back.
         vActualReg     := GetBookmark;
         vInBlockEvents := True;
         If Not vResult.isnull Then
          Begin
           ProcessChanges(vResult.Value);
           GotoBookmark(vActualReg);
          End;
         vInBlockEvents := False;
         If State = dsBrowse Then
          Begin
           If Trim(vUpdateTableName) <> '' Then
            TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vUpdateTableName));
          End
         Else If State = dsInactive Then
          PrepareDetails(False);
        End
       Else
        Begin
         If vError Then
          Begin
           vInBlockEvents := False;
           If Assigned(vOnGetDataError) Then
            vOnGetDataError(False, vErrorMSG);
           If vRaiseError Then
            Raise Exception.Create(PChar(vErrorMSG));
           If ReleaseCache Then
            Begin
             TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
             RebuildMassiveDataset;
            End;

          End;
        End;
       If Assigned(vResult) Then
        FreeAndNil(vResult);
      End
     Else
      Error := cEmptyDBName;
     If Result Then
      Begin
       If ReleaseCache Then
        TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
      End
     Else
      Error := vErrorMSG;
    End;
  End;
End;

Function TRESTDWTable.ParamByName(Value: String): TParam;
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
 If Not Assigned(Result) Then
  Raise Exception.Create(Format(cParamNotFound, [Value]));
End;

Function TRESTDWClientSQL.ParamByName(Value: String): TParam;
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
 If Not Assigned(Result) Then
  Raise Exception.Create(Format(cParamNotFound, [Value]));
End;

Function TRESTDWTable.ParamCount: Integer;
Begin
 Result := vParams.Count;
End;

Function TRESTDWClientSQL.ParamCount: Integer;
Begin
 Result := vParams.Count;
End;

Procedure TRESTDWTable.FieldDefsToFields;
Var
 I          : Integer;
 FieldValue : TField;
Begin
 For I := 0 To FieldDefs.Count -1 Do
  Begin
   FieldValue           := TField.Create(Self);
   FieldValue.DataSet   := Self;
   FieldValue.FieldName := FieldDefs[I].Name;
   FieldValue.SetFieldType(FieldDefs[I].DataType);
   FieldValue.Size      := FieldDefs[I].Size;
   Fields.Add(FieldValue);
  End;
End;

Procedure TRESTDWClientSQL.FieldDefsToFields;
Var
 I          : Integer;
 FieldValue : TField;
Begin
 For I := 0 To FieldDefs.Count -1 Do
  Begin
   FieldValue           := TField.Create(Self);
   FieldValue.DataSet   := Self;
   FieldValue.FieldName := FieldDefs[I].Name;
   FieldValue.SetFieldType(FieldDefs[I].DataType);
   FieldValue.Size      := FieldDefs[I].Size;
   Fields.Add(FieldValue);
  End;
End;

Function TRESTDWTable.FirstWord(Value: String): String;
Var
 vTempValue : PChar;
Begin
 vTempValue := PChar(Trim(Value));
 While Not (vTempValue^ = #0) Do
  Begin
   If (vTempValue^ <> ' ') Then
    Result := Result + vTempValue^
   Else
    Break;
   Inc(vTempValue);
  End;
End;

Function TRESTDWClientSQL.FirstWord(Value: String): String;
Var
 vTempValue : PChar;
Begin
 vTempValue := PChar(Trim(Value));
 While Not (vTempValue^ = #0) Do
  Begin
   If (vTempValue^ <> ' ') Then
    Result := Result + vTempValue^
   Else
    Break;
   Inc(vTempValue);
  End;
End;

procedure TRESTDWClientSQL.ExecOrOpen;
Var
 vError : String;
 Function OpenSQL : Boolean;
 Var
  vSQLText : String;
 Begin
  vSQLText := UpperCase(Trim(vSQL.Text));
  Result := FirstWord(vSQLText) = 'SELECT';
 End;
Begin
 If OpenSQL Then
  Open
 Else
  Begin
   If Not ExecSQL(vError) Then
    Begin
     If csDesigning in ComponentState Then
      Raise Exception.Create(PChar(vError))
     Else
      Begin
       If Assigned(vOnGetDataError) Then
        vOnGetDataError(False, vError)
       Else
        Raise Exception.Create(PChar(vError));
      End;
    End;
  End;
End;

Procedure TRESTDWClientSQL.ExecSQL;
Var
 vError : String;
Begin
 ExecSQL(vError);
 If vError <> '' Then
  Raise Exception.Create(PChar(vError));
End;

function TRESTDWClientSQL.ExecSQL(Var Error: String): Boolean;
Var
 vError        : Boolean;
 vMessageError : String;
 vResult       : TJSONValue;
Begin
 vResult       := Nil;
 vRowsAffected := 0;
 Try
//  ChangeCursor;
  Result := False;
  If MassiveType = mtMassiveObject Then
   Begin
    ProcBeforeExec(Self);
    Result := True;
   End
  Else
   Begin
    Try
     If vRESTDataBase <> Nil Then
      Begin
       If Not vRESTDataBase.Active Then
        vRESTDataBase.Active := True;
       If Not vRESTDataBase.Active then
        Exit;
       vRESTDataBase.ExecuteCommand(vActualPoolerMethodClient, vSQL, vParams,   vError, vMessageError,
                                    vResult, vRowsAffected, True, False, False, False,  vRESTDataBase.RESTClientPooler);
       Result := Not vError;
       Error  := vMessageError;
       If Assigned(vResult) Then
        FreeAndNil(vResult);
       If (vRaiseError) And (vError) Then
        Raise Exception.Create(PChar(vMessageError));
      End
     Else
      Begin
       If (vRaiseError) Then
        Raise Exception.Create(PChar(cEmptyDBName));
      End;
    Except
     On E : Exception do
      Begin
       If (vRaiseError) Then
        Raise Exception.Create(e.Message);
      End;
    End;
   End;
 Finally
//  ChangeCursor(True);
 End;
End;

function TRESTDWClientSQL.InsertMySQLReturnID: Integer;
Var
 vError        : Boolean;
 vMessageError : String;
Begin
 Result := -1;
 Try
  If vRESTDataBase <> Nil Then
   Result := vRESTDataBase.InsertMySQLReturnID(vActualPoolerMethodClient, vSQL, vParams, vError, vMessageError,  Nil)
  Else
   Raise Exception.Create(PChar(cEmptyDBName));
 Except
 End;
End;

procedure TRESTDWClientSQL.OnBeforeChangingSQL(Sender: TObject);
begin
 vOldSQL := vSQL.Text;
end;

procedure TRESTDWClientSQL.OnChangingSQL(Sender: TObject);
Begin
 GetNewData := TStringList(Sender).Text <> vOldSQL;
 If GetNewData Then
  vOldSQL := TStringList(Sender).Text;
 CreateParams;
End;

procedure TRESTDWClientSQL.SetSQL(Value: TStringList);
Var
 I : Integer;
Begin
 vSQL.Clear;
 For I := 0 To Value.Count -1 do
  vSQL.Add(Value[I]);
End;

Procedure TRESTDWTable.CreateDataSet;
Begin
 vCreateDS := True;
 SetInBlockEvents(True);
 Try
  TRESTDWMemtable(Self).Close;
  TRESTDWMemtable(Self).Open;
  vCreateDS := False;
  vActive   := Not vCreateDS;
 Finally
 End;
End;

Procedure TRESTDWClientSQL.SetInactive(Const Value : Boolean);
Begin
 vInactive := Value;
End;

Procedure TRESTDWClientSQL.CreateDataSet;
Begin
 vCreateDS := True;
 SetInBlockEvents(True);
 Try

  EmptyTable;

  vCreateDS := False;
  vActive   := Not vCreateDS;
 Finally
 End;
End;

Class Procedure TRESTDWTable.CreateEmptyDataset(Const Dataset : TDataset);
Begin
 Try
  TRESTDWMemtable(Dataset).Close;
  TRESTDWMemtable(Dataset).Open;
 Finally
 End;
End;

Class Procedure TRESTDWClientSQL.CreateEmptyDataset(Const Dataset : TDataset);
Begin
 Try
  TRESTDWMemtable(Dataset).Close;
  TRESTDWMemtable(Dataset).Open;
 Finally
 End;
End;

Procedure TRESTDWTable.CreateDatasetFromList;
Var
 I        : Integer;
 FieldDef : TFieldDef;
Begin
 TDataset(Self).Close;
 For I := 0 To Length(vFieldsList) -1 Do
  Begin
   FieldDef := FieldDefExist(Self, vFieldsList[I].FieldName);
   If FieldDef = Nil Then
    Begin
     FieldDef          := TDataset(Self).FieldDefs.AddFieldDef;
     FieldDef.Name     := vFieldsList[I].FieldName;
     FieldDef.DataType := vFieldsList[I].DataType;
     FieldDef.Size     := vFieldsList[I].Size;
     If FieldDef.DataType In [ftFloat, ftCurrency, ftBCD,
                              {$IFDEF DELPHIXEUP}ftExtended, ftSingle,{$ENDIF}
                              ftFMTBcd] Then
      Begin
       FieldDef.Size      := vFieldsList[I].Size;
       FieldDef.Precision := vFieldsList[I].Precision;
      End;
     FieldDef.Required    :=  vFieldsList[I].Required;
    End
   Else
    FieldDef.Required    :=  vFieldsList[I].Required;
  End;
 CreateDataset;
End;

Procedure TRESTDWClientSQL.CreateDatasetFromList;
Var
 I        : Integer;
 FieldDef : TFieldDef;
Begin
 TRESTDWMemtable(Self).Close;
 For I := 0 To Length(vFieldsList) -1 Do
  Begin
   FieldDef := FieldDefExist(Self, vFieldsList[I].FieldName);
   If FieldDef = Nil Then
    Begin
     FieldDef          := TRESTDWMemtable(Self).FieldDefs.AddFieldDef;
     FieldDef.Name     := vFieldsList[I].FieldName;
     FieldDef.DataType := vFieldsList[I].DataType;
     FieldDef.Size     := vFieldsList[I].Size;
     If FieldDef.DataType In [ftFloat, ftCurrency, ftBCD,
                              {$IFDEF DELPHIXEUP}ftExtended, ftSingle,{$ENDIF}
                              ftFMTBcd] Then
      Begin
       FieldDef.Size      := vFieldsList[I].Size;
       FieldDef.Precision := vFieldsList[I].Precision;
      End;
     FieldDef.Required    :=  vFieldsList[I].Required;
    End
   Else
    FieldDef.Required    :=  vFieldsList[I].Required;
  End;
 CreateDataset;
End;

procedure TRESTDWTable.CleanFieldList;
Var
 I : Integer;
Begin
 If Self is TRESTDWTable Then
  For I := 0 To Length(vFieldsList) -1 Do
   FreeAndNil(vFieldsList[I]);
 SetLength(vFieldsList, 0);
End;

procedure TRESTDWClientSQL.CleanFieldList;
Var
 I : Integer;
Begin
 If Self is TRESTDWClientSQL Then
  For I := 0 To Length(vFieldsList) -1 Do
   FreeAndNil(vFieldsList[I]);
 SetLength(vFieldsList, 0);
End;

Procedure TRESTDWTable.ClearMassive;
Begin
 If Trim(vTableName) <> '' Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
End;

Procedure TRESTDWClientSQL.ClearMassive;
Begin
 If Trim(vUpdateTableName) <> '' Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
End;

Procedure TRESTDWTable.Close;
Begin
 vInactive       := False;
 vInternalLast   := False;
 vOldRecordCount := -1;
 If vActive Then
  Begin
   vActive         := False;
   SetActiveDB(vActive);
  End;
 Inherited Close;
End;

procedure TRESTDWClientSQL.Close;
Begin
 vInactive       := False;
 vInternalLast   := False;
 vReadData       := False;
 vOldRecordCount := -1;
 If vActive Then
  Begin
   vActive         := False;
   SetActiveDB(vActive);
  End;
 Inherited Close;
End;

Procedure TRESTDWTable.CloseCursor;
begin
 If Not (csDesigning in ComponentState) Then
  Close;
 Inherited;
end;

procedure TRESTDWClientSQL.CloseCursor;
begin
 If Not (csDesigning in ComponentState) Then
  Close;
 Inherited;
end;

Procedure TRESTDWTable.Open;
Begin
 Try
  If Not vInactive Then
   Begin
    If (vActive) Then
     vActive := False;
    If Not vActive Then
     SetActiveDB(True);
   End;
  If vActive Then
   Inherited Open;
 Finally
  vInBlockEvents  := False;
 End;
End;

Procedure TRESTDWClientSQL.Open;
Begin
 Try
  If Not vInactive Then
   Begin
    If (vActive) Then
     vActive := False;
    If Not vActive Then
     SetActiveDB(True);
   End;
  If vActive Then
   Inherited Open;
 Finally
  vInBlockEvents  := False;
 End;
End;

procedure TRESTDWClientSQL.Open(strSQL: String);
Begin
 If Not vActive Then
  Begin
   Close;
   vSQL.Clear;
   vSQL.Add(strSQL);
   SetActiveDB(True);
   Inherited Open;
  End;
End;

Procedure TRESTDWTable.OpenCursor(InfoQuery: Boolean);
Begin
 Try
  If (vRESTDataBase <> Nil) And
     ((Not(((vInBlockEvents) or (vInitDataset))) or (GetNewData)) Or (vInDesignEvents)) And
       Not(vActive) And (Not (BinaryLoadRequest)) Then
   Begin
    GetNewData := False;
    If Not (vRESTDataBase.Active)   Then
     vRESTDataBase.Active := True;
    If  ((Self.FieldDefs.Count = 0) Or
         (vInDesignEvents))         And
        (Not (vActiveCursor))       Or
         (GetNewData)               Then
     Begin
      vActiveCursor := True;
      Try
       SetActiveDB(True);
       If vActive Then
        Begin
         Inherited Open;
         vActiveCursor := False;
         Exit;
        End;
      Except
       On E : Exception Do
        Begin
         vActiveCursor := False;
         Raise Exception.Create(E.Message);
        End;
      End;
      vActiveCursor := False;
     End
    Else If ((Self.FieldDefs.Count > 0) Or
             (Self.Fields.Count > 0)    Or
             (vInDesignEvents))         Then
     Begin
      Try
       If Not((vInBlockEvents) or (vInitDataset)) Then
        Begin
         If Not vActive Then
          SetActiveDB(True);
        End
       Else
        Inherited OpenCursor(InfoQuery);
      Except
       If Not (csDesigning in ComponentState) Then
        Exception.Create(Name + ': ' + cErrorOpenDataset);
      End;
     End
    Else If (Self.FieldDefs.Count = 0)    And
            (Self.FieldListCount = 0) Then
     Raise Exception.Create(Name + ': ' + cErrorNoFieldsDataset)
    Else If Not (csDesigning in ComponentState) Then
     Raise Exception.Create(Name + ': ' + cErrorOpenDataset);
   End
  Else If (((vRESTDataBase <> Nil)) Or (Assigned(vDWResponseTranslator)) And
           ((Self.FieldDefs.Count > 0)) Or (BinaryLoadRequest))          And
          (Not(OnLoadStream))                                            Then
   Begin
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If Not vActive Then
       SetActiveDB(True);
     End
    Else
     Inherited OpenCursor(InfoQuery);
   End
  Else If csDesigning in ComponentState Then
   Begin
    If (vRESTDataBase = Nil) then
     Raise Exception.Create(Name + ': ' + cErrorDatabaseNotFound)
    Else If Not (csDesigning in ComponentState) Then
     Raise Exception.Create(Name + ': ' + cErrorOpenDataset);
   End;
 Except
  On E : Exception do
   Begin
    If csDesigning in ComponentState Then
     Raise Exception.Create(Name+': ' + PChar(E.Message))
    Else
     Begin
      If Assigned(vOnGetDataError) Then
       vOnGetDataError(False, Name+': '+E.Message)
      Else
       Raise Exception.Create(PChar(Name+': ' + E.Message));
     End;
   End;
 End;
End;

Procedure TRESTDWClientSQL.OpenCursor(InfoQuery: Boolean);
var
 Error: String;
Begin
 Try
  If (vRESTDataBase <> Nil) And
     ((Not(((vInBlockEvents) or (vInitDataset))) or (GetNewData)) Or (vInDesignEvents)) And
       Not(vActive) And (Not (BinaryLoadRequest)) Then
   Begin
    GetNewData := False;
    If Not (vRESTDataBase.Active)   Then
     vRESTDataBase.Active := True;
    If  ((Self.FieldDefs.Count = 0) Or
         (vInDesignEvents))         And
        (Not (vActiveCursor))       Or
         (GetNewData)               Then
     Begin
      vActiveCursor := True;
      Try
       SetActiveDB(True);
       If vActive Then
        Begin
         Inherited Open;
         vActiveCursor := False;
         Exit;
        End;
      Except
       On E : Exception Do
        Begin
         vActiveCursor := False;
         Raise Exception.Create(E.Message);
        End;
      End;
      vActiveCursor := False;
     End
    Else If ((Self.FieldDefs.Count > 0) Or
             (Self.Fields.Count > 0)    Or
             (vInDesignEvents))         Then
     Begin
      Try
       If Not((vInBlockEvents) or (vInitDataset)) Then
        Begin
         If Not vActive Then
          SetActiveDB(True);
        End
       Else
        Inherited OpenCursor(InfoQuery);
      Except
       Raise;
      End;
     End
    Else If (Self.FieldDefs.Count = 0)    And
            (Self.FieldListCount = 0) Then
     Raise Exception.Create(Name + ': ' + cErrorNoFieldsDataset)
    Else If Not (csDesigning in ComponentState) Then
     Raise Exception.Create(Name + ': ' + cErrorOpenDataset);
   End
  Else If (((vRESTDataBase <> Nil)) Or (Assigned(vDWResponseTranslator)) And
           ((Self.FieldDefs.Count > 0)) Or (BinaryLoadRequest))          And
          (Not(OnLoadStream))                                            Then
   Begin
    If Not((vInBlockEvents) or (vInitDataset)) Then
     Begin
      If Not vActive Then
       SetActiveDB(True);
     End
    Else
     Inherited OpenCursor(InfoQuery);
   End
  Else If csDesigning in ComponentState Then
   Begin
    If (vRESTDataBase = Nil) then
     Raise Exception.Create(Name + ': ' + cErrorDatabaseNotFound)
    Else If Not (csDesigning in ComponentState) Then
     Raise Exception.Create(Name + ': ' + cErrorOpenDataset);
   End;
 Except
  On E : Exception do
   Begin
    If csDesigning in ComponentState Then
     Raise Exception.Create(Name + ': ' + PChar(E.Message))
    Else
     Begin
      If Assigned(vOnGetDataError) Then
       vOnGetDataError(False, Name + ': '+E.Message)
      Else
       Raise Exception.Create(PChar(Name + ': ' + E.Message));
     End;
   End;
 End;
End;

procedure TRESTDWTable.OldAfterPost(DataSet: TDataSet);
Var
 vError  : String;
 vStream : TStream;
Begin
 vErrorBefore := False;
 vError       := '';
 If Not vReadData Then
  Begin
   If Not ((vInBlockEvents) or (vInitDataset)) Then
    Begin
     Try
      If ((Trim(vTableName) <> '') Or (vUpdateSQL <> Nil)) And (vOldState = dsInsert) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLInsert.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen    := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, DatasetStateToMassiveType(vOldState),
                                                             vOldState = dsEdit,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vStream := TMemoryStream.Create;
            Try
             TMassiveDatasetBuffer(vMassiveDataset).SaveToStream(vStream, TMassiveDatasetBuffer(vMassiveDataset));
             vMassiveCache.Add(vStream, Self);
            Finally
             TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
            End;
           End;
         End;
       End;
      If ((Trim(vTableName) <> '') Or (vUpdateSQL <> Nil)) Then
       If vAutoCommitData Then
        Begin
         If (vUpdateSQL <> Nil) Then
          ApplyUpdates(vError)
         Else If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
          ApplyUpdates(vError);
        End;
      If vError <> '' Then
       Raise Exception.Create(vError)
      Else
       Begin
        If Assigned(vAfterPost) Then
         vAfterPost(Dataset);
        ProcAfterScroll(Dataset);
       End;
     Except

     End;
    End;
  End;
End;

procedure TRESTDWClientSQL.OldAfterPost(DataSet: TDataSet);
Var
 vError  : String;
 vStream : TStream;
Begin
 vErrorBefore := False;
 vError       := '';
 If Not vReadData Then
  Begin
   If Not ((vInBlockEvents) or (vInitDataset)) Then
    Begin
     Try
      If ((Trim(vUpdateTableName) <> '') Or (vUpdateSQL <> Nil)) And (vOldState = dsInsert) Then
       Begin
        If (vUpdateSQL <> Nil) Then
         vUpdateSQL.Store(vUpdateSQL.vSQLInsert.Text, Self)
        Else
         Begin
          TMassiveDatasetBuffer(vMassiveDataset).SequenceName  := SequenceName;
          TMassiveDatasetBuffer(vMassiveDataset).SequenceField := SequenceField;
          TMassiveDatasetBuffer(vMassiveDataset).MassiveType   := MassiveType;
          TMassiveDatasetBuffer(vMassiveDataset).LastOpen      := vLastOpen;
          TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, DatasetStateToMassiveType(vOldState),
                                                             vOldState = dsEdit,
                                                             TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self, TMassiveDatasetBuffer(vMassiveDataset).MassiveMode = mmExec);
          If vMassiveCache <> Nil Then
           Begin
            vStream := TMemoryStream.Create;
            Try
             TMassiveDatasetBuffer(vMassiveDataset).SaveToStream(vStream, TMassiveDatasetBuffer(vMassiveDataset));
             vMassiveCache.Add(vStream, Self);
            Finally
             TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
            End;
           End;
         End;
       End;
      If ((Trim(vUpdateTableName) <> '') Or (vUpdateSQL <> Nil)) Then
       If vAutoCommitData Then
        Begin
         If (vUpdateSQL <> Nil) Then
          ApplyUpdates(vError)
         Else If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
          ApplyUpdates(vError);
        End;
      If vError <> '' Then
       Raise Exception.Create(vError)
      Else
       Begin
        If Assigned(vAfterPost) Then
         vAfterPost(Dataset);
        ProcAfterScroll(Dataset);
       End;
     Except
      On E: Exception Do
       Begin
        Raise Exception.Create(E.Message);
       End;
     End;
    End;
  End;
End;

procedure TRESTDWTable.OldAfterDelete(DataSet: TDataSet);
Var
 vError : String;
Begin
 vErrorBefore := False;
 vError       := '';
 Try
  If Not vReadData Then
   Begin
    Try
     If Trim(vTableName) <> '' Then
      If vAutoCommitData Then
       If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
        ApplyUpdates(vError);
     If vError <> '' Then
      Raise Exception.Create(vError)
     Else
      Begin
       If Assigned(vAfterDelete) Then
        vAfterDelete(Self);
       ProcAfterScroll(Dataset);
      End;
    Except
      On E: Exception Do
      Begin
        Raise Exception.Create(E.Message);
      End;
    End;
   End;
 Finally
  vReadData := False;
 End;
End;

procedure TRESTDWClientSQL.OldAfterDelete(DataSet: TDataSet);
Var
 vError : String;
Begin
 vErrorBefore := False;
 vError       := '';
 Try
  If Not vReadData Then
   Begin
    Try
     If Trim(vUpdateTableName) <> '' Then
      If vAutoCommitData Then
       If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
        ApplyUpdates(vError);
     If vError <> '' Then
      Raise Exception.Create(vError)
     Else
      Begin
       If Assigned(vAfterDelete) Then
        vAfterDelete(Self);
       ProcAfterScroll(Dataset);
      End;
    Except
      On E: Exception Do
      Begin
       Raise Exception.Create(E.Message);
      End;
    End;
   End;
 Finally
  vReadData := False;
 End;
End;

procedure TRESTDWClientSQL.SetUpdateTableName(Value: String);
Begin
 vCommitUpdates    := Trim(Value) <> '';
 vUpdateTableName  := Value;
End;

Procedure TRESTDWClientSQL.AbortData;
Begin
 If Assigned(vRESTDataBase) Then
  If Assigned(vActualPoolerMethodClient) Then
   Begin
    vActualPoolerMethodClient.Abort;
    vActualPoolerMethodClient := Nil;
   End;
End;

Procedure TRESTDWClientSQL.ThreadStart(ExecuteData : TOnExecuteData);
Begin
 If Assigned(vThreadRequest) Then
  ThreadDestroy;
 {$IFDEF RESTDWLAZARUS}
  vThreadRequest        := TRESTDWThreadRequest.Create(Self,
                                                       ExecuteData,
                                                       @AbortData,
                                                       vOnThreadRequestError);
 {$ELSE}
  vThreadRequest        := TRESTDWThreadRequest.Create(Self,
                                                       ExecuteData,
                                                       AbortData,
                                                       vOnThreadRequestError);
 {$ENDIF}
 vThreadRequest.Resume;
End;

Procedure TRESTDWClientSQL.ThreadDestroy;
Begin
 Try
  vThreadRequest.Kill;
 Except
 End;
 FreeAndNil(vThreadRequest);
End;

Procedure TRESTDWTable.InternalLast;
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   vActualRec    := vJsonCount;
   vInternalLast := True;
  End;
 Inherited InternalLast;
End;

Procedure TRESTDWClientSQL.InternalClose;
Begin
 BaseClose;
 vinactive       := False;
 vRowsAffected   := 0;
 vOldRecordCount := 0;
 vJsonCount      := 0;
 vActualRec      := 0;
 Inherited InternalClose;
End;

Procedure TRESTDWClientSQL.InternalLast;
Begin
 If Not ((vInBlockEvents) or (vInitDataset)) Then
  Begin
   vActualRec    := vJsonCount;
   vInternalLast := True;
  End;
 Inherited InternalLast;
End;

Procedure TRESTDWTable.InternalPost;
Begin
 Inherited;
End;

procedure TRESTDWTable.SetTableName(Value: String);
Begin
 vCommitUpdates    := Trim(Value) <> '';
 vTableName  := Value;
End;

procedure TRESTDWTable.InternalOpen;
begin
 Try
  vActive := True;
  Inherited;
  If Not vInBlockEvents Then
   Begin
    If Not (BinaryRequest) Then
     Begin
      If Not (csDesigning in ComponentState) then
       Open;
     End;
   End;
 Except
  On e : Exception do
   Begin
    Raise Exception.Create(e.Message);
   End;
 End;
end;

Procedure TRESTDWClientSQL.InternalPost;
Begin
 Inherited;
End;

procedure TRESTDWClientSQL.InternalOpen;
begin
 Try
  vActive := True;
  Inherited;
  If Not vInBlockEvents Then
   Begin
    If Not (BinaryRequest) Then
     Begin
      If Not (csDesigning in ComponentState) then
       Open;
     End;
   End;
 Except
  On e : Exception do
   Begin
    Raise Exception.Create(e.Message);
   End;
 End;
end;

Procedure TRESTDWTable.InternalRefresh;
Begin
 Inherited;
 If Not (csDesigning In ComponentState) Then
  If Not vInBlockEvents Then
   Refresh;
End;

Procedure TRESTDWClientSQL.InternalRefresh;
Begin
 Inherited;
 If Not (csDesigning In ComponentState) Then
  If Not vInBlockEvents Then
   Refresh;
End;

Procedure TRESTDWTable.Loaded;
Begin
 Inherited Loaded;
 Try
  If Not (csDesigning in ComponentState) Then
   SetActiveDB(False);
 Except
  If Not (csDesigning in ComponentState) Then
   Raise;
 End;
End;

Procedure TRESTDWClientSQL.Loaded;
Begin
 Inherited Loaded;
  try
    if not (csDesigning in ComponentState) then
      SetActiveDB(False);
  except
    if not (csDesigning in ComponentState) then
      raise;
  end;
End;

Procedure TRESTDWTable.LoadFromStream(Stream : TMemoryStream);
Begin
 If Not Assigned(Stream) Then
  Exit;
 DisableControls;
 Close;
 vInBlockEvents := True;
 Try
  Stream.Position := 0;
  TRESTDWClientSQLBase(Self).LoadFromStream(Stream);
 Finally
  vInBlockEvents := False;
 End;
 EnableControls;
End;

Procedure TRESTDWClientSQL.LoadFromStream(Stream : TMemoryStream);
begin
 If Not Assigned(Stream) Then
  Exit;
 DisableControls;
 Close;
 vInBlockEvents := True;
 Try
  Stream.Position := 0;
  TRESTDWClientSQLBase(Self).LoadFromStream(Stream);
 Finally
  vInBlockEvents := False;
 End;
 EnableControls;
end;

Function TRESTDWTable.MassiveCount: Integer;
Begin
 Result := 0;
 If Trim(vTableName) <> '' Then
  Result := TMassiveDatasetBuffer(vMassiveDataset).RecordCount;
End;

Function TRESTDWClientSQL.MassiveCount: Integer;
Begin
 Result := 0;
 If Trim(vUpdateTableName) <> '' Then
  Result := TMassiveDatasetBuffer(vMassiveDataset).RecordCount;
End;

Function TRESTDWTable.MassiveToJSON: String;
Begin
 Result := '';
 If vMassiveDataset <> Nil Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   Result := TMassiveDatasetBuffer(vMassiveDataset).ToJSON;
End;

Function TRESTDWClientSQL.MassiveToJSON: String;
Begin
 Result := '';
 If vMassiveDataset <> Nil Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   Result := TMassiveDatasetBuffer(vMassiveDataset).ToJSON;
End;

Procedure TRESTDWTable.NewDataField(Value: TFieldDefinition);
Var
 I : Integer;
begin
 SetLength(vFieldsList, Length(vFieldsList) +1);
 I := Length(vFieldsList) -1;
 vFieldsList[I]           := TFieldDefinition.Create;
 vFieldsList[I].FieldName := Value.FieldName;
 vFieldsList[I].DataType  := Value.DataType;
 vFieldsList[I].Size      := Value.Size;
 vFieldsList[I].Required  := Value.Required;
end;

Procedure TRESTDWClientSQL.NewDataField(Value: TFieldDefinition);
Var
 I : Integer;
begin
 SetLength(vFieldsList, Length(vFieldsList) +1);
 I := Length(vFieldsList) -1;
 vFieldsList[I]           := TFieldDefinition.Create;
 vFieldsList[I].FieldName := Value.FieldName;
 vFieldsList[I].DataType  := Value.DataType;
 vFieldsList[I].Size      := Value.Size;
 vFieldsList[I].Required  := Value.Required;
end;

Function TRESTDWTable.FieldListCount: Integer;
Begin
 Result := 0;
 If Self is TRESTDWTable Then
  Result := Length(vFieldsList);
End;

Function TRESTDWClientSQL.FieldListCount: Integer;
Begin
 Result := 0;
 If Self is TRESTDWClientSQL Then
  Result := Length(vFieldsList);
End;

Procedure TRESTDWTable.NewFieldList;
Begin
 CleanFieldList;
 If Self is TRESTDWTable Then
  SetLength(vFieldsList, 0);
End;

Procedure TRESTDWClientSQL.NewFieldList;
Begin
 CleanFieldList;
 If Self is TRESTDWClientSQL Then
  SetLength(vFieldsList, 0);
End;

Procedure TRESTDWTable.Newtable;
Begin
 TRESTDWTable(Self).Inactive   := True;
 Try
 {$IFNDEF RESTDWLAZARUS}
  Self.Close;
  Self.Open;
 {$ELSE}
  {$IFDEF ZEOSDRIVER} //TODO
  {$ELSE}
   {$IFDEF RESTDWMEMTABLE} //TODO
    TRESTDWMemtable(Self).Close;
    TRESTDWMemtable(Self).Open;
   {$ELSE}
    {$IFNDEF RESTDWUNIDACMEM}
     If Self is TMemDataset Then
      TMemDataset(Self).CreateTable;
    {$ELSE}
     TVirtualTable(Self).Close;
     TVirtualTable(Self).Open;
    {$ENDIF}
   {$ENDIF}
  {$ENDIF}
  Self.Open;
  TRESTDWTable(Self).Active     := True;
 {$ENDIF}
 Finally
  TRESTDWTable(Self).Inactive   := False;
 End;
End;

procedure TRESTDWClientSQL.Newtable;
Begin
 TRESTDWClientSQL(Self).Inactive   := True;
 Try
 {$IFNDEF FPC}
  Self.Close;
  Self.Open;
 {$ELSE}
  {$IFDEF ZEOSDRIVER} //TODO
  {$ELSE}
   {$IFDEF RESTDWMEMTABLE} //TODO
    TRESTDWMemtable(Self).Close;
    TRESTDWMemtable(Self).Open;
   {$ELSE}
    {$IFNDEF RESTDWUNIDACMEM}
     If Self is TMemDataset Then
      TMemDataset(Self).CreateTable;
    {$ELSE}
     TVirtualTable(Self).Close;
     TVirtualTable(Self).Open;
    {$ENDIF}
   {$ENDIF}
  {$ENDIF}
  Self.Open;
  TRESTDWClientSQL(Self).Active     := True;
 {$ENDIF}
 Finally
  TRESTDWClientSQL(Self).Inactive   := False;
 End;
end;

Procedure TRESTDWTable.Notification(AComponent : TComponent;
                                    Operation  : TOperation);
Begin
 If (Operation    = opRemove)              And
    (AComponent   = vRESTDataBase)         Then
  vRESTDataBase := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vMassiveCache)         Then
  vMassiveCache := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vDWResponseTranslator) Then
  vDWResponseTranslator := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vUpdateSQL)            Then
  vUpdateSQL      := Nil;
 Inherited Notification(AComponent, Operation);
End;

Procedure TRESTDWClientSQL.Notification(AComponent : TComponent;
                                        Operation  : TOperation);
Begin
 If (Operation    = opRemove)              And
    (AComponent   = vRESTDataBase)         Then
   vRESTDataBase := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vMassiveCache)         Then
   vMassiveCache := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vDWResponseTranslator) Then
   vDWResponseTranslator := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vUpdateSQL)            Then
  vUpdateSQL      := Nil;
 Inherited Notification(AComponent, Operation);
End;

Destructor TRESTDWConnectionServer.Destroy;
Begin
 If Assigned(vPoolerList) Then
  FreeAndNil(vPoolerList);
 FreeAndNil(vClientConnectionDefs);
 FreeAndNil(vProxyOptions);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Function TRESTDWBatchFieldsDefs.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

Function TRESTDWBatchFieldsDefs.GetRec(Index : Integer) : TRESTDWBatchFieldItem;
Begin
 Result := TRESTDWBatchFieldItem(Inherited GetItem(Index));
End;

Procedure TRESTDWBatchFieldsDefs.PutRec(Index: Integer; Item: TRESTDWBatchFieldItem);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
End;

procedure TRESTDWBatchFieldsDefs.ClearList;
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

Function TRESTDWBatchFieldsDefs.Add: TCollectionItem;
Begin
 Result := TRESTDWBatchFieldItem(Inherited Add);
End;

Procedure TRESTDWBatchFieldsDefs.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
End;

Procedure TRESTDWBatchFieldsDefs.Delete(Index : String);
Begin
 If ItemsByName[Index] <> Nil Then
  TOwnedCollection(Self).Delete(ItemsByName[Index].Index);
End;

Constructor TRESTDWBatchFieldsDefs.Create(AOwner      : TPersistent;
                                          aItemClass  : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWBatchFieldItem);
 fOwner  := AOwner;
End;

Destructor TRESTDWBatchFieldsDefs.Destroy;
Begin
 ClearList;
 Inherited;
End;

Procedure TRESTDWBatchFieldsDefs.PutRecName(Index        : String;
                                            Item         : TRESTDWBatchFieldItem);
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

Function  TRESTDWBatchFieldsDefs.GetRecName(Index : String)  : TRESTDWBatchFieldItem;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Result := TRESTDWBatchFieldItem(Self.Items[I]);
     Break;
    End;
  End;
End;

Constructor TRESTDWBatchFieldItem.Create(aCollection: TCollection);
Begin
 Inherited;
 vFieldConfig := [dwfk_Keyfield, dwfk_NotNull];
 vListName    := Trim(Format('FieldRule%d', [aCollection.Count -1]));
End;

Destructor TRESTDWBatchFieldItem.Destroy;
Begin
 Inherited;
End;

Function  TRESTDWBatchFieldItem.GetDisplayName             : String;
Begin
 Result := vListName;
End;

Procedure TRESTDWBatchFieldItem.SetDisplayName(Const Value : String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidConnectionName)
 Else
  Begin
   vListName := Value;
   Inherited;
  End;
End;

Function    TRESTDWConnectionServer.GetPoolerList     : TStringList;
Var
 I             : Integer;
 vTempDatabase : TRESTDWDatabasebaseBase;
Begin
 vTempDatabase := TRESTDWDatabasebaseBase.Create(Nil);
 Result                                := TStringList.Create;
 Try
  vTempDatabase.vAccessTag             := vAccessTag;
  vTempDatabase.Compression            := vCompression;
  vTempDatabase.TypeRequest            := vTypeRequest;
  vTempDatabase.DataRoute              := DataRoute;
  vTempDatabase.AuthenticationOptions.Assign(AuthenticationOptions);
  vTempDatabase.Proxy                  := vProxy;             //Diz se tem servidor Proxy
  vTempDatabase.ProxyOptions.vServer   := vProxyOptions.vServer;      //Se tem Proxy diz quais as opções
  vTempDatabase.ProxyOptions.vLogin    := vProxyOptions.vLogin;      //Se tem Proxy diz quais as opções
  vTempDatabase.ProxyOptions.vPassword := vProxyOptions.vPassword;      //Se tem Proxy diz quais as opções
  vTempDatabase.ProxyOptions.vPort     := vProxyOptions.vPort;      //Se tem Proxy diz quais as opções
  vTempDatabase.PoolerService          := vRestWebService;    //Host do WebService REST
  vTempDatabase.DataRoute              := vDataRoute;         //URL do WebService REST
  vTempDatabase.PoolerPort             := vPoolerPort;        //A Porta do Pooler do DataSet
//  vTempDatabase.PoolerName           := vRestPooler;        //Qual o Pooler de Conexão ligado ao componente
  vTempDatabase.RequestTimeOut         := vTimeOut;           //Timeout da Requisição
  vTempDatabase.ConnectTimeOut         := vConnectTimeOut;
  vTempDatabase.EncodedStrings         := vEncodeStrings;
  vTempDatabase.Encoding               := vEncoding;          //Encoding da string
  vTempDatabase.WelcomeMessage         := vWelcomeMessage;
  If Assigned(vPoolerList) Then
   FreeAndNil(vPoolerList);
  vPoolerList                          := vTempDatabase.GetRestPoolers;
  If Assigned(vPoolerList) Then
   Begin
    For I := 0 To vPoolerList.Count -1 Do
     Result.Add(vPoolerList[I]);
   End;
 Finally
  vTempDatabase.Active                 := False;
  FreeAndNil(vTempDatabase);
 End;
End;

Constructor TRESTDWConnectionServer.Create(aCollection: TCollection);
Begin
 Inherited;
 vPoolerList           := Nil;
 vClientConnectionDefs := TClientConnectionDefs.Create(Self);
 {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
  vEncoding            := esUtf8;
 {$ELSE}
  vEncoding            := esAscii;
 {$IFEND}
 vListName            :=  Format('server(%d)', [aCollection.Count]);
 vRestWebService      := '127.0.0.1';
 vCompression         := True;
 vBinaryRequest       := False;
 vAuthOptionParams    := TRESTDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vRestPooler          := '';
 vPoolerPort          := 8082;
 vProxy               := False;
 vEncodeStrings       := True;
 vProxyOptions        := TProxyOptions.Create;
 vTimeOut             := 10000;
 vConnectTimeOut      := 3000;
 vActive              := True;
 vDataRoute           := '';
End;

Function TListDefConnections.Add: TCollectionItem;
Begin
 Result := TRESTDWConnectionServer(Inherited Add);
End;

procedure TListDefConnections.ClearList;
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

Constructor TListDefConnections.Create(AOwner      : TPersistent;
                                        aItemClass  : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWConnectionServer);
 fOwner  := AOwner;
End;

Procedure TListDefConnections.Delete(Index : String);
Begin
 If ItemsByName[Index] <> Nil Then
  TOwnedCollection(Self).Delete(ItemsByName[Index].Index);
End;

Procedure TListDefConnections.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
End;

Destructor TListDefConnections.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TListDefConnections.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

Function  TListDefConnections.GetRecName(Index : String)  : TRESTDWConnectionServer;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Result := TRESTDWConnectionServer(Self.Items[I]);
     Break;
    End;
  End;
End;

Procedure TListDefConnections.PutRecName(Index        : String;
                                          Item         : TRESTDWConnectionServer);
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

function TListDefConnections.GetRec(Index : Integer) : TRESTDWConnectionServer;
begin
 Result := TRESTDWConnectionServer(Inherited GetItem(Index));
end;

procedure TListDefConnections.PutRec(Index: Integer; Item: TRESTDWConnectionServer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
end;

constructor TRESTDWThreadRequest.Create(aSelf                : TComponent;
                                        OnExecuteData,
                                        AbortData            : TOnExecuteData;
                                        OnThreadRequestError : TOnThreadRequestError);
Begin
 Inherited Create(False);
 vSelf                 := aSelf;
 vOnExecuteData        := OnExecuteData;
 vAbortData            := AbortData;
 vOnThreadRequestError := OnThreadRequestError;
 {$IFNDEF RESTDWLAZARUS}
  Priority              := tpLowest;
 {$ENDIF}
End;

Destructor TRESTDWThreadRequest.Destroy;
Begin
 Inherited;
End;

Procedure TRESTDWThreadRequest.Execute;
Begin
 If (Not(Terminated)) Then
  Begin
   Try
    If Assigned(vOnExecuteData) Then
     vOnExecuteData;
   Except
    On E : Exception Do
     Begin
      If Assigned(vOnThreadRequestError) Then
       vOnThreadRequestError(500, E.Message);
     End;
   End;
  End;
End;

Procedure TRESTDWThreadRequest.Kill;
Begin
 Terminate;
 ProcessMessages;
 If Assigned(vAbortData) Then
  vAbortData;
 ProcessMessages;
 If Assigned(vOnThreadRequestError) Then
  vOnThreadRequestError(499, 'Client Closed Request');
 ProcessMessages;
End;

Procedure TRESTDWThreadRequest.ProcessMessages;
Begin
// {$IFNDEF FPC}
//  {$IF Defined(HAS_FMX)}{$IF Not Defined(HAS_UTF8)}FMX.Forms.TApplication.ProcessMessages;{$IFEND}
//  {$ELSE}Application.Processmessages;{$IFEND}
// {$ENDIF}
End;

Procedure TRESTDWClientSQL.CloneDefinitions(Source  : TRESTDWMemtable;
                                            aSelf   : TRESTDWMemtable); //Fields em Definições
Var
 I, A : Integer;
Begin
 aSelf.Close;
 For I := 0 to Source.FieldDefs.Count -1 do
  Begin
   For A := 0 to aSelf.FieldDefs.Count -1 do
    If Uppercase(Source.FieldDefs[I].Name) = Uppercase(aSelf.FieldDefs[A].Name) Then
     Begin
      aSelf.FieldDefs.Delete(A);
      Break;
     End;
  End;
 For I := 0 to Source.FieldDefs.Count -1 do
  Begin
   If Trim(Source.FieldDefs[I].Name) <> '' Then
    Begin
     With aSelf.FieldDefs.AddFieldDef Do
      Begin
       Name     := Source.FieldDefs[I].Name;
       DataType := Source.FieldDefs[I].DataType;
       Size     := Source.FieldDefs[I].Size;
       Required := Source.FieldDefs[I].Required;
       CreateField(aSelf);
      End;
    End;
  End;
 If aSelf.FieldDefs.Count > 0 Then
  aSelf.Open;
End;

Procedure TRESTDWTable.PrepareDetailsNew;
Var
 I, J : Integer;
 vDetailClient : TRESTDWClientSQLBase;
 vOldInBlock   : Boolean;
Begin
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWTable(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWClientSQLBase(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     For J := 0 to TRESTDWTable(vDetailClient).Params.Count -1 Do
      TRESTDWTable(vDetailClient).Params[J].Clear;
     If vDetailClient.Active Then
      Begin
       vOldInBlock   := TRESTDWTable(vDetailClient).GetInBlockEvents;
       Try
        vDetailClient.SetInBlockEvents(True);
        If Self.State = dsInsert Then
         TRESTDWTable(vDetailClient).Newtable;
       Finally
        vDetailClient.SetInBlockEvents(vOldInBlock);
       End;
       TRESTDWTable(vDetailClient).ProcAfterScroll(vDetailClient);
      End
     Else
      Begin
       vOldInBlock   := TRESTDWTable(vDetailClient).GetInBlockEvents;
       Try
        vDetailClient.SetInBlockEvents(True);
        vDetailClient.Active := True;
       Finally
        vDetailClient.SetInBlockEvents(vOldInBlock);
       End;
      End;
    End;
  End;
End;


procedure TRESTDWClientSQL.PrepareDetailsNew;
Var
 I, J : Integer;
 vDetailClient : TRESTDWClientSQL;
 vOldInBlock   : Boolean;
Begin
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     For J := 0 to vDetailClient.Params.Count -1 do
      vDetailClient.Params[J].Clear;
     If vDetailClient.Active Then
      Begin
       vOldInBlock   := vDetailClient.GetInBlockEvents;
       Try
        vDetailClient.SetInBlockEvents(True);
        If Self.State = dsInsert Then
         vDetailClient.Newtable;
       Finally
        vDetailClient.SetInBlockEvents(vOldInBlock);
       End;
       vDetailClient.ProcAfterScroll(vDetailClient);
      End
     Else
      Begin
       vOldInBlock   := vDetailClient.GetInBlockEvents;
       Try
        vDetailClient.SetInBlockEvents(True);
        vDetailClient.Active := True;
       Finally
        vDetailClient.SetInBlockEvents(vOldInBlock);
       End;
      End;
    End;
  End;
End;

Procedure TRESTDWTable.PrepareDetails(ActiveMode: Boolean);
Var
 I, j : Integer;
 vDetailClient : TRESTDWTable;
 Function CloneDetails(Value : TRESTDWTable) : Boolean;
 Var
  I : Integer;
  vTempValue,
  vFieldA,
  vFieldD       : String;
 Begin
  Result := False;
  For I := 0 To Value.RelationFields.Count -1 Do
   Begin
    vTempValue := Value.RelationFields[I];
    vFieldA    := Copy(vTempValue, InitStrPos, (Pos('=', vTempValue) -1) - FinalStrPos);
    vFieldD    := Copy(vTempValue, (Pos('=', vTempValue) - FinalStrPos) + 1, Length(vTempValue));
    If (FindField(vFieldA) <> Nil) And (Value.ParamByName(vFieldD) <> Nil) Then
     Begin
      If Not Result Then
       Result := Not (Value.ParamByName(vFieldD).Value = FindField(vFieldA).Value);
      If (Value.ParamByName(vFieldD).Value = FindField(vFieldA).Value) then
       Continue;
      Value.ParamByName(vFieldD).DataType := FindField(vFieldA).DataType;
      Value.ParamByName(vFieldD).Size     := FindField(vFieldA).Size;
      If Value.ParamByName(vFieldD).DataType in [ftGuid] Then
       Begin
        If Not FindField(vFieldA).IsNull Then
         Begin
          {$IFDEF DELPHI10_2UP}
            Value.ParamByName(vFieldD).AsGUID := FindField(vFieldA).AsGUID;
          {$ELSE}
            Value.ParamByName(vFieldD).AsString := FindField(vFieldA).AsString;
          {$ENDIF}
         End
        Else
         Value.ParamByName(vFieldD).Clear;
       End
      Else
       Value.ParamByName(vFieldD).Value      := FindField(vFieldA).Value;
     End;
   End;
  For I := 0 To Value.Params.Count -1 Do
   Begin
    If FindField(Value.Params[I].Name) <> Nil Then
     Begin
      If Not Result Then
       Result := Not (Value.Params[I].Value = FindField(Value.Params[I].Name).Value) or (Value.Params[0].isnull);
      If ((Value.Params[I].Value = FindField(Value.Params[I].Name).Value)) And
         (Not(Value.Params[0].isnull)) Then
       Continue;
      Value.Params[I].DataType := FindField(Value.Params[I].Name).DataType;
      Value.Params[I].Size     := FindField(Value.Params[I].Name).Size;
      Value.Params[I].Value    := FindField(Value.Params[I].Name).Value;
     End;
   End;
 End;
Begin
 If vReadData Then
  Exit;
 If vMasterDetailList <> Nil Then
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWTable(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWTable(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     vDetailClient.vInactive := False;
     For J := 0 to vDetailClient.Params.Count -1 Do
      vDetailClient.Params[J].Clear;
     If CloneDetails(vDetailClient) Then
      Begin
       vDetailClient.Active := False;
       vDetailClient.Active := ActiveMode;
      End;
    End;
  End;
End;


Procedure TRESTDWClientSQL.PrepareDetails(ActiveMode: Boolean);
Var
 I, j : Integer;
 vDetailClient : TRESTDWClientSQL;
 Function CloneDetails(Value : TRESTDWClientSQL) : Boolean;
 Var
  I : Integer;
  vTempValue,
  vFieldA,
  vFieldD       : String;
 Begin
  Result := False;
  For I := 0 To Value.RelationFields.Count -1 Do
   Begin
    vTempValue := Value.RelationFields[I];
    vFieldA    := Copy(vTempValue, InitStrPos, (Pos('=', vTempValue) -1) - FinalStrPos);
    vFieldD    := Copy(vTempValue, (Pos('=', vTempValue) - FinalStrPos) + 1, Length(vTempValue));
    If (FindField(vFieldA) <> Nil) And (Value.ParamByName(vFieldD) <> Nil) Then
     Begin
      If Not Result Then
       Result := Not (Value.ParamByName(vFieldD).Value = FindField(vFieldA).Value);
      If (Value.ParamByName(vFieldD).Value = FindField(vFieldA).Value) then
       Continue;
      Value.ParamByName(vFieldD).DataType := FindField(vFieldA).DataType;
      Value.ParamByName(vFieldD).Size     := FindField(vFieldA).Size;
      If Value.ParamByName(vFieldD).DataType in [ftGuid] Then
       Begin
        If Not FindField(vFieldA).IsNull Then
         Begin
          {$IFDEF DELPHI10_2UP}
           Value.ParamByName(vFieldD).AsGUID := FindField(vFieldA).AsGUID;
          {$ELSE}
           Value.ParamByName(vFieldD).AsString := FindField(vFieldA).AsString;
          {$ENDIF}
         End
        Else
         Value.ParamByName(vFieldD).Clear;
       End
      Else
       Value.ParamByName(vFieldD).Value      := FindField(vFieldA).Value;
     End;
   End;
  For I := 0 To Value.Params.Count -1 Do
   Begin
    If FindField(Value.Params[I].Name) <> Nil Then
     Begin
      Value.Params[I].Clear;
      If Not Result Then
       Result := Not (Value.Params[I].Value = FindField(Value.Params[I].Name).Value) or (Value.Params[0].isnull);
      If ((Value.Params[I].Value = FindField(Value.Params[I].Name).Value)) And
         (Not(Value.Params[0].isnull)) Then
       Continue;
      Value.Params[I].DataType := FindField(Value.Params[I].Name).DataType;
      Value.Params[I].Size     := FindField(Value.Params[I].Name).Size;
      Value.Params[I].Value    := FindField(Value.Params[I].Name).Value;
     End;
   End;
 End;
Begin
 If vReadData Then
  Exit;
 If vMasterDetailList <> Nil Then
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).RelationFields.Text);
   vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     vDetailClient.vInactive := False;
     If CloneDetails(vDetailClient) Then
      Begin
       vDetailClient.Active := False;
       vDetailClient.Active := ActiveMode;
      End;
    End;
  End;
End;

Procedure TRESTDWTable.Post;
Begin
 {$IFDEF RESTDWLAZARUS}
 If State <> dsSetKey then // Lazarus bug
 {$ENDIF}
  Inherited;
 If State = dsSetKey Then
  Begin
   DataEvent(deCheckBrowseMode, 0);
   SetState(dsBrowse);
   DataEvent(deDataSetChange, 0);
  End;
End;

Procedure TRESTDWClientSQL.Post;
Begin
 {$IFDEF RESTDWLAZARUS}
 If State <> dsSetKey then // Lazarus bug
 {$ENDIF}
  Inherited;
 If State = dsSetKey Then
  Begin
   DataEvent(deCheckBrowseMode, 0);
   SetState(dsBrowse);
   DataEvent(deDataSetChange, 0);
  End;
End;


Function TRESTDWTable.OpenJson(JsonValue              : String = '';
                               Const ElementRoot      : String = '';
                               Const Utf8SpecialChars : Boolean = False) : Boolean;
Var
 LDataSetList  : TJSONValue;
 vMessageError : String;
 oDWResponseTranslator: TRESTDWResponseTranslator;
 vBool: Boolean;
Begin
  Result       := False;
  vBool := False;
  LDataSetList := Nil;
  Close;
  oDWResponseTranslator := vDWResponseTranslator;
  vBool := Not Assigned(vDWResponseTranslator);
  If vBool Then
   Begin
    oDWResponseTranslator := TRESTDWResponseTranslator.Create(Self);
    oDWResponseTranslator.ElementRootBaseName := ElementRoot;
    Self.ResponseTranslator := oDWResponseTranslator;
   End;
  LDataSetList := TJSONValue.Create;
  Try
   If JsonValue <> '' Then
    Begin
     LDataSetList.Encoded             := False;
     LDataSetList.Encoding            := esUtf8;
     LDataSetList.ServerFieldList     := ServerFieldList;
     {$IFDEF RESTDWLAZARUS}
      LDataSetList.DatabaseCharSet    := DatabaseCharSet;
      LDataSetList.NewFieldList       := @NewFieldList;
      LDataSetList.CreateDataSet      := @CreateDataSet;
      LDataSetList.NewDataField       := @NewDataField;
      LDataSetList.SetInitDataset     := @SetInitDataset;
      LDataSetList.SetRecordCount     := @SetRecordCount;
      LDataSetList.Setnotrepage       := @Setnotrepage;
      LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
      LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
      LDataSetList.FieldListCount     := @FieldListCount;
      LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
      LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
      LDataSetList.PrepareDetails     := @PrepareDetails;
     {$ELSE}
      LDataSetList.NewFieldList       := NewFieldList;
      LDataSetList.CreateDataSet      := CreateDataSet;
      LDataSetList.NewDataField       := NewDataField;
      LDataSetList.SetInitDataset     := SetInitDataset;
      LDataSetList.SetRecordCount     := SetRecordCount;
      LDataSetList.Setnotrepage       := Setnotrepage;
      LDataSetList.SetInDesignEvents  := SetInDesignEvents;
      LDataSetList.SetInBlockEvents   := SetInBlockEvents;
      LDataSetList.FieldListCount     := FieldListCount;
      LDataSetList.GetInDesignEvents  := GetInDesignEvents;
      LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
      LDataSetList.PrepareDetails     := PrepareDetails;
     {$ENDIF}
     LDataSetList.Utf8SpecialChars    := Utf8SpecialChars;
     Try
      LDataSetList.OnWriterProcess    := OnWriterProcess;
      LDataSetList.Utf8SpecialChars   := True;
      LDataSetList.WriteToDataset(JsonValue, Self, oDWResponseTranslator, rtJSONAll);
      Result := True;
     Except
      On E : Exception Do
       Begin
        Raise Exception.Create(E.Message);
       End;
     End;
    End;
  Finally
   If (LDataSetList <> Nil) Then
    FreeAndNil(LDataSetList);
   If (oDWResponseTranslator <> nil) And (vBool) Then
    Begin
     FreeAndNil(oDWResponseTranslator);
     ResponseTranslator := Nil;
    End;
   vInBlockEvents  := False;
  End;
End;

// ajuste 19/12/2018 - Thiago Pedro - https://pastebin.com/mFBxbhkN
Function TRESTDWClientSQL.OpenJson(JsonValue              : String = '';
                                   Const ElementRoot      : String = '';
                                   Const Utf8SpecialChars : Boolean = False) : Boolean;
Var
 LDataSetList  : TJSONValue;
 vMessageError : String;
 oDWResponseTranslator: TRESTDWResponseTranslator;
 vBool: Boolean;
Begin
  Result       := False;
  vBool := False;
  LDataSetList := Nil;
  Close;
  oDWResponseTranslator := vDWResponseTranslator;
  vBool := Not Assigned(vDWResponseTranslator);
  If vBool Then
   Begin
    oDWResponseTranslator := TRESTDWResponseTranslator.Create(Self);
    oDWResponseTranslator.ElementRootBaseName := ElementRoot;
    Self.ResponseTranslator := oDWResponseTranslator;
   End;
  LDataSetList := TJSONValue.Create;
  Try
   If JsonValue <> '' Then
    Begin
     LDataSetList.Encoded  := False;
     LDataSetList.Encoding := esUtf8;
     LDataSetList.ServerFieldList := ServerFieldList;
     {$IFDEF RESTDWLAZARUS}
      LDataSetList.DatabaseCharSet := DatabaseCharSet;
      LDataSetList.NewFieldList    := @NewFieldList;
      LDataSetList.CreateDataSet   := @CreateDataSet;
      LDataSetList.NewDataField    := @NewDataField;
      LDataSetList.SetInitDataset  := @SetInitDataset;
      LDataSetList.SetRecordCount     := @SetRecordCount;
      LDataSetList.Setnotrepage       := @Setnotrepage;
      LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
      LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
      LDataSetList.SetInactive        := @SetInactive;
      LDataSetList.FieldListCount     := @FieldListCount;
      LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
      LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
      LDataSetList.PrepareDetails     := @PrepareDetails;
     {$ELSE}
      LDataSetList.NewFieldList    := NewFieldList;
      LDataSetList.CreateDataSet   := CreateDataSet;
      LDataSetList.NewDataField    := NewDataField;
      LDataSetList.SetInitDataset  := SetInitDataset;
      LDataSetList.SetRecordCount     := SetRecordCount;
      LDataSetList.Setnotrepage       := Setnotrepage;
      LDataSetList.SetInDesignEvents  := SetInDesignEvents;
      LDataSetList.SetInBlockEvents   := SetInBlockEvents;
      LDataSetList.SetInactive        := SetInactive;
      LDataSetList.FieldListCount     := FieldListCount;
      LDataSetList.GetInDesignEvents  := GetInDesignEvents;
      LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
      LDataSetList.PrepareDetails     := PrepareDetails;
     {$ENDIF}
     LDataSetList.Utf8SpecialChars := Utf8SpecialChars;
     Try
      LDataSetList.OnWriterProcess := OnWriterProcess;
      LDataSetList.Utf8SpecialChars := True;
      LDataSetList.WriteToDataset(JsonValue, Self, oDWResponseTranslator, rtJSONAll);
      Result := True;
     Except
      On E : Exception Do
       Begin
        Raise Exception.Create(E.Message);
       End;
     End;
    End;
  Finally
   If (LDataSetList <> Nil) Then
    FreeAndNil(LDataSetList);
   If (oDWResponseTranslator <> nil) And (vBool) Then
    Begin
     FreeAndNil(oDWResponseTranslator);
     ResponseTranslator := Nil;
    End;
   vInBlockEvents  := False;
  End;
End;

Function TRESTDWTable.GetData(DataSet: TJSONValue): Boolean;
Var
 LDataSetList  : TJSONValue;
 vError        : Boolean;
 vValue,
 vMessageError : String;
 vStream       : TMemoryStream;
 vTempDS       : TRESTDWClientSQLBase;
 Procedure NewBinaryFieldList;
 Var
  J                : Integer;
  vFieldDefinition : TFieldDefinition;
 Begin
  NewFieldList;
  vFieldDefinition := TFieldDefinition.Create;
  Try
   If vTempDS <> Nil Then
    Begin
     If (vTempDS.Fields.Count > 0) Then
      Begin
       For J := 0 To vTempDS.Fields.Count - 1 Do
        Begin
         If vTempDS.Fields[J].FieldKind = fkData Then
          Begin
           vFieldDefinition.FieldName := vTempDS.Fields[J].FieldName;
           vFieldDefinition.DataType  := vTempDS.Fields[J].DataType;
           If (vFieldDefinition.DataType <> ftFloat) Then
            vFieldDefinition.Size     := vTempDS.Fields[J].Size
           Else
            vFieldDefinition.Size         := 0;
           If (vFieldDefinition.DataType In [ftCurrency, ftBCD,
                                             {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                             {$IFEND}{$ENDIF} ftFMTBcd]) Then
            vFieldDefinition.Precision := TBCDField(vTempDS.Fields[J]).Precision
           Else If (vFieldDefinition.DataType = ftFloat) Then
            vFieldDefinition.Precision := TFloatField(vTempDS.Fields[J]).Precision;
           vFieldDefinition.Required   := vTempDS.Fields[J].Required;
           NewDataField(vFieldDefinition);
          End;
        End;
      End;
    End;
  Finally
   FreeAndNil(vFieldDefinition);
  End;
 End;
Begin
 vValue        := '';
 Result        := False;
 LDataSetList  := Nil;
 vStream       := Nil;
 vRowsAffected := 0;
 Self.Close;
 If Assigned(vDWResponseTranslator) Then
  Begin
   LDataSetList          := TJSONValue.Create;
   Try
    LDataSetList.Encoded  := False;
    If Assigned(vDWResponseTranslator.ClientREST) Then
     LDataSetList.Encoding := TRESTDWClientRESTBase(vDWResponseTranslator.ClientREST).RequestCharset;
    Try
     vValue := vDWResponseTranslator.Open(vDWResponseTranslator.RequestOpen,
                                          vDWResponseTranslator.RequestOpenUrl);
    Except
     Self.Close;
    End;
    If vValue = '[]' Then
     vValue := '';
    {$IFDEF FPC}
     vValue := StringReplace(vValue, #10, '', [rfReplaceAll]);
    {$ELSE}
     vValue := StringReplace(vValue, #$A, '', [rfReplaceAll]);
    {$ENDIF}
    vError := vValue = '';
    If (Assigned(LDataSetList)) And (Not (vError)) Then
     Begin
      Try
       LDataSetList.ServerFieldList := ServerFieldList;
       {$IFDEF FPC}
        LDataSetList.DatabaseCharSet := DatabaseCharSet;
        LDataSetList.NewFieldList    := @NewFieldList;
        LDataSetList.CreateDataSet   := @CreateDataSet;
        LDataSetList.NewDataField    := @NewDataField;
        LDataSetList.SetInitDataset  := @SetInitDataset;
        LDataSetList.SetRecordCount     := @SetRecordCount;
        LDataSetList.Setnotrepage       := @Setnotrepage;
        LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
        LDataSetList.FieldListCount     := @FieldListCount;
        LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
        LDataSetList.PrepareDetails     := @PrepareDetails;
       {$ELSE}
        LDataSetList.NewFieldList    := NewFieldList;
        LDataSetList.CreateDataSet   := CreateDataSet;
        LDataSetList.NewDataField    := NewDataField;
        LDataSetList.SetInitDataset  := SetInitDataset;
        LDataSetList.SetRecordCount     := SetRecordCount;
        LDataSetList.Setnotrepage       := Setnotrepage;
        LDataSetList.SetInDesignEvents  := SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := SetInBlockEvents;
        LDataSetList.FieldListCount     := FieldListCount;
        LDataSetList.GetInDesignEvents  := GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
        LDataSetList.PrepareDetails     := PrepareDetails;
       {$ENDIF}
       LDataSetList.OnWriterProcess := OnWriterProcess;
       LDataSetList.Utf8SpecialChars := True;
       LDataSetList.WriteToDataset(vValue, Self, vDWResponseTranslator, rtJSONAll);
       Result := True;
      Except
      End;
     End;
   Finally
    LDataSetList.Free;
   End;
  End
 Else If Assigned(vRESTDataBase) Then
  Begin
   Try
    If DataSet = Nil Then
     Begin
      vRESTDataBase.ExecuteCommandTB(vActualPoolerMethodClient, vTablename, vParams, vError, vMessageError, LDataSetList,
                                     vRowsAffected, BinaryRequest,  True, Fields.Count = 0, Nil);
      If LDataSetList <> Nil Then
       Begin
        If BinaryRequest Then
         Begin
          If Not LDataSetList.IsNull Then
           vValue := LDataSetList.Value;
         End;
        LDataSetList.Encoded  := vRESTDataBase.EncodedStrings;
        LDataSetList.Encoding := DataBase.Encoding;
        If Not BinaryRequest Then
         Begin
          If Not LDataSetList.IsNull Then
           vValue := LDataSetList.ToJSON;
         End;
       End;
     End
    Else
     Begin
      If Not DataSet.IsNull Then
       vValue                := DataSet.Value;
      LDataSetList          := TJSONValue.Create;
      LDataSetList.Encoded  := vRESTDataBase.EncodedStrings;
      LDataSetList.Encoding := DataBase.Encoding;
      vError                := False;
     End;
    If (Assigned(LDataSetList)) And (Not (vError)) Then
     Begin
      Try
       vActualJSON := vValue;
       vActualRec  := 0;
       vJsonCount  := 0;
       LDataSetList.OnWriterProcess := OnWriterProcess;
       LDataSetList.ServerFieldList := ServerFieldList;
       {$IFDEF FPC}
        LDataSetList.DatabaseCharSet := DatabaseCharSet;
        LDataSetList.NewFieldList    := @NewFieldList;
        LDataSetList.CreateDataSet   := @CreateDataSet;
        LDataSetList.NewDataField    := @NewDataField;
        LDataSetList.SetInitDataset  := @SetInitDataset;
        LDataSetList.SetRecordCount     := @SetRecordCount;
        LDataSetList.Setnotrepage       := @Setnotrepage;
        LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
        LDataSetList.FieldListCount     := @FieldListCount;
        LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
        LDataSetList.PrepareDetails     := @PrepareDetails;
       {$ELSE}
        LDataSetList.NewFieldList    := NewFieldList;
        LDataSetList.CreateDataSet   := CreateDataSet;
        LDataSetList.NewDataField    := NewDataField;
        LDataSetList.SetInitDataset  := SetInitDataset;
        LDataSetList.SetRecordCount     := SetRecordCount;
        LDataSetList.Setnotrepage       := Setnotrepage;
        LDataSetList.SetInDesignEvents  := SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := SetInBlockEvents;
        LDataSetList.FieldListCount     := FieldListCount;
        LDataSetList.GetInDesignEvents  := GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
        LDataSetList.PrepareDetails     := PrepareDetails;
       {$ENDIF}
       LDataSetList.Utf8SpecialChars := True;
       SetInBlockEvents(True);
       If Not BinaryRequest Then
        LDataSetList.WriteToDataset(dtFull, vValue, Self, vJsonCount, vDatapacks, vActualRec)
       Else
        Begin
         vStream         := DecodeStream(vValue);
         If (csDesigning in ComponentState) Then //Clone end compare Fields
          Begin
           vStream.Position := 0;
           vTempDS := TRESTDWClientSQL.Create(Nil);
           Try
            TRESTDWClientSQL(vTempDS).LoadFromStream(vStream);
            NewBinaryFieldList;
           Finally
            FreeAndNil(vTempDS);
           End;
          End;
         vStream.Position := 0;
         SetInBlockEvents(True);
         Try
          TRESTDWClientSQLBase(Self).LoadFromStream(TMemoryStream(vStream));
          TRESTDWClientSQLBase(Self).DisableControls;
          SetInBlockEvents(True);
          If TRESTDWClientSQLBase(Self).Active Then
           Begin
            TRESTDWClientSQLBase(Self).SetInBlockEvents(True); // Novavix
            TRESTDWClientSQLBase(Self).Last;
            TRESTDWClientSQLBase(Self).SetInBlockEvents(False); // Novavix
            If TRESTDWClientSQLBase(Self).Recordcount > 0 Then
             vJsonCount := TRESTDWClientSQLBase(Self).Recordcount
            Else
             vJsonCount := TRESTDWClientSQLBase(Self).RecNo;
            //A Linha a baixo e pedido do Tiago Istuque que não mostrava o recordcount com BN
            TRESTDWClientSQL(Self).SetRecordCount(vJsonCount, vJsonCount);
            TRESTDWClientSQLBase(Self).SetInBlockEvents(True); // Novavix
            TRESTDWClientSQLBase(Self).First;
            TRESTDWClientSQLBase(Self).SetInBlockEvents(False); // Novavix
           End;
         Finally
          TRESTDWClientSQLBase(Self).EnableControls;
          SetInBlockEvents(False);
          If Active Then
           If Not (vInBlockEvents) and not vBinaryRequest and not vInRefreshData Then
            Begin
             If Assigned(vOnAfterOpen) Then
              vOnAfterOpen(Self);
            End;
          If Assigned(vStream) Then
           FreeAndNil(vStream);
          If State = dsBrowse Then
           Begin
            If RecordCount = 0 Then
             PrepareDetailsNew
            Else
             PrepareDetails(True);
           End;
         End;
        End;
       If vDatapacks <> -1 Then
        Begin
         vOldRecordCount := vDatapacks;
         If vOldRecordCount > vJsonCount Then
          vOldRecordCount := vJsonCount;
        End;
       Result := True;
      Except
       On E: Exception Do
        Begin
         If Assigned(vStream) Then
          FreeAndNil(vStream);
         If Assigned(LDataSetList) Then
          FreeAndNil(LDataSetList);
         Raise Exception.Create(E.Message);
        End;
      End;
     End;
   Except
    On E: Exception Do
     Raise Exception.Create(E.Message);
   End;
   If (LDataSetList <> Nil) Then
    FreeAndNil(LDataSetList);
   If vError Then
    Begin
     If csDesigning in ComponentState Then
      Raise Exception.Create(PChar(vMessageError))
     Else
      Begin
       If Assigned(vOnGetDataError) Then
        vOnGetDataError(Not(vError), vMessageError)
       Else
        Raise Exception.Create(PChar(vMessageError));
      End;
    End;
  End
 Else If csDesigning in ComponentState Then
  Raise Exception.Create(PChar(cEmptyDBName));
End;

Function TRESTDWClientSQL.GetData(DataSet: TJSONValue): Boolean;
Var
 I             : Integer;
 LDataSetList  : TJSONValue;
 vMetadata,
 vError        : Boolean;
 vValue,
 vMessageError : String;
 vStream       : TMemoryStream;
 vTempDS       : TRESTDWClientSQLBase;
 Procedure NewBinaryFieldList;
 Var
  J                : Integer;
  vFieldDefinition : TFieldDefinition;
 Begin
  NewFieldList;
  vFieldDefinition := TFieldDefinition.Create;
  Try
   If vTempDS <> Nil Then
    Begin
     If (vTempDS.Fields.Count > 0) Then
      Begin
       For J := 0 To vTempDS.Fields.Count - 1 Do
        Begin
         vFieldDefinition.FieldName := vTempDS.Fields[J].Name;
         vFieldDefinition.DataType  := vTempDS.Fields[J].DataType;
         If (vFieldDefinition.DataType <> ftFloat) Then
          vFieldDefinition.Size     := vTempDS.Fields[J].Size
         Else
          vFieldDefinition.Size         := 0;
         If (vFieldDefinition.DataType
            In [ftCurrency, ftBCD, {$IFDEF DELPHIXEUP}ftExtended, ftSingle,{$ENDIF}
                ftFMTBcd]) Then
          vFieldDefinition.Precision := TBCDField(vTempDS.Fields[J]).Precision
         Else If (vFieldDefinition.DataType = ftFloat) Then
          vFieldDefinition.Precision := TFloatField(vTempDS.Fields[J]).Precision;
         vFieldDefinition.Required   := vTempDS.Fields[J].Required;
         NewDataField(vFieldDefinition);
        End;
      End;
    End;
  Finally
   FreeAndNil(vFieldDefinition);
  End;
 End;
Begin
 vValue        := '';
 Result        := False;
 LDataSetList  := Nil;
 vStream       := Nil;
 vRowsAffected := 0;
 Self.Close;
 If Assigned(vDWResponseTranslator) Then
  Begin
   LDataSetList          := TJSONValue.Create;
   Try
    LDataSetList.Encoded  := False;
    If Assigned(vDWResponseTranslator.ClientREST) Then
     LDataSetList.Encoding := TRESTDWClientRESTBase(vDWResponseTranslator.ClientREST).RequestCharset;
    Try
     vValue := vDWResponseTranslator.Open(vDWResponseTranslator.RequestOpen,
                                          vDWResponseTranslator.RequestOpenUrl);
    Except
     Self.Close;
    End;
    If vValue = '[]' Then
     vValue := '';
    {$IFDEF RESTDWLAZARUS}
     vValue := StringReplace(vValue, #10, '', [rfReplaceAll]);
    {$ELSE}
     vValue := StringReplace(vValue, #$A, '', [rfReplaceAll]);
    {$ENDIF}
    vError := vValue = '';
    If (Assigned(LDataSetList)) And (Not (vError)) Then
     Begin
      Try
       LDataSetList.ServerFieldList := ServerFieldList;
       {$IFDEF RESTDWLAZARUS}
        LDataSetList.DatabaseCharSet := DatabaseCharSet;
        LDataSetList.NewFieldList    := @NewFieldList;
        LDataSetList.CreateDataSet   := @CreateDataSet;
        LDataSetList.NewDataField    := @NewDataField;
        LDataSetList.SetInitDataset  := @SetInitDataset;
        LDataSetList.SetRecordCount     := @SetRecordCount;
        LDataSetList.Setnotrepage       := @Setnotrepage;
        LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
        LDataSetList.SetInactive        := @SetInactive;
        LDataSetList.FieldListCount     := @FieldListCount;
        LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
        LDataSetList.PrepareDetails     := @PrepareDetails;
       {$ELSE}
        LDataSetList.NewFieldList    := NewFieldList;
        LDataSetList.CreateDataSet   := CreateDataSet;
        LDataSetList.NewDataField    := NewDataField;
        LDataSetList.SetInitDataset  := SetInitDataset;
        LDataSetList.SetRecordCount     := SetRecordCount;
        LDataSetList.Setnotrepage       := Setnotrepage;
        LDataSetList.SetInDesignEvents  := SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := SetInBlockEvents;
        LDataSetList.SetInactive        := SetInactive;
        LDataSetList.FieldListCount     := FieldListCount;
        LDataSetList.GetInDesignEvents  := GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
        LDataSetList.PrepareDetails     := PrepareDetails;
       {$ENDIF}
       LDataSetList.OnWriterProcess := OnWriterProcess;
       LDataSetList.Utf8SpecialChars := True;
       LDataSetList.WriteToDataset(vValue, Self, vDWResponseTranslator, rtJSONAll);
       Result := True;
      Except
      End;
     End;
   Finally
    LDataSetList.Free;
   End;
  End
 Else If Assigned(vRESTDataBase) Then
// If Assigned(vRESTDataBase) Then
  Begin
   Try
    If DataSet = Nil Then
     Begin
      vMetaData := True;
      If Assigned(FieldDefs) Then
       vMetaData := FieldDefs.Count = 0;
      For I := 0 To 1 Do
       Begin
        vRESTDataBase.ExecuteCommand(vActualPoolerMethodClient, vSQL, vParams, vError, vMessageError, LDataSetList,
                                     vRowsAffected, False, BinaryRequest,  True, vMetaData, vRESTDataBase.RESTClientPooler);
        If Not(vError) or (vMessageError <> cInvalidAuth) Then
         Break;
       End;
      If LDataSetList <> Nil Then
       Begin
        If BinaryRequest Then
         Begin
         If Not LDataSetList.IsNull Then
           Begin
            vStream := TMemoryStream.Create;
            LDataSetList.SaveToStream(vStream); //vValue := LDataSetList.Value;
           End;
         End
        Else
         Begin
          LDataSetList.Encoded  := vRESTDataBase.EncodedStrings;
          LDataSetList.Encoding := DataBase.Encoding;
          If Not LDataSetList.IsNull Then
           vValue := LDataSetList.ToJSON;
         End;
       End;
     End
    Else
     Begin
      If Not DataSet.IsNull Then
       vValue                := DataSet.Value;
      LDataSetList          := TJSONValue.Create;
      LDataSetList.Encoded  := vRESTDataBase.EncodedStrings;
      LDataSetList.Encoding := DataBase.Encoding;
      vError                := False;
     End;
    If (Assigned(LDataSetList)) And (Not (vError)) Then
     Begin
      Try
       vActualJSON := vValue;
       vActualRec  := 0;
       vJsonCount  := 0;
       LDataSetList.OnWriterProcess     := OnWriterProcess;
       LDataSetList.ServerFieldList := ServerFieldList;
       {$IFDEF RESTDWLAZARUS}
        LDataSetList.DatabaseCharSet    := DatabaseCharSet;
        LDataSetList.NewFieldList       := @NewFieldList;
        LDataSetList.CreateDataSet      := @CreateDataSet;
        LDataSetList.NewDataField       := @NewDataField;
        LDataSetList.SetInitDataset     := @SetInitDataset;
        LDataSetList.SetRecordCount     := @SetRecordCount;
        LDataSetList.Setnotrepage       := @Setnotrepage;
        LDataSetList.SetInDesignEvents  := @SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := @SetInBlockEvents;
        LDataSetList.SetInactive        := @SetInactive;
        LDataSetList.FieldListCount     := @FieldListCount;
        LDataSetList.GetInDesignEvents  := @GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := @PrepareDetailsNew;
        LDataSetList.PrepareDetails     := @PrepareDetails;
        LDataSetList.ServerFieldList    := ServerFieldList;
       {$ELSE}
        LDataSetList.NewFieldList       := NewFieldList;
        LDataSetList.CreateDataSet      := CreateDataSet;
        LDataSetList.NewDataField       := NewDataField;
        LDataSetList.SetInitDataset     := SetInitDataset;
        LDataSetList.SetRecordCount     := SetRecordCount;
        LDataSetList.Setnotrepage       := Setnotrepage;
        LDataSetList.SetInDesignEvents  := SetInDesignEvents;
        LDataSetList.SetInBlockEvents   := SetInBlockEvents;
        LDataSetList.SetInactive        := SetInactive;
        LDataSetList.FieldListCount     := FieldListCount;
        LDataSetList.GetInDesignEvents  := GetInDesignEvents;
        LDataSetList.PrepareDetailsNew  := PrepareDetailsNew;
        LDataSetList.PrepareDetails     := PrepareDetails;
        LDataSetList.ServerFieldList    := ServerFieldList;
       {$ENDIF}
       LDataSetList.Utf8SpecialChars := True;
       If Not BinaryRequest Then
        LDataSetList.WriteToDataset(dtFull, vValue, Self, vJsonCount, vDatapacks, vActualRec)
       Else
        Begin
         If (csDesigning in ComponentState) Then //Clone end compare Fields
          Begin
           vStream.Position := 0;
           vTempDS := TRESTDWClientSQLBase.Create(Nil);
           Try
            TRESTDWClientSQLBase(vTempDS).LoadFromStream(TMemoryStream(vStream));
            NewBinaryFieldList;
           Finally
            FreeAndNil(vTempDS);
           End;
          End;
         vStream.Position := 0;
         SetInBlockEvents(True);
         Try
          TRESTDWClientSQLBase(Self).DisableControls;
          TRESTDWClientSQLBase(Self).LoadFromStream(TMemoryStream(vStream));
          If TRESTDWClientSQLBase(Self).Active Then
           Begin
            TRESTDWClientSQLBase(Self).SetInBlockEvents(True); // Novavix
            TRESTDWClientSQLBase(Self).Last;
            TRESTDWClientSQLBase(Self).SetInBlockEvents(False); // Novavix
            If TRESTDWClientSQLBase(Self).Recordcount > 0 Then
             vJsonCount := TRESTDWClientSQLBase(Self).Recordcount
            Else
             vJsonCount := TRESTDWClientSQLBase(Self).RecNo;
//            //A Linha a baixo e pedido do Tiago Istuque que não mostrava o recordcount com BN
            TRESTDWClientSQLBase(Self).SetInBlockEvents(True); // Novavix
            TRESTDWClientSQL(Self).SetRecordCount(vJsonCount, vJsonCount);
            TRESTDWClientSQL(Self).First;
            TRESTDWClientSQLBase(Self).SetInBlockEvents(False); // Novavix
           End;
         Finally
          TRESTDWClientSQLBase(Self).EnableControls;
          SetInBlockEvents(False);
          If Active Then
           If Not (vInBlockEvents) and not vBinaryRequest and not vInRefreshData Then
            Begin
             If Assigned(vOnAfterOpen) Then
              vOnAfterOpen(Self);
            End;
          If Assigned(vStream) Then
           FreeAndNil(vStream);
          If State = dsBrowse Then
           Begin
            If RecordCount = 0 Then
             PrepareDetailsNew
            Else
             PrepareDetails(True);
           End;
         End;
        End;
       If vDatapacks <> -1 Then
        Begin
         vOldRecordCount := vDatapacks;
         If vOldRecordCount > vJsonCount Then
          vOldRecordCount := vJsonCount;
        End;
       Result := True;
      Except
       On E: Exception Do
        Begin
         If Assigned(vStream) Then
          FreeAndNil(vStream);
         If Assigned(LDataSetList) Then
          FreeAndNil(LDataSetList);
         Raise Exception.Create(E.Message);
        End;
      End;
     End;
   Except
    On E: Exception Do
     Raise Exception.Create(E.Message);
   End;
   If (LDataSetList <> Nil) Then
    FreeAndNil(LDataSetList);
   If vError Then
    Begin
     If csDesigning in ComponentState Then
      Raise Exception.Create(PChar(vMessageError))
     Else
      Begin
       If Assigned(vOnGetDataError) Then
        vOnGetDataError(Not(vError), vMessageError)
       Else
        Raise Exception.Create(PChar(vMessageError));
      End;
    End;
  End
 Else If csDesigning in ComponentState Then
  Raise Exception.Create(PChar(cEmptyDBName));
End;

Function TRESTDWTable.GetDWResponseTranslator: TRESTDWResponseTranslator;
Begin
 Result := vDWResponseTranslator;
End;

function TRESTDWClientSQL.GetDWResponseTranslator: TRESTDWResponseTranslator;
begin
  Result := vDWResponseTranslator;
end;

Function TRESTDWTable.GetFieldListByName(aName: String): TFieldDefinition;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Length(vFieldsList) -1 Do
  Begin
   If UpperCase(vFieldsList[I].FieldName) = Uppercase(aName) Then
    Begin
     Result := vFieldsList[I];
     Break;
    End;
  End;
End;

Function TRESTDWClientSQL.GetFieldListByName(aName: String): TFieldDefinition;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Length(vFieldsList) -1 Do
  Begin
   If UpperCase(vFieldsList[I].FieldName) = Uppercase(aName) Then
    Begin
     Result := vFieldsList[I];
     Break;
    End;
  End;
End;

Function TRESTDWTable.GetInBlockEvents: Boolean;
Begin
 Result := vInBlockEvents;
End;

Function TRESTDWClientSQL.GetInBlockEvents: Boolean;
Begin
 Result := vInBlockEvents;
End;

Function TRESTDWTable.GetInDesignEvents: Boolean;
Begin
 Result := vInDesignEvents;
End;

Function TRESTDWClientSQL.GetInDesignEvents: Boolean;
Begin
 Result := vInDesignEvents;
End;

Function TRESTDWTable.GetMassiveCache : TRESTDWMassiveCache;
begin
  Result := vMassiveCache;
end;

function TRESTDWClientSQL.GetMassiveCache: TRESTDWMassiveCache;
begin
  Result := vMassiveCache;
end;

Function TRESTDWTable.GetRecordCount : Integer;
Begin
 If Not Filtered Then
  Result := vJsonCount
 Else
  Result := Inherited GetRecordCount;
End;

Function TRESTDWClientSQL.GetRecordCount : Integer;
Begin
 If Not vInBlockEvents Then
  Begin
   If Not Filtered Then
    Result := vJsonCount
   Else
    Result := Inherited GetRecordCount;
  End
 Else
  Result := Inherited GetRecordCount;
End;

Procedure TRESTDWTable.SaveToStream(Var Stream : TMemoryStream);
Begin
 If Not Assigned(Stream) then
  Exit;
 vInBlockEvents := True;
 Try
  TRESTDWClientSQLBase(Self).SaveToStream(TStream(Stream));
 Finally
  vInBlockEvents := False;
 End;
End;

Procedure TRESTDWClientSQL.SaveToStream(Var Stream : TMemoryStream);
Begin
 If Not Assigned(Stream) then
  Exit;
 vInBlockEvents := True;
 Try
  TRESTDWClientSQLBase(Self).SaveToStream(TStream(Stream));
 Finally
  vInBlockEvents := False;
 End;
End;

Procedure TRESTDWTable.CreateMassiveDataset;
Begin
 If Trim(vTableName) <> '' Then
  Begin
   vLastOpen := Random(9999);
   TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vTableName));
  End;
End;

procedure TRESTDWClientSQL.CreateMassiveDataset;
Begin
 If Trim(vUpdateTableName) <> '' Then
  Begin
   vLastOpen := Random(9999);
   TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vUpdateTableName));
  End;
End;

procedure TRESTDWClientSQL.ExecuteOpen;
Begin
 Try
  If (Not vInDesignEvents) Then
   ProcBeforeOpen(Self);
  vInBlockEvents := True;
  Filter         := '';
  Filtered       := False;
  vInBlockEvents := False;
  GetNewData     := Filtered;
  vActive        := (GetData) And Not(vInDesignEvents);
  GetNewData     := Not vActive;
  If Not (vInBlockEvents) and not vInRefreshData Then
   Begin
    If Assigned(vOnAfterOpen) Then
     vOnAfterOpen(Self);
   End;
  If vInDesignEvents Then
   Begin
    vInactive       := False;
    vInDesignEvents := False;
    vInBlockEvents  := vInDesignEvents;
    Exit;
   End;
  If State = dsBrowse Then
   CreateMassiveDataset;
//  If BinaryRequest        Then
//   Begin
//    If Assigned(OnCalcFields) Then
//     Begin
//      DisableControls;
//      Last;
//      First;
//      EnableControls;
//     End;
//   End;
 Except
  Raise;
 End;
End;

Procedure TRESTDWTable.SetActiveDB(Value: Boolean);
Begin
 Try
//  ChangeCursor;
  If (vInactive) And Not(vInDesignEvents) Then
   Begin
    vActive := (Value) And Not(vInDesignEvents);
    If vActive Then
     BaseOpen
    Else
     Begin
      BaseClose;
      vinactive := False;
     End;
    Exit;
   End;
  If (vActive) Then //And (Assigned(vDWResponseTranslator)) Then
   vActive := False;
//  If Assigned(vDWResponseTranslator) Then
//   Begin
//    If vDWResponseTranslator.FieldDefs.Count <> FieldDefs.Count Then
//     FieldDefs.Clear;
//   End;
//  If ((vDWResponseTranslator <> Nil) Or (vRESTDataBase <> Nil)) And (Value) Then
  If ((vRESTDataBase <> Nil)) And (Value) Then
   Begin
//    If Not Assigned(vDWResponseTranslator) Then
//     Begin
      If vRESTDataBase <> Nil Then
       If Not vRESTDataBase.Active Then
        vRESTDataBase.Active := True;
      If Not vRESTDataBase.Active then
       Begin
        vActive := False;
        Exit;
       End;
//     End;
    Try
     If (Not(vActive) And (Value)) Or (GetNewData) Or (vInDesignEvents) Then
      Begin
       GetNewData := False;
       If (Not vInDesignEvents) Then
        ProcBeforeOpen(Self);
       vInBlockEvents := True;
       Filter         := '';
       Filtered       := False;
       vInBlockEvents := False;
       GetNewData     := Filtered;
       vActive        := (GetData) And Not(vInDesignEvents);
       GetNewData     := Not vActive;
       If Not (vInBlockEvents) and not vInRefreshData Then
        Begin
         If Assigned(vOnAfterOpen) Then
          vOnAfterOpen(Self);
        End;
       If vInDesignEvents Then
        Begin
         vInactive       := False;
         vInDesignEvents := False;
         vInBlockEvents  := vInDesignEvents;
         Exit;
        End;
       If State = dsBrowse Then
        CreateMassiveDataset;
      End
     Else
      Begin
       If State = dsBrowse Then
        Begin
         CreateMassiveDataset;
         PrepareDetails(True);
        End
       Else If State = dsInactive Then
        PrepareDetails(False);
      End;
    Except
     On E : Exception do
      Begin
       vInBlockEvents := False;
       If csDesigning in ComponentState Then
        Raise Exception.Create(PChar(E.Message))
       Else
        Begin
         If Assigned(vOnGetDataError) Then
          vOnGetDataError(False, E.Message);
         If (vRaiseError) Then
          Raise Exception.Create(PChar(E.Message));
        End;
      End;
    End;
   End
  Else
   Begin
    vInDesignEvents := False;
    If Not InLoadFromStream Then
     Begin
      vActive := False;
      Close;
      If Not (csLoading in ComponentState) And
         Not (csReading in ComponentState) Then
       If Value Then
        If vRESTDataBase = Nil Then
         Begin
          If (vRaiseError) Then
           Raise Exception.Create(PChar(cEmptyDBName));
         End;
     End;
   End;
 Finally
//  ChangeCursor(True);
 End;
End;

procedure TRESTDWClientSQL.SetActiveDB(Value: Boolean);
Begin
 Try
//  ChangeCursor;
  If (vInactive) And Not(vInDesignEvents) Then
   Begin
    vActive := (Value) And Not(vInDesignEvents);
    If vActive Then
     BaseOpen
    Else
     Begin
      BaseClose;
      vinactive := False;
     End;
    Exit;
   End;
  If (vActive) Then
   vActive := False;
  If ((vRESTDataBase <> Nil)) And (Value) Then
   Begin
    If vRESTDataBase <> Nil Then
     If Not vRESTDataBase.Active Then
      vRESTDataBase.Active := True;
    If Not vRESTDataBase.Active then
     Begin
      vActive := False;
      Exit;
     End;
    Try
     If (Not(vActive) And (Value)) Or (GetNewData) Or (vInDesignEvents) Then
      Begin
       GetNewData := False;
       If Not (vPropThreadRequest) Then
        ExecuteOpen
       Else
        Begin
         {$IFDEF RESTDWLAZARUS}
          ThreadStart(@ExecuteOpen);
         {$ELSE}
          ThreadStart(ExecuteOpen);
         {$ENDIF}
        End;
      End
     Else
      Begin
       If State = dsBrowse Then
        Begin
         CreateMassiveDataset;
         PrepareDetails(True);
        End
       Else If State = dsInactive Then
        Begin
         vReadData := False;
         PrepareDetails(False);
        End;
      End;
    Except
     On E : Exception do
      Begin
       vInBlockEvents := False;
       If csDesigning in ComponentState Then
        Raise Exception.Create(PChar(E.Message))
       Else
        Begin
         If Assigned(vOnGetDataError) Then
          vOnGetDataError(False, E.Message);
         If (vRaiseError) Then
          Raise Exception.Create(PChar(E.Message));
        End;
      End;
    End;
   End
  Else
   Begin
    vInDesignEvents := False;
    Self.Close;
    If Not InLoadFromStream Then
     Begin
      vActive := False;
      If Not (csLoading in ComponentState) And
         Not (csReading in ComponentState) Then
       Begin
        If Value Then
         Begin
          If vRESTDataBase = Nil Then
           Begin
            If (vRaiseError) Then
             Raise Exception.Create(PChar(cEmptyDBName));
           End;
         End;
       End;
     End;
   End;
 Finally
//  ChangeCursor(True);
 End;
End;

Procedure TRESTDWTable.SetAutoRefreshAfterCommit(Value: Boolean);
Begin
 vAutoRefreshAfterCommit := Value;
End;

Procedure TRESTDWClientSQL.SetAutoRefreshAfterCommit(Value: Boolean);
Begin
 vAutoRefreshAfterCommit := Value;
 If Value Then
  vReflectChanges := False;
End;

procedure TRESTDWTable.SetCacheUpdateRecords(Value: Boolean);
Begin
 vCacheUpdateRecords := Value;
End;

procedure TRESTDWClientSQL.SetCacheUpdateRecords(Value: Boolean);
Begin
 vCacheUpdateRecords := Value;
End;

constructor TRESTDWStoredProcedure.Create(AOwner: TComponent);
begin
 Inherited;
 vParams        := TParams.Create(Self);
 vProcName      := '';
 vSchemaName    := vProcName;
 vBinaryRequest := False;
end;

destructor TRESTDWStoredProcedure.Destroy;
begin
 vParams.Free;
 Inherited;
end;

Function TRESTDWStoredProcedure.ExecProc(Var Error : String) : Boolean;
Begin
 If vRESTDataBase <> Nil Then
  Begin
   If vParams.Count > 0 Then
    vRESTDataBase.ExecuteProcedure(vActualPoolerMethodClient, vProcName, vParams, Result, Error);
  End
 Else
  Raise Exception.Create(PChar(cEmptyDBName));
End;

Function TRESTDWStoredProcedure.ParamByName(Value: String): TParam;
Begin
 Result := Params.ParamByName(Value);
End;

Procedure TRESTDWStoredProcedure.SetUpdateSQL(Value : TRESTDWUpdateSQL);
Begin
 If (Assigned(vUpdateSQL)) And
    (vUpdateSQL <> Value)  Then
  Begin
   vUpdateSQL.SetClientSQL(Nil);
   vUpdateSQL := Nil;
  End;
 If vUpdateSQL <> Value Then
  vUpdateSQL := Value;
 If vUpdateSQL <> Nil   Then
  Begin
   vUpdateSQL.SetClientSQL(Self);
   vUpdateSQL.FreeNotification(Self);
  End;
End;

Function  TRESTDWStoredProcedure.GetUpdateSQL       : TRESTDWUpdateSQL;
Begin
 Result := vUpdateSQL;
End;

Procedure TRESTDWStoredProcedure.Notification(AComponent : TComponent;
                                         Operation  : TOperation);
Begin
 If (Operation    = opRemove)              And
    (AComponent   = vRESTDataBase)         Then
  vRESTDataBase  := Nil;
 If (Operation    = opRemove)              And
    (AComponent   = vUpdateSQL)            Then
  vUpdateSQL      := Nil;
 Inherited Notification(AComponent, Operation);
end;

procedure TRESTDWStoredProcedure.SetDataBase(const Value: TRESTDWDatabasebaseBase);
begin
 vRESTDataBase := Value;
end;

Procedure TClientConnectionDefs.SetConnectionDefs(Value : TConnectionDefs);
Begin
 If vActive Then
  vConnectionDefs := Value;
End;

Constructor TClientConnectionDefs.Create(AOwner       : TPersistent);
Begin
 inherited Create;
 vActive := False;
 FOwner  := AOwner;
End;

Destructor TClientConnectionDefs.Destroy;
Begin
 If Assigned(vConnectionDefs) Then
  FreeAndNil(vConnectionDefs);
 Inherited;
End;

Function    TClientConnectionDefs.GetOwner  : TPersistent;
Begin
 Result := FOwner;
End;

Procedure TClientConnectionDefs.DestroyParam;
Begin
 {$IFDEF RESTDWLAZARUS}
 If Not(csDesigning in TComponent(GetOwner).ComponentState) Then
  Begin
   If Assigned(vConnectionDefs) Then
    FreeAndNil(vConnectionDefs);
  End
 Else
  Begin
   If Not (vActive) Then
    vConnectionDefs := Nil;
  End;
 {$ELSE}
 If Assigned(vConnectionDefs) Then
  FreeAndNil(vConnectionDefs);
 {$ENDIF}
End;

Procedure TClientConnectionDefs.SetClientConnectionDefs(Value : Boolean);
Begin
 vActive := Value;
 Case Value Of
  True  : Begin
           If Not Assigned(vConnectionDefs) Then
            vConnectionDefs := TConnectionDefs.Create;
          End;
  False : DestroyParam;
 End;
End;

Procedure TRESTDWDatabasebaseBase.SetMyIp(Value: String);
Begin
End;

Class Function TRESTDWTable.FieldDefExist(Const Dataset : TDataset;
                                          Value         : String) : TFieldDef;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Dataset.FieldDefs.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Dataset.FieldDefs[I].Name) Then
    Begin
     Result := Dataset.FieldDefs[I];
     Break;
    End;
  End;
End;

Class Function TRESTDWClientSQL.FieldDefExist(Const Dataset : TDataset;
                                              Value         : String) : TFieldDef;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Dataset.FieldDefs.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Dataset.FieldDefs[I].Name) Then
    Begin
     Result := Dataset.FieldDefs[I];
     Break;
    End;
  End;
End;

Function TRESTDWTable.FieldExist(Value: String): TField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Fields.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Fields[I].FieldName) Then
    Begin
     Result := Fields[I];
     Break;
    End;
  End;
End;

Function TRESTDWClientSQL.FieldExist(Value: String): TField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Fields.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Fields[I].FieldName) Then
    Begin
     Result := Fields[I];
     Break;
    End;
  End;
End;

Constructor TRESTDWValueKey.Create;
Begin
 vKeyname      := '';
 vValue        := Null;
 vIsStream     := False;
 vIsNull       := True;
 vObjectValue  := ovUnknown;
 vStreamValue  := Nil;
End;

Function TRESTDWValueKeys.GetRec(Index : Integer) : TRESTDWValueKey;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TRESTDWValueKey(TList(Self).Items[Index]^);
End;

Procedure TRESTDWValueKeys.PutRec(Index : Integer;
                                  Item  : TRESTDWValueKey);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TRESTDWValueKey(TList(Self).Items[Index]^) := Item;
End;

Function TRESTDWValueKeys.GetRecName(Index : String) : TRESTDWValueKey;
Var
 I         : Integer;
Begin
 Result    := Nil;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If Uppercase(Index) = Uppercase(TRESTDWValueKey(TList(Self).Items[i]^).vKeyname)Then
      Begin
       Result := TRESTDWValueKey(TList(Self).Items[i]^);
       Break;
      End;
    End;
  End;
End;

Procedure TRESTDWValueKeys.PutRecName(Index : String;
                                      Item  : TRESTDWValueKey);
Var
 I         : Integer;
 vNotFount : Boolean;
Begin
 vNotFount := True;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If Lowercase(Index) = Lowercase(TRESTDWValueKey(TList(Self).Items[i]^).vKeyname)  Then
      Begin
       TRESTDWValueKey(TList(Self).Items[i]^) := Item;
       vNotFount := False;
       Break;
      End;
    End;
  End;
 If vNotFount Then
  Begin
   Item         := TRESTDWValueKey.Create;
   Item.Keyname := Index;
   Add(Item);
  End;
End;

Procedure TRESTDWValueKeys.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Constructor TRESTDWValueKeys.Create;
Begin
 Inherited;
End;

Destructor TRESTDWValueKeys.Destroy;
Begin
 ClearList;
 Inherited;
End;

Procedure TRESTDWValueKeys.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index])  Then
    Begin
      {$IF Defined(RESTDWLAZARUS)}
      FreeAndNil(TList(Self).Items[Index]^);
      {$ELSEIF Defined(DELPHI10_4UP)}
      FreeAndNil(TRESTDWValueKey(TList(Self).Items[Index]^));
      {$ELSE}
      FreeAndNil(TList(Self).Items[Index]^);
      {$IFEND}
      {$IFDEF FPC}
       Dispose(PRESTDWValueKey(TList(Self).Items[Index]));
      {$ELSE}
       Dispose(TList(Self).Items[Index]);
      {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Procedure TRESTDWValueKeys.Delete(Index : String);
Var
 I : Integer;
Begin
 For I := 0 To Count -1 Do
  Begin
   If Lowercase(Items[I].vKeyname) = Lowercase(Index) Then
    Begin
     Delete(I);
     Break;
    End;
  End;
End;

Function    TRESTDWValueKeys.BuildKeyNames        : String;
Var
 I : Integer;
Begin
 Result := '';
 For I := 0 To Count -1 Do
  Result := Result + Items[I].vKeyname;
End;

Function    TRESTDWValueKeys.BuildArrayValues     : TArrayData;
Var
 I : Integer;
 Function CreateVariantStream(MS : TMemoryStream) : Variant;
 Var
  P: Pointer;
 Begin
  Result := VarArrayCreate([0, MS.Size-1], varByte);
  If MS.Size > 0 then
   Begin
    P := VarArrayLock(Result);
    MS.ReadBuffer(P^, MS.Size);
    VarArrayUnlock(Result);
   End;
 End;
Begin
 Setlength(Result, Count);
 For I := 0 To Count -1 Do
  Begin
   Result[I] := Null;
   If Items[I].vIsNull Then
    Begin
     If Items[I].vIsStream Then
      Result[I] := CreateVariantStream(Items[I].vStreamValue)
     Else
      Result[I] := Items[I].vValue;
    End;
  End;
End;

Function TRESTDWValueKeys.Add(Item : TRESTDWValueKey) : Integer;
Var
 vItem : ^TRESTDWValueKey;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Function    TRESTDWConnectionParams.GetPoolerList     : TStringList;
Var
 I             : Integer;
 vTempDatabase : TRESTDWDatabasebaseBase;
Begin
 vTempDatabase := TRESTDWDatabasebaseBase.Create(Nil);
 Result        := TStringList.Create;
 vTempDatabase.AuthenticationOptions := AuthenticationOptions;
 Try
  vTempDatabase.AccessTag              := vAccessTag;
  vTempDatabase.Compression            := vCompression;
  vTempDatabase.TypeRequest            := vTypeRequest;
  vTempDatabase.Proxy                  := vProxy;             //Diz se tem servidor Proxy
  vTempDatabase.ProxyOptions.Server    := vProxyOptions.vServer;      //Se tem Proxy diz quais as opções
  vTempDatabase.ProxyOptions.Login     := vProxyOptions.vLogin;      //Se tem Proxy diz quais as opções
  vTempDatabase.ProxyOptions.Password  := vProxyOptions.vPassword;      //Se tem Proxy diz quais as opções
  vTempDatabase.ProxyOptions.Port      := vProxyOptions.vPort;      //Se tem Proxy diz quais as opções
  vTempDatabase.PoolerService          := vRestWebService;    //Host do WebService REST
  vTempDatabase.DataRoute              := vDataRoute;           //URL do WebService REST
  vTempDatabase.PoolerPort             := vPoolerPort;        //A Porta do Pooler do DataSet
//  vTempDatabase.PoolerName           := vRestPooler;        //Qual o Pooler de Conexão ligado ao componente
  vTempDatabase.RequestTimeOut         := vTimeOut;           //Timeout da Requisição
  vTempDatabase.EncodedStrings         := vEncodeStrings;
  vTempDatabase.Encoding               := vEncoding;          //Encoding da string
  vTempDatabase.WelcomeMessage         := vWelcomeMessage;
  if Assigned(vPoolerList) then
   FreeAndNil(vPoolerList);
  vPoolerList                          := vTempDatabase.PoolerList;
  If Assigned(vPoolerList) Then
   Begin
    For I := 0 To vPoolerList.Count -1 Do
     Result.Add(vPoolerList[I]);
   End;
 Finally
  vTempDatabase.Active               := False;
  FreeAndNil(vTempDatabase);
 End;
End;

Constructor TRESTDWConnectionParams.Create;
Begin
 Inherited;
 vClientConnectionDefs := TClientConnectionDefs.Create(Self);
 vAuthOptionParams     := TRESTDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vPoolerList           := Nil;
 {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
  vEncoding         := esUtf8;
 {$ELSE}
  vEncoding         := esAscii;
 {$IFEND}
 vLogin             := cDefaultBasicAuthUser;
 vRestWebService    := '127.0.0.1';
 vCompression       := True;
 vBinaryRequest     := False;
 vPassword          := cDefaultBasicAuthPassword;
 vRestPooler        := '';
 vPoolerPort        := 8082;
 vProxy             := False;
 vEncodeStrings     := True;
 vProxyOptions      := TProxyOptions.Create;
 vTimeOut           := 10000;
 vActive            := True;
End;

Destructor TRESTDWConnectionParams.Destroy;
Begin
 If Assigned(vPoolerList) Then
  FreeAndNil(vPoolerList);
 FreeAndNil(vClientConnectionDefs);
 FreeAndNil(vProxyOptions);
 FreeAndNil(vAuthOptionParams);
 Inherited;
End;

{ TRESTDWPoolerListBase }

Constructor TRESTDWPoolerListBase.Create(AOwner: TComponent);
Begin
 Inherited;
 vDataRoute        := '';
 vPoolerNotFoundMessage := cPoolerNotFound;
 vPoolerPort       := 8082;
 vTimeOut          := 3000;
 vConnectTimeOut   := 3000;
 vProxy            := False;
 vCompression      := True;
 vTypeRequest      := trHttp;
 vProxyOptions     := TProxyOptions.Create;
 vPoolerList       := TStringList.Create;
 vAuthOptionParams := TRESTDWClientAuthOptionParams.Create(Self);
 vCripto           := TCripto.Create;
 vEncoding         := esUtf8;
 vUserAgent        := cUserAgent;
 vHandleRedirects  := False;
 vRedirectMaximum  := 0;
End;

Destructor TRESTDWPoolerListBase.Destroy;
Begin
 vProxyOptions.Free;
 FreeAndNil(vAuthOptionParams);
 FreeAndNil(vCripto);
 FreeAndNil(RESTClientPooler);
 If vPoolerList <> Nil Then
  FreeAndNil(vPoolerList);
 Inherited;
End;

Function TRESTDWPoolerListBase.GetPoolerList: TStringList;
Var
 vTempString,
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
Begin
 Result := Nil;
 RESTClientPooler.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPooler.WelcomeMessage  := vWelcomeMessage;
 RESTClientPooler.HandleRedirects := vHandleRedirects;
 RESTClientPooler.RedirectMaximum := vRedirectMaximum;
 RESTClientPooler.Host            := vRestWebService;
 RESTClientPooler.Port            := vPoolerPort;
 RESTClientPooler.RequestTimeOut  := vTimeOut;
 RESTClientPooler.ConnectTimeOut  := vConnectTimeOut;
 RESTClientPooler.DataCompression := Compression;
 RESTClientPooler.TypeRequest     := vTypeRequest;
 RESTClientPooler.Encoding        := vEncoding;
 RESTClientPooler.UserAgent       := vUserAgent;
 RESTClientPooler.SetAccessTag(vAccessTag);
 RESTClientPooler.CriptOptions.Use:= vCripto.Use;
 RESTClientPooler.CriptOptions.Key:= vCripto.Key;
 RESTClientPooler.DataRoute        := vDataRoute;
 RESTClientPooler.AuthenticationOptions := vAuthOptionParams;
 {$IFDEF RESTDWLAZARUS}
 RESTClientPooler.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams  := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPooler.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPooler.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovString;
 JSONParam.AsString              := '';
// JSONParam.SetValue('', JSONParam.Encoded);
 DWParams.Add(JSONParam);
 Try
  Try
   lResponse := RESTClientPooler.SendEvent('GetPoolerList', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result      := TStringList.Create;
     vTempString := DWParams.ItemsString['Result'].AsString;
     While Not (vTempString = '') Do
      Begin
       if Pos('|', vTempString) > 0 then
        Begin
         Result.Add(Copy(vTempString, 1, Pos('|', vTempString) -1));
         Delete(vTempString, 1, Pos('|', vTempString));
        End
       Else
        Begin
         Result.Add(Copy(vTempString, 1, Length(vTempString)));
         Delete(vTempString, 1, Length(vTempString));
        End;
      End;
    End
   Else
    Begin
     If (lResponse = '') Then
      lResponse  := Format('Unresolved Host : ''%s''', [vRestWebService])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      lResponse  := 'Unauthorized...';
     Raise Exception.Create(lResponse);
     lResponse := '';
    End;
  Except
   On E : Exception Do
    Begin
     Raise Exception.Create(E.Message);
    End;
  End;
 Finally
  FreeAndNil(DWParams);
 End;
End;

Procedure TRESTDWPoolerListBase.SetConnection(Value: Boolean);
Begin
 vConnected := Value;
 If vConnected Then
  vConnected := TryConnect;
End;

Procedure TRESTDWPoolerListBase.SetPoolerPort(Value: Integer);
Begin
 vPoolerPort := Value;
End;

Function TRESTDWPoolerListBase.TryConnect: Boolean;
Var
 PoolerList: TStringList;
Begin
 PoolerList := Self.GetPoolerList;

 try
  vPoolerList.Clear;
  vPoolerList.Assign(PoolerList);
  Result := True;
 finally
  FreeAndNil(PoolerList)
 end;

End;

end.
