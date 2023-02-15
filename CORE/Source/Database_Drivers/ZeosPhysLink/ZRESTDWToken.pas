unit ZRESTDWToken;

interface

{$I ZParseSql.inc}

{$IFNDEF ZEOS_DISABLE_RDW}
uses
  Classes, {$IFDEF MSEgui}mclasses,{$ENDIF}
  ZTokenizer, ZGenericSqlToken;

type

  {** Implements a RESTDW-specific number state object. }
  TZRESTDWNumberState = TZGenericSQLNoHexNumberState;

  {** Implements a RESTDW-specific quote string state object. }
  TZRESTDWQuoteState = TZGenericSQLBracketQuoteState;

  {**
    This state will either delegate to a comment-handling
    state, or return a token with just a slash in it.
  }
  TZRESTDWCommentState = TZGenericSQLCommentState;

  {** Implements a symbol state object. }
  TZRESTDWSymbolState = class (TZSymbolState)
  public
    constructor Create;
  end;

  {** Implements a word state object. }
  TZRESTDWWordState = class (TZGenericSQLWordState)
  public
    constructor Create;
  end;

  {** Implements a default tokenizer object. }
  TZRESTDWTokenizer = class (TZTokenizer)
  protected
    procedure CreateTokenStates; override;
  end;

{$ENDIF ZEOS_DISABLE_RESTDW}
implementation
{$IFNDEF ZEOS_DISABLE_RESTDW}

{$IFDEF FAST_MOVE}uses ZFastCode;{$ENDIF}

{ TZRESTDWSymbolState }

{**
  Creates this RESTDW-specific symbol state object.
}
constructor TZRESTDWSymbolState.Create;
begin
  inherited Create;
  Add('<=');
  Add('>=');
  Add('<>');
  Add('!=');
  Add('==');
  Add('<<');
  Add('>>');
  Add('||');
end;

{ TZRESTDWWordState }

{**
  Constructs this RESTDW-specific word state object.
}
constructor TZRESTDWWordState.Create;
begin
  SetWordChars(#0, #255, False);
  SetWordChars('a', 'z', True);
  SetWordChars('A', 'Z', True);
  SetWordChars('0', '9', True);
  SetWordChars('_', '_', True);
end;

{ TZRESTDWTokenizer }

{**
  Constructs a tokenizer with a default state table (as
  described in the class comment).
}
procedure TZRESTDWTokenizer.CreateTokenStates;
begin
  WhitespaceState := TZWhitespaceState.Create;

  SymbolState := TZRESTDWSymbolState.Create;
  NumberState := TZRESTDWNumberState.Create;
  QuoteState := TZRESTDWQuoteState.Create;
  WordState := TZRESTDWWordState.Create;
  CommentState := TZRESTDWCommentState.Create;

  SetCharacterState(#0, #32, WhitespaceState);
  SetCharacterState(#33, #191, SymbolState);
  SetCharacterState(#192, High(Char), WordState);

  SetCharacterState('a', 'z', WordState);
  SetCharacterState('A', 'Z', WordState);
  SetCharacterState('_', '_', WordState);

  SetCharacterState('0', '9', NumberState);
  SetCharacterState('.', '.', NumberState);

  SetCharacterState('"', '"', QuoteState);
  SetCharacterState(#39, #39, QuoteState);
  SetCharacterState('[', '[', QuoteState);
  SetCharacterState(']', ']', QuoteState);

  SetCharacterState('/', '/', CommentState);
  SetCharacterState('-', '-', CommentState);
end;

{$ENDIF ZEOS_DISABLE_RESTDW}

end.

