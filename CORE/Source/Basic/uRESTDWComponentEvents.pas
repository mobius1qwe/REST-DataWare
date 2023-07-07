unit uRESTDWComponentEvents;

{$I ..\..\Source\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

Uses
 SysUtils, Classes, Db,
 uRESTDWDataUtils, uRESTDWParams, uRESTDWBasicTypes, uRESTDWProtoTypes,
 uRESTDWConsts, uRESTDWMassiveBuffer, uRESTDWAuthenticators;

 Type
  TOnCreate               = Procedure(Sender                : TObject)               Of Object;
  TLastRequest            = Procedure(Value                 : String)                Of Object;
  TLastResponse           = Procedure(Value                 : String)                Of Object;
  TBeforeUseCriptKey      = Procedure(Request               : String;
                                      Var Key               : String)                Of Object;
  TEventContext           = Procedure(AContext              : TComponent;
                                      ARequestInfo          : TComponent;
                                      AResponseInfo         : TComponent)            Of Object;
  TOnWork                 = Procedure(ASender               : TObject;
                                      AWorkCount            : Int64)                 Of Object;
  TOnBeforeExecute        = Procedure(ASender               : TObject)               Of Object;
  TOnWorkEnd              = Procedure(ASender               : TObject)               Of Object;
  TOnStatus               = Procedure(ASender               : TObject;
                                      Const AStatus         : TConnStatus;
                                      Const AStatusText     : String)                Of Object;
  TOnGetpassword          = Procedure(Var Password          : String)                Of Object;
  TCallBack               = Procedure(Json                  : String;
                                      Params                : TRESTDWParams)         Of Object;
  TCallSendEvent          = Function (EventData             : String;
                                      Var Params            : TRESTDWParams;
                                      EventType             : TSendEvent = sePOST;
                                      DataMode              : TDataMode  = dmDataware;
                                      ServerEventName       : String     = '';
                                      Assyncexec            : Boolean    = False;
                                      CallBack              : TCallBack  = Nil) : String Of Object;
  TPrepareGet             = Procedure(Var AUrl              : String;
                                      Var AHeaders          : TStringList)           Of Object;
  TPrepareEvent           = Procedure(Var AUrl              : String;
                                      Var AHeaders          : TStringList)           Of Object;
  TAfterRequest           = Procedure(AUrl                  : String;
                                      ResquestType          : TRequestType;
                                      AResponse             : TStream)               Of Object;
  TOnHeadersAvailable     = Procedure(AHeaders              : TStringList;
                                      vContinue             : Boolean)               Of Object;
  TRESTDWOnSessionData    = Procedure(Const Sender          : TRESTDwSessionData)    Of Object;
  TRESTDWAuthError        = Procedure(Sender                : TRESTDwSessionData;
                                      Const Request         : String)                Of Object;
  TRESTDWSessionError     = Procedure(Sender                : TRESTDwSessionData;
                                      Const ErrorCode       : Integer;
                                      Const ErrorMessage    : String)                Of Object;
  TConnectionRename       = Procedure(Sender                : TRESTDwSessionData;
                                      OldConnectionName,
                                      NewConnectionName     : String)                Of Object;
  TLastSockRequest        = Procedure(Sender                : TRESTDwSessionData;
                                      Value                 : String)                Of Object;
  TLastSockStream         = Procedure(Sender                : TRESTDwSessionData;
                                      Const aStream         : TStream)               Of Object;
  TLastSockResponse       = Procedure(Sender                : TRESTDwSessionData;
                                      Value                 : String)                Of Object;
  TWelcomeMessage         = Procedure(Welcomemsg, AccessTag : String;
                                      Var ConnectionDefs    : TConnectionDefs;
                                      Var Accept            : Boolean;
                                      Var ContentType,
                                      ErrorMessage          : String)                Of Object;
  TNotifyWelcomeMessage   = Procedure(Welcomemsg, AccessTag : String;
                                      Var ConnectionDefs    : TConnectionDefs;
                                      Var Accept            : Boolean)               Of Object;
  TRESTDWReplyEvent       = Procedure(Var   Params          : TRESTDWParams;
                                      Var   Result          : String)                Of Object;
  TRESTDWReplyEventByType = Procedure(Var   Params          : TRESTDWParams;
                                      Var   Result          : String;
                                      Const RequestType     : TRequestType;
                                      Var   StatusCode      : Integer;
                                      RequestHeader         : TStringList)           Of Object;
  TRESTDWAuthRequest      = Procedure(Const Params          : TRESTDWParams;
                                      Var   Rejected        : Boolean;
                                      Var   ResultError     : String;
                                      Var   StatusCode      : Integer;
                                      RequestHeader         : TStringList)           Of Object;
  TObjectEvent            = Procedure(aSelf                 : TComponent)            Of Object;
  TObjectExecute          = Procedure(Const aSelf           : TCollectionItem)       Of Object;
  TOnBeforeSend           = Procedure(aSelf                 : TComponent)            Of Object;
  TMassiveProcess         = Procedure(Var MassiveDataset    : TMassiveDatasetBuffer;
                                      Var Ignore            : Boolean)               Of Object;
  TMassiveEvent           = Procedure(Var MassiveDataset    : TMassiveDatasetBuffer) Of Object;
  TMassiveLineProcess     = Procedure(Var MassiveDataset    : TMassiveDatasetBuffer;
                                      Dataset               : TDataset)              Of Object;
  TOnGetToken             = Procedure(Welcomemsg,
                                      AccessTag             : String;
                                      Params                : TRESTDWParams;
                                      AuthOptions           : TRESTDWAuthToken;
                                      Var ErrorCode         : Integer;
                                      Var ErrorMessage      : String;
                                      Var TokenID           : String;
                                      Var Accept            : Boolean) Of Object;
  TOnBeforeGetToken       = Procedure(Welcomemsg,
                                      AccessTag             : String;
                                      Params                : TRESTDWParams)   Of Object;
  TOnPrepareConnection    = Procedure(Var ConnectionDefs    : TConnectionDefs) Of Object;
  TOnTableBeforeOpen      = Procedure(Var Dataset           : TDataset;
                                      Params                : TRESTDWParams;
                                      Tablename             : String)          Of Object;
  TOnQueryBeforeOpen      = Procedure(Var Dataset           : TDataset;
                                      Params                : TRESTDWParams)       Of Object;
  TOnQueryException       = Procedure(Var Dataset           : TDataset;
                                      Params                : TRESTDWParams;
                                      Error                 : String)       Of Object;

implementation


end.
