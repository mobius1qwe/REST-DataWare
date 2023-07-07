unit uRESTDWAttachmentFile;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 Classes,
 uRESTDWAttachment, uRESTDWMessageParts, uRESTDWTools, uRESTDWMimeTypes;

 Type
  TRESTDWAttachmentFile = Class(TRESTDWAttachment)
 Protected
  FTempFileStream: TFileStream;
  FStoredPathName: String;
  FFileIsTempFile: Boolean;
  FAttachmentBlocked: Boolean;
 Public
  Constructor Create(aCollection     : TRESTDWMessageParts;
                     Const AFileName : String = ''); Reintroduce;
  Destructor  Destroy; Override;
  Function    OpenLoadStream    : TStream; Override;
  Procedure   CloseLoadStream;             Override;
  Function    PrepareTempStream : TStream; Override;
  Procedure   FinishTempStream;            Override;
  Procedure   SaveToFile(Const aFileName : String); Override;
  Property    FileIsTempFile    : Boolean Read FFileIsTempFile    Write FFileIsTempFile;
  Property    StoredPathName    : String  Read FStoredPathName    Write FStoredPathName;
  Property    AttachmentBlocked : Boolean Read FAttachmentBlocked;
 End;

Implementation

Uses
//  {$IFDEF USE_VCL_POSIX}
//  Posix.Unistd,
//  {$ENDIF}
//  {$IFDEF WINDOWS}
//   Windows,
//  {$ENDIF}
  uRESTDWException,
  uRESTDWMessage,
  uRESTDWConsts,
  uRESTDWBasicTypes,
  SysUtils;

Procedure TRESTDWAttachmentFile.CloseLoadStream;
Begin
 FreeAndNil(FTempFileStream);
End;

Constructor TRESTDWAttachmentFile.Create(aCollection      : TRESTDWMessageParts;
                                         Const AFileName : String = '');
Begin
 Inherited Create(aCollection);
 FFilename := ExtractFileName(AFilename);
 FTempFileStream := nil;
 FStoredPathName := AFileName;
 FFileIsTempFile := False;
 If FFilename <> '' Then
  ContentType := TRESTDWMimeType.GetMIMEType(FFilename);
End;

Destructor TRESTDWAttachmentFile.Destroy;
Begin
 If FileIsTempFile Then
  SysUtils.DeleteFile(StoredPathName);
 Inherited Destroy;
End;

Procedure TRESTDWAttachmentFile.FinishTempStream;
Var
 LMsg : TRESTDWMessage;
Begin
 FreeAndNil(FTempFileStream);
 FAttachmentBlocked := Not FileExists(StoredPathName);
 If FAttachmentBlocked Then
  Begin
   LMsg := TRESTDWMessage(OwnerMessage);
   If Assigned(LMsg) And
     (Not LMsg.ExceptionOnBlockedAttachments) Then
    Exit;
   Raise eRESTDWMessageCannotLoad.CreateFmt(cMessageErrorAttachmentBlocked, [StoredPathName]);
  End;
end;

function TRESTDWAttachmentFile.OpenLoadStream: TStream;
begin
  FTempFileStream := TRESTDWReadFileExclusiveStream.Create(StoredPathName);
  Result := FTempFileStream;
end;

function TRESTDWAttachmentFile.PrepareTempStream: TStream;
var
  LMsg: TRESTDWMessage;
begin
  LMsg := TRESTDWMessage(OwnerMessage);
  if Assigned(LMsg) then begin
    FStoredPathName := MakeTempFilename(LMsg.AttachmentTempDirectory);
  end else begin
    FStoredPathName := MakeTempFilename;
  end;
  FTempFileStream := TRESTDWFileCreateStream.Create(FStoredPathName);
  FFileIsTempFile := True;
  Result := FTempFileStream;
end;

procedure TRESTDWAttachmentFile.SaveToFile(const aFileName: String);
Begin
 If Not CopyFileTo(StoredPathname, aFileName) Then
  Raise eRESTDWException.Create(cMessageErrorSavingAttachment);
End;

Initialization
//  MtW: Shouldn't be neccessary??
//  RegisterClass(TRESTDWAttachmentFile);

End.
