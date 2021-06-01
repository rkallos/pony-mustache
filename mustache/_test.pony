use "ponytest"

use "files"
use "json"

use comments = "comments"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    comments.Main.make().tests(test)
