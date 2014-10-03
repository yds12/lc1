require 'set'
require './rule.rb'
require './pearley_state.rb'

# Probabilistic version of the Earley parsing algorithm
class ProbEarleyParser < EarleyParser
  def initialize grammar
    super grammar
    @rule_class = ProbEarleyState
  end

  # We deal with unknown words here
  def scan_fail rules, word
    # For each part-of-speech, create a rule generating word with
    # probability P, with P representing the probability of the POS
    # among tokens
    @grammar.pos_probs.each do |pos, p|
      rule = GrammarRule.new pos, [word], true, p
      rules << rule
    end
  end
end
