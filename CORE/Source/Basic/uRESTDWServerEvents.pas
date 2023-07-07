unit uRESTDWServerEvents;

{$I ..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

Uses
 SysUtils, Classes, uRESTDWJSONObject, uRESTDWConsts,
 uRESTDWBasic, uRESTDWProtoTypes, uRESTDWTools, uRESTDWParams,
 uRESTDWJSONInterface, uRESTDWAbout;

Const
 TServerEventsConst = '{"typeobject":"%s", "objectdirection":"%s", "objectvalue":"%s", "paramname":"%s", "encoded":"%s", "default":"%s"}';

Type
 TDWReplyEvent       = Procedure(Var   Params      : TRESTDWParams;
                                 Var   Result      : String)          Of Object;
 TDWReplyEventByType = Procedure(Var   Params      : TRESTDWParams;
                                 Var   Result      : String;
                                 Const RequestType : TRequestType;
                                 Var   StatusCode  : Integer;
                                 RequestHeader     : TStringList)    Of Object;
 TDWAuthRequest      = Procedure(Const Params      : TRESTDWParams;
                                 Var   Rejected    : Boolean;
                                 Var   ResultError : String;
                                 Var   StatusCode  : Integer;
                                 RequestHeader     : TStringList)     Of Object;
 TObjectEvent        = Procedure(aSelf             : TComponent)      Of Object;
 TObjectExecute      = Procedure(Const aSelf       : TCollectionItem) Of Object;
 TOnBeforeSend       = Procedure(aSelf             : TComponent)      Of Object;

Type
 TDWReplyEventData = Class(TComponent)
 Private
  vReplyEvent         : TDWReplyEvent;
  vDWReplyEventByType : TDWReplyEventByType;
  vDWAuthRequest      : TDWAuthRequest;
  vBeforeExecute      : TObjectExecute;
 Public
  Property    OnReplyEvent       : TDWReplyEvent       Read vReplyEvent         Write vReplyEvent;
  Property    OnReplyEventByType : TDWReplyEventByType Read vDWReplyEventByType Write vDWReplyEventByType;
  Property    OnAuthRequest      : TDWAuthRequest      Read vDWAuthRequest      Write vDWAuthRequest;
  Property    OnBeforeExecute    : TObjectExecute      Read vBeforeExecute      Write vBeforeExecute;
End;

Type
 TRESTDWEvent = Class;
 TRESTDWEvent = Class(TCollectionItem)
 Protected
 Private
  vDescription                           : TStrings;
  vDWRoutes                              : TRESTDWRoutes;
  vDataMode                              : TDataMode;
  vBaseURL,
  vEventName,
  vContentType,
  FName                                  : String;
  vDWParams                              : TRESTDWParamsMethods;
  vOwnerCollection                       : TCollection;
  vCallbackEvent,
  vOnlyPreDefinedParams,
  vNeedAuthorization                     : Boolean;
  DWReplyEventData                       : TDWReplyEventData;
  vBeforeExecute                         : TObjectExecute;
  Function  GetReplyEvent                : TDWReplyEvent;
  Procedure SetReplyEvent      (Value    : TDWReplyEvent);
  Function  GetReplyEventByType          : TDWReplyEventByType;
  Procedure SetReplyEventByType(Value    : TDWReplyEventByType);
  Function  GetAuthRequest               : TDWAuthRequest;
  Procedure SetAuthRequest     (Value    : TDWAuthRequest);
  Procedure SetDescription     (Strings  : TStrings);
  Procedure SetBaseUrl    (Value : String);
  Procedure SetContentType(Value : String);
  Procedure SetDataMode   (Value : TDataMode);
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Procedure   CompareParams (Var Dest    : TRESTDWParams);
  Procedure   Assign        (Source      : TPersistent); Override;
  Constructor Create        (aCollection : TCollection); Override;
  Function    GetNamePath  : String;                     Override;
  Destructor  Destroy; Override;
 Published
  Property    Routes               : TRESTDWRoutes        Read vDWRoutes             Write vDWRoutes;
  Property    NeedAuthorization    : Boolean              Read vNeedAuthorization    Write vNeedAuthorization;
  Property    Params               : TRESTDWParamsMethods Read vDWParams             Write vDWParams;
  Property    DataMode             : TDataMode            Read vDataMode             Write SetDataMode;
  Property    Name                 : String               Read GetDisplayName        Write SetDisplayName;
  Property    EventName            : String               Read vEventName            Write vEventName;
  Property    BaseURL              : String               Read vBaseURL              Write SetBaseURL;
  Property    DefaultContentType   : String               Read vContentType          Write SetContentType;
  Property    CallbackEvent        : Boolean              Read vCallbackEvent        Write vCallbackEvent;
  Property    Description          : TStrings             Read vDescription          Write SetDescription;
  Property    OnlyPreDefinedParams : Boolean              Read vOnlyPreDefinedParams Write vOnlyPreDefinedParams;
  Property    OnReplyEvent         : TDWReplyEvent        Read GetReplyEvent         Write SetReplyEvent;
  Property    OnReplyEventByType   : TDWReplyEventByType  Read GetReplyEventByType   Write SetReplyEventByType;
  Property    OnAuthRequest        : TDWAuthRequest       Read GetAuthRequest        Write SetAuthRequest;
  Property    OnBeforeExecute      : TObjectExecute       Read vBeforeExecute        Write vBeforeExecute;
End;

Type
 TRESTDWEventList = Class;
 TRESTDWEventList = Class(TRESTDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TRESTDWEvent;       Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TRESTDWEvent);                 Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TRESTDWEvent;       Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TRESTDWEvent);                 Overload;
