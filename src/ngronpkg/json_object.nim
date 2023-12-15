import std/strutils
import std/enumerate
import std/tables
include styles

type

  JsonObjectKind = enum
    String,
    Array,
    Object,
    Number,
    Boolean,
    Null

  JsonObject* = ref object
    value* : string
    case kind*: JsonObjectKind  
    of Array:
      items*: seq[JsonObject]
    of Object:
      pairs*: OrderedTable[string, JsonObject]
    else:
      discard

proc `$`(self : JsonObject) : string = 
  
  result &= "JsonObject("
  result &= $self.kind
  result &= ", '"
  result &= self.value
  result &= "')"

proc dumpJson(self : JsonObject, level : int = 0, indent : int = 2,  colorize : bool = false) =

  case self.kind:
  of String:
    if colorize : stdout.write(STRING_COLOR)
    stdout.write("\"")
    stdout.write(self.value)
    stdout.write("\"")
    if colorize: stdout.write(COLOR_END)
    stdout.flushFile()
  of Boolean, Null:
    if colorize : stdout.write(BOOLEAN_NULL_COLOR)
    stdout.write(self.value)
    if colorize: stdout.write(COLOR_END)
    stdout.flushFile()
  of Number:
    if colorize : stdout.write(NUMBER_COLOR)
    stdout.write(self.value)
    if colorize: stdout.write(COLOR_END)
    stdout.flushFile()  
  of Object:
    if colorize:
      stdout.write(STYLED_LEFT_CURLY_BRACE)
      stdout.write("\n")
    else:
      stdout.write("{\n")
    var i = 0
    for key, value in self.pairs.pairs():
      stdout.write(' '.repeat(level + indent))
      if colorize:
        stdout.write(KEY_COLOR)
        stdout.write("\"")
        stdout.write(key)
        stdout.write("\"")
        stdout.write(COLOR_END)
      else:
        stdout.write("\"")
        stdout.write(key)
        stdout.write("\"")
      stdout.write(": ")
      value.dumpJson(level = level + indent,  colorize = colorize)
      if i != self.pairs.len - 1:
        stdout.writeLine(",")
      else:
        stdout.write("\n")
      inc(i)
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
      obj.dumpJson(level = level + indent,  colorize = colorize)
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
    
proc dumpGron(self : JsonObject, path : string = "", colorize : bool = false) =
  
  case self.kind:
  of String:
    stdout.write(path)
    stdout.write(" = ")
    if colorize : stdout.write(STRING_COLOR)
    stdout.write("\"")
    stdout.write(self.value)
    stdout.write("\"")
    if colorize: stdout.write(COLOR_END)
    stdout.writeLine(";")
    stdout.flushFile()
  of Boolean, Null:
    stdout.write(path)
    stdout.write(" = ")
    if colorize : stdout.write(BOOLEAN_NULL_COLOR)
    stdout.write(self.value)
    if colorize: stdout.write(COLOR_END)
    stdout.writeLine(";")
    stdout.flushFile()
  of Number:
    stdout.write(path)
    stdout.write(" = ")
    if colorize : stdout.write(NUMBER_COLOR)
    stdout.write(self.value)
    if colorize: stdout.write(COLOR_END)
    stdout.writeLine(";")
    stdout.flushFile()  
  of Object:
    if colorize : 
      stdout.write(KEY_COLOR)
      stdout.write(path)
      stdout.write(COLOR_END)
    else:
      stdout.write(path)
    
    stdout.write(" = ")

    if colorize : 
      stdout.write(STYLED_LEFT_CURLY_BRACE)
      stdout.write(STYLED_RIGHT_CURLY_BRACE)
    else:
      stdout.write("{}")
    
    stdout.write(";\n")

    for key, value in self.pairs.pairs():
      var pathAppend = "."
      if colorize : 
        pathAppend &= KEY_COLOR
        pathAppend &= key
        pathAppend &= COLOR_END
      else:
        pathAppend &= key

      for character in key:
        if not (isAlphaNumeric(character) or character == '_'):
          if colorize : 
            pathAppend = STYLED_LEFT_BRACKET
            pathAppend &= STRING_COLOR
            pathAppend &= "\""
            pathAppend &= key
            pathAppend &= "\""
            pathAppend &= COLOR_END
            pathAppend &= STYLED_RIGHT_BRACKET
          else:
            pathAppend = "[\""
            pathAppend &= key
            pathAppend &= "\"]"

          break
      var currentPath = path & pathAppend

      if colorize : 
        currentPath = KEY_COLOR
        currentPath &= path
        currentPath &= COLOR_END
        currentPath &= pathAppend

      value.dumpGron(path = currentPath, colorize = colorize)
  of Array:

    if colorize : 
      stdout.write(KEY_COLOR)
      stdout.write(path)
      stdout.write(COLOR_END)
    else:
      stdout.write(path)
    
    stdout.write(" = ")

    if colorize : 
      stdout.write(STYLED_LEFT_BRACKET)
      stdout.write(STYLED_RIGHT_BRACKET)
    else:
      stdout.write("[]")
    
    stdout.write(";\n")

    var index = 0
    for obj in self.items:
      var currentPath = path
      if colorize:
        currentPath = KEY_COLOR
        currentPath &= path 
        currentPath &= COLOR_END
        currentPath &= STYLED_LEFT_BRACKET
        currentPath &= NUMBER_COLOR
        currentPath &= $index
        currentPath &= COLOR_END
        currentPath &= STYLED_RIGHT_BRACKET
      else:
        currentPath &= "["
        currentPath &= $index
        currentPath &= "]"
      obj.dumpGron(path = currentPath, colorize = colorize)
      inc(index)

proc dumpValues(self : JsonObject, colorize : bool = false) =

  case self.kind:
  of String:
    if colorize : stdout.write(STRING_COLOR)
    stdout.write("\"")
    stdout.write(self.value)
    stdout.write("\"")
    if colorize: stdout.write(COLOR_END)
    stdout.write("\n")
    stdout.flushFile()
  of Boolean, Null:
    if colorize : stdout.write(BOOLEAN_NULL_COLOR)
    stdout.write(self.value)
    if colorize: stdout.write(COLOR_END)
    stdout.write("\n")
    stdout.flushFile()
  of Number:
    if colorize : stdout.write(NUMBER_COLOR)
    stdout.write(self.value)
    if colorize: stdout.write(COLOR_END)
    stdout.write("\n")
    stdout.flushFile()  
  of Object:
    for key,value in self.pairs.pairs():
      value.dumpValues(colorize = colorize)
  of Array:
    for obj in self.items:
      obj.dumpValues(colorize = colorize)

