unit uRESTDWServerContext;

{$I ..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}


interface

Uses
  {$IFDEF RESTDWFMX}
    System.JSON,
  {$ELSE}
    uRESTDWJSON,
  {$ENDIF}
  SysUtils, Classes,
  uRESTDWJSONObject, uRESTDWConsts, uRESTDWParams, uRESTDWBasic,
  uRESTDWBasicTypes, uRESTDWTools, uRESTDWAbout;

Const
 TServerEventsConst = '{"typeobject":"%s", "objectdirection":"%s", "objectvalue":"%s", "paramname":"%s", "encoded":"%s", "default":"%s"}';
 DefaultTag         = '<input %s placeholder="%s">';

Type
 TRESTDWReplyRequest       = Procedure(Const Params         : TRESTDWParams;
                                   Var   ContentType,
                                         Result         : String;
                                   Const RequestType    : TRequestType)    Of Object;
 TRESTDWAuthRequest        = Procedure(Const Params         : TRESTDWParams;
                                   Var   Rejected       : Boolean;
                                   Var   ResultError    : String;
                                   Var   StatusCode     : Integer;
                                   RequestHeader        : TStringList)     Of Object;
 TRESTDWMarkRequest        = Procedure(Const Params         : TRESTDWParams;
                                   Var   ContentType,
                                         Result         : String)          Of Object;
 TRESTDWGetContextItemTag  = Procedure(Var   ContextItemTag : String)          Of Object;
 TRESTDWBeforeRenderer     = Procedure(Const BaseHeader     : String;
                                   Var   ContentType,
                                   ContentRenderer      : String;
                                   Const RequestType    : TRequestType)    Of Object;
 TObjectEvent          = Procedure(aSelf                : TComponent)      Of Object;
 TObjectExecute        = Procedure(Const aSelf          : TCollectionItem) Of Object;


 TRESTDWReplyRequestStream = Procedure(Const Params       : TRESTDWParams;
                                   Var   ContentType  : String;
                                   Const Result       : TMemoryStream;
                                   Const RequestType  : TRequestType;
                                   Var   StatusCode     : Integer) Of Object;

Type
 TRESTDWReplyRequestData = Class(TComponent)
 Private
  vReplyRequest : TRESTDWReplyRequest;
  vReplyRequestStream : TRESTDWReplyRequestStream;
 Public
  Property  OnReplyRequest       : TRESTDWReplyRequest       Read vReplyRequest       Write vReplyRequest;
  Property  OnReplyRequestStream : TRESTDWReplyRequestStream Read vReplyRequestStream Write vReplyRequestStream;
End;

Type
 TRESTDWContextRule = Class;
 PDWContextRule = ^TRESTDWContextRule;
 TRESTDWContextRule = Class(TCollectionItem)
 Protected
 Private
  vDWMarkRequest       : TRESTDWMarkRequest;
  vDWGetContextItemTag : TRESTDWGetContextItemTag;
  FName,
  vCSS,
  vType,
  vClass,
  vTagID,
  vTagReplace,
  vContextTag          : String;
  vContextScript       : TStrings;
  vOwnerCollection     : TCollection;
  Procedure SetContextScript(Value : TStrings);
 Public
  Function    GetDisplayName                  : String;             Override;
  Procedure   SetDisplayName    (Const Value  : String);            Override;
  Function    GetNamePath      : String;                            Override;
  Procedure   Assign            (Source       : TPersistent);       Override;
  Constructor Create            (aCollection  : TCollection);       Override;
  Destructor  Destroy;           Override;
  Function    BuildClass       : String;
 Published
  Property    ContextTag                  : String               Read vContextTag          Write vContextTag;
  Property    TypeItem                    : String               Read vType                Write vType;
  Property    ClassItem                   : String               Read vClass               Write vClass;
  Property    TagID                       : String               Read vTagID               Write vTagID;
  Property    TagReplace                  : String               Read vTagReplace          Write vTagReplace;
  Property    css                         : String               Read vCss                 Write vCss;
  Property    ContextScript               : TStrings             Read vContextScript       Write SetContextScript;
  Property    ObjectName                  : String               Read FName                Write FName;
  Property    OnRequestExecute            : TRESTDWMarkRequest       Read vDWMarkRequest       Write vDWMarkRequest;
  Property    OnBeforeRendererContextItem : TRESTDWGetContextItemTag Read vDWGetContextItemTag Write vDWGetContextItemTag;
End;

