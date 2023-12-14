import std/strformat
import std/strutils
import std/terminal
include styles

type
  JsonParser* = ref object 
    current : int 
    data : string
    path : string
    silent : bool = false
    colorize : bool = false
    sort : bool = false
  
  JsonParserException* = ref Exception

  JsonObjectKind = enum
    String,
    Array,
    Object,
    Number,
    Boolean,
    Null

  JsonObject* = ref object
    startP* : int
    endP*: int
    kind*: JsonObjectKind  

proc newJsonParser*() : JsonParser =
  new(result)
  result.data = ""
  result.path = newStringOfCap(4096)
  result.current = 0

# forward declarations
proc parseValue(self : JsonParser) : JsonObject 

proc emit(self : JsonParser, obj : string) = 

  if self.silent:
    return
  
  if self.colorize : stdout.resetAttributes()
  stdout.write(self.path)
  stdout.write(" = ")
  stdout.writeLine(obj) 
  stdout.flushFile()

proc emit(self : JsonParser, obj : JsonObject) = 

  if self.silent:
    return
  
  stdout.write(self.path)
  stdout.write(" = ")
  
  case obj.kind:
  of Number:
    if self.colorize : stdout.write(NUMBER_COLOR)
    stdout.write(self.data[obj.startP..<obj.endP])
    if self.colorize: stdout.write(COLOR_END)
    stdout.writeLine(";")
    stdout.flushFile()  
  of Boolean, Null:
    if self.colorize : stdout.write(BOOLEAN_NULL_COLOR)
    stdout.write(self.data[obj.startP..<obj.endP])
    if self.colorize: stdout.write(COLOR_END)
    stdout.writeLine(";")
    stdout.flushFile()
  of String:
    if self.colorize : stdout.write(STRING_COLOR)
    stdout.write("\"")
    stdout.write(self.data[obj.startP..<obj.endP])
    stdout.write("\"")
    if self.colorize: stdout.write(COLOR_END)
    stdout.writeLine(";")
    stdout.flushFile()
  else:
    discard

proc error(self : JsonParser, msg : string, span : int = 5) = 
  
  writeLine(stderr, fmt"[JsonParserError]: {msg}")
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

  var e = new(JsonParserException)
  e.msg  = msg
  raise e

proc isNumber(character : char) : bool =

  character >= '0' and character <= '9'

proc isWhitespace(character : char) : bool =

  character == ' ' or character == '\n' or character == '\t' or character == '\r'

proc isAlphaExt(character : char) : bool =

  isAlphaNumeric(character) or character == '_'

proc isAtEnd(self : JsonParser) : bool =
  
  self.current == self.data.len

proc peekPrevious(self : JsonParser) : char =
  
  if self.current == 0:
    return '\0'
  self.data[self.current - 1]

proc peek(self : JsonParser) : char =
  
  if self.isAtEnd():
    return '\0'
  self.data[self.current]

proc peekNext(self : JsonParser) : char =
  
  if self.current == self.data.len-1:
    return '\0'
  self.data[self.current+1]
  
proc advance(self : JsonParser) : char =
  
  if self.isAtEnd():
    return '\0'
  result = self.data[self.current]
  self.current += 1

proc consume(self : JsonParser, character : char, errorMessage : string) : char =
  
  if self.data[self.current] == character:
    return self.advance()
  self.error(errorMessage)

proc consumeWhitespace(self : JsonParser) =

  while not self.isAtEnd() and isWhitespace(self.peek()):
    discard self.advance()
  
proc parseBoolean(self : JsonParser) : JsonObject =

  let startP = self.current - 1 

  if self.peekPrevious() == 't':
    for expected in "rue":
      discard self.consume(expected, fmt"Expected '{expected}' in boolean 'true'")
  
  else:
    for expected in "alse":
      discard self.consume(expected, fmt"Expected '{expected}' in boolean 'false'")

  JsonObject(kind : Boolean, startP : startP, endP : self.current)

proc parseNull(self : JsonParser) : JsonObject =

  let startP = self.current - 1 
  for expected in "ull":
    discard self.consume(expected, fmt"Expected '{expected}' in 'null'")

  JsonObject(kind : Null, startP : startP, endP : self.current)

proc parseNumber(self : JsonParser) : JsonObject =

  let startP = self.current - 1 
  
  while isNumber(self.peek()) or self.peek() == '.':
    discard self.advance()

  JsonObject(kind : Number, startP : startP, endP : self.current)

proc parseString(self : JsonParser) : JsonObject =

  let startP = self.current 
  
  while self.peek() != '\"':
    discard self.advance()

  discard self.consume('\"', "Expected \" at the end of a string ")

  JsonObject(kind : String, startP : startP, endP : self.current-1)

