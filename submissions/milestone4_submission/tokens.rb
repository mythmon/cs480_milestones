$LOAD_PATH << "./"

class Token
  attr_accessor :tag

  def initialize(tag)
    @tag = tag
  end

  def to_s
    '<%s: %s>' % [self.class, @tag]
  end
end


class ConstantToken < Token
  attr_accessor :value

  def initialize(tag, value)
    super(tag)
    @value = value
  end

  def to_s
    '<%s: %s - %s>' % [self.class, @tag, @value]
  end

  def to_gforth
    value.to_s
  end
end


class BooleanToken < ConstantToken
end


class StringToken < ConstantToken
  def to_gforth
    '." ' + value + ' "'
  end
end


class NumberToken < ConstantToken
end


class IntegerToken < NumberToken
  def to_gforth
    "#{value}"
  end
end


class RealToken < NumberToken
  def to_gforth
    v = value.to_s
    v = v.chomp("f")
    v = v.split("e")
    "#{v[0]}e#{v[1]}"
  end
end

class OutputToken < ConstantToken
  def to_s
    self.value
  end
end

#EOF vim: sw=2:ts=2
