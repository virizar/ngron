import std/cmdline
import std/sequtils
import std/options
import std/strformat
import std/net
import std/httpclient
import tokenizer
import base_parser
import json_object
import json_parser
import gron_parser
import jgron_parser
import argparse

var p = newParser:
  help("Transform JSON (from a file, URL, or stdin) into discrete assignments to make it greppable")
  flag("--version", help = "Print version information", shortcircuit = true)
  flag("-s", "--sort", help = "Sort keys (slower)")
  flag("-v", "--values", help = "Print just the values of provided assignments")
  flag("-r", "--raw", help = "Print without color")
  option("-i", "--input-type", choices = @["json", "gron", "jgron"],
      help = "Input type (Inferred from file extension)", default = some("json"))
  option("-o", "--output-type", choices = @["json", "gron", "jgron"],
      help = "Output type", default = some("gron"))
  arg("input", help = "Path to file or URL path. Ignored if piping from  stdin",
      default = some("stdin"))

proc runCli*(params: seq[string], pipeInput: bool, pipeOutput: bool) =

  try:

    let opts = p.parse(params)

    var f: File = stdin

    var data: string

    if opts.input == "stdin" and not pipeInput:
      echo p.help
      quit(1)

    if opts.input.startsWith("http://") or opts.input.startsWith("https://"):
      var client = newHttpClient()
      try:
        data = client.getContent(opts.input)
      except Exception as e:
        echo fmt("Failed to fetch URL {opts.input} - {e.msg}")
        quit(1)
      finally:
        client.close()
    else:
      f = open(opts.input)
      data = f.readAll()
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

    try:
      if inputType == "json":
        jsonObject = jsonStringToJsonObject(data)
      elif inputType == "gron":
        jsonObject = gronStringToJsonObject(data)
      elif inputType == "jgron":
        jsonObject = jgronStringToJsonObject(data)
      else:
        echo "Unknown input type"
        quit(1)
    except TokenizerException:
      quit(1)
    except ParserException:
      quit(1)
    
    if opts.values:
      jsonObject.printValues()
      quit(0)

    let colorize = not (opts.raw or pipeOutput)

    if opts.outputType == "json":
      jsonObject.printJson(sort = opts.sort, colorize = colorize)
    elif opts.outputType == "jgron":
      jsonObject.printJgron(sort = opts.sort, colorize = colorize)
    elif opts.outputType == "gron":
      jsonObject.printGron(sort = opts.sort, path = "json",
          colorize = colorize)
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


