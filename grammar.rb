# Represents a Probabilistic Context Free Grammar
class Grammar
  RootSymbol = '__NEW__ROOT__'

  attr_reader :rules, :pos

  def initialize
    @rules = []
	@pos = []
  end
  
  def add rule
    @rules << rule unless contains? rule
  end

  # Call this method after add all rules to calculate the parts of speech
  def complete
    @rules.sort!{|x, y| x.str <=> y.str }
	lex = @rules.select{|r| r.lexicon }
	
	last_head = nil

	@rules.each do |r|
	  next if r.head == last_head

	  last_head = r.head

      @pos << r.head if lex.any?{|lex_rule| lex_rule.head == r.head }
	end  
  end

  def find_by_head symbol
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

private

  def contains? rule
    @rules.each do |r|
	  return true if r.str == rule.str
	end

	return false
  end
end
