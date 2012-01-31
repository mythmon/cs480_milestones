$LOAD_PATH << "./"

class Token
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

class ConstantToken < Token
    attr_accessor :value
end

class BooleanToken < ConstantToken
end

class StringToken < ConstantToken
end

class NumberToken < ConstantToken
end

class IntegerToken < NumberToken
end

class RealToken < NumberToken
end
