import std/strformat
import std/strutils
import std/enumerate
import std/algorithm
import std/tables
include json_object
include base_parser

type
  JsonParser* = ref object of BaseParser
    silent : bool = false
    colorize : bool = false
    sort : bool = false
  
# forward declarations
proc parseValue(self : JsonParser) : JsonObject 

proc newJsonParser(data : string, silent :bool, colorize : bool , sort: bool) : JsonParser = 
  new(result)
  result.current = 0
  result.data = data
  result.silent = silent
  result.colorize = colorize
  result.sort = sort

proc parseBoolean(self : JsonParser) : JsonObject =

  let startP = self.current - 1 

  if self.peekPrevious() == 't':
    for expected in "rue":
      discard self.consume(expected, fmt"Expected '{expected}' in boolean 'true'")
  
  else:
    for expected in "alse":
      discard self.consume(expected, fmt"Expected '{expected}' in boolean 'false'")

  

  JsonObject(kind : Boolean, value : self.data[startP..<self.current])

proc parseNull(self : JsonParser) : JsonObject =

  let startP = self.current - 1 
  for expected in "ull":
    discard self.consume(expected, fmt"Expected '{expected}' in 'null'")

  JsonObject(kind : Null, value : self.data[startP..<self.current])

proc parseNumber(self : JsonParser) : JsonObject =

  let startP = self.current - 1 
  
  while isNumber(self.peek()) or self.peek() == '.':
    discard self.advance()

  JsonObject(kind : Number, value : self.data[startP..<self.current])

proc parseString(self : JsonParser) : JsonObject =

  let startP = self.current 
  
  while self.peek() != '\"':
    discard self.advance()

  discard self.consume('\"', "Expected \" at the end of a string ")

  JsonObject(kind : String, value : self.data[startP..<self.current-1])

proc parseObject(self : JsonParser) : JsonObject =

  var itemPairs = initOrderedTable[string, JsonObject]()
  
  while not self.isAtEnd():

    self.consumeWhitespace()

    if self.peek() == '}':
      discard self.advance()
      return JsonObject(kind : Object)
    
    discard self.consume('\"', "Expected string as key for object")

    let key =  self.parseString()
    
    self.consumeWhitespace()

    discard self.consume(':', "Expected ':' after object key")

    let item = self.parseValue()

    itemPairs[key.value] =  item

    self.consumeWhitespace()

    if self.peek() != ',':
      break
    discard self.advance()

  self.consumeWhitespace()

  discard self.consume('}', "Expected ] at the end of an array ")

  if self.sort:
    itemPairs.sort(system.cmp)

  JsonObject(kind : Object, pairs : itemPairs)

proc parseArray(self : JsonParser) : JsonObject =

  var index = 0
  var items = newSeq[JsonObject]()
  
  while not self.isAtEnd():
    
    self.consumeWhitespace()

    if self.peek() == ']':
      discard self.advance()
      return JsonObject(kind : Array)

    let item = self.parseValue()

    items.add(item)

    if self.peek() != ',':
      break
    discard self.advance()
    inc(index)

  while isWhitespace(self.peek()):
    discard self.advance()

  discard self.consume(']', "Expected ] at the end of an array ")

  JsonObject(kind : Array, items : items)

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

proc stringToGron*(data : string, silent : bool = false, sort : bool = false, colorize : bool = false, values: bool = false) =

  var parser = newJsonParser(data, silent, colorize, sort)

  let jsonPointerTree = parser.parseValue()

  if values:
    jsonPointerTree.dumpValues(colorize = colorize)
    return

  if not silent:
    jsonPointerTree.dumpGron(path = "json", colorize = colorize)







