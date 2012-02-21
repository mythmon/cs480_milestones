$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "lexer.rb"

def accept(enum, tag)
  if enum.peek.tag == tag
    enum.next
  else
    nil
  end
end

def expect(enum, tag)
  if enum.peek.tag == tag
    enum.next
  else
    raise SyntaxError
  end
end

def parser
  input = IO.read(ARGV[0])

  tree = []
  tokens = tokenize(input).to_enum

  loop do
    tree << expect(tokens, :openparen)
    tree << expr(tokens)
    tree << expect(tokens, :closeparen)
  end

  print_teh_tree(tree)
end

def expr(tokens)
  tree = []
  loop do
    t = accept(tokens, :openparen)
    if t
      tree << t
      tree << expr(tokens)
      tree << expect(tokens, :closeparen)
    end

    t = tokens.peek
    if t.tag == :closeparen
      break
    else
      tree << tokens.next
    end
  end

  tree
end

def print_teh_tree(tree, level=0)
  tree.each do |t|
    if t.kind_of? Array
      print_teh_tree(t, level+1)
    else
      puts ("\t"*level) + t.to_s
    end
  end
end

parser
