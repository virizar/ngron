import std/strformat
import std/strutils
import std/enumerate
import std/algorithm
include styles

type

  JsonPointerTreeKind = enum
    String,
    Array,
    Object,
    Number,
    Boolean,
    Null

  JsonPointerTree* = ref object
    startP* : int
    endP*: int
    case kind*: JsonPointerTreeKind  
    of Array:
      items*: seq[JsonPointerTree]
    of Object:
      itemPairs*: seq[tuple[key: JsonPointerTree, value: JsonPointerTree]]
    else:
      discard

proc sortKeys(self : JsonPointerTree, data : string, ascending  : bool = true) =
  case self.kind:
  of Object:
    self.itemPairs.sort do (x,y : tuple[key: JsonPointerTree, value: JsonPointerTree]) -> int:
      result = cmp(data[x.key.startP..<x.key.endP], data[y.key.startP..<y.key.endP])
    for obj in self.itemPairs:
      obj.value.sortKeys(data, ascending)
  of Array:
    for obj in self.items:
      obj.sortKeys(data, ascending)
  else:
    discard

proc dumpJson(self : JsonPointerTree, data : string, level : int = 0, indent : int = 2,  colorize : bool = false) =

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
    
proc dumpGron(self : JsonPointerTree, data : string,  path : string = "", colorize : bool = false) =
  
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
        if not (isAlphaNumeric(character) or character == '_'):
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

      if colorize : 
        currentPath = KEY_COLOR
        currentPath &= path
        currentPath &= COLOR_END
        currentPath &= pathAppend

      obj.value.dumpGron(data = data, path = currentPath, colorize = colorize)
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
      obj.dumpGron(data = data, path = currentPath, colorize = colorize)
      inc(index)

proc dumpValues(self : JsonPointerTree, data : string, colorize : bool = false) =

  case self.kind:
  of String:
    if colorize : stdout.write(STRING_COLOR)
    stdout.write("\"")
    stdout.write(data[self.startP..<self.endP])
    stdout.write("\"")
    if colorize: stdout.write(COLOR_END)
    stdout.write("\n")
    stdout.flushFile()
  of Boolean, Null:
    if colorize : stdout.write(BOOLEAN_NULL_COLOR)
    stdout.write(data[self.startP..<self.endP])
    if colorize: stdout.write(COLOR_END)
    stdout.write("\n")
    stdout.flushFile()
  of Number:
    if colorize : stdout.write(NUMBER_COLOR)
    stdout.write(data[self.startP..<self.endP])
    if colorize: stdout.write(COLOR_END)
    stdout.write("\n")
    stdout.flushFile()  
  of Object:
    for obj in self.itemPairs:
      obj.value.dumpValues(data = data, colorize = colorize)
  of Array:
    for obj in self.items:
      obj.dumpValues(data = data, colorize = colorize)

