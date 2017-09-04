object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Job List'
  ClientHeight = 408
  ClientWidth = 728
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object JobList: TCheckListBox
    Left = 8
    Top = 8
    Width = 683
    Height = 361
    Columns = 1
    ItemHeight = 13
    ScrollWidth = 1
    TabOrder = 0
    OnKeyDown = JobListKeyDown
  end
  object BatchBtn: TButton
    Left = 593
    Top = 375
    Width = 98
    Height = 25
    Caption = 'Make Batch File'
    TabOrder = 1
    OnClick = BatchBtnClick
  end
  object ClearBtn: TButton
    Left = 8
    Top = 375
    Width = 75
    Height = 25
    Caption = 'Clear Jobs'
    TabOrder = 2
    OnClick = ClearBtnClick
  end
  object DeSelBtn: TButton
    Left = 512
    Top = 375
    Width = 75
    Height = 25
    Caption = 'Deselect All'
    TabOrder = 3
    OnClick = DeSelBtnClick
  end
  object SelectBtn: TButton
    Left = 431
    Top = 375
    Width = 75
    Height = 25
    Caption = 'Select All'
    TabOrder = 4
    OnClick = SelectBtnClick
  end
  object UpBtn: TButton
    Left = 697
    Top = 128
    Width = 24
    Height = 33
    Caption = #8593
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnClick = UpBtnClick
  end
  object DownBtn: TButton
    Left = 697
    Top = 167
    Width = 24
    Height = 34
    Caption = #8595
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = DownBtnClick
  end
  object JvFormMagnet1: TJvFormMagnet
    Active = True
    ScreenMagnet = False
    Area = 10
    FormMagnet = True
    Left = 696
    Top = 8
  end
end
