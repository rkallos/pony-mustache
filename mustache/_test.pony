use "ponytest"

use "files"
use "json"

actor Main is TestList
  new create(env: Env) =>
    let auth =
      try
        env.root as AmbientAuth
      else
        env.err.print("env.root as AmbientAuth failed")
        env.exitcode(-1)
        return
      end

    let dir =
      try
        Directory(FilePath(auth, "spec/specs")?)?
      else
        env.err.print("unable to open ./spec/specs/*.json")
        env.exitcode(-1)
        return
      end

    let all_files: Array[String] val =
      try
        dir.entries()?
      else
        env.err.print("unable to list ./spec/specs/*.json")
        env.exitcode(-1)
        return
      end

    let json_files = Array[String](all_files.size())

    for f in all_files.values() do
      // Skip optional files
      if f.compare_sub("~", 1, 0) is Equal then continue end
      // Keep only JSON files
      if f.compare_sub(".json", 5, -5, 0, true) is Equal then
        json_files.push(f)
      end
    end

    let pt = PonyTest(env, this)

    for f in json_files.values() do
      let contents =
        try
          let file = OpenFile(dir.path.join(f)?) as File
          String.from_array(file.read(file.size()))
        else
          env.err.print("failed while trying to read " + f)
          env.exitcode(-1)
          return
        end

      let doc' = recover JsonDoc end
      try
        doc'.parse(contents)?
      else
        (let byte, let err) = doc'.parse_report()
        env.err.print("file is invalid json: " + f)
        env.err.print("error at byte " + byte.string() + ": " + err)
        env.exitcode(-1)
        return
      end

      let doc: JsonDoc val = consume doc'

      let obj =
        try
          doc.data as JsonObject val
        else
          env.err.print("top level JSON term is not an object")
          env.exitcode(-1)
          return
        end

      let test_array =
        try
          obj.data("tests")? as JsonArray val
        else
          env.err.print(".tests either isn't an array, or is missing")
          env.exitcode(-1)
          return
        end

      for test_obj in test_array.data.values() do
        let test =
          try
            test_obj as JsonObject val
          else
            env.err.print(f + ": test is not a JSON object")
            continue
          end

        let name =
          try
            test.data.get_or_else("name", "missing") as String
          else
            env.err.print(f + ": test name is not a string")
            continue
          end

        let data =
          try
            test.data("data")?
          else
            env.err.print(f + ": test is missing a data section")
            continue
          end

        let template =
          try
            test.data("template")? as String
          else
            env.err.print(f + ": test is missing a template section or is not a string")
            continue
          end

        let expected =
          try
            test.data("expected")? as String
          else
            env.err.print(f + ": test is missing an expected section or is not a string")
            continue
          end

        let short_f = f.trim(0, f.size() - 5)
        pt(_JsonTest(consume short_f, name, template, expected, data))
      end
    end

  fun tag tests(test: PonyTest) =>
    test(_Empty)
    test(_NoBindings)
    test(_SimpleBindings)
    test(_MissingBinding)

class iso _Empty is UnitTest
  fun name(): String => "mustache/Empty"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("", Mustache("").render())

class iso _NoBindings is UnitTest
  fun name(): String => "mustache/NoBindings"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("Ahoy there!", Mustache("Ahoy there!").render())

class iso _SimpleBindings is UnitTest
  fun name(): String => "mustache/SimpleBindings"

  fun apply(h: TestHelper) =>
    let m = Mustache("Hello {{name}}")
    m.bind("name", "pony")
    h.assert_eq[String]("Hello pony", m.render())

class iso _MissingBinding is UnitTest
  fun name(): String => "mustache/MissingBinding"

  fun apply(h: TestHelper) =>
    let m = Mustache("Hello {{name}}")
    h.assert_eq[String]("Hello ", m.render())

class iso _JsonTest is UnitTest
  let _file: String
  let _name: String
  let _template: String
  let _expected: String
  let _data: JsonType val

  new iso create(file: String, name': String, template: String, expected: String,
    data: JsonType val
  ) =>
    _file = file
    _name = _file + "/" + name'
    _template = template
    _expected = expected
    _data = data

  fun name(): String => _name
  fun label(): String => _file

  fun apply(h: TestHelper) =>
    let m = Mustache(_template)
    h.assert_eq[String](_expected, m.render())
