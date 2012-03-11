$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "lexer.rb"
require "parser.rb"

def translator

  input = IO.read(ARGV[0])

  tree = parser(input)

  p tree

end

translator
