import std/strformat
import std/tables
import token
import tokenizer
import json_object
import base_parser


type
  JsonParser* = ref object of BaseParser


# forward declarations
proc parseValue(self: JsonParser): JsonObject

proc newJsonParser(data: string, tokens: seq[Token]): JsonParser =
  new(result)
  result.current = 0
  result.data = data
  result.tokens = tokens


proc parseObject(self: JsonParser): JsonObject =

  var itemPairs = newOrderedTable[string, JsonObject]()

  while not self.isAtEnd() and self.peek().kind != RightBrace:

    let key = self.consume(String, "Expected string as key for object")

    discard self.consume(Colon, "Expected ':' after object key")

    itemPairs[key.lexeme] = self.parseValue()

    if self.peek().kind != Comma:
      break

    discard self.advance()

  discard self.consume(RightBrace, "Expected ] at the end of an array ")

  result = newJsonObject(Object)
  result.props = itemPairs

proc parseArray(self: JsonParser): JsonObject =

  var index = 0
  var items = newSeq[JsonObject]()

  while not self.isAtEnd() and self.peek().kind != RightBracket:

    items.add(self.parseValue())
    if self.peek().kind != Comma:
      break
    discard self.advance()
    inc(index)

  discard self.consume(RightBracket, "Expected ] at the end of an array ")

  result = newJsonObject(Array)
  result.items = items

proc parseValue(self: JsonParser): JsonObject =
  while not self.isAtEnd():
    let token = self.advance()
    case token.kind:
    of LeftBrace:
      return self.parseObject()
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

proc parseValues(self: JsonParser): JsonObject =

  result = newJsonObject(Array)
  var items = newSeq[JsonObject]()

  while self.current < self.tokens.len - 1:
    items.add(self.parseValue())
  result.items = items

proc jsonStringToJsonObject*(data: string): JsonObject =

  var tokenizer = newTokenizer(data)

  var tokens = tokenizer.tokenize()

  var parser = newJsonParser(data, tokens)

  result = parser.parseValues()

  if result.items.len == 1:
    return result.items[0]