Type
 TRESTDWContextRuleList = Class;
 TRESTDWContextRuleList = Class(TRESTDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec     (Index       : Integer) : TRESTDWContextRule;       Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TRESTDWContextRule);                 Overload;
  Procedure   ClearList;
  Function    GetRecName (Index       : String)  : TRESTDWContextRule;       Overload;
  Procedure   PutRecName (Index       : String;
                          Item        : TRESTDWContextRule);                 Overload;
  Function    GetMarkName(Index       : String)  : TRESTDWContextRule;       Overload;
  Procedure   PutMarkName(Index       : String;
                          Item        : TRESTDWContextRule);                 Overload;
//  Procedure   Editable  (Value : Boolean);
 Public
  Function    Add    : TCollectionItem;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete       (Index      : Integer);                  Overload;
  Property    Items        [Index      : Integer]  : TRESTDWContextRule     Read GetRec      Write PutRec; Default;
  Property    ContextByName[Index      : String ]  : TRESTDWContextRule     Read GetRecName  Write PutRecName;
  Property    MarkByName   [Index      : String ]  : TRESTDWContextRule     Read GetMarkName Write PutMarkName;
End;

Type
 TRESTDWContextRules = Class(TRESTDWComponent)
 Protected
 Private
  vMasterHtml,
  vIncludeScripts,
  vInvalidChars : TStrings;
  vDWContextRuleList : TRESTDWContextRuleList;
  vIncludeScriptsHtmlTag,
  vMasterHTMLTag,
  vContentType       : String;
  vOnBeforeRenderer  : TObjectEvent;
  Procedure SetIncludeScripts  (Value : TStrings);
  Procedure SetInvalidChars    (Value : TStrings);
  Procedure SetMasterHtml      (Value : TStrings);
  Procedure SetOnBeforeRenderer(Value : TObjectEvent);
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner      : TComponent);Override; //Cria o Componente
  Function    BuildContext(BaseHTML         : TStrings;
                           IgnoreBaseHeader : Boolean) : String;
 Published
  Property    ContentType        : String             Read vContentType           Write vContentType;
  Property    MasterHtml         : TStrings           Read vMasterHtml            Write SetMasterHtml;
  Property    MasterHtmlTag      : String             Read vMasterHTMLTag         Write vMasterHTMLTag;
  Property IncludeScripts        : TStrings           Read vIncludeScripts        Write SetIncludeScripts;
  Property IncludeScriptsHtmlTag : String             Read vIncludeScriptsHtmlTag Write vIncludeScriptsHtmlTag;
  Property DeleteInvalidChars    : TStrings           Read vInvalidChars          Write SetInvalidChars;
  Property Items                 : TRESTDWContextRuleList Read vDWContextRuleList     Write vDWContextRuleList;
  Property    OnBeforeRenderer   : TObjectEvent       Read vOnBeforeRenderer      Write SetOnBeforeRenderer;
End;

Type
 TRESTDWContext = Class;
 PDWContext = ^TRESTDWContext;
 TRESTDWContext = Class(TCollectionItem)
 Protected
 Private
  vDescription,
  vDefaultHtml                           : TStrings;
  vBaseURL,
  vContextName,
  FName,
  vContentType                           : String;
  vDWParams                              : TRESTDWParamsMethods;
  vDWContextRules                        : TRESTDWContextRules;
  vOwnerCollection                       : TCollection;
  DWReplyRequestData                     : TRESTDWReplyRequestData;
  vDWRoutes                              : TRESTDWRoutes;
  vDWBeforeRenderer                      : TRESTDWBeforeRenderer;
  vOnBeforeCall                          : TObjectExecute;
  vAuthRequest                           : TRESTDWAuthRequest;
  vOnlyPreDefinedParams,
  vNeedAuthorization,
  vignorebaseheader                      : Boolean;
  Function  GetReplyRequest              : TRESTDWReplyRequest;
  Procedure SetReplyRequest   (Value     : TRESTDWReplyRequest);
  Function  GetReplyRequestStream        : TRESTDWReplyRequestStream;
  Procedure SetReplyRequestStream(Value  : TRESTDWReplyRequestStream);
  Procedure SetDefaultPage    (Strings   : TStrings);
  Procedure SetDescription    (Strings   : TStrings);
  Function  GetBeforeRenderer            : TRESTDWBeforeRenderer;
  Procedure SetBeforeRenderer (Value     : TRESTDWBeforeRenderer);
  Procedure SetBaseURL(Value : String);
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Function    GetNamePath                : String;       Override;
  Procedure   Assign        (Source      : TPersistent); Override;
  Procedure   CompareParams (Var Dest    : TRESTDWParams);
  Constructor Create        (aCollection : TCollection); Override;
  Destructor  Destroy; Override;
 Published
  Property    Params                     : TRESTDWParamsMethods       Read vDWParams              Write vDWParams;
  Property    ContentType                : String                     Read vContentType           Write vContentType;
  Property    Name                       : String                     Read GetDisplayName         Write SetDisplayName;
  Property    BaseURL                    : String                     Read vBaseURL               Write SetBaseURL;
  Property    ContextName                : String                     Read vContextName           Write vContextName;
  Property    DefaultHtml                : TStrings                   Read vDefaultHtml           Write SetDefaultPage;
  Property    Description                : TStrings                   Read vDescription           Write SetDescription;
  Property    Routes                     : TRESTDWRoutes              Read vDWRoutes              Write vDWRoutes;
  Property    ContextRules               : TRESTDWContextRules        Read vDWContextRules        Write vDWContextRules;
  Property    OnlyPreDefinedParams       : Boolean                    Read vOnlyPreDefinedParams  Write vOnlyPreDefinedParams;
  Property    IgnoreBaseHeader           : Boolean                    Read vignorebaseheader      Write vignorebaseheader;
  Property    NeedAuthorization          : Boolean                    Read vNeedAuthorization     Write vNeedAuthorization;
  Property    OnAuthRequest              : TRESTDWAuthRequest         Read vAuthRequest           Write vAuthRequest;
  Property    OnReplyRequest             : TRESTDWReplyRequest        Read GetReplyRequest        Write SetReplyRequest;
  Property    OnReplyRequestStream       : TRESTDWReplyRequestStream  Read GetReplyRequestStream  Write SetReplyRequestStream;
  Property    OnBeforeRenderer           : TRESTDWBeforeRenderer      Read GetBeforeRenderer      Write SetBeforeRenderer;
  Property    OnBeforeCall               : TObjectExecute             Read vOnBeforeCall          Write vOnBeforeCall;
