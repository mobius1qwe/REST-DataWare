Unit uRESTDWMessageCoderMIME;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 Classes, SysUtils,
 uRESTDWBasicTypes, uRESTDWProtoTypes, uRESTDWException, uRESTDWMessage,
 uRESTDWTools, uRESTDWCoder, uRESTDWMessageCoder, uRESTDWCoderHeader, uRESTDWAbout;

 Type
  eRESTDWNotEnoughDataInBuffer = Class(eRESTDWException);
  eRESTDWTooMuchDataInBuffer   = Class(eRESTDWException); //Only 2GB is allowed
  TRESTDWBufferBytesRemoved    = Procedure(ASender : TObject;
                                           ABytes  : Integer) Of Object;

 Type
  TRESTDWMessageDecoderMIME = class(TRESTDWMessageDecoder)
  Protected
   FFirstLine,
   FMIMEBoundary      : String;
   FProcessFirstLine,
   FBodyEncoded       : Boolean;
   Function    GetProperHeaderItem(Const Line  : String) : String;
  Public
   Constructor Create             (AOwner      : TComponent;
                                   Const ALine : String); Reintroduce; Overload;
   Destructor  Destroy;  Override;
   Function    ReadBody           (ADestStream : TStream;
                                   Var VMsgEnd : Boolean) : TRESTDWMessageDecoder; Override;
   Procedure   CheckAndSetType    (Const AContentType,
                                   AContentDisposition : String);
   Procedure ReadHeader; Override;
   Function  GetAttachmentFilename(Const AContentType,
                                   AContentDisposition     : String) : String;
   Function RemoveInvalidCharsFromFilename(Const AFilename : String) : String;
   Property MIMEBoundary : String  Read FMIMEBoundary Write FMIMEBoundary;
   Property BodyEncoded  : Boolean Read FBodyEncoded  Write FBodyEncoded;
 End;

 Type
  TRESTDWMessageDecoderInfoMIME = Class(TRESTDWMessageDecoderInfo)
 Public
  Function CheckForStart(ASender     : TRESTDWMessage;
                         Const ALine : String) : TRESTDWMessageDecoder; Override;
 End;

 Type
  TRESTDWMessageEncoderMIME     = Class(TRESTDWMessageEncoder)
 Public
  Procedure Encode(ASrc  : TStream;
                   ADest : TStream); Override;
 End;

 Type
  TRESTDWMessageEncoderInfoMIME = Class(TRESTDWMessageEncoderInfo)
 Public
  Constructor Create; Override;
  Procedure InitializeHeaders(AMsg : TRESTDWMessage); Override;
 End;

 Type
  TRESTDWMIMEBoundaryStrings = class
  Public
   Class function GenerateRandomChar: Char;
   Class function GenerateBoundary: String;
  End;

 Type
  TRESTDWMessageDecoderMIMEIgnore = class(TRESTDWMessageDecoder)
 Public
  Function  ReadBody(ADestStream: TStream; var VMsgEnd: Boolean): TRESTDWMessageDecoder; override;
  Procedure ReadHeader; override;
 End;

Implementation

Uses
  uRESTDWCoderMIME, uRESTDWCoderQuotedPrintable, uRESTDWCoderBinHex4,
  uRESTDWBuffer;

Function DoReadLnFromStream(AStream        : TStream;
                            ATerminator    : String;
                            AMaxLineLength : Integer = -1) : String;
Const
 LBUFMAXSIZE = 2048;
Var
 LBuffer   :  TRESTDWBuffer;
 LSize,
 LStartPos,
 LTermPos  : Integer;
 LTerm,
 LTemp     : TRESTDWBytes;
 LStrmStartPos,
 LStrmPos,
 LStrmSize : TRESTDWStreamSize;
