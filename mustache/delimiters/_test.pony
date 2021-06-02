use "ponytest"
use "json"
use ".."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestPairBehavior)
    test(_TestSpecialCharacters)
    test(_TestSections)
    test(_TestInvertedSections)
    test(_TestPartialInheritence)
    test(_TestPostPartialBehavior)
    test(_TestSurroundingWhitespace)
    test(_TestOutlyingWhitespaceInline)
    test(_TestStandaloneTag)
    test(_TestIndentedStandaloneTag)
    test(_TestStandaloneLineEndings)
    test(_TestStandaloneWithoutPreviousLine)
    test(_TestStandaloneWithoutNewline)
    test(_TestPairwithPadding)

class iso _TestPairBehavior is UnitTest
  fun name(): String => "delimiters/Pair Behavior"

  fun apply(h: TestHelper) ? =>
    let template = "{{=<% %>=}}(<%text%>)"
    let expected = "(Hey!)"
    let data = (recover val
      JsonDoc.>parse("""{"text":"Hey!"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestSpecialCharacters is UnitTest
  fun name(): String => "delimiters/Special Characters"

  fun apply(h: TestHelper) ? =>
    let template = "({{=[ ]=}}[text])"
    let expected = "(It worked!)"
    let data = (recover val
      JsonDoc.>parse("""{"text":"It worked!"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestSections is UnitTest
  fun name(): String => "delimiters/Sections"

  fun apply(h: TestHelper) ? =>
    let template = "[\n{{#section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|#section|\n  {{data}}\n  |data|\n|/section|\n]\n"
    let expected = "[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n"
    let data = (recover val
      JsonDoc.>parse("""{"section":true,"data":"I got interpolated."}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestInvertedSections is UnitTest
  fun name(): String => "delimiters/Inverted Sections"

  fun apply(h: TestHelper) ? =>
    let template = "[\n{{^section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|^section|\n  {{data}}\n  |data|\n|/section|\n]\n"
    let expected = "[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n"
    let data = (recover val
      JsonDoc.>parse("""{"section":false,"data":"I got interpolated."}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestPartialInheritence is UnitTest
  fun name(): String => "delimiters/Partial Inheritence"

  fun apply(h: TestHelper) ? =>
    let template = "[ {{>include}} ]\n{{= | | =}}\n[ |>include| ]\n"
    let expected = "[ .yes. ]\n[ .yes. ]\n"
    let data = (recover val
      JsonDoc.>parse("""{"value":"yes"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestPostPartialBehavior is UnitTest
  fun name(): String => "delimiters/Post-Partial Behavior"

  fun apply(h: TestHelper) ? =>
    let template = "[ {{>include}} ]\n[ .{{value}}.  .|value|. ]\n"
    let expected = "[ .yes.  .yes. ]\n[ .yes.  .|value|. ]\n"
    let data = (recover val
      JsonDoc.>parse("""{"value":"yes"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestSurroundingWhitespace is UnitTest
  fun name(): String => "delimiters/Surrounding Whitespace"

  fun apply(h: TestHelper) ? =>
    let template = "| {{=@ @=}} |"
    let expected = "|  |"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestOutlyingWhitespaceInline is UnitTest
  fun name(): String => "delimiters/Outlying Whitespace (Inline)"

  fun apply(h: TestHelper) ? =>
    let template = " | {{=@ @=}}\n"
    let expected = " | \n"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneTag is UnitTest
  fun name(): String => "delimiters/Standalone Tag"

  fun apply(h: TestHelper) ? =>
    let template = "Begin.\n{{=@ @=}}\nEnd.\n"
    let expected = "Begin.\nEnd.\n"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestIndentedStandaloneTag is UnitTest
  fun name(): String => "delimiters/Indented Standalone Tag"

  fun apply(h: TestHelper) ? =>
    let template = "Begin.\n  {{=@ @=}}\nEnd.\n"
    let expected = "Begin.\nEnd.\n"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneLineEndings is UnitTest
  fun name(): String => "delimiters/Standalone Line Endings"

  fun apply(h: TestHelper) ? =>
    let template = "|\r\n{{= @ @ =}}\r\n|"
    let expected = "|\r\n|"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneWithoutPreviousLine is UnitTest
  fun name(): String => "delimiters/Standalone Without Previous Line"

  fun apply(h: TestHelper) ? =>
    let template = "  {{=@ @=}}\n="
    let expected = "="
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestStandaloneWithoutNewline is UnitTest
  fun name(): String => "delimiters/Standalone Without Newline"

  fun apply(h: TestHelper) ? =>
    let template = "=\n  {{=@ @=}}"
    let expected = "=\n"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestPairwithPadding is UnitTest
  fun name(): String => "delimiters/Pair with Padding"

  fun apply(h: TestHelper) ? =>
    let template = "|{{= @   @ =}}|"
    let expected = "||"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))
