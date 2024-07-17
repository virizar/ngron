
import unittest
import os
import strutils
import ngronpkg/json_parser

test "json parser basic":
    let file = "tests/resources/gron/basic.json"
    let f =  open(file)
    defer: f.close()
    stringToGron(f.readAll(), silent = false, sort = false, colorize = false)

test "json parser bulk validation":

  let folder = "tests/resources/gron/*"

  for path in os.walkFiles(folder):

    if not path.endsWith(".json"):
      continue
    
    let f =  open(path)
    defer: f.close()

    stringToGron(f.readAll(), silent = true, sort = false, colorize = false)