object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'BananaSplit86'
  ClientHeight = 408
  ClientWidth = 594
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 260
    Width = 75
    Height = 13
    Caption = 'FFmpeg Output'
  end
  object Label2: TLabel
    Left = 15
    Top = 146
    Width = 76
    Height = 13
    Caption = 'BananaSplit Log'
  end
  object Label3: TLabel
    Left = 16
    Top = 13
    Width = 86
    Height = 13
    Caption = 'Frame -2 Seconds'
  end
  object Label4: TLabel
    Left = 445
    Top = 13
    Width = 90
    Height = 13
    Caption = 'Frame +2 Seconds'
  end
  object Label5: TLabel
    Left = 159
    Top = 13
    Width = 79
    Height = 13
    Caption = 'Detected Breaks'
  end
  object Label6: TLabel
    Left = 288
    Top = 13
    Width = 111
    Height = 13
    Caption = 'Selected Clip Segments'
  end
  object Panel1: TPanel
    Left = 16
    Top = 32
    Width = 137
    Height = 105
    BorderStyle = bsSingle
    Caption = 'Thumbnail'
    TabOrder = 4
    object Thumb1: TImage
      Left = 40
      Top = 24
      Width = 49
      Height = 57
      Stretch = True
    end
  end
  object ffmpegLog: TMemo
    Left = 16
    Top = 279
    Width = 566
    Height = 89
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object OpenBtn: TButton
    Left = 345
    Top = 374
    Width = 75
    Height = 25
    Caption = 'Open Video'
    TabOrder = 1
    OnClick = OpenBtnClick
  end
  object BananaSplitLog: TMemo
    Left = 16
    Top = 165
    Width = 566
    Height = 89
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object AddJobBtn: TButton
    Left = 426
    Top = 374
    Width = 75
    Height = 25
    Caption = 'Add to Jobs'
    TabOrder = 3
    OnClick = AddJobBtnClick
  end
  object Panel2: TPanel
    Left = 445
    Top = 32
    Width = 137
    Height = 105
    BorderStyle = bsSingle
    Caption = 'Thumbnail'
    TabOrder = 5
    object Thumb2: TImage
      Left = 40
      Top = 24
      Width = 49
      Height = 57
      Stretch = True
    end
  end
  object BlackSegList: TCheckListBox
    Left = 159
    Top = 32
    Width = 123
    Height = 105
    OnClickCheck = BlackSegListClickCheck
    ItemHeight = 13
    TabOrder = 6
    OnClick = BlackSegListClick
  end
  object CutList: TMemo
    Left = 288
    Top = 32
    Width = 151
    Height = 105
    ReadOnly = True
    TabOrder = 7
    WordWrap = False
  end
  object JobListBtn: TButton
    Left = 507
    Top = 374
    Width = 75
    Height = 25
    Caption = 'Job List'
    TabOrder = 8
    OnClick = JobListBtnClick
  end
  object StopBtn: TButton
    Left = 16
    Top = 375
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 9
    OnClick = StopBtnClick
  end
  object DosCommand1: TDosCommand
    InputToOutput = False
    MaxTimeAfterBeginning = 0
    MaxTimeAfterLastOutput = 5
    OnNewLine = DosCommand1NewLine
    OnTerminated = DosCommand1Terminated
    Left = 216
    Top = 368
  end
  object KillTimer: TTimer
    Enabled = False
    Interval = 250
    OnTimer = KillTimerTimer
    Left = 264
    Top = 368
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Videos|*.avi;*.mkv;*.mp4'
    Left = 168
    Top = 368
  end
  object JvFormMagnet1: TJvFormMagnet
    Active = True
    ScreenMagnet = False
    Area = 10
    MainFormMagnet = True
    FormMagnet = True
    Left = 128
    Top = 368
  end
end
