unit uRESTDWResponseTranslator;

{$I ..\..\Source\Includes\uRESTDW.inc}
{$IFDEF RESTDWLAZARUS}
 {$mode objfpc}{$H+}
{$ENDIF}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

Uses
  SysUtils, Classes,
  uRESTDWAbout, uRESTDWTools, uRESTDWConsts;

Type
 TPrepareGet         = Procedure (Var AUrl          : String;
                                  Var AHeaders      : TStringList) Of Object;
 TAfterRequest       = Procedure (AUrl              : String;
                                  ResquestType      : TRequestType;
                                  AResponse         : TStream)  Of Object;


Type
 TRESTDWFieldDef = Class;
 TRESTDWFieldDef = Class(TCollectionItem)
 Private
  vElementName,
  vFieldName    : String;
  vElementIndex,
  vFieldSize,
  vPrecision    : Integer;
  vDataType     : TObjectValue;
  vRequired     : Boolean;
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Constructor Create        (aCollection : TCollection); Override;
 Published
  Property    FieldName    : String       Read GetDisplayName Write SetDisplayName;
  Property    ElementName  : String       Read vElementName   Write vElementName;
  Property    ElementIndex : Integer      Read vElementIndex  Write vElementIndex;
  Property    FieldSize    : Integer      Read vFieldSize     Write vFieldSize;
  Property    Precision    : Integer      Read vPrecision     Write vPrecision;
  Property    DataType     : TObjectValue Read vDataType      Write vDataType;
  Property    Required     : Boolean      Read vRequired      Write vRequired;
End;

Type
 TRESTDWFieldDefs = Class;
 TRESTDWFieldDefs = Class(TOwnedCollection)
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TRESTDWFieldDef;  Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TRESTDWFieldDef);            Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TRESTDWFieldDef;  Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TRESTDWFieldDef);            Overload;
 Public
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete        (Index   : Integer);                   Overload;
  Property    Items         [Index   : Integer]   : TRESTDWFieldDef Read GetRec     Write PutRec; Default;
  Property    FieldDefByName[Index   : String ]   : TRESTDWFieldDef Read GetRecName Write PutRecName;
End;

Type
 TRESTDWResponseTranslator = Class(TRESTDWComponent)
 Private
  vOpenRequest,
  vInsertRequest,
  vEditRequest,
  vDeleteRequest        : TRequestType;
  vRequestOpenUrl,
  vRequestInsertUrl,
  vRequestEditUrl,
  vRequestDeleteUrl,
  vElementBaseName,
  aValue                : String;
  fOwner                : TPersistent;
  vDWClientREST         : TRESTDWComponent;
  vDWFieldDefs          : TRESTDWFieldDefs;
  vElementBaseIndex     : Integer;
  vAutoReadElementIndex : Boolean;
  vJSONEditor           : TStringList;
  Procedure   ReadData    (Value  : String);
  procedure SetJSONEditor(const Value: TStringList);
  function GeTRESTDWClientRESTBase: TRESTDWComponent;
  procedure SeTRESTDWClientRESTBase(const Value: TRESTDWComponent);
 Protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  Constructor Create      (AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
  Function    Open        (ResquestType : TRequestType;
                           RequestURL   : String) : String;
  Procedure   ApplyUpdates(ResquestType : TRequestType);
  Procedure   GetFieldDefs(JSONBase : String = '');
 Published
  Property ElementAutoReadRootIndex : Boolean       Read vAutoReadElementIndex Write vAutoReadElementIndex;
  Property ElementRootBaseIndex     : Integer       Read vElementBaseIndex     Write vElementBaseIndex;
  Property ElementRootBaseName      : String        Read vElementBaseName      Write vElementBaseName;
  Property RequestOpen              : TRequestType  Read vOpenRequest          Write vOpenRequest;
  Property RequestInsert            : TRequestType  Read vInsertRequest        Write vInsertRequest;
  Property RequestEdit              : TRequestType  Read vEditRequest          Write vEditRequest;
  Property RequestDelete            : TRequestType  Read vDeleteRequest        Write vDeleteRequest;
  Property RequestOpenUrl           : String        Read vRequestOpenUrl       Write vRequestOpenUrl;
  Property RequestInsertUrl         : String        Read vRequestInsertUrl     Write vRequestInsertUrl;
  Property RequestEditUrl           : String        Read vRequestEditUrl       Write vRequestEditUrl;
  Property RequestDeleteUrl         : String        Read vRequestDeleteUrl     Write vRequestDeleteUrl;
  Property FieldDefs                : TRESTDWFieldDefs  Read vDWFieldDefs          Write vDWFieldDefs;
  Property ClientREST               : TRESTDWComponent  Read GeTRESTDWClientRESTBase       Write SeTRESTDWClientRESTBase;
  Property JSONEditor               : TStringList   Read vJSONEditor           Write SetJSONEditor;
End;

Implementation

Uses uRESTDWJSONObject, uRESTDWBasicClass;

{ TRESTDWResponseTranslator }

Procedure TRESTDWResponseTranslator.ApplyUpdates(ResquestType : TRequestType);
Begin

End;

Constructor TRESTDWResponseTranslator.Create(AOwner : TComponent);
Begin
 Inherited;
 fOwner                := AOwner;
 vElementBaseIndex     := -1;
 vElementBaseName      := '';
 vAutoReadElementIndex := True;
 vDWFieldDefs          := TRESTDWFieldDefs.Create(Self, TRESTDWFieldDef);
 vOpenRequest          := rtGet;
 vInsertRequest        := rtPost;
 vEditRequest          := rtPost;
 vDeleteRequest        := rtDelete;
 vJSONEditor           := TStringList.Create;
End;

Destructor TRESTDWResponseTranslator.Destroy;
begin
 FreeAndNil(vDWFieldDefs);
 FreeAndNil(vJSONEditor);
 Inherited;
end;

Function TRESTDWResponseTranslator.GeTRESTDWClientRESTBase: TRESTDWComponent;
Begin
 Result := vDWClientREST;
End;

Procedure TRESTDWResponseTranslator.GetFieldDefs(JSONBase : String = '');
Var
 vValue       : String;
 LDataSetList : TJSONValue;
Begin
 vValue := JSONBase;
 If Trim(vValue) = '' Then
  vValue := Open(RequestOpen, RequestOpenUrl);
 LDataSetList := TJSONValue.Create;
 Try
  LDataSetList.Encoded  := False;
  If Assigned(ClientREST) Then
   LDataSetList.Encoding := TRESTDWClientRESTBase(ClientREST).RequestCharset;
  LDataSetList.WriteToFieldDefs(vValue, Self);
 Finally
  FreeAndNil(LDataSetList);
 End;
End;

procedure TRESTDWResponseTranslator.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = vDWClientREST) then
  begin
    vDWClientREST := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

