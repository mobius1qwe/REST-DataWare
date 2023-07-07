unit uRESTDWPoolermethod;

{$I ..\..\Source\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
  {$IFDEF RESTDWWINDOWS}Windows,{$ENDIF}
  SysUtils, Classes,
  uRESTDWMassiveBuffer, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWBasic,
  uRESTDWProtoTypes, uRESTDWTools, uRESTDWJSONObject, uRESTDWConsts,
  uRESTDWDataUtils, uRESTDWParams;


 Type
  TRESTDWPoolerMethodClient  = Class(TComponent)
  Private
   vOnWorkBegin,
   vOnWork                 : TOnWork;
   vOnWorkEnd              : TOnWorkEnd;
   vOnStatus               : TOnStatus;
   vHandleRedirects,
   vBinaryRequest,
   vEncodeStrings,
   vCompression            : Boolean;
   vEncoding               : TEncodeSelect;
   {$IFDEF RESTDWLAZARUS}
   vDatabaseCharSet        : TDatabaseCharSet;
   {$ENDIF}
   vAccept,
   vAcceptEncoding,
   vContentType,
   vCharset,
   vContentEncoding,
   vPoolerNotFoundMessage,
   vDataRoute,
   vUserAgent,
   vPoolerURL,
   vAccessTag,
   vWelcomeMessage,
   vHost                   : String;
   vTimeOut,
   vConnectTimeOut,
   vPort                   : Integer;
   vCripto                 : TCripto;
   vTypeRequest            : TtypeRequest;
   vAuthOptionParams       : TRESTDWClientAuthOptionParams;
   vRedirectMaximum        : Integer;
   vOnBeforeGetToken       : TOnBeforeGetToken;
   vActualClientPoolerExec : TRESTClientPoolerBase;
   vSSLVersions            : TRESTDWSSLVersions;
   Procedure SetOnWork     (Value : TOnWork);
   Procedure SetOnWorkBegin(Value : TOnWork);
   Procedure SetOnWorkEnd  (Value : TOnWorkEnd);
   Procedure SetOnStatus   (Value : TOnStatus);
   Procedure SetAuthOptionParams(Value : TRESTDWClientAuthOptionParams);
   Procedure TokenValidade;
   Function  RenewToken           (Var Params              : TRESTDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String) : String;
{ TODO: Criar uma função base para executar todos os comandos e remover as
  redundâncias dessa unit.
   Function ExecuteAction(aAction: string;
                          Method_Prefix: string;
                          Pooler: string = '';
                          Params: TRESTDWParams = Nil;
                          TimeOut: Integer = 3000;
                          ConnectTimeOut: Integer = 3000;
                          RESTClientPooler: TRESTClientPoolerBase = Nil;
                          Var Error: Boolean = false;
                          Var MessageError: String = '';
                          ConnectionDefs: TObject = Nil;
                          Var SocketError: Boolean = false;
                          Var RowsAffected: Integer = -1;
                          Execute: Boolean = false;
                          Metadata: Boolean = false;
                          DatasetStream: TStream = Nil;
   ): string;
}
  Public
   Constructor Create(AOwner: TComponent);Override;
   Destructor  Destroy;Override;
   Procedure   Abort;
   Function GetPoolerList         (Method_Prefix           : String;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TStringList;Overload;
   Function GetServerEvents       (Method_Prefix           : String;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TStringList;Overload;
   Function EchoPooler            (Method_Prefix,
                                   Pooler                  : String;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : String;
   //GetToken Function
   Function GetToken              (Pooler                  : String;
                                   Params                  : TRESTDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : String;
   //Roda Comando SQL
   Function InsertValue           (Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Params                  : TRESTDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : Integer;
   Function ExecuteCommand        (Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Params                  : TRESTDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   Var RowsAffected        : Integer;
                                   Execute                 : Boolean;
                                   BinaryRequest           : Boolean;
                                   BinaryCompatibleMode    : Boolean;
                                   Metadata                : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TJSONValue;
   Function OpenDatasets          (LinesDataset,
                                   Pooler,
                                   Method_Prefix           : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : String;Overload;
   Function OpenDatasets          (DatasetStream           : TStream;
                                   Pooler,
                                   Method_Prefix           : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   BinaryRequest           : Boolean;
                                   BinaryCompatibleMode    : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TStream;Overload;
   Function ApplyUpdates          (Massive                 : TMassiveDatasetBuffer;
                                   Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Params                  : TRESTDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   Var RowsAffected        : Integer;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   MassiveBuffer           : String  = '';
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)    : TJSONValue;Overload;
   Function ApplyUpdatesTB        (Massive                 : TMassiveDatasetBuffer;
                                   Pooler, Method_Prefix   : String;
                                   Params                  : TRESTDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   Var RowsAffected        : Integer;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   MassiveBuffer           : String  = '';
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)    : TJSONValue;Overload;
   Function ApplyUpdates          (LinesDataset,
                                   Pooler,
                                   Method_Prefix           : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)    : String;Overload;
   Function  ApplyUpdates_MassiveCache(MassiveCache            : TStream;
                                       Pooler, Method_Prefix   : String;
                                       Var Error               : Boolean;
                                       Var MessageError        : String;
                                       Var SocketError         : Boolean;
                                       TimeOut                 : Integer = 3000;
                                       ConnectTimeOut          : Integer = 3000;
                                       ConnectionDefs          : TObject = Nil;
                                       ReflectChanges          : Boolean = False;
                                       RESTClientPooler        : TRESTClientPoolerBase = Nil) : TJSONValue;
   Function  ProcessMassiveSQLCache   (MassiveSQLCache,
                                       Pooler, Method_Prefix   : String;
                                       Var Error               : Boolean;
                                       Var MessageError        : String;
                                       Var SocketError         : Boolean;
                                       TimeOut                 : Integer = 3000;
                                       ConnectTimeOut          : Integer = 3000;
                                       ConnectionDefs          : TObject = Nil;
                                       RESTClientPooler        : TRESTClientPoolerBase = Nil) : TJSONValue;
   Function ExecuteCommandJSON    (Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Params                  : TRESTDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   Var RowsAffected        : Integer;
                                   Execute                 : Boolean;
                                   BinaryRequest           : Boolean;
                                   BinaryCompatibleMode    : Boolean;
                                   Metadata                : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TJSONValue;
  Function ExecuteCommandJSONTB   (Pooler,
                                   Method_Prefix,
                                   Tablename               : String;
                                   Params                  : TRESTDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   Var RowsAffected        : Integer;
                                   BinaryRequest           : Boolean;
                                   BinaryCompatibleMode    : Boolean;
                                   Metadata                : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TJSONValue;
   Function InsertValuePure       (Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : Integer;
   Function ExecuteCommandPureJSON(Pooler,
                                   Method_Prefix,
                                   SQL                     : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   Var RowsAffected        : Integer;
                                   Execute                 : Boolean;
                                   BinaryRequest           : Boolean;
                                   BinaryCompatibleMode    : Boolean;
                                   Metadata                : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TJSONValue;
   Function ExecuteCommandPureJSONTB(Pooler,
                                     Method_Prefix,
                                     Tablename        : String;
                                     Var Error            : Boolean;
                                     Var MessageError     : String;
                                     Var SocketError      : Boolean;
                                     Var RowsAffected     : Integer;
                                     BinaryRequest        : Boolean;
                                     BinaryCompatibleMode : Boolean;
                                     Metadata             : Boolean;
                                     TimeOut              : Integer = 3000;
                                     ConnectTimeOut       : Integer = 3000;
                                     ConnectionDefs       : TObject           = Nil;
                                     RESTClientPooler     : TRESTClientPoolerBase = Nil)   : TJSONValue;
   //Lista todos os Pooler's do Servidor
   Procedure GetPoolerList        (Method_Prefix           : String;
                                   Var PoolerList          : TStringList;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil);Overload;
   //StoredProc
   Procedure  ExecuteProcedure    (Pooler,
                                   Method_Prefix,
                                   ProcName                : String;
                                   Params                  : TRESTDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil);
   Procedure  ExecuteProcedurePure(Pooler,
                                   Method_Prefix,
                                   ProcName                : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil);
   Function   GetTableNames       (Pooler,
                                   Method_Prefix           : String;
                                   Var TableNames          : TStringList;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)  : Boolean;
   Function   GetFieldNames       (Pooler,
                                   Method_Prefix,
                                   TableName               : String;
                                   Var FieldNames          : TStringList;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)  : Boolean;
   Function   GetKeyFieldNames    (Pooler,
                                   Method_Prefix,
                                   TableName               : String;
                                   Var FieldNames          : TStringList;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Var SocketError         : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   ConnectTimeOut          : Integer = 3000;
                                   ConnectionDefs          : TObject           = Nil;
                                   RESTClientPooler        : TRESTClientPoolerBase = Nil)  : Boolean;
   Property Accept                : String                     Read vAccept                Write vAccept;
   Property AcceptEncoding        : String                     Read vAcceptEncoding        Write vAcceptEncoding;
   Property ContentType           : String                     Read vContentType           Write vContentType;
   Property Charset               : String                     Read vCharset               Write vCharset;
   Property ContentEncoding       : String                     Read vContentEncoding       Write vContentEncoding;
   Property Compression           : Boolean                    Read vCompression           Write vCompression;
   Property BinaryRequest         : Boolean                    Read vBinaryRequest         Write vBinaryRequest;
   Property HandleRedirects       : Boolean                    Read vHandleRedirects       Write vHandleRedirects;
   Property RedirectMaximum       : Integer                    Read vRedirectMaximum       Write vRedirectMaximum;
   Property Encoding              : TEncodeSelect              Read vEncoding              Write vEncoding;
   Property EncodeStrings         : Boolean                    Read vEncodeStrings         Write vEncodeStrings;
   Property PoolerURL             : String                     Read vPoolerURL             Write vPoolerURL;
   Property Host                  : String                     Read vHost                  Write vHost;
   Property Port                  : Integer                    Read vPort                  Write vPort;
   Property RequestTimeOut        : Integer                    Read vTimeOut               Write vTimeOut;           //Timeout da Requisição
   Property ConnectTimeOut        : Integer                    Read vConnectTimeOut        Write vConnectTimeOut;
   Property WelcomeMessage        : String                     Read vWelcomeMessage        Write vWelcomeMessage;
   Property OnWork                : TOnWork                    Read vOnWork                Write SetOnWork;
   Property OnWorkBegin           : TOnWork                    Read vOnWorkBegin           Write SetOnWorkBegin;
   Property OnWorkEnd             : TOnWorkEnd                 Read vOnWorkEnd             Write SetOnWorkEnd;
   Property OnStatus              : TOnStatus                  Read vOnStatus              Write SetOnStatus;
   {$IFDEF RESTDWLAZARUS}
   Property DatabaseCharSet       : TDatabaseCharSet           Read vDatabaseCharSet       Write vDatabaseCharSet;
   {$ENDIF}
   Property TypeRequest           : TTypeRequest               Read vTypeRequest           Write vTypeRequest Default trHttp;
   Property AccessTag             : String                     Read vAccessTag             Write vAccessTag;
   Property CriptOptions          : TCripto                    Read vCripto                Write vCripto;
   Property UserAgent             : String                     Read vUserAgent             Write vUserAgent;
   Property DataRoute             : String                     Read vDataRoute             Write vDataRoute;
   Property AuthenticationOptions : TRESTDWClientAuthOptionParams Read vAuthOptionParams      Write SetAuthOptionParams;
   Property OnBeforeGetToken      : TOnBeforeGetToken          Read vOnBeforeGetToken      Write vOnBeforeGetToken;
   Property PoolerNotFoundMessage : String                     Read vPoolerNotFoundMessage Write vPoolerNotFoundMessage;
   Property SSLVersions           : TRESTDWSSLVersions         Read vSSLVersions             Write vSSLVersions;
  End;

implementation

Uses uRESTDWBasicDB, uRESTDWJSONInterface, uRESTDWBufferBase;

Function TRESTDWPoolerMethodClient.ApplyUpdatesTB(Massive             : TMassiveDatasetBuffer;
                                              Pooler, Method_Prefix   : String;
                                              Params                  : TRESTDWParams;
                                              Var Error               : Boolean;
                                              Var MessageError        : String;
                                              Var SocketError         : Boolean;
                                              Var RowsAffected        : Integer;
                                              TimeOut                 : Integer = 3000;
                                              ConnectTimeOut          : Integer = 3000;
                                              MassiveBuffer           : String  = '';
                                              ConnectionDefs          : TObject           = Nil;
                                              RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
 bJsonValue           : TRESTDWJSONInterfaceObject;
Begin
 Result := Nil;
 RowsAffected  := 0;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec                 := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                              := TRESTDWParams.Create;
 DWParams.Encoding                     := RESTClientPoolerExec.Encoding;
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Massive';
 JSONParam.ObjectDirection             := odIn;
 If Massive <> Nil Then
  JSONParam.AsString                   := TMassiveDatasetBuffer(Massive).ToJSON
 Else If MassiveBuffer <> '' Then
  JSONParam.AsString                   := MassiveBuffer;
 DWParams.Add(JSONParam);
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Pooler';
 JSONParam.ObjectDirection             := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString                   := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString                   := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Method_Prefix';
 JSONParam.ObjectDirection             := odIn;
 JSONParam.AsString                    := Method_Prefix;
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                           := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                 := 'dwConnectionDefs';
   JSONParam.ObjectDirection           := odIn;
   JSONParam.AsString                  := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 If Params <> Nil Then
  Begin
   If Params.Count > 0 Then
    Begin
     JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
     JSONParam.ParamName             := 'Params';
     JSONParam.ObjectDirection       := odInOut;
     If RESTClientPoolerExec.CriptOptions.Use Then
      JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Params.ToJSON)
     Else
      JSONParam.AsString             := Params.ToJSON;
     DWParams.Add(JSONParam);
    End;
  End;
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Error';
 JSONParam.ObjectDirection             := odInOut;
 JSONParam.AsBoolean                   := False;
 DWParams.Add(JSONParam);
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'MessageError';
 JSONParam.ObjectDirection             := odInOut;
 JSONParam.AsString                    := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Result';
 JSONParam.ObjectDirection             := odOUT;
 JSONParam.ObjectValue                 := ovString;
// JSONParam.Encoded                     := False;
 JSONParam.AsString                    := '';
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'RowsAffected';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovInteger;
 DWParams.Add(JSONParam);
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('ApplyUpdatesTB', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result          := TJSONValue.Create;
     Result.Encoding := vEncoding;
     If DWParams.ItemsString['MessageError'] <> Nil Then
      Begin
       If Not DWParams.ItemsString['MessageError'].IsNull Then
        MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
      End;
     If DWParams.ItemsString['Error'] <> Nil Then
      Begin
       If Not DWParams.ItemsString['Error'].IsNull Then
        Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
      End;
     If DWParams.ItemsString['RowsAffected'] <> Nil Then
      RowsAffected  := DWParams.ItemsString['RowsAffected'].AsInteger;
     If DWParams.ItemsString['Result'] <> Nil Then
     If Not DWParams.ItemsString['Result'].isnull Then
      Begin
       If DWParams.ItemsString['Result'].AsString <> '' Then
        Begin
         If Massive.ReflectChanges Then
          Begin
           bJsonValue  := TRESTDWJSONInterfaceObject.Create(DWParams.ItemsString['Result'].AsString);
           If bJsonValue.PairCount > 3 Then
            Result.SetValue(Decodestrings(TRESTDWJSONInterfaceObject(bJsonValue).Pairs[4].Value{$IFDEF RESTDWLAZARUS}, Result.DatabaseCharSet{$ENDIF}));
           FreeAndNil(bJsonValue);
          End
         Else
          Result.SetValue(DWParams.ItemsString['Result'].AsString);
        End;
      End;
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.ApplyUpdates(Massive                 : TMassiveDatasetBuffer;
                                                Pooler, Method_Prefix,
                                                SQL                     : String;
                                                Params                  : TRESTDWParams;
                                                Var Error               : Boolean;
                                                Var MessageError        : String;
                                                Var SocketError         : Boolean;
                                                Var RowsAffected        : Integer;
                                                TimeOut                 : Integer = 3000;
                                                ConnectTimeOut          : Integer = 3000;
                                                MassiveBuffer           : String  = '';
                                                ConnectionDefs          : TObject           = Nil;
                                                RESTClientPooler        : TRESTClientPoolerBase = Nil) : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
 bJsonValue           : TRESTDWJSONInterfaceObject;
 vMassiveStream       : TStream;
Begin
 Result := Nil;
 RowsAffected  := 0;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec                 := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                              := TRESTDWParams.Create;
 DWParams.Encoding                     := RESTClientPoolerExec.Encoding;
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Massive';
 JSONParam.ObjectDirection             := odIn;
 If Massive <> Nil Then
  Begin
   If vBinaryRequest Then
    Begin
     vMassiveStream := TMemoryStream.Create;
     Try
      TMassiveDatasetBuffer(Massive).SaveToStream(vMassiveStream, Massive);
      JSONParam.LoadFromStream(vMassiveStream);
     Finally
      FreeAndNil(vMassiveStream);
     End;
    End
   Else
    JSONParam.AsString                 := TMassiveDatasetBuffer(Massive).ToJSON;
  End
 Else If MassiveBuffer <> '' Then
  JSONParam.AsString                   := MassiveBuffer;
 DWParams.Add(JSONParam);
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Pooler';
 JSONParam.ObjectDirection             := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString                   := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString                   := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Method_Prefix';
 JSONParam.ObjectDirection             := odIn;
 JSONParam.AsString                    := Method_Prefix;
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                           := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                 := 'dwConnectionDefs';
   JSONParam.ObjectDirection           := odIn;
   JSONParam.AsString                  := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 If Trim(SQL) <> '' Then
  Begin
   JSONParam                           := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                 := 'SQL';
   JSONParam.ObjectDirection           := odIn;
   If RESTClientPoolerExec.CriptOptions.Use Then
    JSONParam.AsString                 := RESTClientPoolerExec.CriptOptions.Encrypt(SQL)
   Else
    JSONParam.AsString                 := SQL;
   DWParams.Add(JSONParam);
   If Params <> Nil Then
    Begin
     If Params.Count > 0 Then
      Begin
       JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
       JSONParam.ParamName             := 'Params';
       JSONParam.ObjectDirection       := odInOut;
       If RESTClientPoolerExec.CriptOptions.Use Then
        JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Params.ToJSON)
       Else
        JSONParam.AsString             := Params.ToJSON;
       DWParams.Add(JSONParam);
      End;
    End;
  End;
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Error';
 JSONParam.ObjectDirection             := odInOut;
 JSONParam.AsBoolean                   := False;
 DWParams.Add(JSONParam);
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'MessageError';
 JSONParam.ObjectDirection             := odInOut;
 JSONParam.AsString                    := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                   := 'Result';
 JSONParam.ObjectDirection             := odOUT;
 JSONParam.ObjectValue                 := ovString;
// JSONParam.Encoded                     := False;
 JSONParam.AsString                    := '';
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'RowsAffected';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovInteger;
 DWParams.Add(JSONParam);
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('ApplyUpdates', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result          := TJSONValue.Create;
     Result.Encoding := vEncoding;
     If DWParams.ItemsString['MessageError'] <> Nil Then
      Begin
       If Not DWParams.ItemsString['MessageError'].IsNull Then
        MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
      End;
     If DWParams.ItemsString['Error'] <> Nil Then
      Begin
       If Not DWParams.ItemsString['Error'].IsNull Then
        Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
      End;
     If DWParams.ItemsString['RowsAffected'] <> Nil Then
      RowsAffected  := DWParams.ItemsString['RowsAffected'].AsInteger;
     If DWParams.ItemsString['Result'] <> Nil Then
     If Not DWParams.ItemsString['Result'].isnull Then
      Begin
       If DWParams.ItemsString['Result'].AsString <> '' Then
        Begin
         If Massive.ReflectChanges Then
          Begin
           bJsonValue  := TRESTDWJSONInterfaceObject.Create(DWParams.ItemsString['Result'].AsString);
           If bJsonValue.PairCount > 3 Then
            Result.SetValue(Decodestrings(TRESTDWJSONInterfaceObject(bJsonValue).Pairs[4].Value{$IFDEF RESTDWLAZARUS}, Result.DatabaseCharSet{$ENDIF}));
           FreeAndNil(bJsonValue);
          End
         Else
          Result.SetValue(DWParams.ItemsString['Result'].AsString);
        End;
      End;
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function  TRESTDWPoolerMethodClient.RenewToken(Var Params           : TRESTDWParams;
                                           Var Error            : Boolean;
                                           Var MessageError     : String) : String;
Var
 I                    : Integer;
 vTempSend            : String;
 vConnection          : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 Procedure DestroyComponents;
 Begin
  If Assigned(RESTClientPoolerExec) Then
   FreeAndNil(RESTClientPoolerExec);
 End;
Begin
 //Atualização de Token na autenticação
 Result                       := '';
 RESTClientPoolerExec         := Nil;
 vConnection                  := TRESTDWPoolerMethodClient.Create(Nil);
 vConnection.HandleRedirects  := vHandleRedirects;
 vConnection.RedirectMaximum  := vRedirectMaximum;
 vConnection.UserAgent        := vUserAgent;
 vConnection.TypeRequest      := vTypeRequest;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vHost;
 vConnection.Port             := vPort;
 vConnection.Compression      := vCompression;
 vConnection.EncodeStrings    := EncodeStrings;
 vConnection.Encoding         := Encoding;
 vConnection.AccessTag        := vAccessTag;
 vConnection.CriptOptions.Use := vCripto.Use;
 vConnection.CriptOptions.Key := vCripto.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFNDEF RESTDWLAZARUS}
  vConnection.Encoding        := vEncoding;
 {$ELSE}
  vConnection.DatabaseCharSet := csUndefined;
 {$ENDIF}
 If vAuthOptionParams.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   Try
    Try
     Case vAuthOptionParams.AuthorizationOption Of
      rdwAOBearer : Begin
                     vTempSend := vConnection.GetToken(vPoolerURL,
                                                       Params,      Error,
                                                       MessageError,vTimeOut,vConnectTimeout,
                                                       Nil,         RESTClientPoolerExec);
                     vTempSend                                      := GettokenValue(vTempSend);
                     TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
      rdwAOToken  : Begin
                     vTempSend := vConnection.GetToken(vPoolerURL,
                                                       Params,       Error,
                                                       MessageError, vTimeOut,vConnectTimeout,
                                                       Nil,          RESTClientPoolerExec);
                     vTempSend                                       := GettokenValue(vTempSend);
                     TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
     End;
     Result      := vTempSend;
     If csDesigning in ComponentState Then
      If Error Then Raise Exception.Create(PChar(cAuthenticationError));
     If Error Then
      Result      := '';
    Except
     On E : Exception do
      Begin
       DestroyComponents;
      End;
    End;
   Finally
    DestroyComponents;
    If vConnection <> Nil Then
     FreeAndNil(vConnection);
   End;
  End;
End;

Procedure TRESTDWPoolerMethodClient.TokenValidade;
Var
 DWParams      : TRESTDWParams;
 vToken,
 vMessageError : String;
 vErrorBoolean : Boolean;
Begin
 DWParams      := TRESTDWParams.Create;
 vToken        := '';
 vMessageError := '';
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

Procedure TRESTDWPoolerMethodClient.SetAuthOptionParams(Value : TRESTDWClientAuthOptionParams);
Begin
 vAuthOptionParams.Assign(Value);
End;

Procedure TRESTDWPoolerMethodClient.SetOnStatus(Value : TOnStatus);
Begin
  vOnStatus            := Value;
End;

Procedure TRESTDWPoolerMethodClient.SetOnWork(Value : TOnWork);
Begin
  vOnWork            := Value;
End;

Procedure TRESTDWPoolerMethodClient.SetOnWorkBegin(Value : TOnWork);
Begin
  vOnWorkBegin            := Value;
End;

Procedure TRESTDWPoolerMethodClient.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
  vOnWorkEnd            := Value;
End;

Function  TRESTDWPoolerMethodClient.ProcessMassiveSQLCache(MassiveSQLCache,
                                                       Pooler, Method_Prefix   : String;
                                                       Var Error               : Boolean;
                                                       Var MessageError        : String;
                                                       Var SocketError         : Boolean;
                                                       TimeOut                 : Integer = 3000;
                                                       ConnectTimeOut          : Integer = 3000;
                                                       ConnectionDefs          : TObject = Nil;
                                                       RESTClientPooler        : TRESTClientPoolerBase = Nil) : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TRESTDWParams;
Begin
 Result := Nil;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MassiveSQLCache';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.ObjectValue           := ovString;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.SetValue(RESTClientPoolerExec.CriptOptions.Encrypt(MassiveSQLCache), JSONParam.Encoded)
 Else
  JSONParam.SetValue(MassiveSQLCache, JSONParam.Encoded);
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovString;
// JSONParam.Encoded               := False;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('ProcessMassiveSQLCache', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result          := TJSONValue.Create;
     Result.Encoding := vEncoding;
     If Not DWParams.ItemsString['MessageError'].IsNull Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If DWParams.ItemsString['Result'].AsString <> '' Then
        Result.SetValue(DWParams.ItemsString['Result'].AsString);
      End;
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.ApplyUpdates_MassiveCache(MassiveCache            : TStream;
                                                             Pooler, Method_Prefix   : String;
                                                             Var Error               : Boolean;
                                                             Var MessageError        : String;
                                                             Var SocketError         : Boolean;
                                                             TimeOut                 : Integer = 3000;
                                                             ConnectTimeOut          : Integer = 3000;
                                                             ConnectionDefs          : TObject = Nil;
                                                             ReflectChanges          : Boolean = False;
                                                             RESTClientPooler        : TRESTClientPoolerBase = Nil) : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TRESTDWParams;
Begin
 Result := Nil;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MassiveCache';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.ObjectValue           := ovBlob;
 JSONParam.LoadFromStream(MassiveCache);
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovString;
// JSONParam.Encoded               := False;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := True;
   lResponse := RESTClientPoolerExec.SendEvent('ApplyUpdates_MassiveCache', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result          := TJSONValue.Create;
     Result.Encoding := vEncoding;
     If Not DWParams.ItemsString['MessageError'].IsNull Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If DWParams.ItemsString['Result'].AsString <> '' Then
        Result.SetValue(DWParams.ItemsString['Result'].AsString);
      End;
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     SocketError   := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Constructor TRESTDWPoolerMethodClient.Create(AOwner: TComponent);
Begin
 Inherited;
 vCompression     := True;
 vEncodeStrings   := True;
 vHandleRedirects := False;
 vRedirectMaximum := 0;
 vTimeOut         := 3000;
 vConnectTimeOut  := 3000;
 vBinaryRequest   := False;
 vPoolerNotFoundMessage := cPoolerNotFound;
 {$IF Defined(RESTDWLAZARUS) or Defined(DELPHIXEUP)}
 vEncoding        := esUtf8;
 {$ELSE}
 vEncoding        := esASCII;
 {$IFEND}
 {$IFDEF RESTDWLAZARUS}
 vDatabaseCharSet := csUndefined;
 {$ENDIF}
 vCripto          := TCripto.Create;
 Host             := '127.0.0.1';
 Port             := 8082;
 vUserAgent       := cUserAgent;
 vAuthOptionParams                     := TRESTDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
End;

Destructor TRESTDWPoolerMethodClient.Destroy;
Begin
 If Assigned(vCripto) Then
  FreeAndNil(vCripto);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Function TRESTDWPoolerMethodClient.GetPoolerList(Method_Prefix    : String;
                                                 TimeOut          : Integer = 3000;
                                                 ConnectTimeOut   : Integer = 3000;
                                                 RESTClientPooler : TRESTClientPoolerBase = Nil)   : TStringList;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 vTempString,
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
Begin
 Result := Nil;
 If Not Assigned(RESTClientPooler) Then
  Begin
   RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil);
   RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
  End
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.WelcomeMessage  := vWelcomeMessage;
 RESTClientPoolerExec.HandleRedirects := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum := vRedirectMaximum;
 RESTClientPoolerExec.Host            := Host;
 RESTClientPoolerExec.Port            := Port;
 RESTClientPoolerExec.RequestTimeOut  := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression := Compression;
 RESTClientPoolerExec.TypeRequest     := vtyperequest;
 RESTClientPoolerExec.OnWork          := vOnWork;
 RESTClientPoolerExec.OnWorkBegin     := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd       := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus        := vOnStatus;
 RESTClientPoolerExec.Encoding        := vEncoding;
 RESTClientPoolerExec.UserAgent       := vUserAgent;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 RESTClientPoolerExec.CriptOptions.Use:= vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key:= vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams  := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovString;
 JSONParam.AsString              := '';
// JSONParam.SetValue('', JSONParam.Encoded);
 DWParams.Add(JSONParam);
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('GetPoolerList', DWParams);
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
      lResponse  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      lResponse  := cInvalidAuth;
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
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.EchoPooler(Method_Prefix,
                                              Pooler                  : String;
                                              TimeOut                 : Integer = 3000;
                                              ConnectTimeOut          : Integer = 3000;
                                              RESTClientPooler        : TRESTClientPoolerBase = Nil) : String;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 BufferStream         : TRESTDWBufferBase;
 vRESTDWBytes         : TRESTDWBytes;
 vStream              : TStream;
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
Begin
 If Not Assigned(RESTClientPooler) Then
  Begin
   RESTClientPoolerExec                  := TRESTClientPoolerBase.Create(Nil);
   RESTClientPoolerExec.Host             := Host;
   RESTClientPoolerExec.Port             := Port;
   RESTClientPoolerExec.DataCompression  := vCompression;
   RESTClientPoolerExec.TypeRequest      := vtyperequest;
   RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
   RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
   RESTClientPoolerExec.SetAccessTag(vAccessTag);
   RESTClientPoolerExec.Encoding         := vEncoding;
   {$IFDEF RESTDWLAZARUS}
    RESTClientPoolerExec.DatabaseCharSet := vDatabaseCharSet;
   {$ENDIF}
  End
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   RESTClientPoolerExec.Host             := Host;
   RESTClientPoolerExec.Port             := Port;
   RESTClientPoolerExec.DataCompression  := vCompression;
   RESTClientPoolerExec.TypeRequest      := vtyperequest;
   RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
   RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
   RESTClientPoolerExec.SetAccessTag(vAccessTag);
   RESTClientPoolerExec.Encoding         := vEncoding;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent          := vUserAgent;
 RESTClientPoolerExec.RequestTimeOut     := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut     := ConnectTimeOut;
 RESTClientPoolerExec.HandleRedirects    := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum    := vRedirectMaximum;
 RESTClientPoolerExec.OnWork             := vOnWork;
 RESTClientPoolerExec.OnWorkBegin        := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd          := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus           := vOnStatus;
 RESTClientPoolerExec.CriptOptions.Use   := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key   := vCripto.Key;
 RESTClientPoolerExec.DataRoute          := DataRoute;
 DWParams                                := TRESTDWParams.Create;
 DWParams.Encoding                       := RESTClientPoolerExec.Encoding;
 JSONParam                               := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                     := 'Pooler';
 JSONParam.ObjectDirection               := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString                     := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString                     := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                               := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName                     := 'Result';
 JSONParam.ObjectDirection               := odOUT;
 JSONParam.ObjectValue                   := ovString;
 JSONParam.AsString                      := '';
// JSONParam.SetValue('', JSONParam.Encoded);
 DWParams.Add(JSONParam);
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('EchoPooler', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     If BinaryRequest Then
      Begin
       BufferStream  := TRESTDWBufferBase.Create;
       vStream       := TMemoryStream.Create;
       Try
        DWParams.ItemsString['Result'].SaveToStream(vStream);
        BufferStream.LoadToStream(vStream);
        FreeAndNil(vStream);
        vRESTDWBytes := BufferStream.ReadBytes;
        If Length(vRESTDWBytes) > 0 Then
         Begin
          Result := BytesToString(vRESTDWBytes);
          SetLength(vRESTDWBytes, 0);
         End;
       Finally
        FreeAndNil(BufferStream);
       End;
      End
     Else
      Result   := DWParams.ItemsString['Result'].AsString;
    End
   Else
    Begin
     If (lResponse = '') Then
      lResponse  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      lResponse  := cInvalidAuth;
     Raise Exception.Create(lResponse);
     lResponse   := '';
    End;
  Except
   On E : Exception Do
    Begin
     Raise Exception.Create(E.Message);
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   If Assigned(RESTClientPoolerExec) Then
    FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.ExecuteCommand(Pooler, Method_Prefix,
                                              SQL                     : String;
                                              Params                  : TRESTDWParams;
                                              Var Error               : Boolean;
                                              Var MessageError        : String;
                                              Var SocketError         : Boolean;
                                              Var RowsAffected        : Integer;
                                              Execute                 : Boolean;
                                              BinaryRequest           : Boolean;
                                              BinaryCompatibleMode    : Boolean;
                                              Metadata                : Boolean;
                                              TimeOut                 : Integer = 3000;
                                              ConnectTimeOut          : Integer = 3000;
                                              ConnectionDefs          : TObject           = Nil;
                                              RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
Begin
 Result := Nil;
 RowsAffected  := 0;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec                 := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'SQL';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(SQL)
 Else
  JSONParam.AsString             := SQL;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Params';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Params.ToJSON)
 Else
  JSONParam.AsString             := Params.ToJSON;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Execute';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := Execute;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryRequest;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryCompatibleMode';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryCompatibleMode;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MetadataRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := Metadata;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 If Not vBinaryRequest Then
  Begin
   JSONParam.ObjectValue         := ovString;
   JSONParam.AsString            := '';
  End
 Else
  JSONParam.ObjectValue          := ovBlob;
// JSONParam.Encoded               := False;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'RowsAffected';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovInteger;
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('ExecuteCommandJSON', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result         := TJSONValue.Create;
     Result.Encoded := False;
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['RowsAffected'] <> Nil Then
      RowsAffected  := DWParams.ItemsString['RowsAffected'].AsInteger;
     If DWParams.ItemsString['Result'] <> Nil Then
      Result.LoadFromJSON(DWParams.ItemsString['Result'].AsString);
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.ExecuteCommandJSONTB(Pooler,
                                                    Method_Prefix,
                                                    Tablename   : String;
                                                    Params                  : TRESTDWParams;
                                                    Var Error               : Boolean;
                                                    Var MessageError        : String;
                                                    Var SocketError         : Boolean;
                                                    Var RowsAffected        : Integer;
                                                    BinaryRequest           : Boolean;
                                                    BinaryCompatibleMode    : Boolean;
                                                    Metadata                : Boolean;
                                                    TimeOut                 : Integer = 3000;
                                                    ConnectTimeOut          : Integer = 3000;
                                                    ConnectionDefs          : TObject           = Nil;
                                                    RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TRESTDWParams;
Begin
 RowsAffected  := 0;
 SocketError   := False;
 Error         := False;
 MessageError  := '';
 Result        := Nil;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Params';
 JSONParam.ObjectDirection       := odInOut;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Params.ToJSON)
 Else
  JSONParam.AsString             := Params.ToJSON;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryRequest;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryCompatibleMode';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryCompatibleMode;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MetadataRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := Metadata;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'rdwtablename';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Tablename;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 If Not vBinaryRequest Then
  Begin
   JSONParam.ObjectValue         := ovString;
   JSONParam.AsString            := '';
  End
 Else
  JSONParam.ObjectValue          := ovBlob;
// JSONParam.SetValue('', JSONParam.Encoded);
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'RowsAffected';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovInteger;
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('ExecuteCommandJSONTB', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result         := TJSONValue.Create;
     Result.Encoded := False;
     Result.Encoding := RESTClientPoolerExec.Encoding;
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['RowsAffected'] <> Nil Then
      RowsAffected  := DWParams.ItemsString['RowsAffected'].AsInteger;
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If DWParams.ItemsString['Result'].AsString <> '' Then
        Begin
         If Not BinaryRequest Then
          Result.LoadFromJSON(DWParams.ItemsString['Result'].AsString)
         Else
          Result.SetValue(DWParams.ItemsString['Result'].AsString, False);
        End
       Else
        Result.SetValue(lResponse, False);
      End;
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     SocketError   := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.ExecuteCommandJSON(Pooler, Method_Prefix,
                                                  SQL                     : String;
                                                  Params                  : TRESTDWParams;
                                                  Var Error               : Boolean;
                                                  Var MessageError        : String;
                                                  Var SocketError         : Boolean;
                                                  Var RowsAffected        : Integer;
                                                  Execute                 : Boolean;
                                                  BinaryRequest           : Boolean;
                                                  BinaryCompatibleMode    : Boolean;
                                                  Metadata                : Boolean;
                                                  TimeOut                 : Integer = 3000;
                                                  ConnectTimeOut          : Integer = 3000;
                                                  ConnectionDefs          : TObject           = Nil;
                                                  RESTClientPooler        : TRESTClientPoolerBase = Nil)   : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
 vStream              : TStream;
Begin
 RowsAffected  := 0;
 SocketError   := False;
 Error         := False;
 MessageError  := '';
 Result        := Nil;
 vStream       := Nil;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'SQL';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(SQL)
 Else
  JSONParam.AsString             := SQL;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Params';
 JSONParam.ObjectDirection       := odInOut;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Params.ToJSON)
 Else
  JSONParam.AsString             := Params.ToJSON;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Execute';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := Execute;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryRequest;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryCompatibleMode';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryCompatibleMode;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MetadataRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := Metadata;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 If Not vBinaryRequest Then
  Begin
   JSONParam.ObjectValue         := ovString;
   JSONParam.AsString            := '';
  End
 Else
  JSONParam.ObjectValue          := ovBlob;
// JSONParam.SetValue('', JSONParam.Encoded);
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'RowsAffected';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovInteger;
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('ExecuteCommandJSON', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result         := TJSONValue.Create;
     Result.Encoded := False;
     Result.Encoding := RESTClientPoolerExec.Encoding;
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['RowsAffected'] <> Nil Then
      RowsAffected  := DWParams.ItemsString['RowsAffected'].AsInteger;
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If Not (DWParams.ItemsString['Result'].IsEmpty) Then
        Begin
         If Not BinaryRequest Then
          Result.LoadFromJSON(DWParams.ItemsString['Result'].AsString)
         Else
          Begin
           Try
            DWParams.ItemsString['Result'].SaveToStream(vStream);
            Result.LoadFromStream(TMemoryStream(vStream));
           Finally
            vStream.Free;
           End;
//           Result.SetValue(DWParams.ItemsString['Result'].AsString, False);
          End;
        End
       Else
        Result.SetValue(lResponse, False);
      End;
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     SocketError   := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.ExecuteCommandPureJSONTB(Pooler,
                                                        Method_Prefix,
                                                        Tablename            : String;
                                                        Var Error            : Boolean;
                                                        Var MessageError     : String;
                                                        Var SocketError      : Boolean;
                                                        Var RowsAffected     : Integer;
                                                        BinaryRequest        : Boolean;
                                                        BinaryCompatibleMode : Boolean;
                                                        Metadata             : Boolean;
                                                        TimeOut              : Integer = 3000;
                                                        ConnectTimeOut       : Integer = 3000;
                                                        ConnectionDefs       : TObject           = Nil;
                                                        RESTClientPooler     : TRESTClientPoolerBase = Nil)   : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TRESTDWParams;
Begin
 Result        := Nil;
 SocketError   := False;
 Error         := False;
 MessageError  := '';
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryRequest;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryCompatibleMode';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryCompatibleMode;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MetadataRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := Metadata;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'rdwtablename';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Tablename;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 If Not vBinaryRequest Then
  Begin
   JSONParam.ObjectValue         := ovString;
   JSONParam.AsString            := '';
  End
 Else
  JSONParam.ObjectValue          := ovBlob;
// JSONParam.ObjectValue           := ovString;
// JSONParam.Encoded               := True;
// JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'RowsAffected';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovInteger;
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('ExecuteCommandPureJSONTB', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result          := TJSONValue.Create;
     Result.Encoded  := False;
     Result.Encoding := RESTClientPoolerExec.Encoding;
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['RowsAffected'] <> Nil Then
      RowsAffected  := DWParams.ItemsString['RowsAffected'].AsInteger;
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If Not (DWParams.ItemsString['Result'].IsEmpty) Then
        Begin
         If Not BinaryRequest Then
          Result.LoadFromJSON(DWParams.ItemsString['Result'].AsString)
         Else
          Result.SetValue(DWParams.ItemsString['Result'].AsString, False);
        End
       Else
        Result.SetValue(lResponse, False);
      End;
    End
   Else
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value)
     Else
      Begin
       Error         := True;
       If (lResponse = '') Then
        MessageError  := Format('Unresolved Host : ''%s''', [Host])
       Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
        MessageError  := cInvalidAuth;
      End;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     SocketError   := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.ExecuteCommandPureJSON(Pooler,
                                                      Method_Prefix,
                                                      SQL                  : String;
                                                      Var Error            : Boolean;
                                                      Var MessageError     : String;
                                                      Var SocketError      : Boolean;
                                                      Var RowsAffected     : Integer;
                                                      Execute              : Boolean;
                                                      BinaryRequest        : Boolean;
                                                      BinaryCompatibleMode : Boolean;
                                                      Metadata             : Boolean;
                                                      TimeOut              : Integer = 3000;
                                                      ConnectTimeOut       : Integer = 3000;
                                                      ConnectionDefs       : TObject           = Nil;
                                                      RESTClientPooler     : TRESTClientPoolerBase = Nil)   : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TRESTDWParams;
 vStream          : TStream;
Begin
 Result        := Nil;
 vStream       := Nil;
 SocketError   := False;
 Error         := False;
 MessageError  := '';
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.BinaryRequest    := BinaryRequest;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'SQL';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(SQL)
 Else
  JSONParam.AsString             := SQL;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Execute';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := Execute;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryRequest;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryCompatibleMode';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := BinaryCompatibleMode;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MetadataRequest';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsBoolean             := Metadata;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 If Not vBinaryRequest Then
  Begin
   JSONParam.ObjectValue         := ovString;
   JSONParam.AsString            := '';
  End
 Else
  JSONParam.ObjectValue          := ovBlob;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'RowsAffected';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovInteger;
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('ExecuteCommandPureJSON', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result          := TJSONValue.Create;
     Result.Encoded  := False;
     Result.Encoding := RESTClientPoolerExec.Encoding;
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['RowsAffected'] <> Nil Then
      RowsAffected  := DWParams.ItemsString['RowsAffected'].AsInteger;
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If Not (DWParams.ItemsString['Result'].IsEmpty) Then
        Begin
         If Not BinaryRequest Then
          Result.LoadFromJSON(DWParams.ItemsString['Result'].AsString)
         Else
          Begin
           Try
            DWParams.ItemsString['Result'].SaveToStream(vStream);
            Result.LoadFromStream(TMemoryStream(vStream));
           Finally
            vStream.Free;
           End;
//           Result.SetValue(DWParams.ItemsString['Result'].AsString, False);
          End;
        End
       Else
        Result.SetValue(lResponse, False);
      End;
    End
   Else
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value)
     Else
      Begin
       Error         := True;
       If (lResponse = '') Then
        MessageError  := Format('Unresolved Host : ''%s''', [Host])
       Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
        MessageError  := cInvalidAuth;
      End;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     SocketError   := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Procedure TRESTDWPoolerMethodClient.ExecuteProcedure(Pooler,
                                                 Method_Prefix,
                                                 ProcName            : String;
                                                 Params              : TRESTDWParams;
                                                 Var Error           : Boolean;
                                                 Var MessageError    : String;
                                                 Var SocketError     : Boolean;
                                                 ConnectionDefs      : TObject           = Nil;
                                                 RESTClientPooler    : TRESTClientPoolerBase = Nil);
Var
 JSONParam : TJSONParam;
Begin
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPooler.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   Params.Add(JSONParam);
  End;
End;

Function  TRESTDWPoolerMethodClient.GetTableNames(Pooler,
                                              Method_Prefix           : String;
                                              Var TableNames          : TStringList;
                                              Var Error               : Boolean;
                                              Var MessageError        : String;
                                              Var SocketError         : Boolean;
                                              TimeOut                 : Integer = 3000;
                                              ConnectTimeOut          : Integer = 3000;
                                              ConnectionDefs          : TObject           = Nil;
                                              RESTClientPooler        : TRESTClientPoolerBase = Nil)  : Boolean;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TRESTDWParams;
Begin
 Result        := False;
 SocketError   := False;
 Error         := False;
 MessageError  := '';
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.AsString              := '';
// JSONParam.ObjectValue           := ovBlob;
// JSONParam.Encoded               := True;
// JSONParam.SetValue('', JSONParam.Encoded);
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('GetTableNames', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If Not (DWParams.ItemsString['Result'].IsEmpty) Then
        TableNames.Text := DWParams.ItemsString['Result'].AsString
       Else
        TableNames.Text := '';
      End;
     Result        := Not Error;
    End
   Else
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Begin
       Error  := StringToBoolean(DWParams.ItemsString['Error'].Value);
       Result := Not Error;
      End
     Else
      Begin
       Result := False;
       Error         := True;
       If (lResponse = '') Then
        MessageError  := Format('Unresolved Host : ''%s''', [Host])
       Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
        MessageError  := cInvalidAuth;
      End;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     SocketError   := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function  TRESTDWPoolerMethodClient.GetFieldNames(Pooler,
                                              Method_Prefix,
                                              TableName               : String;
                                              Var FieldNames          : TStringList;
                                              Var Error               : Boolean;
                                              Var MessageError        : String;
                                              Var SocketError         : Boolean;
                                              TimeOut                 : Integer = 3000;
                                              ConnectTimeOut          : Integer = 3000;
                                              ConnectionDefs          : TObject           = Nil;
                                              RESTClientPooler        : TRESTClientPoolerBase = Nil)  : Boolean;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TRESTDWParams;
Begin
 Result        := False;
 SocketError   := False;
 Error         := False;
 MessageError  := '';
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'TableName';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := TableName;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('GetFieldNames', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If Not (DWParams.ItemsString['Result'].IsEmpty) Then
        FieldNames.Text := DWParams.ItemsString['Result'].AsString
       Else
        FieldNames.Text := '';
      End;
     Result        := Not Error;
    End
   Else
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Begin
       Error  := StringToBoolean(DWParams.ItemsString['Error'].Value);
       Result := Not Error;
      End
     Else
      Begin
       Result := False;
       Error         := True;
       If (lResponse = '') Then
        MessageError  := Format('Unresolved Host : ''%s''', [Host])
       Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
        MessageError  := cInvalidAuth;
      End;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     SocketError   := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function  TRESTDWPoolerMethodClient.GetKeyFieldNames(Pooler,
                                                 Method_Prefix,
                                                 TableName               : String;
                                                 Var FieldNames          : TStringList;
                                                 Var Error               : Boolean;
                                                 Var MessageError        : String;
                                                 Var SocketError         : Boolean;
                                                 TimeOut                 : Integer = 3000;
                                                 ConnectTimeOut          : Integer = 3000;
                                                 ConnectionDefs          : TObject           = Nil;
                                                 RESTClientPooler        : TRESTClientPoolerBase = Nil)  : Boolean;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TRESTDWParams;
Begin
 Result        := False;
 SocketError   := False;
 Error         := False;
 MessageError  := '';
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'TableName';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := TableName;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('GetKeyFieldNames', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If Not (DWParams.ItemsString['Result'].IsEmpty) Then
        FieldNames.Text := DWParams.ItemsString['Result'].AsString
       Else
        FieldNames.Text := '';
      End;
     Result        := Not Error;
    End
   Else
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Error'] <> Nil Then
      Begin
       Error  := StringToBoolean(DWParams.ItemsString['Error'].Value);
       Result := Not Error;
      End
     Else
      Begin
       Result := False;
       Error         := True;
       If (lResponse = '') Then
        MessageError  := Format('Unresolved Host : ''%s''', [Host])
       Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
        MessageError  := cInvalidAuth;
      End;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     SocketError   := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Procedure TRESTDWPoolerMethodClient.ExecuteProcedurePure(Pooler,
                                                     Method_Prefix,
                                                     ProcName            : String;
                                                     Var Error           : Boolean;
                                                     Var MessageError    : String;
                                                     Var SocketError     : Boolean;
                                                     ConnectionDefs      : TObject           = Nil;
                                                     RESTClientPooler    : TRESTClientPoolerBase = Nil);
Var
 JSONParam : TJSONParam;
 Params    : TRESTDWParams;
Begin
 Params := Nil;
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPooler.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   If Assigned(Params) Then
    Params.Add(JSONParam);
  End;
End;

Procedure TRESTDWPoolerMethodClient.GetPoolerList(Method_Prefix    : String;
                                              Var PoolerList   : TStringList;
                                              TimeOut          : Integer = 3000;
                                              ConnectTimeOut   : Integer = 3000;
                                              RESTClientPooler : TRESTClientPoolerBase = Nil);
Begin

End;

Function TRESTDWPoolerMethodClient.GetServerEvents(Method_Prefix    : String;
                                                   TimeOut          : Integer;
                                                   ConnectTimeOut   : Integer;
                                                   RESTClientPooler : TRESTClientPoolerBase) : TStringList;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 vTempString,
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
Begin
 Result := Nil;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec               := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.WelcomeMessage  := vWelcomeMessage;
 RESTClientPoolerExec.Host            := Host;
 RESTClientPoolerExec.Port            := Port;
 RESTClientPoolerExec.RequestTimeOut  := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut  := ConnectTimeOut;
 RESTClientPoolerExec.HandleRedirects := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum := vRedirectMaximum;
 RESTClientPoolerExec.DataCompression := Compression;
 RESTClientPoolerExec.TypeRequest     := vtyperequest;
 RESTClientPoolerExec.OnWork          := vOnWork;
 RESTClientPoolerExec.OnWorkBegin     := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd       := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus        := vOnStatus;
 RESTClientPoolerExec.Encoding        := vEncoding;
 RESTClientPoolerExec.CriptOptions.Use:= vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key:= vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 TokenValidade;
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams  := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovString;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('GetServerEventsList', DWParams);
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
      lResponse  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      lResponse  := cInvalidAuth;
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
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.GetToken(Pooler           : String;
                                            Params           : TRESTDWParams;
                                            Var Error        : Boolean;
                                            Var MessageError : String;
                                            TimeOut          : Integer = 3000;
                                            ConnectTimeOut   : Integer = 3000;
                                            ConnectionDefs   : TObject = Nil;
                                            RESTClientPooler : TRESTClientPoolerBase = Nil) : String;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 vGetTokenEvent,
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
Begin
 Result := '';
 RESTClientPoolerExec            := RESTClientPooler;
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'DataRoute';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := vDataRoute;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'RDWParams';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Params.ToJSON)
 Else
  JSONParam.AsString             := Params.ToJSON;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   If RESTClientPoolerExec.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Begin
     vGetTokenEvent := TRESTDWAuthOptionBearerClient(RESTClientPoolerExec.AuthenticationOptions.OptionParams).GetTokenEvent;
     lResponse := RESTClientPoolerExec.SendEvent(vGetTokenEvent, DWParams);
    End
   Else If RESTClientPoolerExec.AuthenticationOptions.AuthorizationOption = rdwAOToken Then
    Begin
     vGetTokenEvent := TRESTDWAuthOptionTokenClient(RESTClientPoolerExec.AuthenticationOptions.OptionParams).GetTokenEvent;
     lResponse := RESTClientPoolerExec.SendEvent(vGetTokenEvent, DWParams);
    End;
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result         := '';
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If Error Then
      If DWParams.ItemsString['MessageError'] <> Nil Then
       MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     Result := lResponse;
     If vBinaryRequest Then
      Begin
       If DWParams.ItemsString['token'] <> Nil Then
        Result := DWParams.ItemsString['token'].AsString
      End;
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.InsertValue(Pooler, Method_Prefix,
                                           SQL                     : String;
                                           Params                  : TRESTDWParams;
                                           Var Error               : Boolean;
                                           Var MessageError        : String;
                                           Var SocketError         : Boolean;
                                           TimeOut                 : Integer = 3000;
                                           ConnectTimeOut          : Integer = 3000;
                                           ConnectionDefs          : TObject           = Nil;
                                           RESTClientPooler        : TRESTClientPoolerBase = Nil): Integer;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
Begin
 Result := -1;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'SQL';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(SQL)
 Else
  JSONParam.AsString             := SQL;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Params';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Params.ToJSON)
 Else
  JSONParam.AsString             := Params.ToJSON;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                     := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                     := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovString;
 JSONParam.AsString              := '';
// JSONParam.SetValue('', JSONParam.Encoded);
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('InsertMySQLReturnID_PARAMS', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     Result         := -1;
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Result'] <> Nil Then
      Result := StrToInt(DWParams.ItemsString['Result'].AsString);
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TRESTDWPoolerMethodClient.InsertValuePure(Pooler, Method_Prefix,
                                               SQL                     : String;
                                               Var Error               : Boolean;
                                               Var MessageError        : String;
                                               Var SocketError         : Boolean;
                                               TimeOut                 : Integer = 3000;
                                               ConnectTimeOut          : Integer = 3000;
                                               ConnectionDefs          : TObject           = Nil;
                                               RESTClientPooler        : TRESTClientPoolerBase = Nil): Integer;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
Begin
 Result := -1;
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
 Else
  Begin
   RESTClientPoolerExec := RESTClientPooler;
   DataRoute            := RESTClientPoolerExec.DataRoute;
   AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
   vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
   vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
   vtyperequest         := RESTClientPoolerExec.TypeRequest;
   If Trim(DataRoute) = '' Then
    Begin
     If Trim(Method_Prefix) <> '' Then
      Begin
       RESTClientPoolerExec.DataRoute := Method_Prefix;
       DataRoute                      := Method_Prefix;
      End;
    End;
  End;
 vActualClientPoolerExec := RESTClientPoolerExec;
 RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
 RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
 RESTClientPoolerExec.UserAgent        := vUserAgent;
 RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
 RESTClientPoolerExec.Host             := Host;
 RESTClientPoolerExec.Port             := Port;
 RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
 RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
 RESTClientPoolerExec.RequestTimeOut   := TimeOut;
 RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
 RESTClientPoolerExec.DataCompression  := vCompression;
 RESTClientPoolerExec.TypeRequest      := vtyperequest;
 RESTClientPoolerExec.OnWork           := vOnWork;
 RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
 RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
 RESTClientPoolerExec.OnStatus         := vOnStatus;
 RESTClientPoolerExec.Encoding         := vEncoding;
 RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
 RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
 RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
 RESTClientPoolerExec.DataRoute        := DataRoute;
 RESTClientPoolerExec.SetAccessTag(vAccessTag);
 {$IFDEF RESTDWLAZARUS}
 RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
 {$ENDIF}
 DWParams                        := TRESTDWParams.Create;
 DWParams.Encoding               := RESTClientPoolerExec.Encoding;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
 Else
  JSONParam.AsString             := Pooler;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := Method_Prefix;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'SQL';
 JSONParam.ObjectDirection       := odIn;
 If RESTClientPoolerExec.CriptOptions.Use Then
  JSONParam.AsString             := RESTClientPoolerExec.CriptOptions.Encrypt(SQL)
 Else
  JSONParam.AsString             := SQL;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := MessageError;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.ObjectValue           := ovString;
 JSONParam.AsString              := '';
// JSONParam.SetValue('', JSONParam.Encoded);
 DWParams.Add(JSONParam);
 If Assigned(ConnectionDefs) Then
  Begin
   JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName             := 'dwConnectionDefs';
   JSONParam.ObjectDirection       := odIn;
   JSONParam.AsString              := TConnectionDefs(ConnectionDefs).ToJSON;
   DWParams.Add(JSONParam);
  End;
 Try
  Try
   RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
   lResponse := RESTClientPoolerExec.SendEvent('InsertMySQLReturnID', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
     If DWParams.ItemsString['Result'] <> Nil Then
      Result := StrToInt(DWParams.ItemsString['Result'].AsString);
    End
   Else
    Begin
     Error         := True;
     If (lResponse = '') Then
      MessageError  := Format('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      MessageError  := cInvalidAuth;
     Raise Exception.Create(MessageError);
    End;
  Except
   On E : Exception Do
    Begin
     Error         := True;
     MessageError  := E.Message;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Procedure TRESTDWPoolerMethodClient.Abort;
Begin
 If Assigned(vActualClientPoolerExec) Then
  vActualClientPoolerExec.Abort;
End;

Function TRESTDWPoolerMethodClient.ApplyUpdates(LinesDataset,
                                            Pooler,
                                            Method_Prefix    : String;
                                            Var Error        : Boolean;
                                            Var MessageError : String;
                                            Var SocketError  : Boolean;
                                            TimeOut          : Integer = 3000;
                                            ConnectTimeOut   : Integer = 3000;
                                            ConnectionDefs   : TObject           = Nil;
                                            RESTClientPooler : TRESTClientPoolerBase = Nil) : String;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 JSONParam        : TJSONParam;
 DWParams         : TRESTDWParams;
Begin
 Result := '';
 If LinesDataset <> '' Then
  Begin
   If Not Assigned(RESTClientPooler) Then
    RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
   Else
    Begin
     RESTClientPoolerExec := RESTClientPooler;
     DataRoute            := RESTClientPoolerExec.DataRoute;
     AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
     vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
     vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
     vtyperequest         := RESTClientPoolerExec.TypeRequest;
     If Trim(DataRoute) = '' Then
      Begin
       If Trim(Method_Prefix) <> '' Then
        Begin
         RESTClientPoolerExec.DataRoute := Method_Prefix;
         DataRoute                      := Method_Prefix;
        End;
      End;
    End;
   vActualClientPoolerExec               := RESTClientPoolerExec;
   RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
   RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
   RESTClientPoolerExec.UserAgent        := vUserAgent;
   RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
   RESTClientPoolerExec.Host             := Host;
   RESTClientPoolerExec.Port             := Port;
   RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
   RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
   RESTClientPoolerExec.RequestTimeOut   := TimeOut;
   RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
   RESTClientPoolerExec.DataCompression  := vCompression;
   RESTClientPoolerExec.TypeRequest      := vtyperequest;
   RESTClientPoolerExec.TypeRequest      := vtyperequest;
   RESTClientPoolerExec.OnWork           := vOnWork;
   RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
   RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
   RESTClientPoolerExec.OnStatus         := vOnStatus;
   RESTClientPoolerExec.Encoding         := vEncoding;
   RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
   RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
   RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
   RESTClientPoolerExec.DataRoute        := DataRoute;
   RESTClientPoolerExec.SetAccessTag(vAccessTag);
   {$IFDEF RESTDWLAZARUS}
   RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
   {$ENDIF}
   DWParams                              := TRESTDWParams.Create;
   DWParams.Encoding                     := RESTClientPoolerExec.Encoding;
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'LinesDataset';
   JSONParam.ObjectDirection             := odIn;
   If RESTClientPoolerExec.CriptOptions.Use Then
    JSONParam.AsString                   := RESTClientPoolerExec.CriptOptions.Encrypt(LinesDataset)
   Else
     JSONParam.AsString                  := LinesDataset;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Pooler';
   JSONParam.ObjectDirection             := odIn;
   If RESTClientPoolerExec.CriptOptions.Use Then
    JSONParam.AsString                   := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
   Else
    JSONParam.AsString                   := Pooler;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Method_Prefix';
   JSONParam.ObjectDirection             := odIn;
   JSONParam.AsString                    := Method_Prefix;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Error';
   JSONParam.ObjectDirection             := odInOut;
   JSONParam.AsBoolean                   := False;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'MessageError';
   JSONParam.ObjectDirection             := odInOut;
   JSONParam.AsString                    := MessageError;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Result';
   JSONParam.ObjectDirection             := odOUT;
   JSONParam.ObjectValue                 := ovString;
   JSONParam.AsString                    := '';
//   JSONParam.SetValue('', JSONParam.Encoded);
   DWParams.Add(JSONParam);
   If Assigned(ConnectionDefs) Then
    Begin
     JSONParam                           := TJSONParam.Create(RESTClientPoolerExec.Encoding);
     JSONParam.ParamName                 := 'dwConnectionDefs';
     JSONParam.ObjectDirection           := odIn;
     JSONParam.AsString                  := TConnectionDefs(ConnectionDefs).ToJSON;
     DWParams.Add(JSONParam);
    End;
   Try
    Try
     RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
     Result := RESTClientPoolerExec.SendEvent('ApplyUpdatesSQL', DWParams);
     If (Result <> '') And
        (Uppercase(Result) <> Uppercase(cInvalidAuth)) Then
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
       If DWParams.ItemsString['Error'] <> Nil Then
        Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
       If DWParams.ItemsString['Result'] <> Nil Then
        Begin
         If DWParams.ItemsString['Result'].AsString <> '' Then
          Result := DWParams.ItemsString['Result'].AsString;
        End;
      End
     Else
      Begin
       Error         := True;
       If (Result = '') Then
        MessageError  := Format('Unresolved Host : ''%s''', [Host])
       Else If (Uppercase(Result) <> Uppercase(cInvalidAuth)) Then
        MessageError  := cInvalidAuth;
       Raise Exception.Create(MessageError);
      End;
    Except
     On E : Exception Do
      Begin
       Error         := True;
       MessageError  := E.Message;
      End;
    End;
   Finally
    If Not Assigned(RESTClientPooler) Then
     FreeAndNil(RESTClientPoolerExec);
    FreeAndNil(DWParams);
   End;
  End;
End;

Function TRESTDWPoolerMethodClient.OpenDatasets(DatasetStream           : TStream;
                                                Pooler,
                                                Method_Prefix           : String;
                                                Var Error               : Boolean;
                                                Var MessageError        : String;
                                                Var SocketError         : Boolean;
                                                BinaryRequest           : Boolean;
                                                BinaryCompatibleMode    : Boolean;
                                                TimeOut                 : Integer = 3000;
                                                ConnectTimeOut          : Integer = 3000;
                                                ConnectionDefs          : TObject               = Nil;
                                                RESTClientPooler        : TRESTClientPoolerBase = Nil) : TStream;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
 vResult              : String;
Begin
 Result := Nil;
 If Assigned(DatasetStream) Then
  Begin
   If Not Assigned(RESTClientPooler) Then
    RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
   Else
    Begin
     RESTClientPoolerExec := RESTClientPooler;
     DataRoute            := RESTClientPoolerExec.DataRoute;
     AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
     vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
     vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
     vtyperequest         := RESTClientPoolerExec.TypeRequest;
     If Trim(DataRoute) = '' Then
      Begin
       If Trim(Method_Prefix) <> '' Then
        Begin
         RESTClientPoolerExec.DataRoute := Method_Prefix;
         DataRoute                      := Method_Prefix;
        End;
      End;
    End;
   vActualClientPoolerExec := RESTClientPoolerExec;
   RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
   RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
   RESTClientPoolerExec.UserAgent        := vUserAgent;
   RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
   RESTClientPoolerExec.Host             := Host;
   RESTClientPoolerExec.Port             := Port;
   RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
   RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
   RESTClientPoolerExec.RequestTimeOut   := TimeOut;
   RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
   RESTClientPoolerExec.DataCompression  := vCompression;
   RESTClientPoolerExec.TypeRequest      := vtyperequest;
   RESTClientPoolerExec.TypeRequest      := vtyperequest;
   RESTClientPoolerExec.OnWork           := vOnWork;
   RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
   RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
   RESTClientPoolerExec.OnStatus         := vOnStatus;
   RESTClientPoolerExec.Encoding         := vEncoding;
   RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
   RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
   RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
   RESTClientPoolerExec.DataRoute        := DataRoute;
   RESTClientPoolerExec.SetAccessTag(vAccessTag);
   {$IFDEF RESTDWLAZARUS}
   RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
   {$ENDIF}
   DWParams                              := TRESTDWParams.Create;
   DWParams.Encoding                     := RESTClientPoolerExec.Encoding;
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'DatasetStream';
   JSONParam.ObjectDirection             := odIn;
   JSONParam.ObjectValue                 := ovBlob;
   JSONParam.LoadFromStream(DatasetStream);
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Pooler';
   JSONParam.ObjectDirection             := odIn;
   If RESTClientPoolerExec.CriptOptions.Use Then
    JSONParam.AsString                   := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
   Else
    JSONParam.AsString                   := Pooler;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Method_Prefix';
   JSONParam.ObjectDirection             := odIn;
   JSONParam.AsString                    := Method_Prefix;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Error';
   JSONParam.ObjectDirection             := odInOut;
   JSONParam.AsBoolean                   := False;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'MessageError';
   JSONParam.ObjectDirection             := odInOut;
   JSONParam.AsString                    := MessageError;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'BinaryRequest';
   JSONParam.ObjectDirection             := odIn;
   JSONParam.AsBoolean                   := BinaryRequest;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'BinaryCompatibleMode';
   JSONParam.ObjectDirection             := odIn;
   JSONParam.AsBoolean                   := BinaryCompatibleMode;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'MetadataRequest';
   JSONParam.ObjectDirection             := odIn;
   JSONParam.AsBoolean                   := True;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Result';
   JSONParam.ObjectDirection             := odOUT;
   If Not vBinaryRequest Then
    Begin
     JSONParam.ObjectValue         := ovString;
     JSONParam.AsString            := '';
    End
   Else
    JSONParam.ObjectValue          := ovBlob;
   DWParams.Add(JSONParam);
   If Assigned(ConnectionDefs) Then
    Begin
     JSONParam                           := TJSONParam.Create(RESTClientPoolerExec.Encoding);
     JSONParam.ParamName                 := 'dwConnectionDefs';
     JSONParam.ObjectDirection           := odIn;
     JSONParam.AsString                  := TConnectionDefs(ConnectionDefs).ToJSON;
     DWParams.Add(JSONParam);
    End;
   Try
    Try
     RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
     vResult := RESTClientPoolerExec.SendEvent('OpenDatasets', DWParams);
     If (vResult <> '') And
        (Uppercase(vResult) <> Uppercase(cInvalidAuth)) Then
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
       If DWParams.ItemsString['Error'] <> Nil Then
        Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
       If DWParams.ItemsString['Result'] <> Nil Then
        Begin
         If Not DWParams.ItemsString['Result'].IsNull Then
          DWParams.ItemsString['Result'].SaveToStream(Result);
        End;
      End
     Else
      Begin
       Error         := True;
       If (vResult = '') Then
        MessageError  := Format('Unresolved Host : ''%s''', [Host])
       Else If (Uppercase(vResult) <> Uppercase(cInvalidAuth)) Then
        MessageError  := cInvalidAuth;
       Raise Exception.Create(MessageError);
      End;
    Except
     On E : Exception Do
      Begin
       Error         := True;
       MessageError  := E.Message;
      End;
    End;
   Finally
    If Not Assigned(RESTClientPooler) Then
     FreeAndNil(RESTClientPoolerExec);
    FreeAndNil(DWParams);
   End;
  End;
End;

Function TRESTDWPoolerMethodClient.OpenDatasets(LinesDataset,
                                                Pooler,
                                                Method_Prefix           : String;
                                                Var Error               : Boolean;
                                                Var MessageError        : String;
                                                Var SocketError         : Boolean;
                                                TimeOut                 : Integer = 3000;
                                                ConnectTimeOut          : Integer = 3000;
                                                ConnectionDefs          : TObject           = Nil;
                                                RESTClientPooler        : TRESTClientPoolerBase = Nil) : String;
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
 vStream              : TStringStream;
Begin
 Result := '';
 If LinesDataset <> '' Then
  Begin
   If Not Assigned(RESTClientPooler) Then
    RESTClientPoolerExec  := TRESTClientPoolerBase.Create(Nil)
   Else
    Begin
     RESTClientPoolerExec := RESTClientPooler;
     DataRoute            := RESTClientPoolerExec.DataRoute;
     AuthenticationOptions.Assign(RESTClientPoolerExec.AuthenticationOptions);
     vCripto.Use          := RESTClientPoolerExec.CriptOptions.Use;
     vCripto.Key          := RESTClientPoolerExec.CriptOptions.Key;
     vtyperequest         := RESTClientPoolerExec.TypeRequest;
     If Trim(DataRoute) = '' Then
      Begin
       If Trim(Method_Prefix) <> '' Then
        Begin
         RESTClientPoolerExec.DataRoute := Method_Prefix;
         DataRoute                      := Method_Prefix;
        End;
      End;
    End;
   vActualClientPoolerExec := RESTClientPoolerExec;
   RESTClientPoolerExec.PoolerNotFoundMessage := PoolerNotFoundMessage;
   RESTClientPoolerExec.AuthenticationOptions.Assign(AuthenticationOptions);
   RESTClientPoolerExec.UserAgent        := vUserAgent;
   RESTClientPoolerExec.WelcomeMessage   := vWelcomeMessage;
   RESTClientPoolerExec.Host             := Host;
   RESTClientPoolerExec.Port             := Port;
   RESTClientPoolerExec.HandleRedirects  := vHandleRedirects;
   RESTClientPoolerExec.RedirectMaximum  := vRedirectMaximum;
   RESTClientPoolerExec.RequestTimeOut   := TimeOut;
   RESTClientPoolerExec.ConnectTimeOut   := ConnectTimeOut;
   RESTClientPoolerExec.DataCompression  := vCompression;
   RESTClientPoolerExec.TypeRequest      := vtyperequest;
   RESTClientPoolerExec.TypeRequest      := vtyperequest;
   RESTClientPoolerExec.OnWork           := vOnWork;
   RESTClientPoolerExec.OnWorkBegin      := vOnWorkBegin;
   RESTClientPoolerExec.OnWorkEnd        := vOnWorkEnd;
   RESTClientPoolerExec.OnStatus         := vOnStatus;
   RESTClientPoolerExec.Encoding         := vEncoding;
   RESTClientPoolerExec.EncodedStrings   := EncodeStrings;
   RESTClientPoolerExec.CriptOptions.Use := vCripto.Use;
   RESTClientPoolerExec.CriptOptions.Key := vCripto.Key;
   RESTClientPoolerExec.DataRoute        := DataRoute;
   RESTClientPoolerExec.SetAccessTag(vAccessTag);
   {$IFDEF RESTDWLAZARUS}
   RESTClientPoolerExec.DatabaseCharSet  := vDatabaseCharSet;
   {$ENDIF}
   DWParams                              := TRESTDWParams.Create;
   DWParams.Encoding                     := RESTClientPoolerExec.Encoding;
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'LinesDataset';
   JSONParam.ObjectDirection             := odIn;
   If RESTClientPoolerExec.CriptOptions.Use Then
    JSONParam.AsString                   := RESTClientPoolerExec.CriptOptions.Encrypt(LinesDataset)
   Else
     JSONParam.AsString                  := LinesDataset;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Pooler';
   JSONParam.ObjectDirection             := odIn;
   If RESTClientPoolerExec.CriptOptions.Use Then
    JSONParam.AsString                   := RESTClientPoolerExec.CriptOptions.Encrypt(Pooler)
   Else
    JSONParam.AsString                   := Pooler;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Method_Prefix';
   JSONParam.ObjectDirection             := odIn;
   JSONParam.AsString                    := Method_Prefix;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Error';
   JSONParam.ObjectDirection             := odInOut;
   JSONParam.AsBoolean                   := False;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'MessageError';
   JSONParam.ObjectDirection             := odInOut;
   JSONParam.AsString                    := MessageError;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'BinaryRequest';
   JSONParam.ObjectDirection             := odIn;
   JSONParam.AsBoolean                   := BinaryRequest;
   DWParams.Add(JSONParam);
   JSONParam                             := TJSONParam.Create(RESTClientPoolerExec.Encoding);
   JSONParam.ParamName                   := 'Result';
   JSONParam.ObjectDirection             := odOUT;
   If Not vBinaryRequest Then
    Begin
     JSONParam.ObjectValue         := ovString;
     JSONParam.AsString            := '';
    End
   Else
    JSONParam.ObjectValue          := ovBlob;
//   JSONParam.SetValue('', JSONParam.Encoded);
   DWParams.Add(JSONParam);
   If Assigned(ConnectionDefs) Then
    Begin
     JSONParam                           := TJSONParam.Create(RESTClientPoolerExec.Encoding);
     JSONParam.ParamName                 := 'dwConnectionDefs';
     JSONParam.ObjectDirection           := odIn;
     JSONParam.AsString                  := TConnectionDefs(ConnectionDefs).ToJSON;
     DWParams.Add(JSONParam);
    End;
   Try
    Try
     RESTClientPoolerExec.BinaryRequest := vBinaryRequest;
     Result := RESTClientPoolerExec.SendEvent('OpenDatasets', DWParams);
     If (Result <> '') And
        (Uppercase(Result) <> Uppercase(cInvalidAuth)) Then
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        MessageError  := DecodeStrings(DWParams.ItemsString['MessageError'].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
       If DWParams.ItemsString['Error'] <> Nil Then
        Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
       If DWParams.ItemsString['Result'] <> Nil Then
        Begin
         If Not DWParams.ItemsString['Result'].IsNull Then
          Begin
           If vBinaryRequest Then
            Begin
             {$IF Defined(RESTDWLAZARUS) or not(Defined(DELPHIXEUP))}
              vStream := TStringStream.Create('');
             {$ELSE}
              vStream := TStringStream.Create('', TEncoding.UTF8);
             {$IFEND}
             Try
              DWParams.ItemsString['Result'].SaveToStream(vStream);
              Result := vStream.Datastring;// DWParams.ItemsString['Result'].AsString;
              If Result <> '' Then
               Begin
                If Result[InitStrPos] = '"' Then
                 Delete(Result, 1, 1);
                If Result[Length(Result) -FinalStrPos] = '"' Then
                 Delete(Result, Length(Result), 1);
               End;
             Finally
              FreeAndNil(vStream);
             End;
            End
           Else
            Result := DWParams.ItemsString['Result'].AsString;
          End;
        End;
      End
     Else
      Begin
       Error         := True;
       If (Result = '') Then
        MessageError  := Format('Unresolved Host : ''%s''', [Host])
       Else If (Uppercase(Result) <> Uppercase(cInvalidAuth)) Then
        MessageError  := cInvalidAuth;
       Raise Exception.Create(MessageError);
      End;
    Except
     On E : Exception Do
      Begin
       Error         := True;
       MessageError  := E.Message;
      End;
    End;
   Finally
    If Not Assigned(RESTClientPooler) Then
     FreeAndNil(RESTClientPoolerExec);
    FreeAndNil(DWParams);
   End;
  End;
End;

end.

