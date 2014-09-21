require './rule.rb'
require './earley_state.rb'

# Earley parsing algorithm
class EarleyParser
  DummyStartSymbol = '__DUMMY__START_SYM__'

  attr_reader :chart

  def initialize grammar
    @grammar = grammar
  end

  # Parses a sentence, returning all possible parse trees
  def parse sentence
    t = Time.new # DEBUG
    @n = sentence.size
    @chart = Array.new(@n + 1){ Array.new }

    dummy_rule = GrammarRule.new(
      DummyStartSymbol,
      [Grammar::RootSymbol],
      false)

    dummy_state = EarleyState.new(dummy_rule)
    enqueue dummy_state, 0

    @chart.size.times do |i|
      j = 0

      while j < @chart[i].size
        puts "chart #{i} state #{j}" # DEBUG

        if @chart[i][j].complete
          completer @chart[i][j], j
        elsif @grammar.pos.include? @chart[i][j].next_symbol
          scanner @chart[i][j], sentence[i] unless sentence[i].nil?
        else
          predictor @chart[i][j]
        end

        j += 1
      end
    end

    puts Time.new - t

    return @chart.last.select do |s|
      s.rule.head == DummyStartSymbol && s.start == 0 && s.final == @n 
    end.size == 1
  end

  def predictor state
    rules = @grammar.find_by_head state.next_symbol
    rules.each do |r|
    new_state = EarleyState.new(r, state.final, state.final, 0)
    @chart[state.final] << new_state unless @chart[state.final].include? new_state
    end
  end

  def scanner state, word
    @grammar.rules.each do |r|
      if r.lexicon and r.body[0] == word.downcase
        new_state = EarleyState.new(r, state.final, state.final + 1, 1)
        @chart[state.final + 1] << new_state unless @chart[state.final + 1].include? new_state
      end
    end
  end

  def completer completed_state, completed_state_index
    @chart[completed_state.start].each do |affected_state|
      if affected_state.next_symbol == completed_state.rule.head
        new_state = EarleyState.new(
          affected_state.rule, affected_state.start,
          completed_state.final, affected_state.current + 1)

        existing_state_index = @chart[completed_state.final].index(new_state)

        if existing_state_index.nil?
          pointers = affected_state.pointers.clone
          pointers << [] if pointers.size < affected_state.current + 1

          pointers[affected_state.current] <<
            [completed_state.final, completed_state_index]

          new_state.pointers = pointers
          @chart[completed_state.final] << new_state
        else
          old_state = @chart[completed_state.final][existing_state_index]
          old_state.pointers << [] if old_state.pointers.size < affected_state.current + 1

          old_state.pointers[affected_state.current] <<
            [completed_state.final, completed_state_index]
        end
      end
    end
  end

  def enqueue state, position
    unless @chart[position].map{|s| s.str }.include? state.str
      @chart[position] << state 
    end
  end
end
