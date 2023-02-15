unit ZDbcRESTDWStatement;

interface

{$I ZDbc.inc}

{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit
uses
  Classes, {$IFDEF MSEgui}mclasses,{$ENDIF} SysUtils,
  ZDbcStatement, ZDbcIntfs, ZDbcRESTDW, FmtBcd, ZCompatibility;

type
  TZAbstractRESTDWPreparedStatement = class(TZRawPreparedStatement)
  public
    constructor Create(const Connection: IZRESTDWConnection;
      const SQL: string; const Info: TStrings);
  end;

  TZRESTDWPreparedStatement = class(TZAbstractRESTDWPreparedStatement, IZPreparedStatement)
  public
    procedure SetNull(ParameterIndex: Integer; {%H-}SQLType: TZSQLType);
    procedure SetBoolean(ParameterIndex: Integer; Value: Boolean);
    procedure SetByte(ParameterIndex: Integer; Value: Byte);
    procedure SetShort(ParameterIndex: Integer; Value: ShortInt);
    procedure SetWord(ParameterIndex: Integer; Value: Word);
    procedure SetSmall(ParameterIndex: Integer; Value: SmallInt);
    procedure SetUInt(ParameterIndex: Integer; Value: Cardinal);
    procedure SetInt(ParameterIndex: Integer; Value: Integer);
    procedure SetULong(ParameterIndex: Integer; const Value: UInt64);
    procedure SetLong(ParameterIndex: Integer; const Value: Int64);
    procedure SetFloat(ParameterIndex: Integer; Value: Single);
    procedure SetDouble(ParameterIndex: Integer; const Value: Double);
    procedure SetCurrency(ParameterIndex: Integer; const Value: Currency); reintroduce;
    procedure SetBigDecimal(ParameterIndex: Integer;
                            {$IFDEF FPC_HAS_CONSTREF}
                            constref
                            {$ELSE}
                            const
                            {$ENDIF} Value: TBCD); reintroduce;
    procedure SetDate(Index: Integer;
                      {$IFDEF FPC_HAS_CONSTREF}
                      constref
                      {$ELSE}
                      const
                      {$ENDIF} Value: TZDate); reintroduce; overload;
    procedure SetTime(Index: Integer;
                      {$IFDEF FPC_HAS_CONSTREF}
                      constref
                      {$ELSE}
                      const
                      {$ENDIF} Value: TZTime); reintroduce; overload;
    procedure SetTimestamp(Index: Integer;
                           {$IFDEF FPC_HAS_CONSTREF}
                           constref
                           {$ELSE}
                           const
                           {$ENDIF} Value: TZTimeStamp); reintroduce; overload;
    procedure SetBytes(Index: Integer; Value: PByte; Len: NativeUInt); reintroduce; overload;
  end;

  TZRESTDWStatement = class(TZAbstractRESTDWPreparedStatement, IZStatement)
  public
    constructor Create(const Connection: IZRESTDWConnection;
      const Info: TStrings);
  end;


{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit
implementation
{$IFNDEF ZEOS_DISABLE_RDW} //if set we have an empty unit

{ TZRESTStatement }

constructor TZRESTDWStatement.Create(const Connection: IZRESTDWConnection;
  const Info: TStrings);
begin
  inherited Create(Connection, '', Info);
end;

{ TZAbstractRESTPreparedStatement }

constructor TZAbstractRESTDWPreparedStatement.Create(
  const Connection: IZRESTDWConnection; const SQL: string;
  const Info: TStrings);
begin
  inherited Create(Connection, SQL, Info);
end;

{ TZRESTDWPreparedStatement }

procedure TZRESTDWPreparedStatement.SetBigDecimal(ParameterIndex: Integer;
  const Value: TBCD);
begin

end;

procedure TZRESTDWPreparedStatement.SetBoolean(ParameterIndex: Integer;
  Value: Boolean);
begin

end;

procedure TZRESTDWPreparedStatement.SetByte(ParameterIndex: Integer;
  Value: Byte);
begin

end;

procedure TZRESTDWPreparedStatement.SetBytes(Index: Integer; Value: PByte;
  Len: NativeUInt);
begin

end;

procedure TZRESTDWPreparedStatement.SetCurrency(ParameterIndex: Integer;
  const Value: Currency);
begin

end;

procedure TZRESTDWPreparedStatement.SetDate(Index: Integer;
  const Value: TZDate);
begin

end;

procedure TZRESTDWPreparedStatement.SetDouble(ParameterIndex: Integer;
  const Value: Double);
begin

end;

procedure TZRESTDWPreparedStatement.SetFloat(ParameterIndex: Integer;
  Value: Single);
begin

end;

procedure TZRESTDWPreparedStatement.SetInt(ParameterIndex, Value: Integer);
begin

end;

procedure TZRESTDWPreparedStatement.SetLong(ParameterIndex: Integer;
  const Value: Int64);
begin

end;

procedure TZRESTDWPreparedStatement.SetNull(ParameterIndex: Integer;
  SQLType: TZSQLType);
begin

end;

procedure TZRESTDWPreparedStatement.SetShort(ParameterIndex: Integer;
  Value: ShortInt);
begin

end;

procedure TZRESTDWPreparedStatement.SetSmall(ParameterIndex: Integer;
  Value: SmallInt);
begin

end;

procedure TZRESTDWPreparedStatement.SetTime(Index: Integer;
  const Value: TZTime);
begin

end;

procedure TZRESTDWPreparedStatement.SetTimestamp(Index: Integer;
  const Value: TZTimeStamp);
begin

end;

procedure TZRESTDWPreparedStatement.SetUInt(ParameterIndex: Integer;
  Value: Cardinal);
begin

end;

procedure TZRESTDWPreparedStatement.SetULong(ParameterIndex: Integer;
  const Value: UInt64);
begin

end;

procedure TZRESTDWPreparedStatement.SetWord(ParameterIndex: Integer;
  Value: Word);
begin

end;

{$ENDIF ZEOS_DISABLE_RDW} //if set we have an empty unit

end.

