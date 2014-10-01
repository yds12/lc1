require 'set'
require './rule.rb'
require './earley_state.rb'

# Earley parsing algorithm
class EarleyParser
  DummyStartSymbol = '__DUMMY__START__SYM__'.to_sym

  attr_reader :chart, :waiting, :grammar

  def initialize grammar
    @grammar = grammar
  end

  # Parses a sentence, returning all possible parse trees
  def parse sentence
    t0 = Time.new # DEBUG
    @n = sentence.size
    @chart = Array.new(@n + 1){ Array.new }
    @set_chart = Array.new(@n + 1){ Hash.new }
    @waiting = Hash.new { |h, k| h[k] = Array.new(@chart.size) { Array.new } }

    dummy_rule = GrammarRule.new(
      DummyStartSymbol,
      [Grammar::RootSymbol],
      false)

    dummy_state = EarleyState.new(dummy_rule)
    enqueue dummy_state, 0

    puts "Parsing sentence: #{sentence.to_s}"
    
    @chart.size.times do |i|
      puts "calculating chart #{i}..."
      j = 0

      while j < @chart[i].size
        cur_state = @chart[i][j]

        if cur_state.complete
          completer cur_state, j
        elsif @grammar.pos.member? cur_state.next_symbol
          scanner cur_state, sentence[i] unless sentence[i].nil?
        else
          predictor cur_state
        end

        j += 1
      end
    end

    puts "parsed in #{Time.new - t0}s"

    recognized = !get_start_state.nil?

    if recognized
      puts "recognized" 
    else
      puts "not recognized"
    end

    return recognized
  end

  def get_start_state
    states = @chart.last.select do |s|
      s.rule.head == DummyStartSymbol && s.start == 0 && s.final == @n 
    end

    states.first
  end

  def print_chart
    @chart.size.times do |n|
      puts nil
      puts "CHART #{n}"
      @chart[n].each_with_index do |s, i|
        puts "[#{i}] #{s.str_refs}"
      end
    end
  end

  # Verifies whether a certain parse tree was accepted by the parser
  def accepts? tree
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

  def predictor state
    rules = @grammar.find_by_head state.next_symbol
    rules.each do |r|
      new_state = EarleyState.new r, state.final, state.final, 0
      new_state.generated_by = :predictor
      enqueue new_state, state.final
    end
  end

  def scanner state, word
    rules = @grammar.rules.values.select { |r| r.lexicon && r.body[0] == word }
    rules.each do |r|
      new_state = EarleyState.new r, state.final, state.final + 1, 1
      new_state.generated_by = :scanner
      enqueue new_state, state.final + 1
    end
  end

  def completer completed_state, completed_state_index
    waitings = @waiting[completed_state.rule.head][completed_state.start]

    waitings.each do |affected_state_index|
      affected_state = @chart[completed_state.start][affected_state_index]

      new_state = EarleyState.new(
        affected_state.rule, affected_state.start,
        completed_state.final, affected_state.current + 1)
      new_state.generated_by = :completer

      # If the new state already exists, save its index
      existing_state_index = @set_chart[completed_state.final][new_state]

      # If the new state doesn't exist
      if existing_state_index.nil?
        pointers = []

        # Copies the pointers of the affected state
        affected_state.pointers.size.times do |i|
          pointers[i] = affected_state.pointers[i].clone
        end

        pointers << Set.new if pointers.size < affected_state.current + 1

        pointers[affected_state.current] <<
          [completed_state.final, completed_state_index]

        new_state.pointers = pointers
        #@chart[completed_state.final] << new_state
        enqueue new_state, completed_state.final
      else # new state already exists
        old_state = @chart[completed_state.final][existing_state_index]
        old_state.pointers << Set.new if old_state.pointers.size < affected_state.current + 1

        # Adds the pointers of the affected state to the existing state
        affected_state.pointers.size.times do |i|
          old_state.pointers[i] += affected_state.pointers[i]
        end

        old_state.pointers[affected_state.current] <<
          [completed_state.final, completed_state_index]
      end
    end
  end

  def enqueue state, position
    unless @set_chart[position].member? state
      @chart[position] << state 

      # Save the index of the state for rapid retrieval
      @set_chart[position][state] = (@chart[position].size - 1)

      # Adds the index of this state to the list of states
      # waiting for the symbol given by state.next_symbol
      unless state.complete
        @waiting[state.next_symbol][position] << (@chart[position].size - 1)
      end
    end
  end

  # Recursively checks whether a tree is possible given an Earley state
  def recursive_accept? tree, state
    # If the number of children of the tree is not the same
    # as the number of symbols in the right side of the rule,
    # the tree is not accepted
    if state.rule.body.size != tree.children.size
      return false 
    end

    tree.children.size.times do |i|
      child = tree.children[i].type.downcase
      symbol = state.rule.body[i].downcase

      # If one of the children of the tree is not equal the
      # matching symbol on the right side of the rule, the
      # tree is not accepted.
      # If the rule being checked is one of the lexicon,
      # and the child matches the symbol on the right of the rule,
      # then this subtree is accepted
      if child != symbol
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

      unless accept_sub
        return false 
      end
    end

    return true
  end

  def get_state pointer
    @chart[pointer[0]][pointer[1]]
  end
end
