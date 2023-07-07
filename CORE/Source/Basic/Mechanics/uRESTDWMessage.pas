unit uRESTDWMessage;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 Classes,
 uRESTDWAbout, uRESTDWAttachment, uRESTDWHeaderList, uRESTDWMessageParts,
 uRESTDWException, uRESTDWProtoTypes;

Type
 TRESTDWMessagePriority = (mpHighest, mpHigh, mpNormal, mpLow, mpLowest);

Const
 RESTDW_MSG_NODECODE       = False;
 RESTDW_MSG_USESNOWFORDATE = True;
 RESTDW_MSG_PRIORITY       = mpNormal;

 Type
  TRESTDWMIMEBoundary = Class(TObject)
 Protected
  FBoundaryList,
  FParentPartList              : TStrings;
  Function GetBoundary         : String;
  Function GetParentPart       : Integer;
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Procedure   Push(ABoundary   : String;
                   AParentPart : Integer);
  Procedure   Pop;
  Procedure   Clear;
  Function    Count            : Integer;
  Property    Boundary         : String    Read GetBoundary;
  Property    ParentPart       : Integer   Read GetParentPart;
 End;

 TRESTDWMessageFlags          = (mfAnswered, mfFlagged, mfDeleted,
                                 mfDraft,    mfSeen,    mfRecent);
 TRESTDWMessageFlagsSet       = Set Of TRESTDWMessageFlags;
 TRESTDWMessageEncoding       = (meDefault, meMIME, mePlainText);
 TRESTDWInitializeIsoEvent    = Procedure (Var VHeaderEncoding : Char;
                                           Var VCharSet        : String)            Of Object;
 TRESTDWMessage               = Class;
 TRESTDWCreateAttachmentEvent = Procedure (Const AMsg          : TRESTDWMessage;
                                           Const AHeaders      : TStrings;
                                           Var AAttachment     : TRESTDWAttachment) Of Object;

 TRESTDWMessage = Class(TRESTDWComponent)
 Protected
  FBody,
  FNewsGroups               : TStrings;
  FMsgId,
  FAttachmentTempDirectory,
  FCharSet,
  FContentType,
  FContentTransferEncoding,
  FContentDisposition,
  FReferences,
  FUID,
  FText,
  FXProgram                 : String;
  FDate                     : TDateTime;
  FExtraHeaders             : TRESTDWHeaderList;
  FEncoding                 : TRESTDWMessageEncoding;
  FFlags                    : TRESTDWMessageFlagsSet;
  FHeaders                  : TRESTDWHeaderList;
  FMessageParts             : TRESTDWMessageParts;
  FMIMEBoundary             : TRESTDWMIMEBoundary;
  FIsEncoded,
  FConvertPreamble,
  FSavingToFile,
  FIsMsgSinglePartMime,
  FExceptionOnBlockedAttachments,
  FNoEncode,
  FNoDecode                 : Boolean;
  FOnInitializeISO          : TRESTDWInitializeIsoEvent;
  FPriority                 : TRESTDWMessagePriority;
  FOnCreateAttachment       : TRESTDWCreateAttachmentEvent;
  FLastGeneratedHeaders     : TRESTDWHeaderList;
  Procedure DoInitializeISO           (Var VHeaderEncoding  : Char;
                                       Var VCharSet         : String); Virtual;
  Function  GetAttachmentEncoding : String;
  Function  GetUseNowForDate      : Boolean;
  Procedure SetAttachmentEncoding     (Const AValue         : String);
  Procedure SetAttachmentTempDirectory(Const Value          : string);
  Procedure SetBody                   (Const AValue         : TStrings);
  Procedure SetContentType            (Const AValue         : String);
  Procedure SetEncoding               (Const AValue         : TRESTDWMessageEncoding);
  Procedure SetExtraHeaders           (Const AValue         : TRESTDWHeaderList);
  Procedure SetHeaders                (Const AValue         : TRESTDWHeaderList);
  Procedure SetUseNowForDate          (Const AValue         : Boolean);
 Public
  Constructor Create                   (AOwner              : TComponent); Override;
  Destructor  Destroy;      Override;
  Procedure   AddHeader                (Const AValue        : String);
  Procedure   Clear;        Virtual;
  Procedure   ClearBody;
  Procedure   ClearHeader;
  Procedure   GenerateHeader;
  Function    IsBodyEncodingRequired             : Boolean;
  Function    IsBodyEmpty                        : Boolean;
  Procedure   ProcessHeaders;
  procedure   DoCreateAttachment       (Const AHeaders      : TStrings;
                                        Var VAttachment     : TRESTDWAttachment); Virtual;
  Property Flags                           : TRESTDWMessageFlagsSet       Read FFlags                         Write FFlags;
  Property IsEncoded                       : Boolean                      Read FIsEncoded                     Write FIsEncoded;
  Property Headers                         : TRESTDWHeaderList            Read FHeaders                       Write SetHeaders;
  Property MessageParts                    : TRESTDWMessageParts          Read FMessageParts;
  Property MIMEBoundary                    : TRESTDWMIMEBoundary          Read FMIMEBoundary;
  Property UID                             : String                       Read FUID                           Write FUID;
  Property IsMsgSinglePartMime             : Boolean                      Read FIsMsgSinglePartMime           Write FIsMsgSinglePartMime;
  Property Text                            : String                       Read FText                          Write FText;
 Published
  Property AttachmentEncoding              : String                       Read GetAttachmentEncoding          Write SetAttachmentEncoding;
  Property Body                            : TStrings                     Read FBody                          Write SetBody;
  Property CharSet                         : String                       Read FCharSet                       Write FCharSet;
  Property ContentType                     : String                       Read FContentType                   Write SetContentType;
  Property ContentTransferEncoding         : String                       Read FContentTransferEncoding       Write FContentTransferEncoding;
  Property ContentDisposition              : String                       Read FContentDisposition            Write FContentDisposition;
  Property Date                            : TDateTime                    Read FDate                          Write FDate;
  Property Encoding                        : TRESTDWMessageEncoding       Read FEncoding                      Write SetEncoding;
  Property ExtraHeaders                    : TRESTDWHeaderList            Read FExtraHeaders                  Write SetExtraHeaders;
  Property NoEncode                        : Boolean                      Read FNoEncode                      Write FNoEncode        Default RESTDW_MSG_NODECODE;
  Property NoDecode                        : Boolean                      Read FNoDecode                      Write FNoDecode        Default RESTDW_MSG_NODECODE;
  Property Priority                        : TRESTDWMessagePriority       Read FPriority                      Write FPriority        Default RESTDW_MSG_PRIORITY;
  Property References                      : String                       Read FReferences                    Write FReferences;
  Property UseNowForDate                   : Boolean                      Read GetUseNowForDate               Write SetUseNowForDate Default RESTDW_MSG_USESNOWFORDATE;
  Property LastGeneratedHeaders            : TRESTDWHeaderList            Read FLastGeneratedHeaders;
  Property ConvertPreamble                 : Boolean                      Read FConvertPreamble               Write FConvertPreamble;
  Property ExceptionOnBlockedAttachments   : Boolean                      Read FExceptionOnBlockedAttachments Write FExceptionOnBlockedAttachments default False;
  Property AttachmentTempDirectory         : String                       Read FAttachmentTempDirectory       Write SetAttachmentTempDirectory;
  Property OnInitializeISO                 : TRESTDWInitializeIsoEvent    Read FOnInitializeISO               Write FOnInitializeISO;
  Property OnCreateAttachment              : TRESTDWCreateAttachmentEvent Read FOnCreateAttachment            Write FOnCreateAttachment;
 End;
 TRESTDWMessageEvent  = Procedure(ASender  : TComponent;
                                  Var AMsg : TRESTDWMessage) Of Object;
 eRESTDWTextInvalidCount  = Class(eRESTDWException);
 eRESTDWMessageCannotLoad = Class(eRESTDWException);

