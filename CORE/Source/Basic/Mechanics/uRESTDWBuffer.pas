unit uRESTDWBuffer;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
  Classes, SysUtils, uRESTDWException, uRESTDWBasicTypes, uRESTDWProtoTypes, uRESTDWTools;

Type
 eRESTDWNotEnoughDataInBuffer = Class(eRESTDWException);
 eRESTDWTooMuchDataInBuffer   = Class(eRESTDWException); // only 2GB is allowed -
 TRESTDWBufferBytesRemoved    = Procedure(ASender : TObject;
                                          ABytes  : Integer) of object;

 TRESTDWBuffer = Class(TObject)
 Private
  Function GetAsString : String;
 Protected
  FBytes          : TRESTDWBytes;
  FSize,
  FGrowthFactor,
  FHeadIndex      : Integer;
  FOnBytesRemoved : TRESTDWBufferBytesRemoved;
  Procedure CheckAdd      (AByteCount     : Integer;
                           Const AIndex   : Integer);
  Procedure CheckByteCount(Var VByteCount : Integer;
                           Const AIndex   : Integer);
  Function  GetCapacity           : Integer;
  Procedure SetCapacity   (AValue : Integer);
 Public
  Procedure Clear;
  Constructor Create; Overload;
  Constructor Create (AOnBytesRemoved : TRESTDWBufferBytesRemoved); Overload;
  Constructor Create (AGrowthFactor   : Integer);      Overload;
  Constructor Create (Const ABytes    : TRESTDWBytes;
                      Const ALength   : Integer = -1); Overload;
  Procedure CompactHead(ACanShrink    : Boolean = True);
  Destructor Destroy; override;
  Function   ExtractToString (AByteCount    : Integer = -1) : String;
  Procedure  ExtractToStream (Const AStream : TStream;
                              AByteCount    : Integer = -1;
                              Const AIndex  : Integer = -1);
  Procedure  ExtractToBuffer (ABuffer       : TRESTDWBuffer;
                              AByteCount    : Integer = -1;
                              Const AIndex  : Integer = -1);
  Procedure  ExtractToBytes  (Var VBytes    : TRESTDWBytes;
                              AByteCount    : Integer = -1;
                              AAppend       : Boolean = True;
                              AIndex        : Integer = -1);
  Function   IndexOf         (Const AByte   : Byte;
                              AStartPos     : Integer = 0)  : Integer; Overload;
  Function   IndexOf         (Const ABytes  : TRESTDWBytes;
                              AStartPos     : Integer = 0)  : Integer; Overload;
  Function   IndexOf         (Const AString : String;
                              AStartPos     : Integer = 0)  : Integer; Overload;
  Function   PeekByte        (AIndex        : Integer)      : Byte;
  Procedure  Remove          (AByteCount    : Integer);
  Procedure  SaveToStream    (Const AStream : TStream);
  Procedure  Write           (Const AString : String;
                              Const ADestIndex : Integer = -1);        Overload;
  Procedure  Write           (Const ABytes     : TRESTDWBytes;
                              Const ADestIndex : Integer = -1);        Overload;
  Procedure  Write           (Const ABytes     : TRESTDWBytes;
                              Const ALength,
                              AOffset          : Integer;
                              Const ADestIndex : Integer = -1);        Overload;
  Procedure  Write           (AStream          : TStream;
                              AByteCount       : Integer = 0);         Overload;
  Property   Capacity     : Integer Read GetCapacity   Write SetCapacity;
  Property   GrowthFactor : Integer Read FGrowthFactor Write FGrowthFactor;
  Property   Size         : Integer Read FSize;
  Property   AsString     : String  Read GetAsString;
 End;

implementation

Uses uRESTDWConsts;

Procedure TRESTDWBuffer.CheckAdd(AByteCount   : Integer;
                                 Const AIndex : Integer);
