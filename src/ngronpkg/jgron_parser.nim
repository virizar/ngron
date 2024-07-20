import std/strformat
import std/strutils
import std/tables
import token
import tokenizer 
import base_parser
import json_object

type
  JGronParser* = ref object of BaseParser
    globalObject : JsonObject
    
  JGronParserException* = ref Exception

proc newJGronParser(data : string, tokens : seq[Token]) : JGronParser = 
  new(result)
  result.current = 0
  result.data = data
  result.tokens = tokens
  var glob = newJsonObject(Object)
  glob.props["json"] = newJsonObject(Null)
  result.globalObject = glob

proc parseValue(self : JGronParser, obj : JsonObject)  =
  let token = self.advance()
  case token.kind :
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

proc parseAssignment(self : JGronParser)  = 

  discard self.consume(LeftBracket, "Expected '[' at the beginning of assignment")

  discard self.consume(LeftBracket, "Expected '[' at the beginning of jgron lhs")

  var baseObject = self.globalObject.props["json"]

  while not self.isAtEnd() and self.peek().kind != RightBracket:

    let token = self.advance()
    case token.kind:
    of String:
      if baseObject.kind != Object:
        self.error("Cannot access property of non Object")

      if baseObject.props.hasKey(token.lexeme):
        baseObject = baseObject.props[token.lexeme]
      else:
        var newObject = newJsonObject(Null) 
        baseObject.props[token.lexeme] = newObject
        baseObject = newObject      

    of Number:
      
      if baseObject.kind != Array:
        self.error("Cannot access index of non Array")

      let index = token.lexeme.parseInt()
      if index < baseObject.items.len:
        baseObject = baseObject.items[index]
      else:
        var newObject  = newJsonObject(Null)
        baseObject.items.insert(newObject, index)
        baseObject = newObject
      
    of Comma:
      discard 
    else:
      self.error("Expected string or number index")
    
  discard self.consume(RightBracket, "Expected ']' after array index")

  discard self.consume(Comma, "Expected ',' after array index")

  self.parseValue(baseObject)

  discard self.consume(RightBracket, "Expected ']' at the end of assignment")


proc parse(self : JGronParser) : JsonObject = 

  while not self.isAtEnd():
    self.parseAssignment()

  self.globalObject.props["json"]


proc jgronStringToJsonObject*(data: string) : JsonObject = 
  
  var tokenizer = newTokenizer(data)

  var tokens = tokenizer.tokenize()

  var parser = newJGronParser(data, tokens)

  parser.parse()