Const
 MessageFlags : Array [mfAnswered..mfRecent] Of String =('\Answered', '\Flagged',
                                                         '\Deleted',  '\Draft',
                                                         '\Seen',     '\Recent' );

 INREPLYTO    = 'In-Reply-To';

Implementation

Uses
 uRESTDWMessageCoderMIME, // Here so the 'MIME' in create will always suceed
 uRESTDWMessageCoder,
 uRESTDWAttachmentFile,
 uRESTDWTools,
 uRESTDWBasicTypes,
 uRESTDWConsts,
 uRESTDWMessageClient,
 SysUtils;

Const
 cPriorityStrs   : Array[TRESTDWMessagePriority] Of string = ('urgent', 'urgent', 'normal', 'non-urgent', 'non-urgent');
 cImportanceStrs : Array[TRESTDWMessagePriority] Of string = ('high', 'high', 'normal', 'low', 'low');


Procedure TRESTDWMIMEBoundary.Clear;
Begin
 FBoundaryList.Clear;
 FParentPartList.Clear;
End;

Function TRESTDWMIMEBoundary.Count: integer;
Begin
 Result := FBoundaryList.Count;
End;

Constructor TRESTDWMIMEBoundary.Create;
Begin
 Inherited;
 FBoundaryList := TStringList.Create;
 FParentPartList := TStringList.Create;
