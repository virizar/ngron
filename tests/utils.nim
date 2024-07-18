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
oneJsonObject.props["four"].items[3].value= "4"
oneJsonObject.props["five"] = newJsonObject(Object)
oneJsonObject.props["five"].props["alpha"] = newJsonObject(Array)
oneJsonObject.props["five"].props["alpha"].items.add(newJsonObject(String))
oneJsonObject.props["five"].props["alpha"].items[0].value = "fo"
oneJsonObject.props["five"].props["alpha"].items.add(newJsonObject(String))
oneJsonObject.props["five"].props["alpha"].items[1] .value = "fum"
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
