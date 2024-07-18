
import unittest
import os
import strutils
import ngronpkg/gron_parser

test "gron parser basic":
    let file = "tests/resources/gron/one.gron"
    let f =  open(file)
    defer: f.close()
    gronStringToJson(f.readAll(), silent = false, sort = false, colorize = false)

