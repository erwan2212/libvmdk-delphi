object Form1: TForm1
  Left = 465
  Top = 155
  Width = 504
  Height = 129
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'VMDK to RAW Converter 0.1 by erwan2212@gmail.com'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 496
    Height = 98
    Align = alClient
    TabOrder = 0
    object Button1: TButton
      Left = 328
      Top = 32
      Width = 73
      Height = 25
      Caption = 'size'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 408
      Top = 32
      Width = 75
      Height = 25
      Caption = 'Convert'
      TabOrder = 1
      OnClick = Button2Click
    end
    object pb_img: TProgressBar
      Left = 8
      Top = 32
      Width = 313
      Height = 25
      TabOrder = 2
    end
    object StatusBar1: TStatusBar
      Left = 2
      Top = 77
      Width = 492
      Height = 19
      Panels = <>
      SimplePanel = True
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 88
    Top = 8
  end
end