End;

Type
 TRESTDWContextList = Class;
 TRESTDWContextList = Class(TRESTDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TRESTDWContext;     Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TRESTDWContext);               Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TRESTDWContext;     Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TRESTDWContext);               Overload;
//  Procedure   Editable  (Value : Boolean);
 Public
  Function    Add                    : TCollectionItem;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    ToJSON : String;
  Procedure   FromJSON     (Value    : String );
  Procedure   Delete       (Index    : Integer);                  Overload;
  Property    Items        [Index    : Integer]  : TRESTDWContext     Read GetRec     Write PutRec; Default;
  Property    ContextByName[Index    : String ]  : TRESTDWContext     Read GetRecName Write PutRecName;
End;

Type
 TRESTDWServerContext = Class(TRESTDWComponent)
 Protected
 Private
  vBaseHeader          : TStrings;
  vIgnoreInvalidParams : Boolean;
  vEventList           : TRESTDWContextList;
  vAccessTag,
  vRootContext         : String;
  vOnBeforeRenderer    : TObjectEvent;
  Procedure SetBaseHeader(Value : TStrings);
//  Procedure AfterConstruction; override;
  Procedure SetOnBeforeRenderer(Value : TObjectEvent);
 Public
  Procedure   CreateDWParams(ContextName  : String;
                             Var DWParams : TRESTDWParams);
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
 Published
  Property    IgnoreInvalidParams : Boolean        Read vIgnoreInvalidParams Write vIgnoreInvalidParams;
  Property    ContextList         : TRESTDWContextList Read vEventList       Write vEventList;
  Property    AccessTag           : String         Read vAccessTag           Write vAccessTag;
  Property    BaseHeader          : TStrings       Read vBaseHeader          Write SetBaseHeader;
  Property    OnBeforeRenderer    : TObjectEvent   Read vOnBeforeRenderer    Write SetOnBeforeRenderer;
End;

implementation

{ TRESTDWContext }

Function TRESTDWContext.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

constructor TRESTDWContext.Create(aCollection: TCollection);
begin
 Inherited;
 vDWParams               := TRESTDWParamsMethods.Create(aCollection, TRESTDWParamMethod);
 vContentType            := 'text/html';
 DWReplyRequestData      := TRESTDWReplyRequestData.Create(Nil);
 vOwnerCollection        := aCollection;
 FName                   := 'dwcontext' + IntToStr(aCollection.Count);
 vContextName            := '';
 vBaseURL                := '/';
 DWReplyRequestData.Name := FName;
 vNeedAuthorization      := True;
 vDWRoutes               := [crAll];
 vDefaultHtml            := TStringList.Create;
 vDescription            := TStringList.Create;
 vDWContextRules         := Nil;
 vIgnorebaseheader       := False;
 vOnlyPreDefinedParams   := False;
end;

