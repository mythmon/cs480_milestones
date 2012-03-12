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
    'cos'       => [:ibtl_fcos, 1],
    'sin'       => [:ibtl_fsin, 1],
    'tan'       => [:ibtl_ftan, 1],
    'iff'       => [:ibtl_iff, 2],
    '<'         => [:ibtl_lt, 2],
    '-'         => [:ibtl_minus, 2],
    '%'         => [:ibtl_mod, 2],
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

def auto_promote(*args)
  all_int = true
  new_args = []
  for arg in args
    new_args << arg
    if arg.tag != :int
      all_int = false
      break
    end
  end

  if all_int
    return new_args
  else
    new_args = []
  end

  for arg in args
    if arg.tag == :int
      new_args << OutputToken.new(:real, "#{to_gforth arg} 0 d>f")
    else
      new_args << arg
    end
  end

  new_args
end

def ibtl_noop(args)
  return ''
end

def ibtl_add(arg0, arg1)
  arg0, arg1 = auto_promote(arg0, arg1)
  gf0, gf1 = [to_gforth(arg0), to_gforth(arg1)]
  op = (arg0.tag == :int ? '' : 'f') + '+'
  OutputToken.new(arg0.tag, "#{gf0} #{gf1} #{op}")
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
  arg0, arg1 = auto_promote(arg0, arg1)
  gf0, gf1 = [to_gforth(arg0), to_gforth(arg1)]
  op = (arg0.tag == :int ? '' : 'f') + '/'
  OutputToken.new(arg0.tag, "#{gf0} #{gf1} #{op}")
end

def ibtl_eq(arg0, arg1)
  arg0, arg1 = auto_promote(arg0, arg1)
  gf0, gf1 = [to_gforth(arg0), to_gforth(arg1)]
  op = (arg0.tag == :int ? '' : 'f') + '='
  OutputToken.new(:boolean, "#{gf0} #{gf1} #{op}")
end

def ibtl_exp(arg0)
  arg0 = to_gforth arg0
  OutputToken.new(:real, "#{arg0} fexp")
end

def ibtl_fcos(arg)
  arg = to_gforth arg
  OutputToken.new(:real, "#{arg} fcos")
end

def ibtl_fmult(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0} #{arg1} f*")
end

def ibtl_fpower(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:real, "#{arg0} #{arg1} f**")
end

def ibtl_fsin(arg)
  arg = to_gforth arg
  OutputToken.new(:real, "#{arg} fsin")
end

def ibtl_ftan(arg)
  arg = to_gforth arg
  OutputToken.new(:real, "#{arg} ftan")
end

def ibtl_iff(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:boolean, "#{arg0} #{arg1} =")
end

def ibtl_lt(arg0, arg1)
  arg0, arg1 = auto_promote(arg0, arg1)
  gf0, gf1 = [to_gforth(arg0), to_gforth(arg1)]
  op = (arg0.tag == :int ? '' : 'f') + '<'
  OutputToken.new(:boolean, "#{gf0} #{gf1} #{op}")
end

def ibtl_minus(arg0, arg1)
  arg0, arg1 = auto_promote(arg0, arg1)
  gf0, gf1 = [to_gforth(arg0), to_gforth(arg1)]
  op = (arg0.tag == :int ? '' : 'f') + '-'
  OutputToken.new(arg0.tag, "#{gf0} #{gf1} #{op}")
end

def ibtl_mod(arg0, arg1)
  arg0 = to_gforth arg0
  arg1 = to_gforth arg1
  OutputToken.new(:int, "#{arg0} #{arg1} mod")
end

def ibtl_mult(arg0, arg1)
  arg0, arg1 = auto_promote(arg0, arg1)
  gf0, gf1 = [to_gforth(arg0), to_gforth(arg1)]
  op = (arg0.tag == :int ? '' : 'f') + '*'
  OutputToken.new(arg0.tag, "#{gf0} #{gf1} #{op}")
end

def ibtl_neg(arg)
  arg = auto_promote(arg)[0]
  gf = to_gforth(arg)
  op = (arg.tag == :int ? '' : 'f') + '-'
  base = arg.tag == :int ? '0' : '0e'
  OutputToken.new(arg.tag, "#{base} #{gf} #{op}")
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
  OutputToken.new(:int, "#{arg0}e #{arg1}e f** f>d drop")
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
