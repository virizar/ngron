import std/cmdline
import std/sequtils
import std/options
import json_parser
import gron_parser
import jgron_parser
import argparse

var p = newParser:
  help("Transform JSON (from a file, URL, or stdin) into discrete assignments to make it greppable")
  flag( "--version", help="Print version information", shortcircuit=true)
  flag( "--validate", help="Validate json input. Will only print errors and warnings.")
  flag( "-s", "--sort", help="sort keys (slower)")
  flag("-v", "--values", help="Print just the values of provided assignments")
  flag("-c", "--colorize", help="Colorize output")
  flag("-j", "--json-stream", help="Represent gron data as JSON stream")
  flag("-u", "--ungron", help="Reverse the operation (turn assignments back into JSON)")
  arg("input", help="Path to json file")

proc runCli*(params : seq[string], pipeInput : bool) = 

  try:
    
    var tempParams = params

    if pipeInput:
      tempParams = tempParams.filter(proc(x: string): bool = x.startsWith('-'))
      tempParams.add("stdin")

    let opts = p.parse(tempParams)

    var f : File 
    
    if pipeInput:
      f = stdin
    else:
      f = open(opts.input)

    defer: f.close()
    
    if opts.validate:
      stringToGron(f.readAll(), silent = true, false, colorize = false)
      echo "FILE OK"
      quit(0)

    if opts.ungron:
      gronStringToJson(f.readAll(), silent = false, sort = opts.sort, colorize = opts.colorize)
      quit(0)
    
    stringToGron(f.readAll(), silent = false, sort = opts.sort, colorize = opts.colorize,  values = opts.values)

  except ShortCircuit as err:
    if err.flag == "argparse_help":
      echo err.help
      quit(1)
    elif err.flag == "version":
      echo "ngron 0.1.0"
      quit(0)
    else:
      echo "Unknown flag"
      quit(1)
      
  except UsageError:
    stderr.writeLine getCurrentExceptionMsg()
    quit(1)


