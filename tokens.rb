$LOAD_PATH << "./"

class Token
  attr_accessor :tag

  def initialize(tag)
    @tag = tag
  end

  def inspect()
    '<%s: %s>' % [self.class, @tag]
  end
end

class ConstantToken < Token
  attr_accessor :value

  def initialize(tag, value)
    super(tag)
    @value = value
  end

  def inspect()
    '<%s: %s - %s>' % [self.class, @tag, @value]
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
