unit uRESTDWDesignReg;

{$I ..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

interface

uses
  {$IFDEF RESTDWLAZARUS}
    StdCtrls, ComCtrls, Forms, ExtCtrls, DBCtrls, DBGrids, Dialogs, Controls,
    LResources, LazFileUtils,  FormEditingIntf, PropEdits, lazideintf,
    ProjectIntf, ComponentEditors, fpWeb, TypInfo,
  {$ELSE}
    Windows,
   {$IFDEF DELPHIXE2UP}
     vcl.Graphics,
   {$ELSE}
     Graphics, DbTables,
   {$ENDIF}
  ToolsApi, DesignEditors, DSDesign, DesignIntf, ColnEdit,
  {$ENDIF}
  Db, SysUtils, Classes, Menus,
  uRESTDWBasicClass, uRESTDWDatamodule, uRESTDWServerEvents, uRESTDWBasicDB,
  uRESTDWServerContext, uRESTDWMassiveBuffer, uRESTDWMemoryDataset, uRESTDWBufferDb,
  uRESTDWAbout, uRESTDWDriverBase, uRESTDWAuthenticators;

{$IFNDEF RESTDWDELPHINET}
Const
 varUString  = Succ(Succ(varString)); { Variant type code }
{$ENDIF}

Var
 EnabledAllTableDefs : Boolean = False;
 LoadAndStoreToForm  : Boolean = False;

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

Type
  TDriverConnectionListProperty = class(TComponentProperty)
  public
    function  GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
  end;


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

{$IFNDEF RESTDWLAZARUS}
Type
 TDSDesignerDW = Class(TDSDesigner)
 Private
 Public
  {$IFDEF DELPHI2006UP}
  Function  DoCreateField(const FieldName: WideString; Origin: string): TField; override;
  {$ELSE}
  Function  DoCreateField(const FieldName: String; Origin: string): TField; override;
  {$ENDIF}
  Function SupportsAggregates: Boolean; Override;
  Function SupportsInternalCalc: Boolean; Override;
  Procedure BeginUpdateFieldDefs; Override;
  Procedure InitializeMenu(Menu: TPopupMenu); Override;
  Procedure UpdateMenus(Menu: TPopupMenu; EditState: TEditState); Override;
End;

Type
 TRESTDWClientSQLEditor = Class(TComponentEditor)
 Private
  Procedure EditFields(DataSet: TDataSet);
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


{$IFDEF RESTDWLAZARUS}
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

{$IFDEF RESTDWLAZARUS}
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
  {$IFDEF RESTDWLAZARUS} utemplateproglaz,{$ENDIF}
   uRESTDWConsts, uRESTDWPoolermethod, uRESTDWBasic, uRESTDWResponseTranslator,
   uRESTDWFieldSourceEditor, uRESTDWSqlEditor, uRESTDWUpdSqlEditor,
   uRESTDWJSONViewer;

{$IFDEF DELPHIXE3UP}
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
{$ELSE}

Constructor TRESTDWCGIApplicationDescriptor.Create;
Begin
 inherited Create;
 Flags := Flags - [pfMainUnitHasCreateFormStatements];
 Name  := 'REST Dataware - CGI Application';
End;

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

Function TRESTDWDatamodule.GetInterfaceUsesSection : String;
Begin
 Result  := Inherited GetInterfaceUsesSection;
 Result  := Result + ', SysTypes, uRESTDWBasicTypes, uRESTDWJSONObject,' + LineEnding;
 Result  := Result + '  uRESTDWParams, uRESTDWDataUtils, uRESTDWComponentEvents, uRESTDWDatamodule';
End;

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

Function TRESTDWCGIApplicationDescriptor.GetLocalizedDescription : String;
Begin
 Result := Format(rsRESTDWCGIApplicatiDesc, [#13#13]);
End;

Function TRESTDWDatamodule.GetLocalizedDescription : String;
Begin
 Result := Format(rsRESTDWDatamoduleADa, [#13#13]);
End;

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

Function TRESTDWCGIApplicationDescriptor.CreateStartFiles(AProject : TLazProject): TModalResult;
Begin
 LazarusIDE.DoNewEditorFile(PDRESTDWDatamodule, '', '',
                            [nfIsPartOfProject, nfOpenInEditor, nfCreateDefaultSrc]);
 Result:= mrOK;
End;
{$ENDIF}


{$IFNDEF RESTDWLAZARUS}
Procedure TDSDesignerDW.BeginUpdateFieldDefs;
Var
 Idx: Integer;
Begin
 Inherited;
 For Idx := Dataset.FieldDefs.Count -1 DownTo 0 do
  Begin
   If Trim(Dataset.FieldDefs[Idx].Name) = '' then
    Dataset.FieldDefs.Delete(Idx);
  End;
End;

Procedure TDSDesignerDW.InitializeMenu(Menu: TPopupMenu);
Begin
 Inherited;
// Ao clicar duas vezes no componente RESTDWClientSQL
// ou ao selecionar no popup menu opção "Fields Editor".
End;

Procedure TDSDesignerDW.UpdateMenus(Menu: TPopupMenu; EditState: TEditState);
Begin
// Ao acionar o popup menu dos Fields persistents: (Add, Add All, New Field)
 Inherited;
 If not TRESTDWClientSQL(DataSet).Active Then
   TRESTDWClientSQL(DataSet).Open;
End;

Procedure TRESTDWClientSQLEditor.EditFields(DataSet: TDataSet);
begin
 {$IFDEF DELPHIXEUP}
  TRESTDWClientSQL(Component).SetInDesignEvents(True);
 {$ENDIF}
 Try
  {$IFNDEF DELPHIXEUP}
    TRESTDWClientSQL(Component).Close;
    TRESTDWClientSQL(Component).CreateDatasetFromList;
  {$ENDIF}
  ShowFieldsEditor(Designer, TRESTDWClientSQL(Component), TDSDesignerDW);
 Finally
  {$IFDEF DELPHIXEUP}
   TRESTDWClientSQL(Component).SetInDesignEvents(False);
  {$ENDIF}
 End;
End;

procedure TRESTDWClientSQLEditor.Edit;
Begin
 EditFields(TDataSet(Component));
end;

procedure TRESTDWClientSQLEditor.ExecuteVerb(Index: Integer);
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

{$IFDEF DELPHI2006UP}
Function  TDSDesignerDW.DoCreateField(const FieldName: WideString; Origin: string): TField;
{$ELSE}
Function  TDSDesignerDW.DoCreateField(const FieldName: String; Origin: string): TField;
{$ENDIF}
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
Begin

End;

Procedure TTableList.GetValues(Proc : TGetStrProc);
Var
 vLista : TStringList;
 I      : Integer;
Begin
 //Provide a list of Tables
 vLista := Nil;
 If GetComponent(0) is TRESTDWTable Then
  Begin
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
  End
 Else If GetComponent(0) is TRESTDWClientSQL Then
  Begin
   With GetComponent(0) as TRESTDWClientSQL Do
    Begin
     Try
      If TRESTDWClientSQL(GetComponent(0)).DataBase <> Nil Then
       Begin
        TRESTDWClientSQL(GetComponent(0)).DataBase.GetTableNames(vLista);
        For I := 0 To vLista.Count -1 Do
        Proc (vLista[I]);
       End;
     Except
     End;
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
 TDWAboutDialogProperty = class({$IFDEF RESTDWLAZARUS}TClassPropertyEditor{$ELSE}TPropertyEditor{$ENDIF})
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
  0 : {$IFNDEF RESTDWLAZARUS}
       ShowCollectionEditor(Designer, Component, TRESTDWServerContext(Component).ContextList, 'ContextList');
      {$ELSE}
       TCollectionPropertyEditor.ShowCollectionEditor(TRESTDWServerContext(Component).ContextList, Component, 'ContextList');
      {$ENDIF}
 End;
end;

procedure TRESTDWContextRulesEditor.ExecuteVerb(Index: Integer);
Begin
 Case Index of
  0 : {$IFNDEF RESTDWLAZARUS}
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
 {$IFNDEF RESTDWLAZARUS}
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
 RegisterComponents('REST Dataware - Client',      [TRESTDWClientEvents]);
 RegisterComponents('REST Dataware - API',         [TRESTDWServerEvents,       TRESTDWServerContext, TRESTDWContextRules]);
 RegisterComponents('REST Dataware - Tools',       [TRESTDWResponseTranslator, TRESTDWBufferDB]);
 RegisterComponents('REST Dataware - DB',          [TRESTDWPoolerDB,           TRESTDWMemTable,      TRESTDWClientSQL,
                                                    TRESTDWTable,              TRESTDWUpdateSQL,     TRESTDWMassiveSQLCache,
                                                    TRESTDWStoredProcedure,    TRESTDWMassiveCache,  TRESTDWBatchMove]);
 RegisterComponents('REST Dataware - Authenticators', [TRESTDWAuthBasic,       TRESTDWAuthToken,     TRESTDWAuthOAuth]);
// AddIDEMenu;//Menu do REST Debugger
 {$IFNDEF RESTDWLAZARUS}
  RegisterPropertyEditor(TypeInfo(TRESTDWAboutInfo),   Nil, 'AboutInfo', TDWAboutDialogProperty);
//  RegisterPackageWizard(TCustomMenuItemDW.Create);//Request Debbuger
 {$ELSE}
  RegisterPropertyEditor(TypeInfo(TRESTDWAboutInfo),   Nil, 'AboutInfo', TDWAboutDialogProperty);
//  RegisterPropertyEditor(TypeInfo(TRESTDWAboutInfoDS), Nil, 'AboutInfo', TDWAboutDialogProperty);
 {$ENDIF}
  RegisterPropertyEditor(TypeInfo(TComponent),        TRESTDWDriverBase,         'Connection',      TDriverConnectionListProperty);
  RegisterPropertyEditor(TypeInfo(String),            TRESTDWTable,              'Tablename',       TTableList);
  RegisterPropertyEditor(TypeInfo(String),            TRESTDWClientEvents,       'ServerEventName', TServerEventsList);
  RegisterPropertyEditor(TypeInfo(TStrings),          TRESTDWClientSQL,          'SQL',             TRESTDWSQLEditor);
  RegisterPropertyEditor(TypeInfo(TStrings),          TRESTDWClientSQL,          'RelationFields',  TRESTDWFieldsRelationEditor);
  RegisterPropertyEditor(TypeInfo(String),            TRESTDWClientSQL,          'SequenceField',   TRESTDWFieldsList);
  RegisterPropertyEditor(TypeInfo(String),            TRESTDWClientSQL,          'UpdateTableName', TTableList);

  RegisterComponentEditor(TRESTDWServerEvents,        TComponentEditorClass(TRESTDWServerEventsEditor));
  RegisterComponentEditor(TRESTDWClientEvents,        TComponentEditorClass(TRESTDWClientEventsEditor));
  RegisterComponentEditor(TRESTDWResponseTranslator,  TComponentEditorClass(TRESTDWJSONViewer));
  RegisterPropertyEditor (TypeInfo(TRESTDWComponent), TRESTDWResponseTranslator, 'ClientREST', TRESTDWClientRESTList);
  RegisterComponentEditor(TRESTDWServerContext,       TComponentEditorClass(TRESTDWServerContextEditor));
  RegisterComponentEditor(TRESTDWContextRules,        TComponentEditorClass(TRESTDWContextRulesEditor));
 {$IFNDEF RESTDWLAZARUS}
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
       {$IFNDEF RESTDWLAZARUS}
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
        {$IFNDEF RESTDWLAZARUS}
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
Begin

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
 I : Integer;
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

{$IFDEF RESTDWLAZARUS}
 Procedure UnlistPublishedProperty (ComponentClass:TPersistentClass; const PropertyName:String);
 var
   pi : PPropInfo;
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
 {$IFDEF RESTDWLAZARUS}
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

{ TDriverConnectionListProperty }

function TDriverConnectionListProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList];
end;

procedure TDriverConnectionListProperty.GetValueList(List: TStrings);
var
  comp : TComponent;
  drv : TRESTDWDriverBase;
  i : integer;
begin
  drv  := TRESTDWDriverBase(GetComponent(0));
  comp := drv.Owner;
  if Assigned(Comp) then begin
    i := 0;
    while i < comp.ComponentCount do begin
      if drv.compConnIsValid(comp.Components[i]) then
        List.Add(comp.Components[i].Name);

      i := i + 1;
    end;
  end;
end;

procedure TDriverConnectionListProperty.GetValues(Proc: TGetStrProc);
var
  i: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for i := 0 to Pred(Values.Count) do
      Proc(Values[i]);
  finally
    Values.Free;
  end;
end;

initialization
  {$IFDEF DELPHIXE3UP}
 	RegisterAboutBox;
  AddSplash;
 {$ENDIF}
 {$IFDEF RESTDWLAZARUS}
   {$I RESTDataWareComponents.lrs}
 {$ENDIF}
 UnlistPublishedProperty(TRESTDWClientSQL,  'FieldDefs');
 UnlistPublishedProperty(TRESTDWClientSQL,  'Options');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'SequenceName');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'SequenceField');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'OnWriterProcess');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'FieldDefs');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'Options');
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
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'StoreDefs');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'SequenceName');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'SequenceField');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'OnWriterProcess');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'UpdateOptions');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'FetchOptions');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'ObjectView');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'ResourceOptions');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'CachedUpdates');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'MasterSource');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'MasterFields');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'DetailFields');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'ActiveStoredUsage');
 UnlistPublishedProperty(TRESTDWStoredProcedure, 'Adapter');

Finalization
 {$IFDEF DELPHIXE3UP}UnregisterAboutBox; {$ENDIF}

end.