//  Procedure   Editable  (Value : Boolean);
 Public
  Function    Add    : TCollectionItem;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    ToJSON : String;
  Procedure   FromJSON   (Value      : String );
  Procedure   Delete     (Index      : Integer);                  Overload;
  Property    Items      [Index      : Integer]  : TRESTDWEvent       Read GetRec     Write PutRec; Default;
  Property    EventByName[Index      : String ]  : TRESTDWEvent       Read GetRecName Write PutRecName;
End;

Type
 TRESTDWServerEvents = Class(TRESTDWComponent)
 Protected
 Private
  vIgnoreInvalidParams : Boolean;
  vEventList           : TRESTDWEventList;
  vDefaultEvent,
  vAccessTag           : String;
  vOnCreate            : TObjectEvent;
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Procedure   CreateDWParams(EventName    : String;
                             Var DWParams : TRESTDWParams);
 Published
  Property    IgnoreInvalidParams : Boolean      Read vIgnoreInvalidParams Write vIgnoreInvalidParams;
  Property    Events              : TRESTDWEventList Read vEventList           Write vEventList;
  Property    AccessTag           : String       Read vAccessTag           Write vAccessTag;
  Property    DefaultEvent        : String       Read vDefaultEvent        Write vDefaultEvent;
  Property    OnCreate            : TObjectEvent Read vOnCreate            Write vOnCreate;
End;

Type
 { TRESTDWClientEvents }
 TRESTDWClientEvents = Class(TRESTDWComponent)
 Private
  vServerEventName  : String;
  vEditParamList,
  vGetEvents        : Boolean;
  vEventList        : TRESTDWEventList;
  vRESTClientPooler : TRESTClientPoolerBase;
  vOnBeforeSend     : TOnBeforeSend;
  vCripto           : TCripto;
  Procedure GetOnlineEvents         (Value  : Boolean);
  Procedure SetEventList            (aValue : TRESTDWEventList);
  Function  GeTRESTClientPoolerBase             : TRESTClientPoolerBase;
  Procedure SeTRESTClientPoolerBase(Const Value : TRESTClientPoolerBase);
  Procedure TokenValidade(Var DWParams : TRESTDWParams;
                          Var Error    : String);
 Protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  Destructor  Destroy; Override;
  Constructor Create        (AOwner           : TComponent);Override; //Cria o Componente
  Procedure   CreateDWParams(EventName        : String;
                             Var DWParams     : TRESTDWParams);
  Function    SendEvent     (EventName        : String;
                             Var DWParams     : TRESTDWParams;
                             Var Error        : String;
                             EventType        : TSendEvent = sePOST;
                             Assyncexec       : Boolean = False) : Boolean; Overload;
  Function    SendEvent     (EventName        : String;
                             Var DWParams     : TRESTDWParams;
                             Var Error        : String;
                             Var NativeResult : String;
                             EventType        : TSendEvent = sePOST;
                             Assyncexec       : Boolean = False) : Boolean; Overload;
  Procedure   ClearEvents;
  Property    GetEvents        : Boolean               Read vGetEvents              Write GetOnlineEvents;
 Published
  Property    ServerEventName  : String                Read vServerEventName        Write vServerEventName;
  Property    CriptOptions     : TCripto               Read vCripto                 Write vCripto;
  Property    RESTClientPooler : TRESTClientPoolerBase Read GeTRESTClientPoolerBase Write SeTRESTClientPoolerBase;
  Property    Events           : TRESTDWEventList      Read vEventList              Write SetEventList;
  Property    OnBeforeSend     : TOnBeforeSend         Read vOnBeforeSend           Write vOnBeforeSend; // Add Evento por Ico Menezes
End;

implementation

{ TRESTDWEvent }

