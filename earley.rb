require './rule.rb'

# Earley algorithm state
class EarleyState
  attr_accessor :rule, :start, :current, :pointers
  attr_reader :str, :complete

  def initialize rule, start = 0, current = 0, pointers = []
    @rule = rule
    @start = start
    @current = current
    @pointers = pointers

    calculate_attrs
  end

  def next_symbol
    return nil if @complete
    @rule.body[@current - @start]
  end

  def == other
    @str == other.str
  end

  def eql? other
    other.instance_of?(self) && self == other
  end

  def hash
    @str.hash
  end

private

  def calculate_attrs
    @str = "#{@rule.str} | #{@start}, #{@current}, [#{@pointers.join(',')}]"
    @complete = (@current - @start == @rule.body.size)
  end
end

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
        puts j # DEBUG
        if @chart[i][j].complete
          completer @chart[i][j]
        elsif @grammar.pos.include? @chart[i][j].next_symbol
          scanner @chart[i][j]
        else
          predictor @chart[i][j]
        end

        j += 1
      end
    end

    puts Time.new - t
  end

  def predictor state
    rules = @grammar.find_by_head state.next_symbol
    rules.each do |r|
    new_state = EarleyState.new(r, state.start, state.current)
    @chart[state.current] << new_state unless @chart[state.current].include? new_state
    end
  end

  def scanner state
  end

  def completer state
  end

  def enqueue state, position
    unless @chart[position].map{|s| s.str }.include? state.str
      @chart[position] << state 
    end
  end
end
