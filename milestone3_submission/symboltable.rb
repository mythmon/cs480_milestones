class SymbolTable
  attr_accessor :parent

  def initialize(parent=nil)
    @parent = parent
    @st = {}
  end

  def get(name)
    v = @st[name]

    # if not found, try parent tree
    unless v
      p = @parent
      while p
        v = p.get(name)
        return v if v != nil
        p = p.parent
      end
    end

    # return whatever we got
    return v
  end

  def set(name, value)
    @st[name] = value
  end

  def try_set(name, value)
    if @st[name] == nil
      self.set(name, value)
    end

    return self.get(name)
  end

  def inspect
    @st.inspect
  end
end
