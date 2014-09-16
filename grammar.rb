require 'set'

# Represents a Probabilistic Context Free Grammar
class Grammar
  RootSymbol = '__NEW__ROOT__'

  attr_reader :rules, :pos, :rules_by_head

  def initialize
    @rules = Set.new
    @pos = []
  end
  
  def add rule
    @rules << rule
  end

  # Call this method after add all rules to calculate the parts of speech
  def complete
    lex = @rules.select { |r| r.lexicon }
    @pos = lex.map{ |r| r.head }.uniq

    @rules_by_head = Hash.new { |h, k| h[k] = Array.new }
    @rules.each { |r| @rules_by_head[r.head] << r }
  end

  def find_by_head symbol
    @rules_by_head[symbol]
  end
end