Uses uRESTDWDataUtils;

Function TRESTDWEvent.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

constructor TRESTDWEvent.Create(aCollection: TCollection);
begin
 Inherited;
 vDWParams             := TRESTDWParamsMethods.Create(aCollection, TRESTDWParamMethod);
 vDataMode             := dmDataware;
 DWReplyEventData      := TDWReplyEventData.Create(Nil);
 vOwnerCollection      := aCollection;
 FName                 := 'dwevent' + IntToStr(aCollection.Count);
 DWReplyEventData.Name := FName;
 vNeedAuthorization    := True;
 vOnlyPreDefinedParams := False;
 vEventName            := '';
 vBaseURL              := '/';
 vDescription          := TStringList.Create;
 vDWRoutes             := [crAll];
 vContentType          := cDefaultContentType;
 vCallbackEvent        := False;
end;

Destructor TRESTDWEvent.Destroy;
Begin
 vDWParams.Free;
 DWReplyEventData.Free;
 vDescription.Free;
 Inherited;
End;

Function TRESTDWEvent.GetAuthRequest: TDWAuthRequest;
Begin
 Result := DWReplyEventData.OnAuthRequest;
End;

Function TRESTDWEvent.GetDisplayName: String;
Begin
 Result := DWReplyEventData.Name;
End;

Procedure TRESTDWEvent.Assign(Source: TPersistent);
begin
 If Source is TRESTDWEvent then
  Begin
   FName       := TRESTDWEvent(Source).Name;
   vDWParams   := TRESTDWEvent(Source).Params;
   DWReplyEventData.OnBeforeExecute := TRESTDWEvent(Source).OnBeforeExecute;
   DWReplyEventData.OnReplyEvent := TRESTDWEvent(Source).OnReplyEvent;
  End
 Else
  Inherited;
End;

Function TRESTDWEvent.GetReplyEvent: TDWReplyEvent;
Begin
 Result := DWReplyEventData.OnReplyEvent;
End;

Function TRESTDWEvent.GetReplyEventByType : TDWReplyEventByType;
Begin
 Result := DWReplyEventData.OnReplyEventByType;
End;

Procedure TRESTDWEvent.SetDescription(Strings : TStrings);
Begin
 vDescription.Assign(Strings);
End;

Procedure TRESTDWEvent.SetAuthRequest(Value   : TDWAuthRequest);
Begin
 DWReplyEventData.OnAuthRequest := Value;
End;

Procedure TRESTDWEvent.SetDataMode   (Value : TDataMode);
Begin
 vDataMode := Value;
 If vDataMode = dmDataware Then
  vContentType := cDefaultContentType;
End;

Procedure TRESTDWEvent.SetContentType(Value : String);
Begin
 If vDataMode = dmDataware Then
  vContentType := cDefaultContentType
 Else
  vContentType := Value;
 If Trim(vContentType) = '' Then
  vContentType := cDefaultContentType;
End;

Procedure TRESTDWEvent.SetBaseUrl(Value : String);
Var
 vTempValue : String;
Begin
 vTempValue := Value;
 If Trim(vTempValue) = '' Then
  vBaseURL := '/'
 Else
  Begin
   If Copy(vTempValue, 1, 1) <> '/' Then
    vTempValue := '/' + vTempValue;
   If Copy(vTempValue, Length(vTempValue), 1) <> '/' Then
    vTempValue := vTempValue + '/';
   vBaseURL := vTempValue;
  End;
End;

Procedure TRESTDWEvent.SetDisplayName(Const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidEvent)
 Else
  Begin
   FName := Value;
   DWReplyEventData.Name := FName;
   If vEventName = '' Then
    vEventName := DWReplyEventData.Name;
   Inherited;
  End;
End;

procedure TRESTDWEvent.SetReplyEvent(Value: TDWReplyEvent);
begin
 DWReplyEventData.OnReplyEvent := Value;
end;

Procedure TRESTDWEvent.SetReplyEventByType(Value: TDWReplyEventByType);
Begin
 DWReplyEventData.OnReplyEventByType := Value;
End;

Procedure TRESTDWEvent.CompareParams(Var Dest : TRESTDWParams);
Var
 I : Integer;
Begin
 If vOnlyPreDefinedParams Then
  Begin
   If Not Assigned(Dest) Then
    Exit;
   If vDWParams.Count = 0 Then
    Dest.Clear;
   For I := Dest.Count -1 DownTo 0 Do
    Begin
     If (vDWParams.ParamByName[Dest.Items[I].Alias]     = Nil) And
        (vDWParams.ParamByName[Dest.Items[I].ParamName] = Nil) Then
      Dest.Delete(I);
    End;
  End;
