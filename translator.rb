$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "lexer.rb"
require "parser.rb"

def translator
  input = IO.read(ARGV[0])

  tree = parser(input)

  tree = strip_parens(tree)

  descend(tree)
end

def strip_parens(tree)
  tree.each_with_index do|token, index|
    if token.class == Token
      if token.tag == :openparen
        tree.delete_at(index)
      end
      if token.tag == :closeparen
        tree.delete_at(index)
        tree
      end
    end
    if token.class == Array
      tree[index] = strip_parens(tree[index])
    end
  end

  tree
end

def descend(tree)

  tree = tree.to_enum
  loop do
    p tree.next
  end

end

translator
