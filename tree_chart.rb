# Converts a tree to a chart, and calculates the precision
# and recall between two charts
class TreeChart
  # Several measures:
  # Precision, recall and F measure for bracketing, and for phrases;
  # Number of constituents in both trees, in the parse tree, and in the
  # correct tree;
  # Number of phrases in both trees, in the parse tree, and in the
  # correct tree.
  attr_reader :bracketing_p, :bracketing_r, :bracketing_f,
    :phrasal_p, :phrasal_r, :phrasal_f,
    :b_both, :b_parse, :b_goal,
    :p_both, :p_parse, :p_goal

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
    @bracketing_p = 0.0
    @bracketing_r = 0.0
    @bracketing_f = 0.0
    @phrasal_p = 0.0
    @phrasal_r = 0.0
    @phrasal_f = 0.0

    @b_both = 0 # constituent exists in both
    @b_parse = 0 # constituent exists in parsed tree
    @b_goal = 0 # constituent exist in correct tree

    @p_both = 0 # phrase exists in both
    @p_parse = 0 # phrase exists in parsed tree
    @p_goal = 0 # phrase exist in correct tree
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
  def calculate_metrics_charts chart_parse, chart_goal
    arrp = []
    chart_parse.each { |v| arrp += v }
    arrg = []
    chart_goal.each { |v| arrg += v }

    puts arrp.to_s
    puts arrg.to_s

    arrp.size.times do |i|
      cellp = arrp[i]
      cellg = arrg[i]

      next if cellp.empty? && cellg.empty?

      if !cellp.empty?
        if !cellg.empty?
          @b_both += 1

          intersection = cellp.to_set.intersection(cellg.to_set).size
          @p_both += intersection
          @p_parse += cellp.uniq.size - intersection 
          @p_goal += cellg.uniq.size - intersection
        else
          @b_parse += 1
          @p_parse += cellp.size
        end
      elsif !cellg.empty?
        @b_goal += 1
        @p_goal += cellg.size
      end
    end

    @bracketing_p = @b_both.to_f/(@b_both + @b_parse)
    gb = @b_goal + @b_both
    @bracketing_r = gb > 0 ? @b_both.to_f/gb : 1.0
    pr = @bracketing_p + @bracketing_r
    @bracketing_f = pr > 0 ? (2 * @bracketing_p * @bracketing_r)/pr : 0.0

    @phrasal_p = @p_both.to_f/(@p_both + @p_parse)
    gb = @p_goal + @p_both
    @phrasal_r = gb > 0 ? @p_both.to_f/gb : 1.0
    pr = @phrasal_p + @phrasal_r
    @phrasal_f = pr > 0 ? (2 * @phrasal_p * @phrasal_r)/pr : 0.0
  end
end
