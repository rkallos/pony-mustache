#!/usr/bin/jq -Mfr

# meant to be used with comments.json from
# https://github.com/mustache/spec

def testClass(n): "_Test" + (n | gsub("[() -]"; ""));

"use \"ponytest\"
use \"json\"
use \"../..\"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>",
(.tests[].name | ("    test(" + testClass(.) + ")")),
(.tests[] | ("
class iso " + testClass(.name) + " is UnitTest
  fun name(): String => \"partials/" + .name + "\"

  fun apply(h: TestHelper) ? =>
    let template = " + (.template | @json) + "
    let expected = " + (.expected | @json) + "
    let data = (recover val
      JsonDoc.>parse(\"\"\"" + (.data | tojson) + "\"\"\")?
    end).data
    let partials_data = (recover val
      JsonDoc.>parse(\"\"\"" + (.partials | tojson) + "\"\"\")?
    end).data
    let partials: Partials iso = recover
      PartialsFromJson(partials_data)
    end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data, consume partials))"))