Begin
 Assert(AStream <> Nil);
 LTerm         := Nil;
 LStrmStartPos := AStream.Position;
 LStrmPos      := LStrmStartPos;
 LStrmSize     := AStream.Size;
 If LStrmPos >= LStrmSize Then
  Begin
   Result := '';
   Exit;
  End;
 SetLength(LTemp, LBUFMAXSIZE);
 LBuffer := TRESTDWBuffer.Create;
 Try
  If AMaxLineLength < 0  Then
   AMaxLineLength := MaxInt;
  If ATerminator    = '' Then
   ATerminator := LF;
  LTerm := ToBytes(ATerminator);
  LTermPos := -1;
  LStartPos := 0;
  Repeat
   LSize := Min(LStrmSize - LStrmPos, LBUFMAXSIZE);
   LSize := ReadBytesFromStream(AStream, LTemp, LSize);
   If LSize < 1 Then
    Begin
     LStrmPos := LStrmStartPos + LBuffer.Size;
     Break;
    End;
   Inc(LStrmPos, LSize);
   LBuffer.Write(LTemp, LSize, 0);
   LTermPos := LBuffer.IndexOf(LTerm, LStartPos);
   If LTermPos > -1 Then
    Begin
     If (AMaxLineLength > 0)        And
        (LTermPos > AMaxLineLength) Then
      Begin
       LStrmPos := LStrmStartPos + AMaxLineLength;
       LTermPos := AMaxLineLength;
      End
     Else
      LStrmPos := LStrmStartPos + LTermPos + restdwLength(LTerm);
     Break;
    End;
   LStartPos := Max(LBuffer.Size-(restdwLength(LTerm)-1), 0);
   If (AMaxLineLength > 0)          And
      (LStartPos >= AMaxLineLength) Then
    Begin
     LStrmPos := LStrmStartPos + AMaxLineLength;
     LTermPos := AMaxLineLength;
     Break;
    End;
  Until LStrmPos >= LStrmSize;
  If (ATerminator = LF)           And
     (LTermPos    > 0)            And
     (LTermPos    < LBuffer.Size) Then
   Begin
    If (LBuffer.PeekByte(LTermPos)   = Ord(LF)) And
       (LBuffer.PeekByte(LTermPos-1) = Ord(CR)) Then
     Dec(LTermPos);
   End;
  AStream.Position := LStrmPos;
  Result           := LBuffer.ExtractToString(LTermPos);
 Finally
  LBuffer.Free;
 End;
End;

Function TRESTDWMessageDecoderMIMEIgnore.ReadBody(ADestStream : TStream;
                                                  Var VMsgEnd : Boolean) : TRESTDWMessageDecoder;
Begin
 VMsgEnd := False;
 Result := nil;
End;

Procedure TRESTDWMessageDecoderMIMEIgnore.ReadHeader;
Begin
 FPartType := mcptIgnore;
End;

Class Function TRESTDWMIMEBoundaryStrings.GenerateRandomChar : Char;
Var
 LOrd   : Integer;
 LFloat : Double;
Begin
 If RandSeed = 0 Then
  Randomize;
 LFloat := (Random * 61) + 1.5;  //Gives us 1.5 to 62.5
 LOrd   := Trunc(LFloat) + 47;  //(1..62) -> (48..109)
 If LOrd > 83 Then
  LOrd := LOrd + 13  {Move into lowercase letter range}
 Else If LOrd > 57 Then
  Inc(LOrd, 7);  {Move into upper-case letter range}
 Result := Chr(LOrd);
End;

Class Function TRESTDWMIMEBoundaryStrings.GenerateBoundary : String;
Const
 BoundaryLength = 34;
Var
 LN : Integer;
 LFloat: Double;
Begin
 Result       := StringOfChar(' ', BoundaryLength);
 For LN := 1 To BoundaryLength Do
  Result[LN]  := GenerateRandomChar;
 {CC2: RFC 2045 recommends including "=_" in the boundary, insert in random location...}
 LFloat       := (Random * (BoundaryLength-2)) + 1.5;  //Gives us 1.5 to Length-0.5
 LN           := Trunc(LFloat);  // 1 to Length-1 (we are inserting a 2-char string)
 Result[LN]   := '=';
 Result[LN+1] := '_';
End;

Function TRESTDWMessageDecoderInfoMIME.CheckForStart(ASender     : TRESTDWMessage;
                                                     Const ALine : String) : TRESTDWMessageDecoder;
Begin
 Result := nil;
 If ASender.MIMEBoundary.Boundary <> '' Then
  Begin
   If TextIsSame(ALine, '--' + ASender.MIMEBoundary.Boundary) Then
    Result := TRESTDWMessageDecoderMIME.Create(ASender)
   Else If TextIsSame(ALine, '--' + ASender.MIMEBoundary.Boundary + '--') Then
    Begin    {Do not Localize}
     ASender.MIMEBoundary.Pop;
     Result := TRESTDWMessageDecoderMIMEIgnore.Create(ASender);
    End;
  End;
 If (Result = nil) And
    (ASender.ContentTransferEncoding <> '') Then
  Begin
   If IsHeaderMediaType(ASender.ContentType, 'multipart') And {do not localize}
     (PosInStrArray    (ASender.ContentTransferEncoding, ['7bit', '8bit', 'binary'], False) = -1)   Then {do not localize}
    Exit;
   If (PosInStrArray(ASender.ContentTransferEncoding, ['base64', 'quoted-printable'], False) <> -1) Then {Do not localize}
    Result := TRESTDWMessageDecoderMIME.Create(ASender, ALine);
  End;
