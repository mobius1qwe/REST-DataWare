unit uRESTDWCoderBinHex4;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 Classes, SysUtils, uRESTDWException, uRESTDWCoder, uRESTDWCoder3to4, uRESTDWTools,
 uRESTDWBasicTypes, uRESTDWProtoTypes;

 Type
  TRESTDWEncoderBinHex4 = Class(TRESTDWEncoder3to4)
 Protected
  FFileName : String;
  Function  GetCRC(Const ABlock  : TRESTDWBytes;
                   Const AOffset : Integer = 0;
                   Const ASize   : Integer = -1) : Word;
  Procedure AddByteCRC(Var ACRC  : Word;
                       AByte     : Byte);
 Public
  Constructor Create(AOwner       : TComponent); Reintroduce; Overload;
  Procedure   Encode(ASrcStream   : TStream;
                     ADestStream  : TStream;
                     Const ABytes : Integer = -1); override;
  property    FileName            : String Read FFileName Write FFileName;
 End;
 TRESTDWDecoderBinHex4 = Class(TRESTDWDecoder4to3)
 Protected
 Public
  Constructor Create(AOwner       : TComponent); Reintroduce; overload;
  Procedure   Decode(ASrcStream   : TStream;
                     Const ABytes : Integer = -1); override;
 End;

Const
 GBinHex4CodeTable            : String = '!"#$%&''()*+,-012345689@ABCDEFGHIJKLMNPQRSTUVXYZ[`abcdefhijklmpqr';
 GBinHex4IdentificationString : String = '(This file must be converted with BinHex 4.0)';

Type
 eRESTDWMissingColon    = Class(eRESTDWException);
 eRESTDWMissingFileName = Class(eRESTDWException);

Var
 GBinHex4DecodeTable : TRESTDWDecodeTable;

Implementation

Constructor TRESTDWDecoderBinHex4.Create(AOwner: TComponent);
Begin
 Inherited Create(AOwner);
 FDecodeTable := GBinHex4DecodeTable;
 FCodingTable := ToBytes(GBinHex4CodeTable);
 FFillChar := '=';  {Do not Localize}
End;

Procedure TRESTDWDecoderBinHex4.Decode(ASrcStream   : TStream;
                                       Const ABytes : Integer = -1);
Var
 LCopyToPos,
 LN,
 LRepetition,
 LForkLength,
 LInSize     : Integer;
 LIn,
 LOut        : TRESTDWBytes;
