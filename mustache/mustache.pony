use "collections"
use "regex"
use "json"

class MustacheScope
  let data: List[JsonType val]

  new create(data': JsonType val) =>
    data = List[JsonType val].unit(data')

  fun ref find(key: String, default: JsonType val = None): JsonType val =>
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
          continue
        else
          return scope
        end
      end
    end

    // no scopes matched key
    None

interface Renderable
  fun render(out: String iso, scopes: MustacheScope): String iso^
  fun print_token(indent: String = ""): String

class MustacheVariable is Renderable
  let fetch: String
  let escape: Bool

  new create(fetch': String, escape': Bool = true) =>
    fetch = fetch'
    escape = escape'

  fun render(out: String iso, scope: MustacheScope): String iso^ =>
    match scope.find(fetch)
    | None => None
    | let n: (F64 | I64) =>
      out.append(n.string())
    | let n: I64 =>
      out.append(n.string())
    | let s: String =>
      if escape then
        for c in s.runes() do
          match c
          | '&' => out.append("&amp;")
          | 0x22 => out.append("&quot;")
          | '<' => out.append("&lt;")
          | '>' => out.append("&gt;")
          else
            out.push_utf32(c)
          end
        end
      else
        out.append(s)
      end
    end
    consume out

  fun print_token(indent: String = ""): String =>
    let name =
      if escape then
        "MustacheEscapedVariable"
      else
        "MustacheVariable"
      end
    recover
      String()
      .>append(indent)
      .>append(name)
      .>push('(')
      .>append(fetch)
      .>push(')')
    end

class MustacheBlock is Renderable
  let elts: Array[Renderable] = Array[Renderable]

  fun ref push(elt: Renderable) => elts.push(elt)

  fun render(out: String iso, scope: MustacheScope): String iso^ =>
    for elt in elts.values() do
      out.append(elt.render(recover String end, scope))
    end
    consume out

  fun print_token(indent: String = ""): String =>
    let out = recover String end
    out.append(indent)
    out.append("MustacheBlock(\n")
    for elt in elts.values() do
      out.append(elt.print_token(indent + "  "))
      out.push('\n')
    end
    out.append(indent)
    out.append(")\n")
    consume out

class MustacheSection is Renderable
  let fetch: String
  let invert: Bool
  let elts: MustacheBlock

  new create(fetch': String, elts': MustacheBlock, invert': Bool = false) =>
    fetch = fetch'
    elts = elts'
    invert = invert'

  fun ref push(elt: Renderable) =>
    elts.push(elt)

  fun render(out: String iso, scope: MustacheScope): String iso^ =>
    let maybe_scope: JsonType val = scope.find(fetch)
    scope.data.unshift(maybe_scope)
    let res = match maybe_scope
    | None =>
      if invert then
        render_elements(consume out, scope)
      else
        consume out
      end
    | false =>
      if invert then
        render_elements(consume out, scope)
      else
        consume out
      end
    | let a: JsonArray val =>
      if a.data.size() == 0 then
        if invert then
          render_elements(consume out, scope)
        else
          consume out
        end
      else
        if invert then
          consume out
        else
          render_elements(consume out, scope)
        end
      end
    else
      if invert then
        consume out
      else
        render_elements(consume out, scope)
      end
    end
    try scope.data.shift()? end
    consume res

  fun render_elements(out: String iso, scope: MustacheScope): String iso^ =>
    for elt in elts.elts.values() do
      out.append(elt.render(recover String end, scope))
    end
    consume out

  fun print_token(indent: String = ""): String =>
    let name =
      if invert then
        "MustacheInvertedSection"
      else
        "MustacheSection"
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

class MustacheText is Renderable
  let _text: String

  new create(text: String) =>
    _text = text

  fun render(out: String iso, scope: MustacheScope): String iso^ =>
    out.append(_text)
    consume out

  fun print_token(indent: String = ""): String =>
    let text =
      try
        Regex("\n")?.replace[String iso](_text.clone(), "\\n", 0, true)?
      else
        _text
      end
    let name = "MustacheText"
    recover
      String(indent.size() + name.size() + 2 + text.size() + 2)
      .>append(indent)
      .>append(name)
      .>append("(\"")
      .>append(text)
      .>append("\")")
    end

class Mustache
  // TODO: Implement indentation sensitivity
  let _template: String
  let _ast: MustacheBlock
  var err: String = ""

  new create(t: String) ? =>
    _template = t
    let parser =
      try
        _Parser(_template)?
      else
        err = "error constructing parser"
        error
      end

    _ast =
      try
        parser()?
      else
        err = parser.err
        error
      end

  fun render(data: JsonType val): String iso^ =>
    let scopes = MustacheScope(data)
    // TODO: Return a ReadSeq
    _ast.render(recover String(65535) end, scopes)

  fun print_tokens(): String =>
    _ast.print_token()
