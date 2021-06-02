use "ponytest"

use "files"
use "json"

use comments = "tests/comments"
use delimiters = "tests/delimiters"
use interpolation = "tests/interpolation"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    comments.Main.make().tests(test)
    delimiters.Main.make().tests(test)
    interpolation.Main.make().tests(test)
