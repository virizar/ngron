# Package

version       = "0.1.0"
author        = "victor.irizar"
description   = "Make JSON greppable in Nim"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["ngron"]


# Dependencies

requires "nim >= 2.0.4", "argparse >= 4.0.1"
requires "nimclipboard >= 0.1.2 "

task gendoc, "gen doc":
  exec("nimble doc --backend:cpp --project src/ngron.nim --out:docs/")

task test, "Run the tests":
  # run the manually to change the compilation flags
  # TODO add your command run tests
  discard

