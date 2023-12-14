import std/strformat
import std/strutils
import std/enumerate
import std/algorithm
include styles

type
  JsonParser* = ref object 
    current : int 
    silent : bool = false
    colorize : bool = false
    sort : bool = false
    data: string
    jsonObject : JsonObject
    
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
    case kind*: JsonObjectKind  
    of Array:
      items*: seq[JsonObject]
    of Object:
      itemPairs*: seq[tuple[key: JsonObject, value: JsonObject]]
    else:
      discard

proc newJsonParser*() : JsonParser =
  new(result)
  result.data = ""
  result.current = 0

# forward declarations
proc parseValue(self : JsonParser) : JsonObject 

proc isAlphaExt(character : char) : bool =

  isAlphaNumeric(character) or character == '_'

proc sortKeys(self : JsonObject, data : string, ascending  : bool = true) =
  case self.kind:
  of Object:
    self.itemPairs.sort do (x,y : tuple[key: JsonObject, value: JsonObject]) -> int:
      result = cmp(data[x.key.startP..<x.key.endP], data[y.key.startP..<y.key.endP])
    for obj in self.itemPairs:
      obj.value.sortKeys(data, ascending)
  of Array:
    for obj in self.items:
      obj.sortKeys(data, ascending)
  else:
    discard

proc dumpJson(self : JsonObject, data : string, level : int = 0, indent : int = 2,  colorize : bool = false) =

  case self.kind:
  of String:
    if colorize : stdout.write(STRING_COLOR)
    stdout.write("\"")
    stdout.write(data[self.startP..<self.endP])
    stdout.write("\"")
    if colorize: stdout.write(COLOR_END)
    stdout.flushFile()
  of Boolean, Null:
    if colorize : stdout.write(BOOLEAN_NULL_COLOR)
    stdout.write(data[self.startP..<self.endP])
    if colorize: stdout.write(COLOR_END)
    stdout.flushFile()
  of Number:
    if colorize : stdout.write(NUMBER_COLOR)
    stdout.write(data[self.startP..<self.endP])
    if colorize: stdout.write(COLOR_END)
    stdout.flushFile()  
  of Object:
    if colorize:
      stdout.write(STYLED_LEFT_CURLY_BRACE)
      stdout.write("\n")
    else:
      stdout.write("{\n")
    for i, obj in enumerate(self.itemPairs):
      let rawKey = data[obj.key.startP..<obj.key.endP]
      stdout.write(' '.repeat(level + indent))
      if colorize:
        stdout.write(KEY_COLOR)
        stdout.write("\"")
        stdout.write(rawKey)
        stdout.write("\"")
        stdout.write(COLOR_END)
      else:
        stdout.write("\"")
        stdout.write(rawKey)
        stdout.write("\"")
      stdout.write(": ")
      obj.value.dumpJson(data = data, level = level + indent,  colorize = colorize)
      if i != self.itemPairs.len - 1:
        stdout.writeLine(",")
      else:
        stdout.write("\n")
    stdout.write(' '.repeat(level))
    if colorize:
      stdout.write(STYLED_RIGHT_CURLY_BRACE)
    else:
      stdout.write("}")
    stdout.flushFile() 
  of Array:
    if colorize:
      stdout.write(STYLED_LEFT_BRACKET)
      stdout.write("\n")
    else:
      stdout.write("[\n")
    for i, obj in enumerate(self.items):
      stdout.write(' '.repeat(level + indent))
      obj.dumpJson(data = data, level = level + indent,  colorize = colorize)
      if i != self.items.len - 1:
        stdout.writeLine(",")
      else:
        stdout.write("\n")
    stdout.write(' '.repeat(level))
    if colorize:
      stdout.write(STYLED_RIGHT_BRACKET)
    else:
      stdout.write("]")
    stdout.flushFile() 
