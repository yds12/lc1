require './grammar_generator.rb' 
require './corpus.rb' 
require './earley.rb' 

CorpusFile = './aires-treino.parsed'

ModeEarley = 0
ModeProbabilisticEarley = 1
ModeEarleyCorrectness = 2

def test_earley_correctness
  c = Corpus.new CorpusFile
  grammar = GrammarGenerator.generate c.trees
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
end

def test_earley
  repetitions = 5
  training_frac = 0.80

  precision = Array.new repetitions
  recall = Array.new repetitions
  f_measure = Array.new repetitions

  corpus = Corpus.new CorpusFile
  training_last = (corpus.trees.size * training_frac).floor

  puts "Testing Earley algorithm..."
  puts "#{repetitions} iterations, #{training_last + 1} training trees, #{corpus.trees.size - training_last - 1} testing trees"
  puts nil

  repetitions.times do |iteration|
    corpus.trees.shuffle!
    training = corpus.trees[0..training_last]
    testing = corpus.trees[(training_last + 1)..-1]
    
    grammar = GrammarGenerator.generate training
    parser = EarleyParser.new grammar

    tested = testing.size
    recognized = 0
    accepted = 0

    testing.each do |tree|
      recognize = parser.parse tree.sentence
      accept_tree = parser.accepts? tree

      recognized += 1 if recognize
      accepted += 1 if recognize && accept_tree
    end

    precision[iteration] = accepted.to_f / recognized
    recall[iteration] = recognized.to_f / tested
    f_measure[iteration] = (2.0 * precision[iteration] * recall[iteration]) /
      (precision[iteration] + recall[iteration])
  end

  puts "Final Results"
  puts "Iteration\tPrecision\tRecall\tF Measure"
  repetitions.times do |iteration|
    puts "#{iteration}\t#{precision[iteration]}\t#{recall[iteration]}\t#{f_measure[iteration]}"
  end

  avg_precision = precision.inject(0.0) { |sum, el| sum + el } / repetitions
  avg_recall = recall.inject(0.0) { |sum, el| sum + el } / repetitions
  avg_f = f_measure.inject(0.0) { |sum, el| sum + el } / repetitions
  
  puts "AVG Precision\tAVG Recall\tAVG F Measure"
  puts "#{avg_precision}\t#{avg_recall}\t#{avg_f}"
end

mode = ARGV[0].to_i

if mode == ModeEarley
  test_earley
elsif mode == ModeEarleyCorrectness
  test_earley_correctness
elsif mode == ModeProbabilisticEarley

end
