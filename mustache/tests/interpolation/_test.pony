use "ponytest"
use "json"
use "../.."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestNoInterpolation)
    test(_TestBasicInterpolation)
    test(_TestHTMLEscaping)
    test(_TestTripleMustache)
    test(_TestAmpersand)
    test(_TestBasicIntegerInterpolation)
    test(_TestTripleMustacheIntegerInterpolation)
    test(_TestAmpersandIntegerInterpolation)
    test(_TestBasicDecimalInterpolation)
    test(_TestTripleMustacheDecimalInterpolation)
    test(_TestAmpersandDecimalInterpolation)
    test(_TestBasicNullInterpolation)
    test(_TestTripleMustacheNullInterpolation)
    test(_TestAmpersandNullInterpolation)
    test(_TestBasicContextMissInterpolation)
    test(_TestTripleMustacheContextMissInterpolation)
    test(_TestAmpersandContextMissInterpolation)
    test(_TestDottedNamesBasicInterpolation)
    test(_TestDottedNamesTripleMustacheInterpolation)
    test(_TestDottedNamesAmpersandInterpolation)
    test(_TestDottedNamesArbitraryDepth)
    test(_TestDottedNamesBrokenChains)
    test(_TestDottedNamesBrokenChainResolution)
    test(_TestDottedNamesInitialResolution)
    test(_TestDottedNamesContextPrecedence)
    test(_TestImplicitIteratorsBasicInterpolation)
    test(_TestImplicitIteratorsHTMLEscaping)
    test(_TestImplicitIteratorsTripleMustache)
    test(_TestImplicitIteratorsAmpersand)
    test(_TestImplicitIteratorsBasicIntegerInterpolation)
    test(_TestInterpolationSurroundingWhitespace)
    test(_TestTripleMustacheSurroundingWhitespace)
    test(_TestAmpersandSurroundingWhitespace)
    test(_TestInterpolationStandalone)
    test(_TestTripleMustacheStandalone)
    test(_TestAmpersandStandalone)
    test(_TestInterpolationWithPadding)
    test(_TestTripleMustacheWithPadding)
    test(_TestAmpersandWithPadding)

