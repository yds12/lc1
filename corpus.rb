require './tokenizer.rb'
require './tree.rb'

# Class that reads a corpus of parse trees
class Corpus
  WorkingEncoding = 'UTF-8'

  # There are some symbols that are heads of lexicon rules and other rules.
  # This Hash sets whether a symbol must be part of a lexicon rule.
  SymbolLex = { VB: true, NP: false, WPP: false }
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
          @trees << tree if check_tree tree
        else
          tree = tree.father
        end
      end
    end
  end

  def check_tree tree
    exclude_tree = false

    before = lambda do |t, p|
      # Convert all types to symbols
      if t.children.empty?
        t.type = t.type.downcase.to_sym if t.type.instance_of? Symbol
      else
        t.type = t.type.upcase.to_sym

        t.children.each do |c|
          if c.children.empty?
            c.type = c.type.downcase.to_sym
          else
            c.type = c.type.upcase.to_sym
          end
        end
      end

      # This node has its own type as only child, so we need to set its
      # grandchildren as its children, and set their father as this node.
      if t.children.size == 1 && t.children[0].type == t.type &&
        !t.children[0].children.empty?
        t.children = t.children[0].children
        t.children.each { |c| c.father = t }
      end

      # Check if this node symbol is present in both lexicon and non lexicon
      # rules.
      if SymbolLex.has_key? t.type
        if SymbolLex[t.type] # lexicon symbol
          if t.children.size != 1 or !t.children[0].children.empty?
            exclude_tree = true # remove this tree
            puts "Tree Removed"
          end
        else # non lexicon symbol
          t.children.each do |c|
            if c.children.empty?
              exclude_tree = true
              puts "Tree Removed"
              break
            end
          end
        end
      end
    end

    after = lambda { |t, p| }
    tree.depth nil, before, after

    return !exclude_tree
  end
end