destructor TRESTDWContext.Destroy;
begin
  vDWParams.Free;
  DWReplyRequestData.Free;
  vDefaultHtml.Free;
  vDescription.Free;
  inherited;
end;

Function TRESTDWContext.GetBeforeRenderer: TRESTDWBeforeRenderer;
Begin
 Result := vDWBeforeRenderer;
End;

Function TRESTDWContext.GetDisplayName: String;
Begin
 Result := DWReplyRequestData.Name;
End;

Procedure TRESTDWContext.CompareParams(Var Dest : TRESTDWParams);
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
     If (vDWParams.ParamByName[Dest.Items[I].Alias] = Nil)     And
        (vDWParams.ParamByName[Dest.Items[I].ParamName] = Nil) Then
      Dest.Delete(I);
    End;
  End;
End;

Procedure TRESTDWContext.Assign(Source: TPersistent);
begin
 If Source is TRESTDWContext then
  Begin
   FName       := TRESTDWContext(Source).ContextName;
   vDWParams   := TRESTDWContext(Source).Params;
   DWReplyRequestData.OnReplyRequest := TRESTDWContext(Source).OnReplyRequest;
  End
 Else
  Inherited;
End;

Function TRESTDWContext.GetReplyRequestStream: TRESTDWReplyRequestStream;
Begin
 Result := DWReplyRequestData.OnReplyRequestStream;
End;

Function TRESTDWContext.GetReplyRequest: TRESTDWReplyRequest;
Begin
 Result := DWReplyRequestData.OnReplyRequest;
End;

Procedure TRESTDWContext.SetBaseURL(Value : String);
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

Procedure TRESTDWContext.SetBeforeRenderer(Value: TRESTDWBeforeRenderer);
Begin
 vDWBeforeRenderer := Value;
End;

Procedure TRESTDWContext.SetDescription(Strings   : TStrings);
begin
 vDescription.Assign(Strings);
end;

procedure TRESTDWContext.SetDefaultPage(Strings: TStrings);
begin
 vDefaultHtml.Assign(Strings);
end;

Procedure TRESTDWContext.SetDisplayName(Const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidContextName)
 Else
  Begin
   FName := Value;
   DWReplyRequestData.Name := FName;
   If vContextName = '' Then
    vContextName  := DWReplyRequestData.Name;
   Inherited;
  End;
End;

Procedure TRESTDWContext.SetReplyRequestStream(Value : TRESTDWReplyRequestStream);
begin
 DWReplyRequestData.OnReplyRequestStream := Value;
end;

procedure TRESTDWContext.SetReplyRequest(Value: TRESTDWReplyRequest);
begin
 DWReplyRequestData.OnReplyRequest := Value;
end;

Function TRESTDWContextList.Add : TCollectionItem;
Begin
 Result := Nil;
 If vEditable Then
  Result := TRESTDWContext(Inherited Add);
End;

procedure TRESTDWContextList.ClearList;
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

Constructor TRESTDWContextList.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWContext);
 Self.fOwner := AOwner;
 vEditable   := True;
End;

procedure TRESTDWContextList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TRESTDWContextList.Destroy;
begin
 ClearList;
 inherited;
end;

{
procedure TRESTDWContextList.Editable(Value: Boolean);
begin
 vEditable := Value;
end;
}

{$IFDEF RESTDWFMX}
Procedure TRESTDWContextList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : system.json.TJsonObject;

 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : system.json.TJsonArray;

 I, X, Y      : Integer;
 vDWEvent     : TRESTDWContext;
 vDWParamMethod : TRESTDWParamMethod;