class iso _TestNoInterpolation is UnitTest
  fun name(): String => "interpolation/No Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "Hello from {Mustache}!\n"
    let expected = "Hello from {Mustache}!\n"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestBasicInterpolation is UnitTest
  fun name(): String => "interpolation/Basic Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "Hello, {{subject}}!\n"
    let expected = "Hello, world!\n"
    let data = (recover val
      JsonDoc.>parse("""{"subject":"world"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestHTMLEscaping is UnitTest
  fun name(): String => "interpolation/HTML Escaping"

  fun apply(h: TestHelper) ? =>
    let template = "These characters should be HTML escaped: {{forbidden}}\n"
    let expected = "These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n"
    let data = (recover val
      JsonDoc.>parse("""{"forbidden":"& \" < >"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestTripleMustache is UnitTest
  fun name(): String => "interpolation/Triple Mustache"

  fun apply(h: TestHelper) ? =>
    let template = "These characters should not be HTML escaped: {{{forbidden}}}\n"
    let expected = "These characters should not be HTML escaped: & \" < >\n"
    let data = (recover val
      JsonDoc.>parse("""{"forbidden":"& \" < >"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestAmpersand is UnitTest
  fun name(): String => "interpolation/Ampersand"

  fun apply(h: TestHelper) ? =>
    let template = "These characters should not be HTML escaped: {{&forbidden}}\n"
    let expected = "These characters should not be HTML escaped: & \" < >\n"
    let data = (recover val
      JsonDoc.>parse("""{"forbidden":"& \" < >"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestBasicIntegerInterpolation is UnitTest
  fun name(): String => "interpolation/Basic Integer Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{mph}} miles an hour!\""
    let expected = "\"85 miles an hour!\""
    let data = (recover val
      JsonDoc.>parse("""{"mph":85}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestTripleMustacheIntegerInterpolation is UnitTest
  fun name(): String => "interpolation/Triple Mustache Integer Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{{mph}}} miles an hour!\""
    let expected = "\"85 miles an hour!\""
    let data = (recover val
      JsonDoc.>parse("""{"mph":85}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestAmpersandIntegerInterpolation is UnitTest
  fun name(): String => "interpolation/Ampersand Integer Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{&mph}} miles an hour!\""
    let expected = "\"85 miles an hour!\""
    let data = (recover val
      JsonDoc.>parse("""{"mph":85}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestBasicDecimalInterpolation is UnitTest
  fun name(): String => "interpolation/Basic Decimal Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{power}} jiggawatts!\""
    let expected = "\"1.21 jiggawatts!\""
    let data = (recover val
      JsonDoc.>parse("""{"power":1.21}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestTripleMustacheDecimalInterpolation is UnitTest
  fun name(): String => "interpolation/Triple Mustache Decimal Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{{power}}} jiggawatts!\""
    let expected = "\"1.21 jiggawatts!\""
    let data = (recover val
      JsonDoc.>parse("""{"power":1.21}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestAmpersandDecimalInterpolation is UnitTest
  fun name(): String => "interpolation/Ampersand Decimal Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{&power}} jiggawatts!\""
    let expected = "\"1.21 jiggawatts!\""
    let data = (recover val
      JsonDoc.>parse("""{"power":1.21}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestBasicNullInterpolation is UnitTest
  fun name(): String => "interpolation/Basic Null Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "I ({{cannot}}) be seen!"
    let expected = "I () be seen!"
    let data = (recover val
      JsonDoc.>parse("""{"cannot":null}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestTripleMustacheNullInterpolation is UnitTest
  fun name(): String => "interpolation/Triple Mustache Null Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "I ({{{cannot}}}) be seen!"
    let expected = "I () be seen!"
    let data = (recover val
      JsonDoc.>parse("""{"cannot":null}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestAmpersandNullInterpolation is UnitTest
  fun name(): String => "interpolation/Ampersand Null Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "I ({{&cannot}}) be seen!"
    let expected = "I () be seen!"
    let data = (recover val
      JsonDoc.>parse("""{"cannot":null}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestBasicContextMissInterpolation is UnitTest
  fun name(): String => "interpolation/Basic Context Miss Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "I ({{cannot}}) be seen!"
    let expected = "I () be seen!"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestTripleMustacheContextMissInterpolation is UnitTest
  fun name(): String => "interpolation/Triple Mustache Context Miss Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "I ({{{cannot}}}) be seen!"
    let expected = "I () be seen!"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestAmpersandContextMissInterpolation is UnitTest
  fun name(): String => "interpolation/Ampersand Context Miss Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "I ({{&cannot}}) be seen!"
    let expected = "I () be seen!"
    let data = (recover val
      JsonDoc.>parse("""{}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesBasicInterpolation is UnitTest
  fun name(): String => "interpolation/Dotted Names - Basic Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{person.name}}\" == \"{{#person}}{{name}}{{/person}}\""
    let expected = "\"Joe\" == \"Joe\""
    let data = (recover val
      JsonDoc.>parse("""{"person":{"name":"Joe"}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesTripleMustacheInterpolation is UnitTest
  fun name(): String => "interpolation/Dotted Names - Triple Mustache Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{{person.name}}}\" == \"{{#person}}{{{name}}}{{/person}}\""
    let expected = "\"Joe\" == \"Joe\""
    let data = (recover val
      JsonDoc.>parse("""{"person":{"name":"Joe"}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesAmpersandInterpolation is UnitTest
  fun name(): String => "interpolation/Dotted Names - Ampersand Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{&person.name}}\" == \"{{#person}}{{&name}}{{/person}}\""
    let expected = "\"Joe\" == \"Joe\""
    let data = (recover val
      JsonDoc.>parse("""{"person":{"name":"Joe"}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesArbitraryDepth is UnitTest
  fun name(): String => "interpolation/Dotted Names - Arbitrary Depth"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{a.b.c.d.e.name}}\" == \"Phil\""
    let expected = "\"Phil\" == \"Phil\""
    let data = (recover val
      JsonDoc.>parse("""{"a":{"b":{"c":{"d":{"e":{"name":"Phil"}}}}}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesBrokenChains is UnitTest
  fun name(): String => "interpolation/Dotted Names - Broken Chains"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{a.b.c}}\" == \"\""
    let expected = "\"\" == \"\""
    let data = (recover val
      JsonDoc.>parse("""{"a":{}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesBrokenChainResolution is UnitTest
  fun name(): String => "interpolation/Dotted Names - Broken Chain Resolution"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{a.b.c.name}}\" == \"\""
    let expected = "\"\" == \"\""
    let data = (recover val
      JsonDoc.>parse("""{"a":{"b":{}},"c":{"name":"Jim"}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesInitialResolution is UnitTest
  fun name(): String => "interpolation/Dotted Names - Initial Resolution"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{#a}}{{b.c.d.e.name}}{{/a}}\" == \"Phil\""
    let expected = "\"Phil\" == \"Phil\""
    let data = (recover val
      JsonDoc.>parse("""{"a":{"b":{"c":{"d":{"e":{"name":"Phil"}}}}},"b":{"c":{"d":{"e":{"name":"Wrong"}}}}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestDottedNamesContextPrecedence is UnitTest
  fun name(): String => "interpolation/Dotted Names - Context Precedence"

  fun apply(h: TestHelper) ? =>
    let template = "{{#a}}{{b.c}}{{/a}}"
    let expected = ""
    let data = (recover val
      JsonDoc.>parse("""{"a":{"b":{}},"b":{"c":"ERROR"}}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestImplicitIteratorsBasicInterpolation is UnitTest
  fun name(): String => "interpolation/Implicit Iterators - Basic Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "Hello, {{.}}!\n"
    let expected = "Hello, world!\n"
    let data = (recover val
      JsonDoc.>parse(""""world"""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestImplicitIteratorsHTMLEscaping is UnitTest
  fun name(): String => "interpolation/Implicit Iterators - HTML Escaping"

  fun apply(h: TestHelper) ? =>
    let template = "These characters should be HTML escaped: {{.}}\n"
    let expected = "These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n"
    let data = (recover val
      JsonDoc.>parse(""""& \" < >"""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestImplicitIteratorsTripleMustache is UnitTest
  fun name(): String => "interpolation/Implicit Iterators - Triple Mustache"

  fun apply(h: TestHelper) ? =>
    let template = "These characters should not be HTML escaped: {{{.}}}\n"
    let expected = "These characters should not be HTML escaped: & \" < >\n"
    let data = (recover val
      JsonDoc.>parse(""""& \" < >"""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestImplicitIteratorsAmpersand is UnitTest
  fun name(): String => "interpolation/Implicit Iterators - Ampersand"

  fun apply(h: TestHelper) ? =>
    let template = "These characters should not be HTML escaped: {{&.}}\n"
    let expected = "These characters should not be HTML escaped: & \" < >\n"
    let data = (recover val
      JsonDoc.>parse(""""& \" < >"""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestImplicitIteratorsBasicIntegerInterpolation is UnitTest
  fun name(): String => "interpolation/Implicit Iterators - Basic Integer Interpolation"

  fun apply(h: TestHelper) ? =>
    let template = "\"{{.}} miles an hour!\""
    let expected = "\"85 miles an hour!\""
    let data = (recover val
      JsonDoc.>parse("""85""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestInterpolationSurroundingWhitespace is UnitTest
  fun name(): String => "interpolation/Interpolation - Surrounding Whitespace"

  fun apply(h: TestHelper) ? =>
    let template = "| {{string}} |"
    let expected = "| --- |"
    let data = (recover val
      JsonDoc.>parse("""{"string":"---"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestTripleMustacheSurroundingWhitespace is UnitTest
  fun name(): String => "interpolation/Triple Mustache - Surrounding Whitespace"

  fun apply(h: TestHelper) ? =>
    let template = "| {{{string}}} |"
    let expected = "| --- |"
    let data = (recover val
      JsonDoc.>parse("""{"string":"---"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestAmpersandSurroundingWhitespace is UnitTest
  fun name(): String => "interpolation/Ampersand - Surrounding Whitespace"

  fun apply(h: TestHelper) ? =>
    let template = "| {{&string}} |"
    let expected = "| --- |"
    let data = (recover val
      JsonDoc.>parse("""{"string":"---"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestInterpolationStandalone is UnitTest
  fun name(): String => "interpolation/Interpolation - Standalone"

  fun apply(h: TestHelper) ? =>
    let template = "  {{string}}\n"
    let expected = "  ---\n"
    let data = (recover val
      JsonDoc.>parse("""{"string":"---"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestTripleMustacheStandalone is UnitTest
  fun name(): String => "interpolation/Triple Mustache - Standalone"

  fun apply(h: TestHelper) ? =>
    let template = "  {{{string}}}\n"
    let expected = "  ---\n"
    let data = (recover val
      JsonDoc.>parse("""{"string":"---"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestAmpersandStandalone is UnitTest
  fun name(): String => "interpolation/Ampersand - Standalone"

  fun apply(h: TestHelper) ? =>
    let template = "  {{&string}}\n"
    let expected = "  ---\n"
    let data = (recover val
      JsonDoc.>parse("""{"string":"---"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestInterpolationWithPadding is UnitTest
  fun name(): String => "interpolation/Interpolation With Padding"

  fun apply(h: TestHelper) ? =>
    let template = "|{{ string }}|"
    let expected = "|---|"
    let data = (recover val
      JsonDoc.>parse("""{"string":"---"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestTripleMustacheWithPadding is UnitTest
  fun name(): String => "interpolation/Triple Mustache With Padding"

  fun apply(h: TestHelper) ? =>
    let template = "|{{{ string }}}|"
    let expected = "|---|"
    let data = (recover val
      JsonDoc.>parse("""{"string":"---"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))

class iso _TestAmpersandWithPadding is UnitTest
  fun name(): String => "interpolation/Ampersand With Padding"

  fun apply(h: TestHelper) ? =>
    let template = "|{{& string }}|"
    let expected = "|---|"
    let data = (recover val
      JsonDoc.>parse("""{"string":"---"}""")?
    end).data

    let m = Mustache(template)?
    h.log(m.print_tokens())

    h.assert_eq[String](expected, m.render(data))