End;

Destructor TRESTDWMIMEBoundary.Destroy;
Begin
 FreeAndNil(FBoundaryList);
 FreeAndNil(FParentPartList);
 Inherited;
End;

Function TRESTDWMIMEBoundary.GetBoundary : String;
Begin
 If FBoundaryList.Count > 0 Then
  Result := FBoundaryList.Strings[0]
 Else
  Result := '';
End;

Function TRESTDWMIMEBoundary.GetParentPart : integer;
Begin
 If FParentPartList.Count > 0 Then
  Result := RDWStrToInt(FParentPartList.Strings[0])
 Else
  Result := -1;
End;

Procedure TRESTDWMIMEBoundary.Pop;
Begin
 If FBoundaryList.Count > 0   Then
  FBoundaryList.Delete(0);
 If FParentPartList.Count > 0 Then
  FParentPartList.Delete(0);
End;

Procedure TRESTDWMIMEBoundary.Push(ABoundary   : String;
                                   AParentPart : Integer);
Begin
 FBoundaryList.Insert(0, ABoundary);
 FParentPartList.Insert(0, IntToStr(AParentPart));
End;

Procedure TRESTDWMessage.AddHeader(Const AValue : String);
Begin
 FHeaders.Add(AValue);
End;

Procedure TRESTDWMessage.Clear;
Begin
 ClearHeader;
 ClearBody;
 FText := '';
End;

Procedure TRESTDWMessage.ClearBody;
Begin
 MessageParts.Clear;
 Body.Clear;
end;

Procedure TRESTDWMessage.ClearHeader;
Begin
 Date := 0;
 References := '';
 Priority := RESTDW_MSG_PRIORITY;
 FContentType := '';
 FCharSet := '';
 ContentTransferEncoding := '';
 ContentDisposition := '';
 Headers.Clear;
 ExtraHeaders.Clear;
 FMIMEBoundary.Clear;
//  UseNowForDate := RESTDW_MSG_USENOWFORDATE;
 Flags := [];
 UID := '';
 FLastGeneratedHeaders.Clear;
 FEncoding := meDefault; {CC3: Changed initial encoding from meMIME to meDefault}
 FConvertPreamble := True;  {By default, in MIME, we convert the preamble text to the 1st TRESTDWText part}
 FSavingToFile := False;  {Only set True by SaveToFile}
 FIsMsgSinglePartMime := False;
End;

Constructor TRESTDWMessage.Create(AOwner: TComponent);
Begin
 Inherited;
 FBody := TStringList.Create;
 TStringList(FBody).Duplicates := dupAccept;
 FMessageParts                 := TRESTDWMessageParts.Create(Self);
 FNewsGroups                   := TStringList.Create;
 FHeaders                      := TRESTDWHeaderList.Create(QuoteRFC822);
 FExtraHeaders                 := TRESTDWHeaderList.Create(QuoteRFC822);
 NoDecode                      := RESTDW_MSG_NODECODE;
 FMIMEBoundary                 := TRESTDWMIMEBoundary.Create;
 FLastGeneratedHeaders         := TRESTDWHeaderList.Create(QuoteRFC822);
 FText                         := '';
 Clear;
 FEncoding := meDefault;
End;

Destructor TRESTDWMessage.Destroy;
Begin
 FreeAndNil(FBody);
 FreeAndNil(FMessageParts);
 FreeAndNil(FNewsGroups);
 FreeAndNil(FHeaders);
 FreeAndNil(FExtraHeaders);
 FreeAndNil(FMIMEBoundary);
 FreeAndNil(FLastGeneratedHeaders);
 Inherited Destroy;