End;

Function TRESTDWEventList.Add : TCollectionItem;
Begin
 Result := Nil;
 If vEditable Then
  Result := TRESTDWEvent(Inherited Add);
End;

procedure TRESTDWEventList.ClearList;
Var
 I : Integer;
 vOldEditable : Boolean;
Begin
 vOldEditable := vEditable;
 vEditable    := True;
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
  vEditable := vOldEditable;
 End;
End;

Constructor TRESTDWEventList.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWEvent);
 Self.fOwner := AOwner;
 vEditable   := True;
End;

procedure TRESTDWEventList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TRESTDWEventList.Destroy;
begin
 ClearList;
 inherited;
end;

Procedure TRESTDWEventList.FromJSON(Value : String);
Var
 bJsonOBJBase   : TRESTDWJSONInterfaceBase;
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc      : TRESTDWJSONInterfaceObject;
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC    : TRESTDWJSONInterfaceArray;
 I, X, Y        : Integer;
 vDWEvent       : TRESTDWEvent;
 vDWParamMethod : TRESTDWParamMethod;
 vEventName,
 vDataMode,
 vparams,
 vparamname,
 vContentType      : String;
 vneedauth,
 vonlypredefparams : Boolean;
Begin
 Try
  bJsonOBJBase := TRESTDWJSONInterfaceBase(TRESTDWJSONInterfaceObject.Create(Value));
  bJsonArray   := TRESTDWJSONInterfaceArray(bJsonOBJBase);
  For I := 0 to bJsonArray.ElementCount - 1 Do
   Begin
    bJsonOBJ := TRESTDWJSONInterfaceObject(bJsonArray.GetObject(I));
    Try
     bJsonArrayB := bJsonOBJ.OpenArray('serverevents'); //  Tjsonarray.Create(bJsonOBJ.get('serverevents').tostring);
     For X := 0 To bJsonArrayB.ElementCount - 1 Do
      Begin
       bJsonOBJb  := TRESTDWJSONInterfaceObject(bJsonArrayB.GetObject(X));
       vEventName := bJsonOBJb.Pairs[0].Value; //eventname
       vDataMode  := bJsonOBJb.Pairs[1].Value; //DataMode
       vparams    := bJsonOBJb.Pairs[2].Value; //params
       vneedauth  := StringToBoolean(bJsonOBJb.Pairs[3].Value); //params
       vonlypredefparams := StringToBoolean(bJsonOBJb.Pairs[4].Value); //params
       vContentType := DecodeStrings(bJsonOBJb.Pairs[5].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}); //Final
       If EventByName[vEventName] = Nil Then
        vDWEvent  := TRESTDWEvent(Self.Add)
       Else
        vDWEvent  := EventByName[vEventName];
       vDWEvent.DataMode := GetDataModeName(vDataMode);
       vDWEvent.DefaultContentType := vContentType;
       vDWEvent.Name := vEventName;
       vDWEvent.NeedAuthorization    := vneedauth;
       vDWEvent.OnlyPreDefinedParams := vonlypredefparams;
       If vparams <> '' Then
        Begin
         bJsonArrayC    := bJsonOBJb.OpenArray('params');
         Try
          For Y := 0 To bJsonArrayC.ElementCount - 1 do
           Begin
            bJsonOBJc                      := TRESTDWJSONInterfaceObject(bJsonArrayC.GetObject(Y));
            vparamname                     := bJsonOBJc.Pairs[3].Value; // .get('paramname').toString;
            If vDWEvent.vDWParams.ParamByName[vparamname] = Nil Then
             vDWParamMethod                := TRESTDWParamMethod(vDWEvent.vDWParams.Add)
            Else
             vDWParamMethod                := vDWEvent.vDWParams.ParamByName[vparamname];
            vDWParamMethod.TypeObject      := GetObjectName(bJsonOBJc.Pairs[0].Value); // GetObjectName(bJsonOBJc.get('typeobject').toString);
            vDWParamMethod.ObjectDirection := GetDirectionName(bJsonOBJc.Pairs[1].Value); // GetDirectionName(bJsonOBJc.get('objectdirection').toString);
            vDWParamMethod.ObjectValue     := GetValueType(bJsonOBJc.Pairs[2].Value); // GetValueType(bJsonOBJc.get('objectvalue').toString);
            vDWParamMethod.ParamName       := vparamname;
            If bJsonArrayC.ElementCount > 4 Then
             vDWParamMethod.Encoded         := StringToBoolean(bJsonOBJc.Pairs[4].Value); // StringToBoolean(bJsonOBJc.get('encoded').toString);
            If bJsonArrayC.ElementCount > 5 Then
             If Trim(bJsonOBJc.Pairs[5].Value) <> '' Then //Trim(bJsonOBJc.get('default').toString) <> '' Then
              vDWParamMethod.DefaultValue   := DecodeStrings(bJsonOBJc.Pairs[5].Value{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF}); // bJsonOBJc.get('default').toString{$IFDEF FPC}, csUndefined{$ENDIF});
            FreeAndNil(bJsonOBJc);
           End;
         Finally
          FreeAndNil(bJsonArrayC);
         End;
        End
       Else
        vDWEvent.vDWParams.ClearList;
       FreeAndNil(bJsonOBJb);
      End;
    Finally
     FreeAndNil(bJsonArrayB);
    End;
    FreeAndNil(bJsonOBJ);
   End;
 Finally
  FreeAndNil(bJsonOBJBase);
 End;
