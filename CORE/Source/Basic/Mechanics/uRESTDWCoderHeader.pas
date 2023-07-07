unit uRESTDWCoderHeader;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

uses
  Classes, uRESTDWProtoTypes, uRESTDWTools;

  Function EncodeHeader(Const Header         : String;
                        Specials             : String;
                        Const HeaderEncoding : Char;
                        Const MimeCharSet    : String) : String;
  Function DecodeHeader(Const Header         : String) : String;

Implementation

Uses
 uRESTDWException,
 uRESTDWHeaderCoderBase,
 SysUtils;

Const
 csAddressSpecials : String = '()[]<>:;.,@\"';  {Do not Localize}

 base64_tbl        : Array [0..63] Of Char = ('A','B','C','D','E','F','G','H',     {Do not Localize}
                                              'I','J','K','L','M','N','O','P',      {Do not Localize}
                                              'Q','R','S','T','U','V','W','X',      {Do not Localize}
                                              'Y','Z','a','b','c','d','e','f',      {Do not Localize}
                                              'g','h','i','j','k','l','m','n',      {Do not Localize}
                                              'o','p','q','r','s','t','u','v',       {Do not Localize}
                                              'w','x','y','z','0','1','2','3',       {Do not Localize}
                                              '4','5','6','7','8','9','+','/');      {Do not Localize}

Function B64(AChar: Char): Byte;
Begin
 For Result := Low(base64_tbl) To High(base64_tbl) Do
  Begin
   If AChar = base64_tbl[Result] Then
    Exit;
  End;
 Result := 0;
End;

Function DecodeHeader(Const Header : String) : String;
Var
 HeaderCharSet,
 HeaderEncoding,
 HeaderData,
 S              : String;
 LLastWordWasEncoded,
 LDecoded       : Boolean;
 LStartPos,
 LLength,
 LEncodingStartPos,
 LEncodingEndPos,
 LLastStartPos  : Integer;
 Buf            : TRESTDWBytes;
 Function ExtractEncoding(Const AHeader   : String;
                          Const AStartPos : Integer;
                          Var   VStartPos,
                          VEndPos         : Integer;
                          Var VCharSet,
                          VEncoding,
                          VData           : String): Boolean;
 Var
  LCharSet,
  LEncoding,
  LData,
  LDataEnd   : Integer;
 Begin
  Result   := False;
  LCharSet := PosRDW('=?', AHeader, AStartPos);  {Do not Localize}
  If (LCharSet = 0) Or (LCharSet > VEndPos) Then
   Exit;
  Inc(LCharSet, 2);
  LEncoding := PosRDW('?', AHeader, LCharSet);  {Do not Localize}
  If (LEncoding = 0) Or (LEncoding > VEndPos) Then
   Exit;
  Inc(LEncoding);
  LData := PosRDW('?', AHeader, LEncoding);  {Do not Localize}
  If (LData = 0) Or (LData > VEndPos) Then
   Exit;
  Inc(LData);
  LDataEnd := PosRDW('?=', AHeader, LData);  {Do not Localize}
  If (LDataEnd = 0) Or (LDataEnd > VEndPos) Then
   Exit;
  Inc(LDataEnd);
  VStartPos := LCharSet-2;
  VEndPos := LDataEnd;
  VCharSet := Copy(AHeader, LCharSet, LEncoding-LCharSet-1);
  VEncoding := Copy(AHeader, LEncoding, LData-LEncoding-1);
  VData := Copy(AHeader, LData, LDataEnd-LData-1);
  Result := True;
 End;
 Function ExtractEncodedData(Const AEncoding,
                             AData           : String;
                             Var VDecoded    : TRESTDWBytes) : Boolean;
 Var
  I,
  J  : Integer;
  a3 : TRESTDWBytes;
  a4 : Array [0..3] of Byte;
 Begin
  Result := False;
  SetLength(VDecoded, 0);
  Case PosInStrArray(AEncoding, ['Q', 'B', '8'], False) Of {Do not Localize}
    0: Begin // quoted-printable
        I := 1;
        While I <= Length(AData) Do
         Begin
          If AData[i] = '_' Then
           AppendByte(VDecoded, Ord(' '))    {Do not Localize}
          Else If (AData[i] = '=') And (Length(AData) >= (i+2)) Then
           Begin //make sure we can access i+2
            AppendByte(VDecoded, RDWStrToInt('$' + Copy(AData, i+1, 2), 32));   {Do not Localize}
            Inc(I, 2);
           End
          Else
           AppendByte(VDecoded, Ord(AData[i]));
          Inc(I);
         End;
        Result := True;
       End;
      1: Begin // base64
          J := Length(AData) Div 4;
          If J > 0 then
           Begin
            SetLength(a3, 3);
            For I := 0 To J-1 Do
             Begin
              a4[0] := B64(AData[(I*4)+1]);
              a4[1] := B64(AData[(I*4)+2]);
              a4[2] := B64(AData[(I*4)+3]);
              a4[3] := B64(AData[(I*4)+4]);
              a3[0] := Byte((a4[0] shl 2) or (a4[1] shr 4));
              a3[1] := Byte((a4[1] shl 4) or (a4[2] shr 2));
              a3[2] := Byte((a4[2] shl 6) or (a4[3] shr 0));
              If AData[(I*4)+4] = '=' Then
               Begin
                If AData[(I*4)+3] = '=' Then
                 AppendByte(VDecoded, a3[0])
                Else
                 AppendBytes(VDecoded, a3, 0, 2);
                Break;
               End
              Else
               AppendBytes(VDecoded, a3, 0, 3);
             End;
           End;
          Result := True;
         End;
      2: Begin // 8-bit
          {$IFDEF STRING_IS_ANSI}
           If AData <> '' then
            VDecoded := RawToBytes(AData[1], Length(AData));
          {$ELSE}
           VDecoded := GetBytes(AData);
          {$ENDIF}
          Result := True;
         End;
  End;
 End;