End;

Function  TRESTDWMessage.IsBodyEmpty: Boolean;
Var
 LN,
 LOrd : Integer;
Begin
 Result := False;
 For LN := 1 To Length(Body.Text) Do
  Begin
   LOrd := Ord(Body.Text[LN]);
   If ((LOrd <> 13) And (LOrd <> 10)  And
       (LOrd <> 9)  And (LOrd <> 32)) Then
    Exit;
  End;
 Result := True;
End;

Procedure TRESTDWMessage.GenerateHeader;
Var
 LReceiptRecipient,
 ISOCharset,
 LEncoding,
 LCharSet,
 LMIMEBoundary      : String;
 HeaderEncoding     : Char;
 LN                 : Integer;
 LDate              : TDateTime;
Begin
 MessageParts.CountParts;
 If Encoding = meDefault Then
  Begin
   If MessageParts.Count = 0 Then
    Encoding := mePlainText
   Else
    Encoding := meMIME;
  End;
 For LN := 0 To MessageParts.Count-1 Do
  Begin
   LEncoding := MessageParts[LN].ContentTransfer;
   If LEncoding <> '' Then
    Begin
     If Encoding = meMIME Then
      Begin
       If PosInStrArray(LEncoding, ['7bit', '8bit', 'binary', 'base64', 'quoted-printable', 'binhex40'], False) = -1 Then
        MessageParts[LN].ContentTransfer := 'base64';                 {do not localize}
      End
     Else If PosInStrArray(LEncoding, ['UUE', 'XXE'], False) = -1 Then
      MessageParts[LN].ContentTransfer := 'UUE';                    {do not localize}
    End;
  End;
 If MessageParts.Count > 0 Then
  Begin
   If (ContentTransferEncoding <> '') And
      (PosInStrArray(ContentTransferEncoding, ['7bit', '8bit', 'binary'], False) = -1) Then
    ContentTransferEncoding := '';
  End;
 If Encoding = meMIME Then
  Begin
   MIMEBoundary.Clear;
   LMIMEBoundary := TRESTDWMIMEBoundaryStrings.GenerateBoundary;
   MIMEBoundary.Push(LMIMEBoundary, -1);  //-1 is "top level"
   If Length(ContentType) = 0 Then
    Begin
     If MessageParts.TextPartCount > 1 Then
      Begin
       If MessageParts.AttachmentCount > 0 Then
        ContentType := 'multipart/mixed'
       Else
        ContentType := 'multipart/alternative';   {do not localize}
      End
     Else
      Begin
       If MessageParts.AttachmentCount > 0 Then
        ContentType := 'multipart/mixed'
       Else
        ContentType := 'text/plain';    {do not localize}
      End;
    End;
   TRESTDWMessageEncoderInfo(MessageParts.MessageEncoderInfo).InitializeHeaders(Self);
  End;
 FLastGeneratedHeaders.Assign(FHeaders);
 FIsMsgSinglePartMime := (Encoding = meMIME) and (MessageParts.Count = 1) and IsBodyEmpty;
 If Encoding = meMIME Then
  Begin
   If IsMsgSinglePartMime Then
    Begin
     FLastGeneratedHeaders.Values['MIME-Version'] := '1.0'; {do not localize}
     FLastGeneratedHeaders.Values['Content-Type'] := '';
     FLastGeneratedHeaders.Values['Content-Transfer-Encoding'] := '';
     FLastGeneratedHeaders.Values['Content-Disposition'] := '';
    End
   Else
    Begin
     If FContentType <> '' Then
      Begin
       LCharSet := FCharSet;
       If (LCharSet = '') And
           IsHeaderMediaType(FContentType, 'text') Then
        LCharSet := 'us-ascii';  {do not localize}
       FLastGeneratedHeaders.Values['Content-Type'] := FContentType;  {do not localize}
       FLastGeneratedHeaders.Params['Content-Type', 'charset'] := LCharSet;  {do not localize}
       If (MessageParts.Count > 0) And
          (LMIMEBoundary <> '')    Then
        FLastGeneratedHeaders.Params['Content-Type', 'boundary'] := LMIMEBoundary;  {do not localize}
      End;
     FLastGeneratedHeaders.Values['MIME-Version'] := '1.0'; {do not localize}
     FLastGeneratedHeaders.Values['Content-Transfer-Encoding'] := ContentTransferEncoding; {do not localize}
    End;
  End
 Else
  Begin
   LCharSet := FCharSet;
   If (LCharSet = '') And
      IsHeaderMediaType(FContentType, 'text') Then
    LCharSet := 'us-ascii';  {do not localize}
   FLastGeneratedHeaders.Values['Content-Type'] := FContentType;  {do not localize}
   FLastGeneratedHeaders.Params['Content-Type', 'charset'] := LCharSet;  {do not localize}
   FLastGeneratedHeaders.Values['Content-Transfer-Encoding'] := ContentTransferEncoding; {do not localize}
  End;
 FLastGeneratedHeaders.Values['Disposition-Notification-To'] := LReceiptRecipient; {do not localize}
 FLastGeneratedHeaders.Values['Return-Receipt-To'] := LReceiptRecipient; {do not localize}
 FLastGeneratedHeaders.Values['References'] := References; {do not localize}
 If UseNowForDate Then
  LDate := Now
 Else
  LDate := Self.Date;