End;

Constructor TRESTDWMessageDecoderMIME.Create(AOwner      : TComponent;
                                             Const ALine : String);
Begin
 Inherited Create(AOwner);
 FFirstLine := ALine;
 FProcessFirstLine := True;
 FBodyEncoded := False;
 If Owner Is TRESTDWMessage Then
  Begin
   FMIMEBoundary := TRESTDWMessage(Owner).MIMEBoundary.Boundary;
   If TRESTDWMessage(Owner).ContentTransferEncoding <> '' Then
    Begin
     If (Not IsHeaderMediaType(TRESTDWMessage(Owner).ContentType, 'multipart')) And
        (PosInStrArray(TRESTDWMessage(Owner).ContentTransferEncoding, ['8bit', '7bit', 'binary'], False) = -1) Then
      FBodyEncoded := True;
    End;
  End;
End;

destructor TRESTDWMessageDecoderMIME.Destroy;
begin
  inherited;
end;

Function TRESTDWMessageDecoderMIME.ReadBody(ADestStream : TStream;
                                            Var VMsgEnd : Boolean) : TRESTDWMessageDecoder;
Var
 LContentType,
 LContentTransferEncoding,
 LLine,
 LBinaryLineBreak,
 LBuffer,                       //Needed for binhex4 because cannot decode line-by-line.
 LBoundaryStart,
 LBoundaryEnd              : String;
 LIsThisTheFirstLine,           //Needed for binary encoding
 LIsBinaryContentTransferEncoding : Boolean;
 LDecoder                  : TRESTDWDecoder;
Begin
 LIsThisTheFirstLine := True;
 VMsgEnd := False;
 Result  := Nil;
 If FBodyEncoded Then
  Begin
   LContentType             := TRESTDWMessage(Owner).ContentType;
   LContentTransferEncoding := TRESTDWMessage(Owner).ContentTransferEncoding;
  End
 Else
  Begin
   LContentType             := FHeaders.Values['Content-Type']; {Do not Localize}
   LContentTransferEncoding := FHeaders.Values['Content-Transfer-Encoding']; {Do not Localize}
  End;
 If LContentTransferEncoding = '' Then
  Begin
   If IsHeaderMediaType(LContentType, 'application/mac-binhex40') Then  {Do not Localize}
    LContentTransferEncoding := 'binhex40' {do not localize}
   Else If Not IsHeaderMediaType(LContentType, 'application/octet-stream') Then  {Do not Localize}
    LContentTransferEncoding := '7bit'; {do not localize}
  End
 Else If IsHeaderMediaType(LContentType, 'multipart') Then {do not localize}
  Begin
   If PosInStrArray(LContentTransferEncoding, ['7bit', '8bit', 'binary'], False) = -1 Then {do not localize}
    LContentTransferEncoding := '';
  End;
 If TextIsSame(LContentTransferEncoding, 'base64')                Then {Do not Localize}
  LDecoder := TRESTDWDecoderMIMELineByLine.Create(Nil)
 Else If TextIsSame(LContentTransferEncoding, 'quoted-printable') Then {Do not Localize}
  LDecoder := TRESTDWDecoderQuotedPrintable.Create(Nil)
 Else If TextIsSame(LContentTransferEncoding, 'binhex40')         Then {Do not Localize}
  LDecoder := TRESTDWDecoderBinHex4.Create      (Nil)
 Else
  LDecoder := nil;
 Try
  If LDecoder <> Nil Then
   LDecoder.DecodeBegin(ADestStream);
  If MIMEBoundary <> '' Then
   Begin
    LBoundaryStart := '--' + MIMEBoundary; {Do not Localize}
    LBoundaryEnd := LBoundaryStart + '--'; {Do not Localize}
   End;
  If LContentTransferEncoding <> '' Then
   Begin
    Case PosInStrArray(LContentTransferEncoding, ['7bit', 'quoted-printable', 'base64', '8bit', 'binary'], False) Of {do not localize}
     0..2: LIsBinaryContentTransferEncoding := False;
     3..4: LIsBinaryContentTransferEncoding := True;
    Else
     LIsBinaryContentTransferEncoding := True;
     LContentTransferEncoding         := '';
    End;
   End
  Else
   LIsBinaryContentTransferEncoding := True;
  Repeat
   If Not FProcessFirstLine Then
    Begin
     If LIsBinaryContentTransferEncoding Then
      Begin
       LLine            := ReadLnRFC(VMsgEnd, EOL, '.'); {do not localize}
       LBinaryLineBreak := EOL;
      End
     Else
      LLine := ReadLnRFC(VMsgEnd, LF, '.'); {do not localize}
    End
   Else
    Begin
     LLine := FFirstLine;
     FFirstLine := '';    {Do not Localize}
     FProcessFirstLine := False;
     // Do not use ADELIM since always ends with . (standard)
     If LLine = '.' Then
      Begin {Do not Localize}
       VMsgEnd := True;
       Break;
      End;
     If TextStartsWith(LLine, '..') Then
      Delete(LLine, 1, 1);
    End;
   If VMsgEnd Then
    Break;
   If MIMEBoundary <> '' Then
    Begin
     If TextIsSame(LLine, LBoundaryStart) Then
      Begin
       Result := TRESTDWMessageDecoderMIME.Create(Owner);
       Break;
      End;
     If TextIsSame(LLine, LBoundaryEnd) Then
      Begin
       If Owner is TRESTDWMessage Then
        TRESTDWMessage(Owner).MIMEBoundary.Pop;
       Break;
      End;
    End;
   If LDecoder = Nil Then
    Begin
     If LIsBinaryContentTransferEncoding Then
      Begin {do not localize}
       If LIsThisTheFirstLine Then
        LIsThisTheFirstLine := False
       Else
        Begin
         If Assigned(ADestStream) Then
          WriteStringToStream(ADestStream, LBinaryLineBreak, -1, 1);
        End;
       If Assigned(ADestStream) Then
        WriteStringToStream(ADestStream, LLine, -1, 1);
      End
     Else
      Begin
       If Assigned(ADestStream) Then
        WriteStringToStream(ADestStream, LLine + EOL, -1, 1);
      End;
    End
   Else
    Begin
     If LDecoder Is TRESTDWDecoderQuotedPrintable Then
      LDecoder.Decode(LLine + EOL)
     Else If LDecoder Is TRESTDWDecoderBinHex4 Then
      LBuffer := LBuffer + LLine
     Else If LLine <> '' Then
      LDecoder.Decode(LLine);
    End;
  Until False;
  If LDecoder <> Nil Then
   Begin
    If LDecoder Is TRESTDWDecoderBinHex4 Then
     LDecoder.Decode(LBuffer);
    LDecoder.DecodeEnd;
   End;
 Finally
  FreeAndNil(LDecoder);
 End;
