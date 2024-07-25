
import std/unittest
import std/os
import ngronpkg/json_object
import ngronpkg/gron_parser
import utils

test "gron parser basic":
  let file = joinPath("tests", "resources", "gron", "one.gron")
  let f = open(file)
  defer: f.close()
  let result = gronStringToJsonObject(f.readAll())
  check result == oneJsonObject

