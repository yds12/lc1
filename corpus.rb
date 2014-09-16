require './tokenizer.rb'
require './tree.rb'

# Class that reads a corpus of parse trees
class Corpus
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

        if level == 1
          tree = Tree.new(token, nil)
        else
          tree = tree.add_child(token)
        end
      elsif token == :close
        level -= 1

        if level == 0
          @trees << tree 
        else
          tree = tree.father
        end
      end
    end
  end
end
