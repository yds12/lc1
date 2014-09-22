require './earley.rb'

# Generates trees from the Earley chart
class EarleyTreeGenerator
  def generate chart
    trees = []

    start_state = chart.last.select do |s|
      s.rule.head == EarleyParser::DummyStartSymbol &&
        s.start == 0 && s.final == chart.size - 1
    end.first

    tree = Tree.new start_state.rule.body[0], nil
    states = Set.new
    states << start_state

    start_state.pointers[0].each do |p|
      copy = tree.copy
      trees << copy
      states_copy = states.clone
      next_state = get_state(chart, p)

      build_trees chart, trees, copy, next_state, states_copy
    end

    return trees
  end

private
  
  def build_trees chart, trees, tree, state, states
    #print "trees: #{trees.count}, tree: "
    #tree.show
    #print ", tree root: "
    #tree.root.show
    #puts ", state: #{state.str_refs}"

    states << state
    children = state.rule.body

    children.each_with_index do |child, index|
      child_tree = tree.add_child child

      next if state.pointers[index].nil?

      cur_tree = child_tree
      copy_tree = child_tree.copy

      state.pointers[index].each_with_index do |pointer, p_index|
        next_state = get_state(chart, pointer)

        if states.include? next_state
          trees.delete cur_tree.root
          next
        end

        if p_index > 0
          cur_tree = copy_tree.copy 
          trees << cur_tree.root
        end

        states_copy = states.clone
        build_trees chart, trees, cur_tree, next_state, states_copy
      end
    end
  end

  def get_state chart, pointer
    chart[pointer[0]][pointer[1]]
  end
end
