unit uRESTDWCoder;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

uses
  Classes, uRESTDWAbout, uRESTDWProtoTypes, uRESTDWTools;

 Type
  TRESTDWEncoder = Class(TRESTDWComponent)
 Public
  Function  Encode(Const AIn    : String) : String; Overload;
  Procedure Encode(Const AIn    : String;
                   ADestStrings : TStrings); Overload;
  Procedure Encode(Const AIn    : String;
                   ADestStream  : TStream);  Overload;
  Function  Encode(ASrcStream   : TStream;
                   Const ABytes : Integer = -1) : String; Overload;
  Procedure Encode(ASrcStream   : TStream;
                   ADestStrings : TStrings;
                   Const ABytes : Integer = -1); Overload;
  Procedure Encode(ASrcStream   : TStream;
                   ADestStream  : TStream;
                   Const ABytes : Integer = -1); Overload; Virtual; Abstract;
  Class Function  EncodeString(Const AIn    : String) : String; Overload;
  Class Procedure EncodeString(Const AIn    : String;
                               ADestStrings : TStrings); Overload;
  Class Procedure EncodeString(Const AIn    : String;
                               ADestStream  : TStream);  Overload;
  Class Function  EncodeBytes (Const ABytes : TRESTDWBytes) : String; Overload;
  Class Procedure EncodeBytes (Const ABytes : TRESTDWBytes;
                               ADestStrings : TStrings); Overload;
  Class Procedure EncodeBytes (Const ABytes : TRESTDWBytes;
                               ADestStream  : TStream); Overload;
  Class Function  EncodeStream(ASrcStream   : TStream;
                               Const ABytes : Integer = -1): String; Overload;
  Class Procedure EncodeStream(ASrcStream   : TStream;
                               ADestStrings : TStrings;
                               Const ABytes : Integer = -1); Overload;
  Class Procedure EncodeStream(ASrcStream   : TStream;
                               ADestStream  : TStream;
                               Const ABytes : Integer = -1); Overload;
 End;
 TRESTDWEncoderClass = Class of TRESTDWEncoder;
 TRESTDWDecoder      = Class(TRESTDWComponent)
 Protected
  FStream : TStream;
 Public
  Procedure DecodeBegin(ADestStream : TStream); Virtual;
  Procedure DecodeEnd; Virtual;
  Procedure Decode(Const AIn    : String); Overload;
  Procedure Decode(ASrcStream   : TStream;
                   Const ABytes : Integer = -1); Overload; Virtual; Abstract;
  Class Function DecodeString (Const AIn   : String) : String;
  Class Function DecodeBytes  (Const AIn   : String) : TRESTDWBytes;
  Class procedure DecodeStream(Const AIn   : String;
                               ADestStream : TStream);
 End;
 TRESTDWDecoderClass = Class Of TRESTDWDecoder;

Implementation

Uses
 SysUtils;

{ TRESTDWDecoder }

Procedure TRESTDWDecoder.DecodeBegin(ADestStream: TStream);
Begin
 FStream := ADestStream;
End;

Procedure TRESTDWDecoder.DecodeEnd;
Begin
 FStream := nil;
End;

Procedure TRESTDWDecoder.Decode(Const AIn : String);
Var
 LStream   : TMemoryStream;
Begin
 LStream := TMemoryStream.Create;
 Try
  WriteStringToStream(LStream, AIn, -1, 1);
  LStream.Position := 0;
  Decode(LStream);
 Finally
  FreeAndNil(LStream);
 End;
End;

Class Function TRESTDWDecoder.DecodeString(Const AIn : String) : String;
Var
 LStream : TMemoryStream;
Begin
 LStream := TMemoryStream.Create;
 Try
  DecodeStream(AIn, LStream);
  LStream.Position := 0;
  Result := ReadStringFromStream(LStream, -1);
 Finally
  FreeAndNil(LStream);
 End;
End;

Class Function TRESTDWDecoder.DecodeBytes(const AIn : String) : TRESTDWBytes;
Var
 LStream : TMemoryStream;
Begin
 Result := nil;
 LStream := TMemoryStream.Create;
 Try
  DecodeStream(AIn, LStream);
  LStream.Position := 0;
  ReadBytesFromStream(LStream, Result, -1);
 Finally
  FreeAndNil(LStream);
 End;
End;

Class Procedure TRESTDWDecoder.DecodeStream(Const AIn   : String;
                                            ADestStream : TStream);
Var
 LDecoder : TRESTDWDecoder;
Begin
 LDecoder := Create(nil);
 Try
  LDecoder.DecodeBegin(ADestStream);
  Try
   LDecoder.Decode(AIn);
  Finally
   LDecoder.DecodeEnd;
  End;
 Finally
  FreeAndNil(LDecoder);
 End;
End;

Function TRESTDWEncoder.Encode(Const AIn : String) : String;
Var
 LStream : TMemoryStream;
Begin
 If AIn <> '' Then
  Begin
   LStream := TMemoryStream.Create;
   Try
    WriteStringToStream(LStream, AIn, -1, 1);
    LStream.Position := 0;
    Result := Encode(LStream);
   Finally
    FreeAndNil(LStream);
   End;
  End
 Else
  Result := '';
End;

Procedure TRESTDWEncoder.Encode(Const AIn    : String;
                                ADestStrings : TStrings);
Var
 LStream : TMemoryStream;