proc dumpGron(self : JsonObject, data : string,  path : string = "", colorize : bool = false) =
  
  case self.kind:
  of String:
    stdout.write(path)
    stdout.write(" = ")
    if colorize : stdout.write(STRING_COLOR)
    stdout.write("\"")
    stdout.write(data[self.startP..<self.endP])
    stdout.write("\"")
    if colorize: stdout.write(COLOR_END)
    stdout.writeLine(";")
    stdout.flushFile()
  of Boolean, Null:
    stdout.write(path)
    stdout.write(" = ")
    if colorize : stdout.write(BOOLEAN_NULL_COLOR)
    stdout.write(data[self.startP..<self.endP])
    if colorize: stdout.write(COLOR_END)
    stdout.writeLine(";")
    stdout.flushFile()
  of Number:
    stdout.write(path)
    stdout.write(" = ")
    if colorize : stdout.write(NUMBER_COLOR)
    stdout.write(data[self.startP..<self.endP])
    if colorize: stdout.write(COLOR_END)
    stdout.writeLine(";")
    stdout.flushFile()  
  of Object:
    for obj in self.itemPairs:
      var pathAppend = "."
      let rawKey = data[obj.key.startP..<obj.key.endP]
      if colorize : 
        pathAppend &= KEY_COLOR
        pathAppend &= rawKey
        pathAppend &= COLOR_END
      else:
        pathAppend &= rawKey

      for character in rawKey:
        if not isAlphaExt(character):
          if colorize : 
            pathAppend = STYLED_LEFT_BRACKET
            pathAppend &= STRING_COLOR
            pathAppend &= "\""
            pathAppend &= rawKey
            pathAppend &= "\""
            pathAppend &= COLOR_END
            pathAppend &= STYLED_RIGHT_BRACKET
          else:
            pathAppend = "[\""
            pathAppend &= rawKey
            pathAppend &= "\"]"

          break
      var currentPath = path & pathAppend
      obj.value.dumpGron(data = data, path = currentPath, colorize = colorize)
  of Array:
    var index = 0
    for obj in self.items:
      var currentPath = path
      if colorize:
        currentPath &= STYLED_LEFT_BRACKET
        currentPath &= NUMBER_COLOR
        currentPath &= $index
        currentPath &= COLOR_END
        currentPath &= STYLED_RIGHT_BRACKET
      else:
        currentPath &= "["
        currentPath &= $index
        currentPath &= "]"
      obj.dumpGron(data = data, path = currentPath, colorize = colorize)
      inc(index)

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

  var itemPairs = newSeq[(JsonObject, JsonObject)]()
  
  while not self.isAtEnd():

    self.consumeWhitespace()
    
    discard self.consume('\"', "Expected string as key for object")

    let key =  self.parseString()
    
    self.consumeWhitespace()

    discard self.consume(':', "Expected ':' after object key")

    let item = self.parseValue()

    itemPairs.add((key, item))

    self.consumeWhitespace()

    if self.peek() != ',':
      break
    discard self.advance()

  self.consumeWhitespace()

  discard self.consume('}', "Expected ] at the end of an array ")

  if self.sort:
    itemPairs.sort do (x,y : tuple[key: JsonObject, value: JsonObject]) -> int:
      result = cmp(self.data[x.key.startP..<x.key.endP], self.data[y.key.startP..<y.key.endP])

  JsonObject(kind : Object, startP : startP, endP : self.current - 1, itemPairs : itemPairs)

proc parseArray(self : JsonParser) : JsonObject =

  let startP = self.current 
  var index = 0
  var items = newSeq[JsonObject]()
  
  while not self.isAtEnd():
    
    self.consumeWhitespace()

    let item = self.parseValue()

    items.add(item)

    if self.peek() != ',':
      break
    discard self.advance()
    inc(index)

  while isWhitespace(self.peek()):
    discard self.advance()

  discard self.consume(']', "Expected ] at the end of an array ")

  JsonObject(kind : Array, startP : startP, endP : self.current - 1, items : items)

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

  let jsonObject = self.parseValue()

  jsonObject.dumpGron(data, path = "json", colorize = self.colorize)