// FLastGeneratedHeaders.Values['Date'] := LocalDateTimeToGMT(LDate); {do not localize}
 If Priority <> mpNormal Then
  Begin
   FLastGeneratedHeaders.Values['Priority'] := cPriorityStrs[Priority]; {do not localize}
   FLastGeneratedHeaders.Values['X-Priority'] := IntToStr(Ord(Priority) + 1); {do not localize}
   FLastGeneratedHeaders.Values['Importance'] := cImportanceStrs[Priority]; {do not localize}
  End
 Else
  Begin
   FLastGeneratedHeaders.Values['Priority'] := '';    {do not localize}
   FLastGeneratedHeaders.Values['X-Priority'] := '';    {do not localize}
   FLastGeneratedHeaders.Values['Importance'] := '';    {do not localize}
  End;
 If (FExtraHeaders.Count > 0) Then
  FLastGeneratedHeaders.AddStrings(FExtraHeaders);
End;

Procedure TRESTDWMessage.ProcessHeaders;
Var
 LBoundary,
 LMIMEVersion : String;
 Function GetMsgPriority(APriority: string): TRESTDWMessagePriority;
 Var
  s   : String;
  Num : Integer;
 Begin
  APriority := LowerCase(APriority);
  If (restdwPos('non-urgent', APriority) <> 0) Or {do not localize}
     (restdwPos('low', APriority) <> 0)        Then {do not localize}
   Result := mpLowest
  Else if (restdwPos('urgent', APriority) <> 0) Or {do not localize}
          (restdwPos('high', APriority) <> 0)   Then {do not localize}
   Result := mpHighest
  Else
   Begin
    s := Trim(APriority);
    Num := RDWStrToInt(Fetch(s, ' '), 3); {do not localize}
    If (Num < 1) Or
       (Num > 5) Then
     Num := 3;
    Result := TRESTDWMessagePriority(Num - 1);
   End;
 End;
Begin
 FContentType := Headers.Values['Content-Type']; {do not localize}
 If FContentType = '' Then
  Begin
   FContentType := 'text/plain';  {do not localize}
   FCharSet := 'us-ascii';  {do not localize}
  End
 Else
  Begin
   FContentType := RemoveHeaderEntry(FContentType, 'charset', FCharSet, QuoteMIME);  {do not localize}
   If (FCharSet = '') And
      IsHeaderMediaType(FContentType, 'text') Then
    FCharSet := 'us-ascii';  {do not localize}
  End;

  ContentTransferEncoding := Headers.Values['Content-Transfer-Encoding']; {do not localize}
  ContentDisposition := Headers.Values['Content-Disposition'];  {do not localize}
  References := Headers.Values['References']; {do not localize}
