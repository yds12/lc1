# Converts a tree to a chart, and calculates the precision
# and recall between two charts
class TreeChart
  attr_accessor :bracketing_p, :bracketing_r, :bracketing_f,
    :phrasal_p, :phrasal_r, :phrasal_f

  # Calculate precision, recall and F measure for bracketing and phrases
  # between two trees
  def calculate_metrics tree1, tree2
    reset_metrics
    if tree1.sentence.size != tree2.sentence.size
      puts "WARNING: trees of different sizes!"
      return
    end

    chart1 = to_chart tree1
    chart2 = to_chart tree2

    calculate_metrics_charts chart1, chart2
  end

  def print_chart tree
    sentence = tree.sentence
    chart = to_chart tree

    puts chart.to_s

    chart.size.times do |i|
      j = chart.size - i - 1
      level = chart[j]

      print "#{j}\t|"

      level.each do |square|
        print square.to_s[1..-2]
        print "\t|"
      end

      puts nil
    end

    sentence.each do |w|
      print w
      print "\t|"
    end

    puts nil
  end

private
  def reset_metrics
    @bracketing_p = 0
    @bracketing_r = 0
    @bracketing_f = 0
    @phrasal_p = 0
    @phrasal_r = 0
    @phrasal_f = 0
  end

  # Create a chart from a tree
  def to_chart tree
    n = tree.sentence.size

    chart = Array.new(n)

    chart.each_with_index do |level, i|
      chart[i] = Array.new(n - i) { Array.new }
    end

    @last_child = 0
    get_span tree, chart
    chart
  end

  def get_span tree, chart
    add = false
    if tree.children.empty?
      span = [@last_child, @last_child + 1]
      @last_child += 1
    else
      spans = []
      add = true
      tree.children.each do |child|
        spans << get_span(child, chart)
      end

      span = [spans.first[0], spans.last[1]]
    end

    set_chart tree.type, chart, span, add
    return span
  end

  def set_chart value, chart, span, add
    start = span[0]
    fin = span[1]
    chart[fin - start - 1][start] << value if add
  end

  # Calculate precision, recall and F measure for bracketing and phrases
  # between two charts
  def calculate_metrics_charts chart1, chart2
  end
end
