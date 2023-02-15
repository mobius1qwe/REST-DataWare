unit ZRESTDWAnalyser;

interface

{$I ZParseSql.inc}

{$IFNDEF ZEOS_DISABLE_RESTDW}

uses Classes, ZGenericSqlAnalyser;

type

  {** Implements an RESTDW statements analyser. }
  TZRESTDWStatementAnalyser = class (TZGenericStatementAnalyser)
  public
    constructor Create;
  end;

{$ENDIF ZEOS_DISABLE_RESTDW}

implementation

{$IFNDEF ZEOS_DISABLE_RESTDW}

const
  {** The generic constants.}
  RESTDWSectionNames: array[0..11] of string = (
    'SELECT', 'UPDATE', 'DELETE', 'INSERT', 'FROM',
    'WHERE', 'INTO', 'GROUP*BY', 'HAVING', 'ORDER*BY',
    'OFFSET', 'LIMIT'
  );
  RESTDWSelectOptions: array[0..1] of string = (
    'DISTINCT', 'ALL'
  );
  RESTDWFromJoins: array[0..7] of string = (
    'NATURAL', 'RIGHT', 'LEFT', 'FULL', 'INNER', 'OUTER', 'JOIN', 'CROSS'
  );
  RESTDWFromClauses: array[0..1] of string = (
    'ON', 'USING'
  );

{ TZRESTDWStatementAnalyser }

{**
  Creates the object and assignes the main properties.
}
constructor TZRESTDWStatementAnalyser.Create;
begin
  SectionNames := ArrayToStrings(RESTDWSectionNames);
  SelectOptions := ArrayToStrings(RESTDWSelectOptions);
  FromJoins := ArrayToStrings(RESTDWFromJoins);
  FromClauses := ArrayToStrings(RESTDWFromClauses);
end;

{$ENDIF ZEOS_DISABLE_RESTDW}
end.

