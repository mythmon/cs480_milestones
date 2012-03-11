$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "lexer.rb"

def expect(enum, tag)
  begin
    if enum.peek.tag == tag
      enum.next
    else
      raise SyntaxError
    end
  rescue StopIteration
    raise SyntaxError
  end
end

def parser(input)
  tree = []
  tokens = tokenize(input).to_enum

  loop do
    # If we are at the end of the file, this will raise a StopIteration, and stop the loop. Otherwise, expect will throw an error.
    t = tokens.peek
    if t.nil?
      break
    elsif t.tag == :openparen
      tree << tokens.next
      tree << expr(tokens)
      tree << expect(tokens, :closeparen)
    else
      raise SyntaxError
    end
  end

  # puts "+++ Tree Format +++"
  # print_teh_tree(tree)
  # puts ""
  # puts "+++ Array Format +++"
  # p tree
  strip_parens(tree)[0]
end

def expr(tokens)
  tree = []
  loop do
    t = tokens.peek
    if t.tag == :closeparen
      break
    elsif t.tag == :openparen
      tree << tokens.next
      tree << expr(tokens)
      tree << expect(tokens, :closeparen)
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
      puts("\t"*level + t.to_s)
    end
  end
end

def strip_parens(tree)

  arr = Array.new

  tree.each do|token|
    if token.is_a? Token
      if token.tag == :openparen or token.tag == :closeparen
        next
      end
      arr << token
    elsif token.class == Array
      arr << strip_parens(token)
    end
  end

  return arr

end
