import std/cmdline
import std/os
import std/terminal
import ngronpkg/cli

if isMainModule:
  runCli(commandLineParams(), not isatty(stdin), not isatty(stdout))

## Nim gron implementation
## Usage : 
##   - `ngron mydata.json`
##   - Copy your json in your clipboard and run `ngron -c`