End;

Function TRESTDWEventList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TRESTDWEventList.GetRec(Index: Integer): TRESTDWEvent;
begin
 Result := TRESTDWEvent(Inherited GetItem(Index));
end;

function TRESTDWEventList.GetRecName(Index: String): TRESTDWEvent;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(TRESTDWEvent(Items[I]).EventName))                                  Or
      (Uppercase(Index) = Uppercase(TRESTDWEvent(Items[I]).BaseURL + TRESTDWEvent(Items[I]).EventName)) Then
    Begin
     Result := TRESTDWEvent(Self.Items[I]);
     Break;
    End;
  End;
End;

procedure TRESTDWEventList.PutRec(Index: Integer; Item: TRESTDWEvent);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
end;

procedure TRESTDWEventList.PutRecName(Index: String; Item: TRESTDWEvent);
Var
 I : Integer;
Begin
 If (vEditable) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TRESTDWEvent(Items[I]).EventName)) Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

Function TRESTDWEventList.ToJSON: String;
Var
 A, I : Integer;
 vTagEvent,
 vParamsLines,
 vParamLine,
 vParamLine2,
 vEventsLines : String;
Begin
 Result := '';
 vEventsLines := '';
 For I := 0 To Count -1 Do
  Begin
   vParamLine2  := Format('"needauth":"%s", "onlypredefparams":"%s", "ContentType":"%s"', [BooleanToString(Items[I].NeedAuthorization),
                                                                                           BooleanToString(Items[I].OnlyPreDefinedParams),
                                                                                           EncodeStrings(Items[I].DefaultContentType{$IFDEF FPC}, csUndefined{$ENDIF})]);
   vTagEvent    := Format('{"eventname":"%s"', [TRESTDWEvent(Items[I]).EventName]);
   vTagEvent    := vTagEvent + Format(', "DataMode":"%s"', [GetDataModeName(Items[I].vDataMode)]);
   vTagEvent    := vTagEvent + ', "params":[%s], ' + vParamLine2 + '}';
   vParamsLines := '';
   For A := 0 To Items[I].vDWParams.Count -1 Do
    Begin
     vParamLine := Format(TServerEventsConst,
                          [GetObjectName(Items[I].vDWParams[A].TypeObject),
                           GetDirectionName(Items[I].vDWParams[A].ObjectDirection),
                           GetValueType(Items[I].vDWParams[A].ObjectValue),
                           Items[I].vDWParams[A].ParamName,
                           BooleanToString(Items[I].vDWParams[A].Encoded),
                           EncodeStrings(Items[I].vDWParams[A].DefaultValue{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF})]);
     If vParamsLines = '' Then
      vParamsLines := vParamLine
     Else
      vParamsLines := vParamsLines + ', ' + vParamLine;
    End;
   If vEventsLines = '' Then
    vEventsLines := vEventsLines + Format(vTagEvent, [vParamsLines])
   Else
    vEventsLines := vEventsLines + Format(', ' + vTagEvent, [vParamsLines]);
  End;
 Result := Format('{"serverevents":[%s]}', [vEventsLines]);
End;

Procedure TRESTDWServerEvents.CreateDWParams(EventName    : String;
                                         Var DWParams : TRESTDWParams);
Var
 vParamNameS : String;
 dwParam     : TJSONParam;
 I           : Integer;
 vFound      : Boolean;
