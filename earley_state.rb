# Earley algorithm state
class EarleyState
  attr_accessor :rule, :start, :current, :pointers, :final, :generated_by, :p
  attr_reader :str, :complete

  def initialize rule, start = 0, final = 0, current = 0, pointers = []
    @rule = rule
    @start = start
    @current = current
    @pointers = pointers
    @final = final

    calculate_attrs
  end

  def next_symbol
    return nil if @complete
    @rule.body[@current]
  end

  def == other
    @_hash == other.hash
  end

  def eql? other
    other.instance_of?(self.class) && self == other
  end

  def hash
    @_hash
  end

  def str_refs
    @str_refs = "#{@str}, #{str_pointers}"
  end
  
  def str_pointers
    str = ""

    @pointers.each do |p|
      str << "[" << p.to_a.to_s << "]"
    end

    str
  end

private

  def calculate_attrs
    @str = "#{@rule.str} | #{@current} | #{@start}, #{@final}"
    @_hash = @str.hash
    @complete = (@current == @rule.body.size)
  end
end
