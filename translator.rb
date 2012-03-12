$LOAD_PATH << "./"

require "tokens.rb"
require "symboltable.rb"
require "lexer.rb"
require "parser.rb"

def translator
  input = IO.read(ARGV[0])
  tree = parser(input)
  output = translate(tree)
  output += "\nbye"
  # write output to a file?
end

def translate(tree)
    ops = {
        :openparen => [:ibtl_noop, 0],
        :println => [:ibtl_println, 1],
        :print => [:ibtl_println, 1],
        'print' => [:ibtl_println, 1],
        'println' => [:ibtl_println, 1],
        :closeparen => [:ibtl_noop, 0],
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

def ibtl_noop(args)
    return ''
end

def ibtl_println(args)
    return "#{args[0].to_gforth} . cr"
end

puts translator
