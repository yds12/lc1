require 'set'

# Represents a Probabilistic Context Free Grammar
class Grammar
  RootSymbol = '__NEW__ROOT__'

  attr_reader :rules, :pos

  def initialize
    @rules = Set.new #[]
    @pos = []
  end
  
  def add rule
    @rules << rule
  end

  # Call this method after add all rules to calculate the parts of speech
  def complete
    lex = @rules.select { |r| r.lexicon }
    @pos = lex.map{ |r| r.head }.uniq
  end

  def find_by_head symbol
    return @rules.select { |r| r.head == symbol }

    head_found = false
    rules = []

    @rules.each do |r|
      if r.head == symbol
        head_found = true
        rules << r
      else
        break if head_found
      end
    end
    
    rules
  end
end
