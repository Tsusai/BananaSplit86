object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Job List'
  ClientHeight = 408
  ClientWidth = 698
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
    ItemHeight = 13
    ScrollWidth = 1
    TabOrder = 0
    OnKeyDown = JobListKeyDown
  end
  object BatchBtn: TButton
    Left = 592
    Top = 375
    Width = 98
    Height = 25
    Caption = 'Make Batch File'
    TabOrder = 1
    OnClick = BatchBtnClick
  end
  object JvFormMagnet1: TJvFormMagnet
    Active = True
    ScreenMagnet = False
    Area = 10
    FormMagnet = True
    Left = 32
    Top = 376
  end
end
