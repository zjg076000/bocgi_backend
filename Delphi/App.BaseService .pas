unit App.BaseService;
interface
uses System.Classes, System.SysUtils, Data.DB, System.JSON,
  FireDAC.Comp.Client, FireDAC.Stan.Param,Vcl.ComCtrls;
type
  TBaseService = class
  private
    class var FInstance: TBaseService;
    class function GetInstance: TBaseService; static;
    function ExistContato(AID: Integer): Boolean;
    function InsertContato(AContato: TJSONObject): string;
    function UpdateContrato(AContato: TJSONObject): string;
  public
    constructor Create;
    function Tipos(sql:string): string;
    function Contatos: string;
    function Save(AID: Integer; AContato: string): string;
    function Delete(AID: Integer): string;
    class property Instance: TBaseService read GetInstance;
  end;
implementation
uses uDM, DataSet.Serialize;
{ TBaseService }

function UnicodeToChinese(inputstr:string):string;
var
i:Integer;
index:Integer;
temp,top,last:string;
begin
   index:=1;
   while index>=0 do
   begin
   index:= inputstr.IndexOf('\u');
 if index<0 then
begin
last:= inputstr;
   Result:= Result+ last;
   Exit;
end;
   top:= Copy(inputstr,1,index); //取出 编码字符前的 非 unic 编码的字符，如数字
   temp:= Copy(inputstr,index+1,6);//取出编码，包括 \u    ,如\u4e3f
   Delete(temp,1,2);
   Delete(inputstr,1,index+6);
  result:= Result+ top+ WideChar( StrToInt('$'+ temp)) ;
   end;
end;



function TBaseService.Contatos: string;
var
  lDM: TDM;
  lQry: TFDQuery;
  lJSON: TJSONObject;
begin
  try
    lDM := TDM.Create(nil);
    try
      lQry := lDM.GetQuery;
      try
        lQry.SQL.Add('SELECT a.id                                     ');
        lQry.SQL.Add('      ,a.nome                                   ');
        lQry.SQL.Add('      ,a.id_tipo                                ');
        lQry.SQL.Add('      ,t.descricao as tipo                      ');
        lQry.SQL.Add('      ,a.contato                                ');
        lQry.SQL.Add('  FROM agenda a                                 ');
        lQry.SQL.Add(' INNER JOIN tipo_contato t ON (a.id_tipo = t.id)');
        lQry.SQL.Add(' ORDER BY a.nome                                ');
        lQry.Open;
        lJSON := TJSONObject.Create;
        try
          Result := lJSON.AddPair('success', True)
                         .AddPair('data', lQry.ToJSONArray())
                         .ToJSON;
        finally
          lJSON.Free;
        end;
      finally
        lQry.Close;
        lQry.Free;
      end;
    finally
      lDM.Free;
    end;
  except
    on E: exception do
    begin
      lJSON := TJSONObject.Create;
      try
        Result := lJSON.AddPair('success', False)
                       .AddPair('message', E.Message)
                       .ToJSON;
      finally
        lJSON.Free;
      end;
    end;
  end;
end;
constructor TBaseService.Create;
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := TCaseNameDefinition.cndLower;
end;
function TBaseService.Delete(AID: Integer): string;
var
  lDM: TDM;
  lQry: TFDQuery;
  lJSON: TJSONObject;
begin
  try
    if not ExistContato(AID) then
      raise Exception.Create('Contato n�o localizado!');
    lDM := TDM.Create(nil);
    try
      lQry := lDM.GetQuery;
      try
        lQry.SQL.Add('DELETE FROM agenda');
        lQry.SQL.Add('WHERE id = :id');
        lQry.ParamByName('id').AsInteger := AID;
        lQry.ExecSQL;
        lJSON := TJSONObject.Create;
        try
          Result := lJSON.AddPair('success', True)
                         .AddPair('message', 'Registro exclu�do com sucesso.')
                         .ToJSON;
        finally
          lJSON.Free;
        end;
      finally
        lQry.Free;
      end;
    finally
      lDM.Free;
    end;
  except
    on E: exception do
    begin
      lJSON := TJSONObject.Create;
      try
        Result := lJSON.AddPair('success', False)
                       .AddPair('message', E.Message)
                       .ToJSON;
      finally
        lJSON.Free;
      end;
    end;
  end;
end;
function TBaseService.ExistContato(AID: Integer): Boolean;
var
  lDM: TDM;
  lQry: TFDQuery;
begin
  try
    lDM := TDM.Create(nil);
    try
      lQry := lDM.GetQuery;
      try
        lQry.SQL.Add('SELECT id      ');
        lQry.SQL.Add('  FROM agenda  ');
        lQry.SQL.Add(' WHERE id = :id');
        lQry.ParamByName('id').AsInteger := AID;
        lQry.Open;
        Result := not lQry.IsEmpty;
      finally
        lQry.Close;
        lQry.Free;
      end;
    finally
      lDM.Free;
    end;
  except
    on E: exception do
      raise Exception.Create(E.Message);
  end;
end;
class function TBaseService.GetInstance: TBaseService;
begin
  if not Assigned(FInstance) then
    FInstance := TBaseService.Create;
  Result := FInstance;
end;
function TBaseService.InsertContato(AContato: TJSONObject): string;
var
  lDM: TDM;
  lQry: TFDQuery;
  lJSON: TJSONObject;