Begin
 Try
  bJsonArray  := TJSONObject.ParseJSONValue(Value) as TJSONArray;
  For I := 0 to bJsonArray.count -1 Do
   Begin
    bJsonOBJ := bJsonArray.get(I) as TJsonobject;
    Try
     bJsonArrayB := bJsonOBJ.getvalue('serverevents') as Tjsonarray;
     For X := 0 To bJsonArrayB.count -1 Do
      Begin
       bJsonOBJb := bJsonArrayB.get(X) as TJsonObject;
       If ContextByName[bJsonOBJb.getvalue('contextname').value] = Nil Then
        vDWEvent  := TRESTDWContext(Self.Add)
       Else
        vDWEvent  := ContextByName[bJsonOBJb.getvalue('contextname').value];
       vDWEvent.Name := bJsonOBJb.getvalue('contextname').value;
       If bJsonOBJb.getvalue('params').ToString <> '' Then
        Begin
         bJsonArrayC    := bJsonOBJb.getvalue('params') as Tjsonarray;
         Try
          For Y := 0 To bJsonArrayC.count -1 do
           Begin
            bJsonOBJc                      := bJsonArrayC.get(Y) as TJsonobject;
            If vDWEvent.vDWParams.ParamByName[bJsonOBJc.getvalue('paramname').value] = Nil Then
             vDWParamMethod                := TRESTDWParamMethod(vDWEvent.vDWParams.Add)
            Else
             vDWParamMethod                := vDWEvent.vDWParams.ParamByName[bJsonOBJc.getvalue('paramname').value];
            vDWParamMethod.TypeObject      := GetObjectName(bJsonOBJc.getvalue('typeobject').value);
            vDWParamMethod.ObjectDirection := GetDirectionName(bJsonOBJc.getvalue('objectdirection').value);
            vDWParamMethod.ObjectValue     := GetValueType(bJsonOBJc.getvalue('objectvalue').value);
            vDWParamMethod.ParamName       := bJsonOBJc.getvalue('paramname').value;
            vDWParamMethod.Encoded         := StringToBoolean(bJsonOBJc.getvalue('encoded').value);
            If Trim(bJsonOBJc.getvalue('default').value) <> '' Then
             vDWParamMethod.DefaultValue   := DecodeStrings(bJsonOBJc.getvalue('default').value{$IFDEF FPC}, csUndefined{$ENDIF});
           End;
         Finally
          bJsonArrayC.Free;
         End;
        End
       Else
        vDWEvent.vDWParams.ClearList;
      End;
    Finally
     bJsonArrayB.Free;
    End;
   End;
 Finally
  bJsonArray.Free;
 End;
End;
{$ELSE}

Procedure TRESTDWContextList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : {$IFDEF RESTDWFMX}system.json.TJsonObject;
                {$ELSE}       uRESTDWJSON.TJsonObject;{$ENDIF}
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : {$IFDEF RESTDWFMX}system.json.TJsonArray;
                {$ELSE}       uRESTDWJSON.TJsonArray;{$ENDIF}
 I, X, Y      : Integer;
 vDWEvent     : TRESTDWContext;
 vDWParamMethod : TRESTDWParamMethod;
Begin
 bJsonArrayB := Nil;
 bJsonArray  := Nil;
 Try
  bJsonArray  := Tjsonarray.Create(Value);
  For I := 0 to bJsonArray.length -1 Do
   Begin
    bJsonOBJ := bJsonArray.getJSONObject(I);
    Try
     bJsonArrayB := Tjsonarray.Create(bJsonOBJ.get('serverevents').tostring);
     For X := 0 To bJsonArrayB.length -1 Do
      Begin
       bJsonOBJb := bJsonArrayB.getJSONObject(X);
       If ContextByName[bJsonOBJb.get('contextname').tostring] = Nil Then
        vDWEvent  := TRESTDWContext(Self.Add)
       Else
        vDWEvent  := ContextByName[bJsonOBJb.get('contextname').tostring];
       vDWEvent.ContextName := bJsonOBJb.get('contextname').tostring;
       If bJsonOBJb.get('params').toString <> '' Then
        Begin
         bJsonArrayC    := Tjsonarray.Create(bJsonOBJb.get('params').toString);
         Try
          For Y := 0 To bJsonArrayC.length -1 do
           Begin
            bJsonOBJc                      := bJsonArrayC.getJSONObject(Y);
            If vDWEvent.vDWParams.ParamByName[bJsonOBJc.get('paramname').toString] = Nil Then
             vDWParamMethod                := TRESTDWParamMethod(vDWEvent.vDWParams.Add)
            Else
             vDWParamMethod                := vDWEvent.vDWParams.ParamByName[bJsonOBJc.get('paramname').toString];
            vDWParamMethod.TypeObject      := GetObjectName(bJsonOBJc.get('typeobject').toString);
            vDWParamMethod.ObjectDirection := GetDirectionName(bJsonOBJc.get('objectdirection').toString);
            vDWParamMethod.ObjectValue     := GetValueType(bJsonOBJc.get('objectvalue').toString);
            vDWParamMethod.ParamName       := bJsonOBJc.get('paramname').toString;
            vDWParamMethod.Encoded         := StringToBoolean(bJsonOBJc.get('encoded').toString);
            If Trim(bJsonOBJc.get('default').toString) <> '' Then
             vDWParamMethod.DefaultValue   := DecodeStrings(bJsonOBJc.get('default').toString{$IFDEF FPC}, csUndefined{$ENDIF});
           End;
         Finally
          bJsonArrayC.Free;
         End;
        End
       Else
        vDWEvent.vDWParams.ClearList;
      End;
    Finally
     If Assigned(bJsonArrayB) Then
      bJsonArrayB.Free;
    End;
   End;
 Finally
  If Assigned(bJsonArray) Then
   bJsonArray.Free;
 End;
