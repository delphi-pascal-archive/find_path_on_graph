object FormEnter: TFormEnter
  Left = 398
  Top = 191
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #1042#1077#1089' '#1088#1077#1073#1088#1072
  ClientHeight = 72
  ClientWidth = 204
  Color = clTeal
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object bOK: TButton
    Left = 8
    Top = 40
    Width = 89
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = bOKClick
  end
  object bDel: TButton
    Left = 104
    Top = 40
    Width = 89
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 1
    OnClick = bDelClick
  end
  object MEweight: TMaskEdit
    Left = 8
    Top = 8
    Width = 185
    Height = 21
    Color = clMoneyGreen
    MaxLength = 4
    TabOrder = 2
    OnKeyDown = MEweightKeyDown
  end
end
