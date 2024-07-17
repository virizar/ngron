type

  TokenKind* = enum
    LeftBrace, 
    RightBrace, 
    LeftBracket, 
    RightBracket, 
    Comma, 
    Equal,
    Semicolon,
    Dot,
    Colon, 
    String, 
    Number, 
    Boolean, 
    Null,
    Identifier

  Token* = ref object
    kind* : TokenKind
    lexeme* : string

proc newToken*(kind : TokenKind, lexeme : string) : Token = 
  new(result)
  result.kind = kind
  result.lexeme = lexeme

proc `$`*(self : Token) : string = 
  result &= "Token(" 
  result &= $self.kind
  result &= ", '"
  result &= self.lexeme
  result &= "')"
