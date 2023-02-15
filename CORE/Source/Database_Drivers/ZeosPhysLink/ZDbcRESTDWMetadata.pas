unit ZDbcRESTDWMetadata;

interface

{$I ZDbc.inc}

{$IFNDEF ZEOS_DISABLE_RESTDW} //if set we have an empty unit
uses
  Types, Classes, SysUtils, ZSysUtils, ZDbcIntfs, ZDbcMetadata,
  ZCompatibility
  //, ZDbcRESTDWUtils
  ;

type
  TZRESTDWDatabaseInfo = class(TZAbstractDatabaseInfo)
  public
    function GetDatabaseProductName: string; override;
    function GetDriverName: string; override;
    function GetDriverMajorVersion: Integer; override;
    function GetDriverMinorVersion: Integer; override;
    function SupportsMixedCaseIdentifiers: Boolean; override;
    function SupportsMixedCaseQuotedIdentifiers: Boolean; override;
    function SupportsExpressionsInOrderBy: Boolean; override;
    function SupportsOrderByUnrelated: Boolean; override;
    function SupportsGroupBy: Boolean; override;
    function SupportsGroupByUnrelated: Boolean; override;
    function SupportsGroupByBeyondSelect: Boolean; override;
    function SupportsIntegrityEnhancementFacility: Boolean; override;
    function SupportsSchemasInDataManipulation: Boolean; override;
    function SupportsSchemasInProcedureCalls: Boolean; override;
    function SupportsSchemasInTableDefinitions: Boolean; override;
    function SupportsSchemasInIndexDefinitions: Boolean; override;
    function SupportsSchemasInPrivilegeDefinitions: Boolean; override;
    function SupportsCatalogsInDataManipulation: Boolean; override;
    function SupportsCatalogsInProcedureCalls: Boolean; override;
    function SupportsCatalogsInTableDefinitions: Boolean; override;
    function SupportsCatalogsInIndexDefinitions: Boolean; override;
    function SupportsCatalogsInPrivilegeDefinitions: Boolean; override;
    function SupportsPositionedDelete: Boolean; override;
    function SupportsPositionedUpdate: Boolean; override;
    function SupportsSelectForUpdate: Boolean; override;
    function SupportsStoredProcedures: Boolean; override;
    function SupportsSubqueriesInComparisons: Boolean; override;
    function SupportsSubqueriesInExists: Boolean; override;
    function SupportsSubqueriesInIns: Boolean; override;
    function SupportsSubqueriesInQuantifieds: Boolean; override;
    function SupportsCorrelatedSubqueries: Boolean; override;
    function SupportsUnion: Boolean; override;
    function SupportsUnionAll: Boolean; override;
    function SupportsOpenCursorsAcrossCommit: Boolean; override;
    function SupportsOpenCursorsAcrossRollback: Boolean; override;
    function SupportsOpenStatementsAcrossCommit: Boolean; override;
    function SupportsOpenStatementsAcrossRollback: Boolean; override;
    function SupportsTransactions: Boolean; override;
    function SupportsTransactionIsolationLevel(const {%H-}Level: TZTransactIsolationLevel):
      Boolean; override;
    function SupportsDataDefinitionAndDataManipulationTransactions: Boolean; override;
    function SupportsDataManipulationTransactionsOnly: Boolean; override;
    function SupportsResultSetType(const _Type: TZResultSetType): Boolean; override;
    function SupportsResultSetConcurrency(const _Type: TZResultSetType;
      const Concurrency: TZResultSetConcurrency): Boolean; override;
    function GetMaxBinaryLiteralLength: Integer; override;
    function GetMaxCharLiteralLength: Integer; override;
    function GetMaxColumnNameLength: Integer; override;
    function GetMaxColumnsInGroupBy: Integer; override;
    function GetMaxColumnsInIndex: Integer; override;
    function GetMaxColumnsInOrderBy: Integer; override;
    function GetMaxColumnsInSelect: Integer; override;
    function GetMaxColumnsInTable: Integer; override;
    function GetMaxConnections: Integer; override;
    function GetMaxCursorNameLength: Integer; override;
    function GetMaxIndexLength: Integer; override;
    function GetMaxSchemaNameLength: Integer; override;
    function GetMaxProcedureNameLength: Integer; override;
    function GetMaxCatalogNameLength: Integer; override;
    function GetMaxRowSize: Integer; override;
    function GetMaxStatementLength: Integer; override;
    function GetMaxStatements: Integer; override;
    function GetMaxTableNameLength: Integer; override;
    function GetMaxTablesInSelect: Integer; override;
    function GetMaxUserNameLength: Integer; override;
    function DoesMaxRowSizeIncludeBlobs: Boolean; override;
    function UsesLocalFilePerTable: Boolean; override;
    function StoresUpperCaseIdentifiers: Boolean; override;
    function StoresLowerCaseIdentifiers: Boolean; override;
    function StoresMixedCaseIdentifiers: Boolean; override;
    function StoresUpperCaseQuotedIdentifiers: Boolean; override;
    function StoresLowerCaseQuotedIdentifiers: Boolean; override;
    function StoresMixedCaseQuotedIdentifiers: Boolean; override;
    function GetDefaultTransactionIsolation: TZTransactIsolationLevel; override;
    function DataDefinitionCausesTransactionCommit: Boolean; override;
    function DataDefinitionIgnoredInTransactions: Boolean; override;
    function GetSchemaTerm: string; override;
    function GetProcedureTerm: string; override;
    function GetCatalogTerm: string; override;
    function GetCatalogSeparator: string; override;
    function GetSQLKeywords: string; override;
    function GetNumericFunctions: string; override;
    function GetStringFunctions: string; override;
    function GetSystemFunctions: string; override;
    function GetTimeDateFunctions: string; override;
    function GetSearchStringEscape: string; override;
    function GetExtraNameCharacters: string; override;
  end;

  {** Implements RESTDW Database Metadata. }
  TZRESTDWDatabaseMetadata = class(TZAbstractDatabaseMetadata)
  protected
    function CreateDatabaseInfo: IZDatabaseInfo; override; // technobot 2008-06-28
    function UncachedGetTables(const Catalog: string; const {%H-}SchemaPattern: string;
      const TableNamePattern: string; const Types: TStringDynArray): IZResultSet; override;
    function UncachedGetCatalogs: IZResultSet; override;
    function UncachedGetTableTypes: IZResultSet; override;
    function UncachedGetColumns(const Catalog: string; const SchemaPattern: string;
      const TableNamePattern: string; const ColumnNamePattern: string): IZResultSet; override;
    function UncachedGetPrimaryKeys(const Catalog: string; const Schema: string;
      const Table: string): IZResultSet; override;
    function UncachedGetIndexInfo(const Catalog: string; const Schema: string; const Table: string;
      Unique: Boolean; Approximate: Boolean): IZResultSet; override;
    function UncachedGetTypeInfo: IZResultSet; override;
    function UncachedGetCharacterSets: IZResultSet; override; //EgonHugeist
  end;

