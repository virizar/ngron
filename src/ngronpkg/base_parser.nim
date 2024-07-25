import std/strformat
import std/strutils
import token

type
  BaseParser* = ref object of RootObj
    current*: int
    tokens*: seq[Token]
    data*: string

  ParserException* = ref Exception

proc error*(self: BaseParser, msg: string, span: int = 5) =

  writeLine(stderr, fmt"[ParserError]: {msg}")
  writeLine(stderr, fmt"On character {self.tokens[self.current].start}:".indent(1))

  var initPointer = self.tokens[self.current].start - span
  var endPointer = self.tokens[self.current].start + span

  if initPointer <= 0:
    initPointer = 0

  if endPointer >= self.data.len:
    endPointer = self.data.len

  writeLine(stderr, fmt"{self.data[initPointer..<endPointer]}".indent(2))

  var guide = '-'.repeat(endPointer-initPointer)
  guide[self.tokens[self.current].start - initPointer] = '^'

  writeLine(stderr, guide.indent(2))

  var e = new(ParserException)
  e.msg = msg
  raise e


proc isAtEnd*(self: BaseParser): bool =

  self.tokens[self.current].kind == Eof

proc peekPrevious*(self: BaseParser): Token =

  if self.current == 0:
    return self.tokens[self.current]
  self.tokens[self.current - 1]

proc peek*(self: BaseParser): Token =
  if self.isAtEnd():
    return Token(kind: Eof, lexeme: "")
  self.tokens[self.current]

proc advance*(self: BaseParser): Token =

  if self.isAtEnd():
    return Token(kind: Eof, lexeme: "")
  result = self.tokens[self.current]
  self.current += 1

proc consume*(self: BaseParser, expected: TokenKind,
    errorMessage: string): Token =

  if self.peek().kind == expected:
    return self.advance()
  self.error(errorMessage)

proc match*(self: BaseParser, expected: varargs[TokenKind]): bool =

  for kind in items(expected):
    if self.peek().kind == kind:
      discard self.advance()
      return true
  return false





