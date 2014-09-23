require './grammar_generator.rb' 
require './corpus.rb' 
require './earley.rb' 

c = Corpus.new './aires-treino.parsed' 
grammar = GrammarGenerator.generate c 
p = EarleyParser.new grammar

c.trees.each_with_index.
  map{|t,i| [i] + t.sentence }.
  sort{|x,y| x.size <=> y.size }.
  each do |i| 
    puts i.to_s
    result = p.parse c.trees[i[0]].sentence
    puts result
  end

puts nil
