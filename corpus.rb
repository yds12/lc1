require './tokenizer.rb'
require './tree.rb'

# Class that reads a corpus of parse trees
class Corpus
  WorkingEncoding = 'UTF-8'
  attr_reader :trees

  # Reads the tokens from the corpus and turns them into trees
  def initialize file
    t = Tokenizer.new file
    @trees = []
    level = 0
    tree = nil

    while token = t.next
      if token == :open
        level += 1
        token = t.next
        raise "Missing token in corpus" unless token

        token = token.encode(WorkingEncoding) if
          token.instance_of? String

        if level == 1
          tree = Tree.new(token, nil)
        else
          tree = tree.add_child(token)
        end
      elsif token == :close
        level -= 1

        if level == 0
          @trees << tree 
          check_tree tree
        else
          tree = tree.father
        end
      end
    end
  end

  def check_tree tree
    before = lambda do |t, p|
      # This node has its own type as only child, so we need to set its
      # grandchildren as its children, and set their father as this node.
      if t.children.size == 1 && t.children[0].type == t.type &&
        !t.children[0].children.empty?
        t.children = t.children[0].children
        t.children.each { |c| c.father = t }
      end
    end

    after = lambda { |t, p| }

    tree.depth nil, before, after
  end
end
