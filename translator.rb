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
    '+'         => [:ibtl_add, 2],
    'and'       => [:ibtl_and, 2],
    'concat'    => [:ibtl_concat, 2],
    '/'         => [:ibtl_div, 2],
    '='         => [:ibtl_eq, 2],
    'e'         => [:ibtl_exp, 1],
    'f+'        => [:ibtl_fadd, 2],
    'f/'        => [:ibtl_fdiv, 2],
    'f='        => [:ibtl_feq, 2],
    'f<'        => [:ibtl_flt, 2],
    'f-'        => [:ibtl_fminus, 2],
    'f*'        => [:ibtl_fmult, 2],
    'fneg'      => [:ibtl_fneg, 1],
    'f^'        => [:ibtl_fpower, 2],
    'iff'       => [:ibtl_iff, 2],
    '<'         => [:ibtl_lt, 2],
    '-'         => [:ibtl_minus, 2],
    '*'         => [:ibtl_mult, 2],
    'neg'       => [:ibtl_neg, 1],
    'not'       => [:ibtl_not, 1],
    'or'        => [:ibtl_or, 2],
    '^'         => [:ibtl_power, 2],
    'print'     => [:ibtl_print, 1],
    'println'   => [:ibtl_println, 1],
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

def ibtl_add(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} +")
end

def ibtl_and(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} and")
end

def ibtl_concat(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:string, "#{arg0} #{arg1}")
end

def ibtl_div(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} /")
end

def ibtl_eq(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} =")
end

def ibtl_exp(arg0)
  arg0 = to_gforth arg0
  OutputToken.new(:int, "#{arg0} fexp")
end

def ibtl_fadd(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0} #{arg1} f+")
end

def ibtl_fdiv(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0} #{arg1} f/")
end

def ibtl_feq(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} f=")
end

def ibtl_flt(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} f<")
end

def ibtl_fminus(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0} #{arg1} f-")
end

def ibtl_fmult(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0} #{arg1} f*")
end

def ibtl_fneg(arg0)
  arg0 = to_gforth arg0
  OutputToken.new(:real, "0e #{arg0} f-")
end

def ibtl_fpower(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0} #{arg1} f**")
end

def ibtl_iff(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} =")
end

def ibtl_lt(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} <")
end

def ibtl_minus(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} -")
end

def ibtl_mult(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} *")
end

def ibtl_neg(arg)
  arg = to_gforth arg
  OutputToken.new(:int, "0 #{arg} -")
end

def ibtl_not(arg0)
  arg0 = to_gforth arg0
  OutputToken.new(:boolean, "#{arg0} invert")
end

def ibtl_or(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} or")
end

def ibtl_power(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0}e #{arg1}e f**")
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

puts translator

#EOF vim: sw=2:ts=2
