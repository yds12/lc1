require 'set'

# Represents a Probabilistic Context Free Grammar
class Grammar
  RootSymbol = '__NEW__ROOT__'.to_sym

  attr_reader :rules, :pos, :rules_by_head

  def initialize
    @rules = Hash.new
    @pos = Set.new
  end
  
  def add rule
    if @rules[rule]
      @rules[rule].count += 1
    else
      @rules[rule] = rule
    end
  end

  # Call this method after add all rules to calculate the parts of speech
  def complete
    lex = @rules.values.select { |r| r.lexicon }
    @pos.merge lex.map{ |r| r.head }.uniq

    @rules_by_head = Hash.new { |h, k| h[k] = Array.new }
    @rules.each { |k, v| @rules_by_head[v.head] << v }

    heads_totals = Hash.new
    @rules_by_head.each do |k, rules|
      heads_totals[k] = rules.inject(0) { |sum, r| sum + r.count }
    end

    @rules.values.each do |r|
      r.p = r.count.to_f / heads_totals[r.head]
    end
  end

  def find_by_head symbol
    @rules_by_head[symbol]
  end
end
