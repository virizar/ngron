import std/strformat
import std/strutils
import std/enumerate
import std/algorithm
include json_object

type
  JsonParser* = ref object 
    current : int 
    silent : bool = false
    colorize : bool = false
    sort : bool = false
    data: string
    
  JsonParserException* = ref Exception

# forward declarations
proc parseValue(self : JsonParser) : JsonPointerTree 

proc newJsonParser(data : string, silent :bool, colorize : bool , sort: bool) : JsonParser = 
  new(result)
  result.current = 0
  result.data = data
  result.silent = silent
  result.colorize = colorize
  result.sort = sort

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
  
proc parseBoolean(self : JsonParser) : JsonPointerTree =

  let startP = self.current - 1 

  if self.peekPrevious() == 't':
    for expected in "rue":
      discard self.consume(expected, fmt"Expected '{expected}' in boolean 'true'")
  
  else:
    for expected in "alse":
      discard self.consume(expected, fmt"Expected '{expected}' in boolean 'false'")

  JsonPointerTree(kind : Boolean, startP : startP, endP : self.current)

proc parseNull(self : JsonParser) : JsonPointerTree =

  let startP = self.current - 1 
  for expected in "ull":
    discard self.consume(expected, fmt"Expected '{expected}' in 'null'")

  JsonPointerTree(kind : Null, startP : startP, endP : self.current)

proc parseNumber(self : JsonParser) : JsonPointerTree =

  let startP = self.current - 1 
  
  while isNumber(self.peek()) or self.peek() == '.':
    discard self.advance()

  JsonPointerTree(kind : Number, startP : startP, endP : self.current)

proc parseString(self : JsonParser) : JsonPointerTree =

  let startP = self.current 
  
  while self.peek() != '\"':
    discard self.advance()

  discard self.consume('\"', "Expected \" at the end of a string ")

  JsonPointerTree(kind : String, startP : startP, endP : self.current-1)

proc parseObject(self : JsonParser) : JsonPointerTree =

  let startP = self.current 

  var itemPairs = newSeq[(JsonPointerTree, JsonPointerTree)]()
  
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
    itemPairs.sort do (x,y : tuple[key: JsonPointerTree, value: JsonPointerTree]) -> int:
      result = cmp(self.data[x.key.startP..<x.key.endP], self.data[y.key.startP..<y.key.endP])

  JsonPointerTree(kind : Object, startP : startP, endP : self.current - 1, itemPairs : itemPairs)

proc parseArray(self : JsonParser) : JsonPointerTree =

  let startP = self.current 
  var index = 0
  var items = newSeq[JsonPointerTree]()
  
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

  JsonPointerTree(kind : Array, startP : startP, endP : self.current - 1, items : items)

proc parseValue(self : JsonParser) : JsonPointerTree =
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

proc stringToGron*(data : string, silent : bool = false, sort : bool = false, colorize : bool = false) =

  var parser = newJsonParser(data, silent, colorize, sort)

  let jsonPointerTree = parser.parseValue()

  jsonPointerTree.dumpGron(data, path = "json", colorize = colorize)







