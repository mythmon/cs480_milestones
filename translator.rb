$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "lexer.rb"
require "parser.rb"

def translator
  input = IO.read(ARGV[0])
  tree = parser(input)
  output = translate(tree)
  # write output to a file?
end

def translate(tree)
    ops = {
        'println' => [:ibtl_println, 1],
        '+' => [:ibtl_plus, 2],
    }

    output = ''

    tree = tree.to_enum
    loop do
        n = tree.next
        if n.is_a? Array
            output += translate(n) + ' '
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
                   args << translate(a)
               else
                   args << a
               end
            end
            output += method(func).call(args) + ' '
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

def ibtl_println(args)
    arg = to_gforth args[0]
    "#{arg} ."
end

def ibtl_plus(args)
    arg0 = to_gforth args[0]
    arg1 = to_gforth args[1]
    return "#{arg0} #{arg1} +"
end

puts translator
