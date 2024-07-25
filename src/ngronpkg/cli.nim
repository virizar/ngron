import std/cmdline
import std/sequtils
import std/options
import json_object
import json_parser
import gron_parser
import jgron_parser
import argparse

var p = newParser:
  help("Transform JSON (from a file, URL, or stdin) into discrete assignments to make it greppable")
  flag("--version", help = "Print version information", shortcircuit = true)
  flag("--validate", help = "Validate json input. Will only print errors and warnings.")
  flag("-s", "--sort", help = "Sort keys (slower)")
  flag("-v", "--values", help = "Print just the values of provided assignments")
  flag("-c", "--colorize", help = "Colorize output")
  option("-i", "--input-type", choices = @["json", "gron", "jgron"],
      help = "Input type (Inferred from file extension)", default = some("json"))
  option("-o", "--output-type", choices = @["json", "gron", "jgron"],
      help = "Output type", default = some("gron"))
  arg("input", help = "Path to file or URL path. Ignored if piping from  stdin",
      default = some("stdin"))

proc runCli*(params: seq[string], pipeInput: bool) =

  try:

    let opts = p.parse(params)

    var f: File = stdin

    if opts.input == "stdin" and not pipeInput:
      echo p.help
      quit(1)

    f = open(opts.input)

    defer: f.close()

    var jsonObject: JsonObject

    var inputType = opts.inputType
    var (_, _, ext) = splitFile(opts.input)

    if ext == ".gron":
      inputType = "gron"
    elif ext == ".jgron":
      inputType = "jgron"
    else:
      discard

    if inputType == "json":
      jsonObject = jsonStringToJsonObject(f.readAll())
    elif inputType == "gron":
      jsonObject = gronStringToJsonObject(f.readAll())
    elif inputType == "jgron":
      jsonObject = jgronStringToJsonObject(f.readAll())
    else:
      echo "Unknown input type"
      quit(1)

    if opts.values:
      jsonObject.printValues()
      quit(0)

    if opts.outputType == "json":
      jsonObject.printJson(sort = opts.sort, colorize = opts.colorize)
    elif opts.outputType == "jgron":
      jsonObject.printJgron(sort = opts.sort, colorize = opts.colorize)
    elif opts.outputType == "gron":
      jsonObject.printGron(sort = opts.sort, path = "json",
          colorize = opts.colorize)
    else:
      echo "Unknown output type"
      quit(1)

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


