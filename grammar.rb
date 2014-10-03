require 'set'

# Represents a Probabilistic Context Free Grammar
class Grammar
  RootSymbol = '__NEW__ROOT__'.to_sym

  attr_reader :rules, :pos, :rules_by_head, :pos_probs

  def initialize
    @rules = Hash.new
    @pos = Set.new
  end
  
  def add rule
    if @rules[rule]
      @rules[rule].count += rule.count
    else
      @rules[rule] = rule
    end
  end

  # Call this method after add all rules to calculate the parts of speech
  def complete
    # Set of the part-of-speech variables
    @pos = Set.new
    lex = @rules.values.select { |r| r.lexicon }
    @pos.merge lex.map{ |r| r.head }.uniq

    # Each head indexing a list of its rules
    @rules_by_head = Hash.new { |h, k| h[k] = Array.new }
    @rules.each { |k, v| @rules_by_head[v.head] << v }

    heads_totals = Hash.new # total number of times each head appeared
    @rules_by_head.each do |head, rules|
      heads_totals[head] = rules.inject(0) { |sum, r| sum + r.count }
    end

    @rules.values.each do |r|
      r.p = r.count.to_f / heads_totals[r.head]
    end

    # Each part-of-speech mapping to its probability (among tokens)
    @pos_probs = Hash.new
    total_pos = 0
    @pos.each do |pos|
      @pos_probs[pos] = heads_totals[pos]
      total_pos += @pos_probs[pos] 
    end

    # Calculate the probabilities of each POS
    @pos_probs.each do |k, v|
      @pos_probs[k] = v.to_f / total_pos
    end
  end

  def find_by_head symbol
    @rules_by_head[symbol]
  end
end