proc parseObject(self : JsonParser) : JsonObject =

  let startP = self.current 
  var oldPath = self.path
  
  while not self.isAtEnd():
    if isWhitespace(self.peek()):
      discard self.advance()
      continue
    
    discard self.consume('\"', "Expected string as key for object")

    let key =  self.parseString()
    var pathAppend = "."
    if self.colorize : 
      pathAppend &= KEY_COLOR
      pathAppend &= self.data[key.startP..<key.endP]
      pathAppend &= COLOR_END
    else:
      pathAppend &= self.data[key.startP..<key.endP]
    for character in self.data[key.startP..<key.endP]:
      if not isAlphaExt(character):
        if self.colorize : 
          pathAppend = STYLED_LEFT_BRACKET
          pathAppend &= STRING_COLOR
          pathAppend &= "\""
          pathAppend &= self.data[key.startP..<key.endP]
          pathAppend &= "\""
          pathAppend &= COLOR_END
          pathAppend &= STYLED_RIGHT_BRACKET
        else:
          pathAppend = "[\""
          pathAppend &= self.data[key.startP..<key.endP]
          pathAppend &= "\"]"

        break
    self.path &= pathAppend
    
    self.consumeWhitespace()

    discard self.consume(':', "Expected ':' after object key")

    let item = self.parseValue()

    if not self.silent:

      case item.kind:
      of Number, Boolean, Null, String:
        self.emit(item)
      else:
        discard
    
    self.consumeWhitespace()

    if self.peek() != ',':
      break
    discard self.advance()
    self.path = oldPath

  self.consumeWhitespace()

  discard self.consume('}', "Expected ] at the end of an array ")

  JsonObject(kind : Object, startP : startP, endP : self.current - 1)

proc parseArray(self : JsonParser) : JsonObject =

  let startP = self.current 
  var index = 0
  var oldPath = self.path
  
  while not self.isAtEnd():
    if isWhitespace(self.peek()):
      discard self.advance()
      continue
    
    if self.colorize:
      self.path &= STYLED_LEFT_BRACKET
      self.path &= NUMBER_COLOR
      self.path &= $index
      self.path &= COLOR_END
      self.path &= STYLED_RIGHT_BRACKET
    else:
      self.path &= "["
      self.path &= $index
      self.path &= "]"

    let item = self.parseValue()
    if not self.silent:
      case item.kind:
      of Number, Boolean, Null, String:
        self.emit(item)
      else:
        discard

    if self.peek() != ',':
      break
    discard self.advance()
    inc(index)
    self.path = oldPath

  while isWhitespace(self.peek()):
    discard self.advance()

  discard self.consume(']', "Expected ] at the end of an array ")

  JsonObject(kind : Array, startP : startP, endP : self.current - 1)

proc parseValue(self : JsonParser) : JsonObject =
  while not self.isAtEnd():
    let curChar = self.advance()
    case curChar:
    of '{':
      return  self.parseObject()
    of '[':
      return self.parseArray()
    of '\'','\"':
      return self.parseString()
    of 'n':
      return self.parseNull()
    of 't','f':
      return self.parseBoolean()
    else:
      
      if isWhitespace(curChar):
        continue

      if isNumber(curChar) or curChar == '-':
        return self.parseNumber()

      self.error(fmt("Cannot parse character '{curChar}'"))  

proc parse*(self : JsonParser, data : string, silent : bool = false, sort : bool = false, colorize : bool = false) =

  self.current = 0
  self.data = data
  self.silent = silent
  self.colorize = colorize
  self.sort = sort

  if self.colorize:
    self.path = KEY_COLOR
    self.path &= "json"
    self.path &= COLOR_END
  else:
    self.path &= "json"
  
  self.consumeWhitespace()  

  let curChar = self.advance()
  case curChar:
  of '{':
      if self.colorize:
        var obj = STYLED_LEFT_CURLY_BRACE
        obj &= STYLED_RIGHT_CURLY_BRACE
        self.emit(obj)
      else:
        self.emit("{}")
      discard  self.parseObject()
  of '[':
      if self.colorize:
        var obj = STYLED_LEFT_BRACKET
        obj &= STYLED_RIGHT_BRACKET
        self.emit(obj)
      else:
        self.emit("[]")
      discard self.parseArray()
  of '\'','\"':
      self.emit(self.parseString())
  of 'n':
      self.emit(self.parseNull())
  of 't','f':
      self.emit(self.parseBoolean())
  else:

    if isNumber(curChar) or curChar == '-':
      self.emit(self.parseNumber())

    self.error(fmt("Cannot parse character '{curChar}'"))  







