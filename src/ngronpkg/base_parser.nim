import std/strformat
import std/strutils

type
  BaseParser* = ref object of RootObj
    current : int 
    data: string

  ParserException* = ref Exception

proc error(self : BaseParser, msg : string, span : int = 5) = 
  
  writeLine(stderr, fmt"[ParserError]: {msg}")
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

  var e = new(ParserException)
  e.msg  = msg
  raise e

proc isNumber(character : char) : bool =

  character >= '0' and character <= '9'

proc isWhitespace(character : char) : bool =

  character == ' ' or character == '\n' or character == '\t' or character == '\r'

proc isAtEnd(self : BaseParser) : bool =
  
  self.current >= self.data.len

proc peekPrevious(self : BaseParser) : char =
  
  if self.current == 0:
    return '\0'
  self.data[self.current - 1]

proc peek(self : BaseParser) : char =
  
  if self.isAtEnd():
    return '\0'
  self.data[self.current]

proc advance(self : BaseParser) : char =
  
  if self.isAtEnd():
    return '\0'
  result = self.data[self.current]
  self.current += 1

proc consume(self : BaseParser, character : char, errorMessage : string) : char =
  
  if self.data[self.current] == character:
    return self.advance()
  self.error(errorMessage)

proc consumeWhitespace(self : BaseParser) =

  while not self.isAtEnd() and isWhitespace(self.peek()):
    discard self.advance()
  