begin
  try
    lDM := TDM.Create(nil);
    try
      lQry := lDM.GetQuery;
      try
        lQry.SQL.Add('INSERT INTO agenda (nome, id_tipo, contato)');
        lQry.SQL.Add('VALUES (:nome, :id_tipo, :contato)');
        lQry.ParamByName('nome').AsString := AContato.GetValue<string>('nome');
        lQry.ParamByName('id_tipo').AsInteger := AContato.GetValue<Integer>('id_tipo');
        lQry.ParamByName('contato').AsString := AContato.GetValue<string>('contato');
        lQry.ExecSQL;
        lJSON := TJSONObject.Create;
        try
          Result := lJSON.AddPair('success', True)
                         .AddPair('message', 'Registro inclu�do com sucesso.')
                         .ToJSON;
        finally
          lJSON.Free;
        end;
      finally
        lQry.Free;
      end;
    finally
      lDM.Free;
    end;
  except
    on E: exception do
      raise Exception.Create(E.Message);
  end;
end;
function TBaseService.Save(AID: Integer; AContato: string): string;
var
  lJSONObject: TJSONObject;
  lJSON: TJSONObject;
begin
  try
    if not AContato.StartsWith('{') and not AContato.EndsWith('}')  then
      raise Exception.Create('JSON Invalid!');
    lJSONObject := TJsonObject.ParseJSONValue(TEncoding.UTF8.GetBytes(AContato), 0) as TJSONObject;
    if (lJSONObject.Count = 0) then
      raise Exception.Create('Dados n�o informado!');
    if lJSONObject.Values['nome'].Null or lJSONObject.GetValue<string>('nome').IsEmpty then
      raise Exception.Create('Nome n�o informado!');
    if (lJSONObject.GetValue<Integer>('id_tipo') = 0) then
      raise Exception.Create('Tipo n�o informado!');
    if lJSONObject.Values['contato'].Null or lJSONObject.GetValue<string>('contato').IsEmpty then
      raise Exception.Create('Contato n�o informado!');
    if (AID > 0) then
    begin
      if not ExistContato(AID) then
        raise Exception.Create('Contato not found!');
      lJSONObject.RemovePair('id');
      lJSONObject.AddPair('id', AID);
      Result := UpdateContrato(lJSONObject);
    end
    else
      Result := InsertContato(lJSONObject);
  except
    on E: exception do
    begin
      lJSON := TJSONObject.Create;
      try
        Result := lJSON.AddPair('success', False)
                       .AddPair('message', E.Message)
                       .ToJSON;
      finally
        lJSON.Free;
      end;
    end;
  end;



end;






function TBaseService.Tipos(sql:string): string;
var
  lDM: TDM;
  lQry: TFDQuery;
  lJSON,lJSON2: TJSONObject;
  str,str2:widestring;
  richedit1:trichedit;
  list:TStringList;
begin
  try
    lDM := TDM.Create(nil);
    try
      lQry := lDM.GetQuery;
      try
        lQry.SQL.clear;
        lQry.SQL.Add(sql);
        lQry.Open;
        lJSON := TJSONObject.Create;
        try
         // lJSON:=TJSONObject.parsejsonvalue(tencoding.utf8.getbytes(jsonstr),0) as tjsonobject;
          Result :=lJSON.AddPair('success', True)
                         .AddPair('data', lQry.ToJSONArray())
                         .ToJSON;

           Result:=UnicodeToChinese(Result);
        finally
          lJSON.Free;
        end;
      finally
        lQry.Close;
        lQry.Free;
      end;
    finally
      lDM.Free;
    end;
  except
    on E: exception do
    begin
      lJSON := TJSONObject.Create;
      try
        Result := lJSON.AddPair('success', False)
                       .AddPair('message', E.Message)
                       .ToJSON;
      finally
        lJSON.Free;
      end;
    end;
  end;
end;
function TBaseService.UpdateContrato(AContato: TJSONObject): string;
var
  lDM: TDM;
  lQry: TFDQuery;
  lJSON: TJSONObject;
begin
  try
    lDM := TDM.Create(nil);
    try
      lQry := lDM.GetQuery;
      try
        lQry.SQL.Add('UPDATE agenda       ');
        lQry.SQL.Add('SET nome = :nome,   ');
        lQry.SQL.Add(' id_tipo = :id_tipo,');
        lQry.SQL.Add(' contato = :contato ');
        lQry.SQL.Add('WHERE id = :id      ');
        lQry.ParamByName('id').AsInteger := AContato.GetValue<Integer>('id');
        lQry.ParamByName('nome').AsString := AContato.GetValue<string>('nome');
        lQry.ParamByName('id_tipo').AsInteger := AContato.GetValue<Integer>('id_tipo');
        lQry.ParamByName('contato').AsString := AContato.GetValue<string>('contato');
        lQry.ExecSQL;
        lJSON := TJSONObject.Create;
        try
          Result := lJSON.AddPair('success', True)
                         .AddPair('message', 'Registro alterado com sucesso.')
                         .ToJSON;
        //  Result:=UnicodeToChinese(Result);
        finally
          lJSON.Free;
        end;
      finally
        lQry.Free;
      end;
    finally
      lDM.Free;
    end;
  except
    on E: exception do
      raise Exception.Create(E.Message);
  end;
end;
initialization
finalization
  TBaseService.FInstance.Free;
end.
