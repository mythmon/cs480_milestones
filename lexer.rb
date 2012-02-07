$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "strscan"

if ARGV.length == 0
  puts 'Type something'
  input = gets
  puts
elsif ARGV.length == 1
  input = IO.read(ARGV[0])
else
  puts "Usage: lexer.rb [file]"
  exit 1
end

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

  # =========================================
  # PRIMITIVE TYPES (bool, int, real, string)
  # =========================================
  # bool
  l = s.scan(/bool/)
  if l
    token = Token.new(:bool)
    st.try_set(l, token)
    tokens << token
    next
  end

  # int
  l = s.scan(/int/)
  if l
    token = Token.new(:int)
    st.try_set(l, token)
    tokens << token
    next
  end

  # real
  l = s.scan(/real/)
  if l
    token = Token.new(:real)
    st.try_set(l, token)
    tokens << token
    next
  end

  # string
  l = s.scan(/string/)
  if l
    token = Token.new(:string)
    st.try_set(l, token)
    tokens << token
    next
  end

  # ========================================
  # REAL FUNCTIONS (log, e^n, sin, cos, tan)
  # ========================================

  # log
  l = s.scan(/log/)
  if l
    token = Token.new(:log)
    st.try_set(l, token)
    tokens << token
    next
  end

  # e^n
  l = s.scan(/e/)
  if l
    token = Token.new(:e)
    st.try_set(l, token)
    tokens << token
    next
  end

  # sin
  l = s.scan(/sin/)
  if l
    token = Token.new(:sin)
    st.try_set(l, token)
    tokens << token
    next
  end

  # cos
  l = s.scan(/cos/)
  if l
    token = Token.new(:cos)
    st.try_set(l, token)
    tokens << token
    next
  end

  # tan
  l = s.scan(/tan/)
  if l
    token = Token.new(:tan)
    st.try_set(l, token)
    tokens << token
    next
  end

  # ==========================================
  # STATEMENTS (print, if, while, let, assign)
  # ==========================================

  # print statement
  l = s.scan(/println/)
  if l
    token = Token.new(:print)
    st.try_set(l, token)
    tokens << token
    next
  end

  # if statement
  l = s.scan(/if/)
  if l
    token = Token.new(:if)
    st.try_set(l, token)
    tokens << token
    next
  end

  # while statement
  l = s.scan(/while/)
  if l
    token = Token.new(:while)
    st.try_set(l, token)
    tokens << token
    next
  end

  # let statement
  l = s.scan(/let/)
  if l
    token = Token.new(:let)
    st.try_set(l, token)
    tokens << token
    next
  end

  # assign statement
  l = s.scan(/assign/)
  if l
    token = Token.new(:assign)
    st.try_set(l, token)
    tokens << token
    next
  end

  # =====================================================
  # OPERATORS (and, or, not, iff, +, -, *, /, %, ^, =, <)
  # =====================================================
  l = s.scan(/and/)
  if l
    token = Token.new(:and)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/or/)
  if l
    token = Token.new(:or)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/not/)
  if l
    token = Token.new(:not)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/iff/)
  if l
    token = Token.new(:iff)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\+/)
  if l
    token = Token.new(:add)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\-/)
  if l
    token = Token.new(:subtract)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\*/)
  if l
    token = Token.new(:multiply)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\//)
  if l
    token = Token.new(:divide)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\%/)
  if l
    token = Token.new(:modulus)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\^/)
  if l
    token = Token.new(:power)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\=/)
  if l
    token = Token.new(:equals)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\</)
  if l
    token = Token.new(:lessthan)
    st.try_set(l, token)
    tokens << token
    next
  end

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

puts "Token Stream"
puts '[' + tokens.collect{ |l| l.inspect }.join(', ') + ']'
puts
puts "Symbol Table"
puts st.inspect