Begin
 vParamNameS := '';
 If vEventList.EventByName[EventName] <> Nil Then
  Begin
   If Not Assigned(DWParams) Then
    DWParams := TRESTDWParams.Create;
   DWParams.DataMode := vEventList.EventByName[EventName].DataMode;
   For I := 0 To vEventList.EventByName[EventName].vDWParams.Count -1 Do
    Begin
     vParamNameS := '';
     vFound  := (DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName] <> Nil);
     If vFound Then
      vParamNameS := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName
     Else
      Begin
       vFound  := (DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].Alias]   <> Nil);
       If vFound Then
        vParamNameS := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
      End;
     If Not(vFound) Then
      Begin
       dwParam                 := TJSONParam.Create(DWParams.Encoding);
       dwParam.Alias           := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
       dwParam.ParamName       := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
       dwParam.ObjectDirection := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectDirection;
       dwParam.ObjectValue     := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectValue;
       dwParam.Encoded         := vEventList.EventByName[EventName].vDWParams.Items[I].Encoded;
       dwParam.DataMode        := DWParams.DataMode;
       If (vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue <> '')  And
          (Trim(dwParam.AsString) = '') Then
        dwParam.Value          := vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue;
       DWParams.Add(dwParam);
      End
     Else
      Begin
       If (DWParams.ItemsString[vParamNameS].ParamName             =  '') Or
          ((DWParams.ItemsString[vParamNameS].ParamName            <> '') And
           (Lowercase(DWParams.ItemsString[vParamNameS].ParamName) <>
            Lowercase(vEventList.EventByName[EventName].vDWParams.Items[I].ParamName))) Then
        Begin
         DWParams.ItemsString[vParamNameS].Alias      := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
         DWParams.ItemsString[vParamNameS].ParamName  := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
        End;
       If DWParams.ItemsString[vParamNameS].Alias      = '' Then
        DWParams.ItemsString[vParamNameS].Alias       := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
      End;
    End;
  End
 Else
  DWParams := Nil;
End;

Constructor TRESTDWServerEvents.Create(AOwner : TComponent);
Begin
 Inherited;
 vEventList := TRESTDWEventList.Create(Self, TRESTDWEvent);
 vIgnoreInvalidParams := False;
 vDefaultEvent := '';
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;

Destructor TRESTDWServerEvents.Destroy;
Begin
 vEventList.Free;
 Inherited;
End;

{ TRESTDWClientEvents }

constructor TRESTDWClientEvents.Create(AOwner: TComponent);
begin
 Inherited;
 vEventList     := TRESTDWEventList.Create(Self, TRESTDWEvent);
 vCripto        := TCripto.Create;
 vGetEvents     := False;
 vEditParamList := True;
end;

procedure TRESTDWClientEvents.CreateDWParams(EventName: String;
  Var DWParams: TRESTDWParams);
Var
 vParamName : String;
 dwParam    : TJSONParam;
 I          : Integer;
 vFound     : Boolean;
Begin
 vParamName := '';
 If vEventList.EventByName[EventName] <> Nil Then
  Begin
//   If (Not Assigned(DWParams)) or (dwParams = nil) Then
   DWParams := TRESTDWParams.Create;
   DWParams.Encoding := vRESTClientPooler.Encoding;
   For I := 0 To vEventList.EventByName[EventName].vDWParams.Count -1 Do
    Begin
     vParamName := '';
     vFound  := (DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName] <> Nil);
     If vFound Then
      vParamName := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName
     Else
      Begin
       vFound  := (DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].Alias]   <> Nil);
       If vFound Then
        vParamName := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
      End;
     If Not(vFound) Then
      dwParam                := TJSONParam.Create(DWParams.Encoding)
     Else
      dwParam                := DWParams.ItemsString[vParamName];
     dwParam.ParamName       := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
     dwParam.Alias           := vEventList.EventByName[EventName].vDWParams.Items[I].Alias;
     dwParam.ObjectDirection := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectDirection;
     dwParam.ObjectValue     := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectValue;
     dwParam.Encoded         := vEventList.EventByName[EventName].vDWParams.Items[I].Encoded;
     dwParam.DataMode        := dmDataware;
     If (vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue <> '') And
        (Trim(dwParam.AsString) = '') Then
      dwParam.Value           := vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue;
     If Not(vFound) Then
      DWParams.Add(dwParam);
    End;
  End
 Else
  DWParams := Nil;
End;

destructor TRESTDWClientEvents.Destroy;
begin
 vEventList.Free;
 FreeAndNil(vCripto);
 Inherited;
end;

procedure TRESTDWClientEvents.GetOnlineEvents(Value: Boolean);
Var
 RESTClientPoolerExec : TRESTClientPoolerBase;
 vResult,
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TRESTDWParams;
 vRaised              : Boolean;
