use "json"
use "collections"

interface Partials
  fun find_partial(name: String): Mustache val ?

class PartialsFromJson
  let _m: Map[String, Mustache val] = Map[String, Mustache val]

  new create(json: JsonType val) =>
    try
      let obj = json as JsonObject val
      for (name, value) in obj.data.pairs() do
        try
          _m(name) = recover val Mustache(value as String)? end
        end
      end
    end

  fun find_partial(name: String): Mustache val ? =>
    _m(name)?

class PartialsEmpty
  fun find_partial(name: String): Mustache val ? => error
