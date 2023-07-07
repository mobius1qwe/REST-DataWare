unit uRESTDWMessageCoderQuotedPrintable;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 Classes,
 uRESTDWMessageCoder,
 uRESTDWMessage;

 Type
  TRESTDWMessageEncoderQuotedPrintable    = Class(TRESTDWMessageEncoder)
 Public
  Procedure Encode(ASrc  : TStream;
                   ADest : TStream); Override;
 End;
 TRESTDWMessageEncoderInfoQuotedPrintable = Class(TRESTDWMessageEncoderInfo)
 Public
  Constructor Create; Override;
 End;

Implementation

Uses
  uRESTDWCoder, uRESTDWCoderMIME, uRESTDWCoderQuotedPrintable, uRESTDWException, SysUtils;

Constructor TRESTDWMessageEncoderInfoQuotedPrintable.Create;
Begin
 Inherited;
 FMessageEncoderClass := TRESTDWMessageEncoderQuotedPrintable;
End;

Procedure TRESTDWMessageEncoderQuotedPrintable.Encode(ASrc: TStream; ADest: TStream);
Var
 LEncoder : TRESTDWEncoderQuotedPrintable;
Begin
 LEncoder := TRESTDWEncoderQuotedPrintable.Create(Nil);
 Try
  LEncoder.Encode(ASrc, ADest);
 Finally
  FreeAndNil(LEncoder);
 End;
End;

Initialization
 TRESTDWMessageEncoderList.RegisterEncoder('QP', TRESTDWMessageEncoderInfoQuotedPrintable.Create);    {Do not Localize}

End.
