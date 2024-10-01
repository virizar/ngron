# ngron

![workflow](https://github.com/virizar/ngron/actions/workflows/ci.yml/badge.svg)
![workflow](https://github.com/virizar/ngron/actions/workflows/doctest.yml/badge.svg)

Nim reimplementation of the great [gron](https://github.com/tomnomnom/gron) tool.

Converts json text into Javascript statements, and makes it easy to grep!

### Example

Lets take a very simple `json` file

``` json
{
  "integer": 1,
  "float": 2.1,
  "string": "string",
  "array": [
    0,
    "1",
    2.0
  ],
  "nest": {
    "ted": "ಠ_ಠ",
    "boolean": true,
    "null": null
  }
}
```

We can save it as `test.json`. Now lets try to play with it using `ngron`


Lets convert it to `gron`, which outputs valid json assignment statements that would generate the json input

``` bash
> ./ngron test.json
json = {};
json.integer = 1;
json.float = 2.1;
json.string = "string";
json.array = [];
json.array[0] = 0;
json.array[1] = "1";
json.array[2] = 2.0;
json.nest = {};
json.nest.ted = "ಠ_ಠ";
json.nest.boolean = true;
json.nest.null = null;
```

Or `jgron`, which outputs a stream of paths and values tuples

``` bash
> ./ngron -o jgron test.json
[[],{}]
[["integer"],1]
[["float"],2.1]
[["string"],"string"]
[["array"],[]]
[["array",0],0]
[["array",1],"1"]
[["array",2],2.0]
[["nest"],{}]
[["nest","ted"],"ಠ_ಠ"]
[["nest","boolean"],true]
[["nest","null"],null]
```

Lets save the gron output to a file `out.gron`

``` bash
> ./ngron test.json > out.gron
```

And finally lets convert our `out.gron` file to get the original json input

``` bash
> ./ngron -o json out.gron 
{
  "integer": 1,
  "float": 2.1,
  "string": "string",
  "array": [
    0,
    "1",
    2.0
  ],
  "nest": {
    "ted": "ಠ_ಠ",
    "boolean": true,
    "null": null
  }
}
```

You can also use your clipboard as an input source with the `-c` flag

### CLI Help

```
Transform JSON (from a file, URL, clipboard or stdin) into discrete assignments to make it greppable

Usage:
   [options] [input]

Arguments:
  [input]          Path to file or URL path. Ignored if piping from  stdin (default: stdin)

Options:
  -h, --help
  --version                  Print version information
  -s, --sort                 Sort keys (slower)
  -v, --values               Print just the values of provided assignments
  -c, --clipboard            Use clipboard as input
  -r, --raw                  Print without color (ignores input argument)
  -i, --input-type=INPUT_TYPE
                             Input type (Inferred from file extension) Possible values: [json, gron, jgron] (default: json)
  -o, --output-type=OUTPUT_TYPE
                             Output type Possible values: [json, gron, jgron] (default: gron)
```

### Requirements

To build and develop you will need

- `git`
- `nimble`
- `nim >= 2.0.4`


### Features 
- Input Types
  - [x] File
  - [x] URL (http/https)
  - [x] Clipboard
  - [x] stdin
- Input formats
  - [x] JSON
  - [x] JSON stream
  - [x] gron
  - [x] jgron
- Output formats
  - [x] JSON
  - [x] gron
  - [x] jgron
- Output formatting
  - [x] Sorted keys
  - [x] Colorized
  - [x] Values only

### Things to do
- [ ] Broader testing
  - Large files, weird characters.
  - Windows, Mac OS 
- [ ] Full compliance with JSON spec
  - Identifiers are not really compliant with the spec
- [ ] Benchmarks and test
  - Memory consumption and performance vs original implementation
- [ ] Optimizations
  - Compact json object data structure
  - Stream input instead of reading all string in memory
  - Better handling of allocations in tokenizer/parser
  - Multithreading
- [ ] Prebuilt binaries

### Tests


The test files of the original [gron](https://github.com/tomnomnom/gron) are part of this repository, they are located in `tests/resources/gron`

Other tests files are added to the folder `tests/resources`

The original testing and development has been carried on Ubuntu 20.4

### Resources

- [gron](https://github.com/tomnomnom/gron) repository
- [Nim std library docs](https://nim-lang.org/docs/lib.html)
- [Crafting interpreters](https://craftinginterpreters.com/) book. The parsers are heavily inspired on the book!
- [Scripter's notes on tty on Nim](https://scripter.co/nim-check-if-stdin-stdout-are-associated-with-terminal-or-pipe/), has some great info on Nim tricks all around
