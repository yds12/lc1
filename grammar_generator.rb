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
	end

	after = lambda {|tree, grammar| }

t = Time.new
	corpus.trees.each_with_index do |corpus_tree, i|
	  corpus_tree.depth g, before, after
puts "#{i}/#{corpus.trees.size}"
	end

    g.rules.sort!{|x, y| x.str <=> y.str }
puts Time.new - t
	return g
  end
end