{$ENDIF ZEOS_DISABLE_RESTDW} //if set we have an empty unit
implementation
{$IFNDEF ZEOS_DISABLE_RESTDW} //if set we have an empty unit

uses
  ZDbcUtils, ZDbcRESTDW, ZFastCode, ZSelectSchema, ZMatchPattern,
  ZEncoding, ZDbcCachedResultSet;

{ TZRESTDWDatabaseInfo }

function TZRESTDWDatabaseInfo.GetDatabaseProductName: string;
begin
  Result := 'restdw';
end;

function TZRESTDWDatabaseInfo.GetDriverName: string;
begin
  Result := 'Zeos Database Connectivity Driver for RESTDW';
end;

function TZRESTDWDatabaseInfo.GetDriverMajorVersion: Integer;
begin
  Result := 1;
end;

function TZRESTDWDatabaseInfo.GetDriverMinorVersion: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.UsesLocalFilePerTable: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsMixedCaseIdentifiers: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.StoresUpperCaseIdentifiers: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.StoresLowerCaseIdentifiers: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.StoresMixedCaseIdentifiers: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsMixedCaseQuotedIdentifiers: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.StoresUpperCaseQuotedIdentifiers: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.StoresLowerCaseQuotedIdentifiers: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.StoresMixedCaseQuotedIdentifiers: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.GetSQLKeywords: string;
begin
  Result := 'ALL,AND,BETWEEN,CASE,CHECK,COLLATE,COMMIT,CONSTRAINT,'
    + 'DEFAULT,DEFERRABLE,DISTINCT,ELSE,EXCEPT,FOREIGN,GLOB,'
    + 'IN,INTERSECT,ISNULL,LIMIT,'
    + 'NOT,NOTNULL,REFERENCES,ROLLBACK,'
    + 'THEN,TRANSACTION,UNION,UNIQUE,USING,WHEN,'
    + 'ABORT,AFTER,ASC,ATTACH,BEFORE,BEGIN,DEFERRED,CASCADE,CLUSTER,CONFLICT,'
    + 'COPY,CROSS,DATABASE,DELIMITERS,DESC,DETACH,EACH,END,EXPLAIN,FAIL,'
    + 'FULL,IGNORE,IMMEDIATE,INITIALLY,INNER,INSTEAD,LEFT,MATCH,NATURAL,'
    + 'OF,OFFSET,OUTER,PRAGMA,RAISE,REPLACE,RESTRICT,RIGHT,ROW,STATEMENT,'
    + 'TEMP,TEMPORARY,TRIGGER,VACUUM,VIEW';
