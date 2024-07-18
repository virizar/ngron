
import unittest
import std/os
import ngronpkg/json_object
import ngronpkg/gron_parser
import ngronpkg/json_parser
import ngronpkg/jgron_parser

test "multiple conversions":
  let names = ["one", "two", "three", "github"]
  let folder = joinPath("tests", "resources", "gron")

  for name in  names:
    let gronFilePath = joinPath(folder, name & ".gron") 
    let jsonFilePath = joinPath(folder, name & ".json") 
    let jgronFilePath = joinPath(folder, name & ".jgron") 
    let gf =  open(gronFilePath)
    let jf =  open(jsonFilePath)
    let jgf =  open(jgronFilePath)
    defer: 
      gf.close()
      jf.close()
      jgf.close()
    
    let gronJsonObject = gronStringToJsonObject(gf.readAll())
    let jsonJsonObject = jsonStringToJsonObject(jf.readAll())
    let jgronJsonObject = jgronStringToJsonObject(jgf.readAll())

    check gronJsonObject == jsonJsonObject
    check gronJsonObject == jgronJsonObject
    check jsonJsonObject == jgronJsonObject
