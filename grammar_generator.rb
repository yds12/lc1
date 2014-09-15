require './grammar.rb'
require './rule.rb'

# Creates a grammar from a corpus
class GrammarGenerator
  def self.generate corpus
    g = Grammar.new    

    before = lambda do |tree, grammar|
      rule = GrammarRule.new(
        tree.type,
        tree.children.map{|t| t.type},
        tree.children.size == 1 && tree.children[0].children.empty?)

      grammar.add rule unless tree.children.empty?

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
      puts "#{i}/#{corpus.trees.size}"
    end

    g.complete
    puts Time.new - t # DEBUG

    return g
  end
end
