
import std/unittest
import std/os
import ngronpkg/json_object
import ngronpkg/json_parser
import utils 

test "json parser basic":
  let file = joinPath("tests", "resources", "gron", "one.json")
  let f =  open(file)
  defer: f.close()
  let result =  jsonStringToJsonObject(f.readAll())
  check result == oneJsonObject
