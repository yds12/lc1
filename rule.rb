# Represents a rule in a context free grammar
class GrammarRule
  attr_accessor :head, :body, :p, :lexicon, :count
  attr_reader :str

  def initialize head, body, lexicon, p=1.0
    @head = head
    @p = p
    @lexicon = lexicon
    @count = 1

    @body = body.clone

    generate_str
    generate_hash
  end

  def generate_str
    @str = "#{@head} ::= #{@body.join ' '}"
  end

  def generate_hash
    @_hash = @str.hash
  end

  def to_s
    @str
  end

  def == other
    other.instance_of?(self.class) && @_hash == other.hash
      # && @str == other.str
  end

  alias_method :eql?, :==

  def hash
    @_hash
  end

  def <=> other
    return 0 if self == other
    return -1 if self.str < other.str
    return 1
  end
end
