unit uRESTDWDesignReg;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
 de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
 Fl�vio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

uses
  {$IFDEF FPC}
    StdCtrls, ComCtrls, Forms, ExtCtrls, DBCtrls, DBGrids, Dialogs, Controls,
    LResources, LazFileUtils,  FormEditingIntf, PropEdits, lazideintf,
    ProjectIntf, ComponentEditors, fpWeb,
  {$ELSE}
   Windows, StrEdit, RTLConsts, Db, DBReg, ToolsApi, DesignWindows,
   DesignEditors, DSDesign, DesignIntf, ColnEdit,
   {$IF CompilerVersion > 22}
    vcl.Graphics,  ExptIntf,
   {$ELSE}
     Graphics, DbTables,
   {$IFEND}
   {$IFDEF COMPILER16_UP}UITypes,{$ENDIF}
  {$ENDIF}
  Variants, TypInfo, SysUtils, Classes,
  uRESTDWBasicClass, uRESTDWDatamodule, uRESTDWServerEvents, uRESTDWBasicDB,
  uRESTDWServerContext, uRESTDWMassiveBuffer, uRESTDWDataset, uRESTDWBufferDb,
  uRESTDWComponentBase

  ;

{$IFNDEF CLR}
Const
 varUString  = Succ(Succ(varString)); { Variant type code }
{$ENDIF}

Var
 EnabledAllTableDefs : Boolean = False;
 LoadAndStoreToForm  : Boolean = False;

{$IFNDEF FPC} //TODO
Type
 TDWDSDesigner = class(TDSDesigner)
Public
 Function DoCreateField(const FieldName : {$IF CompilerVersion > 17}WideString{$ELSE}String{$IFEND}; Origin: String): TField; Override;
End;
{$ENDIF}

Type
 TAddFields = Procedure (All: Boolean) of Object;

Type
 TRESTDWFieldsList = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;

Type
 TRESTDWClientRESTList = Class(TComponentProperty)
 Public
  Procedure GetValues(Proc : TGetStrProc);        Override;
End;

Type
 TPoolersList = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;

Type
 TTableList = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;

Type
 TPoolersListCDF = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;

Type
 TServerEventsList = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;

Type
 TServerEventsListCV = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;

type
 TRESTDWServerEventsEditor = Class(TComponentEditor)
  Function  GetVerbCount       : Integer;  Override;
  Function  GetVerb     (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index  : Integer); Override;
End;