Begin
 Result := Header;
 LStartPos := 1;
 LLength := Length(Result);
 LLastWordWasEncoded := False;
 LLastStartPos := LStartPos;
 While LStartPos <= LLength do
  Begin
   LStartPos := FindFirstNotOf(LWS, Result, LLength, LStartPos);
   If LStartPos = 0 Then
    Break;
   LEncodingEndPos := FindFirstOf(LWS, Result, LLength, LStartPos);
   If LEncodingEndPos <> 0 Then
    Dec(LEncodingEndPos)
   Else
    LEncodingEndPos := LLength;
   If ExtractEncoding(Result, LStartPos, LEncodingStartPos,
                      LEncodingEndPos, HeaderCharSet,
                      HeaderEncoding, HeaderData) Then
    Begin
     LDecoded := False;
     If ExtractEncodedData(HeaderEncoding, HeaderData, Buf) Then
      LDecoded := DecodeHeaderData(HeaderCharSet, Buf, S);
     If LDecoded Then
      Begin
       If LLastWordWasEncoded Then
        Begin
         Result := Copy(Result, 1, LLastStartPos - 1) + S + Copy(Result, LEncodingEndPos + 1, MaxInt);
         LStartPos := LLastStartPos + Length(S);
        End
       Else
        Begin
         Result := Copy(Result, 1, LEncodingStartPos - 1) + S + Copy(Result, LEncodingEndPos + 1, MaxInt);
         LStartPos := LEncodingStartPos + Length(S);
        End;
      End
     Else
      LStartPos := LEncodingEndPos + 1;
     LLength := Length(Result);
     LLastWordWasEncoded := True;
     LLastStartPos := LStartPos;
    End
   Else
    Begin
     LStartPos := FindFirstOf(LWS, Result, LLength, LStartPos);
     If LStartPos = 0 Then
      Break;
     LLastWordWasEncoded := False;
    End;
  End;
End;

Function EncodeHeader(Const Header         : String;
                      Specials             : String;
                      Const HeaderEncoding : Char;
                      Const MimeCharSet    : String) : String;
Const
 SPACES = [Ord(' '), 9, 13, 10];    {Do not Localize}
