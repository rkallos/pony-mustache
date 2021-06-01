use "ponytest"
use "json"
use ".."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestInline)
    test(_TestMultiline)
    test(_TestStandalone)
    test(_TestIndentedStandalone)
    test(_TestStandaloneLineEndings)
    test(_TestStandaloneWithoutPreviousLine)
    test(_TestStandaloneWithoutNewline)
    test(_TestMultilineStandalone)
    test(_TestIndentedMultilineStandalone)
    test(_TestIndentedInline)
    test(_TestSurroundingWhitespace)

class iso _TestInline is UnitTest
  fun name(): String => "comments/Inline"

  fun apply(h: TestHelper) ? =>
    let template = "12345{{! Comment Block! }}67890"
    let expected = "1234567890"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestMultiline is UnitTest
  fun name(): String => "comments/Multiline"

  fun apply(h: TestHelper) ? =>
    let template = "12345{{!\n  This is a\n  multi-line comment...\n}}67890\n"
    let expected = "1234567890\n"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandalone is UnitTest
  fun name(): String => "comments/Standalone"

  fun apply(h: TestHelper) ? =>
    let template = "Begin.\n{{! Comment Block! }}\nEnd.\n"
    let expected = "Begin.\nEnd.\n"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestIndentedStandalone is UnitTest
  fun name(): String => "comments/Indented Standalone"

  fun apply(h: TestHelper) ? =>
    let template = "Begin.\n  {{! Indented Comment Block! }}\nEnd.\n"
    let expected = "Begin.\nEnd.\n"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneLineEndings is UnitTest
  fun name(): String => "comments/Standalone Line Endings"

  fun apply(h: TestHelper) ? =>
    let template = "|\r\n{{! Standalone Comment }}\r\n|"
    let expected = "|\r\n|"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneWithoutPreviousLine is UnitTest
  fun name(): String => "comments/Standalone Without Previous Line"

  fun apply(h: TestHelper) ? =>
    let template = "  {{! I'm Still Standalone }}\n!"
    let expected = "!"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneWithoutNewline is UnitTest
  fun name(): String => "comments/Standalone Without Newline"

  fun apply(h: TestHelper) ? =>
    let template = "!\n  {{! I'm Still Standalone }}"
    let expected = "!\n"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestMultilineStandalone is UnitTest
  fun name(): String => "comments/Multiline Standalone"

  fun apply(h: TestHelper) ? =>
    let template = "Begin.\n{{!\nSomething's going on here...\n}}\nEnd.\n"
    let expected = "Begin.\nEnd.\n"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestIndentedMultilineStandalone is UnitTest
  fun name(): String => "comments/Indented Multiline Standalone"

  fun apply(h: TestHelper) ? =>
    let template = "Begin.\n  {{!\n    Something's going on here...\n  }}\nEnd.\n"
    let expected = "Begin.\nEnd.\n"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestIndentedInline is UnitTest
  fun name(): String => "comments/Indented Inline"

  fun apply(h: TestHelper) ? =>
    let template = "  12 {{! 34 }}\n"
    let expected = "  12 \n"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestSurroundingWhitespace is UnitTest
  fun name(): String => "comments/Surrounding Whitespace"

  fun apply(h: TestHelper) ? =>
    let template = "12345 {{! Comment Block! }} 67890"
    let expected = "12345  67890"
    let data = recover val JsonObject end

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))