Begin
 LStream := TMemoryStream.Create;
 Try
  WriteStringToStream(LStream, AIn, -1, 1);
  LStream.Position := 0;
  Encode(LStream, ADestStrings);
 Finally
  FreeAndNil(LStream);
 End;
End;

Procedure TRESTDWEncoder.Encode(Const AIn   : String;
                                ADestStream : TStream);
Var
 LStream : TMemoryStream;
Begin
 LStream := TMemoryStream.Create;
 Try
  WriteStringToStream(LStream, AIn, -1, 1);
  LStream.Position := 0;
  Encode(LStream, ADestStream);
 Finally
  FreeAndNil(LStream);
 End;
End;

Function TRESTDWEncoder.Encode(ASrcStream   : TStream;
                               Const ABytes : Integer = -1) : String;
Var
 LStream : TMemoryStream;
Begin
 LStream := TMemoryStream.Create;
 Try
  Encode(ASrcStream, LStream, ABytes);
  LStream.Position := 0;
  Result := ReadStringFromStream(LStream, -1);
 Finally
  FreeAndNil(LStream);
 End;
End;

Procedure TRESTDWEncoder.Encode(ASrcStream   : TStream;
                                ADestStrings : TStrings;
                                Const ABytes : Integer = -1);
Var
 LStream : TMemoryStream;
Begin
 ADestStrings.Clear;
 LStream := TMemoryStream.Create;
 Try
  Encode(ASrcStream, LStream, ABytes);
  LStream.Position := 0;
  ADestStrings.LoadFromStream(LStream);
 Finally
  FreeAndNil(LStream);
 End;
End;

Class Function TRESTDWEncoder.EncodeString(Const AIn : String) : String;
Var
 LEncoder : TRESTDWEncoder;
Begin
 LEncoder := Create(nil);
 Try
  Result := LEncoder.Encode(AIn);
 Finally
  FreeAndNil(LEncoder);
 End;
End;

Class Procedure TRESTDWEncoder.EncodeString(Const AIn    : String;
                                            ADestStrings : TStrings);
Var
 LEncoder : TRESTDWEncoder;
Begin
 LEncoder := Create(nil);
 Try
  LEncoder.Encode(AIn, ADestStrings);
 Finally
  FreeAndNil(LEncoder);
 End;
End;

Class Procedure TRESTDWEncoder.EncodeString(Const AIn   : String;
                                            ADestStream : TStream);
Var
 LEncoder: TRESTDWEncoder;
Begin
 LEncoder := Create(nil);
 Try
  LEncoder.Encode(AIn, ADestStream);
 Finally
  FreeAndNil(LEncoder);
 End;
end;

Class Function TRESTDWEncoder.EncodeBytes(Const ABytes : TRESTDWBytes) : String;
Var
 LStream : TMemoryStream;
Begin
 If ABytes <> Nil Then
  Begin
   LStream := TMemoryStream.Create;
   Try
    WriteBytesToStream(LStream, ABytes);
    LStream.Position := 0;
    Result := EncodeStream(LStream);
   Finally
    FreeAndNil(LStream);
   End;
  End
 Else
  Result := '';
End;

Class Procedure TRESTDWEncoder.EncodeBytes(Const ABytes : TRESTDWBytes;
                                           ADestStrings : TStrings);
Var
 LStream : TMemoryStream;
Begin
 If ABytes <> Nil Then
  Begin
   LStream := TMemoryStream.Create;
   Try
    WriteBytesToStream(LStream, ABytes);
    LStream.Position := 0;
    EncodeStream(LStream, ADestStrings);
   Finally
    FreeAndNil(LStream);
   End;
  End;
End;

Class Procedure TRESTDWEncoder.EncodeBytes(Const ABytes : TRESTDWBytes;
                                           ADestStream  : TStream);
Var
 LStream : TMemoryStream;
Begin
 If ABytes <> Nil Then
  Begin
   LStream := TMemoryStream.Create;
   Try
    WriteBytesToStream(LStream, ABytes);
    LStream.Position := 0;
    EncodeStream(LStream, ADestStream);
   Finally
    FreeAndNil(LStream);
   End;
  End;
End;

Class Function TRESTDWEncoder.EncodeStream(ASrcStream   : TStream;
                                           Const ABytes : Integer = -1) : String;
Var
 LEncoder : TRESTDWEncoder;
Begin
 If ASrcStream <> Nil Then
  Begin
   LEncoder := Create(nil);
   Try
    Result := LEncoder.Encode(ASrcStream, ABytes);
   Finally
    FreeAndNil(LEncoder);
   End;
  End
 Else
  Result := '';
End;

Class Procedure TRESTDWEncoder.EncodeStream(ASrcStream   : TStream;
                                            ADestStrings : TStrings;
                                            Const ABytes : Integer = -1);
Var
 LEncoder : TRESTDWEncoder;
Begin
 If ASrcStream <> Nil Then
  Begin
   LEncoder := Create(nil);
   Try
    LEncoder.Encode(ASrcStream, ADestStrings, ABytes);
   Finally
    FreeAndNil(LEncoder);
   End;
  End;
End;

Class Procedure TRESTDWEncoder.EncodeStream(ASrcStream   : TStream;
                                            ADestStream  : TStream;
                                            Const ABytes : Integer = -1);
Var
 LEncoder: TRESTDWEncoder;
Begin
 If ASrcStream <> Nil Then
  Begin
   LEncoder := Create(nil);
   Try
    LEncoder.Encode(ASrcStream, ADestStream, ABytes);
   Finally
    FreeAndNil(LEncoder);
   End;
  End;
End;

End.


