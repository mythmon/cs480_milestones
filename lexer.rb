$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "strscan"

def tokenize(input)

  tokens = []
  s = StringScanner.new(input)
  st = SymbolTable.new

  line = 1

  # =============================================================
  # tokenize stream of characters with regexes in if/next fashion
  # =============================================================
  until s.eos?

    # nom whitespace, turn input to character stream
    begin
      l = s.scan(/\s/)
      if l == '\n'
        line += 1
      end
    end while l

    # parentheses
    l = s.scan(/[()]/)
    if l
      token = Token.new(:openparen) if l == '('
      token = Token.new(:closeparen) if l == ')'
      st.try_set(l, token)
      tokens << token
      next
    end

    # ==========================================
    # CONSTANTS (boolean, integer, real, string)
    # ==========================================

    # booleans
    l = s.scan(/true/)
    l = s.scan(/false/) unless l
    if l
      token = BooleanToken.new(:boolean, l)
      st.try_set(l, token)
      tokens << token
      next
    end

    # reals
    l = s.scan(/\-?\d+\.(\d+)?/)
    if l
      token = RealToken.new(:real, l.to_f)
      st.try_set(l, token)
      tokens << token
      next
    end

    # integers
    l = s.scan(/\-?\d+/)
    if l
      token = IntegerToken.new(:int, l.to_i)
      st.try_set(l, token)
      tokens << token
      next
    end

    # strings (quoted)
    l = s.scan(/"(.*?)"/)
    l = s.scan(/'(.*?)'/) unless l
    if l
      token = StringToken.new(:string, s[0])
      st.try_set(l, token)
      tokens << token
      next
    end

    # strings (bare)
    l = s.scan(/[^\s)]+/)
    if l
      token = StringToken.new(:string, l)
      st.try_set(l, token)
      tokens << token
      next
    end

    # invalid
    raise "What? " + s.inspect unless s.eos?

  end

  return tokens

end

#EOF vim: sw=2:ts=2
