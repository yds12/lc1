# Probabilistic Earley algorithm state
class ProbEarleyState < EarleyState
  attr_accessor :bounds

  def initialize rule, start = 0, final = 0, current = 0, pointers = [], bounds = []
    @bounds = bounds
    super rule, start, final, current, pointers
  end

private

  def calculate_attrs
    @str = "#{@rule.str} | #{@current} | #{@start}, #{@final}, #{@bounds.to_s}"
    @_hash = @str.hash
    @complete = (@current == @rule.body.size)
  end
end
