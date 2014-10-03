require './test.rb'

ModeEarley = 0
ModeProbabilisticEarley = 1
ModeEarleyCorrectness = 2
ModeIncrementalEarley = 3
ModeViterbiCorrectness = 4
ModeEarleyAllLexicon = 5

mode = ARGV[0].to_i
file = ARGV[1]

if mode == ModeEarley
  Test.new.test_earley file
elsif mode == ModeEarleyAllLexicon
  Test.new.test_earley file, true
elsif mode == ModeEarleyCorrectness
  slice_size = ARGV[2].to_i
  slice_number = ARGV[3].to_i
  Test.new.test_earley_correctness file, slice_size, slice_number
elsif mode == ModeProbabilisticEarley
  Test.new.test_pearley file
elsif mode == ModeIncrementalEarley
  Test.new.test_incremental_earley file
elsif mode == ModeViterbiCorrectness
  Test.new.test_viterbi_correctness file
end
