
import unittest
import ngronpkg/json_object
import ngronpkg/gron_parser
import ngronpkg/json_parser

test "multiple conversions":
  let names = ["one", "two", "three", "github"]
  let folder = "tests/resources/gron"

  for name in  names:
    echo "testing: ", name
    let gronFilePath = folder & "/" & name & ".gron"
    let jsonFilePath = folder & "/" & name & ".json"
    let gf =  open(gronFilePath)
    let jf =  open(jsonFilePath)
    defer: 
      gf.close()
      jf.close()
    
    let gronJsonObject = gronStringToJsonObject(gf.readAll())
    let jsonJsonObject = jsonStringToJsonObject(jf.readAll())

    check gronJsonObject == jsonJsonObject