Begin
 If (MaxInt - AByteCount) < (Size + AIndex) Then
  Raise eRESTDWTooMuchDataInBuffer.Create(cTooMuchDataInBuffer);
End;

Procedure TRESTDWBuffer.CheckByteCount(Var VByteCount : Integer;
                                       Const AIndex   : Integer);
Begin
 If VByteCount = -1 Then
  VByteCount := Size+AIndex
 Else If VByteCount > (Size+AIndex) Then
  Raise eRESTDWNotEnoughDataInBuffer.CreateFmt('%s (%d/%d)', [cNotEnoughDataInBuffer, VByteCount, Size]); {do not localize}
End;

Procedure TRESTDWBuffer.Clear;
Begin
 SetLength(FBytes, 0);
 FHeadIndex := 0;
 FSize := restdwLength(FBytes);
End;

Constructor TRESTDWBuffer.Create(AGrowthFactor : Integer);
Begin
 Create;
 FGrowthFactor := AGrowthFactor;
End;

Constructor TRESTDWBuffer.Create(AOnBytesRemoved : TRESTDWBufferBytesRemoved);
Begin
 Create;
 FOnBytesRemoved := AOnBytesRemoved;
End;

Constructor TRESTDWBuffer.Create(Const ABytes  : TRESTDWBytes;
                                 Const ALength : Integer);
Begin
 Create;
 If ALength < 0 Then
  Begin
   FBytes := ABytes;
   FSize  := restdwLength(ABytes);
  End
 Else
  Begin
   SetLength(FBytes, ALength);
   If ALength > 0 Then
    Begin
     CopyBytes(ABytes, 0, FBytes, 0, ALength);
     FSize := ALength;
    End;
  End;
End;

Destructor TRESTDWBuffer.Destroy;
Begin
 Clear;
 Inherited Destroy;
End;

Function TRESTDWBuffer.ExtractToString(AByteCount: Integer = -1) : String;
Var
 LBytes: TRESTDWBytes;
Begin
 If AByteCount < 0 Then
  AByteCount := Size;
 If AByteCount > 0 Then
  Begin
   ExtractToBytes(LBytes, AByteCount);
   Result := BytesToString(LBytes);
  End
 Else
  Result := '';
End;

Procedure TRESTDWBuffer.ExtractToBytes(Var VBytes : TRESTDWBytes;
                                       AByteCount : Integer = -1;
                                       AAppend    : Boolean = True;
                                       AIndex     : Integer = -1);
Var
 LOldSize,
 LIndex   : Integer;
Begin
 If AByteCount < 0 Then
  AByteCount := Size;
 LIndex := restdwMax(AIndex, 0);
 If AByteCount > 0 Then
  Begin
   CheckByteCount(AByteCount, LIndex);
   If AAppend Then
    Begin
     LOldSize := restdwLength(VBytes);
     SetLength(VBytes, LOldSize + AByteCount);
    End
   Else
    Begin
     LOldSize := 0;
     If restdwLength(VBytes) < AByteCount Then
      SetLength(VBytes, AByteCount);
    End;
   If AIndex < 0 Then
    Begin
     CopyBytes(FBytes, FHeadIndex, VBytes, LOldSize, AByteCount);
     Remove(AByteCount);
    End
   Else
    CopyBytes(FBytes, AIndex, VBytes, LOldSize, AByteCount);
  End;
End;

Procedure TRESTDWBuffer.ExtractToBuffer(ABuffer      : TRESTDWBuffer;
                                        AByteCount   : Integer = -1;
                                        Const AIndex : Integer = -1);
Var
 LBytes : TRESTDWBytes;
Begin
 If AByteCount < 0 Then
  AByteCount := Size;
 ExtractToBytes(LBytes, AByteCount, True, AIndex);
 ABuffer.Write(LBytes);
End;

Procedure TRESTDWBuffer.ExtractToStream(Const AStream : TStream;
                                        AByteCount    : Integer = -1;
                                        Const AIndex  : Integer = -1);
