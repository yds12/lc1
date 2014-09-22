require './rule.rb'
require './earley_state.rb'

# Earley parsing algorithm
class EarleyParser
  DummyStartSymbol = '__DUMMY__START__SYM__'

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
      puts "calculating chart #{i}..."
      j = 0

      while j < @chart[i].size
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

    puts "parsed in #{Time.new - t}s"

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

  def print_chart
    @chart.size.times do |n|
      puts nil
      puts "CHART #{n}"
      @chart[n].each do |s|
        puts s.str_refs
      end
    end
  end

  # Verifies whether a certain parse tree was accepted by the parser
  def accept? tree
    start_state = @chart.last.select do |s|
      s.rule.head == DummyStartSymbol &&
        s.start == 0 && s.final == @chart.size - 1
    end.first

    # The first 2 symbols are dummy symbols created by the
    # algorithm
    start_state.pointers[0].each do |p|
      state = get_state p

      state.pointers[0].each do |p2|
        state2 = get_state p2

        if recursive_accept? tree, state2
          return true
        end
      end
    end

    return false
  end

private

  # Recursively checks whether a tree is possible given an Earley state
  def recursive_accept? tree, state
    # If the number of children of the tree is not the same
    # as the number of symbols in the right side of the rule,
    # the tree is not accepted
    return false if state.rule.body.size != tree.children.size

    tree.children.size.times do |i|
      # If one of the children of the tree is not equal the
      # matching symbol on the right side of the rule, the
      # tree is not accepted.
      # If the rule being checked is one of the lexicon,
      # and the child matches the symbol on the right of the rule,
      # then this subtree is accepted
      if tree.children[i].type.downcase != state.rule.body[i].downcase
        return false
      elsif state.rule.lexicon
        return true
      end

      accept_sub = false

      # For this particular child (or symbol of the rule),
      # verifies whether any of the pointers yields an
      # acceptable subtree
      state.pointers[i].each do |p|
        sub_state = get_state p

        if recursive_accept? tree.children[i], sub_state
          accept_sub = true
          break
        end
      end

      return false unless accept_sub
    end

    return true
  end

  def get_state pointer
    @chart[pointer[0]][pointer[1]]
  end
end