Begin
 vRaised := False;
 If Assigned(vRESTClientPooler) Then
  RESTClientPoolerExec := vRESTClientPooler
 Else
  Exit;
 If Assigned(vRESTClientPooler) Then
  If Assigned(vRESTClientPooler.OnBeforeExecute) Then
   vRESTClientPooler.OnBeforeExecute(Self);
 DWParams                        := TRESTDWParams.Create;
 DWParams.CriptOptions.Use       := CriptOptions.Use;
 DWParams.CriptOptions.Key       := CriptOptions.Key;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'dwservereventname';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := vServerEventName;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'BinaryRequest';
 JSONParam.ObjectDirection       := odIn;
 If Assigned(vRESTClientPooler) Then
  JSONParam.AsBoolean            := vRESTClientPooler.BinaryRequest
 Else
  JSONParam.AsBoolean            := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOut;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 Try
  Try
   RESTClientPoolerExec.NewToken;
   lResponse := RESTClientPoolerExec.SendEvent('GetEvents', DWParams, sePOST, dmDataware, vServerEventName);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
    Begin
     If Not DWParams.ItemsString['error'].AsBoolean Then
      Begin
//       If vRESTClientPooler.CriptOptions.Use Then
//        DWParams.ItemsString['Result'].CriptOptions.Use := False;
       vResult := DWParams.ItemsString['Result'].AsString;
       If Trim(vResult) <> '' Then //Carreta o ParamList
        vEventList.FromJSON(Trim(vResult));
      End
     Else
      Begin
       vRaised := True;
       Raise Exception.Create(DWParams.ItemsString['MessageError'].AsString);
      End;
    End
   Else
    Begin
     If (lResponse = '') Then
      lResponse  := Format('Unresolved Host : ''%s''', [RESTClientPoolerExec.Host])
     Else If (Uppercase(lResponse) <> Uppercase(cInvalidAuth)) Then
      lResponse  := cInvalidAuth;
     Raise Exception.Create(lResponse);
     lResponse   := '';
    End;
  Except
   On E : Exception Do
    Begin
     If Not vRaised Then
      Begin
       If Trim(vServerEventName) = '' Then
        Raise Exception.Create(cInvalidServerEventName)
       Else
        Raise Exception.Create(cServerEventNotFound);
      End;
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

function TRESTDWClientEvents.GeTRESTClientPoolerBase: TRESTClientPoolerBase;
begin
  Result := vRESTClientPooler;
end;

procedure TRESTDWClientEvents.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = vRESTClientPooler) then
  begin
    vRESTClientPooler := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

Function TRESTDWClientEvents.SendEvent(EventName        : String;
                                       Var DWParams     : TRESTDWParams;
                                       Var Error        : String;
                                       Var NativeResult : String;
                                       EventType        : TSendEvent = sePOST;
                                       Assyncexec       : Boolean = False): Boolean;
Var
 vDataMode : TDataMode;
Begin
 Error := '';
 Result := False;
 If vRESTClientPooler <> Nil Then
  Begin
   If Assigned(vOnBeforeSend) Then
    vOnBeforeSend(Self);
   If Assigned(vRESTClientPooler.OnBeforeExecute) Then
    vRESTClientPooler.OnBeforeExecute(Self);
   If vEventList.EventByName[EventName] = Nil Then
    Begin
     Result := False;
     Error  := cInvalidEvent;
     Exit
    End;
   TokenValidade(DWParams, Error);
   vDataMode    := vEventList.EventByName[EventName].vDataMode;
   Try
    Error        := '';
    NativeResult := vRESTClientPooler.SendEvent(EventName, DWParams, EventType, vDataMode, vServerEventName);
    Result       := (NativeResult = TReplyOK) Or (NativeResult = AssyncCommandMSG);
   Except
    On E : Exception Do
     Begin
      // Eloy
      Error := E.Message;
      If Error = cInvalidAuth Then
       Begin
        Case vRESTClientPooler.AuthenticationOptions.AuthorizationOption Of
         rdwAOBearer : Begin
                        If (TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoRenewToken) And
                           (TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token <> '')  Then
                         Begin
                          TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                          SendEvent(EventName, DWParams, Error, NativeResult, EventType, Assyncexec);
                         End;
                       End;
         rdwAOToken  : Begin
                        If (TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoRenewToken) And
                           (TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token  <> '')  Then
                         Begin
                          TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                          SendEvent(EventName, DWParams, Error, NativeResult, EventType, Assyncexec);
                         End;
                       End;
        End;
       End
      Else
       Begin
        Raise Exception.Create(Error);
       End;
     End;
   End;
  End;
End;

Procedure TRESTDWClientEvents.TokenValidade(Var DWParams : TRESTDWParams;
                                        Var Error    : String);
Var
 JSONParam     : TJSONParam;
 vToken        : String;
 vErrorBoolean : Boolean;
