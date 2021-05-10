use "collections/persistent"
use "debug"

// TODO: Add nesting support
type MustacheValue is String
type MustacheToken is (MustacheText | MustacheTag)

class val MustacheTag
  let _text: String
  new val create(inner: String) =>
    _text = inner.clone().>strip()

  fun render(bs: Map[String, MustacheValue] val): String =>
    bs.get_or_else(_text, "")

class val MustacheText
  let _text: String
  new val create(text: String) =>
    _text = text

  fun render(bs: Map[String, MustacheValue] val): String => _text

class val MustacheMap
// TODO: Make a list to parent context in MustacheMap
// TODO: 'expected bindings' for a given template?

class Mustache
  // TODO: Implement indentation sensitivity
  var _template: String = ""
  var _bindings: Map[String, MustacheValue]
  var _ast: Array[MustacheToken] = Array[MustacheToken]

  new create(t: String) =>
    _bindings = Map[String, MustacheValue]
    template(t)

  fun ref template(t: String) =>
    _template = t
    _ast = _parse(_template)

  fun ref bind(k: String, v: MustacheValue) =>
    _bindings = _bindings(k) = v

  fun ref bindings(bs: Map[String, MustacheValue] iso^) =>
    _bindings = bs

  fun render(): String iso^ =>
    let out = recover String(_template.size()) end

    // TODO: Return a ReadSeq
    for v in _ast.values() do
      out.append(v.render(_bindings))
    end
    consume out

  fun _parse(s: String): Array[MustacheToken] =>
    // The state of the lexical analyzer.is the set delimiter characters
    // Terminals: Text, OpenDelimiter, CloseDelimiter, SetDelimiter
    let open = "{{"
    let close = "}}"
    var setopen = _setopen(open)
    var setclose = _setclose(close)

    let out = recover Array[MustacheToken] end
    var i: ISize = 0
    var in_tag: Bool = false
    let len = _template.size().isize()
    while true do
      let tag_open = try s.find(open, i)? else len end
      if tag_open > i then
        out.push(MustacheText(s.trim(i.usize(), tag_open.usize())))
      end

      i = tag_open + open.size().isize()
      in_tag = true

      // If next character is '{' or '=',
      // handle set-delimiter change or triple-mustache accordingly
      (let tag_close: ISize, let d_tag_close: ISize) =
        match try s(i.usize() + 1)? else '\0' end
        // TODO: Add tag kind?
        | '{' =>
          (try s.find("}" + close, ISize(i))? else len end, 1)
        | '=' =>
          (try s.find("=" + close, ISize(i))? else len end, 1)
        // TODO: Add new tag types here
        else
          (try s.find(close, ISize(i))? else len end, 0)
        end

      if tag_close > i then
        out.push(MustacheTag(s.trim(i.usize(), tag_close.usize())))
      end
      i = tag_close + close.size().isize() + d_tag_close
      if i >= len then
        break
      end
    end

    if i < s.size().isize() then
      out.push(MustacheText(s.trim(i.usize())))
    end

    consume out

  fun _setopen(o: String): String =>
    recover
      String(o.size() + 1).>append(o).>push('=')
    end
  fun _setclose(c: String): String =>
    recover
      String(c.size() + 1).>push('=').>append(c)
    end
