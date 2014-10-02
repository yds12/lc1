require 'set'
require './rule.rb'
require './pearley_state.rb'

# Probabilistic version of the Earley parsing algorithm
class ProbEarleyParser < EarleyParser
  def initialize grammar
    super grammar
    @rule_class = ProbEarleyState
  end
end