End;
{$ENDIF}

Function TRESTDWContextList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TRESTDWContextList.GetRec(Index: Integer): TRESTDWContext;
begin
 Result := TRESTDWContext(Inherited GetItem(Index));
end;

function TRESTDWContextList.GetRecName(Index: String): TRESTDWContext;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].ContextName))                          Or
      (Uppercase(Index) = Uppercase(Self.Items[I].BaseURL + Self.Items[I].ContextName))  Then
    Begin
     Result := TRESTDWContext(Self.Items[I]);
     Break;
    End;
  End;
End;

procedure TRESTDWContextList.PutRec(Index: Integer; Item: TRESTDWContext);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
end;

procedure TRESTDWContextList.PutRecName(Index: String; Item: TRESTDWContext);
Var
 I : Integer;
Begin
 If (vEditable) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

Function TRESTDWContextList.ToJSON: String;
Var
 A, I : Integer;
 vTagEvent,
 vParamsLines,
 vParamLine,
 vEventsLines : String;
Begin
 Result := '';
 vEventsLines := '';
 For I := 0 To Count -1 Do
  Begin
   vTagEvent    := Format('{"contextname":"%s"', [Items[I].FName]);
   vTagEvent    := vTagEvent + ', "params":[%s]}';
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

Constructor TRESTDWServerContext.Create(AOwner : TComponent);
Begin
 Inherited;
 vOnBeforeRenderer  := Nil;
 vEventList := TRESTDWContextList.Create(Self, TRESTDWContext);
 vIgnoreInvalidParams := False;
 vBaseHeader := TStringList.Create;
End;

Destructor TRESTDWServerContext.Destroy;
Begin
 vEventList.Free;
 vBaseHeader.Free;
 Inherited;
End;

Procedure TRESTDWServerContext.SetBaseHeader(Value: TStrings);
Begin
 vBaseHeader.Assign(Value);
End;

Procedure TRESTDWServerContext.CreateDWParams(ContextName  : String;
                                          Var DWParams : TRESTDWParams);
Var
 vParamName : String;
 dwParam : TJSONParam;
 I       : Integer;
 vFound  : Boolean;
Begin
 vParamName := '';
 If (vEventList.ContextByName[ContextName] <> Nil) Then
  Begin
   If Not Assigned(DWParams) Then
    DWParams := TRESTDWParams.Create;
   DWParams.DataMode := dmRAW;
   For I := 0 To vEventList.ContextByName[ContextName].vDWParams.Count -1 Do
    Begin
     vParamName := '';
     vFound  := (DWParams.ItemsString[vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName] <> Nil);
     If vFound Then
      vParamName := vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName
     Else
      Begin
       vFound  := (DWParams.ItemsString[vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias]   <> Nil);
       If vFound Then
        vParamName := vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias;
      End;
     If Not(vFound) Then
      Begin
       dwParam                 := TJSONParam.Create(DWParams.Encoding);
       dwParam.ParamName       := vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName;
       dwParam.Alias           := vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias;
       dwParam.ObjectDirection := vEventList.ContextByName[ContextName].vDWParams.Items[I].ObjectDirection;
       dwParam.ObjectValue     := vEventList.ContextByName[ContextName].vDWParams.Items[I].ObjectValue;
       dwParam.Encoded         := vEventList.ContextByName[ContextName].vDWParams.Items[I].Encoded;
       dwParam.DataMode        := DWParams.DataMode;
       If (vEventList.ContextByName[ContextName].vDWParams.Items[I].DefaultValue <> '')  And
          (Trim(dwParam.AsString) = '') Then
        dwParam.Value           := vEventList.ContextByName[ContextName].vDWParams.Items[I].DefaultValue;
       DWParams.Add(dwParam);
      End
     Else
      Begin
       If (DWParams.ItemsString[vParamName].ParamName             =  '') Or
          ((DWParams.ItemsString[vParamName].ParamName            <> '') And
           (Lowercase(DWParams.ItemsString[vParamName].ParamName) <>
            Lowercase(vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName))) Then
        Begin
         DWParams.ItemsString[vParamName].Alias      := vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias;
         DWParams.ItemsString[vParamName].ParamName  := vEventList.ContextByName[ContextName].vDWParams.Items[I].ParamName;
        End;
       If DWParams.ItemsString[vParamName].Alias      = '' Then
        DWParams.ItemsString[vParamName].Alias       := vEventList.ContextByName[ContextName].vDWParams.Items[I].Alias;
      End;
    End;
  End
 Else
  DWParams := Nil;
