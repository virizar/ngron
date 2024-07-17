# ngron

Nim implementation of the [gron](https://github.com/tomnomnom/gron) tool.

Converts json text into Javascript statements, and makes it easy to grep!

### Example

Lets take a very simple JSON file

``` json
{
  "integer": 1,
  "string": "simple string",
  "array": [0,1,2],
  "nest": {
    "doubleNest": {
      "arrayNest": [
        {"1" : 1, "2" : 2}
      ]
    }
  },
  "boolean": true,
  "null": null,
}
```

We can save it as `test.json`. Now lets try to play with it using `ngron`

Lets check that it is indeed valid JSON

``` bash
> ./ngron test.json --validate
FILE OK
```

Now lets convert it to gron

``` bash
> ./ngron test.json
json = {};
json.integer = 1;
json.string = "simple string";
json.array = [];
json.array[0] = 0;
json.array[1] = 1;
json.array[2] = 2;
json.nest = {};
json.nest.doubleNest = {};
json.nest.doubleNest.arrayNest = [];
json.nest.doubleNest.arrayNest[0] = {};
json.nest.doubleNest.arrayNest[0].1 = 1;
json.nest.doubleNest.arrayNest[0].2 = 2;
json.boolean = true;
json.null = null;
```

This outputs valid JSON assignment statements that would generate the JSON input

Lets save the gron output to a file `out.gron`

``` bash
> ./ngron test.json > out.gron
```

And finally lets ungron our `out.gron` file to get the original JSON input



### CLI 

``` bash
Transform JSON (from a file, URL, or stdin) into discrete assignments to make it greppable

Usage:
   [options] input

Arguments:
  input            Path to json file

Options:
  -h, --help
  --version                  Print version information
  --validate                 Validate json input. Will only print errors and warnings.
  --sort                     sort keys (slower)
  -v, --values               Print just the values of provided assignments
  -c, --colorize             Colorize output
  -j, --json-stream          Represent gron data as JSON stream
  -u, --ungron               Reverse the operation (turn assignments back into JSON)

```


### Features 
- [x] Read from file
- [ ] Read from URL
- [x] Read from stdin
- [x] Validate input JSON
- [x] Colorize output
- [x] Sort output
- [x] Convert gron assignments back to JSON
- [x] Output values only

### Tests

The test files of the original [gron](https://github.com/tomnomnom/gron) are part of this repository

### Benchmarks