End;

Function TRESTDWMessageDecoderMIME.GetAttachmentFilename(Const AContentType,
                                                         AContentDisposition : String) : String;
Var
 LValue : String;
Begin
 LValue := ExtractHeaderSubItem(AContentDisposition, 'filename', QuoteMIME); {do not localize}
 If LValue = '' Then
  LValue := ExtractHeaderSubItem(AContentType, 'name', QuoteMIME); {do not localize}
 If Length(LValue) > 0 Then
  Result := RemoveInvalidCharsFromFilename(DecodeHeader(LValue))
 Else
  Result := '';
End;

Procedure TRESTDWMessageDecoderMIME.CheckAndSetType(Const AContentType,
                                                    AContentDisposition : String);
Begin
 FFileName := GetAttachmentFilename(AContentType, AContentDisposition);
 If IsHeaderMediaTypes(AContentType, ['text', 'multipart']) And {do not localize}
    (Not IsHeaderValue(AContentDisposition, 'attachment'))  Then {do not localize}
  FPartType := mcptText
 Else
  FPartType := mcptAttachment;
End;

Function TRESTDWMessageDecoderMIME.GetProperHeaderItem(Const Line : String) : String;
Var
 LPos,
 Idx,
 LLen  : Integer;
Begin
 LPos := Pos(':', Line);
 If LPos = 0 Then
  Begin // the header line is invalid
   Result := Line;
   Exit;
  End;
 Idx := LPos - 1;
 While (Idx > 0)          And
       (Line[Idx] = ' ')  Do
  Dec(Idx);
 LLen := Length(Line);
 Inc(LPos);
 While (LPos <= LLen)     And
       (Line[LPos] = ' ') Do
  Inc(LPos);
 Result := Copy(Line, 1, Idx) + '=' + Copy(Line, LPos, MaxInt);
End;

Procedure TRESTDWMessageDecoderMIME.ReadHeader;
Var
 ABoundary,
 s,
 LLine      : String;
 LMsgEnd    : Boolean;