End;

Procedure TRESTDWServerContext.SetOnBeforeRenderer(Value: TObjectEvent);
Begin
 vOnBeforeRenderer := Value;
End;

{ TRESTDWContextRules }

constructor TRESTDWContextRules.Create(AOwner: TComponent);
begin
 Inherited;
 vOnBeforeRenderer      := Nil;
 vIncludeScripts        := TStringList.Create;
 vInvalidChars          := TStringList.Create;
 vMasterHtml            := TStringList.Create;
 vDWContextRuleList     := TRESTDWContextRuleList.Create(Self, TRESTDWContextRule);
 vContentType           := 'text/html';
 vMasterHTMLTag         := '$body';
 vIncludeScriptsHtmlTag := '{%incscripts%}';
end;

destructor TRESTDWContextRules.Destroy;
begin
 vIncludeScripts.Free;
 vInvalidChars.Free;
 vMasterHtml.Free;
 vDWContextRuleList.Free;
 Inherited;
end;

procedure TRESTDWContextRules.SetIncludeScripts(Value: TStrings);
begin
 vIncludeScripts.Assign(Value);
end;

procedure TRESTDWContextRules.SetInvalidChars(Value: TStrings);
begin
 vInvalidChars.Assign(Value);
end;

procedure TRESTDWContextRules.SetMasterHtml(Value: TStrings);
begin
 vMasterHtml.Assign(Value);
end;

Procedure TRESTDWContextRules.SetOnBeforeRenderer(Value: TObjectEvent);
Begin
 vOnBeforeRenderer := Value;
End;

procedure TRESTDWContextRule.Assign(Source: TPersistent);
begin
  inherited;
 If Source is TRESTDWContextRule then
  Begin
   vContextTag    := TRESTDWContextRule(Source).ContextTag;
   vTagID         := TRESTDWContextRule(Source).TagID;
   vContextScript := TRESTDWContextRule(Source).ContextScript;
  End
 Else
  Inherited;
end;

Function TRESTDWContextRule.BuildClass : String;
Begin
 Result := '';
End;

Constructor TRESTDWContextRule.Create(aCollection: TCollection);
Begin
 Inherited;
 vTagID            := lowercase('dwcontextrule') + IntToStr(aCollection.Count);
 vContextTag       := Format(DefaultTag, ['{%itemtag%}', vTagID]);
 vType             := 'text';
 vClass            := 'form-control item';
 vTagReplace       := '{%' + vTagID + '%}';
 FName             := vTagID;
 vOwnerCollection  := aCollection;
 vContextScript    := TStringList.Create;
 vCss              := '';
End;

Destructor TRESTDWContextRule.Destroy;
Begin
 vContextScript.Free;
 Inherited;
End;

Function TRESTDWContextRule.GetDisplayName: String;
Begin
 Result := FName;
End;

function TRESTDWContextRule.GetNamePath: String;
begin
 Result := vOwnerCollection.GetNamePath + FName;
end;

Procedure TRESTDWContextRule.SetContextScript(Value: TStrings);
Begin
 vContextScript.Assign(Value);
End;

procedure TRESTDWContextRule.SetDisplayName(const Value: String);
begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidContextRule)
 Else
  Begin
   FName := Value;
   Inherited;
  End;
end;

{ TRESTDWContextRuleList }

Function TRESTDWContextRuleList.Add: TCollectionItem;
Begin
 Result := Nil;
 If vEditable Then
  Result := TRESTDWContextRule(Inherited Add);
End;

Function TRESTDWContextRules.BuildContext(BaseHTML         : TStrings;
                                      IgnoreBaseHeader : Boolean): String;
Var
 vTempResult,
 vTempComponent,
 vTempClass     : String;
 I              : Integer;
 Procedure ApplyContextTagList(ObjectName : String; Var TagComponent : String);
 Var
  I        : Integer;
  vTempTag : String;
 Begin
  For I := 0 To vDWContextRuleList.Count -1 Do
   Begin
    If Pos(vDWContextRuleList[I].vTagReplace, TagComponent) > InitStrPos Then
     Begin
      vTempTag := vDWContextRuleList[I].vContextTag;
      If Assigned(vDWContextRuleList[I].OnBeforeRendererContextItem) Then
       vDWContextRuleList[I].OnBeforeRendererContextItem(vTempTag);
      TagComponent := StringReplace(TagComponent, vDWContextRuleList[I].vTagReplace, vTempTag, [rfReplaceAll]);
     End;
   End;
 End;
