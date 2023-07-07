unit uRESTDWCoder3to4;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
  Classes, SysUtils, uRESTDWCoder, uRESTDWBasicTypes, uRESTDWProtoTypes;

 Type
  TRESTDWDecodeTable = Array[1..127] of Byte;
  TRESTDWEncoder3to4 = Class(TRESTDWEncoder)
 Protected
  FCodingTable: TRESTDWBytes;
  FFillChar: Char;
  Function InternalEncode(const ABuffer: TRESTDWBytes): TRESTDWBytes;
 Public
  Procedure Encode(ASrcStream: TStream; ADestStream: TStream; const ABytes: Integer = -1); Override;
  Property  CodingTable : TRESTDWBytes Read FCodingTable;
 Published
  Property FillChar: Char Read FFillChar Write FFillChar;
 End;
  TRESTDWEncoder3to4Class = Class of TRESTDWEncoder3to4;
  TRESTDWDecoder4to3      = Class(TRESTDWDecoder)
 Protected
  FCodingTable : TRESTDWBytes;
  FDecodeTable : TRESTDWDecodeTable;
  FFillChar    : Char;
  Function InternalDecode(Const ABuffer       : TRESTDWBytes;
                          Const AIgnoreFiller : Boolean = False) : TRESTDWBytes;
 Public
  Class Procedure ConstructDecodeTable(Const ACodingTable : String;
                                       Var ADecodeArray   : TRESTDWDecodeTable);
  Procedure Decode                    (ASrcStream         : TStream;
                                       Const ABytes       : Integer = -1); Override;
 Published
  Property FillChar: Char read FFillChar write FFillChar;
 End;

Implementation

Uses
 uRESTDWException, uRESTDWTools;

Class Procedure TRESTDWDecoder4to3.ConstructDecodeTable(Const ACodingTable : String;
                                                        Var ADecodeArray   : TRESTDWDecodeTable);
Var
 c, i : Integer;
Begin
 For i := Low(ADecodeArray) To High(ADecodeArray) Do
  ADecodeArray[i] := $FF;
 c := 0;
 For i := 1 To Length(ACodingTable) Do
  Begin
   ADecodeArray[Ord(ACodingTable[i])] := c;
   Inc(c);
  End;
End;

Procedure TRESTDWDecoder4to3.Decode(ASrcStream   : TStream;
                                    Const ABytes : Integer = -1);
Var
 LBuffer  : TRESTDWBytes;
 LBufSize : Integer;
Begin
 LBufSize := restdwLength(ASrcStream, ABytes);
 If LBufSize > 0 Then
  Begin
   SetLength(LBuffer, LBufSize);
   TRESTDWStreamHelper.ReadBytes(ASrcStream, LBuffer, LBufSize);
   LBuffer := InternalDecode(LBuffer);
   If Assigned(FStream) Then
    TRESTDWStreamHelper.Write(FStream, LBuffer);
  End;
End;

Function TRESTDWDecoder4to3.InternalDecode(Const ABuffer       : TRESTDWBytes;
                                           Const AIgnoreFiller : Boolean) : TRESTDWBytes;
Var
 LOutPos,
 LOutSize,
 LInLimit,
 LInPos,
 LInBufSize,
 LEmptyBytes : Integer;
 LInBytes    : TRESTDWBytes;
Begin
 SetLength(LInBytes, 4);
 LInPos := 0;
 LInBufSize := restdwLength(ABuffer);
 If (LInBufSize Mod 4) <> 0 Then
  LInLimit := (LInBufSize div 4) * 4
 Else
  LInLimit := LInBufSize;
 LOutPos := 0;
 LOutSize := (LInLimit div 4) * 3;
 SetLength(Result, LOutSize);
 While LInPos < LInLimit Do
  Begin
   LInBytes[0] := ABuffer[LInPos];
   LInBytes[1] := ABuffer[LInPos + 1];
   LInBytes[2] := ABuffer[LInPos + 2];
   LInBytes[3] := ABuffer[LInPos + 3];
   Inc(LInPos, 4);
   Result[LOutPos]     := ((FDecodeTable[LInBytes[0]] and 63) shl 2) or ((FDecodeTable[LInBytes[1]] shr 4) and 3);
   Result[LOutPos + 1] := ((FDecodeTable[LInBytes[1]] and 15) shl 4) or ((FDecodeTable[LInBytes[2]] shr 2) and 15);
   Result[LOutPos + 2] := ((FDecodeTable[LInBytes[2]] and 3) shl 6) or (FDecodeTable[LInBytes[3]] and 63);
   Inc(LOutPos, 3);
  End;
 If (Not AIgnoreFiller) And
    (LInPos > 0)        Then
  Begin
   If ABuffer[LInPos-1] = Ord(FillChar) Then
    Begin
     If ABuffer[LInPos-2] = Ord(FillChar) Then
      LEmptyBytes := 2
     Else
      LEmptyBytes := 1;
     SetLength(Result, LOutSize - LEmptyBytes);
    End;
  End;
