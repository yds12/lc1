# Represents a rule in a context free grammar
class GrammarRule
  attr_accessor :head, :body, :p, :lexicon
  attr_reader :str

  def initialize head, body, lexicon, p=1.0
    @head = head.upcase
    @p = p
    @lexicon = lexicon

    @body = body.map do |r|
      if @lexicon
        r.downcase
      else
        r.upcase
      end
    end

    generate_str
  end

  def generate_str
    @str = "#{@head} ::= #{@body.join ' '}"
  end

  def to_s
    @str
  end

  def == other
    other.instance_of?(self.class) && @str == other.str
  end

  alias_method :eql?, :==

  def hash
    @str.hash
  end

  def <=> other
    return 0 if self == other
    return -1 if self.str < other.str
    return 1
  end
end