Begin
 vErrorBoolean := False;
 If Not(Assigned(DWParams)) Then
  Begin
   DWParams                  := TRESTDWParams.Create;
   DWParams.DataMode         := dmDataware;
   DWParams.Encoding         := vRESTClientPooler.Encoding;
   JSONParam                 := TJSONParam.Create(vRESTClientPooler.Encoding);
   JSONParam.ParamName       := 'BinaryRequest';
   JSONParam.ObjectDirection := odIn;
   JSONParam.AsBoolean       := vRESTClientPooler.BinaryRequest;
   DWParams.Add(JSONParam);
  End;
 If vRESTClientPooler.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   Case vRESTClientPooler.AuthenticationOptions.AuthorizationOption Of
    rdwAOBearer : Begin
                   If (TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken) And
                      (TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token = '') Then
                    Begin
                     If Assigned(vRESTClientPooler.OnBeforeGetToken) Then
                      vRESTClientPooler.OnBeforeGetToken(vRESTClientPooler.WelcomeMessage,
                                                         vRESTClientPooler.AccessTag, DWParams);
                     vToken :=  vRESTClientPooler.RenewToken(DWParams, vErrorBoolean, Error);
                     If Not vErrorBoolean Then
                      TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := vToken;
                    End;
                  End;
    rdwAOToken  : Begin
                   If (TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken) And
                      (TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token = '') Then
                    Begin
                     If Assigned(vRESTClientPooler.OnBeforeGetToken) Then
                      vRESTClientPooler.OnBeforeGetToken(vRESTClientPooler.WelcomeMessage,
                                                         vRESTClientPooler.AccessTag, DWParams);
                     vToken :=  vRESTClientPooler.RenewToken(DWParams, vErrorBoolean, Error);
                     If Not vErrorBoolean Then
                      TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := vToken;
                    End;
                  End;
   End;
  End;
End;

Function TRESTDWClientEvents.SendEvent(EventName    : String;
                                   Var DWParams : TRESTDWParams;
                                   Var Error    : String;
                                   EventType    : TSendEvent = sePOST;
                                   Assyncexec   : Boolean = False): Boolean;
Var
 vDataMode     : TDataMode;
Begin
 // Add por Ico Menezes
 Result          := False;
 Error           := '';
 If vRESTClientPooler <> Nil Then
  Begin
   If Assigned(vOnBeforeSend) Then
     vOnBeforeSend(Self);
   If Assigned(vRESTClientPooler.OnBeforeExecute) Then
    vRESTClientPooler.OnBeforeExecute(Self);
   If vEventList.EventByName[EventName] = Nil Then
    Begin
     Result := False;
     Error  := cInvalidEvent;
     Exit
    End;
   TokenValidade(DWParams, Error);
   vDataMode := vEventList.EventByName[EventName].vDataMode;
   Try
    Error    := vRESTClientPooler.SendEvent(EventName, DWParams, EventType, vDataMode, vServerEventName, Assyncexec);
    Result   := (Error = TReplyOK) Or (Error = AssyncCommandMSG);
    If Result Then
     Error  := '';
   Except
    On E : Exception Do
     Begin
      // Eloy
      Error := E.Message;
      If Error = cInvalidAuth Then
       Begin
        Case vRESTClientPooler.AuthenticationOptions.AuthorizationOption Of
         rdwAOBearer : Begin
                        If (TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken) And
                           (TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoRenewToken) And
                           (TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token <> '')  Then
                         Begin
                          TRESTDWAuthOptionBearerClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                          SendEvent(EventName, DWParams, Error, EventType, Assyncexec);
                         End;
                       End;
         rdwAOToken  : Begin
                        If (TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoGetToken)  And
                           (TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).AutoRenewToken) And
                           (TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token  <> '')  Then
                         Begin
                          TRESTDWAuthOptionTokenClient(vRESTClientPooler.AuthenticationOptions.OptionParams).Token := '';
                          SendEvent(EventName, DWParams, Error, EventType, Assyncexec);
                         End;
                       End;
        End;
       End
      Else
       Begin
        Raise Exception.Create(Error);
       End;
     End;
   End;
  End;
End;

procedure TRESTDWClientEvents.ClearEvents;
begin
 vEventList.ClearList;
end;

procedure TRESTDWClientEvents.SetEventList(aValue : TRESTDWEventList);
begin
 If vEditParamList Then
  vEventList := aValue;
end;

procedure TRESTDWClientEvents.SeTRESTClientPoolerBase(const Value: TRESTClientPoolerBase);
begin
 If vRESTClientPooler <> Value then
  vRESTClientPooler := Value;
 If vRESTClientPooler <> nil then
  vRESTClientPooler.FreeNotification(Self);
end;

Initialization
 RegisterClass(TRESTDWServerEvents);
 RegisterClass(TRESTDWClientEvents);
end.