Type
 TRESTDWClientEventsEditor = Class(TComponentEditor)
  Function  GetVerbCount      : Integer;  Override;
  Function  GetVerb    (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
End;

{$IFNDEF FPC}
Type
 TDSDesignerDW = Class(TDSDesigner)
 Private
 Public
  {$if CompilerVersion > 17}
  Function  DoCreateField(const FieldName: WideString; Origin: string): TField; override;
  {$ELSE}
  Function  DoCreateField(const FieldName: String; Origin: string): TField; override;
  {$IFEND}
  {$IFNDEF FPC}
  Function SupportsAggregates: Boolean; Override;
  Function SupportsInternalCalc: Boolean; Override;
  {$ENDIF}
End;

Type
 TRESTDWClientSQLEditor = Class(TComponentEditor)
 Private
 Public
  Procedure Edit; override;
  Function  GetVerbCount : Integer; Override;
  Function  GetVerb    (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
End;
{$ENDIF}

Type
 TRESTDWServerContextEditor = Class(TComponentEditor)
Public
 Function  GetVerbCount      : Integer;  Override;
 Function  GetVerb    (Index : Integer): String; Override;
 Procedure ExecuteVerb(Index : Integer); Override;
End;

Type
 TRESTDWContextRulesEditor = Class(TComponentEditor)
Public
 Function  GetVerbCount      : Integer;  Override;
 Function  GetVerb    (Index : Integer): String; Override;
 Procedure ExecuteVerb(Index : Integer); Override;
End;


{$IFDEF FPC}
Type
 TRESTDWCGIApplicationDescriptor = Class(TProjectDescriptor)
 Public
  Constructor Create; Override;
  Function    GetLocalizedName          : String; Override;
  Function    GetLocalizedDescription   : String; Override;
  Function    InitProject     (AProject : TLazProject) : TModalResult; Override;
  Function    CreateStartFiles(AProject : TLazProject) : TModalResult; Override;
 End;
 //TRESTDWCGIDatamodule = Class(TFileDescPascalUnitWithResource)
 //Public
 // Constructor Create; Override;
 // Function    GetInterfaceUsesSection : String; Override;
 // Function    GetInterfaceSource(const Filename, SourceName,
 //                                ResourceName : String) : String; Override;
 // Function    GetLocalizedName        : String; Override;
 // Function    GetLocalizedDescription : String; Override;
 // Function    GetImplementationSource(Const Filename,
 //                                     SourceName,
 //                                     ResourceName : String) : String;Override;
 //End;
 TRESTDWDatamodule    = Class(TFileDescPascalUnitWithResource)
 Public
  Constructor Create;Override;
  Function    GetInterfaceUsesSection : String; Override;
  Function    GetInterfaceSource(const Filename, SourceName,
                                 ResourceName : String) : String; Override;
  Function    GetLocalizedName        : String; Override;
  Function    GetLocalizedDescription : String; Override;
  Function    GetImplementationSource(Const Filename,
                                      SourceName,
                                      ResourceName : String) : String;Override;
 End;
{$ENDIF}

Procedure Register;

{$IFDEF FPC}
Resourcestring
  rsRESTDWCGIApplicati      = 'REST Dataware - CGI Application';
  rsRESTDWCGIApplicatiDesc  = 'REST Dataware - CGI Application%sA CGI (Common Gateway Interface) ' +
                              'program in Free Pascal using webmodules.';
  rsRESTDWStandaloneApp     = 'REST Dataware - Standalone Application';
  rsRESTDWStandaloneAppDesc = 'REST Dataware - Standalone Application%sA Standalone' +
                              'program in Free Pascal to use RDW HttpServer like REST Server.';
  rsRESTDWCGIDatamodule     = 'REST Dataware - CGI Datamodule';
  rsRESTDWCGIDatamoduleADa  = 'REST Dataware - CGI Datamodule%sA Datamodule for WEB (HTTP) Applications.';
  rsRESTDWDatamodule        = 'REST Dataware - Datamodule';
  rsRESTDWDatamoduleADa     = 'REST Dataware - Datamodule%sA Datamodule for REST Dataware Web Components.';

Var
 PDRESTDWCGIApplication : TRESTDWCGIApplicationDescriptor;
 PDRESTDWDatamodule     : TRESTDWDatamodule;
{$ENDIF}

Implementation

uses
  {$IFDEF FPC} utemplateproglaz,{$ENDIF}
   uRESTDWConsts, uRESTDWPoolermethod, uRESTDWBasic, uRESTDWResponseTranslator,
   uRESTDWFieldSourceEditor, uRESTDWSqlEditor, uRESTDWUpdSqlEditor,
   uRESTDWJSONViewer;

{$IFNDEF FPC}
{$IFDEF  RTL240_UP}
Var
 AboutBoxServices : IOTAAboutBoxServices = nil;
 AboutBoxIndex    : Integer = 0;

procedure RegisterAboutBox;
Var
 ProductImage: HBITMAP;
Begin
 Supports(BorlandIDEServices,IOTAAboutBoxServices, AboutBoxServices);
 Assert(Assigned(AboutBoxServices), '');
 Try
 If LoadBitmap(FindResourceHInstance(HInstance), 'DW') > 0 Then
  Begin
   ProductImage  := LoadBitmap(FindResourceHInstance(HInstance), 'DW');
   AboutBoxIndex := AboutBoxServices.AddPluginInfo(RESTDWSobreTitulo , RESTDWSobreDescricao,
                                                   ProductImage, False, RESTDWSobreLicencaStatus);
  End;
 Except
 End;
End;

procedure UnregisterAboutBox;
Begin
 If (AboutBoxIndex <> 0) and Assigned(AboutBoxServices) then
  Begin
   AboutBoxServices.RemovePluginInfo(AboutBoxIndex);
   AboutBoxIndex := 0;
   AboutBoxServices := nil;
  End;
End;

Procedure AddSplash;
Var
 bmp : TBitmap;
Begin
 bmp := TBitmap.Create;
 Try
  bmp.LoadFromResourceName(HInstance, 'DW');
  SplashScreenServices.AddPluginBitmap(RESTDWDialogoTitulo, bmp.Handle, false, RESTDWSobreLicencaStatus, '');
 Except
 End;
 bmp.Free;
End;
{$ENDIF}
{$ELSE}
Constructor TRESTDWCGIApplicationDescriptor.Create;
Begin
 inherited Create;
 Flags := Flags - [pfMainUnitHasCreateFormStatements];
 Name  := 'REST Dataware - CGI Application';
End;

//Constructor TRESTDWCGIDatamodule.Create;
//Begin
// Inherited Create;
// Name                    := 'RESTDWCGIWebModule';
// ResourceClass           := Trestdwcgiwebmodule;
// UseCreateFormStatements := True;
//End;

Constructor TRESTDWDatamodule.Create;
Var
 LFMFilename : String;
Begin
 Inherited Create;
 Name                    := 'RESTDWDatamodule';
 ResourceClass           := TServerMethodDataModule;
 DeclareClassVariable    := True;
 UseCreateFormStatements := True;
 AddToProject            := True;
 RequiredPackages        := 'restdatawarecomponents';
 If LazarusIDE.ActiveProject <> Nil Then
  Begin
   LazarusIDE.ActiveProject.AddPackageDependency(RequiredPackages);
   LazarusIDE.DoNewEditorFile(PDRESTDWDatamodule, '', '',
                              [nfIsPartOfProject, nfOpenInEditor, nfCreateDefaultSrc]);
  End;
End;

Function TRESTDWCGIApplicationDescriptor.GetLocalizedName : String;
Begin
 Result := rsRESTDWCGIApplicati;
End;

Function TRESTDWDatamodule.GetLocalizedName : String;
Begin
 Result := rsRESTDWDatamodule;
End;

//Function TRESTDWCGIDatamodule.GetLocalizedName : String;
//Begin
// Result := rsRESTDWCGIDatamodule;
//End;

Function TRESTDWDatamodule.GetInterfaceUsesSection : String;
Begin
 Result  := Inherited GetInterfaceUsesSection;
 Result  := Result + ', SysTypes, uRESTDWBasicTypes, uRESTDWJSONObject,' + LineEnding;
 Result  := Result + '  uRESTDWParams, uRESTDWDataUtils, uRESTDWComponentEvents, uRESTDWDatamodule';
End;

//Function TRESTDWCGIDatamodule.GetInterfaceUsesSection : String;
//Begin
// Result  := 'SysUtils, Classes';
// If GetResourceType = rtLRS Then
//  Result :=  Result+ ', LResources, ';
// Result  := Result + ', uRESTDWBase, httpdefs, fpHTTP, fpWeb, dmdwcgiserver, unit2';
//End;

Function TRESTDWDatamodule.GetInterfaceSource(Const Filename, SourceName, ResourceName : String) : String;
Const
 LE = LineEnding;
Begin
 Result := 'Type'+ LE
         + ' T'+ResourceName+' = Class(TServerMethodDataModule)' + LE
         + 'Private'+LE
         + LE
         + 'Public'+LE
         + LE
         + 'End;'+LE
         + LE;
 If DeclareClassVariable Then
  Result := Result + 'Var' + LE
                   + '  ' + ResourceName + ': T' + ResourceName + ';' + LE + LE;
End;

//Function TRESTDWCGIDatamodule.GetInterfaceSource(Const Filename, SourceName, ResourceName : String) : String;
//Const
// LE = LineEnding;
//Begin
// Result := 'Type'+ LE
//         + '  T'+ResourceName+' = class(Trestdwcgiwebmodule)'+LE
//         + '  Private'+LE
//         + LE
//         + '  Public'+LE
//         + LE
//         + ' End;'+LE
//         + LE;
// If DeclareClassVariable Then
//  Result := Result + 'Var' + LE
//                   + '  ' + ResourceName + ': T' + ResourceName + ';' + LE + LE;
//End;

Function TRESTDWCGIApplicationDescriptor.GetLocalizedDescription : String;
Begin
 Result := Format(rsRESTDWCGIApplicatiDesc, [#13#13]);
End;

Function TRESTDWDatamodule.GetLocalizedDescription : String;
Begin
 Result := Format(rsRESTDWDatamoduleADa, [#13#13]);
End;

//Function TRESTDWCGIDatamodule.GetLocalizedDescription : String;
//Begin
// Result := Format(rsRESTDWCGIDatamoduleADa, [#13#13]);
//End;

Function TRESTDWCGIApplicationDescriptor.InitProject(AProject : TLazProject) : TModalResult;
Var
 NewSource : String;
 MainFile  : TLazProjectFile;
Begin
 Inherited InitProject(AProject);
 MainFile                 := AProject.CreateProjectFile('restdwcgiproject1.lpr');
 MainFile.IsPartOfProject := True;
 AProject.AddFile(MainFile, false);
 AProject.MainFileID      := 0;
 // create program source
 NewSource                := cRESTDWcgiproject;
 AProject.MainFile.SetSourceText(NewSource);
 AProject.AddPackageDependency('restdatawarecomponents');
 AProject.AddPackageDependency('WebLaz');
 // compiler options
 AProject.LazCompilerOptions.Win32GraphicApp := False;
 AProject.LazCompilerOptions.BuildMacros.Add('LCLWidgetType');
 AProject.LazCompilerOptions.BuildMacros.Items[AProject.LazCompilerOptions.BuildMacros.IndexOfIdentifier('LCLWidgetType')].Values.Text := 'LCLWidgetType:=nogui';
 AProject.LazCompilerOptions.UnitOutputDirectory := 'lib' + PathDelim + '$(TargetCPU)-$(TargetOS)';
 AProject.Flags           := AProject.Flags - [pfMainUnitHasCreateFormStatements];
 AProject.Flags           := AProject.Flags - [pfRunnable];
 Result                   := mrOK;
End;

Function TRESTDWDatamodule.GetImplementationSource(const Filename, SourceName, ResourceName : String) : String;
Begin
 Result := Inherited GetImplementationSource(FileName, SourceName, ResourceName);
End;

//Function TRESTDWCGIDatamodule.GetImplementationSource(const Filename, SourceName, ResourceName : String) : String;
//Var
// ResourceFilename: String;
//Begin
// Case GetResourceType Of
//  rtLRS :
//   Begin
//    ResourceFilename := TrimFilename(ExtractFilenameOnly(Filename) + DefaultResFileExt);
//    Result           := 'Initialization' + LineEnding + '  {$I ' + ResourceFilename + '}' + LineEnding + LineEnding;
//   End;
//  rtRes : Result := '{$R *.lfm}' + LineEnding + LineEnding;
//  Else    Result := '';
// End;
// Result := Result + 'Initialization' + LineEnding + ' RegisterHTTPModule('''', T' + ResourceName + ');' + LineEnding;
//End;

Function TRESTDWCGIApplicationDescriptor.CreateStartFiles(AProject : TLazProject): TModalResult;
Begin
 //LazarusIDE.DoNewEditorFile(PDRESTDWCGIDatamodule, '', '',
 //                           [nfIsPartOfProject, nfOpenInEditor, nfCreateDefaultSrc]);
 LazarusIDE.DoNewEditorFile(PDRESTDWDatamodule, '', '',
                            [nfIsPartOfProject, nfOpenInEditor, nfCreateDefaultSrc]);
 Result:= mrOK;
End;
{$ENDIF}

{$IFNDEF FPC}
procedure TRESTDWClientSQLEditor.Edit;
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   TRESTDWClientSQL(Component).SetInDesignEvents(True);
  {$IFEND}
 {$ENDIF}
 Try
  {$IFNDEF FPC}
   {$IF CompilerVersion < 21}
    TRESTDWClientSQL(Component).Close;
    TRESTDWClientSQL(Component).CreateDatasetFromList;
   {$IFEND}
  {$ENDIF}
  ShowFieldsEditor(Designer, TRESTDWClientSQL(Component), TDSDesignerDW);
 Finally
  {$IFNDEF FPC}
   {$IF CompilerVersion > 21}
   TRESTDWClientSQL(Component).SetInDesignEvents(False);
   {$IFEND}
  {$ENDIF}
 End;
end;

procedure TRESTDWClientSQLEditor.ExecuteVerb(Index: Integer);
 Procedure EditFields(DataSet: TDataSet);
 begin
  {$IFNDEF FPC}
   {$IF CompilerVersion < 21}
    TRESTDWClientSQL(DataSet).Close;
    TRESTDWClientSQL(DataSet).CreateDatasetFromList;
   {$IFEND}
  {$ENDIF}
  ShowFieldsEditor(Designer, TRESTDWClientSQL(Component), TDSDesignerDW);
 End;
Begin
 Case Index of
  0 : EditFields(TDataSet(Component));
 End;
end;

Function TRESTDWClientSQLEditor.GetVerb(Index: Integer): String;
Begin
 Case Index Of
  0 : Result := 'Fields Edi&tor';
 End;
End;

Function TRESTDWClientSQLEditor.GetVerbCount: Integer;
Begin
 Result := 1;
End;

{$if CompilerVersion > 17}
Function  TDSDesignerDW.DoCreateField(const FieldName: WideString; Origin: string): TField;
{$ELSE}
Function  TDSDesignerDW.DoCreateField(const FieldName: String; Origin: string): TField;
{$IFEND}
Var
  F: TField;
  I: Integer;
  vDWClientSQL : TRESTDWClientSQL;
Begin
 Result := Nil;
 Try
  If TRESTDWClientSQL(DataSet).FieldListCount > 0 Then
   Begin
    Try
     TRESTDWClientSQL(DataSet).Close;
     TRESTDWClientSQL(DataSet).CreateDatasetFromList;
    Finally
    End;
    If TRESTDWClientSQL.FieldDefExist(DataSet, FieldName) <> Nil Then
     Result := Inherited DoCreateField(FieldName, Origin);
   End;
 Finally
 End;
 If TRESTDWClientSQL(DataSet).FieldListCount = TRESTDWClientSQL(DataSet).FieldCount then
  Begin
   vDWClientSQL := TRESTDWClientSQL.Create(nil);
   Try
    With vDWClientSQL Do
     Begin
      DisableControls;
      DataBase := TRESTDWClientSQL(DataSet).DataBase;
      SQL.Text := TRESTDWClientSQL(DataSet).SQL.Text;
      Open;
      For I := 0 to Fields.Count - 1 do
       Begin
        F := Fields.Fields[I];
        If (pfInKey in F.ProviderFlags) Then
         TRESTDWClientSQL(DataSet).Fields.FieldByName(F.FieldName).ProviderFlags := F.ProviderFlags;
       End;
      Close;
      EnableControls;
     End;
   Finally
    FreeAndNil(vDWClientSQL);
   End;
   TRESTDWClientSQL(DataSet).Active := False;
  End;
End;

Function TDSDesignerDW.SupportsAggregates: Boolean;
Begin
 Result := True;
End;

Function TDSDesignerDW.SupportsInternalCalc: Boolean;
Begin
 Result := True;
End;
{$ENDIF}

Function TPoolersListCDF.GetAttributes : TPropertyAttributes;
Begin
  // editor, sorted list, multiple selection
 Result := [paValueList, paSortList];
End;

Function TTableList.GetAttributes : TPropertyAttributes;
Begin
  // editor, sorted list, multiple selection
 Result := [paValueList, paSortList];
End;

Function TPoolersList.GetAttributes : TPropertyAttributes;
Begin
  // editor, sorted list, multiple selection
 Result := [paValueList, paSortList];
End;

procedure TPoolersListCDF.Edit;
Var
 vTempData : String;
Begin
 Inherited Edit;
 Try
  vTempData := GetValue;
  SetValue(vTempData);
 Finally
 End;
end;

procedure TTableList.Edit;
Var
 vTempData : String;
Begin
 Inherited Edit;
 Try
  vTempData := GetValue;
  SetValue(vTempData);
 Finally
 End;
end;

procedure TPoolersList.Edit;
Var
 vTempData : String;
Begin
 Inherited Edit;
 Try
  vTempData := GetValue;
  SetValue(vTempData);
 Finally
 End;
end;

Procedure TPoolersListCDF.GetValues(Proc : TGetStrProc);
Var
 vLista : TStringList;
 I      : Integer;
Begin
 //Provide a list of Poolers
 vLista := Nil;
// If GetComponent(0) is TRESTDWConnectionServer Then
//  Begin
//   With GetComponent(0) as TRESTDWConnectionServer Do
//    Begin
//     vLista := TRESTDWConnectionServer(GetComponent(0)).PoolerList;
//     Try
//      If Assigned(vLista) Then
//       For I := 0 To vLista.Count -1 Do
//        Proc (vLista[I]);
//     Finally
//      If Assigned(vLista) Then
//       FreeAndNil(vLista);
//     End;
//    End;
//  End
// Else If GetComponent(0) is TRESTDWConnectionParams Then
//  Begin
//   With GetComponent(0) as TRESTDWConnectionParams Do
//    Begin
//     vLista := TRESTDWConnectionParams(GetComponent(0)).PoolerList;
//     Try
//      If Assigned(vLista) Then
//       For I := 0 To vLista.Count -1 Do
//        Proc (vLista[I]);
//     Finally
//      If Assigned(vLista) Then
//       FreeAndNil(vLista);
//     End;
//    End;
//  End;
End;

Procedure TTableList.GetValues(Proc : TGetStrProc);
Var
 vLista : TStringList;
 I      : Integer;
Begin
 //Provide a list of Tables
 vLista := Nil;
 With GetComponent(0) as TRESTDWTable Do
  Begin
   Try
    If TRESTDWTable(GetComponent(0)).DataBase <> Nil Then
     Begin
      TRESTDWTable(GetComponent(0)).DataBase.GetTableNames(vLista);
      For I := 0 To vLista.Count -1 Do
       Proc (vLista[I]);
     End;
   Except
   End;
  End;
End;

Procedure TPoolersList.GetValues(Proc : TGetStrProc);
Var
 vLista : TStringList;
 I      : Integer;
Begin
 //Provide a list of Poolers
 With GetComponent(0) as TRESTDWDatabasebaseBase Do
  Begin
   Try
    vLista := TRESTDWDatabasebaseBase(GetComponent(0)).PoolerList;
    For I := 0 To vLista.Count -1 Do
     Proc (vLista[I]);
   Except
   End;
  End;
End;

{Ico Testando }
{Editor de Proriedades de Componente para mostrar o AboutDW}
Type
 TDWAboutDialogProperty = class({$IFDEF FPC}TClassPropertyEditor{$ELSE}TPropertyEditor{$ENDIF})
Public
 Procedure Edit; override;
 Function  GetAttributes : TPropertyAttributes; Override;
 Function  GetValue      : String;              Override;
End;

Procedure TDWAboutDialogProperty.Edit;
Begin
 RESTDWAboutDialog;
End;

Function TDWAboutDialogProperty.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadOnly];
End;

Function TDWAboutDialogProperty.GetValue: String;
Begin
 Result := 'Version : '+ RESTDWVERSAO;
End;

procedure TRESTDWServerContextEditor.ExecuteVerb(Index: Integer);
Begin
 Case Index of
  0 : {$IFNDEF FPC}
       ShowCollectionEditor(Designer, Component, TRESTDWServerContext(Component).ContextList, 'ContextList');
      {$ELSE}
       TCollectionPropertyEditor.ShowCollectionEditor(TRESTDWServerContext(Component).ContextList, Component, 'ContextList');
      {$ENDIF}
 End;
end;

procedure TRESTDWContextRulesEditor.ExecuteVerb(Index: Integer);
Begin
 Case Index of
  0 : {$IFNDEF FPC}
       ShowCollectionEditor(Designer, Component, TRESTDWContextRules(Component).Items, 'Items');
      {$ELSE}
       TCollectionPropertyEditor.ShowCollectionEditor(TRESTDWContextRules(Component).Items, Component, 'Items');
      {$ENDIF}
 End;
end;

Function TRESTDWServerContextEditor.GetVerb(Index: Integer): string;
Begin
 Case Index of
  0 : Result := '&ContextList Editor';
 End;
End;

Function TRESTDWContextRulesEditor.GetVerb(Index: Integer): string;
Begin
 Case Index of
  0 : Result := '&ContextRules Editor';
 End;
End;

Function TRESTDWServerContextEditor.GetVerbCount: Integer;
Begin
 Result := 1;
End;

Function TRESTDWContextRulesEditor.GetVerbCount: Integer;
Begin
 Result := 1;
End;

Procedure Register;
Begin
 {$IFNDEF FPC}
  RegisterNoIcon([TServerMethodDataModule]);
  RegisterCustomModule(TServerMethodDataModule, TCustomModule);
 {$ELSE}
  FormEditingHook.RegisterDesignerBaseClass(TServerMethodDataModule);
//  PDRESTDWCGIApplication    := TRESTDWCGIApplicationDescriptor.Create;
//  RegisterProjectDescriptor (PDRESTDWCGIApplication);
//  PDRESTDWCGIDatamodule     := TRESTDWCGIDatamodule.Create;
//  PDRESTDWDatamodule        := TRESTDWDatamodule.Create;
//  RegisterProjectFileDescriptor(PDRESTDWDatamodule);
//  FormEditingHook.RegisterDesignerBaseClass(TServerMethodDataModule);
 {$ENDIF}
// RegisterComponents('REST Dataware - Service',     [TRESTDWServiceNotification]);
 RegisterComponents('REST Dataware - Client''s',   [TRESTDWClientEvents]);
 RegisterComponents('REST Dataware - API',         [TRESTDWServerEvents, TRESTDWServerContext, TRESTDWContextRules]);
 RegisterComponents('REST Dataware - Tools',       [TRESTDWResponseTranslator, TRESTDWBufferDB]);

 RegisterComponents('REST Dataware - DB',          [TRESTDWPoolerDB,        TRESTDWClientSQL,  TRESTDWMemtable, TRESTDWTable,      TRESTDWUpdateSQL,
                                                   TRESTDWMassiveSQLCache, TRESTDWStoredProc, TRESTDWPoolerList, TRESTDWMassiveCache,  TRESTDWBatchMove]);
// AddIDEMenu;//Menu do REST Debugger
 {$IFNDEF FPC}
  RegisterPropertyEditor(TypeInfo(TRESTDWAboutInfo),   Nil, 'AboutInfo', TDWAboutDialogProperty);
//  RegisterPropertyEditor(TypeInfo(TRESTDWAboutInfoDS), Nil, 'AboutInfo', TDWAboutDialogProperty);
//  RegisterPackageWizard(TCustomMenuItemDW.Create);//Request Debbuger
 {$ELSE}
  RegisterPropertyEditor(TypeInfo(TRESTDWAboutInfo),   Nil, 'AboutInfo', TDWAboutDialogProperty);
//  RegisterPropertyEditor(TypeInfo(TRESTDWAboutInfoDS), Nil, 'AboutInfo', TDWAboutDialogProperty);
 {$ENDIF}
  RegisterPropertyEditor(TypeInfo(String),            TRESTDWTable,              'Tablename',       TTableList);
  RegisterPropertyEditor(TypeInfo(String),            TRESTDWClientEvents,       'ServerEventName', TServerEventsList);
  RegisterPropertyEditor(TypeInfo(TStrings),          TRESTDWClientSQL,          'SQL',             TRESTDWSQLEditor);
  RegisterPropertyEditor(TypeInfo(TStrings),          TRESTDWClientSQL,          'RelationFields',  TRESTDWFieldsRelationEditor);
  RegisterPropertyEditor(TypeInfo(String),            TRESTDWClientSQL,          'SequenceField',   TRESTDWFieldsList);
  RegisterComponentEditor(TRESTDWServerEvents,        TComponentEditorClass(TRESTDWServerEventsEditor));
  RegisterComponentEditor(TRESTDWClientEvents,        TComponentEditorClass(TRESTDWClientEventsEditor));
  RegisterComponentEditor(TRESTDWResponseTranslator,  TComponentEditorClass(TRESTDWJSONViewer));
  RegisterPropertyEditor (TypeInfo(TRESTDWComponent), TRESTDWResponseTranslator, 'ClientREST', TRESTDWClientRESTList);
  RegisterComponentEditor(TRESTDWServerContext,       TComponentEditorClass(TRESTDWServerContextEditor));
  RegisterComponentEditor(TRESTDWContextRules,        TComponentEditorClass(TRESTDWContextRulesEditor));
 {$IFNDEF FPC}
  RegisterComponentEditor(TRESTDWClientSQL,         TRESTDWClientSQLEditor);
  RegisterComponentEditor(TRESTDWServerContext,     TRESTDWServerContextEditor);
  RegisterComponentEditor(TRESTDWContextRules,      TRESTDWContextRulesEditor);
 {$ENDIF}
End;

{ TRESTDWServerEventsEditor }

procedure TRESTDWServerEventsEditor.ExecuteVerb(Index: Integer);
begin
 Inherited;
 Case Index of
  0 : Begin
       {$IFNDEF FPC}
        ShowCollectionEditor(Designer, Component, (Component as TRESTDWServerEvents).Events, 'Events');
       {$ELSE}
        TCollectionPropertyEditor.ShowCollectionEditor(TRESTDWServerEvents(Component).Events, Component, 'Events');
       {$ENDIF}
      End;
 End;
End;

Function TRESTDWServerEventsEditor.GetVerb(Index: Integer): String;
Begin
 Case Index of
  0 : Result := 'Events &List';
 End;
End;

function TRESTDWServerEventsEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

Procedure TRESTDWClientEventsEditor.ExecuteVerb(Index: Integer);
Begin
 Inherited;
 Case Index of
   0 : Begin
        {$IFNDEF FPC}
         ShowCollectionEditor(Designer, Component, TRESTDWClientEvents(Component).Events, 'Events');
        {$ELSE}
         TCollectionPropertyEditor.ShowCollectionEditor(TRESTDWClientEvents(Component).Events,Component, 'Events');
        {$ENDIF}
       End;
   1 : (Component as TRESTDWClientEvents).GetEvents := True;
   2 : (Component as TRESTDWClientEvents).ClearEvents;
 End;
End;

Function TRESTDWClientEventsEditor.GetVerb(Index: Integer): string;
Begin
 Case Index of
  0 : Result := 'Events &List';
  1 : Result := '&Get Server Events';
  2 : Result := '&Clear Client Events';
 End;
End;

Function TRESTDWClientEventsEditor.GetVerbCount: Integer;
Begin
 Result := 3;
End;

{$IFNDEF FPC}
Function TDWDSDesigner.DoCreateField(Const FieldName : {$IF CompilerVersion > 17}WideString{$ELSE}String{$IFEND}; Origin: string): TField;
Begin
// TDWCustomDataSet(DataSet).DesignNotify(FieldName, 0);
// Result  := Inherited DoCreateField(FieldName, Origin);
// TDWCustomDataSet(DataSet).DesignNotify(FieldName, 104);
End;
{$ENDIF}

{ TServerEventsList }

procedure TServerEventsListCV.Edit;
Var
 vTempData : String;
Begin
 Inherited Edit;
 Try
  vTempData := GetValue;
  SetValue(vTempData);
 Finally
 End;
End;

procedure TServerEventsList.Edit;
Var
 vTempData : String;
Begin
 Inherited Edit;
 Try
  vTempData := GetValue;
  SetValue(vTempData);
 Finally
 End;
End;


Function TServerEventsListCV.GetAttributes: TPropertyAttributes;
begin
  // editor, sorted list, multiple selection
 Result := [paValueList, paSortList];
end;

Function TServerEventsList.GetAttributes: TPropertyAttributes;
begin
  // editor, sorted list, multiple selection
 Result := [paValueList, paSortList];
end;

procedure TServerEventsListCV.GetValues(Proc: TGetStrProc);
Var
 vLista : TStringList;
 I      : Integer;
Begin
 //Provide a list of Poolers
 vLista := Nil;
// With GetComponent(0) as TRESTDWConnectionServerCP Do
//  Begin
//   vLista := TRESTDWConnectionServerCP(GetComponent(0)).GetPoolerList;
//   Try
//    For I := 0 To vLista.Count -1 Do
//     Proc (vLista[I]);
//   Except
//   End;
//   FreeAndNil(vLista);
//  End;
End;

procedure TServerEventsList.GetValues(Proc: TGetStrProc);
Var
 vLista : TStringList;
 I      : Integer;
 Function GetRestPoolers : TStringList;
 Var
  vTempList         : TStringList;
  vConnection       : TRESTDWPoolerMethodClient;
  I                 : Integer;
  vRESTClientPooler : TRESTClientPoolerBase;
 Begin
  Result := Nil;
  If TRESTDWClientEvents(GetComponent(0)).RESTClientPooler <> Nil Then
   Begin
    vRESTClientPooler                     := TRESTDWClientEvents(GetComponent(0)).RESTClientPooler;
    vConnection                           := TRESTDWPoolerMethodClient.Create(Nil);
    vConnection.WelcomeMessage            := vRESTClientPooler.WelcomeMessage;
    vConnection.Host                      := vRESTClientPooler.Host;
    vConnection.Port                      := vRESTClientPooler.Port;
    vConnection.Compression               := vRESTClientPooler.DataCompression;
    vConnection.TypeRequest               := vRESTClientPooler.TypeRequest;
    vConnection.AccessTag                 := vRESTClientPooler.AccessTag;
    vConnection.CriptOptions.Use          := vRESTClientPooler.CriptOptions.Use;
    vConnection.CriptOptions.Key          := vRESTClientPooler.CriptOptions.Key;
    vConnection.DataRoute                 := vRESTClientPooler.DataRoute;
    vConnection.AuthenticationOptions.Assign(vRESTClientPooler.AuthenticationOptions);
    Result := TStringList.Create;
    Try
     vTempList := vConnection.GetServerEvents(vRESTClientPooler.DataRoute,
                                              vRESTClientPooler.RequestTimeOut,
                                              vRESTClientPooler.ConnectTimeOut,
                                              vRESTClientPooler);
     Try
      For I := 0 To vTempList.Count -1 do
       Result.Add(vTempList[I]);
     Finally
      If Assigned(vTempList) Then
       vTempList.Free;
     End;
    Except
     On E : Exception do
      Begin
       Raise Exception.Create(E.Message);
      End;
    End;
    FreeAndNil(vConnection);
   End;
 End;
Begin
 //Provide a list of Poolers
 vLista := Nil;
 With TRESTDWClientEvents(GetComponent(0)) Do
  Begin
   vLista := GetRestPoolers;
   Try
    For I := 0 To vLista.Count -1 Do
     Proc (vLista[I]);
   Except
   End;
   FreeAndNil(vLista);
  End;
End;

{ TRESTDWFieldsList }

procedure TRESTDWFieldsList.Edit;
Var
 vTempData : String;
Begin
 Inherited Edit;
 Try
  vTempData := GetValue;
  SetValue(vTempData);
 Finally
 End;
End;

Function TRESTDWFieldsList.GetAttributes : TPropertyAttributes;
Begin
  // editor, sorted list, multiple selection
 Result := [paValueList, paSortList];
End;

procedure TRESTDWFieldsList.GetValues(Proc: TGetStrProc);
Var
 I      : Integer;
Begin
 //Provide a list of Poolers
 With GetComponent(0) as TRESTDWClientSQL Do
  Begin
   Try
    If TRESTDWClientSQL(GetComponent(0)).Fields.Count > 0 Then
     Begin
      For I := 0 To TRESTDWClientSQL(GetComponent(0)).Fields.Count -1 Do
       Proc (TRESTDWClientSQL(GetComponent(0)).Fields[I].FieldName);
     End
    Else
     Begin
      For I := 0 To TRESTDWClientSQL(GetComponent(0)).FieldDefs.Count -1 Do
       Proc (TRESTDWClientSQL(GetComponent(0)).FieldDefs[I].Name);
     End;
   Except
   End;
  End;
End;

{$IFDEF FPC}
 Procedure UnlistPublishedProperty (ComponentClass:TPersistentClass; const PropertyName:String);
 var
   pi :PPropInfo;
 begin
   pi := TypInfo.GetPropInfo (ComponentClass, PropertyName);
   if (pi <> nil) then
     RegisterPropertyEditor (pi^.PropType, ComponentClass, PropertyName, PropEdits.THiddenPropertyEditor);
 end;
{$ENDIF}

{ TRESTDWClientRESTList }

procedure TRESTDWClientRESTList.GetValues(Proc: TGetStrProc);
Var
 I         : Integer;
 COwner,
 Component : TComponent;
 PropClass : TClass;
 Finded    : Boolean;
Begin
// COwner := FormEditor.FormDesigner.GetRoot;
 {$IFDEF FPC}
 COwner := TComponent(GetComponent(0)).GetParentComponent;
 {$ELSE}
 COwner := Designer.GetRoot;
 {$ENDIF}
 PropClass := TRESTDWClientRESTBase;
 For I := 0 to COwner.ComponentCount - 1 Do
  Begin
   Component := COwner.Components[I];
   Finded := (Component.ClassType = TRESTDWClientRESTBase) Or
             (Component.InheritsFrom(TRESTDWClientRESTBase));
   If (Component Is PropClass) And
      (Component.Name <> '')   And
      (Finded)                 Then
    Proc(Component.Name);
  End;
End;

initialization
 {$IFNDEF FPC}
  {$IFDEF  RTL240_UP}
 	RegisterAboutBox;
   AddSplash;
  {$ENDIF}
 {$ENDIF}
 {$IFDEF FPC}
  {$I restdatawarecomponents.lrs}
 {$ENDIF}
 UnlistPublishedProperty(TRESTDWClientSQL,  'FieldDefs');
 UnlistPublishedProperty(TRESTDWClientSQL,  'Options');
 UnlistPublishedProperty(TRESTDWStoredProc, 'SequenceName');
 UnlistPublishedProperty(TRESTDWStoredProc, 'SequenceField');
 UnlistPublishedProperty(TRESTDWStoredProc, 'OnWriterProcess');
 UnlistPublishedProperty(TRESTDWStoredProc, 'FieldDefs');
 UnlistPublishedProperty(TRESTDWStoredProc, 'Options');
 UnlistPublishedProperty(TRESTDWClientSQL,  'CachedUpdates');
 UnlistPublishedProperty(TRESTDWClientSQL,  'MasterSource');
 UnlistPublishedProperty(TRESTDWClientSQL,  'MasterFields');
 UnlistPublishedProperty(TRESTDWClientSQL,  'DetailFields');
 UnlistPublishedProperty(TRESTDWClientSQL,  'ActiveStoredUsage');
 UnlistPublishedProperty(TRESTDWClientSQL,  'Adapter');
 UnlistPublishedProperty(TRESTDWClientSQL,  'ChangeAlerter');
 UnlistPublishedProperty(TRESTDWClientSQL,  'ChangeAlertName');
 UnlistPublishedProperty(TRESTDWClientSQL,  'DataSetField');
 UnlistPublishedProperty(TRESTDWClientSQL,  'FetchOptions');
 UnlistPublishedProperty(TRESTDWClientSQL,  'ObjectView');
 UnlistPublishedProperty(TRESTDWClientSQL,  'ResourceOptions');
 UnlistPublishedProperty(TRESTDWClientSQL,  'StoreDefs');
 UnlistPublishedProperty(TRESTDWClientSQL,  'UpdateOptions');
 UnlistPublishedProperty(TRESTDWClientSQL,  'LocalSQL');
 UnlistPublishedProperty(TRESTDWClientSQL,  'FieldOptions');
 UnlistPublishedProperty(TRESTDWClientSQL,  'Constraints');
 UnlistPublishedProperty(TRESTDWClientSQL,  'ConstraintsEnabled');
 UnlistPublishedProperty(TRESTDWStoredProc, 'StoreDefs');
 UnlistPublishedProperty(TRESTDWStoredProc, 'SequenceName');
 UnlistPublishedProperty(TRESTDWStoredProc, 'SequenceField');
 UnlistPublishedProperty(TRESTDWStoredProc, 'OnWriterProcess');
 UnlistPublishedProperty(TRESTDWStoredProc, 'UpdateOptions');
 UnlistPublishedProperty(TRESTDWStoredProc, 'FetchOptions');
 UnlistPublishedProperty(TRESTDWStoredProc, 'ObjectView');
 UnlistPublishedProperty(TRESTDWStoredProc, 'ResourceOptions');
 UnlistPublishedProperty(TRESTDWStoredProc, 'CachedUpdates');
 UnlistPublishedProperty(TRESTDWStoredProc, 'MasterSource');
 UnlistPublishedProperty(TRESTDWStoredProc, 'MasterFields');
 UnlistPublishedProperty(TRESTDWStoredProc, 'DetailFields');
 UnlistPublishedProperty(TRESTDWStoredProc, 'ActiveStoredUsage');
 UnlistPublishedProperty(TRESTDWStoredProc, 'Adapter');

Finalization
 {$IFNDEF FPC}
 {$IFDEF  RTL240_UP}
	UnregisterAboutBox;
 {$ENDIF}
 {$ENDIF}

end.
