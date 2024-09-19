import std/cmdline
import std/os
import std/terminal
import ngronpkg/cli

if isMainModule:
  runCli(commandLineParams(), not isatty(stdin), not isatty(stdout))
