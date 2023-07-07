unit uRESTDWHeaderList;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 Classes, uRESTDWProtoTypes;

 Type
  TRESTDWHeaderList = class(TStringList)
 Protected
  FNameValueSeparator : String;
  FUnfoldLines,
  FFoldLines          : Boolean;
  FFoldLinesLength    : Integer;
  FQuoteType: TRESTDWHeaderQuotingType;
  Procedure AssignTo         (Dest        : TPersistent);Override;
  Procedure DeleteFoldedLines(Index       : Integer);
  Procedure FoldLineToList   (AString     : String;
                              ALines      : TStrings);
  Procedure FoldAndInsert    (AString     : String;
                              Index       : Integer);
  Function  GetName          (Index       : Integer) : String;
  Function  GetValue         (Const AName : String)  : String;
  Function  GetParam         (Const AName,
                              AParam      : String)  : String;
  Function  GetAllParams     (Const AName : String)  : String;
  Procedure SetValue         (Const AName,
                              AValue      : String);
  Procedure SetParam         (Const AName,
                              AParam,
                              AValue      : String);
  Procedure SetAllParams     (Const AName,
                              AValue      : String);
  Function  GetValueFromLine (Var VLine   : Integer) : String;
  procedure SkipValueAtLine  (Var VLine   : Integer);
 Public
  Procedure AddStrings       (aStrings    : TStrings); Override;
  Procedure AddStdValues     (ASrc        : TStrings);
  Procedure AddValue         (Const AName,
                              AValue       : String);
  Procedure ConvertToStdValues(ADest       : TStrings);
  Constructor Create          (AQuoteType  : TRESTDWHeaderQuotingType);
  Procedure   Extract         (Const AName : String;
                               ADest       : TStrings);
  Function    IndexOfName     (const AName : String) : Integer; Reintroduce;
  Property    Names [Index : Integer]           : String Read GetName;
  Property    Values[Const Name : String]       : String Read GetValue            Write SetValue;
  Property    Params[Const Name, Param: String] : String Read GetParam            Write SetParam;
  Property    AllParams[Const Name : String]    : String Read GetAllParams        Write SetAllParams;
  Property    NameValueSeparator   : String              Read FNameValueSeparator Write FNameValueSeparator;
  Property    UnfoldLines          : Boolean             Read FUnfoldLines        Write FUnfoldLines;
  Property    FoldLines            : Boolean             Read FFoldLines          Write FFoldLines;
  Property    FoldLength           : Integer             Read FFoldLinesLength    Write FFoldLinesLength;
 End;

Implementation

Uses
  SysUtils, uRESTDWException, uRESTDWTools;

Procedure TRESTDWHeaderList.AddStdValues(ASrc: TStrings);
Var
 I : integer;
Begin
 BeginUpdate;
 Try
  For I := 0 To ASrc.Count - 1 Do
   AddValue(ASrc.Names[i], restdwValueFromIndex(ASrc, i));
  Finally
   EndUpdate;
  End;
End;

Procedure TRESTDWHeaderList.AddValue(const AName, AValue: string);
Var
 I : Integer;
Begin
 If (AName <> '')  And
    (AValue <> '') Then
  Begin  {Do not Localize}
   I := Add('');    {Do not Localize}
   If FFoldLines Then
    FoldAndInsert(AName + FNameValueSeparator + AValue, I)
   Else
    Put(I, AName + FNameValueSeparator + AValue);
  End;
End;

Procedure TRESTDWHeaderList.AddStrings(aStrings: TStrings);
Begin
 If aStrings Is TRESTDWHeaderList Then
  Inherited AddStrings(aStrings)
 Else
  AddStdValues(aStrings);
End;

Procedure TRESTDWHeaderList.AssignTo(Dest: TPersistent);
Begin
 If (Dest Is TStrings)              And
    Not (Dest Is TRESTDWHeaderList) Then
  ConvertToStdValues(TStrings(Dest))
 Else
  Inherited AssignTo(Dest);
End;

