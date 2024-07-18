import std/strformat
import std/algorithm
import std/tables
import token
import tokenizer
import json_object
import base_parser


type
  JsonParser* = ref object of BaseParser

  
# forward declarations
proc parseValue(self : JsonParser) : JsonObject 

proc newJsonParser(data : string, tokens : seq[Token],  silent :bool, colorize : bool , sort: bool) : JsonParser = 
  new(result)
  result.current = 0
  result.data = data
  result.tokens = tokens
  result.silent = silent
  result.colorize = colorize
  result.sort = sort


proc parseObject(self : JsonParser) : JsonObject =

  var itemPairs = newOrderedTable[string, JsonObject]()
  
  while not self.isAtEnd() and self.peek().kind != RightBrace:
    
    let key =  self.consume(String, "Expected string as key for object")

    discard self.consume(Colon, "Expected ':' after object key")

    itemPairs[key.lexeme] =  self.parseValue()

    if self.peek().kind != Comma:
      break

    discard self.advance()

  discard self.consume(RightBrace, "Expected ] at the end of an array ")

  if self.sort:
    itemPairs.sort(system.cmp)

  result = newJsonObject(Object)
  result.props = itemPairs

proc parseArray(self : JsonParser) : JsonObject =

  var index = 0
  var items = newSeq[JsonObject]()
  
  while not self.isAtEnd() and  self.peek().kind != RightBracket:

    items.add(self.parseValue())
    if self.peek().kind != Comma:
      break
    discard self.advance()
    inc(index)

  discard self.consume(RightBracket, "Expected ] at the end of an array ")

  result = newJsonObject(Array)
  result.items = items

proc parseValue(self : JsonParser) : JsonObject =
  while not self.isAtEnd():
    let token = self.advance()
    case token.kind:
    of LeftBrace:
      return  self.parseObject()
    of LeftBracket:
      return self.parseArray()
    of String:
      return newJsonObject(String, token.lexeme)
    of Number:
      return newJsonObject(Number, token.lexeme)
    of Boolean:
      return newJsonObject(Boolean, token.lexeme)
    of Null:
      return newJsonObject(Null, token.lexeme)
    else:
      self.error(fmt("Cannot parse Token '{token}'"))  

proc stringToGron*(data : string, silent : bool = false, sort : bool = false, colorize : bool = false, values: bool = false) =

  var tokenizer = newTokenizer(data)

  var tokens = tokenizer.tokenize()

  var parser = newJsonParser(data, tokens, silent, colorize, sort)

  let jsonPointerTree = parser.parseValue()

  if values:
    jsonPointerTree.dumpValues(colorize = colorize)
    return

  if not silent:
    jsonPointerTree.dumpGron(path = "json", colorize = colorize)


proc jsonStringToJsonObject*(data: string) : JsonObject = 
  
  var tokenizer = newTokenizer(data)

  var tokens = tokenizer.tokenize()

  var parser = newJsonParser(data, tokens, false, false, false)

  parser.parseValue()




