$LOAD_PATH << "./"

require "tokens.rb"
require "strscan"

puts 'Type something'
input = gets

lexemes = []
s = StringScanner.new(input)

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
    lexemes << SymbolToken.new(l)
    next
  end

  l = s.scan(/\d+\.(\d+)?/)
  if l
    lexemes << RealToken.new(l.to_f)
    next
  end

  l = s.scan(/\d+/)
  if l
    lexemes << IntegerToken.new(l.to_i)
    next
  end

  l = s.scan(/"(.*)"/)
  if l
    lexemes << StringToken.new(s[0])
    next
  end

  l = s.scan(/[^\s)]+/)
  if l
    lexemes << StringToken.new(l)
    next
  end

  raise "What? " + s.inspect unless s.eos?
end

puts "Lexemes"
puts '[' + lexemes.collect{ |l| l.inspect }.join(', ') + ']'
