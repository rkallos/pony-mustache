use "ponytest"
use "json"
use "../.."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestBasicBehavior)
    test(_TestFailedLookup)
    test(_TestContext)
    test(_TestRecursion)
    test(_TestSurroundingWhitespace)
    test(_TestInlineIndentation)
    test(_TestStandaloneLineEndings)
    test(_TestStandaloneWithoutPreviousLine)
    test(_TestStandaloneWithoutNewline)
    test(_TestStandaloneIndentation)
    test(_TestPaddingWhitespace)

class iso _TestBasicBehavior is UnitTest
  fun name(): String => "partials/Basic Behavior"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{>text}}\""
    let expected = "\"from partial\""
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestFailedLookup is UnitTest
  fun name(): String => "partials/Failed Lookup"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{>text}}\""
    let expected = "\"\""
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestContext is UnitTest
  fun name(): String => "partials/Context"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{>partial}}\""
    let expected = "\"*content*\""
    let data = (recover val
      JsonDoc.>parse("""{"text":"content"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestRecursion is UnitTest
  fun name(): String => "partials/Recursion"

  fun apply(h: TestHelper) ? =>
    let template = "{{>node}}"
    let expected = "X<Y<>>"
    let data = (recover val
      JsonDoc.>parse("""{"content":"X","nodes":[{"content":"Y","nodes":[]}]}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestSurroundingWhitespace is UnitTest
  fun name(): String => "partials/Surrounding Whitespace"

  fun apply(h: TestHelper) ? =>
    let template = "| {{>partial}} |"
    let expected = "| \t|\t |"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestInlineIndentation is UnitTest
  fun name(): String => "partials/Inline Indentation"

  fun apply(h: TestHelper) ? =>
    let template = "  {{data}}  {{> partial}}\n"
    let expected = "  |  >\n>\n"
    let data = (recover val
      JsonDoc.>parse("""{"data":"|"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneLineEndings is UnitTest
  fun name(): String => "partials/Standalone Line Endings"

  fun apply(h: TestHelper) ? =>
    let template = "|\r\n{{>partial}}\r\n|"
    let expected = "|\r\n>|"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneWithoutPreviousLine is UnitTest
  fun name(): String => "partials/Standalone Without Previous Line"

  fun apply(h: TestHelper) ? =>
    let template = "  {{>partial}}\n>"
    let expected = "  >\n  >>"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneWithoutNewline is UnitTest
  fun name(): String => "partials/Standalone Without Newline"

  fun apply(h: TestHelper) ? =>
    let template = ">\n  {{>partial}}"
    let expected = ">\n  >\n  >"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneIndentation is UnitTest
  fun name(): String => "partials/Standalone Indentation"

  fun apply(h: TestHelper) ? =>
    let template = "\\\n {{>partial}}\n/\n"
    let expected = "\\\n |\n <\n->\n |\n/\n"
    let data = (recover val
      JsonDoc.>parse("""{"content":"<\n->"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestPaddingWhitespace is UnitTest
  fun name(): String => "partials/Padding Whitespace"

  fun apply(h: TestHelper) ? =>
    let template = "|{{> partial }}|"
    let expected = "|[]|"
    let data = (recover val
      JsonDoc.>parse("""{"boolean":true}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))
