use "regex"

class _Parser
  var otag_pat: String = "([ \t]*)?{{"
  var ctag_pat: String = "}}"

  var otag_regex: Regex
  var ctag_regex: Regex

  let allowed_in_tags: Regex
  let whitespace: Regex
  let skip_whitespace: Regex
  let valid_tag_types: Regex

  var elts: Block ref^ = Block
  let sections: Array[(String, ISize, Block)] =
    Array[(String, ISize, Block)]

  let scanner: _Scanner
  var err: String = ""

  new create(str: String) ? =>
    scanner = _Scanner(str)

    otag_regex = Regex(otag_pat)?
    ctag_regex = Regex(ctag_pat)?

    allowed_in_tags = Regex("(\\w|[?!\\/.-])*")?
    whitespace = Regex("\\s+")?
    skip_whitespace = Regex("[#^/<>=!]")?
    valid_tag_types = Regex("[#^/<>=!&{]")?

  fun ref apply(): Block ? =>
    repeat
      scan_tags()?
      scan_text()
    until
      scanner.is_eos()
    end
    elts

  // Reads until a tag-open. If there is preceding whitespace
  // before the tag-open, it will match that as well.
  fun ref scan_text() =>
    var text = scanner.scan_until(otag_pat)

    if text.size() > 0 then
      elts.push(Text(text))
    end

  fun ref scan_tags()? =>
    // find otag, possibly setting aside preceding whitespace
    let at_line_start = scanner.is_beginning_of_line()

    // consume otag
    if scanner.scan(otag_regex).size() == 0 then
      return
    end

    var padding = scanner(1)
    if not at_line_start and (padding.size() > 0) then
      elts.push(Text(padding))
      padding = ""
    end

    // consume tag kind
    let kind = scanner.scan(valid_tag_types)

    // consume whitespace
    scanner.scan(whitespace)
    // consume tag content
    let contents = tag_contents(kind)
    if contents.size() == 0 then
      err = "Illegal content in tag"
      error
    end

    // consume whitespace
    scanner.scan(whitespace)

    // consume pre-ctag, if applicable
    match kind
    | "=" => scanner.skip("=")
    | "{" => scanner.skip("}")
    end

    // consume ctag
    let close = scanner.scan(ctag_regex)
    if close.size() == 0 then
      err = "Malformed tag"
      error
    end

    // add whitespace preceding tag if \w in rest of line
    if at_line_start and not scanner.is_eos() then
      if scanner.match_peek("\r?\n") and (skip_whitespace == kind) then
        scanner.skip("\r?\n")
      else
        if padding.size() > 0 then
          elts.push(Text(padding))
        end
      end
    end

    // parse tag
    parse_tag(kind, contents, padding)?

  fun ref tag_contents(kind: String): String =>
    let pos = scanner.pos
    match kind
    | "!" => scanner.scan_until(ctag_pat)
    | "=" =>
      scanner.scan_until("=" + ctag_pat)
    else
      scanner.scan(allowed_in_tags)
    end

  fun ref set_tag_regexes(ot': String, ct': String) ? =>
    let ot = escape_pcre_metachars(ot')
    let ct = escape_pcre_metachars(ct')

    let new_otag_pat: String = "([ \t]*)?" + ot
    let new_otag_regex = Regex(new_otag_pat)?

    let new_ctag_regex = Regex(ct)?

    otag_pat = new_otag_pat
    ctag_pat = ct

    otag_regex = new_otag_regex
    ctag_regex = new_ctag_regex

  fun ref parse_tag(kind: String, contents: String, padding: String) ? =>
    match kind
    | "!" => None
    |  "" => parse_variable(contents, true)
    | "&" => parse_variable(contents, false)
    | "{" => parse_variable(contents, false)
    | "#" => parse_section_open(contents)
    | "/" => parse_section_close(contents)?
    | "^" => parse_inverted_section_open(contents)
    | "=" => parse_tag_delimiter_change(contents)?
    | ">" => parse_partial_open(contents, padding)
    | "<" => parse_partial_open(contents, padding)
    else
      err = "Unknown tag type: " + kind
      error
    end

  fun ref parse_variable(contents: String, escape: Bool = false) =>
    elts.push(Variable(contents, escape))

  fun ref parse_section_open(contents: String) =>
    let new_elts: Block = Block
    elts.push(Section(contents, new_elts))
    sections.push((contents, scanner.pos, elts))
    elts = new_elts

  fun ref parse_inverted_section_open(contents: String) =>
    let new_elts: Block = Block
    elts.push(Section(contents, new_elts, true))
    sections.push((contents, scanner.pos, elts))
    elts = new_elts

  fun ref parse_section_close(contents: String) ? =>
    (let section, let pos, let old_elts) =
      try
        sections.pop()?
      else
        err = "Closing unopened section: " + contents
        error
      end
    elts = old_elts
    if section != contents then
      err = "Unclosed section: " + section
      error
    end

  fun ref parse_tag_delimiter_change(contents: String) ? =>
    let split = recover ref contents.clone().>strip().split_by(" ") end
    let parts = Array[String](2)
    for part in split.values() do
      if part != "" then
        parts.push(part)
      end
    end
    if parts.size() != 2 then
      err = "Invalid {{= tag: cannot split tag content into open and close delimiters"
      error
    end
    try
      set_tag_regexes(parts(0)?, parts(1)?)?
    else
      err = "Invalid {{= tag: \"" + contents + "\", unable to set tag regexes"
      error
    end

  fun ref parse_partial_open(contents: String, padding: String) =>
    elts.push(Partial(contents, padding))

  fun escape_pcre_metachars(s: String): String =>
    // most of the time, s will be small, and relatively few
    // backslashes will need to be added. size() + 8 ought to be enough
    let out = recover String(s.size() + 8) end
    for rune in s.runes() do
      match rune
      | '\\' => out.push('\\')
      | '^' => out.push('\\')
      | '$' => out.push('\\')
      | '.' => out.push('\\')
      | '[' => out.push('\\')
      | '|' => out.push('\\')
      | '(' => out.push('\\')
      | ')' => out.push('\\')
      | '?' => out.push('\\')
      | '*' => out.push('\\')
      | '+' => out.push('\\')
      | '{' => out.push('\\')
      end
      out.push_utf32(rune)
    end
    consume out
