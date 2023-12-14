import std/strformat
import std/strutils
import std/enumerate
import std/algorithm
include json_object
include base_parser

type
  GronParser* = ref object of BaseParser
    silent : bool = false
    colorize : bool = false
    sort : bool = false
    
  GronParserException* = ref Exception

proc newGronParser(data : string, silent :bool, colorize : bool , sort: bool) : GronParser = 
  new(result)
  result.current = 0
  result.data = data
  result.silent = silent
  result.colorize = colorize
  result.sort = sort
