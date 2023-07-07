unit uRESTDWBase64;

{$I ..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 {$IFDEF DELPHIXE7UP}System.NetEncoding,{$ENDIF}
  SysUtils,
  uRESTDWTools, uRESTDWProtoTypes, uRESTDWConsts;

 Type
  TRESTDWBase64 = Class
   Class Function Encode   (const ASource: TRESTDWBytes): TRESTDWBytes; Overload;
   Class Function Decode   (const ASource: TRESTDWBytes): TRESTDWBytes; Overload;
   Class Function URLEncode(const ASource: TRESTDWBytes): TRESTDWBytes; Overload;
   Class Function URLDecode(const ASource: TRESTDWBytes): TRESTDWBytes; Overload;
 End;

Implementation

{$IF Defined(RESTDWLAZARUS) or not Defined(DELPHIXE6UP)}
  Type
   TPacket = Packed Record
   Case Integer of
    0 : (b0, b1, b2, b3: Byte);
    1 : (i : Integer);
    2 : (a : array[0..3] of Byte);
   End;

  Function DecodeBase64(Const AInput : String) : TRESTDWBytes;
  Const
  DECODE_TABLE: array[#0..#127] of Integer = (
     Byte('='), 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
     64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
     64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63,
     52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
     64,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
     15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64,
     64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
     41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64
   );

   function DecodePacket(AInputBuffer: PChar; var ANumChars: Integer): TPacket;
   begin
     Result.a[0] :=
       (DECODE_TABLE[AInputBuffer[0]] shl 2) or (DECODE_TABLE[AInputBuffer[1]] shr 4);
     ANumChars := 1;
     if AInputBuffer[2] <> '=' then
     begin
       Inc(ANumChars);
       Result.a[1] := (DECODE_TABLE[AInputBuffer[1]] shl 4) or (DECODE_TABLE[AInputBuffer[2]] shr 2);
     end;
     if AInputBuffer[3] <> '=' then
     begin
       Inc(ANumChars);
       Result.a[2] := (DECODE_TABLE[AInputBuffer[2]] shl 6) or DECODE_TABLE[AInputBuffer[3]];
     end;
   end;

  var
   I, J, K: Integer;
   LPacket: TPacket;
   LLen: Integer;
  begin
   SetLength(Result, Length(AInput) div 4 * 3);
   LLen := 0;
   for I := 1 to Length(AInput) div 4 do
   begin
     LPacket := DecodePacket(PChar(@AInput[(I - 1) * 4 + 1]), J);
     K := 0;
     while J > 0 do
     begin
       Result[LLen] := LPacket.a[K];
       Inc(LLen);
       Inc(K);
       Dec(J);
     end;
   end;
   SetLength(Result, LLen);
  end;

  function EncodeBase64(const AInput: TRESTDWBytes): string;
  const
   ENCODE_TABLE: array[0..63] of Char =
     'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
     'abcdefghijklmnopqrstuvwxyz' +
     '0123456789+/';

   procedure EncodePacket(const APacket: TPacket; ANumChars: Integer; AOutBuffer: PChar);
   begin
     AOutBuffer[0] := ENCODE_TABLE[APacket.a[0] shr 2];
     AOutBuffer[1] := ENCODE_TABLE[((APacket.a[0] shl 4) or (APacket.a[1] shr 4)) and $0000003f];

     if ANumChars < 2 then
       AOutBuffer[2] := '='
     else
       AOutBuffer[2] := ENCODE_TABLE[((APacket.a[1] shl 2) or (APacket.a[2] shr 6)) and $0000003f];

     if ANumChars < 3 then
       AOutBuffer[3] := '='
     else
       AOutBuffer[3] := ENCODE_TABLE[APacket.a[2] and $0000003f];
   end;

  var
   I, K, J: Integer;
   LPacket: TPacket;
  begin
   Result := '';
   I := (Length(AInput) div 3) * 4;
   if Length(AInput) mod 3 > 0 then
     Inc(I, 4);
   SetLength(Result, I);
   J := 1;
   for I := 1 to Length(AInput) div 3 do
   begin
     LPacket.i := 0;
     LPacket.a[0] := AInput[(I - 1) * 3];
     LPacket.a[1] := AInput[(I - 1) * 3 + 1];
     LPacket.a[2] := AInput[(I - 1) * 3 + 2];
     EncodePacket(LPacket, 3, PChar(@Result[J]));
     Inc(J, 4);
   end;
   K := 0;
   LPacket.i := 0;
   for I := Length(AInput) - (Length(AInput) mod 3) + 1 to Length(AInput) do
   begin
     LPacket.a[K] := Byte(AInput[I - 1]);
     Inc(K);
     if I = Length(AInput) then
       EncodePacket(LPacket, Length(AInput) mod 3, PChar(@Result[J]));
   end;
  end;
{$IFEND}

{ TRESTDWBase64 }

class function TRESTDWBase64.Decode(const ASource: TRESTDWBytes): TRESTDWBytes;
begin
  {$IFDEF DELPHIXE7UP}
  Result := TRESTDWBytes(TNetEncoding.Base64.Decode(TBytes(ASource)));
  {$ELSE}
  Result := DecodeBase64(BytesToString(ASource));
  {$ENDIF}
end;

class function TRESTDWBase64.Encode(const ASource: TRESTDWBytes): TRESTDWBytes;
begin
  {$IF Defined(RESTDWLAZARUS)}
  Result := StringToBytes(EncodeStrings(BytesToString(ASource), csUndefined));
  {$ELSEIF Defined(DELPHIXE7UP)}
  Result := TRESTDWBytes(TNetEncoding.Base64.Encode(TBytes(ASource)));
  {$ELSE}
  Result := StringToBytes(EncodeBase64(ASource));
  {$IFEND}
end;

class function TRESTDWBase64.URLDecode(const ASource: TRESTDWBytes): TRESTDWBytes;
var
  LBase64Str : String;
begin
  LBase64Str := BytesToString(ASource);
  LBase64Str := LBase64Str + StringOfChar('=', (4 - Length(ASource) mod 4) mod 4);
  LBase64Str := StringReplace(LBase64Str, '-', '+', [rfReplaceAll]);
  LBase64Str := StringReplace(LBase64Str, '_', '/', [rfReplaceAll]);
  Result := TRESTDWBase64.Decode(ToBytes(LBase64Str));
end;

class function TRESTDWBase64.URLEncode(const ASource: TRESTDWBytes): TRESTDWBytes;
var
  LBase64Str: string;
begin
  LBase64Str := BytesToString(TRESTDWBase64.Encode(ASource));

  LBase64Str := StringReplace(LBase64Str, #13#10, '', [rfReplaceAll]);
  LBase64Str := StringReplace(LBase64Str, #13, '', [rfReplaceAll]);
  LBase64Str := StringReplace(LBase64Str, #10, '', [rfReplaceAll]);
//  LBase64Str := LBase64Str.TrimRight(['=']);
  LBase64Str := StringReplace(LBase64Str, ' ', '=', [rfReplaceAll]);

  LBase64Str := StringReplace(LBase64Str, '+', '-', [rfReplaceAll]);
  LBase64Str := StringReplace(LBase64Str, '/', '_', [rfReplaceAll]);

  Result := ToBytes(LBase64Str);
end;

end.
