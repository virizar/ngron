import std/strutils
import std/enumerate
import std/tables
import std/strformat
include styles

type

  JsonObjectKind* = enum
    Null,
    String,
    Array,
    Object,
    Number,
    Boolean
    

  JsonObject* = ref object
    value* : string
    kind*: JsonObjectKind  
    items*: seq[JsonObject]
    props*: OrderedTableRef[string, JsonObject]


proc newJsonObject*(kind : JsonObjectKind, value : string = "") : JsonObject =
  new(result)
  result.kind = kind
  result.value = value
  result.items = @[]
  result.props = newOrderedTable[string, JsonObject]()


proc `$`*(self : JsonObject) : string = 
  
  result &= "JsonObject("
  result &= $self.kind
  result &= ", '"
  result &= self.value
  result &= "', "
  result &= $self.items
  result &= ", "
  result &= $self.props
  result &= "')"


proc `==`*(self :  JsonObject , other : JsonObject) : bool =

  if self.kind != other.kind:
    echo "Kind mismatch"
    return false

  if self.value != other.value:
    echo "Value mismatch"
    return false

  if self.items.len != other.items.len:
    echo "Items length mismatch"
    return false

  if self.props.len != other.props.len:
    echo "Props length mismatch"
    return false

  for i in 0..<self.items.len:
    if self.items[i] != other.items[i]:
      echo fmt("Item mismatch at index {i}")
      return false

  for key, value in self.props.pairs():
    if not other.props.hasKey(key):
      echo fmt("Key {key} not found in other")
      return false
    if value != other.props[key]:
      echo fmt("Value mismatch for key {key}")
      return false

  true

proc printJson*(self : JsonObject, level : int = 0, indent : int = 2,  colorize : bool = false, sort : bool = false) =

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
    
    if sort:
      self.props.sort(system.cmp)

    var i = 0
    for key, value in self.props.pairs():
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
      value.printJson(level = level + indent,  colorize = colorize, sort = sort)
      if i != self.props.len - 1:
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
      obj.printJson(level = level + indent,  colorize = colorize, sort = sort)
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
    
proc printGron*(self : JsonObject, path : string = "", colorize : bool = false, sort: bool = false) =
  
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

    if sort:
      self.props.sort(system.cmp)

    for key, value in self.props.pairs():
      var pathAppend = "."

      if key[0] in ['_', '$'] or key[0].isAlphaAscii():

        if colorize : 
          pathAppend &= KEY_COLOR
          pathAppend &= key
          pathAppend &= COLOR_END
        else:
          pathAppend &= key
      
      else:

        for character in key:
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

      value.printGron(path = currentPath, colorize = colorize, sort=sort)
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
      obj.printGron(path = currentPath, colorize = colorize, sort=sort)
      inc(index)

proc printValues*(self : JsonObject, colorize : bool = false) =

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
    for key,value in self.props.pairs():
      value.printValues(colorize = colorize)
  of Array:
    for obj in self.items:
      obj.printValues(colorize = colorize)
