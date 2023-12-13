import std/cmdline
import std/options
import parser
import argparse

# Transform JSON (from a file, URL, or stdin) into discrete assignments to make it greppable

# Usage:
#   gron [OPTIONS] [FILE|URL|-]

# Options:
#   -u, --ungron     Reverse the operation (turn assignments back into JSON)
#   -v, --values     Print just the values of provided assignments
#   -c, --colorize   Colorize output (default on tty)
#   -m, --monochrome Monochrome (don't colorize output)
#   -s, --stream     Treat each line of input as a separate JSON object
#   -k, --insecure   Disable certificate validation
#   -j, --json       Represent gron data as JSON stream
#       --no-sort    Don't sort output (faster)
#       --version    Print version information

var p = newParser:
  help("Transform JSON (from a file, URL, or stdin) into discrete assignments to make it greppable")
  flag( "--version", help="Print version information")
  flag( "--validate", help="Validate json input")
  flag( "--sort", help="sort keys (slower)")
  flag("-c", "--colorize", help="Colorize output (default on tty)")
  option("-u", "--ungron", help="Reverse the operation (turn assignments back into JSON)")
  option("-v", "--values", help="Print just the values of provided assignments")
  arg("input", default=some(""), help="Path to json file")

proc runCli*(params : seq[string]) = 

  try:
    let opts = p.parse(params)

    if opts.version:
      echo "v0.0.1"
      quit(0)

    if opts.input == "":
      echo "Missing argument(s): input"
      echo p.help
      quit(1)


    let f =  open(opts.input)
    defer: f.close()

    var parser = newJsonParser()
    
    if opts.validate:
      parser.parse(f.readAll(), silent = true, sort = opts.sort)
      echo "FILE OK"
    else:
      parser.parse(f.readAll(), silent = false, sort = opts.sort)

  except ShortCircuit as err:
    if err.flag == "argparse_help":
      echo err.help
      quit(1)
  except UsageError:
    stderr.writeLine getCurrentExceptionMsg()
    quit(1)