end;

function TZRESTDWDatabaseInfo.GetNumericFunctions: string;
begin
  Result := 'ABS,MAX,MIN,RANDOM,ROUND';
end;

function TZRESTDWDatabaseInfo.GetStringFunctions: string;
begin
  Result := 'LENGTH,LIKE,LOWER,SOUNDEX,SUBSTRING,UPPER';
end;

function TZRESTDWDatabaseInfo.GetSystemFunctions: string;
begin
  Result := 'LAST_INSERT_ROWID,RESTDW_VERSION,TYPEOF';
end;

function TZRESTDWDatabaseInfo.GetTimeDateFunctions: string;
begin
  Result := '';
end;

function TZRESTDWDatabaseInfo.GetSearchStringEscape: string;
begin
  Result := '/';
end;

function TZRESTDWDatabaseInfo.GetExtraNameCharacters: string;
begin
  Result := '';
end;

function TZRESTDWDatabaseInfo.SupportsExpressionsInOrderBy: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsOrderByUnrelated: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsGroupBy: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsGroupByUnrelated: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsGroupByBeyondSelect: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsIntegrityEnhancementFacility: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.GetSchemaTerm: string;
begin
  Result := '';
end;

function TZRESTDWDatabaseInfo.GetProcedureTerm: string;
begin
  Result := '';
end;

function TZRESTDWDatabaseInfo.GetCatalogTerm: string;
begin
  Result := 'database';
end;

function TZRESTDWDatabaseInfo.GetCatalogSeparator: string;
begin
  Result := '.';
end;

function TZRESTDWDatabaseInfo.SupportsSchemasInDataManipulation: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsSchemasInProcedureCalls: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsSchemasInTableDefinitions: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsSchemasInIndexDefinitions: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsSchemasInPrivilegeDefinitions: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsCatalogsInDataManipulation: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsCatalogsInProcedureCalls: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsCatalogsInTableDefinitions: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsCatalogsInIndexDefinitions: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsCatalogsInPrivilegeDefinitions: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsPositionedDelete: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsPositionedUpdate: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsSelectForUpdate: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsStoredProcedures: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsSubqueriesInComparisons: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsSubqueriesInExists: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsSubqueriesInIns: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsSubqueriesInQuantifieds: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsCorrelatedSubqueries: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsUnion: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsUnionAll: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsOpenCursorsAcrossCommit: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.SupportsOpenCursorsAcrossRollback: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsOpenStatementsAcrossCommit: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsOpenStatementsAcrossRollback: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.GetMaxBinaryLiteralLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxCharLiteralLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxColumnNameLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxColumnsInGroupBy: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxColumnsInIndex: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxColumnsInOrderBy: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxColumnsInSelect: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxColumnsInTable: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxConnections: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxCursorNameLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxIndexLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxSchemaNameLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxProcedureNameLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxCatalogNameLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxRowSize: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.DoesMaxRowSizeIncludeBlobs: Boolean;
begin
  Result := True;
