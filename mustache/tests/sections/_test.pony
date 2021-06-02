use "ponytest"
use "json"
use "../.."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestFalsey)
    test(_TestTruthy)
    test(_TestNullisfalsey)
    test(_TestContext)
    test(_TestList)
    test(_TestEmptyList)
    test(_TestDoubled)
    test(_TestNestedFalsey)
    test(_TestNestedTruthy)
    test(_TestContextMisses)
    test(_TestDottedNamesTruthy)
    test(_TestDottedNamesFalsey)
    test(_TestDottedNamesBrokenChains)
    test(_TestSurroundingWhitespace)
    test(_TestInternalWhitespace)
    test(_TestIndentedInlineSections)
    test(_TestStandaloneLines)
    test(_TestStandaloneIndentedLines)
    test(_TestStandaloneLineEndings)
    test(_TestStandaloneWithoutPreviousLine)
    test(_TestStandaloneWithoutNewline)
    test(_TestPadding)

class iso _TestFalsey is UnitTest
  fun name(): String => "sections/Falsey"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{^boolean}}This should be rendered.{{/boolean}}\""
    let expected = "\"This should be rendered.\""
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestTruthy is UnitTest
  fun name(): String => "sections/Truthy"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{^boolean}}This should not be rendered.{{/boolean}}\""
    let expected = "\"\""
    let data = (recover val
      JsonDoc.>parse("""{"boolean":true}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestNullisfalsey is UnitTest
  fun name(): String => "sections/Null is falsey"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{^null}}This should be rendered.{{/null}}\""
    let expected = "\"This should be rendered.\""
    let data = (recover val
      JsonDoc.>parse("""{"null":null}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestContext is UnitTest
  fun name(): String => "sections/Context"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{^context}}Hi {{name}}.{{/context}}\""
    let expected = "\"\""
    let data = (recover val
      JsonDoc.>parse("""{"context":{"name":"Joe"}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestList is UnitTest
  fun name(): String => "sections/List"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{^list}}{{n}}{{/list}}\""
    let expected = "\"\""
    let data = (recover val
      JsonDoc.>parse("""{"list":[{"n":1},{"n":2},{"n":3}]}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestEmptyList is UnitTest
  fun name(): String => "sections/Empty List"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{^list}}Yay lists!{{/list}}\""
    let expected = "\"Yay lists!\""
    let data = (recover val
      JsonDoc.>parse("""{"list":[]}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDoubled is UnitTest
  fun name(): String => "sections/Doubled"

  fun apply(h: TestHelper) ? =>
    let template = "{{^bool}}\n* first\n{{/bool}}\n* {{two}}\n{{^bool}}\n* third\n{{/bool}}\n"
    let expected = "* first\n* second\n* third\n"
    let data = (recover val
      JsonDoc.>parse("""{"bool":false,"two":"second"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestNestedFalsey is UnitTest
  fun name(): String => "sections/Nested (Falsey)"

  fun apply(h: TestHelper) ? =>
    let template = "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
    let expected = "| A B C D E |"
    let data = (recover val
      JsonDoc.>parse("""{"bool":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestNestedTruthy is UnitTest
  fun name(): String => "sections/Nested (Truthy)"

  fun apply(h: TestHelper) ? =>
    let template = "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
    let expected = "| A  E |"
    let data = (recover val
      JsonDoc.>parse("""{"bool":true}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestContextMisses is UnitTest
  fun name(): String => "sections/Context Misses"

  fun apply(h: TestHelper) ? =>
    let template = "[{{^missing}}Cannot find key 'missing'!{{/missing}}]"
    let expected = "[Cannot find key 'missing'!]"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesTruthy is UnitTest
  fun name(): String => "sections/Dotted Names - Truthy"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"\""
    let expected = "\"\" == \"\""
    let data = (recover val
      JsonDoc.>parse("""{"a":{"b":{"c":true}}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesFalsey is UnitTest
  fun name(): String => "sections/Dotted Names - Falsey"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"Not Here\""
    let expected = "\"Not Here\" == \"Not Here\""
    let data = (recover val
      JsonDoc.>parse("""{"a":{"b":{"c":false}}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesBrokenChains is UnitTest
  fun name(): String => "sections/Dotted Names - Broken Chains"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"Not Here\""
    let expected = "\"Not Here\" == \"Not Here\""
    let data = (recover val
      JsonDoc.>parse("""{"a":{}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestSurroundingWhitespace is UnitTest
  fun name(): String => "sections/Surrounding Whitespace"

  fun apply(h: TestHelper) ? =>
    let template = " | {{^boolean}}\t|\t{{/boolean}} | \n"
    let expected = " | \t|\t | \n"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestInternalWhitespace is UnitTest
  fun name(): String => "sections/Internal Whitespace"

  fun apply(h: TestHelper) ? =>
    let template = " | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
    let expected = " |  \n  | \n"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestIndentedInlineSections is UnitTest
  fun name(): String => "sections/Indented Inline Sections"

  fun apply(h: TestHelper) ? =>
    let template = " {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n"
    let expected = " NO\n WAY\n"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneLines is UnitTest
  fun name(): String => "sections/Standalone Lines"

  fun apply(h: TestHelper) ? =>
    let template = "| This Is\n{{^boolean}}\n|\n{{/boolean}}\n| A Line\n"
    let expected = "| This Is\n|\n| A Line\n"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneIndentedLines is UnitTest
  fun name(): String => "sections/Standalone Indented Lines"

  fun apply(h: TestHelper) ? =>
    let template = "| This Is\n  {{^boolean}}\n|\n  {{/boolean}}\n| A Line\n"
    let expected = "| This Is\n|\n| A Line\n"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneLineEndings is UnitTest
  fun name(): String => "sections/Standalone Line Endings"

  fun apply(h: TestHelper) ? =>
    let template = "|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|"
    let expected = "|\r\n|"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneWithoutPreviousLine is UnitTest
  fun name(): String => "sections/Standalone Without Previous Line"

  fun apply(h: TestHelper) ? =>
    let template = "  {{^boolean}}\n^{{/boolean}}\n/"
    let expected = "^\n/"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneWithoutNewline is UnitTest
  fun name(): String => "sections/Standalone Without Newline"

  fun apply(h: TestHelper) ? =>
    let template = "^{{^boolean}}\n/\n  {{/boolean}}"
    let expected = "^\n/\n"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestPadding is UnitTest
  fun name(): String => "sections/Padding"

  fun apply(h: TestHelper) ? =>
    let template = "|{{^ boolean }}={{/ boolean }}|"
    let expected = "|=|"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":false}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))
