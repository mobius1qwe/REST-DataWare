unit uRESTDWFileBuffer;

{$I ..\..\Source\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

uses
  SysUtils, Types, Variants, Classes,
  uRESTDWConsts, uRESTDWDynamic, uRESTDWTools, uRESTDWProtoTypes, uRESTDWAbout;

Const
 cFinalLine      = #10;
 {$IFDEF RESTDWWINDOWS}
 cFinalReturn  = #13;
 {$ENDIF}
 cBufferSize     = 1024;

Type
 TRESTDWFileMode  = (rdwFileCreate          = fmCreate,
                     rdwFileCreateExclusive = fmCreate        Or
                                              fmOpenReadWrite Or
                                              fmShareDenyWrite,
                     rdwOpenExclusive       = fmOpenRead      Or
                                              fmShareExclusive,
                     rdwOpenExclusiveWrite  = fmOpenReadWrite Or
                                              fmShareDenyWrite,
                     rdwOpen                = fmOpenReadWrite);
 TRESTDWStreamMode = (rdwFileStream, rdwMemoryStream);
 TClassArray       = Array of String;

Type
 TRESTDWStreamBuffer = Class(TRESTDWComponent)
Private
 vPosition          : DWBufferSize;
 vFileName          : String;
 vTempFile          : TFileStream;
 vTempStream        : TMemoryStream;
 vRESTDWFileMode    : TRESTDWFileMode;
 vBufferSize        : Integer;
 vRESTDWStreamMode  : TRESTDWStreamMode;
 vRewriteFile,
 vCreateDirectories : Boolean;
 vActualStream      : TStream;
 Procedure SetPosition(Position : DWBufferSize);
 Function  GetBof       : Boolean;
 Procedure SetBof(Value : Boolean);
 Function  GetEof       : Boolean;
 Procedure SetEof(Value : Boolean);
 Procedure SetStreamMode(Value  : TRESTDWStreamMode);
 Function  GetStreamObject      : TStream;
 Function  GetBufferSize        : DWBufferSize;
 Procedure CreateFile;
 Procedure CreateStream;
Public
 Constructor Create(AOwner  : TComponent);Override;
 Destructor  Destroy;Override;
 Procedure   NewBuff;
 Procedure   CloseFile;
 Procedure   WriteBuffer  (Const Buffer;
                           Size              : DWBufferSize);
 Procedure   WriteLn      (Value             : DWString);
 Function    ReadLn       (InitFile          : Boolean = False) : DWString;
 Procedure   ReadBuffer   (Var Buffer;
                           Size              : DWBufferSize);
 Procedure   ReadArray    (Var Buffer; ElementClassType : Pointer);
 Procedure   WriteArray   (Var Buffer; ElementClassType : Pointer);
 Class       Function StreamToFile (Stream : TStream; Filename : String) : Boolean;
 Property Bof               : Boolean           Read GetBof             Write SetBof;
 Property Eof               : Boolean           Read GetEof             Write SetEof;
 Property Size              : DWBufferSize      Read GetBufferSize;
 Property Stream            : TStream           Read GetStreamObject;
Published
 Property BufferSize        : Integer           Read vBufferSize        Write vBufferSize;
 Property StreamMode        : TRESTDWStreamMode Read vRESTDWStreamMode  Write SetStreamMode;
 Property CreateDirectories : Boolean           Read vCreateDirectories Write vCreateDirectories;
 Property FileName          : String            Read vFileName          Write vFileName;
 Property FileMode          : TRESTDWFileMode   Read vRESTDWFileMode    Write vRESTDWFileMode;
 Property RewriteFile       : Boolean           Read vRewriteFile       Write vRewriteFile;
 Property Position          : DWBufferSize      Read vPosition          Write SetPosition;
End;

implementation

{ TRESTDWStreamBuffer }

Procedure TRESTDWStreamBuffer.SetBof(Value : Boolean);
Begin
 If Value Then
  Begin
   vActualStream.Position := 0;
   vPosition          := vActualStream.Position;
  End;
End;

Function  TRESTDWStreamBuffer.GetBufferSize   : DWBufferSize;
Begin
 Result := -1;
 If Assigned(vActualStream) Then
  Result := vActualStream.Size;
End;

Function  TRESTDWStreamBuffer.GetStreamObject : TStream;
Begin
 Case vRESTDWStreamMode Of
  rdwFileStream   : Result := vTempFile;
  rdwMemoryStream : Result := vTempStream;
 End;
End;

Procedure TRESTDWStreamBuffer.SetStreamMode(Value : TRESTDWStreamMode);
Begin
 vRESTDWStreamMode := Value;
 Case vRESTDWStreamMode Of
  rdwFileStream   : CreateFile;
  rdwMemoryStream : CreateStream;
 End;
End;

Class Function TRESTDWStreamBuffer.StreamToFile(Stream   : TStream;
                                                Filename : String) : Boolean;
Var
 vTempFileA : TFileStream;
Begin
 Result := False;
 vTempFileA := Nil;
 If Assigned(Stream) Then
  Begin
   Try
    vTempFileA := TFileStream.Create(FileName, Integer(rdwFileCreateExclusive));
    Stream.Position := 0;
    vTempFileA.CopyFrom(Stream, Stream.Size);
    Result := True;
   Finally
    If Assigned(vTempFileA) Then
     FreeAndNil(vTempFileA);
   End;
  End;
End;

Procedure TRESTDWStreamBuffer.SetEof(Value: Boolean);
Begin
 If Value Then
  Begin
   vActualStream.Position := vActualStream.Size;
   vPosition              := vActualStream.Position;
  End;
End;

Procedure TRESTDWStreamBuffer.SetPosition(Position : DWBufferSize);
Begin
 If GetStreamObject <> Nil Then
  Begin
   If vActualStream.Size >= Position Then
    vActualStream.Position := Position
   Else
    Raise Exception.Create(cInvalidBufferPosition);
  End;
End;

Procedure TRESTDWStreamBuffer.NewBuff;
Begin
 Case vRESTDWStreamMode Of
  rdwFileStream   : CreateFile;
  rdwMemoryStream : CreateStream;
 End;
End;

Procedure TRESTDWStreamBuffer.CloseFile;
begin
 If Assigned(vTempFile) Then
  FreeAndNil(vTempFile);
 If Assigned(vTempStream) Then
  FreeAndNil(vTempStream);
 vPosition       := 0;
end;

Constructor TRESTDWStreamBuffer.Create(AOwner  : TComponent);
Begin
 Inherited;
 vRESTDWFileMode    := rdwFileCreate;
 vTempFile          := Nil;
 vTempStream        := Nil;
 vFileName          := '';
 vPosition          := 0;
 vBufferSize        := cBufferSize;
 vRESTDWStreamMode  := rdwFileStream;
 vCreateDirectories := False;
 vRewriteFile       := False;
End;

Procedure TRESTDWStreamBuffer.CreateStream;
Begin
 CloseFile;
 vTempStream          := TMemoryStream.Create;
 vTempStream.Position := 0;
 vPosition            := vTempStream.Position;
 vActualStream        := vTempStream;
End;

Procedure TRESTDWStreamBuffer.CreateFile;
Begin
 CloseFile;
 If vFileName <> '' Then
  Begin
   If vCreateDirectories Then
    Begin
     If Not DirectoryExists(ExtractFilePath(vFileName)) Then
      ForceDirectories(ExtractFilePath(vFileName));
    End;
   If vRewriteFile Then
    vTempFile          := TFileStream.Create(vFileName, Integer(rdwFileCreateExclusive))
   Else
    Begin
     If FileExists(vFileName) Then
      vTempFile        := TFileStream.Create(vFileName, Integer(fmOpenReadWrite))
     Else
      vTempFile        := TFileStream.Create(vFileName, Integer(rdwFileCreateExclusive));
    End;
   vTempFile.Position := 0;
   vPosition          := vTempFile.Position;
   vActualStream      := vTempFile;
  End;
End;

Destructor TRESTDWStreamBuffer.Destroy;
Begin
 CloseFile;
 Inherited;
End;

Function TRESTDWStreamBuffer.GetBof : Boolean;
Begin
 Result := (vActualStream.Position = 0) And
           (vActualStream.Size     > 0);
End;

Function TRESTDWStreamBuffer.GetEof: Boolean;
Begin
 Result := (vActualStream.Position = vActualStream.Size) And
           (vActualStream.Size     > 0);
End;

Procedure TRESTDWStreamBuffer.ReadArray(Var Buffer; ElementClassType : Pointer);
Begin
 Bof     := True;
 TRESTDWDynamic.ReadFrom(vActualStream, Pointer(Buffer), ElementClassType);
End;

Procedure TRESTDWStreamBuffer.WriteArray(Var Buffer; ElementClassType : Pointer);
Begin
 Bof := True;
 TRESTDWDynamic.WriteTo(vActualStream, Pointer(Buffer), ElementClassType);
End;

Procedure TRESTDWStreamBuffer.ReadBuffer(Var Buffer;
                                       Size : DWBufferSize);
Var
 vTempSize : DWBufferSize;
Begin
 Try
  If GetStreamObject = Nil Then
   Begin
    Raise Exception.Create(cCannotReadBuffer);
    Exit;
   End;
  vTempSize := Size;
  If vActualStream.Size < vTempSize Then
   vTempSize := vActualStream.Size;
  vActualStream.ReadBuffer(Buffer, vTempSize);
  vPosition := vActualStream.Position;
 Except
  Raise Exception.Create(cCannotReadBuffer);
 End;
End;

Procedure TRESTDWStreamBuffer.WriteBuffer(Const Buffer;
                                          Size : DWBufferSize);
Begin
 Try
  vActualStream.WriteBuffer(Buffer, Size);
  vPosition := vActualStream.Position;
 Except
  Raise Exception.Create(cCannotWriteBuffer);
 End;
End;

Function TRESTDWStreamBuffer.ReadLn(InitFile : Boolean = False) : DWString;
Var
 I, A, X      : Integer;
 vTempString  : DWString;
 vFinalLine   : Boolean;
 {$IFDEF RESTDWWINDOWS}
  vOldString  : DWString;
 {$ENDIF}
Begin
 vTempString  := '';
 Result       := '';
 vFinalLine   := False;
 Try
  If GetStreamObject = Nil Then
   Begin
    Raise Exception.Create(cCannotReadBuffer);
    Exit;
   End;
  If InitFile Then
   vActualStream.Position := 0;
  I := vActualStream.Position;
  A := 0;
  {$IFDEF RESTDWWINDOWS}
   vOldString := '';
  {$ENDIF}
  While I < vActualStream.Size -1 Do
   Begin
    If (I + vBufferSize) <= vActualStream.Size Then
     A := vBufferSize
    Else
     A := vActualStream.Size - I;
    SetLength(vTempString, A);
    vActualStream.ReadBuffer(Pointer(vTempString)^, A);
    For X := InitStrPos To Length(vTempString) - FinalStrPos Do
     Begin
      If (vTempString[X] = cFinalLine)
         {$IFDEF RESTDWWINDOWS} And (vOldString = cFinalReturn){$ENDIF} Then
       Begin
        {$IFDEF RESTDWWINDOWS}
         If Length(Result) > 0 Then
          If Result[Length(Result) - FinalStrPos] = cFinalReturn Then
           Delete(Result, Length(Result), 1);
        {$ENDIF}
        vFinalLine   := True;
        vTempString  := '';
        vActualStream.Position := I + X;
        Break;
       End;
      Result         := Result + vTempString[X];
      {$IFDEF RESTDWWINDOWS}
       vOldString    := vTempString[X];
      {$ENDIF}
     End;
    vTempString     := '';
    If (vFinalLine) Or
       (vActualStream.Position = vActualStream.Size) Then
     Break;
   End;
  vTempString       := '';
  {$IFDEF RESTDWWINDOWS}
   vOldString := '';
  {$ENDIF}
  vPosition := vActualStream.Position;
 Except
  Raise Exception.Create(cCannotReadBuffer);
 End;
End;

Procedure TRESTDWStreamBuffer.WriteLn  (Value : DWString);
Begin
 If Length(Value) >  0 Then
  Begin
   If Value[Length(Value) - FinalStrPos] <> sLineBreak Then
    Value := Value + sLineBreak;
   vActualStream.Write(Value[1], Length(Value));
   vPosition := vActualStream.Position;
  End;
End;

end.
