# Represents a Probabilistic Context Free Grammar
class Grammar
  attr_accessor :rules
  attr_reader :terminals, :nonterminals, :pos

  def initialize
    @rules = []
	@terminals = []
	@nonterminals = []
	@pos = []
  end
  
  def add rule
    @rules << rule unless contains? rule
	#add_symbols rule
  end

private

  def add_symbols rule
    add_nonterminal rule.head
	add_pos rule.head if rule.lexicon
	
	rule.body.each do |s|
	  if rule.lexicon
        add_terminal s
	  else
	    add_nonterminal s
	  end
	end
  end

  def add_nonterminal s
    @nonterminals << s unless @nonterminals.include? s
  end

  def add_terminal s
    @terminals << s unless @terminals.include? s
  end

  def add_pos s
    @pos << s unless @pos.include? s
  end

  def contains? rule
    @rules.each do |r|
	  return true if r.str == rule.str
	end

	return false
  end
end