Var
 LIndex : Integer;
 LBytes : TRESTDWBytes;
Begin
 If AByteCount < 0 Then
  AByteCount := Size;
 LIndex := restdwMax(AIndex, 0);
 If AIndex < 0 Then
  Begin
   CompactHead;
   CheckByteCount(AByteCount, LIndex);
   TRESTDWStreamHelper.Write(AStream, FBytes, AByteCount);
   Remove(AByteCount);
  End
 Else
  Begin
   CheckByteCount(AByteCount, LIndex);
   SetLength(LBytes, AByteCount);
   CopyBytes(FBytes, AIndex, LBytes, 0, AByteCount);
   TRESTDWStreamHelper.Write(AStream, LBytes, AByteCount);
  End;
End;

Procedure TRESTDWBuffer.Remove(AByteCount : Integer);
Begin
 If AByteCount >= Size Then
  Clear
 Else
  Begin
   Inc(FHeadIndex, AByteCount);
   Dec(FSize, AByteCount);
   If FHeadIndex > GrowthFactor Then
    CompactHead;
  End;
 If Assigned(FOnBytesRemoved) Then
  FOnBytesRemoved(Self, AByteCount);
End;

Procedure TRESTDWBuffer.CompactHead(ACanShrink: Boolean = True);
Begin
 If FHeadIndex > 0 Then
  Begin
   CopyBytes(FBytes, FHeadIndex, FBytes, 0, Size);
   FHeadIndex := 0;
   If ACanShrink And ((Capacity - Size - FHeadIndex) > GrowthFactor) Then
    SetLength(FBytes, FHeadIndex + Size + GrowthFactor);
  End;
End;

