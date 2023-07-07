unit uRESTDWIOHandler;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 Classes, uRESTDWException, uRESTDWBuffer, uRESTDWProtoTypes, uRESTDWTools,
 uRESTDWAbout, uRESTDWConsts;

Const
 GRecvBufferSizeDefault  = 32 * 1024;
 GSendBufferSizeDefault  = 32 * 1024;
 rdwMaxLineLengthDefault = 16 * 1024;
 rdw_IOHandler_MaxCapturedLines = -1;

 Type
  eRESTDWIOHandler                    = Class(eRESTDWException);
  eRESTDWIOHandlerRequiresLargeStream = Class(eRESTDWIOHandler);
  eRESTDWIOHandlerStreamDataTooLarge  = Class(eRESTDWIOHandler);
  TRESTDWIOHandlerClass               = Class of TRESTDWIOHandler;
  TRESTDWIOHandler                    = class(TRESTDWComponent)
 Private
  FLargeStream,
  FReadLnTimedout,
  FClosedGracefully : Boolean;
  FReadTimeOut,
  FPort,
  FConnectTimeout   : Integer;
  FHost: string;
  Procedure Notification(AComponent: TComponent; Operation: TOperation);
 Protected
  FInputBuffer           : TRESTDWBuffer;
  FMaxCapturedLines,
  FMaxLineLength,
  FWriteBufferThreshold,
  FRecvBufferSize,
  FSendBufferSize        : Integer;
  FMaxLineAction         : TRESTDWMaxLineAction;
  FOpened,
  FReadLnSplit           : Boolean;
  FWriteBuffer           : TRESTDWBuffer;
  Function  WriteDataToTarget (Const ABuffer    : TRESTDWBytes;
                               Const AOffset,
                               ALength          : Integer)      : Integer; Virtual; Abstract;
  Function  SourceIsAvailable : Boolean; Virtual; Abstract;
  Function  CheckForError(ALastResult : Integer): Integer; Virtual; Abstract;
  Procedure RaiseError   (AError      : Integer);          Virtual; Abstract;
 Public
  Destructor Destroy; override;
  Constructor Create;
  Procedure Close; virtual;
  Class Function MakeDefaultIOHandler(AOwner    : TComponent = Nil) : TRESTDWIOHandler;
  Class Function MakeIOHandler       (ABaseType : TRESTDWIOHandlerClass;
                                      AOwner    : TComponent = Nil) : TRESTDWIOHandler;
  Class Function TryMakeIOHandler    (ABaseType : TRESTDWIOHandlerClass;
                                      AOwner    : TComponent = Nil) : TRESTDWIOHandler;
  Class procedure RegisterIOHandler;
  Class procedure SetDefaultClass;
  Procedure Open; virtual;
  Function  ReadLn   : String; Overload; // .Net overload
  Function  ReadLn     (ATerminator         : String) : String; Overload;
  Function  ReadLn     (ATerminator         : String;
                        ATimeout            : Integer = cTimeoutDefault;
                        AMaxLineLength      : Integer = -1) : String; Overload;
  Function  ReadLnRFC  (Var VMsgEnd         : Boolean): String; Overload;
  Function  ReadLnRFC  (Var VMsgEnd         : Boolean;
                        ALineTerminator     : String;
                        Const ADelim        : String = '.') : String; Overload;
  Function  ReadLnWait (AFailCount          : Integer = MaxInt): String; Virtual;
  Function  ReadLnSplit(Var AWasSplit       : Boolean;
                        ATerminator         : String = LF;
                        ATimeout            : Integer = cTimeoutDefault;
                        AMaxLineLength      : Integer = -1) : String;Overload;
  Function  ReadChar    : Char;
  Function  ReadByte    : Byte;
  Procedure ReadBytes   (Var VBuffer        : TRESTDWBytes;
                         AByteCount         : Integer;
                         AAppend            : Boolean = True);
  Function  ReadString  (ABytes     : Integer)        : String;
  Function  ReadInt16   (AConvert   : Boolean = True) : DWInt16;
  Function  ReadUInt16  (AConvert   : Boolean = True) : DWUInt16;
  Function  ReadInt32   (AConvert   : Boolean = True) : DWInt32;
  Function  ReadUInt32  (AConvert   : Boolean = True) : DWUInt32;
  Function  ReadInt64   (AConvert   : Boolean = True) : Int64;
  Function  ReadUInt64  (AConvert   : Boolean = True) : TRESTDWUInt64;
  Function  ReadSmallInt(AConvert   : Boolean = True) : DWInt16; {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use ReadInt16()'{$ENDIF};{$ENDIF}
  Function  ReadWord    (AConvert   : Boolean = True) : DWUInt16; {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use ReadUInt16()'{$ENDIF};{$ENDIF}
  Function  ReadLongInt (AConvert   : Boolean = True) : DWInt32;  {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use ReadInt32()'{$ENDIF};{$ENDIF}
  Function  ReadLongWord(AConvert   : Boolean = True) : DWUInt32; {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use ReadUInt32()'{$ENDIF};{$ENDIF}
  Procedure ReadStrings (ADest                : TStrings;
                         AReadLinesCount      : Integer = -1);
  Procedure WriteBufferCancel; Virtual;
  Procedure WriteBufferClear;  Virtual;
  Procedure WriteBufferClose;  Virtual;
  Procedure WriteBufferOpen  (AThreshold : Integer); Overload; Virtual;
  Function  InputBufferIsEmpty: Boolean;
  Procedure InputBufferToStream(AStream    : TStream;
                                AByteCount : Integer = -1);
  Property  InputBuffer         : TRESTDWBuffer        Read FInputBuffer;
  Property  LargeStream         : Boolean              Read FLargeStream      Write FLargeStream;
  Property  MaxCapturedLines    : Integer              Read FMaxCapturedLines Write FMaxCapturedLines Default cIOHandler_MaxCapturedLines;
  Property  Opened              : Boolean              Read FOpened;
  Property  ReadTimeout         : Integer              Read FReadTimeOut      Write FReadTimeOut      Default cTimeoutDefault;
  Property  ReadLnTimedout      : Boolean              Read FReadLnTimedout;
  Property  WriteBufferThreshold: Integer              Read FWriteBufferThreshold;
 Published
  Property  MaxLineLength       : Integer              Read FMaxLineLength    Write FMaxLineLength    Default cMaxLineLengthDefault;
  Property  MaxLineAction       : TRESTDWMaxLineAction Read FMaxLineAction    Write FMaxLineAction;
  Property  RecvBufferSize      : Integer              Read FRecvBufferSize   Write FRecvBufferSize   Default cRecvBufferSizeDefault;
  Property  SendBufferSize      : Integer              Read FSendBufferSize   Write FSendBufferSize   Default cSendBufferSizeDefault;
 End;

Implementation

Uses
  {$IFDEF WIN32_OR_WIN64}
  Windows,
  {$ENDIF}
  {$IFDEF USE_VCL_POSIX}
    {$IFDEF DARWIN}
  Macapi.CoreServices,
    {$ENDIF}
  {$ENDIF}
  {$IFDEF HAS_UNIT_Generics_Collections}
  System.Generics.Collections,
  {$ENDIF}
  SysUtils;

 Type
  TRESTDWIOHandlerClassList = TList;

Var
 GIOHandlerClassDefault : TRESTDWIOHandlerClass     = Nil;
 GIOHandlerClassList    : TRESTDWIOHandlerClassList = Nil;

{$IFDEF DCC}
  {$IFNDEF VCL_7_OR_ABOVE}
    // RLebeau 5/13/2015: The Write(Int64) and ReadInt64() methods produce an
    // "Internal error URW533" compiler error in Delphi 5, and an "Internal
    // error URW699" compiler error in Delphi 6, so need to use some workarounds
    // for those versions...
    {$DEFINE AVOID_URW_ERRORS}
  {$ENDIF}
{$ENDIF}

{ TRESTDWIOHandler }

Procedure TRESTDWIOHandler.Close;
Begin
 FOpened := False;
 WriteBufferClear;
End;

Destructor TRESTDWIOHandler.Destroy;
Begin
 Close;
 FreeAndNil(FInputBuffer);
 FreeAndNil(FWriteBuffer);
 Inherited Destroy;
End;

Procedure TRESTDWIOHandler.Open;
Begin
 FOpened           := False;
 FClosedGracefully := False;
 WriteBufferClear;
 FInputBuffer.Clear;
 FOpened           := True;
End;

// under ARC, all weak references to a freed object get nil'ed automatically
{$IFNDEF USE_OBJECT_ARC}
procedure TRESTDWIOHandler.Notification(AComponent: TComponent; Operation: TOperation);
begin
//  if (Operation = opRemove) and (AComponent = FIntercept) then begin
//    FIntercept := nil;
//  end;
  inherited Notification(AComponent, OPeration);
end;
{$ENDIF}

Class procedure TRESTDWIOHandler.SetDefaultClass;
Begin
 GIOHandlerClassDefault := Self;
 RegisterIOHandler;
End;

Class Function TRESTDWIOHandler.MakeDefaultIOHandler(AOwner : TComponent = Nil) : TRESTDWIOHandler;
Begin
 Result := GIOHandlerClassDefault.Create;
End;

Class Procedure TRESTDWIOHandler.RegisterIOHandler;
Begin
 If GIOHandlerClassList = Nil Then
  GIOHandlerClassList := TRESTDWIOHandlerClassList.Create;
 {$IFNDEF DOTNET_EXCLUDE}
  If GIOHandlerClassList.IndexOf(Self) = -1 Then
   GIOHandlerClassList.Add(Self);
 {$ENDIF}
End;

Class Function TRESTDWIOHandler.MakeIOHandler(ABaseType : TRESTDWIOHandlerClass;
                                              AOwner    : TComponent = Nil) : TRESTDWIOHandler;
Begin
 Result := TryMakeIOHandler(ABaseType, AOwner);
 If Not Assigned(Result) Then
  Raise erestdwException.CreateFmt(cIOHandlerTypeNotInstalled, [ABaseType.ClassName]);
End;

Class Function TRESTDWIOHandler.TryMakeIOHandler(ABaseType : TRESTDWIOHandlerClass;
                                                 AOwner    : TComponent = Nil) : TRESTDWIOHandler;
Var
 i : Integer;
Begin
 If GIOHandlerClassList <> Nil Then
  Begin
   For i := GIOHandlerClassList.Count - 1 Downto 0 Do
    Begin
     If TRESTDWIOHandlerClass(GIOHandlerClassList[i]).InheritsFrom(ABaseType) Then
      Begin
       Result := TRESTDWIOHandlerClass(GIOHandlerClassList[i]).Create;
       Exit;
      End;
    End;
  End;
 Result := nil;
End;

Procedure TRESTDWIOHandler.WriteBufferOpen(AThreshold : Integer);
Begin
 If FWriteBuffer <> Nil Then
  FWriteBuffer.Clear
 Else
  FWriteBuffer := TRESTDWBuffer.Create;
 FWriteBufferThreshold := AThreshold;
End;

Procedure TRESTDWIOHandler.WriteBufferClose;
Begin
 Try
 Finally
  FreeAndNil(FWriteBuffer);
 End;
End;

Procedure TRESTDWIOHandler.WriteBufferClear;
Begin
 If FWriteBuffer <> Nil Then
  FWriteBuffer.Clear;
End;

Procedure TRESTDWIOHandler.WriteBufferCancel;
Begin
 WriteBufferClear;
 WriteBufferClose;
End;

Procedure TRESTDWIOHandler.ReadBytes(Var VBuffer : TRESTDWBytes;
                                     AByteCount  : Integer;
                                     AAppend     : Boolean = True);
Begin
End;

function TRESTDWIOHandler.ReadString(ABytes: Integer): string;
var
  LBytes: TRESTDWBytes;
begin
 If ABytes > 0 Then
  Begin
   ReadBytes(LBytes, ABytes, False);
   Result := BytesToString(LBytes, 0, ABytes);
  End
 Else
  Result := '';
End;

Procedure TRESTDWIOHandler.ReadStrings(ADest           : TStrings;
                                       AReadLinesCount : Integer = -1);
Var
 i : Integer;
Begin
 If AReadLinesCount < 0 Then
  AReadLinesCount := ReadInt32;
 For i := 0 To AReadLinesCount - 1 Do
  ADest.Add(ReadLn);
End;

Function TRESTDWIOHandler.ReadUInt16(AConvert : Boolean = True): DWUInt16;
Var
 LBytes : TRESTDWBytes;
Begin
 ReadBytes(LBytes, SizeOf(DWUInt16), False);
 //TODO
// Result := BytesToUInt16(LBytes);
// If AConvert Then
//    Result := GStack.NetworkToHost(Result);
End;

Function TRESTDWIOHandler.ReadWord(AConvert: Boolean = True): DWUInt16;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 Result := ReadUInt16(AConvert);
End;

Function TRESTDWIOHandler.ReadInt16(AConvert: Boolean = True): DWInt16;
Var
 LBytes : TRESTDWBytes;
Begin
 ReadBytes(LBytes, SizeOf(DWInt16), False);
 Result := BytesToInt16(LBytes);
// If AConvert Then
//    Result := Int16(GStack.NetworkToHost(UInt16(Result)));
end;

Function TRESTDWIOHandler.ReadSmallInt(AConvert: Boolean = True): DWInt16;{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 Result := ReadInt16(AConvert);
End;

Function TRESTDWIOHandler.ReadChar : Char;
Var
 I,
 J,
 NumChars,
 NumBytes : Integer;
 LBytes   : TRESTDWBytes;
 LChars   : TRESTDWWideChars;
 {$IFDEF FPC}
 LWTmp    : UnicodeString;
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
   LWTmp    : UnicodeString;
  {$ELSE}
   LWTmp    : Utf8String;
  {$IFEND}
 {$ENDIF}
 LATmp    : TRESTDWBytes;
Begin
 NumBytes := FinalStrPos * 2;
 SetLength(LBytes, NumBytes);
 NumChars := 0;
 If NumBytes > 0 then
  Begin
   For I := 1 To NumBytes Do
    Begin
     LBytes[I-1] := ReadByte;
     NumChars := GetChars(LBytes, 0, I, LChars, 0);
     If NumChars > 0 Then
      Begin
       For J := 0 To NumChars-1 Do
        Begin
         If LChars[J] = DWWideChar($FFFD) Then
          Begin
           NumChars := 0;
           Break;
          End;
        End;
       If NumChars > 0 Then
        Break;
      End;
    End;
  End;
 SetString(LWTmp, PWideChar(LChars), NumChars);
 LATmp := GetBytes(LWTmp); // convert to Ansi
 Assert(Length(LATmp) = 1);
 Result := Char(LATmp[0]);
End;

Function TRESTDWIOHandler.ReadByte: Byte;
Var
 LBytes : TRESTDWBytes;
Begin
 ReadBytes(LBytes, 1, False);
 Result := LBytes[0];
End;

Function TRESTDWIOHandler.ReadInt32(AConvert: Boolean): DwInt32;
Var
 LBytes : TRESTDWBytes;
Begin
 ReadBytes(LBytes, SizeOf(DwInt32), False);
 Result := BytesToInt32(LBytes);
// If AConvert Then
//    Result := Int32(GStack.NetworkToHost(UInt32(Result)));
End;

Function TRESTDWIOHandler.ReadLongInt(AConvert: Boolean): DwInt32;{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 Result := ReadInt32(AConvert);
End;

Function TRESTDWIOHandler.ReadInt64(AConvert: boolean): Int64;
Var
 LBytes : TRESTDWBytes;
Begin
 ReadBytes(LBytes, SizeOf(Int64), False);
 Result := BytesToInt64(LBytes);
End;

Function TRESTDWIOHandler.ReadUInt64(AConvert: boolean): TRESTDWUInt64;
Var
 LBytes : TRESTDWBytes;
Begin
 ReadBytes(LBytes, SizeOf(TRESTDWUInt64), False);
 //TODO
// Result := BytesToUInt64(LBytes);
// If AConvert Then
//    Result := GStack.NetworkToHost(Result);
End;

Function TRESTDWIOHandler.ReadUInt32(AConvert: Boolean): DwUInt32;
Var
 LBytes : TRESTDWBytes;
Begin
 ReadBytes(LBytes, SizeOf(DwUInt32), False);
 //TODO
 //Result := BytesToUInt32(LBytes);
// If AConvert Then
//    Result := GStack.NetworkToHost(Result);
End;

Function TRESTDWIOHandler.ReadLongWord(AConvert: Boolean): DwUInt32;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 Result := ReadUInt32(AConvert);
End;

Function TRESTDWIOHandler.ReadLn : String;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 Result := ReadLn(LF, cTimeoutDefault, -1);
End;

Function TRESTDWIOHandler.ReadLn(ATerminator : String): string;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 Result := ReadLn(ATerminator, cTimeoutDefault, -1);
End;

Function TRESTDWIOHandler.ReadLn(ATerminator    : String;
                                 ATimeout       : Integer = cTimeoutDefault;
                                 AMaxLineLength : Integer = -1) : string;
Begin
End;

Function TRESTDWIOHandler.ReadLnRFC(Var VMsgEnd : Boolean) : String;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 Result := ReadLnRFC(VMsgEnd, LF, '.');
End;

Function TRESTDWIOHandler.ReadLnRFC(Var VMsgEnd     : Boolean;
                                    ALineTerminator : String;
                                    Const ADelim    : String = '.'): string;
Begin
 Result := ReadLn(ALineTerminator, cTimeoutDefault, -1);
  // Do not use ATerminator since always ends with . (standard)
 If Result = ADelim then
  Begin
   VMsgEnd := True;
   Exit;
  End;
 If TextStartsWith(Result, '..') Then
  Delete(Result, 1, 1);
 VMsgEnd := False;
End;

Function TRESTDWIOHandler.ReadLnSplit(Var AWasSplit  : Boolean;
                                      ATerminator    : String = LF;
                                      ATimeout       : Integer = cTimeoutDefault;
                                      AMaxLineLength : Integer = -1) : String;
Var
 FOldAction : TRESTDWMaxLineAction;
Begin
 FOldAction := MaxLineAction;
 MaxLineAction := maSplit;
 Try
  Result := ReadLn(ATerminator, ATimeout, AMaxLineLength);
  AWasSplit := FReadLnSplit;
 Finally
  MaxLineAction := FOldAction;
 End;
End;

Function TRESTDWIOHandler.ReadLnWait(AFailCount : Integer = MaxInt) : String;
Var
 LAttempts : Integer;
Begin
 Result := '';
 LAttempts := 0;
 While LAttempts < AFailCount Do
  Begin
   Result := Trim(ReadLn);
   If Length(Result) > 0 Then
    Exit;
   If ReadLnTimedOut Then
    Raise eRESTDWReadTimeout.Create(cReadTimeout);
   Inc(LAttempts);
  End;
 Raise eRESTDWReadLnWaitMaxAttemptsExceeded.Create(cReadLnWaitMaxAttemptsExceeded);
end;

Constructor TRESTDWIOHandler.create;
Begin
 FRecvBufferSize := GRecvBufferSizeDefault;
 FSendBufferSize := GSendBufferSizeDefault;
 FMaxLineLength := cMaxLineLengthDefault;
 FMaxCapturedLines := cIOHandler_MaxCapturedLines;
 FLargeStream := False;
 FInputBuffer := TRESTDWBuffer.Create;
End;

Procedure AdjustStreamSize(Const AStream : TStream;
                           Const ASize   : TRESTDWStreamSize);
Var
 LStreamPos : TRESTDWStreamSize;
Begin
 LStreamPos := AStream.Position;
 AStream.Size := ASize;
 If AStream.Position <> LStreamPos Then
  AStream.Position := LStreamPos;
End;

Procedure TRESTDWIOHandler.InputBufferToStream(AStream    : TStream;
                                               AByteCount : Integer = -1);
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 FInputBuffer.ExtractToStream(AStream, AByteCount);
End;

Function TRESTDWIOHandler.InputBufferIsEmpty: Boolean;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 Result := FInputBuffer.Size = 0;
End;

Initialization

Finalization
 FreeAndNil(GIOHandlerClassList)
End.
