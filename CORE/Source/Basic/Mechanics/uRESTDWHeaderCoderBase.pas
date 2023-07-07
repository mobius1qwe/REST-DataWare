unit uRESTDWHeaderCoderBase;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

uses
  Classes, uRESTDWProtoTypes, uRESTDWException, uRESTDWTools;

Type
  TRESTDWHeaderDecodingNeededEvent = Procedure(Const ACharSet : String;
                                           Const AData    : TRESTDWBytes;
                                           Var VResult    : String;
                                           Var VHandled   : Boolean)  Of object;
  TRESTDWHeaderEncodingNeededEvent = Procedure(Const ACharSet,
                                           AData          : String;
                                           Var VResult    : TRESTDWBytes;
                                           Var VHandled   : Boolean)  Of object;

  TRESTDWHeaderCoder = class(TObject)
  public
    class function Decode(const ACharSet: String; const AData: TRESTDWBytes): String; virtual;
    class function Encode(const ACharSet, AData: String): TRESTDWBytes; virtual;
    class function CanHandle(const ACharSet: String): Boolean; virtual;
  end;

  TRESTDWHeaderCoderClass = class of TRESTDWHeaderCoder;

  eRESTDWHeaderEncodeError = class(eRESTDWException);

Var
 GHeaderEncodingNeeded : TRESTDWHeaderEncodingNeededEvent = nil;
 GHeaderDecodingNeeded : TRESTDWHeaderDecodingNeededEvent = nil;

 Function  HeaderCoderByCharSet (Const ACharSet : String) : TRESTDWHeaderCoderClass;
 Function  DecodeHeaderData     (Const ACharSet : String;
                                 Const AData    : TRESTDWBytes;
                                 Var VResult    : String) : Boolean;
 Function  EncodeHeaderData     (Const ACharSet,
                                 AData          : String): TRESTDWBytes;
 Procedure RegisterHeaderCoder  (Const ACoder   : TRESTDWHeaderCoderClass);
 Procedure UnregisterHeaderCoder(Const ACoder   : TRESTDWHeaderCoderClass);

implementation

uses
  {$IFDEF DELPHIXE3UP}
  System.Types,
  {$ENDIF}
  uRESTDWConsts,
  SysUtils;

Type
 TRESTDWHeaderCoderList = Class(TList)
Public
 Function ByCharSet(const ACharSet: String): TRESTDWHeaderCoderClass;
End;

Var
 GHeaderCoderList : TRESTDWHeaderCoderList = Nil;

Class Function TRESTDWHeaderCoder.Decode(Const ACharSet : String;
                                         Const AData    : TRESTDWBytes) : String;
Begin
 Result := '';
End;

Class Function TRESTDWHeaderCoder.Encode(Const ACharSet,
                                         AData          : String)    : TRESTDWBytes;
Begin
 Result := nil;
End;

Class Function TRESTDWHeaderCoder.CanHandle(Const ACharSet : String) : Boolean;
Begin
 Result := False;
End;

{ TRESTDWHeaderCoderList }

Function TRESTDWHeaderCoderList.ByCharSet(const ACharSet: string)    : TRESTDWHeaderCoderClass;
Var
 I      : Integer;
 LCoder : TRESTDWHeaderCoderClass;
Begin
 Result := nil;
  For I := Count-1 Downto 0 Do
   Begin
    LCoder := TRESTDWHeaderCoderClass(Items[I]);
    If LCoder.CanHandle(ACharSet) Then
     Begin
      Result := LCoder;
      Exit;
     End;
   End;
End;

Function HeaderCoderByCharSet(Const ACharSet : String) : TRESTDWHeaderCoderClass;
Begin
 If Assigned(GHeaderCoderList) Then
  Result := GHeaderCoderList.ByCharSet(ACharSet)
 Else
  Result := nil;
End;

Function DecodeHeaderData(Const ACharSet : String;
                          Const AData    : TRESTDWBytes;
                          Var VResult    : String) : Boolean;
Var
 LCoder : TRESTDWHeaderCoderClass;
Begin
 LCoder := HeaderCoderByCharSet(ACharSet);
 If LCoder <> Nil Then
  Begin
   VResult := LCoder.Decode(ACharSet, AData);
   Result := True;
  End
 Else
  Begin
   VResult := '';
   Result := False;
   If Assigned(GHeaderDecodingNeeded) Then
   GHeaderDecodingNeeded(ACharSet, AData, VResult, Result);
  End;
End;

Function EncodeHeaderData(Const ACharSet,
                          AData           : String) : TRESTDWBytes;
Var
 LCoder   : TRESTDWHeaderCoderClass;
 LEncoded : Boolean;
Begin
 LCoder := HeaderCoderByCharSet(ACharSet);
 If LCoder <> Nil Then
  Result := LCoder.Encode(ACharSet, AData)
 Else
  Begin
   Result := nil;
   LEncoded := False;
   If Assigned(GHeaderEncodingNeeded) Then
    GHeaderEncodingNeeded(ACharSet, AData, Result, LEncoded);
   If not LEncoded Then
    Raise eRESTDWHeaderEncodeError.CreateFmt(cHeaderEncodeError, [ACharSet]);
  End;
End;

Procedure RegisterHeaderCoder(Const ACoder : TRESTDWHeaderCoderClass);
Begin
 If Assigned(ACoder) And
    Assigned(GHeaderCoderList) And
   (GHeaderCoderList.IndexOf(TObject(ACoder)) = -1) Then
  GHeaderCoderList.Add(TObject(ACoder));
End;

Procedure UnregisterHeaderCoder(Const ACoder : TRESTDWHeaderCoderClass);
Begin
 If Assigned(GHeaderCoderList) Then
  GHeaderCoderList.Remove(TObject(ACoder));
End;

Initialization
  GHeaderCoderList := TRESTDWHeaderCoderList.Create;
Finalization
 FreeAndNil(GHeaderCoderList);

End.