Begin
 LInSize := restdwLength(ASrcStream, ABytes);
 If LInSize <= 0 Then
  Exit;
 SetLength(LIn, LInSize);
 TRESTDWStreamHelper.ReadBytes(ASrcStream, LIn, LInSize);
 LCopyToPos := -1;
 For LN := 0 To LInSize-1 Do
  Begin
   If LIn[LN] = 58 Then
    Begin
     If LCopyToPos = -1 Then
      LCopyToPos := 0
     Else
      Begin
       SetLength(LIn, LCopyToPos);
       LCopyToPos := -2;
       Break;
      End;
    End
   Else
    Begin
     If (LCopyToPos > -1)          And
        (Not ByteIsInEOL(LIn, LN)) Then
      Begin
       LIn[LCopyToPos] := LIn[LN];
       Inc(LCopyToPos);
      End;
    End;
  End;
 If LCopyToPos = -1  Then
  Raise eRESTDWMissingColon.Create('Block passed to TRESTDWDecoderBinHex4.Decode is missing a starting colon :');    {Do not Localize}
 If LCopyToPos <> -2 Then
  Raise eRESTDWMissingColon.Create('Block passed to TRESTDWDecoderBinHex4.Decode is missing a terminating colon :'); {Do not Localize}
 If restdwLength(LIn) = 0  Then
  Exit;
 LOut := InternalDecode(LIn);
 LN := 0;
 While LN < restdwLength(LOut) Do
  Begin
   If LOut[LN] = $90 Then
    Begin
     LRepetition   := LOut[LN+1];
     If LRepetition = 0 Then
      Begin
       RemoveBytes(LOut, LN+1, 1);
       Inc(LN);  //Move past the $90
      End
     Else If LRepetition = 1 Then
      RemoveBytes(LOut, LN, 2)
     Else If LRepetition = 2 Then
      Begin
       LOut[LN] := LOut[LN-1];
       RemoveBytes(LOut, LN+1, 1);
       Inc(LN);
      End
     Else If LRepetition = 3 Then
      Begin
       LOut[LN] := LOut[LN-1];
       LOut[LN+1] := LOut[LN-1];
       Inc(LN, 2);
      End
     Else
      Begin
       LOut[LN] := LOut[LN-1];
       LOut[LN+1] := LOut[LN-1];
       ExpandBytes(LOut, LN+2, LRepetition-2, LOut[LN-1]);
       Inc(LN, LRepetition-1);
      End;
    End
   Else
    Inc(LN);
  End;
 LN := 1 + LOut[0];
 Inc(LN, 1 + 4 + 4 + 2);
 LForkLength := (((((LOut[LN]*256)+LOut[LN+1])*256)+LOut[LN+2])*256)+LOut[LN+3];
 Inc(LN, 4);
 If LForkLength = 0 Then
  LForkLength := (((((LOut[LN]*256)+LOut[LN+1])*256)+LOut[LN+2])*256)+LOut[LN+3];
 Inc(LN, 4);
 Inc(LN, 2);
 If Assigned(FStream) Then
  TRESTDWStreamHelper.Write(FStream, LOut, LForkLength, LN);
End;

Constructor TRESTDWEncoderBinHex4.Create(AOwner: TComponent);
Begin
 Inherited Create(AOwner);
 FCodingTable := ToBytes(GBinHex4CodeTable);
 FFillChar := '=';   {Do not Localize}
End;

Function TRESTDWEncoderBinHex4.GetCRC(Const ABlock  : TRESTDWBytes;
                                      Const AOffset : Integer = 0;
                                      Const ASize   : Integer = -1) : Word;
Var
 LN,
 LActual : Integer;
Begin
 Result := 0;
 LActual := restdwLength(ABlock, ASize, AOffset);
 If LActual > 0 Then
  Begin
   For LN := 0 To LActual-1 Do
    AddByteCRC(Result, ABlock[AOffset+LN]);
  End;
End;

Procedure TRESTDWEncoderBinHex4.AddByteCRC(Var ACRC : Word;
                                           AByte    : Byte);
Var
 LWillShiftedOutBitBeA1 : Boolean;
 LN                     : Integer;
Begin
 For LN := 1 To 8 Do
  Begin
   LWillShiftedOutBitBeA1 := (ACRC And $8000) <> 0;
   ACRC := (ACRC  Shl 1) Or
           (AByte Shr 7);
   If LWillShiftedOutBitBeA1 Then
    ACRC := ACRC xor $1021;
   AByte := (AByte shl 1) and $FF;
  End;
End;

Procedure TRESTDWEncoderBinHex4.Encode(ASrcStream   : TStream;
                                       ADestStream  : TStream;
                                       Const ABytes : Integer = -1);
Var
 LN,
 LOffset,
 LBlocks,
 LRemainder,
 LSSize,
 LTemp       : Integer;
 LOut        : TRESTDWBytes;
 LFileName   : {$IFDEF HAS_AnsiString}AnsiString{$ELSE}TRESTDWBytes{$ENDIF};
 LCRC        : word;
