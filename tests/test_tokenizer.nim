
import unittest
import os
import strutils
import ngronpkg/token
import ngronpkg/tokenizer



test "tokenizer basic json":
  let inFilePath = "tests/resources/tokenizer.json"
  let expectedFilePath = "tests/resources/tokenizer.json.out"
  let inFile = open(inFilePath)
  let expectedFile = open(expectedFilePath)
  defer:
    inFile.close()
    expectedFile.close()

  let tokenizer = newTokenizer(inFile.readAll())

  let tokens = tokenizer.tokenize()

  for i in 0..<tokens.len:
    let token = tokens[i]
    let expected = expectedFile.readLine()
    check $token == expected

test "tokenizer basic gron":
  let inFilePath = "tests/resources/tokenizer.gron"
  let expectedFilePath = "tests/resources/tokenizer.gron.out"
  let inFile = open(inFilePath)
  let expectedFile = open(expectedFilePath)
  defer:
    inFile.close()
    expectedFile.close()

  let tokenizer = newTokenizer(inFile.readAll())

  let tokens = tokenizer.tokenize()

  for i in 0..<tokens.len:
    let token = tokens[i]
    let expected = expectedFile.readLine()
    check $token == expected

