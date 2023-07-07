unit uRESTDWMessageCoder;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

uses
  Classes, SysUtils, uRESTDWAbout, uRESTDWMessage, uRESTDWTools, uRESTDWConsts, uRESTDWException;

  Type
   TRESTDWMessageCoderPartType = (mcptText, mcptAttachment, mcptIgnore, mcptEOF);
   TRESTDWMessageDecoder       = Class(TRESTDWComponent)
  Protected
   FFilename         : String;
   FFreeSourceStream : Boolean;
   FHeaders          : TStrings;
   FPartType         : TRESTDWMessageCoderPartType;
   FSourceStream     : TStream;
  Public
   Constructor Create  (AOwner      : TComponent);Override;
   Function    ReadBody(ADestStream : TStream;
                        Var AMsgEnd : Boolean)  : TRESTDWMessageDecoder; Virtual; Abstract;
   Procedure   ReadHeader; Virtual;
   Function    ReadLn   (Const ATerminator      : String = LF)  : String;
   Function    ReadLnRFC(Var   VMsgEnd          : Boolean)      : String; Overload;
   Function    ReadLnRFC(Var   VMsgEnd          : Boolean;
                         Const ALineTerminator  : String;
                         Const ADelim           : String = '.') : String; Overload;
   Destructor  Destroy;  Override;
   Property Filename         : String                      Read FFilename;
   Property FreeSourceStream : Boolean                     Read FFreeSourceStream Write FFreeSourceStream;
   Property Headers          : TStrings                    Read FHeaders;
   Property PartType         : TRESTDWMessageCoderPartType Read FPartType;
   Property SourceStream     : TStream                     Read FSourceStream     Write FSourceStream;
  End;
  TRESTDWMessageDecoderInfo = Class
  Public
   Function    CheckForStart(ASender     : TRESTDWMessage;
                             Const ALine : String) : TRESTDWMessageDecoder; Virtual; Abstract;
   Constructor Create; Virtual;
  End;
  TRESTDWMessageDecoderList = Class
  Protected
   FMessageCoders : TStrings;
  Public
   Class Function ByName       (Const AName : String) : TRESTDWMessageDecoderInfo;
   Class Function CheckForStart(ASender     : TRESTDWMessage;
                                const ALine : String) : TRESTDWMessageDecoder;
   Constructor Create;
   Destructor Destroy; override;
   Class Procedure RegisterDecoder(Const AMessageCoderName : String;
                                   AMessageCoderInfo       : TRESTDWMessageDecoderInfo);
  End;
  TRESTDWMessageEncoder = Class(TRESTDWComponent)
  Protected
   FFilename       : String;
   FPermissionCode : Integer;
  Public
   Constructor Create(AOwner          : TComponent);Override;
   Procedure   Encode(Const AFilename : String;
                      ADest           : TStream);   Overload;
   Procedure   Encode(ASrc            : TStream;
                      ADest           : TStrings);  Overload;
   Procedure   Encode(ASrc            : TStream;
                      ADest           : TStream);   Overload; Virtual; Abstract;
  Published
   Property    Filename       : String  Read FFilename       Write FFilename;
   Property    PermissionCode : Integer Read FPermissionCode Write FPermissionCode;
  End;
  TRESTDWMessageEncoderClass = Class Of TRESTDWMessageEncoder;
  TRESTDWMessageEncoderInfo  = Class
  Protected
   FMessageEncoderClass : TRESTDWMessageEncoderClass;
  Public
   Constructor Create; Virtual;
   Procedure InitializeHeaders(AMsg : TRESTDWMessage); Virtual;
   Property  MessageEncoderClass    : TRESTDWMessageEncoderClass Read FMessageEncoderClass;
  End;
  TRESTDWMessageEncoderList = Class
  Protected
   FMessageCoders : TStrings;
  Public
   Class Function ByName          (Const AName               : String): TRESTDWMessageEncoderInfo;
   Constructor Create;
   Destructor Destroy; override;
   Class Procedure RegisterEncoder(Const AMessageEncoderName : String;
                                   AMessageEncoderInfo       : TRESTDWMessageEncoderInfo);
  End;

Implementation

Uses uRESTDWMessageCoderMIME, uRESTDWBuffer, uRESTDWBasicTypes, uRESTDWProtoTypes;

var
  GMessageDecoderList: TRESTDWMessageDecoderList = nil;
  GMessageEncoderList: TRESTDWMessageEncoderList = nil;