Begin
 If FFileName = '' Then
  Raise eRESTDWMissingFileName.Create('Data passed to TRESTDWEncoderBinHex4.Encode is missing a filename');    {Do not Localize}
 LSSize := restdwLength(ASrcStream, ABytes);
 {$IFNDEF HAS_AnsiString}
  LFileName := GetBytes(FFileName);
 {$ELSE}
  {$IFDEF STRING_IS_UNICODE}
   LFileName := AnsiString(FFileName); // explicit convert to Ansi
  {$ELSE}
    LFileName := FFileName;
  {$ENDIF}
 {$ENDIF}
 If Length(FFileName) > 255 Then
  SetLength(LFileName, 255);
 SetLength(LOut, 1+ restdwLength(LFileName)+1+4+4+2+4+4+2+LSSize+2);
 LOut[0]   := restdwLength(LFileName);
 For LN    := 1 To restdwLength(LFileName) Do
  LOut[LN] := {$IFNDEF HAS_AnsiString}LFileName[LN-1]{$ELSE}Byte(LFileName[LN]){$ENDIF};
 LOffset   := 1 + restdwLength(LFileName);             //Points to byte after filename
 LOut[LOffset] := 0;                         //Version
 Inc(LOffset);
 For LN := 0 to 7 Do
  LOut[LOffset+LN] := 32;                   //Use spaces for Type & Creator
 Inc(LOffset, 8);
 LOut[LOffset]     := 0;                         //Flags
 LOut[LOffset]     := 0;                         //Flags
 Inc(LOffset, 2);
 LTemp := LSSize;
 LOut[LOffset]     := LTemp mod 256;             //Length of data fork
 LTemp             := LTemp div 256;
 LOut[LOffset+1]   := LTemp mod 256;           //Length of data fork
 LTemp             := LTemp div 256;
 LOut[LOffset+2]   := LTemp mod 256;           //Length of data fork
 LTemp             := LTemp div 256;
 LOut[LOffset+3]   := LTemp;                   //Length of data fork
 Inc(LOffset, 4);
 LOut[LOffset]     := 0;                         //Length of resource fork
 LOut[LOffset+1]   := 0;                       //Length of resource fork
 LOut[LOffset+2]   := 0;                       //Length of resource fork
 LOut[LOffset+3]   := 0;                       //Length of resource fork
 Inc(LOffset, 4);
 LCRC              := GetCRC(LOut, 0, LOffset);
 LOut[LOffset]     := LCRC mod 256;              //CRC of data fork
 LCRC              := LCRC div 256;
 LOut[LOffset+1]   := LCRC;                    //CRC of data fork
 Inc(LOffset, 2);
 TRESTDWStreamHelper.ReadBytes(ASrcStream, LOut, LSSize, LOffset);
 LCRC              := GetCRC(LOut, LOffset, LSSize);
 Inc(LOffset, LSSize);
 LOut[LOffset]     := LCRC mod 256;              //CRC of data fork
 LCRC              := LCRC div 256;
 LOut[LOffset+1]   := LCRC;                    //CRC of data fork
 Inc(LOffset, 2);
 LSSize            := LOffset mod 3;
 If LSSize > 0 Then
  ExpandBytes(LOut, LOffset, 3-LSSize);
 LOut := InternalEncode(LOut);
 InsertByte(LOut, 58, 0);
 AppendByte(LOut, 58);
 LN := 0;
 While LN < restdwLength(LOut) Do
  Begin
   If LOut[LN] = $90 Then
    Begin
     InsertByte(LOut, 0, LN+1);
     Inc(LN);
    End;
   Inc(LN);
  End;
 WriteStringToStream(ADestStream, GBinHex4IdentificationString + EOL, -1, 1);
 LBlocks := restdwLength(LOut) div 64;
 For LN := 0 to LBlocks-1 Do
  Begin
   TRESTDWStreamHelper.Write(ADestStream, LOut, 64, LN*64);
   WriteStringToStream(ADestStream, EOL, -1, 1);
  End;
 LRemainder := restdwLength(LOut) mod 64;
 If LRemainder > 0 Then
  Begin
   TRESTDWStreamHelper.Write(ADestStream, LOut, LRemainder, LBlocks*64);
   WriteStringToStream(ADestStream, EOL, -1, 1);
  End;
End;

Initialization
  TRESTDWDecoder4to3.ConstructDecodeTable(GBinHex4CodeTable, GBinHex4DecodeTable);
end.

