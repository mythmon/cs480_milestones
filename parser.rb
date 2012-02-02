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

until s.eos?
  # Nom whitespace
  begin
    l = s.scan(/\s/)
    if l == '\n'
      line += 1
    end
  end while l

  l = s.scan(/[()]/)
  if l
    token = Token.new(:openparen) if l == '('
    token = Token.new(:closeparen) if l == ')'
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\d+\.(\d+)?/)
  if l
    token = RealToken.new(:real, l.to_f)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/\d+/)
  if l
    token = IntegerToken.new(:int, l.to_i)
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/"(.*)"/)
  l = s.scan(/'(.*)'/) unless l
  if l
    token = StringToken.new(:string, s[0])
    st.try_set(l, token)
    tokens << token
    next
  end

  l = s.scan(/[^\s)]+/)
  if l
    token = StringToken.new(:string, l)
    st.try_set(l, token)
    tokens << token
    next
  end

  raise "What? " + s.inspect unless s.eos?
end

puts "Lexemes"
puts '[' + tokens.collect{ |l| l.inspect }.join(', ') + ']'
puts
puts "Symbol Table"
puts st.inspect
