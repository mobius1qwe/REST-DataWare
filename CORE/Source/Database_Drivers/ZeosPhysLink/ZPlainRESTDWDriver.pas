unit ZPlainRESTDWDriver;

interface

{$I ZPlain.inc}

{$IFNDEF ZEOS_DISABLE_RDW}

uses
  {$IFDEF MSEgui}mclasses,{$ENDIF}
  {$IFDEF OLDFPC}ZClasses,{$ENDIF}
  SysUtils, Classes,
  ZCompatibility, ZPlainDriver;

type
  TZRESTDWPlainDriver = class (TZAbstractPlainDriver, IZPlainDriver)
  protected
    function Clone: IZPlainDriver; override;
    procedure LoadCodePages; override;
  public
    constructor Create;
    destructor Destroy; override;
    function GetProtocol: string; override;
    function GetDescription: string; override;
  end;

{$ENDIF ZEOS_DISABLE_RDW}

implementation

{$IFNDEF ZEOS_DISABLE_RDW}

uses ZPlainLoader, ZEncoding, ZClasses, ZMessages, ZFastCode, ZSysUtils;

{ TZRDWPlainDriver }

function TZRESTDWPlainDriver.GetProtocol: string;
begin
  Result := 'restdw';
end;

function TZRESTDWPlainDriver.Clone: IZPlainDriver;
begin
  Result := TZRESTDWPlainDriver.Create;
end;

procedure TZRESTDWPlainDriver.LoadCodePages;
begin
  AddCodePage('UTF-8', 1, ceUTF8, zCP_UTF8, '', 4);
end;

constructor TZRESTDWPlainDriver.Create;
begin
  inherited Create;
  LoadCodePages;
end;

destructor TZRESTDWPlainDriver.Destroy;
begin
  inherited;
end;

function TZRESTDWPlainDriver.GetDescription: string;
begin
  Result := 'Native Plain Driver for RestDataware';
end;

{$ENDIF ZEOS_DISABLE_RDW}

end.

