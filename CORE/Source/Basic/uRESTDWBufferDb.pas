unit uRESTDWBufferDb;

{$I ..\..\Source\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

uses
 SysUtils, Variants, TypInfo, Classes, Db,
 uRESTDWConsts,uRESTDWFileBuffer, uRESTDWTools, uRESTDWBasicTypes, uRESTDWAbout;

Const                                      // \b  \t  \n   \f   \r
 TSpecialChars     : Array [0 .. 7] Of Char = ('\', '"', '/', #8, #9, #10, #12, #13);
 cReplaceLineBreak = '<|#%30#|>';
 cReplaceSeparator = '<|#%20#|>';
 TTagFile          = '<|#' + cTablenameTAG + '#|>';

Type
 TFileType        = (ftbFixedText, ftbCSVFile);
 TOnGetLineValue  = Procedure (LineNumber : Integer;
                               Line       : String;
                               Var Accept : Boolean)  Of Object;
 TOnSetLineValue  = Procedure (LineNumber : Integer;
                               Var Line   : String;
                               Var Accept,
                               Stop       : Boolean) Of Object;
 TOnReadData      = Procedure (Var Accept : Boolean) Of Object;
 TOnWriteData     = Procedure (Line       : String;
                               Var Accept : Boolean) Of Object;
 TOnGetFieldValue = Procedure (Self       : TObject;
                               Var Value  : String)  Of Object;
 TOnError         = Procedure (LineNumber : Integer;
                               Error      : String)  Of Object;
 TBeginProcess    = Procedure (LineNumber : Integer) Of Object;
 TEndProcess      = Procedure                        Of Object;

Type
 TMaskOptions = Class(TPersistent)
 Private
  vTimeMask,
  vNumberMask,
  vDateMask,
  vDateTimeMask,
  vReplaceLinebreakFor,
  vIntegerMask                 : String;
  vInsertChar,
  vTimeSeparator,
  vDateSeparator,
  vDecimalSeparator            : Char;
  vDefaultPrecision,
  vDefaultFieldSize            : Integer;
  vExcludeDecimalSeparator,
  vMemoToString,
  vDefaultInsertLeftChar       : Boolean;
 Public
  Procedure   Assign(Source    : TPersistent);  Override;
  Constructor Create;
 Published
  Property    InsertChar              : Char      Read vInsertChar              Write vInsertChar;
  Property    DefaultInsertLeftChar   : Boolean   Read vDefaultInsertLeftChar   Write vDefaultInsertLeftChar;
  Property    DecimalSeparator        : Char      Read vDecimalSeparator        Write vDecimalSeparator;
  Property    ExcludeDecimalSeparator : Boolean   Read vExcludeDecimalSeparator Write vExcludeDecimalSeparator;
  Property    DateSeparator           : Char      Read vDateSeparator           Write vDateSeparator;
  Property    TimeSeparator           : Char      Read vTimeSeparator           Write vTimeSeparator;
  Property    NumberFormat            : String    Read vNumberMask              Write vNumberMask;
  Property    DateFormat              : String    Read vDateMask                Write vDateMask;
  Property    TimeFormat              : String    Read vTimeMask                Write vTimeMask;
  Property    DateTimeFormat          : String    Read vDateTimeMask            Write vDateTimeMask;
  Property    IntegerMask             : String    Read vIntegerMask             Write vIntegerMask;
  Property    MemoToString            : Boolean   Read vMemoToString            Write vMemoToString;
  Property    ReplaceLinebreakFor     : String    Read vReplaceLinebreakFor     Write vReplaceLinebreakFor;
  Property    DefaultPrecision        : Integer   Read vDefaultPrecision        Write vDefaultPrecision;
  Property    DefaultFieldSize        : Integer   Read vDefaultFieldSize        Write vDefaultFieldSize;
End;

Type
 PCustomFieldDef = ^TCustomFieldDef;
 TCustomFieldDef = Class(TCollectionItem)
 Private
  vNotNull,
  vInsertCharLeft,
  vKeyField,
  vExcludeDecimalSeparator,
  vISODateTimeFormat             : Boolean;
  vPrecision,
  vFieldSize                     : Integer;
  FName,
  vDisplayLabel,
  vInsertChar,
  vFieldName                     : String;
  vMaskOptions                   : TMaskOptions;
  vFieldtype                     : TObjectValue;
  vOnGetFieldValue               : TOnGetFieldValue;
  vDefaultValue                  : String;
  vOwnerCollection               : TCollection;
  Procedure   SetFieldName(Value : String);
 Public
  Procedure   Assign(Source              : TPersistent); Override;
  Constructor Create(aCollection         : TCollection); Override;
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Function    GetNamePath                : String;       Override;
  Destructor  Destroy;             Override;
 Published
  Property    InsertChar              : String           Read vInsertChar              Write vInsertChar;
  Property    InsertCharLeft          : Boolean          Read vInsertCharLeft          Write vInsertCharLeft;
  Property    ISODateTimeFormat       : Boolean          Read vISODateTimeFormat       Write vISODateTimeFormat;
  Property    MaskOptions             : TMaskOptions     Read vMaskOptions             Write vMaskOptions;
  Property    FieldSize               : Integer          Read vFieldSize               Write vFieldSize;
  Property    Precision               : Integer          Read vPrecision               Write vPrecision;
  Property    Name                    : String           Read FName                    Write FName;
  Property    FieldName               : String           Read vFieldName               Write SetFieldName;
  Property    DisplayLabel            : String           Read vDisplayLabel            Write vDisplayLabel;
  Property    FieldType               : TObjectValue     Read vFieldtype               Write vFieldtype;
  Property    KeyField                : Boolean          Read vKeyField                Write vKeyField;
  Property    NotNull                 : Boolean          Read vNotNull                 Write vNotNull;
  Property    DefaultValue            : String           Read vDefaultValue            Write vDefaultValue;
  Property    OnGetFieldValue         : TOnGetFieldValue Read vOnGetFieldValue         Write vOnGetFieldValue;
End;

Type
 TCustomFieldDefs = Class(TRESTDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner          : TPersistent;                       Override;
 Private
  fOwner      : TPersistent;
  Function    GetRec     (Index : Integer) : TCustomFieldDef;        Overload;
  Procedure   PutRec     (Index : Integer;
                          Item  : TCustomFieldDef);                  Overload;
  Function    GetRecName (Index : String)  : TCustomFieldDef;        Overload;
  Procedure   PutRecName (Index : String;
                          Item  : TCustomFieldDef);                  Overload;
  Procedure   ClearList;
 Public
  Constructor Create(AOwner     : TPersistent;
                     aItemClass : TCollectionItemClass);
  Destructor  Destroy;                                               Override;
  Procedure   Delete     (Index : Integer);                          Overload;
  Procedure   Delete     (Param : TCustomFieldDef);                  Overload;
//  Function    Add        (Item  : TCustomFieldDef) : Integer;        Overload;
  Function    Add               : TCollectionItem;
  Property    Items      [Index : Integer]         : TCustomFieldDef Read GetRec     Write PutRec;
  Property    ItemsString[Index : String]          : TCustomFieldDef Read GetRecName Write PutRecName;
End;

Type
 TFileOptions = Class(TPersistent)
 Private
  vFileType         : TFileType;
  vHeaderTag,
  vLineTag,
  vTablename,
  vFileName,
  vReplaceSeparator,
  vTagFile          : String;
  vSeparator        : Char;
  vBlobsFiles,
  vRewriteFile,
  vOnlyCustomFields,
  vISODateTimeFormat,
  vWriteHeader,
  vUtf8SpecialChars,
  vIgnoreBlobs,
  vHeaderFields     : Boolean;
  vEncoding         : TEncodeSelect;
  {$IFDEF RESTDWLAZARUS}
  vEncodingLazarus  : TEncoding;
  vDatabaseCharSet  : TDatabaseCharSet;
  {$ENDIF}
  Procedure   SetEncoding(bValue : TEncodeSelect);
 Public
  Procedure   Assign     (Source : TPersistent);Override;
  Constructor Create;
 Published
  Property    HeaderFields       : Boolean          Read vHeaderFields      Write vHeaderFields;
  Property    RewriteFile        : Boolean          Read vRewriteFile       Write vRewriteFile;
  Property    ISODateTimeFormat  : Boolean          Read vISODateTimeFormat Write vISODateTimeFormat;
  Property    IgnoreBlobs        : Boolean          Read vIgnoreBlobs       Write vIgnoreBlobs;
  Property    BlobsFiles         : Boolean          Read vBlobsFiles        Write vBlobsFiles;
  Property    WriteHeader        : Boolean          Read vWriteHeader       Write vWriteHeader;
  Property    OnlyCustomFields   : Boolean          Read vOnlyCustomFields  Write vOnlyCustomFields;
  Property    Delimiter          : Char             Read vSeparator         Write vSeparator;
  Property    HeaderTag          : String           Read vHeaderTag         Write vHeaderTag;
  Property    LineTag            : String           Read vLineTag           Write vLineTag;
  Property    TagFile            : String           Read vTagFile           Write vTagFile;
  Property    ReplaceSeparator   : String           Read vReplaceSeparator  Write vReplaceSeparator;
  Property    FileType           : TFileType        Read vFileType          Write vFileType;
  Property    Tablename          : String           Read vTablename         Write vTablename;
  Property    FileName           : String           Read vFileName          Write vFileName;
  Property    Encoding           : TEncodeSelect    Read vEncoding          Write SetEncoding;
  Property    Utf8SpecialChars   : Boolean          Read vUtf8SpecialChars  Write vUtf8SpecialChars;
  {$IFDEF RESTDWLAZARUS}
  Property    DatabaseCharSet    : TDatabaseCharSet Read vDatabaseCharSet   Write vDatabaseCharSet;
  {$ENDIF}
End;

Type
 TFieldImport = Class
 Public
  Name,
  Mask      : String;
  FieldType : TFieldType;
  Size,
  Precision : Integer;
  IsPK      : Boolean;
  Value     : Variant;
  Blob      : TMemoryStream;
  Constructor Create;
  Destructor  Destroy;Override;
End;

Type
 PFieldImport  = ^TFieldImport;
 TFieldsImport = Class(TList)
 Public
  Function  ItemAdd(Var Value : PFieldImport) : Integer;
  Function  ItemsCount        : Integer;
  Function  FielByName (Value : String)       : TFieldImport;
  Function  FielByIndex(Value : Integer)      : TFieldImport;
  Procedure ClearData;
  Procedure Release;
End;

Type
 TRESTDWBufferDB    = Class(TRESTDWStreamBuffer)
 Private
  vDataset          : TDataset;
  vCustomFieldDefs  : TCustomFieldDefs;
  vOnGetLineValue   : TOnGetLineValue;
  vOnSetLineValue   : TOnSetLineValue;
  vOnError          : TOnError;
  vBeginProcess     : TBeginProcess;
  vEndProcess       : TEndProcess;
  vMaskOptions      : TMaskOptions;
  vFileOptions      : TFileOptions;
  vStreamMode       : TRESTDWStreamMode;
  vTempBlobPath     : String;
  Procedure   CreateValues;
  Procedure   ReadValues;
  Procedure   SetDataset         (Value          : TDataset);
  Property    Filename;
  Procedure   NewBuff(Rewrite : Boolean = True);
 Public
  Procedure   DatasetToFile;
  Procedure   DatasetToStream    (Const cStream     : TStream);
  Procedure   FileToDataset;
  Procedure   StreamToDataset    (dStream         : TStream);
  Constructor Create             (AOwner         : TComponent);Override;
  Destructor  Destroy;Override;
 Published
  Property    Dataset           : TDataset         Read vDataset           Write SetDataset;
  Property    MaskOptions       : TMaskOptions     Read vMaskOptions       Write vMaskOptions;
  Property    FieldDefs         : TCustomFieldDefs Read vCustomFieldDefs   Write vCustomFieldDefs;
  Property    FileOptions       : TFileOptions     Read vFileOptions       Write vFileOptions;
  Property    OnSetLineValue    : TOnSetLineValue  Read vOnSetLineValue    Write vOnSetLineValue;
  Property    OnGetLineValue    : TOnGetLineValue  Read vOnGetLineValue    Write vOnGetLineValue;
  Property    OnError           : TOnError         Read vOnError           Write vOnError;
  Property    OnBeginProcess    : TBeginProcess    Read vBeginProcess      Write vBeginProcess;
  Property    OnEndProcess      : TEndProcess      Read vEndProcess        Write vEndProcess;
 End;

Implementation

Uses uRESTDWJSONObject;

Function InsertChar(Value,
                    CharIn   : String;
                    Size     : Integer;
                    LeftSide : Boolean = False) : String;
Var
 vActualSize : Integer;
Begin
 Result := Value;
 For vActualSize := Length(Result) To Size -1 Do
  If LeftSide Then
   Result := CharIn + Result
  Else
   Result := Result + CharIn;
End;

Function FileNameWithoutExtension(Filename : String) : String;
Begin
 Result := ChangeFileExt(ExtractFileName(Filename), '');
End;

Function StringToJsonString(OriginalString: String): String;
Var
 I : Integer;
 Function NewChar(OldChar: String): String;
 Begin
  Result := '';
  If Length(OldChar) > 0 Then
   Begin
    Case OldChar[1] Of
     '\' : Result := '\\';
     '"' : Result := '\"';
     '/' : Result := '\/';
     #8  : Result := '\b';
     #9  : Result := '\t';
     #10 : Result := '\n';
     #12 : Result := '\f';
     #13 : Result := '\r';
    End;
   End;
 End;
Begin
 Result := OriginalString;
 For I := 0 To Length(TSpecialChars) - 1 Do
  Result := StringReplace(Result, TSpecialChars[i], NewChar(TSpecialChars[i]), [rfReplaceAll]);
End;

Procedure TFileOptions.Assign(Source : TPersistent);
Begin
 Inherited Assign(Source);
End;

Constructor TFileOptions.Create;
Begin
 vIgnoreBlobs       := False;
 vWriteHeader       := True;
 vUtf8SpecialChars  := True;
 vISODateTimeFormat := False;
 vOnlyCustomFields  := False;
 vRewriteFile       := False;
 vBlobsFiles        := True;
 vSeparator         := '|';
 vReplaceSeparator  := cReplaceSeparator;
 vFileType          := ftbCSVFile;
 vTablename         := '';
 vFileName          := '';
 vHeaderTag         := '';
 vLineTag           := '';
// vTagFile           := TTagFile;
 {$IF Defined(DELPHIXEUP) or Defined(RESTDWLAZARUS)}
   vEncoding        := esUtf8;
 {$ELSE}
   vEncoding        := esASCII;
 {$IFEND}
 {$IFDEF RESTDWLAZARUS}
   vDatabaseCharSet := csUndefined;
 {$ENDIF}
End;

Function  TFieldsImport.ItemAdd(Var Value : PFieldImport) : Integer;
Begin
 Result := Add(Value);
End;

Function  TFieldsImport.ItemsCount : Integer;
Begin
 Result := Count;
End;

Function  TFieldsImport.FielByName(Value : String)    : TFieldImport;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 to Count -1 Do
  Begin
   If UpperCase(TFieldImport(Items[I]^).Name) = UpperCase(Value) Then
    Begin
     Result := TFieldImport(Items[I]^);
     Break;
    End;
  End;
End;

Function  TFieldsImport.FielByIndex(Value : Integer)  : TFieldImport;
Begin
 Try
  Result := TFieldImport(Items[Value]^);
 Except
  Result := Nil;
 End;
End;

Procedure TFieldsImport.Release;
Var
 I : Integer;
Begin
 For I := 0 to Count -1 Do
  Begin
   If TFieldImport(Items[I]^).FieldType in [
      {$IFDEF DELPHIXEUP}ftWideMemo, ftStream,{$ENDIF}
      ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftBytes, ftVarBytes, ftOraBlob,
      ftOraClob, ftTypedBinary] Then
    Begin
     If TFieldImport(Items[I]^).Blob <> Nil Then
      TFieldImport(Items[I]^).Blob.Clear;
     Delete(I);
    End;
  End;
End;

Procedure TFieldsImport.ClearData;
Var
 I : Integer;
Begin
 For I := 0 to Count -1 Do
  Begin
   If TFieldImport(Items[I]^).FieldType in [
      {$IFDEF DELPHIXEUP}ftWideMemo, ftStream,{$ENDIF}
      ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftBytes, ftVarBytes, ftOraBlob,
      ftOraClob, ftTypedBinary] Then
    Begin
     If TFieldImport(Items[I]^).Blob <> Nil Then
      TFieldImport(Items[I]^).Blob.Clear;
    End;
   TFieldImport(Items[I]^).Value := Null;
  End;
End;

Procedure TFileOptions.SetEncoding(bValue : TEncodeSelect);
Begin
 vEncoding := bValue;
 {$IFDEF RESTDWLAZARUS}
  Case vEncoding Of
   esASCII : vEncodingLazarus := TEncoding.ANSI;
   esUtf8  : vEncodingLazarus := TEncoding.Utf8;
  End;
 {$ENDIF}
End;

Constructor TRESTDWBufferDB.Create(AOwner  : TComponent);
Begin
 Inherited;
 vCustomFieldDefs   := TCustomFieldDefs.Create(Self, TCustomFieldDef);
 vMaskOptions       := TMaskOptions.Create;
 vFileOptions       := TFileOptions.Create;
 vDataset           := Nil;
End;

Procedure TRESTDWBufferDB.ReadValues;
Var
 vLine,
 vKeys         : String;
 vTotalRecs,
 IncLine,
 InitTag       : Integer;
 vFieldsImport : TFieldsImport;
 FieldImport   : PFieldImport;
 vAccept       : Boolean;
 Function GetKeysNames : String;
 Begin

 End;
 Function GetPKValue(Name : String) : Boolean;
  Function GetFieldName(Var Value : String) : String;
  Begin
   If Pos(';', Value) > 0 Then
    Begin
     Result := Trim(Copy(Value, 1, Pos(';', Value) -1));
     Delete(Value, 1, Pos(';', Value));
    End
   Else
    Begin
     Result := Value;
     Value  := '';
    End;
  End;
 Var
  vTempKeys : String;
 Begin
  vTempKeys := GetKeysNames;
  While vTempKeys <> '' Do
   Begin
    Result := UpperCase(GetFieldName(vTempKeys)) = UpperCase(Name);
    If Result Then
     Break;
   End;
 End;
 Function CompTAG(Value : String) : Boolean;
 Var
  vTempTAG : String;
 Begin
  vTempTAG := Copy(Value, 1, Length(vFileOptions.TagFile));
  Delete(Value, 1, Length(vFileOptions.TagFile));
  vTempTAG := vTempTAG + Copy(Value, 1, Pos(vFileOptions.Delimiter, Value));
  Result   := UpperCase(vTempTAG) = UpperCase(vFileOptions.TagFile + vFileOptions.Delimiter);
 End;
 Procedure LoadFields;Overload;
 Var
  I           : Integer;
  FieldImport : PFieldImport;
  Procedure SetField(Value : TField; Var FieldImport : TFieldImport);
  Var
   ClassNameString,
   vTempSP     : String;
   Size,
   Precision   : Integer;
  Begin
   Size             := 0;
   Precision        := 0;
   FieldImport.IsPK := (pfInKey in Value.ProviderFlags);
   FieldImport.Name := Value.FieldName;
   If Not FieldImport.IsPK Then
    FieldImport.IsPK := GetPKValue(FieldImport.Name);
   FieldImport.FieldType := Value.DataType;
   FieldImport.Size      := Value.Size;
   If (FieldImport.FieldType In [{$IFDEF DELPHIXEUP}ftExtended, ftSingle,{$ENDIF}
                                 ftCurrency, ftBCD, ftFMTBcd]) Then
    FieldImport.Precision := TBCDField(Value).Precision;
  End;
 Begin
  For I := 0 To vDataset.Fields.Count -1 Do
   Begin
    New(FieldImport);
    FieldImport^ := TFieldImport.Create;
    SetField(vDataset.Fields[I], FieldImport^);
    vFieldsImport.ItemAdd(FieldImport);
   End;
 End;
 Procedure LoadFields(Value : String);Overload; //Carrega os campos a partir do Reader
 Var
  vTempLine,
  vFieldDef   : String;
  FieldImport : PFieldImport;
  Procedure SetField(Value : String; Var FieldImport : TFieldImport);
  Var
   ClassNameString,
   vTempSP     : String;
   Size,
   Precision   : Integer;
  Begin
   Size             := 0;
   Precision        := 0;
   FieldImport.IsPK := (Pos('&PK', UpperCase(Value)) > 0);
   Value            := StringReplace(Uppercase(Value), '&PK', '', [rfReplaceAll]);
   If Pos(':', Value) > 0 Then
    FieldImport.Name := Copy(Value, 1, Pos(':', Value) -1)
   Else
    FieldImport.Name := Trim(Value);
   If Not FieldImport.IsPK Then
    FieldImport.IsPK := GetPKValue(FieldImport.Name);
   If Pos(':', Value) > 0 Then
    Begin
     Delete(Value, 1, Pos(':', Value));
     ClassNameString  := Value;
    End
   Else
    Begin
     ClassNameString  := 'String(' + IntToStr(vMaskOptions.DefaultFieldSize) + ')';
     Value            := ClassNameString;
    End;
   If Pos('(', ClassNameString) > 0 Then
    Begin
     ClassNameString := Trim(Copy(ClassNameString, 1, Pos('(', ClassNameString) -1));
     vTempSP         := Trim(Copy(Value, 1, Length(Value)));
     Delete(vTempSP, 1, Length(ClassNameString) + 1);
     If Pos(',', vTempSP) = 0 Then
      Size := StrToInt(Trim(Copy(vTempSP, 1, Pos(')', vTempSP) -1)))
     Else
      Begin
       Size      := StrToInt(Trim(Copy(vTempSP, 1, Pos(',', vTempSP) -1)));
       Delete(vTempSP, 1, Pos(',', vTempSP));
       Precision := StrToInt(Trim(Copy(vTempSP, 1, Pos(')', vTempSP) -1)));
      End;
    End;
   FieldImport.Size      := Size;
   FieldImport.Precision := Precision;
   FieldImport.FieldType := TFieldType(GetEnumValue(TypeInfo(TFieldType), 'ft' + ClassNameString));
  End;
 Begin
  Value := ReadLn;
  vTempLine := Value; //Copy(Value, Length(vFileOptions.TagFile) + Length(vFileOptions.Delimiter) + 1, Length(Value));
  While vTempLine <> '' Do
   Begin
    New(FieldImport);
    FieldImport^ := TFieldImport.Create;
    If Pos(vFileOptions.Delimiter, vTempLine) > 0 Then
     Begin
      vFieldDef    := Copy(vTempLine, 1, Pos(vFileOptions.Delimiter, vTempLine) -1);
      Delete(vTempLine, 1, Pos(vFileOptions.Delimiter, vTempLine));
     End
    Else
     Begin
      vFieldDef    := vTempLine;
      Delete(vTempLine, 1, Length(vTempLine));
     End;
    SetField(vFieldDef, FieldImport^);
    vFieldsImport.ItemAdd(FieldImport);
   End;
 End;
 Procedure CreateFields(Value : String); //Carrega os campos a partir da Variável
 Var
  I           : Integer;
  vFieldName  : String;
  FieldImport : PFieldImport;
  Function GetFieldName(Var Value : String) : String;
  Begin
   If Pos(';', Value) > 0 Then
    Begin
     Result := Trim(Copy(Value, 1, Pos(';', Value) -1));
     Delete(Value, 1, Pos(';', Value));
    End
   Else
    Begin
     Result := Value;
     Value  := '';
    End;
  End;
 Begin
  While Value <> '' Do
   Begin
    vFieldName := GetFieldName(Value);
    If vDataset.FieldByName(vFieldName) <> Nil Then
     Begin
      New(FieldImport);
      FieldImport^      := TFieldImport.Create;
      FieldImport^.Name := vFieldName;
      FieldImport^.FieldType := vDataset.FieldByName(vFieldName).DataType;
      FieldImport^.IsPK := (pfInKey in vDataset.FieldByName(vFieldName).ProviderFlags) Or GetPKValue(FieldImport^.Name);
      If FieldImport^.FieldType In [ftFixedChar, ftWideString, ftString{$IFDEF DELPHIXEUP}, ftFixedWideChar{$ENDIF}] Then
       FieldImport^.Size := vDataset.FieldByName(vFieldName).Size
      Else If FieldImport^.FieldType In [ftFMTBcd, {$IFDEF DELPHIXEUP}TFieldType.ftExtended,{$ENDIF} ftFloat, ftCurrency, ftBCD] Then
       Begin
        FieldImport^.Size      := TCurrencyField(vDataset.FieldByName(vFieldName)).DisplayWidth -
                                  TCurrencyField(vDataset.FieldByName(vFieldName)).Size;
        FieldImport^.Precision := TCurrencyField(vDataset.FieldByName(vFieldName)).Size;
       End;
      vFieldsImport.ItemAdd(FieldImport);
     End;
   End;
 End;
 Procedure BuildValue(Value : String);
 Var
  vFilePath,
  vTempLine,
  vValue          : String;
  I               : Integer;
  vCustomFieldDef : TCustomFieldDef;
 Begin
  vFieldsImport.ClearData;
  If vFileOptions.vTagFile <> '' Then
   vTempLine := Copy(Value, Length(vFileOptions.vTagFile) + 2, Length(Value))
  Else
   vTempLine := Value;
  For I := 0 To vFieldsImport.ItemsCount -1 Do
   Begin
    Try
     If Pos(vFileOptions.vSeparator, vTempLine) > 0 Then
      Begin
       vValue := Copy(vTempLine, 1, Pos(vFileOptions.vSeparator, vTempLine) - 1);
       Delete(vTempLine, 1, Pos(vFileOptions.vSeparator, vTempLine));
      End
     Else
      Begin
       vValue := vTempLine;
       vTempLine := '';
      End;
     Case TFieldImport(vFieldsImport.Items[I]^).FieldType Of
      ftBoolean       :
       Begin
        If Trim(vValue) <> '' Then
         TFieldImport(vFieldsImport.Items[I]^).Value := StrToInt(vValue) = 1;
       End;
      {$IFDEF DELPHIXEUP}TFieldType.ftSingle,
      ftByte,
      ftLongWord,
      ftShortint,
      {$ENDIF}
      ftLargeint,
      ftAutoInc,
      ftSmallint,
      ftInteger,
      ftWord          :
       Begin
        If Trim(vValue) <> '' Then
         TFieldImport(vFieldsImport.Items[I]^).Value := StrToInt(vValue);
       End;
      ftFixedChar,
      ftWideString,
      ftString{$IFDEF DELPHIXEUP},
      ftFixedWideChar{$ENDIF} :
       Begin
        If Trim(vValue) <> '' Then
         TFieldImport(vFieldsImport.Items[I]^).Value := vValue;
       End;
      ftFMTBcd,
      {$IFDEF DELPHIXEUP}
      TFieldType.ftExtended,
      {$ENDIF}
      ftFloat,
      ftCurrency,
      ftBCD           :
       Begin
        If Trim(vValue) <> '' Then
         TFieldImport(vFieldsImport.Items[I]^).Value := StrToFloat(vValue);
       End;
      {$IFDEF DELPHIXEUP}
      ftTimeStampOffset,
      ftOraTimeStamp,
      {$ENDIF}
      ftTimeStamp,
      ftDate, ftTime,
      ftDateTime      :
       Begin
        If Trim(vValue) <> '' Then
         TFieldImport(vFieldsImport.Items[I]^).Value := StrToDateTime(vValue);
       End;
      {$IFDEF DELPHIXEUP}
      ftWideMemo,
      ftStream,
      {$ENDIF}
      ftBlob,    ftMemo,
      ftGraphic,
      ftFmtMemo,
      ftBytes,
      ftVarBytes,
      ftOraBlob, ftOraClob,
      ftTypedBinary   :
       Begin
        If Not (vFileOptions.vIgnoreBlobs) Then
         Begin
          If TFieldImport(vFieldsImport.Items[I]^).FieldType In [{$IFDEF DELPHIXEUP}
                                                                  ftWideMemo,
                                                                 {$ENDIF} ftMemo, ftFmtMemo] Then
           Begin
            vCustomFieldDef := vCustomFieldDefs.ItemsString[TFieldImport(vFieldsImport.Items[I]^).Name];
            If vCustomFieldDef <> Nil Then
             Begin
              If vCustomFieldDef.MaskOptions.vMemoToString Then
               vValue := StringReplace(vValue, vCustomFieldDef.MaskOptions.vReplaceLinebreakFor, sLineBreak, [rfReplaceAll]);
             End
            Else
             Begin
              If MaskOptions.vMemoToString Then
               vValue := StringReplace(vValue, MaskOptions.vReplaceLinebreakFor, sLineBreak, [rfReplaceAll]);
             End;
            vValue := StringReplace(vValue, vFileOptions.ReplaceSeparator, vFileOptions.vSeparator, [rfReplaceAll]);
            TFieldImport(vFieldsImport.Items[I]^).Value := vValue;
           End
          Else
           Begin
            If vFileOptions.BlobsFiles Then
             Begin
              vFilePath := vValue;
              {$IFDEF RESTDWWINDOWS}
               vFilePath := StringReplace(vFilePath, '/', '\', [rfReplaceAll]);
              {$ELSE}
               vFilePath := StringReplace(vFilePath, '\', '/', [rfReplaceAll]);
              {$ENDIF}
              TFieldImport(vFieldsImport.Items[I]^).Blob.LoadFromFile(vFilePath);
              TFieldImport(vFieldsImport.Items[I]^).Blob.Position := 0;
             End;
           End;
         End;
       End;
     End;
    Except
     On E : Exception Do
      Begin
       If Assigned(vOnError) Then
        vOnError(IncLine, E.Message);
       Exit;
      End;
    End;
   End;
 End;
 Procedure RunAction;
  Function GetUpdateFields : String;
  Var
   I           : Integer;
   FieldImport : TFieldImport;
  Begin
   Result := '';
   For I := 0 To vFieldsImport.ItemsCount -1 Do
    Begin
     FieldImport := vFieldsImport.FielByIndex(I);
     If Not FieldImport.IsPK Then
      Begin
       If Result = '' Then
        Result := Format('%s = :%s', [UpperCase(FieldImport.Name),
                                      UpperCase(FieldImport.Name)])
       Else
        Result := Result + Format(', %s = :%s', [UpperCase(FieldImport.Name),
                                                 UpperCase(FieldImport.Name)]);
      End;
    End;
  End;
  Function GetInsertFields : String;
  Var
   I           : Integer;
   FieldImport : TFieldImport;
  Begin
   Result := '';
   For I := 0 To vFieldsImport.ItemsCount -1 Do
    Begin
     FieldImport := vFieldsImport.FielByIndex(I);
     If Result = '' Then
      Result := UpperCase(FieldImport.Name)
     Else
      Result := Result + Format(', %s', [UpperCase(FieldImport.Name)]);
    End;
  End;
  Function GetInsertParams : String;
  Var
   I           : Integer;
   FieldImport : TFieldImport;
  Begin
   Result := '';
   For I := 0 To vFieldsImport.ItemsCount -1 Do
    Begin
     FieldImport := vFieldsImport.FielByIndex(I);
     If Result = '' Then
      Result := ':' + UpperCase(FieldImport.Name)
     Else
      Result := Result + Format(', :%s', [UpperCase(FieldImport.Name)]);
    End;
  End;
  Function GetParams : String;
  Var
   I           : Integer;
   FieldImport : TFieldImport;
  Begin
   Result := '';
   For I := 0 To vFieldsImport.ItemsCount -1 Do
    Begin
     FieldImport := vFieldsImport.FielByIndex(I);
     If FieldImport.IsPK Then
      Begin
       If Result = '' Then
        Result := Result + Format(' (%s = :%s)', [UpperCase(FieldImport.Name),
                                                  UpperCase(FieldImport.Name)])
       Else
        Result := Result + Format(' AND (%s = :%s)', [UpperCase(FieldImport.Name),
                                                      UpperCase(FieldImport.Name)]);
      End;
    End;
   If Result <> '' Then
    Result := 'WHERE ' + Result;
  End;
  Procedure PrepareValues;
  Var
   I           : Integer;
   FieldImport : TFieldImport;
  Begin
   For I := 0 To vFieldsImport.ItemsCount -1 Do
    Begin
     FieldImport := vFieldsImport.FielByIndex(I);
     If vDataset.FindField(UpperCase(FieldImport.Name)) <> Nil Then
      Begin
       If FieldImport.FieldType in [{$IFDEF DELPHIXEUP}ftWideMemo, ftStream, {$ENDIF}
                                    ftBlob, ftMemo, ftGraphic, ftFmtMemo,
                                    ftBytes, ftVarBytes, ftOraBlob, ftOraClob,
                                    ftTypedBinary] Then
        Begin
         If FieldImport.FieldType In [{$IFDEF DELPHIXEUP}
                                       ftWideMemo,
                                      {$ENDIF} ftMemo, ftFmtMemo] Then
          vDataset.FindField(UpperCase(FieldImport.Name)).AsString := FieldImport.Value
         Else
          TBlobField(vDataset.FindField(UpperCase(FieldImport.Name))).LoadFromStream(FieldImport.Blob);
        End
       Else If vDataset.FindField(UpperCase(FieldImport.Name)).DataType In
               [ftFixedChar, ftWideString, ftString{$IFDEF DELPHIXEUP}, ftFixedWideChar{$ENDIF}] Then
        Begin
         If Not VarIsNull(FieldImport.Value) Then
          Begin
           If FieldImport.Size > 0 Then
            vDataset.FindField(UpperCase(FieldImport.Name)).Value    := Copy(FieldImport.Value, 1, FieldImport.Size)
           Else If vDataset.FindField(UpperCase(FieldImport.Name)).Size > 0 Then
            vDataset.FindField(UpperCase(FieldImport.Name)).Value    := Copy(FieldImport.Value, 1, vDataset.FindField(UpperCase(FieldImport.Name)).Size)
           Else
            vDataset.FindField(UpperCase(FieldImport.Name)).AsString := FieldImport.Value;
          End;
        End
       Else
        vDataset.FindField(UpperCase(FieldImport.Name)).Value   := FieldImport.Value;
      End;
    End;
  End;
  Procedure PrepareParams;
  Var
   I           : Integer;
   FieldImport : TFieldImport;
  Begin
   For I := 0 To vFieldsImport.ItemsCount -1 Do
     FieldImport := vFieldsImport.FielByIndex(I);
  End;
  Procedure ResizeValues;
  Var
   I : Integer;
  Begin
   For I := 0 To vFieldsImport.ItemsCount -1 Do
    Begin
     If vDataset.FindField(TFieldImport(vFieldsImport.Items[I]^).Name) <> Nil Then
      Begin
       If TFieldImport(vFieldsImport.Items[I]^).FieldType In
         [ftFixedChar, ftWideString, ftString{$IFDEF DELPHIXEUP}, ftFixedWideChar{$ENDIF}] Then
        If TFieldImport(vFieldsImport.Items[I]^).Size <> vDataset.FindField(TFieldImport(vFieldsImport.Items[I]^).Name).Size Then
         TFieldImport(vFieldsImport.Items[I]^).Size := vDataset.FindField(TFieldImport(vFieldsImport.Items[I]^).Name).Size;
      End;
    End;
  End;
 Begin
  If Not vDataset.Active Then
   vDataset.Open;
  ResizeValues;
  PrepareValues;
 End;
 Procedure SetFieldsDataset(Var Dataset : TDataset);
 Var
  I : Integer;
 Begin
  For I := 0 To vFieldsImport.Count -1 Do
   Begin
    If Dataset.FindField(PFieldImport(vFieldsImport.Items[I])^.Name) = Nil Then
     Dataset.FieldDefs.Add(PFieldImport(vFieldsImport.Items[I])^.Name,
                           PFieldImport(vFieldsImport.Items[I])^.FieldType,
                           PFieldImport(vFieldsImport.Items[I])^.Size,
                           PFieldImport(vFieldsImport.Items[I])^.IsPK);
   End;
 End;
Begin
 If Not Assigned(vDataset) Then
  Begin
   Raise Exception.Create(cErrorDataSetNotDefined);
   Exit;
  End;
 vFieldsImport := TFieldsImport.Create;
 vTotalRecs := 0;
 vAccept    := True;
 Try
//  vTotalRecs := CountItemsFromFile(ChangeFileExt(FileName, '.buf'));
  If Assigned(vBeginProcess) Then
   vBeginProcess(vTotalRecs);
//     TextFileSeek(vTextFile, InitTag);
  IncLine := 0;
  If vFileOptions.HeaderFields Then
   LoadFields(vLine)
  Else
   LoadFields;
  If Not vDataset.Active Then
   Begin
    SetFieldsDataset(vDataset);
    vDataset.Open;
   End;
  While Not Eof Do
   Begin
    vDataset.Append;
    //Read Data
    vLine := ReadLn;
    If Assigned(vOnGetLineValue) Then
     vOnGetLineValue(IncLine, vLine, vAccept);
    If vAccept Then
     Begin
      BuildValue(vLine);
      //Generate and Execute Action
      RunAction;
      //Next Line
     End;
    vAccept := True;
    Inc(IncLine);
    vDataset.Post;
   End;
 Finally
  vDataset.First;
  If Assigned(vFieldsImport) Then
   FreeAndNil(vFieldsImport);
  If Assigned(vEndProcess) Then
   vEndProcess;
 End;
End;

procedure TRESTDWBufferDB.CreateValues;
Var
 vBlobName,
 vLineNo  : Integer;
 vAccept,
 vStop    : Boolean;
 vLineTag,
 vLine,
 vTagFile : String;
 Function GetPKValue(Name : String) : Boolean;
 Var
  I : Integer;
 Begin
  Result := False;
  For I := 0 To vCustomFieldDefs.Count -1 Do
   Begin
    Result := (vCustomFieldDefs.Items[I].vKeyField) And
              (UpperCase(vCustomFieldDefs.Items[I].vFieldName) = UpperCase(Name));
    If Result Then
     Break;
   End;
 End;
 Procedure WriteHeaderFields;
 Var
  I           : Integer;
  vTablename,
  vHeaderTag,
  vFieldTypeName,
  vHeaderLine,
  vFieldPk : String;
 Begin
  vHeaderLine := '';
  vTagFile    := '';
  vHeaderTag  := '';
  vTablename  := '';
  If vCustomFieldDefs.Count > 0 Then
   Begin
    For I := 0 To vCustomFieldDefs.Count -1 Do
     Begin
      vFieldPk := '';
      If vFileOptions.IgnoreBlobs Then
       If ObjectValueToFieldType(vCustomFieldDefs.Items[I].vFieldtype)
          in [{$IFDEF DELPHIXEUP}ftWideMemo, ftStream,{$ENDIF}
              ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftBytes, ftVarBytes,
              ftOraBlob, ftOraClob, ftTypedBinary] Then
       Continue;
      vFieldTypeName := UpperCase(GetEnumName(TypeInfo(TFieldType), Integer(ObjectValueToFieldType(vCustomFieldDefs.Items[I].vFieldtype))));
      Delete(vFieldTypeName, 1, 2);
      If (vCustomFieldDefs.Items[I].vKeyField) Then
       vFieldPk := UpperCase('&pk');
      If ObjectValueToFieldType(vCustomFieldDefs.Items[I].vFieldtype) In [ftWideString, ftString{$IFNDEF FPC}{$if CompilerVersion > 22}, ftFixedChar, ftFixedWideChar{$IFEND}{$ENDIF}] Then
       vHeaderLine := vHeaderLine + Format('%s:%s(%d)%s', [UpperCase(vCustomFieldDefs.Items[I].vFieldName) + vFieldPk,
                                                           vFieldTypeName,
                                                           vCustomFieldDefs.Items[I].vFieldSize,
                                                           vFileOptions.vSeparator])
      Else If ObjectValueToFieldType(vCustomFieldDefs.Items[I].vFieldtype) In [ftFloat, ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 22}, ftSingle, ftExtended{$IFEND}{$ENDIF}] Then
       vHeaderLine := vHeaderLine + Format('%s:%s(%d,%d)%s', [UpperCase(vCustomFieldDefs.Items[I].vFieldName) + vFieldPk,
                                                              vFieldTypeName,
                                                              vCustomFieldDefs.Items[I].vFieldSize,
                                                              vCustomFieldDefs.Items[I].vPrecision,
                                                              vFileOptions.vSeparator])

      Else
       vHeaderLine := vHeaderLine + Format('%s:%s%s', [UpperCase(vCustomFieldDefs.Items[I].vFieldName) + vFieldPk,
                                                       vFieldTypeName,
                                                       vFileOptions.vSeparator]);
     End;
   End;
  If Not (vFileOptions.vOnlyCustomFields) Then
   Begin
    For I := 0 To Dataset.Fields.Count -1 Do
     Begin
      If vCustomFieldDefs.ItemsString[Dataset.Fields[I].FieldName] <> Nil Then
       Continue;
      vFieldPk := '';
      If vFileOptions.IgnoreBlobs Then
       If ObjectValueToFieldType(vCustomFieldDefs.ItemsString[Dataset.Fields[I].FieldName].vFieldtype)
          in [{$IFDEF DELPHIXEUP}ftWideMemo, ftStream,{$ENDIF}
              ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftBytes, ftVarBytes,
              ftOraBlob, ftOraClob, ftTypedBinary] Then
       Continue;
      vFieldTypeName := UpperCase(GetEnumName(TypeInfo(TFieldType), Integer(Dataset.Fields[I].DataType)));
      Delete(vFieldTypeName, 1, 2);
      If (pfInKey in Dataset.Fields[I].ProviderFlags) Or (GetPKValue(Dataset.Fields[I].FieldName)) Then
       vFieldPk := UpperCase('&pk');
      If Dataset.Fields[I].DataType In [ftWideString, ftString{$IFDEF DELPHIXEUP}, ftFixedChar, ftFixedWideChar{$ENDIF}] Then
       vHeaderLine := vHeaderLine + Format('%s:%s(%d)%s', [UpperCase(Dataset.Fields[I].FieldName) + vFieldPk,
                                                           vFieldTypeName,
                                                           Dataset.Fields[I].Size,
                                                           vFileOptions.vSeparator])
      Else If Dataset.Fields[I].DataType In [ftFloat, ftCurrency, ftBCD, ftFMTBcd{$IFDEF DELPHIXEUP},ftSingle, ftExtended{$ENDIF}] Then
       vHeaderLine := vHeaderLine + Format('%s:%s(%d,%d)%s', [UpperCase(Dataset.Fields[I].FieldName) + vFieldPk,
                                                              vFieldTypeName,
                                                              TCurrencyField(Dataset.Fields[I]).Precision,
                                                              TCurrencyField(Dataset.Fields[I]).Precision -
                                                              TCurrencyField(Dataset.Fields[I]).DisplayWidth,
                                                              vFileOptions.vSeparator])

      Else
       vHeaderLine := vHeaderLine + Format('%s:%s%s', [UpperCase(Dataset.Fields[I].FieldName) + vFieldPk,
                                                       vFieldTypeName,
                                                       vFileOptions.vSeparator]);
     End;
   End;
  If vHeaderLine = '' Then
   Exit
  Else
   Begin
    If vFileOptions.vHeaderTag <> '' Then
     vHeaderTag := vFileOptions.vHeaderTag + vFileOptions.vSeparator;
    If vFileOptions.vTagFile <> '' Then
     Begin
      vTagFile := StringReplace(vFileOptions.vTagFile, cTablenameTAG, vFileOptions.vTablename, [rfReplaceAll]) + vFileOptions.vSeparator;
      If vTagFile = '' Then
       vTagFile := vFileOptions.vTagFile;
     End;
    vHeaderLine := vHeaderTag + vTagFile + vTablename + vHeaderLine;
   End;
  If Assigned(vOnSetLineValue) Then
   vOnSetLineValue(vLineNo, vHeaderLine, vAccept, vStop);
  If vFileOptions.vFileType = ftbFixedText Then
   If vHeaderLine <> '' Then
    If vHeaderLine[Length(vHeaderLine) - FinalStrPos] = vFileOptions.vSeparator Then
     vHeaderLine := Copy(vHeaderLine, 1, Length(vHeaderLine) -1);
  If (vAccept) And (Not (vStop)) Then
   WriteLn(vHeaderLine);
 End;
 Function GenerateLine : String;
 Var
  vValueLine : String;
  Function GetValue(Field : TField) : String;
  Var
   vAtualValue     : String;
   vBlobStreamFile : TMemoryStream;
   vCustomFieldDef : TCustomFieldDef;
  Begin
   Result      := '';
   vAtualValue := '';
   Case Field.DataType Of
    ftBoolean :        //Tipo Boolean
     Begin
      If vAtualValue = '' Then
       If Field.AsBoolean Then
        vAtualValue := '1'
       Else
        vAtualValue := '0';
      vCustomFieldDef := vCustomFieldDefs.ItemsString[Field.FieldName];
      If vCustomFieldDef <> Nil Then
       Begin
        If Assigned(vCustomFieldDef.OnGetFieldValue) Then
         vCustomFieldDef.OnGetFieldValue(vCustomFieldDef, vAtualValue);
        If vCustomFieldDef.FieldSize > 0 Then
         If vAtualValue <> '' Then
          vAtualValue := Copy(vAtualValue, 1, vCustomFieldDef.FieldSize);
        vAtualValue := InsertChar(vAtualValue,
                                  vCustomFieldDef.vInsertChar,
                                  vCustomFieldDef.vFieldSize,
                                  vCustomFieldDef.vInsertCharLeft);
       End
      Else
       Begin
        If vMaskOptions.vDefaultFieldSize > 0 Then
         If vAtualValue <> '' Then
          vAtualValue := Copy(vAtualValue, 1, vMaskOptions.vDefaultFieldSize);
        vAtualValue := InsertChar(vAtualValue,
                                  vMaskOptions.vInsertChar,
                                  vMaskOptions.vDefaultFieldSize,
                                  vMaskOptions.vDefaultInsertLeftChar);
       End;
      Case vFileOptions.vFileType Of
       ftbFixedText : Result := vAtualValue;
       ftbCSVFile   : Result := Format('%s%s', [vAtualValue, vFileOptions.vSeparator]);
      End;
     End;
    {$IFDEF DELPHIXEUP}
    ftByte,
    ftLongWord,
    ftShortint,
    {$ENDIF}
    ftLargeint,
    ftAutoInc,
    ftSmallint,
    ftInteger,
    ftWord     : Begin
                  vCustomFieldDef := vCustomFieldDefs.ItemsString[Field.FieldName];
                  Try
                   If vCustomFieldDef <> Nil Then
                    Begin
                     If vAtualValue = '' Then
                      If Not VarIsNull(Field.Value) Then
                       vAtualValue := FormatFloat(vCustomFieldDef.MaskOptions.IntegerMask, Field.AsInteger)
                      Else
                       vAtualValue := '';
                     If Assigned(vCustomFieldDef.OnGetFieldValue) Then
                      vCustomFieldDef.OnGetFieldValue(vCustomFieldDef, vAtualValue);
                     If vCustomFieldDef.FieldSize > 0 Then
                      If vAtualValue <> '' Then
                       vAtualValue := Copy(vAtualValue, 1, vCustomFieldDef.FieldSize);
                     If vCustomFieldDef.vFieldSize > 0 Then
                      vAtualValue := InsertChar(vAtualValue,
                                                vCustomFieldDef.vInsertChar,
                                                vCustomFieldDef.vFieldSize,
                                                vCustomFieldDef.vInsertCharLeft);
                    End
                   Else
                    Begin
                     If vAtualValue = '' Then
                      If Not Field.IsNull Then
                       vAtualValue := FormatFloat(vMaskOptions.vIntegerMask, Field.AsInteger);
                     If vMaskOptions.vDefaultFieldSize > 0 Then
                      If vAtualValue <> '' Then
                       vAtualValue := Copy(vAtualValue, 1, vMaskOptions.vDefaultFieldSize);
                     If vMaskOptions.vDefaultFieldSize > 0 Then
                      vAtualValue := InsertChar(vAtualValue,
                                                vMaskOptions.vInsertChar,
                                                vMaskOptions.vDefaultFieldSize,
                                                vMaskOptions.vDefaultInsertLeftChar);
                    End;
                  Except
                   On E : Exception Do
                    Begin
                     If Assigned(vOnError) Then
                      vOnError(Dataset.RecNo, Format('Field %s Value %s no is a %s Value', [Field.FieldName,
                                                                                            Field.AsString,
                                                                                            'Integer']));
                    End;
                  End;
                  Case vFileOptions.vFileType Of
                   ftbFixedText : Result := vAtualValue;
                   ftbCSVFile   : Result := Format('%s%s', [vAtualValue, vFileOptions.vSeparator]);
                  End;
                 End;
    ftWideString,
    ftString
    {$IFDEF DELPHIXEUP}
    , ftFixedChar,
    ftFixedWideChar
    {$ENDIF}: Begin
                vCustomFieldDef := vCustomFieldDefs.ItemsString[Field.FieldName];
                Try
                 If vCustomFieldDef <> Nil Then
                  Begin
                   If vAtualValue = '' Then
                    If Not VarIsNull(Field.Value) Then
                     vAtualValue := Field.AsString
                    Else
                     vAtualValue := '';
                   If Assigned(vCustomFieldDef.OnGetFieldValue) Then
                    vCustomFieldDef.OnGetFieldValue(vCustomFieldDef, vAtualValue);
                   If vCustomFieldDef.FieldSize > 0 Then
                    If vAtualValue <> '' Then
                     vAtualValue := Copy(vAtualValue, 1, vCustomFieldDef.FieldSize);
                   vAtualValue := InsertChar(vAtualValue,
                                             vCustomFieldDef.vInsertChar,
                                             vCustomFieldDef.vFieldSize,
                                             vCustomFieldDef.vInsertCharLeft);
                  End
                 Else
                  Begin
                   If vAtualValue = '' Then
                    If Not Field.IsNull Then
                     vAtualValue := Field.AsString;
                   If vMaskOptions.vDefaultFieldSize > 0 Then
                    If vAtualValue <> '' Then
                     vAtualValue := Copy(vAtualValue, 1, vMaskOptions.vDefaultFieldSize);
                   vAtualValue := InsertChar(vAtualValue,
                                             vMaskOptions.vInsertChar,
                                             vMaskOptions.vDefaultFieldSize,
                                             vMaskOptions.vDefaultInsertLeftChar);
                  End;
                Except
                 On E : Exception Do
                  Begin
                   If Assigned(vOnError) Then
                    vOnError(Dataset.RecNo, Format(cErrorInvalidFieldStringValue, [Field.FieldName, Field.AsString]));
                  End;
                End;
                Case vFileOptions.vFileType Of
                 ftbFixedText : Result := vAtualValue;
                 ftbCSVFile   : Result := Format('%s%s', [vAtualValue, vFileOptions.vSeparator]);
                End;
              End;
    ftFloat,
    ftCurrency,
    ftBCD,
    ftFMTBcd
    {$IFDEF DELPHIXEUP}
    ,ftSingle,
    ftExtended
    {$ENDIF}: Begin
                vCustomFieldDef := vCustomFieldDefs.ItemsString[Field.FieldName];
                Try
                 If vCustomFieldDef <> Nil Then
                  Begin
                   If vAtualValue = '' Then
                    If Not VarIsNull(Field.Value) Then
                     Begin
                      If vCustomFieldDef.MaskOptions.vNumberMask <> '' Then
                       vAtualValue := FormatFloat(vCustomFieldDef.MaskOptions.vNumberMask, Field.AsCurrency)
                      Else
                       vAtualValue := FloatToStr(Field.AsCurrency);
                     End
                    Else
                     vAtualValue := '';
                   If Assigned(vCustomFieldDef.OnGetFieldValue) Then
                    vCustomFieldDef.OnGetFieldValue(vCustomFieldDef, vAtualValue);
                   If vCustomFieldDef.vMaskOptions.vDefaultPrecision > 0 Then
                    If Pos(vCustomFieldDef.vMaskOptions.DecimalSeparator, vAtualValue) > 0 Then
                     vAtualValue := Copy(vAtualValue, 1,
                                         Pos(vCustomFieldDef.vMaskOptions.DecimalSeparator, vAtualValue) +
                                             vCustomFieldDef.vMaskOptions.vDefaultPrecision);
                   If vCustomFieldDef.vMaskOptions.vNumberMask <> '' Then
                    If (vAtualValue <> '') Then
                     vAtualValue := FormatFloat(vCustomFieldDef.vMaskOptions.vNumberMask, StrToFloat(vAtualValue))
                    Else If vCustomFieldDef.DefaultValue <> '' Then
                     vAtualValue := FormatFloat(vCustomFieldDef.vMaskOptions.vNumberMask, StrToFloat(vCustomFieldDef.DefaultValue));
                   If vCustomFieldDef.FieldSize > 0 Then
                    If vAtualValue <> '' Then
                     vAtualValue := Copy(vAtualValue, 1, vCustomFieldDef.FieldSize);
                   If vCustomFieldDef.vMaskOptions.vExcludeDecimalSeparator Then
                    vAtualValue := StringReplace(vAtualValue, vCustomFieldDef.vMaskOptions.vDecimalSeparator, '', [rfReplaceAll]);
                   vAtualValue := InsertChar(vAtualValue,
                                             vCustomFieldDef.vInsertChar,
                                             vCustomFieldDef.vFieldSize,
                                             vCustomFieldDef.vInsertCharLeft);
                  End
                 Else
                  Begin
                   If vAtualValue = '' Then
                    If Not VarIsNull(Field.Value) Then
                     Begin
                      If vMaskOptions.vNumberMask <> '' Then
                       vAtualValue := FormatFloat(vMaskOptions.vNumberMask, Field.AsCurrency)
                      Else
                       vAtualValue := FloatToStr(Field.AsCurrency);
                     End
                    Else
                     vAtualValue := '';
                   If vMaskOptions.vDefaultPrecision > 0 Then
                    If Pos(vMaskOptions.DecimalSeparator, vAtualValue) > 0 Then
                     vAtualValue := Copy(vAtualValue, 1,
                                         Pos(vMaskOptions.DecimalSeparator, vAtualValue) +
                                             vMaskOptions.vDefaultPrecision);
                   If vMaskOptions.vNumberMask <> '' Then
                    If (vAtualValue <> '') Then
                     vAtualValue := FormatFloat(vMaskOptions.vNumberMask, StrToFloat(vAtualValue));
                   If vMaskOptions.vDefaultFieldSize > 0 Then
                    If vAtualValue <> '' Then
                     vAtualValue := Copy(vAtualValue, 1, vMaskOptions.vDefaultFieldSize);
                   If vMaskOptions.vExcludeDecimalSeparator Then
                    vAtualValue := StringReplace(vAtualValue, vMaskOptions.vDecimalSeparator, '', [rfReplaceAll]);
                   vAtualValue := InsertChar(vAtualValue,
                                             vMaskOptions.vInsertChar,
                                             vMaskOptions.vDefaultFieldSize,
                                             vMaskOptions.vDefaultInsertLeftChar);
                  End;
                Except
                 On E : Exception Do
                  Begin
                   If Assigned(vOnError) Then
                    vOnError(Dataset.RecNo, Format(cErrorInvalidFieldFloatValue,
                                             [Field.FieldName, Field.AsString]));
                  End;
                End;
                Case vFileOptions.vFileType Of
                 ftbFixedText : Result := vAtualValue;
                 ftbCSVFile   : Result := Format('%s%s', [vAtualValue, vFileOptions.vSeparator]);
                End;
              End;
    {$IFDEF DELPHIXEUP}
    ftTimeStampOffset, //Tipos Date/DateTime
    ftOraTimeStamp,
    {$ENDIF}
    ftTimeStamp,
    ftDate, ftTime,
    ftDateTime: Begin
                  vCustomFieldDef := vCustomFieldDefs.ItemsString[Field.FieldName];
                  Try
                   If vCustomFieldDef <> Nil Then
                    Begin
                     If vAtualValue = '' Then
                      If Not VarIsNull(Field.Value) Then
                       Begin
                        If Field.DataType in [ftTimeStamp, {$IFDEF DELPHIXEUP}ftTimeStampOffset,
                                             ftOraTimeStamp,{$ENDIF} ftDateTime] Then
                         vAtualValue := FormatDateTime(vCustomFieldDef.MaskOptions.vDateTimeMask, Field.AsDateTime)
                        Else If Field.DataType = ftDate Then
                         vAtualValue := FormatDateTime(vCustomFieldDef.MaskOptions.vDateMask, Field.AsDateTime)
                        Else
                         vAtualValue := FormatDateTime(vCustomFieldDef.MaskOptions.vTimeMask, Field.AsDateTime);
                       End
                      Else
                       vAtualValue := '';
                     If Assigned(vCustomFieldDef.OnGetFieldValue) Then
                      vCustomFieldDef.OnGetFieldValue(vCustomFieldDef, vAtualValue);
                     If vCustomFieldDef.FieldSize > 0 Then
                      If vAtualValue <> '' Then
                       vAtualValue := Copy(vAtualValue, 1, vCustomFieldDef.FieldSize);
                     vAtualValue := InsertChar(vAtualValue,
                                               vCustomFieldDef.vInsertChar,
                                               vCustomFieldDef.vFieldSize,
                                               vCustomFieldDef.vInsertCharLeft);
                    End
                   Else
                    Begin
                     If vAtualValue = '' Then
                      If Not Field.IsNull Then
                       Begin
                        If Field.DataType in [ftTimeStamp, {$IFDEF DELPHIXEUP}ftTimeStampOffset,
                                             ftOraTimeStamp,{$ENDIF} ftDateTime] Then
                         vAtualValue := FormatDateTime(vMaskOptions.vDateTimeMask, Field.AsDateTime)
                        Else If Field.DataType = ftDate Then
                         vAtualValue := FormatDateTime(vMaskOptions.vDateMask, Field.AsDateTime)
                        Else
                         vAtualValue := FormatDateTime(vMaskOptions.vTimeMask, Field.AsDateTime);
                       End
                      Else
                       vAtualValue := '';
                     If vMaskOptions.vDefaultFieldSize > 0 Then
                      If vAtualValue <> '' Then
                       vAtualValue := Copy(vAtualValue, 1, vMaskOptions.vDefaultFieldSize);
                     vAtualValue := InsertChar(vAtualValue,
                                               vMaskOptions.vInsertChar,
                                               vMaskOptions.vDefaultFieldSize,
                                               vMaskOptions.vDefaultInsertLeftChar);
                    End;
                  Except
                   On E : Exception Do
                    Begin
                     If Assigned(vOnError) Then
                      vOnError(Dataset.RecNo, Format(cErrorInvalidFieldDateTimeValue,
                                            [Field.FieldName, Field.AsString]));
                    End;
                  End;
                  Case vFileOptions.vFileType Of
                   ftbFixedText : Result := vAtualValue;
                   ftbCSVFile   : Result := Format('%s%s', [vAtualValue, vFileOptions.vSeparator]);
                  End;
                End;
    {$IFDEF DELPHIXEUP}
    ftWideMemo,        //Tipos Blob
    ftStream,
    {$ENDIF}
    ftBlob,    ftMemo,
    ftGraphic,
    ftFmtMemo,
    ftBytes,
    ftVarBytes,
    ftOraBlob, ftOraClob,
    ftTypedBinary   :
     Begin
      Result := Format('%s%s', ['', vFileOptions.vSeparator]);
      If Not (vFileOptions.vIgnoreBlobs) Then
       Begin
        Try
         vBlobStreamFile := TMemoryStream.Create;
         vBlobStreamFile.LoadFromStream(Dataset.CreateBlobStream(Field, bmRead));
         vBlobStreamFile.Position := 0;
         If Field.DataType In [{$IFDEF DELPHIXEUP}ftWideMemo,{$ENDIF}
                                ftMemo, ftFmtMemo] Then
          Begin
           vAtualValue     := Field.AsString;
           vCustomFieldDef := vCustomFieldDefs.ItemsString[Field.FieldName];
           If vCustomFieldDef <> Nil Then
            Begin
             If vCustomFieldDef.MaskOptions.vMemoToString Then
              vAtualValue := StringReplace(vAtualValue, sLineBreak, vCustomFieldDef.MaskOptions.vReplaceLinebreakFor, [rfReplaceAll]);
            End
           Else If vMaskOptions.vMemoToString Then
            vAtualValue := StringReplace(vAtualValue, sLineBreak, vMaskOptions.vReplaceLinebreakFor,          [rfReplaceAll]);
           vAtualValue := StringReplace(vAtualValue,  vFileOptions.vSeparator, vFileOptions.ReplaceSeparator, [rfReplaceAll]);
           Result      := Format('%s%s', [vAtualValue, vFileOptions.vSeparator]);
           Exit;
          End;
         If vFileOptions.BlobsFiles Then
          Begin
            Try
             If vBlobStreamFile.Size > 0 Then
              Begin
               If TRESTDWStreamBuffer.StreamToFile(vBlobStreamFile, vTempBlobPath + FormatFloat('00000', vBlobName) + '.blob') Then
                Begin
                 Result := Format('%s%s', [vTempBlobPath + FormatFloat('00000', vBlobName) + '.blob', vFileOptions.vSeparator]);
                 Inc(vBlobName);
                End;
              End;
            Finally
             vBlobStreamFile.Free;
            End;
          End
         Else
          Result := Format('%s%s', [EncodeStream(vBlobStreamFile), vFileOptions.vSeparator]);
        Except
         On E : Exception Do
          Begin
           If Assigned(vOnError) Then
            vOnError(Dataset.RecNo, Format(cErrorInvalidFieldBlobValue,
                                           [Field.FieldName, Field.AsString]));
          End;
        End;
       End;
     End;
   End;
  End;
  Function GetLineReg(Dataset : TDataSet) : String;
  Var
   I : Integer;
  Begin
   Result := vTagFile;
   If vFileOptions.vOnlyCustomFields Then
    Begin
     For I := 0 To vCustomFieldDefs.Count -1 Do
      Begin
       If Dataset.FindField(vCustomFieldDefs.Items[I].vFieldName) <> Nil Then
        Result := Result + GetValue(Dataset.FindField(vCustomFieldDefs.Items[I].vFieldName));
      End;
    End
   Else
    Begin
     For I := 0 To Dataset.Fields.Count -1 Do
      Result := Result + GetValue(Dataset.Fields[I]);
    End;
   If Result = vTagFile Then
    Result := '';
  End;
 Begin
  If vFileOptions.vFileType = ftbFixedText Then
   vValueLine := GetLineReg(Dataset)
  Else
   vValueLine := GetLineReg(Dataset) + vFileOptions.vSeparator;
  If vValueLine <> '' Then
   Begin
    If Assigned(vOnSetLineValue) Then
     vOnSetLineValue(vLineNo, vValueLine, vAccept, vStop);
    If Not(vAccept) Or (vStop) Then
     vValueLine := '';
   End
  Else
   Begin
    If Assigned(vOnError) Then
     vOnError(Dataset.RecNo, cErrorWriteDataSetNullValue);
   End;
  Result     := vValueLine;
 End;
Begin
 vLineNo  := 0;
 If Assigned(vBeginProcess) Then
  vBeginProcess(vLineNo);
 vAccept  := True;
 vStop    := False;
 vLine    := '';
 vLineTag := '';
 vTagFile := vFileOptions.vTagFile;
 vDataset.DisableControls;
 Try
  If Not vDataset.Active Then
   vDataset.Open;
  vDataset.First;
  vBlobName  := 0;
  If vFileOptions.vHeaderFields Then
   WriteHeaderFields;
  If vTagFile <> '' Then
   If vTagFile[Length(vTagFile) - FinalStrPos] = vFileOptions.vSeparator Then
    Delete(vTagFile, Length(vTagFile), 1);
  If vFileOptions.vLineTag <> '' Then
   vLineTag := vFileOptions.vLineTag + vFileOptions.vSeparator;
  If vStop Then
   Exit;
  While Not vDataset.Eof Do
   Begin
    vAccept := True;
    vLine   := vLineTag + GenerateLine;
    If vLine <> '' Then
     Begin
      If vLine[InitStrPos] = vFileOptions.vSeparator Then
       Delete(vLine, 1, 1);
     End;
    If (vAccept) And (Not(vStop)) Then
     WriteLn(vLine);
    Inc(vLineNo);
    If vStop Then
     Break;
    vDataset.Next;
   End;
 Finally
  vDataset.First;
  vDataset.EnableControls;
 End;
End;

Procedure TRESTDWBufferDB.DatasetToFile;
Begin
 vStreamMode   :=  rdwFileStream;
 Try
  NewBuff;
  CreateValues;
  CloseFile;
  If Assigned(vEndProcess) Then
   vEndProcess;
 Finally
  vTempBlobPath := '';
 End;
End;

Procedure TRESTDWBufferDB.DatasetToStream(Const cStream : TStream);
Begin
 vStreamMode := rdwMemoryStream;
 Try
  If Assigned(cStream) Then
   Begin
    NewBuff;
    CreateValues;
    If Assigned(Stream) Then
     Begin
      cStream.Position := 0;
      Stream.Position := 0;
      cStream.CopyFrom(Stream, Stream.Size);
      cStream.Position := 0;
     End;
    CloseFile;
    If Assigned(vEndProcess) Then
     vEndProcess;
   End;
 Finally
  vTempBlobPath := '';
 End;
End;

Destructor TRESTDWBufferDB.Destroy;
Begin
 FreeAndNil(vCustomFieldDefs);
 FreeAndNil(vMaskOptions);
 FreeAndNil(vFileOptions);
 Inherited;
End;

Procedure TRESTDWBufferDB.FileToDataset;
Begin
 vStreamMode   :=  rdwFileStream;
 Try
  NewBuff(False);
  ReadValues;
  CloseFile;
  If Assigned(vEndProcess) Then
   vEndProcess;
 Finally
  vTempBlobPath := '';
 End;
End;

Procedure TRESTDWBufferDB.NewBuff(Rewrite : Boolean = True);
Var
 vTempFileName : String;
 vOldRewriteFile : Boolean;
Begin
 vTempBlobPath := '';
 vTempFileName := vFileOptions.FileName;
 ForceDirectories(ExtractFilePath(vTempFileName));
 vOldRewriteFile := vFileOptions.vRewriteFile;
 vFileOptions.vRewriteFile := Rewrite;
 Try
  If vFileOptions.vRewriteFile Then
   DeleteFile(vTempFileName);
  FileMode      := rdwFileCreateExclusive;
  Filename      := vTempFileName;
  RewriteFile   := vFileOptions.vRewriteFile;
  StreamMode    := vStreamMode;
  If (Not (vFileOptions.IgnoreBlobs)) And
     (StreamMode = rdwFileStream)     Then
   Begin
    If Trim(vTempFileName) <> '' Then
     Begin
      vTempBlobPath := IncludeTrailingPathDelimiter('.' + IncludeTrailingPathDelimiter('') + ChangeFileExt(ExtractFileName(vTempFileName), '') + '_blobs');
      ForceDirectories(vTempBlobPath);
     End;
   End;
//  If (Size > 0) And
//     (Not(vFileOptions.vRewriteFile)) Then
//   Position := Size;
 Finally
  vFileOptions.vRewriteFile := vOldRewriteFile;
 End;
End;

Procedure TRESTDWBufferDB.SetDataset(Value : TDataset);
Begin
 vDataset := Value;
End;

Procedure TRESTDWBufferDB.StreamToDataset(dStream      : TStream);
Begin
 vStreamMode := rdwMemoryStream;
 NewBuff;
End;

Constructor TCustomFieldDef.Create(aCollection : TCollection);
Begin
 Inherited;
 vOwnerCollection         := aCollection;
 vISODateTimeFormat       := False;
 vInsertCharLeft          := False;
 vKeyField                := False;
 vNotNull                 := False;
 vExcludeDecimalSeparator := False;
 vFieldSize               := 50;
 vPrecision               := 0;
 vDefaultValue            := '';
 vMaskOptions             := TMaskOptions.Create;
 FName                    := 'FIELD' + IntToStr(aCollection.Count);
End;

Destructor TCustomFieldDef.Destroy;
Begin
 FreeAndNil(vMaskOptions);
 Inherited;
End;

Function TCustomFieldDef.GetDisplayName: String;
Begin
 Result := FName;
End;

Function TCustomFieldDef.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

Procedure TMaskOptions.Assign(Source : TPersistent);
Begin
 Inherited Assign(Source);
End;

Constructor TMaskOptions.Create;
Begin
 vNumberMask              := '#########0.00';
 {$IFDEF DELPHIXE2UP}
 vDecimalSeparator        := FormatSettings.DecimalSeparator;
 vDateMask                := FormatSettings.ShortDateFormat;
 vTimeMask                := FormatSettings.ShortTimeFormat;
 vDateSeparator           := FormatSettings.DateSeparator;
 vTimeSeparator           := FormatSettings.TimeSeparator;
 {$ELSE}
 vDecimalSeparator        := DecimalSeparator;
 vDateMask                := ShortDateFormat;
 vTimeMask                := ShortTimeFormat;
 vDateSeparator           := DateSeparator;
 vTimeSeparator           := TimeSeparator;
 {$ENDIF}
 vDateTimeMask            := Format('%s %s', [vDateMask, vTimeMask]);
 vIntegerMask             := '0';
 vDefaultFieldSize        := 50;
 vInsertChar              := ' ';
 vReplaceLinebreakFor     := cReplaceLineBreak;
 vDefaultPrecision        := 0;
 vDefaultInsertLeftChar   := False;
 vExcludeDecimalSeparator := False;
 vMemoToString            := True;
End;

Procedure TCustomFieldDef.SetDisplayName(const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidCustomFieldName)
 Else
  Begin
   FName := Value;
   Inherited;
  End;
End;

Procedure TCustomFieldDef.SetFieldName(Value : String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidFieldName)
 Else
  Begin
   If (vDisplayLabel = vFieldName) Or
      (vDisplayLabel = '')         Then
    vDisplayLabel   := Value;
   vFieldName       := Value;
  End;
End;

Function TCustomFieldDefs.Add: TCollectionItem;
Begin
 Result := TCustomFieldDef(Inherited Add);
End;

Procedure TCustomFieldDef.Assign(Source: TPersistent);
Begin
 If Source is TCustomFieldDef Then
  Begin
   vInsertChar        := TCustomFieldDef(Source).InsertChar;
   vInsertCharLeft    := TCustomFieldDef(Source).InsertCharLeft;
   vISODateTimeFormat := TCustomFieldDef(Source).ISODateTimeFormat;
   vMaskOptions       := TCustomFieldDef(Source).MaskOptions;
   vFieldSize         := TCustomFieldDef(Source).FieldSize;
   vPrecision         := TCustomFieldDef(Source).Precision;
   vFieldName         := TCustomFieldDef(Source).FieldName;
   vDisplayLabel      := TCustomFieldDef(Source).DisplayLabel;
   vFieldtype         := TCustomFieldDef(Source).Fieldtype;
   vKeyField          := TCustomFieldDef(Source).KeyField;
   vNotNull           := TCustomFieldDef(Source).NotNull;
   vDefaultValue      := TCustomFieldDef(Source).DefaultValue;
   vOnGetFieldValue   := TCustomFieldDef(Source).OnGetFieldValue;
  End
 Else
  Inherited;
End;

Procedure TCustomFieldDefs.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Constructor TCustomFieldDefs.Create(AOwner     : TPersistent;
                                    aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TCustomFieldDef);
 Self.fOwner  := AOwner;
 vEditable   := True;
End;

Procedure TCustomFieldDefs.Delete(Param : TCustomFieldDef);
Var
 I : Integer;
Begin
 For I := 0 To Count -1 Do
  Begin
   If Items[I] = Param Then
    Begin
     Delete(I);
     Break;
    End;
  End;
End;

Procedure TCustomFieldDefs.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  TOwnedCollection(Self).Delete(Index);
End;

Destructor TCustomFieldDefs.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TCustomFieldDefs.GetOwner: TPersistent;
Begin
 Result := fOwner;
End;

Function TCustomFieldDefs.GetRec(Index : Integer) : TCustomFieldDef;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TCustomFieldDef(Inherited GetItem(Index));
End;

Function TCustomFieldDefs.GetRecName(Index : String) : TCustomFieldDef;
Var
 I         : Integer;
Begin
 Result    := Nil;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TCustomFieldDef(Inherited GetItem(I)).vFieldName)) Then
      Begin
       Result := TCustomFieldDef(Inherited GetItem(I));
       Break;
      End;
    End;
  End;
End;

Procedure TCustomFieldDefs.PutRec(Index : Integer;
                                  Item  : TCustomFieldDef);
Begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
End;

Procedure TCustomFieldDefs.PutRecName(Index : String;
                                      Item  : TCustomFieldDef);
Var
 I         : Integer;
 vNotFount : Boolean;
Begin
 vNotFount := True;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Lowercase(Index) = Lowercase(TCustomFieldDef(Inherited GetItem(I)).vFieldName)) Then
      Begin
       SetItem(I, Item);
       vNotFount := False;
       Break;
      End;
    End;
  End;
 If vNotFount Then
  Begin
   Item           := TCustomFieldDef.Create(Self);
   Item.FieldName := Index;
   SetItem(Self.Count, Item);
  End;
End;

{ TFieldImport }

Constructor TFieldImport.Create;
Begin
 Blob      := TMemoryStream.Create;
 FieldType := ftUnknown;
 Size      := 0;
 Precision := 0;
 IsPK      := False;
 Value     := '';
End;

Destructor  TFieldImport.Destroy;
Begin
 Blob.Clear;
 Blob.Free;
 Inherited;
End;

End.
