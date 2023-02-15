object FrmDWSqlEditor: TFrmDWSqlEditor
  Left = 479
  Top = 236
  BorderWidth = 5
  Caption = 'RESTDWClientSQL Editor'
  ClientHeight = 707
  ClientWidth = 1053
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PnlSQL: TPanel
    Left = 0
    Top = 0
    Width = 1053
    Height = 376
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PnlButton: TPanel
      Left = 958
      Top = 0
      Width = 95
      Height = 376
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object BtnExecute: TButton
        Left = 8
        Top = 20
        Width = 80
        Height = 25
        Caption = 'Execute'
        TabOrder = 0
        OnClick = BtnExecuteClick
      end
    end
    object pSQLEditor: TPanel
      Left = 0
      Top = 0
      Width = 209
      Height = 376
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object labSql: TLabel
        Left = 0
        Top = 0
        Width = 209
        Height = 23
        Align = alTop
        AutoSize = False
        Caption = ' .: TABLES'
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object Label1: TLabel
        Left = 0
        Top = 232
        Width = 209
        Height = 23
        Align = alTop
        AutoSize = False
        Caption = ' .: FIELDS'
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object Label2: TLabel
        Left = 0
        Top = 153
        Width = 209
        Height = 23
        Align = alTop
        AutoSize = False
        Caption = ' .: SQL TYPE'
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object lbTables: TListBox
        Left = 0
        Top = 23
        Width = 209
        Height = 130
        Align = alTop
        BorderStyle = bsNone
        DragMode = dmAutomatic
        ItemHeight = 13
        Sorted = True
        TabOrder = 0
        OnClick = lbTablesClick
        OnKeyUp = lbTablesKeyUp
      end
      object lbFields: TListBox
        Left = 0
        Top = 255
        Width = 209
        Height = 121
        Align = alClient
        BorderStyle = bsNone
        ItemHeight = 13
        MultiSelect = True
        TabOrder = 1
      end
      object pSQLTypes: TPanel
        Left = 0
        Top = 176
        Width = 209
        Height = 56
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object rbInsert: TRadioButton
          Left = 88
          Top = 8
          Width = 92
          Height = 17
          Caption = 'Insert'
          TabOrder = 0
        end
        object rbSelect: TRadioButton
          Left = 8
          Top = 8
          Width = 73
          Height = 17
          Caption = 'Select'
          Checked = True
          TabOrder = 1
          TabStop = True
        end
        object rbDelete: TRadioButton
          Left = 88
          Top = 32
          Width = 92
          Height = 17
          Caption = 'Delete'
          TabOrder = 2
        end
        object rbUpdate: TRadioButton
          Left = 8
          Top = 32
          Width = 73
          Height = 17
          Caption = 'Update'
          TabOrder = 3
        end
      end
    end
    object pEditor: TPanel
      Left = 209
      Top = 0
      Width = 749
      Height = 376
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      object PageControl: TPageControl
        Left = 0
        Top = 0
        Width = 749
        Height = 355
        ActivePage = TabSheetSQL
        Align = alClient
        TabOrder = 0
        object TabSheetSQL: TTabSheet
          BorderWidth = 5
          Caption = 'SQL Command'
          object Memo: TMemo
            Left = 0
            Top = 0
            Width = 731
            Height = 317
            Align = alClient
            ScrollBars = ssBoth
            TabOrder = 0
            OnDragDrop = MemoDragDrop
            OnDragOver = MemoDragOver
          end
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 355
        Width = 749
        Height = 21
        Align = alBottom
        BevelOuter = bvLowered
        TabOrder = 1
        object Label3: TLabel
          Left = 7
          Top = 4
          Width = 79
          Height = 13
          Caption = 'Execute Time:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbExecutedTime: TLabel
          Left = 91
          Top = 4
          Width = 66
          Height = 13
          Caption = '00:00:00:000'
        end
      end
    end
  end
  object PnlAction: TPanel
    Left = 0
    Top = 666
    Width = 1053
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      1053
      41)
    object BtnOk: TButton
      Left = 889
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object BtnCancelar: TButton
      Left = 970
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = BtnCancelarClick
    end
  end
  object PageControlResult: TPageControl
    Left = 0
    Top = 376
    Width = 1053
    Height = 290
    ActivePage = TabSheetTable
    Align = alBottom
    TabOrder = 2
    object TabSheetTable: TTabSheet
      BorderWidth = 5
      Caption = 'RecordSet'
      object DBGridRecord: TDBGrid
        Left = 0
        Top = 0
        Width = 1035
        Height = 252
        Align = alClient
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
end
