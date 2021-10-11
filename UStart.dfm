object StartForm: TStartForm
  Left = 298
  Top = 213
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Start for random'
  ClientHeight = 209
  ClientWidth = 474
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  ScreenSnap = True
  ShowHint = True
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object pointCB: TComboBox
    Left = 288
    Top = 48
    Width = 177
    Height = 24
    Hint = #1042#1099#1073#1088#1072#1090#1100' '#1084#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086#1077' '#1095#1080#1089#1083#1086' '#1074#1077#1088#1096#1080#1085
    Style = csDropDownList
    ItemHeight = 16
    ItemIndex = 0
    MaxLength = 2
    ParentColor = True
    TabOrder = 0
    Text = 'Default(10)'
    Items.Strings = (
      'Default(10)'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12'
      '13'
      '14'
      '15'
      '16')
  end
  object linkCB: TComboBox
    Left = 288
    Top = 80
    Width = 177
    Height = 24
    Hint = #1042#1099#1073#1088#1072#1090#1100' '#1084#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086#1077' '#1095#1080#1089#1083#1086' '#1089#1074#1103#1079#1077#1081' '#1091' '#1086#1076#1085#1086#1081' '#1074#1077#1088#1096#1080#1085#1099' '#1089' '#1076#1088#1091#1075#1080#1084#1080
    Style = csDropDownList
    ItemHeight = 16
    ItemIndex = 0
    MaxLength = 2
    ParentColor = True
    TabOrder = 1
    Text = 'Default(4)'
    Items.Strings = (
      'Default(4)'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12'
      '13'
      '14'
      '15')
  end
  object ST1: TStaticText
    Left = 8
    Top = 53
    Width = 171
    Height = 20
    Caption = 'Choose quantity for vertices:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object ST2: TStaticText
    Left = 8
    Top = 86
    Width = 209
    Height = 20
    Caption = 'Choose quantity links for one point:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object OkButton: TButton
    Left = 296
    Top = 176
    Width = 97
    Height = 25
    Hint = #1055#1088#1086#1076#1086#1083#1078#1080#1090#1100' '#1088#1072#1073#1086#1090#1091' '#1089' '#1091#1089#1090#1072#1085#1086#1074#1083#1077#1085#1085#1099#1084#1080' '#1085#1072#1089#1090#1088#1086#1081#1082#1072#1084#1080
    Caption = 'OK'
    TabOrder = 4
    OnClick = OkButtonClick
  end
  object ExitButton: TButton
    Left = 88
    Top = 176
    Width = 97
    Height = 25
    Hint = #1042#1099#1093#1086#1076' '#1080#1079' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
    Caption = 'Exit program'
    TabOrder = 5
    OnClick = ExitButtonClick
  end
  object cbRandom: TCheckBox
    Left = 79
    Top = 118
    Width = 129
    Height = 20
    Hint = #1042#1099#1073#1086#1088' '#1084#1077#1090#1086#1076#1072' '#1075#1077#1085#1077#1088#1072#1094#1080#1080
    Caption = 'Random generate'
    Checked = True
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clTeal
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    State = cbChecked
    TabOrder = 6
    OnClick = cbRandomClick
  end
  object CBMemory: TCheckBox
    Left = 246
    Top = 118
    Width = 129
    Height = 20
    Hint = #1050#1086#1085#1090#1088#1086#1083#1100' '#1079#1072' '#1074#1088#1077#1084#1077#1085#1077#1084' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103' '#1086#1087#1077#1088#1072#1094#1080#1081
    Caption = 'Control of memory'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    State = cbChecked
    TabOrder = 7
    OnClick = CBMemoryClick
  end
  object ST3: TStaticText
    Left = 260
    Top = 147
    Width = 170
    Height = 20
    Caption = 'Time for operation (sec)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 8
  end
  object METime: TMaskEdit
    Left = 432
    Top = 144
    Width = 33
    Height = 25
    EditMask = '!999;0;_'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Times New Roman'
    Font.Style = []
    MaxLength = 3
    ParentColor = True
    ParentFont = False
    TabOrder = 9
  end
  object TB: TTrackBar
    Left = 8
    Top = 8
    Width = 465
    Height = 33
    Hint = #1047#1072#1076#1077#1088#1078#1082#1072' '#1087#1088#1080' '#1072#1085#1080#1084#1072#1094#1080#1080
    Max = 50
    Position = 25
    TabOrder = 10
    ThumbLength = 14
    TickMarks = tmBoth
  end
end