//  Date  := GMTToLocalDateTime(Headers.Values['Date']); {do not localize}
  FText := Headers.Values['Sender']; {do not localize}
  If Length(Headers.Values['X-Priority']) > 0 Then
   Priority := GetMsgPriority(Headers.Values['X-Priority'])
  Else If Length(Headers.Values['Priority']) > 0 Then
   Priority := GetMsgPriority(Headers.Values['Priority'])
  Else If Length(Headers.Values['Importance']) > 0 Then
   Priority := GetMsgPriority(Headers.Values['Importance'])
  Else If Length(Headers.Values['X-MSMail-Priority']) > 0 Then
   Priority := GetMsgPriority(Headers.Values['X-MSMail-Priority'])
  Else
   Priority := mpNormal;
  FContentType := RemoveHeaderEntry(FContentType, 'boundary', LBoundary, QuoteMIME);  {do not localize}
  If LBoundary <> '' Then
   MIMEBoundary.Push(LBoundary, -1);
  LMIMEVersion := Headers.Values['MIME-Version']; {do not localize}
  If LMIMEVersion = '' Then
   Encoding := mePlainText
  Else
   Encoding := meMIME;
End;

Procedure TRESTDWMessage.SetBody(const AValue: TStrings);
Begin
 FBody.Assign(AValue);
End;

Procedure TRESTDWMessage.SetContentType(const AValue: String);
Var
 LCharSet : String;
Begin
 If AValue <> '' Then
  Begin
   FContentType := RemoveHeaderEntry(AValue, 'charset', LCharSet, QuoteMIME); {do not localize}
   If csReading In ComponentState Then
    Exit;
   If (LCharSet = '') And
      IsHeaderMediaType(FContentType, 'text') Then
    LCharSet := 'us-ascii'; {do not localize}
   If LCharSet <> ''  Then
    FCharSet := LCharSet;
  End
 Else
  Begin
   FContentType := 'text/plain'; {do not localize}
   If Not (csReading in ComponentState) Then
    FCharSet := 'us-ascii'; {do not localize}
  End;
End;

Procedure TRESTDWMessage.SetExtraHeaders(const AValue: TRESTDWHeaderList);
Begin
 FExtraHeaders.Assign(AValue);
End;

Procedure TRESTDWMessage.SetHeaders(const AValue: TRESTDWHeaderList);
Begin
 FHeaders.Assign(AValue);
End;

Function TRESTDWMessage.GetUseNowForDate: Boolean;
Begin
 Result := (FDate = 0);
End;

Procedure TRESTDWMessage.SetUseNowForDate(const AValue: Boolean);
Begin
 If GetUseNowForDate <> AValue Then
  Begin
   If AValue Then
    FDate := 0
   Else
    FDate := Now;
  End;
End;

Procedure TRESTDWMessage.SetAttachmentEncoding(const AValue: string);
Begin
 MessageParts.AttachmentEncoding := AValue;
End;

Function TRESTDWMessage.GetAttachmentEncoding : string;
Begin
 Result := MessageParts.AttachmentEncoding;
End;

Procedure TRESTDWMessage.SetEncoding(Const AValue : TRESTDWMessageEncoding);
Begin
 FEncoding := AValue;
 If AValue = meMIME Then
  AttachmentEncoding := 'MIME'
 Else
  AttachmentEncoding := 'UUE';    {do not localize}
End;

Procedure TRESTDWMessage.DoInitializeISO(Var VHeaderEncoding : Char;
                                         Var VCharSet        : String);
Begin
 If Assigned(FOnInitializeISO) Then
  FOnInitializeISO(VHeaderEncoding, VCharSet);//APR
End;

Procedure TRESTDWMessage.DoCreateAttachment(Const AHeaders  : TStrings;
                                            Var VAttachment : TRESTDWAttachment);
Begin
 VAttachment := Nil;
 If Assigned(FOnCreateAttachment) Then
  FOnCreateAttachment(Self, AHeaders, VAttachment);
 If VAttachment = Nil Then
  VAttachment := TRESTDWAttachmentFile.Create(MessageParts);
End;

Function TRESTDWMessage.IsBodyEncodingRequired : Boolean;
Var
 i,
 j : Integer;
 S : String;
Begin
 Result := False;//7bit
 For i:= 0 To FBody.Count - 1 Do
  Begin
   S := FBody[i];
   For j := 1 To Length(S) Do
    Begin
     If S[j] > #127 Then
      Begin
       Result := True;
       Exit;
      End;
    End;
  End;
End;

Procedure TRESTDWMessage.SetAttachmentTempDirectory(Const Value: string);
Begin
 If Value <> AttachmentTempDirectory Then
  FAttachmentTempDirectory := ExcludeTrailingPathDelimiter(Value);
End;

end.

