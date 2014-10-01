require './earley.rb'

# Viterbi algorithm
class Viterbi
  # Calculates the Viterbi Path through the Earley Chart and returns
  # the matching tree
  def path earley
    @chart = earley.chart
    grammar = earley.grammar
    start_state = earley.get_start_state

    raise "Nil start state!" if start_state.nil?

    tree = Tree.new :void

    # Inserts the probabilities in each state
    viterbi start_state

    # Then, navigates through the most likely ones to build the
    # most likely parse tree
    build_tree tree, start_state
    tree
  end

  # Calculates the probability of this state, using the Viterbi
  # algorithm to evaluate the probability of all of its subtrees,
  # and choosing the most likely ones
  def viterbi state
    # Probability of a subtree is the probability of the rule...
    state.p = state.rule.p

    state.pointers.each do |pos|
      vits = []

      pos.each do |p|
        st = get_state p

        if st.p
          vits << st.p
        else
          vits << viterbi(st)
        end
      end

      # ...times the probability of its subtrees
      state.p *= vits.max
    end

    state.p
  end

  def build_tree tree, state
    return if state.nil?
    state.p = 0 # Don't repeat states

    # Terminal
    if state.pointers.empty?
      tree.add_child state.rule.body.first
    else
      state.pointers.size.times do |pos|
        subtree = tree.add_child state.rule.body[pos]
        
        max_state = nil
        max_prob = 0

        state.pointers[pos].each do |p|
          st = get_state p
          if st.p >= max_prob
            max_state = st
            max_prob = max_state.p
          end
        end

        build_tree subtree, max_state
      end
    end
  end

  def get_state pointer
    @chart[pointer[0]][pointer[1]]
  end
end
