
import std/unittest
import std/os
import ngronpkg/json_object
import ngronpkg/jgron_parser
import utils

test "jgron parser basic":
  let file = joinPath("tests", "resources", "gron", "one.jgron")
  let f = open(file)
  defer: f.close()
  let result = jgronStringToJsonObject(f.readAll())
  check result == oneJsonObject

