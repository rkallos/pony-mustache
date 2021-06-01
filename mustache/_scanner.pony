use "regex"

class _Scanner
  let str: String
  var pos: ISize = 0
  var mat: (Match | None) = None

  new create(str': String) =>
    str = str'

  fun is_beginning_of_line(): Bool =>
    if pos == 0 then
      return true
    end
    try
      str(pos.usize()-1)? == '\n'
    else
      false
    end

  fun is_eos(): Bool =>
    pos >= str.size().isize()

  fun ref scan(re: Regex): String =>
    try
      let m = re(str, pos.usize())?
      if m.start_pos() != pos.usize() then
        return ""
      end
      mat = m
      let s = m(0)?
      pos = pos + s.size().isize()
      s
    else
      ""
    end

  fun ref scan_until(pat: String): String =>
    // scans until the supplied pattern matches
    try
      let re = Regex(pat)?
      let m =
        try
          re(str, pos.usize())?
        else
          let here = pos
          terminate()
          return str.trim(here.usize())
        end
      mat = m
      let s = str.trim(pos.usize(), m.start_pos())
      pos = pos + s.size().isize()
      s
    else
      ""
    end

  fun ref skip(pat: String): USize =>
    try
      scan(Regex(pat)?).size()
    else
      0
    end

  fun match_peek(pat: String): Bool =>
    try
      Regex(pat)? == str.trim(pos.usize())
    else
      false
    end

  fun rest(): String => str.trim(pos.usize())

  fun ref terminate() => pos = str.size().isize()

  fun ref apply(n: USize = 0): String =>
    try
      let m: Match = mat as Match
      m(n.u32())?
    else
      ""
    end