Class Function TRESTDWMessageDecoderList.ByName(Const AName : String): TRESTDWMessageDecoderInfo;
Var
 I : Integer;
Begin
 Result := nil;
 If GMessageDecoderList <> Nil Then
  Begin
   I := GMessageDecoderList.FMessageCoders.IndexOf(AName);
   If I <> -1 Then
    Result := TRESTDWMessageDecoderInfo(GMessageDecoderList.FMessageCoders.Objects[I]);
  End;
 If Result = Nil Then
  Raise eRESTDWException.Create(cMessageDecoderNotFound + ': ' + AName);
End;

Class Function TRESTDWMessageDecoderList.CheckForStart(ASender     : TRESTDWMessage;
                                                       const ALine : String) : TRESTDWMessageDecoder;
Var
 i : Integer;
Begin
 Result := Nil;
 If GMessageDecoderList <> Nil Then
  Begin
   For i := 0 To GMessageDecoderList.FMessageCoders.Count - 1 Do
    Begin
     Result := TRESTDWMessageDecoderInfo(GMessageDecoderList.FMessageCoders.Objects[i]).CheckForStart(ASender, ALine);
     If Result <> Nil Then
      Break;
    End;
  End;
End;

Constructor TRESTDWMessageDecoderList.Create;
Begin
 Inherited;
 FMessageCoders := TStringList.Create;
End;

Destructor TRESTDWMessageDecoderList.Destroy;
{$IFNDEF USE_OBJECT_ARC}
Var
 i : integer;
{$ENDIF}
Begin
  {$IFNDEF USE_OBJECT_ARC}
  For i := 0 To FMessageCoders.Count - 1 Do
   TRESTDWMessageDecoderInfo(FMessageCoders.Objects[i]).Free;
  {$ENDIF}
 FreeAndNil(FMessageCoders);
 Inherited Destroy;
End;

Class Procedure TRESTDWMessageDecoderList.RegisterDecoder(Const AMessageCoderName : String;
                                                          AMessageCoderInfo       : TRESTDWMessageDecoderInfo);
Begin
 If GMessageDecoderList = Nil Then
  GMessageDecoderList := TRESTDWMessageDecoderList.Create;
 GMessageDecoderList.FMessageCoders.AddObject(AMessageCoderName, AMessageCoderInfo);
End;

Constructor TRESTDWMessageDecoderInfo.Create;
Begin
 Inherited Create;
End;

Constructor TRESTDWMessageDecoder.Create(AOwner : TComponent);
Begin
 Inherited;
 FFreeSourceStream := True;
 FHeaders := TStringList.Create;
End;

Destructor TRESTDWMessageDecoder.Destroy;
Begin
 FreeAndNil(FHeaders);
 If FFreeSourceStream Then
  FreeAndNil(FSourceStream)
 Else
  FSourceStream := nil;
 Inherited Destroy;
End;

Procedure TRESTDWMessageDecoder.ReadHeader;
Begin
End;

Function DoReadLnFromStream(AStream        : TStream;
                            ATerminator    : String;
                            AMaxLineLength : Integer = -1) : String;
Const
 LBUFMAXSIZE = 2048;
Var
 LBuffer        : TRESTDWBuffer;
 LSize,
 LStartPos,
 LTermPos       : Integer;
 LTerm, LTemp   : TRESTDWBytes;
 LStrmStartPos,
 LStrmPos,
 LStrmSize      : TRESTDWStreamSize;
Begin
 Assert(AStream<>nil);
 LTerm         := Nil;
 LStrmStartPos := AStream.Position;
 LStrmPos      := LStrmStartPos;
 LStrmSize     := AStream.Size;
 If LStrmPos   >= LStrmSize Then
  Begin
   Result := '';
   Exit;
  End;
 SetLength(LTemp, LBUFMAXSIZE);
 LBuffer := TRESTDWBuffer.Create;
 Try
  If AMaxLineLength < 0 Then
   AMaxLineLength := MaxInt;
  If ATerminator = '' Then
   ATerminator := LF;
  LTerm := ToBytes(ATerminator);
  LTermPos := -1;
  LStartPos := 0;
  Repeat
   LSize := restdwMin(LStrmSize - LStrmPos, LBUFMAXSIZE);
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
   LStartPos := restdwMax(LBuffer.Size-(restdwLength(LTerm)-1), 0);
   If (AMaxLineLength > 0) And
      (LStartPos >= AMaxLineLength) Then
    Begin
     LStrmPos := LStrmStartPos + AMaxLineLength;
     LTermPos := AMaxLineLength;
     Break;
    End;
  Until LStrmPos >= LStrmSize;
  If (ATerminator = LF) And
     (LTermPos > 0)     And
     (LTermPos < LBuffer.Size) Then
   Begin
    If (LBuffer.PeekByte(LTermPos) = Ord(LF))   And
       (LBuffer.PeekByte(LTermPos-1) = Ord(CR)) Then
     Dec(LTermPos);
   End;
  AStream.Position := LStrmPos;
  Result := LBuffer.ExtractToString(LTermPos);
 Finally
  LBuffer.Free;
 End;
