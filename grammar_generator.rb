require './grammar.rb'
require './rule.rb'

# Creates a grammar from a corpus
class GrammarGenerator
  def self.generate corpus_trees
    g = Grammar.new    

    before = lambda do |tree, grammar|
      lexicon = tree.children.size == 1 && tree.children[0].children.empty?
      rule = GrammarRule.new(tree.type, tree.children.map{|t| t.type}, lexicon)

      has_nonterminal_child = false
      has_terminal_child = false

      # Warns if there are nodes with terminals and non terminals as
      # children
      tree.children.each do |child|
        has_nonterminal_child = true unless child.children.empty?
        has_terminal_child = true if child.children.empty?

        if has_nonterminal_child && has_terminal_child
          puts "WARNING: rule with terminal and non terminal detected!!"
          break
        end
      end

      # Bans rules of the kind X ::= X
      # and rules with terminals and nonterminals
      unless tree.children.empty? ||
        (!lexicon && rule.body.size == 1 && rule.head == rule.body[0]) ||
        (has_nonterminal_child && has_terminal_child)
        grammar.add rule
      end

      if tree.father.nil?
        rule = GrammarRule.new(
          Grammar::RootSymbol,
          [tree.type],
          false)

        grammar.add rule
      end
    end

    after = lambda {|tree, grammar| }

    t = Time.new # DEBUG

    corpus_trees.each_with_index do |corpus_tree, i|
      corpus_tree.depth g, before, after
    end

    g.complete
    puts "#{corpus_trees.size} trees extracted in #{Time.new - t}s" # DEBUG

    return g
  end
end
