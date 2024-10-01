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
