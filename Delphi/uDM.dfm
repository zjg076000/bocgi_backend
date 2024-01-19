object DM: TDM
  Height = 480
  Width = 640
  PixelsPerInch = 96
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=E:\02.Delphi'#24320#21457#36164#26009'\01.delphi\02.DEMo\01.SemanaHashload-ma' +
        'in\SemanaHashload-main\Back-end\database\DB_AGENDA.db'
      'OpenMode=CreateUTF16'
      'StringFormat=Unicode'
      'DriverID=SQLite')
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvKeepConnection]
    ConnectedStoredUsage = []
    LoginPrompt = False
    Left = 64
    Top = 48
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    VendorLib = '.\sqlite3.dll'
    Left = 232
    Top = 160
  end
end
