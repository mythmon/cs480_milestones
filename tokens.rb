class Token
  attr_accesor :name

  def initialize(name)
    @name = name
  end
end

class Constant << Token
    attr_accesor :value
end

class Boolean << Constant
end

class String << Constant
end

class Number << Constant
end

class Integer << Number
end

class Real << Number
end
