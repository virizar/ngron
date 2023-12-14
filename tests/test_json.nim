
import unittest
import os
import strutils
import ngronpkg/json_parser

test "gron basic":
    let file = "tests/resources/basic.json"
    let f =  open(file)
    defer: f.close()
    stringToGron(f.readAll(), silent = false, sort = false, colorize = false)

test "gron validate":

  let folder = "tests/resources/*"

  for path in os.walkFiles(folder):

    if not path.endsWith(".json"):
      continue
    
    let f =  open(path)
    defer: f.close()

    stringToGron(f.readAll(), silent = true, sort = false, colorize = false)