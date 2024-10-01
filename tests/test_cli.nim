
import std/unittest
import std/os
import std/osproc
import std/strformat
import std/re
import ngronpkg/json_object
import ngronpkg/json_parser
import ngronpkg/gron_parser
import ngronpkg/jgron_parser
import utils
import nimclipboard/libclipboard

discard execProcess("nimble build")

test "json file to gron":
  let file = joinPath("tests", "resources", "gron", "one.json")
  let output = execProcess(fmt("./ngron {file}"))
  let result = gronStringToJsonObject(output)
  check result == oneJsonObject

test "json file to jgron":
  let file = joinPath("tests", "resources", "gron", "one.json")
  let output = execProcess(fmt("./ngron -o jgron {file}"))
  let result = jgronStringToJsonObject(output)
  check result == oneJsonObject

test "gron file to json":
  let file = joinPath("tests", "resources", "gron", "one.gron")
  let output = execProcess(fmt("./ngron -o json {file}"))
  let result = jsonStringToJsonObject(output)
  check result == oneJsonObject

test "gron file to jgron":
  let file = joinPath("tests", "resources", "gron", "one.gron")
  let output = execProcess(fmt("./ngron -o jgron {file}"))
  let result = jgronStringToJsonObject(output)
  check result == oneJsonObject

test "jgron file to json":
  let file = joinPath("tests", "resources", "gron", "one.jgron")
  let output = execProcess(fmt("./ngron -o json {file}"))
  let result = jsonStringToJsonObject(output)
  check result == oneJsonObject

test "jgron file to gron":
  let file = joinPath("tests", "resources", "gron", "one.jgron")
  let output = execProcess(fmt("./ngron -o gron {file}"))
  let result = gronStringToJsonObject(output)
  check result == oneJsonObject

test "json file to sorted gron":
  let file = joinPath("tests", "resources", "gron", "one.json")
  let output = execProcess(fmt("./ngron -s {file}"))
  let result = gronStringToJsonObject(output)
  check result.isSorted()

#TODO: test color output

test "gron file from https":
  let output = execProcess("./ngron -o gron https://jsonplaceholder.typicode.com/posts/1")
  discard gronStringToJsonObject(output)

test "json file from clipboard":
  let file = joinPath("tests", "resources", "gron", "one.json")
  let f = open(file)
  let data = f.readAll()
  defer: f.close()
  var cb = clipboard_new(nil)
  defer: cb.clipboard_free()
  cb.clipboard_clear(LCB_CLIPBOARD)
  echo cb.clipboard_set_text(data)
  let output = execProcess(fmt("./ngron -c "))
  let result = gronStringToJsonObject(output)
  check result == oneJsonObject