End;

Procedure TRESTDWEncoder3to4.Encode(ASrcStream,
                                    ADestStream  : TStream;
                                    Const ABytes : Integer = -1);
Var
 LBuffer  : TRESTDWBytes;
 LBufSize : Integer;
Begin
 LBufSize := restdwLength(ASrcStream, ABytes);
 If LBufSize > 0 Then
  Begin
   SetLength(LBuffer, LBufSize);
   TRESTDWStreamHelper.ReadBytes(ASrcStream, LBuffer, LBufSize);
   LBuffer := InternalEncode(LBuffer);
   TRESTDWStreamHelper.Write(ADestStream, LBuffer);
  End;
End;

Function TRESTDWEncoder3to4.InternalEncode(Const ABuffer : TRESTDWBytes) : TRESTDWBytes;
Var
 LInBufSize,
 LOutSize,
 LLen,
 LPos,
 LBufDataLen,
 LSize        : Integer;
 LIn1,
 LIn2,
 LIn3         : Byte;
Begin
 LInBufSize := restdwLength(ABuffer);
 LOutSize   := ((LInBufSize + 2) div 3) * 4;
 SetLength(Result, LOutSize);
 LLen := 0;
 LPos := 0;
 While LPos < LInBufSize Do
  Begin
   Assert((LLen + 4) <= LOutSize, 'TRESTDWEncoder3to4.Encode: Calculated length exceeded (expected ' +
                                  IntToStr(LOutSize) + ', about to go ' + IntToStr(LLen + 4) + ' at offset ' +
                                  IntToStr(LPos)     + ' of '           + IntToStr(LInBufSize));

   LBufDataLen := LInBufSize - LPos;
   If LBufDataLen > 2 Then
    Begin
     LIn1 := ABuffer[LPos];
     LIn2 := ABuffer[LPos+1];
     LIn3 := ABuffer[LPos+2];
     LSize := 3;
    End
   Else If LBufDataLen > 1 Then
    Begin
     LIn1 := ABuffer[LPos];
     LIn2 := ABuffer[LPos+1];
     LIn3 := 0;
     LSize := 2;
    End
   Else
    Begin
     LIn1 := ABuffer[LPos];
     LIn2 := 0;
     LIn3 := 0;
     LSize := 1;
    End;
   Inc(LPos, LSize);
   Assert(restdwLength(FCodingTable)>0);
   Result[LLen]     := FCodingTable[(LIn1   Shr 2)  And 63];
   Result[LLen + 1] := FCodingTable[(((LIn1 And 3)  Shl 4)   Or
                                    ((LIn2  Shr 4)  And 15)) And 63];
   Result[LLen + 2] := FCodingTable[(((LIn2 And 15) Shl 2)   Or
                                     ((LIn3 Shr 6)  And 3))  And 63];
   Result[LLen + 3] := FCodingTable[LIn3 and 63];
   Inc(LLen, 4);
   If LSize < 3 Then
    Begin
     Result[LLen-1] := Ord(FillChar);
     If LSize = 1 Then
      Result[LLen-2] := Ord(FillChar);
    End;
  End;
 SetLength(Result, LLen);
 Assert(LLen = LOutSize, 'TRESTDWEncoder3to4.Encode: Calculated length not met (expected ' +
                         IntToStr(LOutSize) + ', finished at ' + IntToStr(LLen) + ', BufSize = ' + IntToStr(LInBufSize));
End;

End.

