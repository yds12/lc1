# Reads the file containing the trees and breaks it into tokens
class Tokenizer
  CorpusEncoding = 'iso-8859-15'

  def initialize file
    @tokens = []
    @file_handle = File.open(file, "r:#{CorpusEncoding}")
    @last_token = nil
    @cur_token = ''
  end

  # Gets the next token
  def next
    if @tokens.empty?
      while line = @file_handle.gets
        add_tokens line
        return @tokens.shift unless line.strip.empty?
      end

      @file_handle.close
      return nil
    end

    @tokens.shift
  end

private

  def id? token
    not ([:open, :close, nil].include? token)
  end

  def special? token
    token.strip.empty? or ['(', ')'].include? token
  end

  # Breaks up the next file line into tokens
  def add_tokens line
    s = line.strip

    s.chars.each do |c|
      if special? c
        flush c
      else
        @cur_token << c
      end
    end

    flush nil
  end

  # Add all characters read to the tokens list
  def flush last_char
    add_cur_token
    add_last_char last_char
    @cur_token = ''
  end

  # Add the current accumulated characters to the tokens list
  def add_cur_token
    unless @cur_token.empty?
      terminal = id?(@cur_token) && id?(@last_token)

      @tokens << :open if terminal 
      @tokens << @cur_token
      @tokens << :close if terminal 
      @last_token = @tokens[-1]
    end
  end

  # Add the last character read to the tokens list
  def add_last_char last_char
    if ['(', ')'].include? last_char
      @tokens << :open if last_char == '('
      @tokens << :close if last_char == ')'
      @last_token = @tokens[-1]
    end
  end
end
