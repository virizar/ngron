import std/strformat
import std/strutils
import token

type
  Tokenizer* = ref object of RootObj
    current : int 
    data: string

  TokenizerException* = ref Exception

proc newTokenizer*(data : string) : Tokenizer = 
  new(result)
  result.current = 0
  result.data = data

proc error(self : Tokenizer, msg : string, span : int = 5) = 
  
  writeLine(stderr, fmt"[TokenizerError]: {msg}")
  writeLine(stderr, fmt"On character {self.current}:".indent(1))
  
  var initPointer = self.current - span
  var endPointer = self.current + span

  if initPointer <= 0:
    initPointer = 0

  if endPointer >= self.data.len:
    endPointer = self.data.len

  writeLine(stderr, fmt"{self.data[initPointer..<endPointer]}".indent(2))

  var guide = '-'.repeat(endPointer-initPointer)
  guide[self.current - initPointer] = '^'

  writeLine(stderr, guide.indent(2))

  var e = new(TokenizerException)
  e.msg  = msg
  raise e

proc isNumber(character : char) : bool =

  character >= '0' and character <= '9'

proc isWhitespace(character : char) : bool =

  character == ' ' or character == '\n' or character == '\t' or character == '\r'

proc isAtEnd(self : Tokenizer) : bool =
  
  self.current >= self.data.len

proc peekPrevious(self : Tokenizer) : char =
  
  if self.current == 0:
    return '\0'
  self.data[self.current - 1]

proc peek(self : Tokenizer) : char =
  
  if self.isAtEnd():
    return '\0'
  self.data[self.current]

proc advance(self : Tokenizer) : char =
  
  if self.isAtEnd():
    return '\0'
  result = self.data[self.current]
  self.current += 1

proc consume(self : Tokenizer, character : char, errorMessage : string) : char =
  
  if self.data[self.current] == character:
    return self.advance()
  self.error(errorMessage)

proc consumeWhitespace(self : Tokenizer) =

  while not self.isAtEnd() and isWhitespace(self.peek()):
    discard self.advance()

proc number(self : Tokenizer) : Token = 

  let startP = self.current - 1

  var isFloat = false

  while true:
    if isNumber(self.peek()):
      discard self.advance()
    elif self.peek() == '.':
      if isFloat:
        self.error("Duplicate decimal point")
      if not isNumber(self.peekPrevious()):
        self.error("Decimal point must be preceded by a number")
      isFloat = true
      discard self.advance()
    elif self.peek() == 'e' or self.peek() == 'E':
      if not isNumber(self.peekPrevious()):
        self.error("Exponential notation must be preceded by a number")
      discard self.advance()
      if self.peek() == '+' or self.peek() == '-':
        discard self.advance()
      if not isNumber(self.peek()):
        self.error("Exponential notation must be followed by a number")
    else:
      break

  return Token(kind : Number, lexeme : self.data[startP..<self.current])

proc identifier(self: Tokenizer ) : Token = 
  
  let startP = self.current - 1
  while self.peek().isAlphaNumeric():
      discard self.advance()
  let lexeme = self.data[startP..<self.current]
  case lexeme:
  of "true", "false":
    return Token(kind : Boolean, lexeme : lexeme)
  of "null":
    return Token(kind : Null, lexeme : lexeme)
  else:
    return Token(kind : Identifier, lexeme : lexeme)
  
proc tokenize*(self : Tokenizer) : seq[Token] =
  var curChar : char
  while not self.isAtEnd():
    curChar = self.advance()
    case curChar:
    of '{':
      result.add(Token(kind : LeftBrace, lexeme : "{"))
    of '}':
      result.add(Token(kind : RightBrace, lexeme : "}"))
    of '[':
      result.add(Token(kind : LeftBracket, lexeme : "["))
    of ']':
      result.add(Token(kind : RightBracket, lexeme : "]"))
    of ',':
      result.add(Token(kind : Comma, lexeme : ","))
    of ':':
      result.add(Token(kind : Colon, lexeme : ":"))
    of '=':
      result.add(Token(kind : Equal, lexeme : "="))
    of ';':
      result.add(Token(kind : Semicolon, lexeme : ";"))
    of '.':
      result.add(Token(kind : Dot, lexeme : "."))
    of '\'', '\"':
      let startP = self.current
      while self.peek() != curChar:
        discard self.advance()
      result.add(Token(kind : String, lexeme : self.data[startP..<self.current]))
      discard self.advance()
    # TODO :  RAise exception for mismatched quote
    else:
    
      if isWhitespace(curChar):
        continue

      if isNumber(curChar) or curChar == '-':
        result.add(self.number())
        continue

      if curChar in ['_', '$'] or curChar.isAlphaAscii():
        result.add(self.identifier())
        continue

      self.error(fmt"Cannot tokenize character '{curChar}'")  




