use "ponytest"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

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
