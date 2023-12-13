
import unittest
import os
import strutils
import ngronpkg/parser

test "gron basic":
    let file = "tests/resources/basic.json"
    let f =  open(file)
    defer: f.close()
    var parser = newJsonParser()

    parser.parse(f.readAll(), silent = false)

test "gron validate":

  var parser = newJsonParser()

  let folder = "tests/resources/*"

  for path in os.walkFiles(folder):

    if not path.endsWith(".json"):
      continue
    
    let f =  open(path)
    defer: f.close()

    parser.parse(f.readAll(), silent = true)