Begin
 If Assigned(vOnBeforeRenderer) Then
  vOnBeforeRenderer(Self);
 vTempResult := '';
 Result      := '';
 If Not IgnoreBaseHeader Then
  Begin
   If Assigned(BaseHTML) Then
    vTempResult := BaseHTML.Text;
   If Pos(vMasterHTMLTag, vTempResult) > 0 Then
    If vMasterHtml.Count > 0 Then
     vTempResult := StringReplace(vTempResult, vMasterHTMLTag, vMasterHtml.Text,  [rfReplaceAll, rfIgnoreCase]);
  End;
 If vTempResult = '' Then
  vTempResult := vMasterHtml.Text;
 If Pos(vIncludeScriptsHtmlTag, vTempResult) > 0 Then
  If vIncludeScripts.Count > 0 Then
   vTempResult := StringReplace(vTempResult, vIncludeScriptsHtmlTag, vIncludeScripts.Text,  [rfReplaceAll, rfIgnoreCase]);
 For I := 0 To vDWContextRuleList.Count -1 Do
  Begin
   If (vDWContextRuleList[I].vContextTag <> DefaultTag) And
      (Pos('{%itemtag%}', lowercase(vDWContextRuleList[I].vContextTag)) > 0) Then
    Begin
     vTempClass := vDWContextRuleList[I].vContextTag;
     vTempComponent := '';
     Try
      If vDWContextRuleList[I].vType <> '' Then
       vTempComponent := vTempComponent + Format(' type="%s"',  [vDWContextRuleList[I].vType]);
      If vDWContextRuleList[I].vClass <> '' Then
       vTempComponent := vTempComponent + Format(' class="%s"', [vDWContextRuleList[I].vClass]);
      If vDWContextRuleList[I].vTagID <> '' Then
       vTempComponent := vTempComponent + Format(' id="%s"',    [vDWContextRuleList[I].vTagID]);
      If vDWContextRuleList[I].vCSS <> '' Then
       vTempComponent := vTempComponent + Format(' css="%s"',   [vDWContextRuleList[I].vCSS]);
     Finally
      vTempComponent := StringReplace(vTempClass, '{%itemtag%}', vTempComponent, [rfReplaceAll, rfIgnoreCase]);
     End;
    End
   Else
    vTempComponent := vDWContextRuleList[I].vContextTag;
   If Assigned(vDWContextRuleList[I].OnBeforeRendererContextItem) Then
    vDWContextRuleList[I].OnBeforeRendererContextItem(vTempComponent);
   ApplyContextTagList(vDWContextRuleList[I].ObjectName, vTempComponent);
   If ((vTempComponent <> '') And (vTempComponent <> DefaultTag)) Or
      ((vTempComponent = '') And (vDWContextRuleList[I].vTagReplace <> '')) Then
    vTempResult := StringReplace(vTempResult, vDWContextRuleList[I].vTagReplace, vTempComponent, [rfReplaceAll, rfIgnoreCase]);
  End;
 Result := vTempResult;
End;

procedure TRESTDWContextRuleList.ClearList;
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

constructor TRESTDWContextRuleList.Create(AOwner: TPersistent;
  aItemClass: TCollectionItemClass);
begin
 Inherited Create(AOwner, TRESTDWContextRule);
 Self.fOwner := AOwner;
 vEditable   := True;
end;

procedure TRESTDWContextRuleList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TRESTDWContextRuleList.Destroy;
begin
 ClearList;
 Inherited;
end;

Function TRESTDWContextRuleList.GetMarkName(Index : String): TRESTDWContextRule;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
    Begin
     Result := TRESTDWContextRule(Self.Items[I]);
     Break;
    End;
  End;
End;

Function TRESTDWContextRuleList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TRESTDWContextRuleList.GetRec(Index: Integer): TRESTDWContextRule;
begin
 Result := TRESTDWContextRule(Inherited GetItem(Index));
end;

Function TRESTDWContextRuleList.GetRecName(Index: String): TRESTDWContextRule;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vTagID)) Then
    Begin
     Result := TRESTDWContextRule(Self.Items[I]);
     Break;
    End;
  End;
End;

Procedure TRESTDWContextRuleList.PutMarkName(Index : String;
                                         Item  : TRESTDWContextRule);
Var
 I : Integer;
Begin
 If (vEditable) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

procedure TRESTDWContextRuleList.PutRec(Index: Integer; Item: TRESTDWContextRule);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
end;

procedure TRESTDWContextRuleList.PutRecName(Index: String; Item: TRESTDWContextRule);
Var
 I : Integer;
Begin
 If (vEditable) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].vTagID)) Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

Initialization
 RegisterClass(TRESTDWServerContext);
 RegisterClass(TRESTDWContextRules);
end.
