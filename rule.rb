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
end
