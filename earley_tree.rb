require './earley.rb'

# Generates trees from the Earley chart
class EarleyTreeGenerator
  def self.generate chart
    trees = []

    start_state = chart.last.select do |s|
      s.rule.head == EarleyParser::DummyStartSymbol &&
        s.start == 0 && s.final == chart.size - 1
    end.first
  end
end
