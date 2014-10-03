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
    tree = tree.children[0].children[0]
    tree
  end

private

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

  def build_tree tree, state, blacklist = []
    #gets # DEBUG
    #puts state.str_refs # DEBUG

    return if state.nil?
    state.p *= 0.01 # Don't repeat states

    # Terminal
    if state.pointers.empty?
      tree.add_child state.rule.body.first
    else
      state.pointers.size.times do |pos|
        subtree = tree.add_child state.rule.body[pos]
        
        max_state = nil
        max_prob = 0
        max_p = nil

        #puts blacklist.to_s # DEBUG
        #puts state.pointers[pos].size

        state.pointers[pos].each do |p|
          st = get_state p

          if st.rule.body.size == 1 && blacklist.include?(st.rule.body.first)
            #puts "BLACKLIST" # DEBUG
            st.p *= 0.01
          end

          if st.p >= max_prob
            max_state = st
            max_prob = max_state.p
            max_p = p # DEBUG
          end
        end

        # Avoid long paths repeating the same variables
        if max_state.pointers.size < 2
          blacklist << max_state.rule.head 
        else
          blacklist = []
        end

        #puts max_p.to_s # DEBUG
        build_tree subtree, max_state, blacklist
      end
    end
  end

  def get_state pointer
    @chart[pointer[0]][pointer[1]]
  end
end
