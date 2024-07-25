import std/strformat
import std/strutils
import std/tables
import token
import tokenizer
import base_parser
import json_object


type
  GronParser* = ref object of BaseParser
    globalObject: JsonObject

  GronParserException* = ref Exception

proc newGronParser(data: string, tokens: seq[Token]): GronParser =
  new(result)
  result.current = 0
  result.data = data
  result.tokens = tokens
  result.globalObject = newJsonObject(Object)

proc parseValue(self: GronParser, obj: JsonObject) =
  let token = self.advance()
  case token.kind:
  of LeftBrace:
    discard self.consume(RightBrace, "Expected '}' empty object")
    obj.kind = Object
  of LeftBracket:
    discard self.consume(RightBracket, "Expected ']' empty array")
    obj.kind = Array
  of String:
    obj.kind = String
    obj.value = token.lexeme
  of Number:
    obj.kind = Number
    obj.value = token.lexeme
  of Boolean:
    obj.kind = Boolean
    obj.value = token.lexeme
  of Null:
    obj.kind = Null
    obj.value = token.lexeme
  else:
    self.error(fmt("Cannot parse Token '{self.peek()}'"))

proc parseAssignment(self: GronParser) =

  let baseId = self.consume(Identifier, "Expected identifier for left hand side of assignment")

  var baseObject: JsonObject

  if self.globalObject.props.hasKey(baseId.lexeme):
    baseObject = self.globalObject.props[baseId.lexeme]
  else:
    baseObject = newJsonObject(Null)
    self.globalObject.props[baseId.lexeme] = baseObject

  while not self.isAtEnd() and self.peek().kind != Equal:

    let token = self.advance()
    case token.kind:

    of Dot:
      if baseObject.kind != Object:
        self.error("Cannot access property of non Object")

      if not self.match(TokenKind.Identifier, TokenKind.Boolean,
          TokenKind.Null):
        self.error("Expected identifier after '.'")

      let key = self.peekPrevious()

      if baseObject.props.hasKey(key.lexeme):
        baseObject = baseObject.props[key.lexeme]
      else:
        var newObject = newJsonObject(Null)
        baseObject.props[key.lexeme] = newObject
        baseObject = newObject

    of LeftBracket:

      if self.peek().kind == RightBracket:
        self.error("Empty index not allowed")

      if self.peek().kind == Number:
        if baseObject.kind != Array:
          self.error("Cannot access index of non Array")

        let index = self.advance().lexeme.parseInt()
        if index < baseObject.items.len:
          baseObject = baseObject.items[index]
        else:
          var newObject = newJsonObject(Null)
          baseObject.items.insert(newObject, index)
          baseObject = newObject

      elif self.peek().kind == String:
        if baseObject.kind != Object:
          self.error("Cannot access property of non Object")
        let key = self.advance().lexeme
        if baseObject.props.hasKey(key):
          baseObject = baseObject.props[key]
        else:
          var newObject = newJsonObject(Null)
          baseObject.props[key] = newObject
          baseObject = newObject

      else:
        self.error("Expected string or number index")

      discard self.consume(RightBracket, "Expected ']' after array index")

    else:
      discard

  discard self.consume(Equal, "Expected '=' after variable name")

  self.parseValue(baseObject)

  discard self.consume(Semicolon, "Expected ';' after variable assignment")

proc parse(self: GronParser): JsonObject =

  while not self.isAtEnd():
    self.parseAssignment()

  self.globalObject.props["json"]


proc gronStringToJsonObject*(data: string): JsonObject =

  var tokenizer = newTokenizer(data)

  var tokens = tokenizer.tokenize()

  var parser = newGronParser(data, tokens)

  parser.parse()
