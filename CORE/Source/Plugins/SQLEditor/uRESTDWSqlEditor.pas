unit uRESTDWSqlEditor;

{$I ..\..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

uses
  SysUtils, Dialogs, Forms, ExtCtrls, StdCtrls, ComCtrls, DBGrids, uRESTDWBasicDB, DB{$IFNDEF FPC}, Grids{$ENDIF}, Controls,
  Classes,{$IFDEF FPC}FormEditingIntf, PropEdits, lazideintf{$ELSE}DesignEditors, DesignIntf{$ENDIF};

Const
 cSelect = 'Select %s From %s';
 cInsert = 'Insert into %s (%s) Values (%s)';
 cDelete = 'Delete From %s Where ';
 cUpdate = 'Update %s Set %s Where ';

 Type

  { TFrmDWSqlEditor }

  TFrmDWSqlEditor = class(TForm)
   BtnCancelar: TButton;
   BtnExecute: TButton;
   BtnOk: TButton;
   DBGridRecord: TDBGrid;
   PageControlResult: TPageControl;
   PnlAction: TPanel;
   PnlButton: TPanel;
   PnlSQL: TPanel;
   pSQLEditor: TPanel;
   lbTables: TListBox;
   labSql: TLabel;
   Label1: TLabel;
   lbFields: TListBox;
   Label2: TLabel;
   pSQLTypes: TPanel;
   rbInsert: TRadioButton;
   rbSelect: TRadioButton;
   rbDelete: TRadioButton;
   rbUpdate: TRadioButton;
   TabSheetTable: TTabSheet;
   pEditor: TPanel;
   PageControl: TPageControl;
   TabSheetSQL: TTabSheet;
   Memo: TMemo;
   Panel1: TPanel;
   Label3: TLabel;
   lbExecutedTime: TLabel;
   procedure BtnExecuteClick(Sender: TObject);
   {$IFNDEF FPC}
   procedure FormClose(Sender: TObject; var Action: TCloseAction);
   {$ELSE}
   procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
   {$ENDIF}
   procedure FormShow(Sender: TObject);
   procedure FormCreate(Sender: TObject);
   procedure lbTablesClick(Sender: TObject);
   procedure lbTablesKeyUp(Sender: TObject; var Key: Word;
     Shift: TShiftState);
   procedure MemoDragOver(Sender, Source: TObject; X, Y: Integer;
     State: TDragState; var Accept: Boolean);
   procedure MemoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure BtnCancelarClick(Sender: TObject);
 Private
  { Private declarations }
  DataSource         : TDataSource;
  RESTDWDatabase     : TRESTDWDatabasebaseBase;
  RESTDWClientSQL,
  RESTDWClientSQLB   : TRESTDWClientSQL;
  vLastSelect,
  vOldSQL            : String;
  Procedure SetFields;
  Function  BuildSQL : String;
  Procedure SetDatabase(Value : TRESTDWDatabasebaseBase);
  Procedure SetarControles(enab : boolean);
 Public
  { Public declarations }
  Procedure SetClientSQL(Value : TRESTDWClientSQL);
  Property  Database : TRESTDWDatabasebaseBase Read RESTDWDatabase Write SetDatabase;
 End;

 Type
  TRESTDWSQLEditor = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

Var
 FrmDWSqlEditor : TFrmDWSqlEditor;

Implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

Function TRESTDWSQLEditor.GetValue : String;
Begin
 Result := Trim(TRESTDWClientSQL(GetComponent(0)).SQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set SQL...'
End;

Procedure TRESTDWSQLEditor.Edit;
Var
 objObj : TRESTDWClientSQL;
Begin
 FrmDWSqlEditor := TFrmDWSqlEditor.Create(Application);
 Try
  objObj        := TRESTDWClientSQL(GetComponent(0));
  FrmDWSqlEditor.SetClientSQL(objObj);
  FrmDWSqlEditor.ShowModal;
  objObj        := Nil;
  FrmDWSqlEditor.Free;
 Except
 End;
End;

Function TRESTDWSQLEditor.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paAutoUpdate];
End;

procedure TFrmDWSqlEditor.BtnCancelarClick(Sender: TObject);
begin
  BtnCancelar.Tag := 1;
end;

Procedure TFrmDWSqlEditor.BtnExecuteClick(Sender: TObject);
var
  dti, dtf : TDateTime;
Begin
 Screen.Cursor := crHourGlass;
 Try
  RESTDWClientSQLB.Close;
  RESTDWClientSQLB.BinaryRequest := RESTDWClientSQL.BinaryRequest;
  RESTDWClientSQLB.SQL.Clear;
  RESTDWClientSQLB.SQL.Add(Memo.Lines.Text);

  dti := Now;
  RESTDWClientSQLB.Open;
  dtf := Now;
 Finally
  lbExecutedTime.Caption := FormatDateTime('HH:nn:ss:zzz',dtf-dti);
  Screen.Cursor := crDefault;
 End;
End;

{$IFNDEF FPC}
procedure TFrmDWSqlEditor.FormClose(Sender: TObject; var Action: TCloseAction);
{$ELSE}
procedure TFrmDWSqlEditor.FormClose(Sender: TObject; var CloseAction: TCloseAction);
{$ENDIF}
begin
 If (ModalResult = mrCancel) and (vOldSQL <> Memo.Text) and (BtnCancelar.Tag = 1) Then
 Begin
   {$IFDEF FPC}
    If MessageDlg('SQL Editor', 'Realmente deseja sair ?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
     Begin
      BtnCancelar.Tag := 0;
      CloseAction:=caNone;
      Exit;
     End;
  {$ELSE}
    If MessageDlg('Realmente deseja sair ?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
     Begin
      BtnCancelar.Tag := 0;
      Action:=caNone;
      Exit;
     End;
  {$ENDIF}
 End;

 if ModalResult <> mrCancel then
   RESTDWClientSQL.SQL.Assign(Memo.Lines);

 RESTDWClientSQLB.Active := False;
 FreeAndNil(RESTDWClientSQLB);
 If Assigned(RESTDWDatabase) Then
  RESTDWDatabase.Active   := False;
 FreeAndNil(DataSource);
 Release;
end;

procedure TFrmDWSqlEditor.FormCreate(Sender: TObject);
begin
 RESTDWClientSQLB := TRESTDWClientSQL.Create(Self);
 DataSource       := TDataSource.Create(Self);
 vLastSelect      := '';
 SetarControles(False);
end;

procedure TFrmDWSqlEditor.FormShow(Sender: TObject);
begin
 DataSource.DataSet        := RESTDWClientSQLB;
 DBGridRecord.DataSource   := DataSource;
end;

Procedure TFrmDWSqlEditor.SetFields;
Var
 vMemString : TStringList;
Begin
 If (lbTables.Count > 0) And (lbTables.ItemIndex > -1)  And
    (vLastSelect <> lbTables.Items[lbTables.itemIndex]) Then
  Begin
   If RESTDWClientSQL.DataBase <> Nil Then
    Begin
     vLastSelect                          := lbTables.Items[lbTables.itemIndex];
     vMemString                           := TStringList.Create;
     Try
      RESTDWDatabase.GetFieldNames(lbTables.Items[lbTables.itemIndex], vMemString);
      lbFields.Items.Text                 := vMemString.Text;
     Finally
      FreeAndNil(vMemString);
     End;
    End;
  End
 Else If (lbTables.Count > 0) And (lbTables.ItemIndex = -1) Then
  lbFields.Items.Clear;
End;

procedure TFrmDWSqlEditor.SetarControles(enab: boolean);
begin
 PnlButton.Enabled         := enab;
 PageControlResult.Enabled := enab;
 pSQLEditor.Enabled        := enab;
end;

Procedure TFrmDWSqlEditor.SetClientSQL(Value: TRESTDWClientSQL);
Var
 vMemString : TStringList;
Begin
 RESTDWClientSQL           := Value;
 vOldSQL                   := '';
 Memo.Lines.Text           := vOldSQL;
 If Assigned(RESTDWClientSQL) Then
  Begin
   vOldSQL                   := RESTDWClientSQL.SQL.Text;
   Memo.Lines.Text           := vOldSQL;
   RESTDWDatabase            := RESTDWClientSQL.DataBase;
   RESTDWClientSQLB.DataBase := RESTDWDatabase;
   If RESTDWClientSQL.DataBase <> Nil Then
    Begin
     vMemString := TStringList.Create;
     Try
      RESTDWDatabase.GetTableNames(vMemString);
      lbTables.Items.Text := vMemString.Text;
      If lbTables.Count > 0 Then
       Begin
        SetarControles(True);
        lbTables.ItemIndex                 := 0;
        SetFields;
       End;
     Finally
      FreeAndNil(vMemString);
     End;
    End;
  End;
End;

Procedure TFrmDWSqlEditor.SetDatabase(Value : TRESTDWDatabasebaseBase);
Begin
 RESTDWClientSQLB.DataBase := Value;
End;

procedure TFrmDWSqlEditor.lbTablesClick(Sender: TObject);
begin
 SetFields;
end;

procedure TFrmDWSqlEditor.lbTablesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 SetFields;
end;

procedure TFrmDWSqlEditor.MemoDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
 Accept := Source is Tlistbox;
end;

Function TFrmDWSqlEditor.BuildSQL : String;
Var
 I         : Integer;
 vFieldsA,
 vFieldsB  : String;
Begin
 Result   := '';
 vFieldsA := Result;
 vFieldsB := Result;
 If lbTables.itemIndex < 0 Then
  Exit;
 If rbSelect.Checked Then
  Result := Format(cSelect, ['%s', lbTables.Items[lbTables.itemIndex]]);
 If rbInsert.Checked Then
  Result := Format(cInsert, [lbTables.Items[lbTables.itemIndex], '%s', '%s']);
 If rbDelete.Checked Then
  Result := Format(cDelete, [lbTables.Items[lbTables.itemIndex]]);
 If rbUpdate.Checked Then
  Result := Format(cUpdate, [lbTables.Items[lbTables.itemIndex], '%s']);
 If lbFields.SelCount > 0 Then
  Begin
   If rbSelect.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If lbFields.Selected[I] Then
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA]);
    End
   Else If rbInsert.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If lbFields.Selected[I] Then
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
       If lbFields.Selected[I] Then
       If vFieldsB = '' Then
        vFieldsB := ':' + lbFields.Items[I]
       Else
        vFieldsB := vFieldsB + ', :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA, vFieldsB]);
    End
   Else If rbUpdate.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If lbFields.Selected[I] Then
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I] + ' = :' + lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I] + ' = :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA]);
    End;
  End
 Else
  Begin
   If rbSelect.Checked Then
    Begin
     Result := Format(Result, ['*'])
    End
   Else If rbInsert.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I];
       If vFieldsB = '' Then
        vFieldsB := ':' + lbFields.Items[I]
       Else
        vFieldsB := vFieldsB + ', :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA, vFieldsB]);
    End
   Else If rbUpdate.Checked Then
    Begin
     For I := 0 To lbFields.Count -1 Do
      Begin
       If vFieldsA = '' Then
        vFieldsA := lbFields.Items[I] + ' = :' + lbFields.Items[I]
       Else
        vFieldsA := vFieldsA + ', ' + lbFields.Items[I] + ' = :' + lbFields.Items[I];
      End;
     Result := Format(Result, [vFieldsA]);
    End;
  End;
End;

procedure TFrmDWSqlEditor.MemoDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
 If Source = lbTables Then
  If Trim(TMemo(Sender).Lines.Text) = '' Then
   TMemo(Sender).Lines.Text := BuildSQL
  Else
   TMemo(Sender).Lines.Text := TMemo(Sender).Lines.Text + sLineBreak + BuildSQL;
end;

end.
