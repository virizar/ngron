import std/tables
import std/paths
import ngronpkg/json_object

let oneJsonObject* = newJsonObject(Object)
oneJsonObject.props["one"] = newJsonObject(Number)
oneJsonObject.props["one"].value = "1"
oneJsonObject.props["two"] = newJsonObject(Number)
oneJsonObject.props["two"].value = "2.2"
oneJsonObject.props["three-b"] = newJsonObject(String)
oneJsonObject.props["three-b"].value = "3"
oneJsonObject.props["four"] = newJsonObject(Array)
oneJsonObject.props["four"].items.add(newJsonObject(Number))
oneJsonObject.props["four"].items[0].value = "1"
oneJsonObject.props["four"].items.add(newJsonObject(Number))
oneJsonObject.props["four"].items[1].value = "2"
oneJsonObject.props["four"].items.add(newJsonObject(Number))
oneJsonObject.props["four"].items[2].value = "3"
oneJsonObject.props["four"].items.add(newJsonObject(Number))
oneJsonObject.props["four"].items[3].value = "4"
oneJsonObject.props["five"] = newJsonObject(Object)
oneJsonObject.props["five"].props["alpha"] = newJsonObject(Array)
oneJsonObject.props["five"].props["alpha"].items.add(newJsonObject(String))
oneJsonObject.props["five"].props["alpha"].items[0].value = "fo"
oneJsonObject.props["five"].props["alpha"].items.add(newJsonObject(String))
oneJsonObject.props["five"].props["alpha"].items[1].value = "fum"
oneJsonObject.props["five"].props["beta"] = newJsonObject(Object)
oneJsonObject.props["five"].props["beta"].props["hey"] = newJsonObject(String)
oneJsonObject.props["five"].props["beta"].props["hey"].value = "How's tricks?"
oneJsonObject.props["abool"] = newJsonObject(Boolean)
oneJsonObject.props["abool"].value = "true"
oneJsonObject.props["abool2"] = newJsonObject(Boolean)
oneJsonObject.props["abool2"].value = "false"
oneJsonObject.props["isnull"] = newJsonObject(Null)
oneJsonObject.props["isnull"].value = "null"
oneJsonObject.props["id"] = newJsonObject(Number)
oneJsonObject.props["id"].value = "66912849"

let scalarStreamJsonObject* = newJsonObject(Array)
scalarStreamJsonObject.items.add(newJsonObject(Boolean))
scalarStreamJsonObject.items[0].value = "true"
scalarStreamJsonObject.items.add(newJsonObject(Boolean))
scalarStreamJsonObject.items[1].value = "false"
scalarStreamJsonObject.items.add(newJsonObject(Null))
scalarStreamJsonObject.items[2].value = "null"
scalarStreamJsonObject.items.add(newJsonObject(String))
scalarStreamJsonObject.items[3].value = "hello"
scalarStreamJsonObject.items.add(newJsonObject(Number))
scalarStreamJsonObject.items[4].value = "4"
scalarStreamJsonObject.items.add(newJsonObject(Number))
scalarStreamJsonObject.items[5].value = "4.4"

let streamJsonObject* = newJsonObject(Array)
streamJsonObject.items.add(newJsonObject(Object))
streamJsonObject.items[0].props["one"] = newJsonObject(Number)
streamJsonObject.items[0].props["one"].value = "1"
streamJsonObject.items[0].props["three"] = newJsonObject(Array)
streamJsonObject.items[0].props["three"].items.add(newJsonObject(Number))
streamJsonObject.items[0].props["three"].items[0].value = "1"
streamJsonObject.items[0].props["three"].items.add(newJsonObject(Number))
streamJsonObject.items[0].props["three"].items[1].value = "2"
streamJsonObject.items[0].props["three"].items.add(newJsonObject(Number))
streamJsonObject.items[0].props["three"].items[2].value = "3"
streamJsonObject.items[0].props["two"] = newJsonObject(Number)
streamJsonObject.items[0].props["two"].value = "2"
streamJsonObject.items.add(newJsonObject(Object))
streamJsonObject.items[1].props["one"] = newJsonObject(Number)
streamJsonObject.items[1].props["one"].value = "1"
streamJsonObject.items[1].props["three"] = newJsonObject(Array)
streamJsonObject.items[1].props["three"].items.add(newJsonObject(Number))
streamJsonObject.items[1].props["three"].items[0].value = "1"
streamJsonObject.items[1].props["three"].items.add(newJsonObject(Number))
streamJsonObject.items[1].props["three"].items[1].value = "2"
streamJsonObject.items[1].props["three"].items.add(newJsonObject(Number))
streamJsonObject.items[1].props["three"].items[2].value = "3"
streamJsonObject.items[1].props["two"] = newJsonObject(Number)
streamJsonObject.items[1].props["two"].value = "2"


