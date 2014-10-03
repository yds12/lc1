require './grammar_generator.rb' 
require './corpus.rb' 
require './earley.rb' 
require './pearley.rb' 
require './viterbi.rb'
require './tree_chart.rb'

class Test
  def test_earley_correctness file, slice_size, slice_number
    c = Corpus.new file
    grammar = GrammarGenerator.generate c.trees
    p = EarleyParser.new grammar

    sentences = c.trees.each_with_index.
      map{|t,i| [i] + t.sentence }

    start = slice_size * slice_number
    _end = start + slice_size
    
    sentences[start..._end].each do |i| 
      puts i.to_s
      recognized = p.parse c.trees[i[0]].sentence

      accepted = false
      accepted = p.accepts? c.trees[i[0]] if recognized

      if accepted
        puts "accepted" 
      else
        puts "not accepted" 
      end
    end

    puts nil
  end

  def test_earley file, use_all_lexicon = false
    repetitions = 1
    training_frac = 0.90

    precision = Array.new repetitions
    recall = Array.new repetitions
    f_measure = Array.new repetitions
    training_time = Array.new repetitions
    exec_time = Array.new repetitions

    corpus = Corpus.new file

    if use_all_lexicon
      entire_grammar = GrammarGenerator.generate corpus.trees
      lexicon = entire_grammar.rules.select{|r| r.lexicon}
      puts "Total Lexicon size: #{lexicon.size}"
    end

    training_last = (corpus.trees.size * training_frac).floor

    puts "Testing Earley algorithm..."
    puts "#{repetitions} iterations, #{training_last + 1} training trees, #{corpus.trees.size - training_last - 1} testing trees"
    puts nil

    repetitions.times do |iteration|
      corpus.trees.shuffle!
      training = corpus.trees[0..training_last]
      testing = corpus.trees[(training_last + 1)..-1]
      
      t0 = Time.new
      grammar = GrammarGenerator.generate training
      puts "Rules: #{grammar.rules.size}"
      puts "Lexicon rules: #{grammar.rules.select{|r| r.lexicon}.size}"

      if use_all_lexicon
        lexicon.values.each do |r|
          grammar.add r
        end

        grammar.complete
        puts "With all lexicon: #{grammar.rules.size}"
      end

      training_time[iteration] = Time.now - t0

      t0 = Time.new
      parser = EarleyParser.new grammar

      tested = testing.size
      recognized = 0
      accepted = 0

      testing.each do |tree|
        recognize = parser.parse tree.sentence

        accept_tree = false

        if recognize
          accept_tree = parser.accepts? tree

          if accept_tree
            puts "tree accepted"
          else
            puts "tree not accepted"
          end
        end

        recognized += 1 if recognize
        accepted += 1 if recognize && accept_tree
      end

      exec_time[iteration] = Time.now - t0
      precision[iteration] = recognized > 0 ? accepted.to_f / recognized : 0
      recall[iteration] = recognized.to_f / tested

      pr = precision[iteration] + recall[iteration]
      f_measure[iteration] = pr > 0 ? (2.0 * precision[iteration] * recall[iteration]) / pr : 0
    end

    puts nil

    puts "Final Results"
    puts "Iteration\tPrecision\tRecall\tF Measure\tTrain. Time\tExec Time"
    repetitions.times do |iteration|
      puts "#{iteration}\t\t#{precision[iteration]}\t#{recall[iteration]}\t#{f_measure[iteration]}\t#{training_time[iteration]}\t#{exec_time[iteration]}"
    end

    puts nil

    avg_precision = precision.inject(0.0) { |sum, el| sum + el } / repetitions
    avg_recall = recall.inject(0.0) { |sum, el| sum + el } / repetitions
    avg_training = training_time.inject(0.0) { |sum, el| sum + el } / repetitions
    avg_exec = exec_time.inject(0.0) { |sum, el| sum + el } / repetitions
    
    pr = avg_precision + avg_recall
    avg_f = pr > 0 ? (2.0 * avg_precision * avg_recall) / pr : 0
    
    puts "AVG Precision\tAVG Recall\tAVG F Measure\tAVG Train. Time\tAVG Exec. Time"
    puts "#{avg_precision}\t#{avg_recall}\t#{avg_f}\t#{avg_training}\t#{avg_exec}"
  end

  def test_pearley file
    training_frac = 0.9975
    corpus = Corpus.new file
    training_last = (corpus.trees.size * training_frac).floor

    puts "Testing Probabilistic Earley algorithm..."
    puts "#{training_last + 1} training trees"
    puts "#{corpus.trees.size - training_last - 1} testing trees"
    puts nil

    # Randomize training and test set
    corpus.trees.shuffle!
    training = corpus.trees[0..training_last]
    testing = corpus.trees[(training_last + 1)..-1]
    
    # Training phase
    t0 = Time.new
    grammar = GrammarGenerator.generate training
    puts "Rules: #{grammar.rules.size}"
    puts "Lexicon rules: #{grammar.rules.select{|r| r.lexicon}.size}"

    viterbi = Viterbi.new
    tree_chart = TreeChart.new
    training_time = Time.now - t0

    # Testing phase
    test_time = 0.0
    t0 = Time.new
    parser = ProbEarleyParser.new grammar

    testing.each do |tree|
      recognize = parser.parse tree.sentence

      accept_tree = false

      if recognize
        accept_tree = parser.accepts? tree

        if accept_tree
          puts "tree accepted"
        else
          puts "tree not accepted"
        end
      end

      parse_tree = viterbi.path parser
      test_time += Time.now - t0

      # Calculate metrics
      tree_chart.calculate_metrics parse_tree, tree

      puts "Bracketing precision: #{tree_chart.bracketing_p}"
      puts "Bracketing recall: #{tree_chart.bracketing_r}"
      puts "Bracketing F measure: #{tree_chart.bracketing_f}"
      puts "Phrasal precision: #{tree_chart.phrasal_p}"
      puts "Phrasal recall: #{tree_chart.phrasal_r}"
      puts "Phrasal F measure: #{tree_chart.phrasal_f}"

      t0 = Time.new
    end
  end

  def test_incremental_earley file
    corpus = Corpus.new file

    corpus.trees.size.times do |i|
      puts "Starting iteration #{i + 1}"

      t0 = Time.new
      grammar = GrammarGenerator.generate corpus.trees[0..i]
      parser = EarleyParser.new grammar

      tot_rec = 0
      tot_acc = 0

      (i + 1).times do |j|
        recognized = parser.parse corpus.trees[j].sentence
        accepted = false
        accepted = parser.accepts? corpus.trees[j] if recognized

        if accepted
          puts "accepted"
        else
          puts "not accepted"
        end

        tot_rec += 1 if recognized
        tot_acc += 1 if accepted
      end

      puts "Results of Iteration #{i + 1}: acc/rec/tot #{tot_acc}/#{tot_rec}/#{i + 1}, #{grammar.rules.size} rules, #{'%.3f' % ((Time.new - t0)/(i + 1))}s avg. parse"
    end
  end

  def test_viterbi_correctness file
    corpus = Corpus.new file
    grammar = GrammarGenerator.generate corpus.trees
    parser = ProbEarleyParser.new grammar
    viterbi = Viterbi.new

    corpus.trees.sort!{|x,y| x.sentence.size <=> y.sentence.size}

    it = 0
    correct = 0

    corpus.trees.each do |tree|
      it += 1
      puts "Iteration #{it}"

      parser.parse tree.sentence
      vitree = viterbi.path parser

      if vitree.sentence == tree.sentence
        correct += 1 
      else
        puts "FAIL"
      end

      vitree.show
      puts nil
      puts vitree.sentence.to_s
      puts "Results: #{correct} of #{it} correct."
    end
  end
end
