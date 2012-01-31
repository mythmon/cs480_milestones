$LOAD_PATH << "./"

class Token
  def inspect()
    '<%s>' % [self.class]
  end
end

class SymbolToken < Token
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def inspect()
    '<%s: %s>' % [self.class, @name]
  end
end

class ConstantToken < Token
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def inspect()
    '<%s: %s>' % [self.class, @value]
  end
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
