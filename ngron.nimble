# Package

version       = "0.1.0"
author        = "victor.irizar"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["ngron"]


# Dependencies

requires "nim >= 2.0.0", "argparse >= 4.0.1"