Var
 L,
 P,
 Q,
 R,
 B0,
 B1,
 B2,
 InEncode   : Integer;
 NeedEncode : Boolean;
 Buf,
 csNoEncode,
 csNoReqQuote,
 csSpecials : TRESTDWBytes;
 T,
 BeginEncode,
 EndEncode  : String;
 Procedure EncodeWord(AP: Integer);
 Const
  MaxEncLen = 75;
 Var
  LQ,
  EncLen : Integer;
  Enc1   : String;
 Begin
  T := T + BeginEncode;
  If L < AP Then
   AP := L + 1;
  LQ := InEncode;
  InEncode := -1;
  EncLen := Length(BeginEncode) + 2;
  Case PosInStrArray(HeaderEncoding, ['Q', 'B'], False) Of {Do not Localize}
   0 : Begin { quoted-printable }
        While LQ < AP Do
         Begin
          If Buf[LQ] = Ord(' ') Then
           Enc1 := '_'
          Else If (Not ByteIsInSet(Buf, LQ, csNoReqQuote)) or
                       ByteIsInSet(Buf, LQ, csSpecials)    Then
           Enc1 := '=' + IntToHex(Buf[LQ], 2)     {Do not Localize}
          Else
           Enc1 := Char(Buf[LQ]);
          If (EncLen + Length(Enc1)) > MaxEncLen Then
           Begin
            T := T + EndEncode + EOL + ' ' + BeginEncode;
            EncLen := Length(BeginEncode) + 2;
           End;
          T := T + Enc1;
          Inc(EncLen, Length(Enc1));
          Inc(LQ);
         End;
       End;
   1 : Begin
        While LQ < AP Do
         Begin
          If (EncLen + 4) > MaxEncLen Then
           Begin
            T := T + EndEncode + EOL + ' ' + BeginEncode;
            EncLen := Length(BeginEncode) + 2;
           End;
          B0 := Buf[LQ];
          Case AP - LQ Of
           1 : T := T + base64_tbl[B0 shr 2] + base64_tbl[B0 and $03 shl 4] + '==';  {Do not Localize}
           2 : Begin
                B1 := Buf[LQ + 1];
                T  := T + base64_tbl[B0 shr 2] +
                      base64_tbl[B0 and $03 shl 4 + B1 shr 4] +
                      base64_tbl[B1 and $0F shl 2] + '=';  {Do not Localize}
               End;
           Else
               Begin
                B1 := Buf[LQ + 1];
                B2 := Buf[LQ + 2];
                T  := T + base64_tbl[B0 shr 2] +
                      base64_tbl[B0 and $03 shl 4 + B1 shr 4] +
                      base64_tbl[B1 and $0F shl 2 + B2 shr 6] +
                      base64_tbl[B2 and $3F];
               End;
          End;
          Inc(EncLen, 4);
          Inc(LQ, 3);
         End;
       End;
  End;
  T := T + EndEncode;
 End;
 Function CreateEncodeRange(AStart, AEnd: Byte): TRESTDWBytes;
 Var
  I : Integer;
 Begin
  SetLength(Result, AEnd-AStart+1);
  For I := 0 To restdwLength(Result)-1 Do
   Result[I] := AStart+I;
 End;
Begin
 If Header = '' Then
  Begin
   Result := '';
   Exit;
  End;
 Buf := EncodeHeaderData(MimeCharSet, Header);
 If HeaderEncoding = '8' Then
  Begin {Do not Localize}
   Result := BytesToStringRaw(Buf);
   Exit;
  End;
 csNoEncode := CreateEncodeRange(32, 126);
 csNoReqQuote := CreateEncodeRange(33, 60);
 AppendByte(csNoReqQuote, 62);
 AppendBytes(csNoReqQuote, CreateEncodeRange(64, 94));
 AppendBytes(csNoReqQuote, CreateEncodeRange(96, 126));
 csSpecials := ToBytes(Specials);
 BeginEncode := '=?' + MimeCharSet + '?' + HeaderEncoding + '?';    {Do not Localize}
 EndEncode := '?=';  {Do not Localize}
 If DecodeHeader(Header) <> Header Then
  RemoveBytes(csNoEncode, 1, ByteIndex(Ord('='), csNoEncode));
 L := restdwLength(Buf);
 P := 0;
 T := '';  {Do not Localize}
 InEncode := -1;
 While P < L do
  Begin
   Q := P;
   While (P < L) And
         (Buf[P] In SPACES) Do
    Inc(P);
   R := P;
   NeedEncode := False;
   While (P < L)      And
         (Not (Buf[P] in SPACES)) Do
    Begin
     If (Not ByteIsInSet(Buf, P, csNoEncode)) Or
             ByteIsInSet(Buf, P, csSpecials)  Then
      NeedEncode := True;
     Inc(P);
    End;
   If NeedEncode Then
    Begin
     If InEncode = -1 Then
      Begin
       T := T + BytesToString(Buf, Q, R - Q);
       InEncode := R;
      End;
    End
   Else
    Begin
     If InEncode <> -1 Then
      EncodeWord(Q);
      T := T + BytesToString(Buf, Q, P - Q);
    End;
  End;
 If InEncode <> -1 Then
  EncodeWord(P);
 Result := T;
End;

End.
