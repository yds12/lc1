require './grammar.rb'
require './rule.rb'

# Creates a grammar from a corpus
class GrammarGenerator
  def self.generate corpus
    g = Grammar.new    

    before = lambda do |tree, grammar|
      lexicon = tree.children.size == 1 && tree.children[0].children.empty?
      rule = GrammarRule.new(tree.type, tree.children.map{|t| t.type}, lexicon)

      # Bans rules of the kind X ::= X
      unless tree.children.empty? ||
        (!lexicon && rule.body.size == 1 && rule.head == rule.body[0])
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

    corpus.trees.each_with_index do |corpus_tree, i|
      corpus_tree.depth g, before, after
    end

    g.complete
    puts "#{corpus.trees.size} trees extracted in #{Time.new - t}s" # DEBUG

    return g
  end
end
