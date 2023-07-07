unit uRESTDWCoderQuotedPrintable;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
  Classes, uRESTDWCoder, SysUtils;

  Type
   TRESTDWDecoderQuotedPrintable = Class(TRESTDWDecoder)
  Public
   Procedure Decode(ASrcStream   : TStream;
                    Const ABytes : Integer = -1); Override;
  End;
  TRESTDWEncoderQuotedPrintable = class(TRESTDWEncoder)
  Public
   Procedure Encode(ASrcStream,
                    ADestStream  : TStream;
                    Const ABytes : Integer = -1); Override;
  End;

Implementation

Uses
 uRESTDWException,
 uRESTDWTools,
 uRESTDWBasicTypes,
 uRESTDWProtoTypes;

Procedure TRESTDWDecoderQuotedPrintable.Decode(ASrcStream: TStream; const ABytes: Integer = -1);
Var
 LBuffer      : TRESTDWBytes;
 i,
 LBufferLen,
 LBufferIndex,
 LPos         : Integer;
 B,
 DecodedByte  : Byte;
 procedure StripEOLChars;
 Var
  j : Integer;
 Begin
  For j := 1 To 2 Do
   Begin
    If (LBufferIndex >= LBufferLen) Or
       (Not ByteIsInEOL(LBuffer, LBufferIndex)) Then
     Break;
    Inc(LBufferIndex);
   End;
 End;
 Function TrimRightWhiteSpace(Const ABuf : TRESTDWBytes) : TRESTDWBytes;
 Var
  LSaveBytes : TRESTDWBytes;
  li,
  LLen       : Integer;
 Begin
  SetLength(LSaveBytes, 0);
  LLen := restdwLength(ABuf);
  For li := restdwLength(ABuf)-1 Downto 0 Do
   Begin
    Case ABuf[li] Of
     9, 32  : ;
     10, 13 : InsertByte(LSaveBytes, ABuf[li], 0);
     Else
      Break;
    End;
    Dec(LLen);
   End;
  SetLength(Result, LLen + restdwLength(LSaveBytes));
  If LLen > 0 Then
   CopyBytes(ABuf, 0, Result, 0, LLen);
  If restdwLength(LSaveBytes) > 0 Then
   CopyBytes(LSaveBytes, 0, Result, LLen, restdwLength(LSaveBytes));
 End;
 Procedure WriteByte(AValue: Byte; AWriteEOL: Boolean);
 Var
  LTemp : TRESTDWBytes;
 Begin
  SetLength(LTemp, iif(AWriteEOL, 3, 1));
  LTemp[0] := AValue;
  If AWriteEOL Then
   Begin
    LTemp[1] := Ord(CR);
    LTemp[2] := Ord(LF);
   End;
  TRESTDWStreamHelper.Write(FStream, LTemp);
 End;
Begin
 LBufferLen := restdwLength(ASrcStream, ABytes);
 If LBufferLen <= 0 Then
  Exit;
 SetLength(LBuffer, LBufferLen);
 TRESTDWStreamHelper.ReadBytes(ASrcStream, LBuffer, LBufferLen);
 LBuffer := TrimRightWhiteSpace(LBuffer);
 LBufferLen := restdwLength(LBuffer);
 LBufferIndex := 0;
 While LBufferIndex < LBufferLen Do
  Begin
   LPos := ByteIndex(Ord('='), LBuffer, LBufferIndex);
   If LPos = -1 Then
    Begin
     If Assigned(FStream) Then
      TRESTDWStreamHelper.Write(FStream, LBuffer, -1, LBufferIndex);
     Break;
    End;
   If Assigned(FStream)   Then
    TRESTDWStreamHelper.Write(FStream, LBuffer, LPos-LBufferIndex, LBufferIndex);
   LBufferIndex := LPos+1;
   If LBufferIndex < LBufferLen Then
    Begin
     i := 0;
     DecodedByte := 0;
     While LBufferIndex < LBufferLen Do
      Begin
       B := LBuffer[LBufferIndex];
       Case B Of
        48..57  : DecodedByte := (DecodedByte Shl 4) Or (B - 48);
        65..70  : DecodedByte := (DecodedByte shl 4) Or (B - 65 + 10);
        97..102 : DecodedByte := (DecodedByte shl 4) or (B - 97 + 10);
        Else
         Break;
       End;
       Inc(i);
       Inc(LBufferIndex);
       If i > 1 Then
        Break;
      End;
     If i > 0 Then
      Begin
       If (DecodedByte = 32)                 And
          (LBufferIndex < LBufferLen)        And
          ByteIsInEOL(LBuffer, LBufferIndex) Then
        Begin
         If Assigned(FStream) Then
          WriteByte(DecodedByte, True);
         StripEOLChars;
        End
       Else
        Begin
         If Assigned(FStream) Then
          WriteByte(DecodedByte, False);
        End;
      End
     Else
      StripEOLChars;
    End;
  End;
End;

Function CharToHex(const AChar : Char): String;
Begin
 Result := '=' + ByteToHex(Ord(AChar));
End;

Procedure TRESTDWEncoderQuotedPrintable.Encode(ASrcStream,
                                               ADestStream  : TStream;
                                               Const ABytes : Integer = -1);
Const
 SafeChars = '!"#$%&''()*+,-./0123456789:;<>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmonpqrstuvwxyz{|}~';
 HalfSafeChars = #9' ';
Var
 I,
 CurrentLen  : Integer;
 LSourceSize : TRESTDWStreamSize;
 S,
 SourceLine  : String;
Begin
 LSourceSize := ASrcStream.Size;
 If ASrcStream.Position < LSourceSize Then
  Begin
   Repeat
    SourceLine := ReadLnFromStream(ASrcStream, -1, False);
    CurrentLen := 0;
    For I := 1 To Length(SourceLine) Do
     Begin
      If Not CharIsInSet(SourceLine, I, SafeChars)   Then
       Begin
        If CharIsInSet(SourceLine, I, HalfSafeChars) And
          (I < Length(SourceLine))                   Then
         S := SourceLine[I]
        Else
         S := CharToHex(SourceLine[I]);
       End
      Else If ((CurrentLen = 0)      Or
               (CurrentLen >= 70))   And
               (SourceLine[I] = '.') Then
       S := CharToHex(SourceLine[I])
      Else
       S := SourceLine[I];
      WriteStringToStream(ADestStream, S, -1, 1);
      Inc(CurrentLen, Length(S));
      If CurrentLen >= 70 Then
       Begin
        WriteStringToStream(ADestStream, '=' + EOL, -1, 1);  {Do not Localize}
        CurrentLen := 0;
       End;
     End;
    WriteStringToStream(ADestStream, EOL, -1, 1);
   Until ASrcStream.Position >= LSourceSize;
  End;
End;

End.