Function TRESTDWResponseTranslator.Open(ResquestType : TRequestType;
                                        RequestURL   : String) : String;
Var
 vResult : TStringStream;
Begin
  Result  := '';
  {$IFDEF DELPHIXEUP}
    vResult := TStringStream.Create('', TEncoding.UTF8);
  {$ELSE}
    vResult  := TStringStream.Create('');
  {$ENDIF}
 Try
  Case ResquestType Of
   rtGet  : TRESTDWClientRESTBase(ClientREST).Get (RequestURL, Nil, vResult);
   rtPost : TRESTDWClientRESTBase(ClientREST).Post(RequestURL, Nil, vResult);
  End;
 Finally
  {$IFDEF RESTDWLAZARUS}
   Result  := StringReplace(vResult.DataString, #10, '', [rfReplaceAll]);
  {$ELSE}
   Result  := StringReplace(vResult.DataString, #$A, '', [rfReplaceAll]);
  {$ENDIF}
  FreeAndNil(vResult);
 End;
End;

Procedure TRESTDWResponseTranslator.ReadData(Value : String);
Begin
 aValue := Value;
End;

Procedure TRESTDWResponseTranslator.SeTRESTDWClientRESTBase(const Value: TRESTDWComponent);
Begin
 If vDWClientREST <> Value Then
  vDWClientREST := Value;
 If vDWClientREST <> nil then
  vDWClientREST.FreeNotification(Self);
End;

procedure TRESTDWResponseTranslator.SetJSONEditor(const Value: TStringList);
Var
 I : Integer;
Begin
 vJSONEditor.Clear;
 For I := 0 To Value.Count -1 do
  vJSONEditor.Add(Value[I]);
end;

{ TRESTDWFieldDefs }

Procedure TRESTDWFieldDefs.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(I);
 Self.Clear;
End;

Constructor TRESTDWFieldDefs.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWFieldDef);
 Self.fOwner := AOwner;
End;

Procedure TRESTDWFieldDefs.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
End;

Destructor TRESTDWFieldDefs.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TRESTDWFieldDefs.GetRec(Index: Integer): TRESTDWFieldDef;
Begin
 Result := TRESTDWFieldDef(inherited GetItem(Index));
End;

Function TRESTDWFieldDefs.GetRecName(Index: String): TRESTDWFieldDef;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].FieldName))   Or
      (Uppercase(Index) = Uppercase(Self.Items[I].ElementName)) Then
    Begin
     Result := TRESTDWFieldDef(Self.Items[I]);
     Break;
    End;
  End;
End;

Procedure TRESTDWFieldDefs.PutRec(Index: Integer; Item: TRESTDWFieldDef);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
End;

Procedure TRESTDWFieldDefs.PutRecName(Index: String; Item: TRESTDWFieldDef);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].FieldName)) Then
    Begin
     Self.Items[I] := Item;
     Break;
    End;
  End;
End;

{ TRESTDWFieldDef }

Constructor TRESTDWFieldDef.Create(aCollection: TCollection);
Begin
 Inherited;
 vFieldName    :=  'restdwFieldDef' + IntToStr(aCollection.Count);
 vElementName  := vFieldName;
 vDataType     := ovString;
 vFieldSize    := 20;
 vPrecision    := 0;
 vElementIndex := -1;
 vRequired     := False;
End;

Function TRESTDWFieldDef.GetDisplayName: String;
Begin
 Result := vFieldName;
End;

Procedure TRESTDWFieldDef.SetDisplayName(const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create('Invalid FieldName')
 Else
  Begin
   vFieldName := Trim(Value);
   Inherited;
  End;
End;

end.
