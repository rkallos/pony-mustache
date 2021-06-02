use "ponytest"

use "files"
use "json"

use comments = "tests/comments"
use delimiters = "tests/delimiters"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    comments.Main.make().tests(test)
    delimiters.Main.make().tests(test)