Procedure TRESTDWHeaderList.ConvertToStdValues(ADest: TStrings);
Var
 idx    : Integer;
 LName,
 LValue : String;
Begin
 ADest.BeginUpdate;
 Try
  idx := 0;
  While idx < Count Do
   Begin
    LName  := GetName(idx);
    LValue := GetValueFromLine(idx);
    ADest.Add(LName + '=' + LValue); {do not localize}
   End;
 Finally
  ADest.EndUpdate;
 End;
End;

Constructor TRESTDWHeaderList.Create(AQuoteType: TRESTDWHeaderQuotingType);
Begin
 Inherited Create;
 FNameValueSeparator := ': ';    {Do not Localize}
 FUnfoldLines := True;
 FFoldLines := True;
 FFoldLinesLength := iif(AQuoteType = QuoteHTTP, MaxInt, 78);
 FQuoteType := AQuoteType;
End;

Procedure TRESTDWHeaderList.DeleteFoldedLines(Index: Integer);
Begin
 Inc(Index);  {skip the current line}
 If Index < Count Then
  Begin
   While (Index < Count) And
         CharIsInSet(Get(Index), 1, LWS) Do
    Delete(Index);
  End;
End;

Procedure TRESTDWHeaderList.Extract(const AName: string; ADest: TStrings);
Var
 idx : Integer;
Begin
 If Assigned(ADest) Then
  Begin
   ADest.BeginUpdate;
   Try
    idx := 0;
    While idx < Count Do
     Begin
      If TextIsSame(AName, GetName(idx)) Then
       ADest.Add(GetValueFromLine(idx))
      Else
       SkipValueAtLine(idx);
     End;
   Finally
    ADest.EndUpdate;
   End;
  End;
End;

Procedure TRESTDWHeaderList.FoldAndInsert(AString : String; Index: Integer);
Var
 LStrs : TStrings;
 idx   : Integer;
Begin
 LStrs := TStringList.Create;
 Try
  FoldLineToList(AString, LStrs);
  idx := LStrs.Count - 1;
  Put(Index, LStrs[idx]);
  Dec(idx);
  While idx > -1 Do
   Begin
    Insert(Index, LStrs[idx]);
    Dec(idx);
   End;
 Finally
  FreeAndNil(LStrs);
 End;  //finally
End;

Procedure TRESTDWHeaderList.FoldLineToList(AString : string; ALines: TStrings);
Var
 s : String;
Begin
 s := WrapText(AString, EOL+' ', LWS+',', FFoldLinesLength);    {Do not Localize}
 If s <> '' Then
  Begin
   ALines.BeginUpdate;
   Try
    Repeat
     ALines.Add(TrimRight(Fetch(s, EOL)));
    Until s = '';  {Do not Localize};
   Finally
    ALines.EndUpdate;
   End;
  End;
End;

Function TRESTDWHeaderList.GetName(Index: Integer) : String;
Var
 I : Integer;
Begin
 Result := Get(Index);
 I := InternalAnsiPos(TrimRight(FNameValueSeparator), Result);
 If I <> 0 Then
  SetLength(Result, I - 1)
 Else
  SetLength(Result, 0);
End;

Function TRESTDWHeaderList.GetValue(Const AName : String) : String;
Var
 idx : Integer;
Begin
 idx    := IndexOfName(AName);
 Result := GetValueFromLine(idx);
End;

Function TRESTDWHeaderList.GetValueFromLine(Var VLine : Integer) : String;
Var
 LLine,
 LSep   : string;
 P      : Integer;
Begin
 If (VLine >= 0)    And
    (VLine < Count) Then
  Begin
   LLine  := Get(VLine);
   Inc(VLine);
   LSep   := TrimRight(FNameValueSeparator);
   P      := InternalAnsiPos(LSep, LLine);
   Result := TrimLeft(Copy(LLine, P + Length(LSep), MaxInt));
   If FUnfoldLines Then
    Begin
     While VLine < Count Do
      Begin
       LLine := Get(VLine);
       If Not CharIsInSet(LLine, 1, LWS) Then
        Break;
       Result := Trim(Result) + ' ' + Trim(LLine); {Do not Localize}
       Inc(VLine);
      End;
    End;
   Result := Trim(Result);
  End
 Else
  Result := '';
