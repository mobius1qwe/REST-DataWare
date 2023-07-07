unit uRESTDWMessageCoderBinHex4;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

uses
  Classes,
  uRESTDWMessageCoder,
  uRESTDWMessage;

 Type
  TRESTDWMessageEncoderBinHex4 = Class(TRESTDWMessageEncoder)
 Public
  Procedure Encode(ASrc  : TStream;
                   ADest : TStream); Override;
 End;
 TRESTDWMessageEncoderInfoBinHex4 = class(TRESTDWMessageEncoderInfo)
 Public
  Constructor Create; Override;
 End;

Implementation

Uses
 uRESTDWCoder, uRESTDWCoderBinHex4, SysUtils;

Constructor TRESTDWMessageEncoderInfoBinHex4.Create;
Begin
 Inherited;
 FMessageEncoderClass := TRESTDWMessageEncoderBinHex4;
End;

Procedure TRESTDWMessageEncoderBinHex4.Encode(ASrc  : TStream;
                                              ADest : TStream);
Var
 LEncoder : TRESTDWEncoderBinHex4;
Begin
 LEncoder := TRESTDWEncoderBinHex4.Create(Nil);
 Try
  LEncoder.FileName := FileName;
  LEncoder.Encode(ASrc, ADest);
 Finally
  FreeAndNil(LEncoder);
 End;
End;

Initialization
 TRESTDWMessageEncoderList.RegisterEncoder('binhex4', TRESTDWMessageEncoderInfoBinHex4.Create);    {Do not Localize}

End.
