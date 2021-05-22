use "collections/persistent"
use "regex"

// TODO: Add nesting support
type MustacheBindings is Map[String, MustacheValue]
type MustacheValue is String

interface Renderable
  //fun render(bs: Map[String, MustacheValue]): String
  fun print_token(indent: String = ""): String

class MustacheVariable is Renderable
  let fetch: String
  let escape: Bool

  new create(fetch': String, escape': Bool = false) =>
    fetch = fetch'
    escape = escape'

  fun render(bs: Map[String, MustacheValue] val): String =>
    bs.get_or_else(fetch, "")

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

  fun print_token(indent: String = ""): String =>
    let name =
      if invert then
        "MustacheInvertedSection"
      else
        "MustacheSection"
      end
    let printed_elts = elts.print_token(indent + "  ")
    recover
      String()
      .>append(indent)
      .>append(name)
      .>push('(')
      .>append(fetch)
      .>push(')')
      .>push('\n')
      .>append(printed_elts)
      .>append(indent)
      .>append(")")
    end

class MustacheText is Renderable
  let _text: String

  new create(text: String) =>
    _text = text

  fun render(bs: Map[String, MustacheValue] val): String => _text

  fun print_token(indent: String = ""): String =>
    let text =
      try
        Regex("\n")?.replace[String iso](_text.clone(), "\\n", 0, true)?
      else
        _text
      end
    recover
      String()
      .>append(indent)
      .>append("MustacheText(\"")
      .>append(text)
      .>append("\")")
    end

class val MustacheMap
// TODO: Make a list to parent context in MustacheMap
// TODO: 'expected bindings' for a given template?

class Mustache
  // TODO: Implement indentation sensitivity
  var _template: String = ""
  var _bindings: Map[String, MustacheValue] = Map[String, MustacheValue]
  var _ast: MustacheBlock = MustacheBlock
  var err: String = ""

  fun ref template(t: String): None ? =>
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

  fun ref bind(k: String, v: MustacheValue) =>
    _bindings = _bindings(k) = v

  fun ref bindings(bs: Map[String, MustacheValue] iso^) =>
    _bindings = bs

  fun render(): String iso^ =>
    let out = recover String(_template.size()) end

    // TODO: Return a ReadSeq
    // for v in _ast.elts.values() do
    //   out.append(v.render(_bindings))
    // end
    consume out

  fun print_tokens(): String =>
    _ast.print_token()

  fun _parse(s: String): MustacheBlock ? =>
    _Parser(s)?.apply()?