End;

Procedure TRESTDWHeaderList.SkipValueAtLine(var VLine: Integer);
Begin
 If (VLine >= 0)    And
    (VLine < Count) Then
  Begin
   Inc(VLine);
   If FUnfoldLines Then
    Begin
     While VLine < Count Do
      Begin
       If Not CharIsInSet(Get(VLine), 1, LWS) Then
        Break;
       Inc(VLine);
      End;
    End;
  End;
End;

Function TRESTDWHeaderList.GetParam(Const AName, AParam : String) : String;
Var
 s          : String;
 LQuoteType : TRESTDWHeaderQuotingType;
Begin
 s := Values[AName];
 If s <> '' Then
  Begin
   LQuoteType := FQuoteType;
   Case LQuoteType Of
      QuoteRFC822 : Begin
                     If PosInStrArray(AName, ['Content-Type', 'Content-Disposition'], False) <> -1 Then
                      LQuoteType := QuoteMIME;
                    End;
      QuoteMIME   : Begin
                     If PosInStrArray(AName, ['Content-Type', 'Content-Disposition'], False) = -1 Then
                      LQuoteType := QuoteRFC822;
                    End;
   End;
   Result := ExtractHeaderSubItem(s, AParam, LQuoteType);
  End
 Else
  Result := '';
End;

Function TRESTDWHeaderList.GetAllParams(const AName: string): string;
Var
 s : String;
Begin
 s := Values[AName];
 If s <> '' Then
  Begin
   Fetch(s, ';'); {do not localize}
   Result := Trim(s);
  End
 Else
  Result := '';
End;

Function TRESTDWHeaderList.IndexOfName(const AName: string): Integer;
Var
 i : Integer;
Begin
 Result := -1;
 For i := 0 To Count - 1 Do
  Begin
   If TextIsSame(GetName(i), AName) Then
    Begin
     Result := i;
     Exit;
    end;
  End;
End;

Procedure TRESTDWHeaderList.SetValue(const AName, AValue: string);
Var
 I : Integer;
Begin
 I := IndexOfName(AName);
 If AValue <> '' Then
  Begin  {Do not Localize}
   If I < 0 Then
    I := Add('');    {Do not Localize}
   If FFoldLines Then
    Begin
     DeleteFoldedLines(I);
     FoldAndInsert(AName + FNameValueSeparator + AValue, I);
    End
   Else
    Put(I, AName + FNameValueSeparator + AValue);
  End
 Else if I >= 0 Then
  Begin
   If FFoldLines Then
    DeleteFoldedLines(I);
   Delete(I);
  End;
End;

Procedure TRESTDWHeaderList.SetParam(const AName, AParam, AValue: string);
Var
 LQuoteType : TRESTDWHeaderQuotingType;
Begin
 LQuoteType := FQuoteType;
 Case LQuoteType Of
  QuoteRFC822 : Begin
                 If PosInStrArray(AName, ['Content-Type', 'Content-Disposition'], False) <> -1 Then
                  LQuoteType := QuoteMIME;
                End;
  QuoteMIME   : Begin
                 If PosInStrArray(AName, ['Content-Type', 'Content-Disposition'], False) = -1 Then
                  LQuoteType := QuoteRFC822;
                End;
 End;
 Values[AName] := ReplaceHeaderSubItem(Values[AName], AParam, AValue, LQuoteType);
End;

Procedure TRESTDWHeaderList.SetAllParams(const AName, AValue: string);
Var
 LValue : String;
Begin
 LValue := Values[AName];
 If LValue <> '' Then
  Begin
   LValue := ExtractHeaderItem(LValue);
   If AValue <> '' Then
    LValue := LValue + '; ' + AValue; {do not localize}
   Values[AName] := LValue;
  End;
End;

end.
