unit FireDAC.Phys.RESTDWMeta;

{$I ..\Includes\uRESTDWPlataform.inc}

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
 Fernando Banhos            - Drivers e Datasets.
}

interface

uses
  FireDAC.Phys.Meta, FireDAC.Stan.Intf, FireDAC.DatS, Classes, SysUtils,
  FireDAC.Phys.Intf, FireDAC.Phys, uRESTDWBasicDB, FireDAC.Phys.SQLGenerator;

type
  TFDPhysRDWMetadata = class (TFDPhysConnectionMetadata)
  private
    FRDBMS : TFDRDBMSKind;
    FNameDoubleQuote : boolean;
  protected
    function GetNameQuoteChar(AQuote: TFDPhysNameQuoteLevel; ASide: TFDPhysNameQuoteSide): Char; override;
    function GetNameQuotedSupportedParts: TFDPhysNameParts; override;
    function GetNameQuotedCaseSensParts: TFDPhysNameParts; override;
  public
    constructor Create(const AConnectionObj: TFDPhysConnection;
      AServerVersion, AClientVersion: TFDVersion; AIsUnicode: Boolean);
  end;

  TFDPhysRDWCommandGenerator = class(TFDPhysCommandGenerator)

  end;

implementation

uses
  FireDAC.Phys.RESTDWBase;

{ TFDPhysRDWMetadata }

constructor TFDPhysRDWMetadata.Create(const AConnectionObj: TFDPhysConnection;
  AServerVersion, AClientVersion: TFDVersion; AIsUnicode: Boolean);
var
  driverLink : TFDPhysRDWBaseDriverLink;
begin
  FRDBMS := TFDRDBMSKinds.Other;
  if FConnectionObj <> nil then begin
    driverLink := TFDPhysRDWConnectionBase(FConnectionObj).findRESTDWLink;
    if driverLink <> nil then
      FRDBMS := driverLink.RDBMS;
  end;

  FNameDoubleQuote := False;
  inherited Create(AConnectionObj,AServerVersion,AClientVersion,AIsUnicode);
end;

function TFDPhysRDWMetadata.GetNameQuoteChar(AQuote: TFDPhysNameQuoteLevel;
  ASide: TFDPhysNameQuoteSide): Char;
begin
  Result := #0;

  if FRDBMS = TFDRDBMSKinds.MySQL then begin
    Result := #0;
    case AQuote of
      ncDefault:
        Result := '`';
      ncSecond:
        if FNameDoubleQuote then
          Result := '"';
    end;
  end
  else if FRDBMS = TFDRDBMSKinds.MSSQL then begin
    Result := #0;
    case AQuote of
    ncDefault:
      if ASide = nsLeft then
        Result := '['
      else
        Result := ']';
    ncSecond:
      if FNameDoubleQuote then
        Result := '"';
    end;
  end
  else if (FRDBMS = TFDRDBMSKinds.Firebird) or (FRDBMS = TFDRDBMSKinds.Interbase) then begin
//    if (FDialect >= 3) and (AQuote = ncDefault) then
//      Result := '"'
//    else
//      Result := #0;

    inherited; //todo firebird/ interbase
  end
  else if FRDBMS = TFDRDBMSKinds.SQLite then begin
    Result := ' ';
    case AQuote of
    ncDefault:
      Result := '"';
    ncSecond:
      if ASide = nsLeft then
        Result := '['
      else
        Result := ']';
    ncThird:
      Result := '`';
    end;
  end
  else if FRDBMS = TFDRDBMSKinds.Oracle then begin
    // oracle nao tem essa funcao declarada em seus metodos
    // verificado na unit FireDAC.Phys.OracleMeta
    inherited;
  end
  else if FRDBMS = TFDRDBMSKinds.PostgreSQL then begin
    // postgres nao tem essa funcao declarada em seus metodos
    // verificado na unit FireDAC.Phys.PGMeta
    inherited;
  end
  else begin
    inherited;
  end;
end;

function TFDPhysRDWMetadata.GetNameQuotedCaseSensParts: TFDPhysNameParts;
begin
  Result := [];
end;

function TFDPhysRDWMetadata.GetNameQuotedSupportedParts: TFDPhysNameParts;
begin
  Result := [];
end;

end.
