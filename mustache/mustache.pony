use "collections"
use "regex"
use "json"

class Scope
  let data: List[JsonType val]

  new create(data': JsonType val) =>
    data = List[JsonType val].unit(data')

  fun ref find(key: String, default: JsonType val = None): JsonType val =>
    match key
    | "." =>
      try
        return data(0)?
      else
        return None
      end
    end

    let parts_it: Iterator[String] = key.split_by(".").values()
    let first: String =
      try
        parts_it.next()?
      else
        return None // should be unreachable
      end

    for scope in data.values() do
      match scope
      | let obj: JsonObject val =>
        if obj.data.contains(first) then
          // first part of dotted name matched, search inside, or return None
          try
            var inner: JsonType val = obj.data(first)?
            for part in parts_it do
              inner = (inner as JsonObject val).data(part)?
            end
            return inner
          else
            return None
          end
        else
          // look in next scope
          continue
        end
      else
        if parts_it.has_next() then
          // miss; key is not empty
          return None
        else
          // try next scope
          continue
        end
      end
    end

    // no scopes matched key
    None

interface Renderable
  fun render(r: Renderer): Renderer
  fun print_token(indent: String = ""): String

class Renderer
  let _scopes: Scope
  let _partials: Partials val
  // TODO: Use ByteSeq
  var _out: String iso = recover String(65535) end
  var padding: String = ""

  new create(data: JsonType val, partials: Partials iso) =>
    _scopes = Scope(data)
    _partials = consume partials

  fun ref find(key: String): JsonType val => _scopes.find(key)
  fun ref shift()? => _scopes.data.shift()?
  fun ref unshift(v: JsonType val) => _scopes.data.unshift(v)
  fun ref append_without_padding(s: String) => _out.append(s)
  fun ref append(s: String) =>
    if padding.size() == 0 then
      _out.append(s)
      return
    end

    var i: USize = 0
    try
      while i <= s.size() do
        let nl = s.find("\n", i.isize())?.usize() + 1
        _out.append(s.trim(i, nl))
        _out.append(padding)
        i = nl
      end
    else
      _out.append(s.trim(i.usize()))
    end
  fun ref push_utf32(c: U32) => _out.push_utf32(c)
  fun ref string(): String iso^ => _out = recover String end
  fun ref render_partial(name: String): Renderer =>
    try
      _partials.find_partial(name)?.render_with(this)
    else
      this
    end
  fun ref set_padding(new_padding: String): String =>
    padding = new_padding
  fun ref backtrack_to_newline() =>
    var i = _out.size()-1
    try
      while _out(i)? == 0x20 do
        i = i-1
      end
    end
    _out.trim_in_place(0, i+1)

class Variable is Renderable
  let fetch: String
  let escape: Bool

  new create(fetch': String, escape': Bool = true) =>
    fetch = fetch'
    escape = escape'

  fun render(r: Renderer): Renderer =>
    match r.find(fetch)
    | None => None
    | let n: (F64 | I64) =>
      r.append_without_padding(n.string())
    | let n: I64 =>
      r.append_without_padding(n.string())
    | let s: String =>
      if escape then
        for c in s.runes() do
          match c
          | '&' => r.append("&amp;")
          | 0x22 => r.append("&quot;")
          | '<' => r.append("&lt;")
          | '>' => r.append("&gt;")
          else
            r.push_utf32(c)
          end
        end
      else
        r.append_without_padding(s)
      end
    end
    consume r

  fun print_token(indent: String = ""): String =>
    let name =
      if escape then
        "EscapedVariable"
      else
        "Variable"
      end
    recover
      String()
      .>append(indent)
      .>append(name)
      .>push('(')
      .>append(fetch)
      .>push(')')
    end

class Block is Renderable
  let elts: Array[Renderable] = Array[Renderable]

  fun ref push(elt: Renderable) => elts.push(elt)

  fun render(r: Renderer): Renderer =>
    var r' = consume r
    for elt in elts.values() do
      r' = elt.render(consume r')
    end
    consume r'

  fun print_token(indent: String = ""): String =>
    let out = recover String end
    out.append(indent)
    out.append("Block(\n")
    for elt in elts.values() do
      out.append(elt.print_token(indent + "  "))
      out.push('\n')
    end
    out.append(indent)
    out.append(")\n")
    consume out

class Section is Renderable
  let fetch: String
  let invert: Bool
  let elts: Block

  new create(fetch': String, elts': Block, invert': Bool = false) =>
    fetch = fetch'
    elts = elts'
    invert = invert'

  fun ref push(elt: Renderable) =>
    elts.push(elt)

  fun render(r: Renderer): Renderer =>
    let maybe_scope: JsonType val = r.find(fetch)
    r.unshift(maybe_scope)
    let res = match maybe_scope
    | None =>
      if invert then
        render_elements(consume r)
      else
        consume r
      end
    | false =>
      if invert then
        render_elements(consume r)
      else
        consume r
      end
    | let a: JsonArray val =>
      if a.data.size() == 0 then
        if invert then
          render_elements(consume r)
        else
          consume r
        end
      else
        if invert then
          consume r
        else
          var r2 = consume r
          for scope in a.data.values() do
            r2.unshift(scope)
            r2 = render_elements(consume r2)
            try r2.shift()? end
          end
          consume r2
        end
      end
    else
      if invert then
        consume r
      else
        render_elements(consume r)
      end
    end
    try res.shift()? end
    consume res

  fun render_elements(r: Renderer): Renderer =>
    var r' = consume r
    for elt in elts.elts.values() do
      r' = elt.render(consume r')
    end
    consume r'

  fun print_token(indent: String = ""): String =>
    let name =
      if invert then
        "InvertedSection"
      else
        "Section"
      end
    let printed_elts = elts.print_token(indent + "  ")
    recover
      String(indent.size() + name.size() + 1 + fetch.size() + 2 +
        printed_elts.size() + indent.size() + 1)
      .>append(indent)
      .>append(name)
      .>push('(')
      .>append(fetch)
      .>push(')')
      .>push('\n')
      .>append(printed_elts)
      .>append(indent)
      .>push(')')
    end

class Text is Renderable
  let _text: String

  new create(text: String) =>
    _text = text

  fun render(r: Renderer): Renderer =>
    r.append(_text)
    consume r

  fun print_token(indent: String = ""): String =>
    let text =
      try
        Regex("\n")?.replace[String iso](_text.clone(), "\\n", 0, true)?
      else
        _text
      end
    let name = "Text"
    recover
      String(indent.size() + name.size() + 2 + text.size() + 2)
      .>append(indent)
      .>append(name)
      .>append("(\"")
      .>append(text)
      .>append("\")")
    end

class Partial
  let fetch: String
  let padding: String

  new create(fetch': String, padding': String) =>
    fetch = fetch'
    padding = padding'

  fun render(r: Renderer): Renderer =>
    let old_padding = r.set_padding(padding)
    r.append(padding)
    r.render_partial(fetch)
    r.backtrack_to_newline()
    r.>set_padding(old_padding)

  fun print_token(indent: String = ""): String =>
    recover
      String()
      .>append(indent)
      .>append("Partial")
      .>push('(')
      .>append(fetch)
      .>push(')')
    end

class Mustache
  // TODO: Improve error reporting
  let _template: String
  let _ast: Block

  new create(t: String) ? =>
    _template = t
    let parser =
      try
        _Parser(_template)?
      else
        //err = "error constructing parser"
        error
      end

    _ast =
      try
        parser()?
      else
        //err = parser.err
        error
      end

  fun render(data: JsonType val, partials: Partials iso = PartialsEmpty): String iso^ =>
    // TODO: Return a ByteSeq
    render_with(recover Renderer(data, consume partials) end).string()

  fun render_with(r: Renderer): Renderer =>
    _ast.render(consume r)

  fun print_tokens(): String =>
    _ast.print_token()
