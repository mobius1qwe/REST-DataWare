Unit uRESTDWAttachment;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 Classes,
 uRESTDWMessageParts;

 Type
  TRESTDWAttachment = Class(TRESTDWMessagePart)
 Public
  Function  OpenLoadStream    : TStream; Virtual; Abstract;
  Procedure CloseLoadStream;             Virtual; Abstract;
  Function  PrepareTempStream : TStream; Virtual; Abstract;
  Procedure FinishTempStream;            Virtual; Abstract;
  Procedure LoadFromFile(Const aFileName : String); Virtual;
  Procedure LoadFromStream(AStream: TStream);      Virtual;
  Procedure SaveToFile  (Const aFileName : String); Virtual;
  Procedure SaveToStream(AStream : TStream);       Virtual;
  Class Function PartType : TRESTDWMessagePartType; Override;
 End;
 TRESTDWAttachmentClass = Class Of TRESTDWAttachment;

Implementation

Uses
 uRESTDWBasicTypes, uRESTDWTools, uRESTDWConsts, SysUtils;

Class Function TRESTDWAttachment.PartType: TRESTDWMessagePartType;
Begin
 Result := mptAttachment;
End;

Procedure TRESTDWAttachment.LoadFromFile(const aFileName: String);
Var
 LStrm : TRESTDWReadFileExclusiveStream;
Begin
 LStrm := TRESTDWReadFileExclusiveStream.Create(aFileName);
 Try
  LoadFromStream(LStrm);
 Finally
  FreeAndNil(LStrm);
 End;
End;

Procedure TRESTDWAttachment.LoadFromStream(AStream: TStream);
Var
 LStrm : TStream;
Begin
 LStrm := PrepareTempStream;
 Try
  LStrm.CopyFrom(AStream, 0);
 Finally
  FinishTempStream;
 End;
End;

Procedure TRESTDWAttachment.SaveToFile(const aFileName: String);
Var
 LStrm : TRESTDWFileCreateStream;
Begin
 LStrm := TRESTDWFileCreateStream.Create(aFileName);
 Try
  SaveToStream(LStrm);
 Finally
  FreeAndNil(LStrm);
 End;
End;

Procedure TRESTDWAttachment.SaveToStream(AStream: TStream);
Var
 LStrm : TStream;
Begin
 LStrm := OpenLoadStream;
 Try
  AStream.CopyFrom(LStrm, 0);
 Finally
  CloseLoadStream;
 End;
End;

End.

