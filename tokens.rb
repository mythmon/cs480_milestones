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
  def to_gforth
    if value
      -1 # -1 is gforth's true.
    else
      0 # 0 is gforth's false
    end
  end
end


class StringToken < ConstantToken
  def to_gforth
  end
end


class NumberToken < ConstantToken
end


class IntegerToken < NumberToken
end


class RealToken < NumberToken
end

#EOF vim: sw=2:ts=2
