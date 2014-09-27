# Earley algorithm state
class EarleyState
  attr_accessor :rule, :start, :current, :pointers, :final, :generated_by
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
    @str == other.str
  end

  def eql? other
    other.instance_of?(self) && self == other
  end

  def hash
    @str.hash
  end

  def str_refs
    @str_refs = 
      "#{@rule.str} | #{@current} | #{@start}, #{@final}, #{str_pointers}"
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
    @complete = (@current == @rule.body.size)
  end
end