Procedure TRESTDWBuffer.Write(Const ABytes     : TRESTDWBytes;
                              Const ADestIndex : Integer = -1);{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
Begin
 Write(ABytes, restdwLength(ABytes), 0, ADestIndex);
End;

Procedure TRESTDWBuffer.Write(AStream    : TStream;
                              AByteCount : Integer);
Var
 LAdded,
 LLength : Integer;
Begin
 If AByteCount < 0 Then
  LAdded := AStream.Size - AStream.Position
 Else If AByteCount = 0 Then
  Begin
   AStream.Position := 0;
   LAdded := AStream.Size;
  End
 Else
  LAdded := restdwMin(AByteCount, AStream.Size - AStream.Position);
 If LAdded > 0 Then
  Begin
   LLength := Size;
   CheckAdd(LAdded, 0);
   CompactHead;
   SetLength(FBytes, LLength + LAdded);
   TRESTDWStreamHelper.ReadBytes(AStream, FBytes, LAdded, LLength);
   Inc(FSize, LAdded);
  End;
End;

Function TRESTDWBuffer.IndexOf(Const AString : String;
                               AStartPos     : Integer = 0) : Integer;
Begin
 Result := IndexOf(ToBytes(AString, AStartPos));
end;

Function TRESTDWBuffer.IndexOf(Const ABytes : TRESTDWBytes;
                               AStartPos    : Integer = 0) : Integer;
Var
 i, j,
 LEnd,
 BytesLen : Integer;
 LFound   : Boolean;
Begin
 Result := -1;
 If Size > 0 Then
  Begin
   If Length(ABytes) = 0  Then
    Raise eRESTDWException.Create(cBufferMissingTerminator);
   If (AStartPos < 0) Or
      (AStartPos >= Size) Then
    Raise eRESTDWException.Create(cBufferInvalidStartPos);
   BytesLen := Length(ABytes);
   LEnd := FHeadIndex + Size;
   For i := FHeadIndex + AStartPos To LEnd - BytesLen Do
    Begin
     LFound := True;
     For j := 0 To BytesLen - 1 Do
      Begin
       If (i + j) >= LEnd Then
        Break;
       If FBytes[i + j] <> ABytes[j] Then
        Begin
         LFound := False;
         Break;
        End;
      End;
     If LFound Then
      Begin
       Result := i - FHeadIndex;
       Break;
      End;
    End;
  End;
End;

Function TRESTDWBuffer.IndexOf(Const AByte : Byte;
                               AStartPos   : Integer = 0): Integer;
Var
 i : Integer;
Begin
 Result := -1;
 If Size > 0 Then
  Begin
   If (AStartPos < 0) Or (AStartPos >= Size) Then
    Raise eRESTDWException.Create(cBufferInvalidStartPos);
   For i := (FHeadIndex + AStartPos) To (FHeadIndex + Size - 1) Do
    Begin
     If FBytes[i] = AByte Then
      Begin
       Result := i - FHeadIndex;
       Break;
      End;
    End;
  End;
End;

Procedure TRESTDWBuffer.Write(Const AString    : String;
                              Const ADestIndex : Integer = -1);
Begin
 Write(ToBytes(AString, ADestIndex));
End;

Function TRESTDWBuffer.GetCapacity: Integer;
Begin
 Result := restdwLength(FBytes);
End;

Procedure TRESTDWBuffer.SetCapacity(AValue: Integer);
Begin
 If AValue < Size Then
  Raise eRESTDWException.Create('Capacity cannot be smaller than Size'); {do not localize}
 CompactHead;
 SetLength(FBytes, AValue);
End;

Constructor TRESTDWBuffer.Create;
Begin
 inherited Create;
 FGrowthFactor := 2048;
 Clear;
End;

Function TRESTDWBuffer.PeekByte(AIndex: Integer): Byte;
Begin
 If Size = 0 Then
  Raise eRESTDWException.Create('No bytes in buffer.'); {do not localize}
 If (AIndex < 0)     Or
    (AIndex >= Size) Then
  Raise eRESTDWException.Create('Index out of bounds.'); {do not localize}
 Result := FBytes[FHeadIndex + AIndex];
End;

Procedure TRESTDWBuffer.SaveToStream(Const AStream : TStream);
Begin
 CompactHead(False);
 TRESTDWStreamHelper.Write(AStream, FBytes, Size);
End;

Procedure TRESTDWBuffer.Write(Const ABytes     : TRESTDWBytes;
                              Const ALength,
                              AOffset          : Integer;
                              Const ADestIndex : Integer = -1);
Var
 LByteLength,
 LIndex       : Integer;
Begin
 LByteLength := restdwLength(ABytes, ALength, AOffset);
 If LByteLength = 0 Then
  Exit;
 LIndex := restdwMax(ADestIndex, 0);
 CheckAdd(LByteLength, LIndex);
 If Size = 0 Then
  Begin
   FHeadIndex := 0;
   If ADestIndex < 0 Then
    Begin
     FBytes := ToBytes(ABytes, LByteLength, AOffset);
     FSize := LByteLength;
    End
   Else
    Begin
     FSize := ADestIndex + LByteLength;
     SetLength(FBytes, FSize);
     CopyBytes(ABytes, AOffset, FBytes, ADestIndex, LByteLength);
    End;
  End
 Else If ADestIndex < 0 Then
  Begin
   CompactHead(False);
   If (Capacity - Size - FHeadIndex) < LByteLength Then
    SetLength(FBytes, Size + LByteLength + GrowthFactor);
   CopyBytes(ABytes, AOffset, FBytes, FHeadIndex + Size, LByteLength);
   Inc(FSize, LByteLength);
  End
 Else
  Begin
   CopyBytes(ABytes, AOffset, FBytes, LIndex, LByteLength);
   If LIndex >= FSize Then
    FSize := LIndex + LByteLength;
  End;
End;

Function TRESTDWBuffer.GetAsString: string;
Begin
 Result := BytesToString(FBytes);
End;

End.


