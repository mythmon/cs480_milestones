$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "strscan"

puts 'Type something'
input = gets

tokens = []
s = StringScanner.new(input)
st = SymbolTable.new

line = 1

# tokenize stream of characters with regexes in if/next fashion
until s.eos?

  # trim whitespace
  begin
    l = s.scan(/\s/)
    if l == '\n'
      line += 1
    end
  end while l

  # boolean
  l = s.scan(/true/)
  l = s.scan(/false/) unless l
  if l
    token = BooleanToken.new(:boolean, l)
    st.try_set(l, token)
    tokens << token
    next
  end

  # parenthesis
  l = s.scan(/[()]/)
  if l
    token = Token.new(:openparen) if l == '('
    token = Token.new(:closeparen) if l == ')'
    st.try_set(l, token)
    tokens << token
    next
  end

  # real number / float
  l = s.scan(/\d+\.(\d+)?/)
  if l
    token = RealToken.new(:real, l.to_f)
    st.try_set(l, token)
    tokens << token
    next
  end

  # integer
  l = s.scan(/\d+/)
  if l
    token = IntegerToken.new(:int, l.to_i)
    st.try_set(l, token)
    tokens << token
    next
  end

  # string literal
  l = s.scan(/"(.*)"/)
  l = s.scan(/'(.*)'/) unless l
  if l
    token = StringToken.new(:string, s[0])
    st.try_set(l, token)
    tokens << token
    next
  end

  # bare word
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

puts "Lexemes"
puts '[' + tokens.collect{ |l| l.inspect }.join(', ') + ']'
puts
puts "Symbol Table"
puts st.inspect
