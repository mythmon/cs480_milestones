$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "lexer.rb"
require "parser.rb"

def translator
  input = IO.read(ARGV[0])
  tree = parser(input)
  output = translate(tree).join(' ')
  output += "\nbye"
  # write output to a file?
end

def translate(tree)
  ops = {
    'println'   => [:ibtl_println, 1],
    'print'     => [:ibtl_print, 1],
    '+'         => [:ibtl_plus, 2],
    'f+'        => [:ibtl_fplus, 2],
    '-'         => [:ibtl_minus, 2],
    'f-'        => [:ibtl_fminus, 2],
    'neg'       => [:ibtl_negate, 1],
    '*'         => [:ibtl_times, 2],
    '/'         => [:ibtl_divide, 2],
    '^'         => [:ibtl_power, 2],
    'and'       => [:ibtl_and, 2],
    'or'        => [:ibtl_or, 2],
    'iff'       => [:ibtl_iff, 2],
    'not'       => [:ibtl_not, 1],
  }

  output = []

  tree = tree.to_enum
  loop do
    n = tree.next
    if n.is_a? Array
      output.concat translate(n)
    else
      begin
        key = n.value
      rescue NoMethodError
        key = n.tag
      end
      func, arg_count = ops[key]
      if func.nil?
        puts "Unknown token :#{n.tag} #{n.value} -- #{n}"
        exit 1
      end
      args = []
      arg_count.times do |i|
        a = tree.next
        if a.is_a? Array
          args.concat translate(a)
        else
          args << a
        end
      end
      func = method(func)
      result = func.call(*args)
      output << result
    end
  end

  output
end

def to_gforth arg
  if arg.is_a? Token
    "#{arg.to_gforth}"
  else
    "#{arg.to_s}"
  end
end

def ibtl_noop(args)
  return ''
end

def ibtl_println(arg)
  gf = to_gforth(arg)

  case arg.tag
  when :int, :boolean
    OutputToken.new(nil, "#{gf} . cr")
  when :float, :real
    OutputToken.new(nil, "#{gf} f. cr")
  when :string
    OutputToken.new(nil, "#{gf} cr")
  end
end

def ibtl_fplus(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0} #{arg1} f+")
end

def ibtl_plus(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} +")
end

def ibtl_fminus(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0} #{arg1} f-")
end

def ibtl_minus(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} -")
end

def ibtl_negate(arg)
  arg = to_gforth arg
  OutputToken.new(:int, "0 #{arg} -")
end

def ibtl_times(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} *")
end

def ibtl_divide(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} /")
end

def ibtl_power(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} ^")
end

def ibtl_concat(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:string, "#{arg0} #{arg1}")
end

def ibtl_and(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} and")
end

def ibtl_or(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} or")
end

def ibtl_iff(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} =")
end

def ibtl_not(arg0)
  arg0 = to_gforth arg0
  OutputToken.new(:boolean, "#{arg0} invert")
end

puts translator

#EOF vim: sw=2:ts=2