end;

function TZRESTDWDatabaseInfo.GetMaxStatementLength: Integer;
begin
  Result := 65535;
end;

function TZRESTDWDatabaseInfo.GetMaxStatements: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxTableNameLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxTablesInSelect: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetMaxUserNameLength: Integer;
begin
  Result := 0;
end;

function TZRESTDWDatabaseInfo.GetDefaultTransactionIsolation:
  TZTransactIsolationLevel;
begin
  Result := tiNone;
end;

function TZRESTDWDatabaseInfo.SupportsTransactions: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsTransactionIsolationLevel(
  const Level: TZTransactIsolationLevel): Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.
  SupportsDataDefinitionAndDataManipulationTransactions: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.
  SupportsDataManipulationTransactionsOnly: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.DataDefinitionCausesTransactionCommit: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.DataDefinitionIgnoredInTransactions: Boolean;
begin
  Result := False;
end;

function TZRESTDWDatabaseInfo.SupportsResultSetType(
  const _Type: TZResultSetType): Boolean;
begin
  Result := _Type = rtForwardOnly;
end;

function TZRESTDWDatabaseInfo.SupportsResultSetConcurrency(
  const _Type: TZResultSetType; const Concurrency: TZResultSetConcurrency): Boolean;
begin
  Result := (_Type = rtForwardOnly) and (Concurrency = rcReadOnly);
end;


{ TZRESTDWDatabaseMetadata }

function TZRESTDWDatabaseMetadata.CreateDatabaseInfo: IZDatabaseInfo;
begin
  Result := TZRESTDWDatabaseInfo.Create(Self);
end;

function TZRESTDWDatabaseMetadata.UncachedGetTables(const Catalog: string;
  const SchemaPattern: string; const TableNamePattern: string;
  const Types: TStringDynArray): IZResultSet;
begin
  Result := inherited UncachedGetTables(Catalog,SchemaPattern,TableNamePattern,Types);
end;

function TZRESTDWDatabaseMetadata.UncachedGetTableTypes: IZResultSet;
begin
  Result:=inherited UncachedGetTableTypes;
end;

function TZRESTDWDatabaseMetadata.UncachedGetColumns(const Catalog: string;
  const SchemaPattern: string; const TableNamePattern: string;
  const ColumnNamePattern: string): IZResultSet;
begin
  Result:=inherited UncachedGetColumns(Catalog, SchemaPattern, TableNamePattern, ColumnNamePattern);
end;

function TZRESTDWDatabaseMetadata.UncachedGetPrimaryKeys(const Catalog: string;
  const Schema: string; const Table: string): IZResultSet;
begin
  Result:=inherited UncachedGetPrimaryKeys(Catalog, Schema, Table);
end;

function TZRESTDWDatabaseMetadata.UncachedGetTypeInfo: IZResultSet;
begin
  Result:=inherited UncachedGetTypeInfo;
end;

function TZRESTDWDatabaseMetadata.UncachedGetIndexInfo(const Catalog: string;
  const Schema: string; const Table: string; Unique: Boolean;
  Approximate: Boolean): IZResultSet;
begin
  Result:=inherited UncachedGetIndexInfo(Catalog, Schema, Table, Unique, Approximate);
end;

function TZRESTDWDatabaseMetadata.UncachedGetCatalogs: IZResultSet;
begin
  Result := inherited UncachedGetCatalogs;
end;

function TZRESTDWDatabaseMetadata.UncachedGetCharacterSets: IZResultSet; //EgonHugeist
begin
  Result:=inherited UncachedGetCharacterSets;
end;

{$ENDIF ZEOS_DISABLE_RESTDW} //if set we have an empty unit
end.

