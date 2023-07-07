Unit uRESTDWCoderMIME;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 Classes, uRESTDWCoder3to4, uRESTDWProtoTypes;

 Type
  TRESTDWEncoderMIME = Class(TRESTDWEncoder3to4)
 Protected
 Public
  Constructor Create(AOwner : TComponent); Reintroduce; Overload;
 End;
 TRESTDWDecoderMIME = Class(TRESTDWDecoder4to3)
 Protected
 Public
  Constructor Create(AOwner : TComponent); Reintroduce; Overload;
 End;
 TRESTDWDecoderMIMELineByLine = Class(TRESTDWDecoderMIME)
 Protected
  FLeftFromLastTime: TRESTDWBytes;
 Public
  Procedure DecodeBegin(ADestStream  : TStream);        Override;
  Procedure DecodeEnd; Override;
  Procedure Decode     (ASrcStream   : TStream;
                        Const ABytes : Integer = -1);   Override;
 End;

Const
 GBase64CodeTable   : String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

Var
 GBase64DecodeTable : TRESTDWDecodeTable;

Implementation

Uses
 uRESTDWTools,
 SysUtils;

Procedure TRESTDWDecoderMIMELineByLine.DecodeBegin(ADestStream : TStream);
Begin
 Inherited DecodeBegin(ADestStream);
 SetLength(FLeftFromLastTime, 0);
End;

Procedure TRESTDWDecoderMIMELineByLine.DecodeEnd;
Var
 LStream: TMemoryStream;
 LPos: Integer;
Begin
 If restdwLength(FLeftFromLastTime) > 0 Then
  Begin
   LPos := restdwLength(FLeftFromLastTime);
   SetLength(FLeftFromLastTime, 4);
   While LPos < 4 Do
    Begin
     FLeftFromLastTime[LPos] := Ord(FFillChar);
     Inc(LPos);
    End;
   LStream := TMemoryStream.Create;
   Try
    WriteBytesToStream(LStream, FLeftFromLastTime);
    LStream.Position := 0;
    Inherited Decode(LStream);
   Finally
    FreeAndNil(LStream);
    SetLength(FLeftFromLastTime, 0);
   End;
  End;
 Inherited DecodeEnd;
End;

Procedure TRESTDWDecoderMIMELineByLine.Decode(ASrcStream   : TStream;
                                              Const ABytes : Integer = -1);
Var
 LMod,
 LDiv    : Integer;
 LIn,
 LSrc    : TRESTDWBytes;
 LStream : TMemoryStream;
Begin
 LIn := FLeftFromLastTime;
 If ReadBytesFromStream(ASrcStream, LSrc, ABytes) > 0 Then
  AppendBytes(LIn, LSrc);
 LMod := restdwLength(LIn) Mod 4;
 If LMod <> 0 Then
  Begin
   LDiv              := (restdwLength(LIn) Div 4) * 4;
   FLeftFromLastTime := Copy(LIn, LDiv, restdwLength(LIn) - LDiv);
   LIn               := Copy(LIn, 0, LDiv);
  End
 Else
  SetLength(FLeftFromLastTime, 0);
 LStream := TMemoryStream.Create;
 Try
  WriteBytesToStream(LStream, LIn);
  LStream.Position := 0;
  Inherited Decode(LStream, ABytes);
 Finally
  FreeAndNil(LStream);
 End;
End;

Constructor TRESTDWDecoderMIME.Create(AOwner: TComponent);
Begin
 Inherited Create(AOwner);
 FDecodeTable := GBase64DecodeTable;
 FCodingTable := ToBytes(GBase64CodeTable);
 FFillChar    := '=';
End;

Constructor TRESTDWEncoderMIME.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 FCodingTable := ToBytes(GBase64CodeTable);
 FFillChar    := '=';
End;

Initialization
 TRESTDWDecoder4to3.ConstructDecodeTable(GBase64CodeTable, GBase64DecodeTable);
End.