End;

Function TRESTDWMessageDecoder.ReadLn(Const ATerminator : String = LF) : String;
Begin
 Result := DoReadLnFromStream(SourceStream, ATerminator, -1);
End;

Function TRESTDWMessageDecoder.ReadLnRFC(Var VMsgEnd : Boolean): String;
Begin
 Result := ReadLnRFC(VMsgEnd, LF, '.');
End;

Function TRESTDWMessageDecoder.ReadLnRFC(Var VMsgEnd           : Boolean;
                                         Const ALineTerminator : String;
                                         Const ADelim          : String = '.') : String;
Begin
 Result := ReadLn(ALineTerminator);
 If Result = ADelim Then {do not localize}
  Begin
   VMsgEnd := True;
   Exit;
  end;
 If TextStartsWith(Result, '..') Then
  Delete(Result, 1, 1);
 VMsgEnd := False;
end;

Constructor TRESTDWMessageEncoderInfo.Create;
Begin
 Inherited Create;
End;

Procedure TRESTDWMessageEncoderInfo.InitializeHeaders(AMsg: TRESTDWMessage);
Begin
//
End;

Class Function TRESTDWMessageEncoderList.ByName(Const AName : String) : TRESTDWMessageEncoderInfo;
Var
 I : Integer;
Begin
 Result := nil;
 If GMessageEncoderList <> Nil Then
  Begin
   I := GMessageEncoderList.FMessageCoders.IndexOf(AName);
   If I <> -1 Then
    Result := TRESTDWMessageEncoderInfo(GMessageEncoderList.FMessageCoders.Objects[I]);
  End;
 If Result = Nil Then
  Raise eRESTDWException.Create(cMessageEncoderNotFound + ': ' + AName);
End;

Constructor TRESTDWMessageEncoderList.Create;
Begin
 Inherited;
 FMessageCoders := TStringList.Create;
End;

Destructor TRESTDWMessageEncoderList.Destroy;
{$IFNDEF USE_OBJECT_ARC}
Var
 i : Integer;
{$ENDIF}
Begin
 {$IFNDEF USE_OBJECT_ARC}
  For i := 0 To FMessageCoders.Count - 1 Do
   TRESTDWMessageEncoderInfo(FMessageCoders.Objects[i]).Free;
 {$ENDIF}
 FreeAndNil(FMessageCoders);
 Inherited Destroy;
End;

Class Procedure TRESTDWMessageEncoderList.RegisterEncoder(Const AMessageEncoderName : String;
                                                          AMessageEncoderInfo       : TRESTDWMessageEncoderInfo);
Begin
 If GMessageEncoderList = Nil Then
  GMessageEncoderList := TRESTDWMessageEncoderList.Create;
 GMessageEncoderList.FMessageCoders.AddObject(AMessageEncoderName, AMessageEncoderInfo);
End;

Procedure TRESTDWMessageEncoder.Encode(Const AFilename : String;
                                       ADest           : TStream);
Var
 LSrcStream : TStream;
Begin
 LSrcStream := TRESTDWReadFileExclusiveStream.Create(AFileName);
 Try
  Encode(LSrcStream, ADest);
 Finally
  FreeAndNil(LSrcStream);
 End;
End;

Procedure TRESTDWMessageEncoder.Encode(ASrc  : TStream;
                                       ADest : TStrings);
Var
 LDestStream : TStream;
Begin
 LDestStream := TMemoryStream.Create;
 Try
  Encode(ASrc, LDestStream);
  LDestStream.Position := 0;
  ADest.LoadFromStream(LDestStream);
 Finally
  FreeAndNil(LDestStream);
 End;
End;

Constructor TRESTDWMessageEncoder.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 FPermissionCode := 660;
End;

Initialization
Finalization
 FreeAndNil(GMessageDecoderList);
 FreeAndNil(GMessageEncoderList);
End.