Begin
 If FBodyEncoded Then
  CheckAndSetType(TRESTDWMessage(Owner).ContentType, TRESTDWMessage(Owner).ContentDisposition)
 Else
  Begin
   Repeat
    LLine := ReadLnRFC(LMsgEnd);
    If LMsgEnd Then
     Begin
      FPartType := mcptEOF;
      Exit;
     End;//if
    If LLine = '' Then
     Break;
    If CharIsInSet(LLine, 1, LWS) Then
     Begin
      If FHeaders.Count > 0 Then
       FHeaders[FHeaders.Count - 1] := FHeaders[FHeaders.Count - 1] + ' ' + TrimLeft(LLine)
      Else
       FHeaders.Add(GetProperHeaderItem(TrimLeft(LLine))); {Do not Localize}
     End
    Else
     FHeaders.Add(GetProperHeaderItem(LLine));    {Do not Localize}
   Until False;
   s := FHeaders.Values['Content-Type'];    {do not localize}
   If IsHeaderMediaType(s, 'multipart') Then
    Begin  {do not localize}
     ABoundary := ExtractHeaderSubItem(s, 'boundary', QuoteMIME);  {do not localize}
     If Owner Is TRESTDWMessage Then
      Begin
       If Length(ABoundary) > 0 Then
        Begin
         TRESTDWMessage(Owner).MIMEBoundary.Push(ABoundary, TRESTDWMessage(Owner).MessageParts.Count);
         FMIMEBoundary := ABoundary;
        End
       Else
        TRESTDWMessage(Owner).MIMEBoundary.Push(FMIMEBoundary, TRESTDWMessage(Owner).MessageParts.Count);
      End;
    End;
   CheckAndSetType(FHeaders.Values['Content-Type'], FHeaders.Values['Content-Disposition']);
  End;
End;

Function TRESTDWMessageDecoderMIME.RemoveInvalidCharsFromFilename(Const AFilename : String) : String;
Const
 InvalidWindowsFilenameChars = '\/:*?"<>|'; {do not localize}
Var
 LN : integer;
Begin
 Result := AFilename;
 //First, strip any Windows or Unix path...
 For LN := Length(Result) Downto 1 Do
  Begin
   If ((Result[LN] = '/') or (Result[LN] = '\')) Then
    Begin  {do not localize}
     Result := Copy(Result, LN+1, MaxInt);
     Break;
    End;
  End;
 For LN := 1 To Length(Result) Do
  Begin
   If Pos(Result[LN], InvalidWindowsFilenameChars) > 0 Then
    Result[LN] := '_';
  End;
End;

Constructor TRESTDWMessageEncoderInfoMIME.Create;
Begin
 Inherited;
 FMessageEncoderClass := TRESTDWMessageEncoderMIME;
End;

Procedure TRESTDWMessageEncoderInfoMIME.InitializeHeaders(AMsg : TRESTDWMessage);
Begin
 If AMsg.ContentType = '' Then
  Begin
   If AMsg.MessageParts.RelatedPartCount > 0 Then
    AMsg.ContentType := 'multipart/related; type="multipart/alternative"'
   Else
    Begin
     If AMsg.MessageParts.AttachmentCount > 0 Then
      AMsg.ContentType := 'multipart/mixed' //; boundary="' {do not localize}
     Else
      Begin
       If AMsg.MessageParts.TextPartCount > 0 Then
        AMsg.ContentType := 'multipart/alternative';  //; boundary="' {do not localize}
      End;
    End;
  End;
End;

Procedure TRESTDWMessageEncoderMIME.Encode(ASrc: TStream; ADest: TStream);
Var
 s        : String;
 LEncoder : TRESTDWEncoderMIME;
 LSPos,
 LSSize   : TRESTDWStreamSize;
Begin
 ASrc.Position := 0;
 LSPos := 0;
 LSSize := ASrc.Size;
 LEncoder := TRESTDWEncoderMIME.Create(nil);
 Try
  While LSPos < LSSize Do
   Begin
    s := LEncoder.Encode(ASrc, 57) + EOL;
    Inc(LSPos, 57);
    WriteStringToStream(ADest, s, -1, 1);
   End;
 Finally
  FreeAndNil(LEncoder);
 End;
End;

Initialization
 TRESTDWMessageDecoderList.RegisterDecoder('MIME', TRESTDWMessageDecoderInfoMIME.Create);
 TRESTDWMessageEncoderList.RegisterEncoder('MIME', TRESTDWMessageEncoderInfoMIME.Create);
Finalization

end.
