# Simulate a error prone human typist
# Assumes typographical errors are Poisson distributed and
# each error is either a deletion, insertion, or transposition
module TreeSpell
  require_relative 'change_word'
  class HumanTypo
    LAMBDA = 0.05 # The typographical error rate of the Poisson distribution

    def initialize(input)
      @input = input
      check_input
      @len = input.length
    end

    def call
      @word = input.dup
      i_place = initialize_i_place
      loop do
        action = action_type
        @word = make_change action, i_place
        @len = word.length
        i_place += exponential
        break if i_place >= len
      end
      word
    end

    private

    attr_accessor :input, :word, :len

    def initialize_i_place
      i_place = nil
      loop do
        i_place = exponential
        break if i_place < len
      end
      i_place
    end

    def exponential(lambda = LAMBDA)
      (rand / (lambda / 2)).to_i
    end

    def rand_char
      popular_chars =  alphabetic_characters + special_characters
      n = popular_chars.length
      popular_chars[rand(n)]
    end

    def alphabetic_characters
      ('a'..'z').to_a.join + ('A'..'Z').to_a.join
    end

    def special_characters
      '?<>,.!`+=-_":;@#$%^&*()'
    end

    def toss
      return +1 if rand >= 0.5
      -1
    end

    def action_type
      [:insert, :transpose, :delete, :substitute][rand(3)]
    end

    def make_change(action, i_place)
      cw = ChangeWord.new(word)
      case action
      when :delete
        cw.deletion(i_place)
      when :insert
        cw.insertion(i_place, rand_char)
      when :substitute
        cw.substitution(i_place, rand_char)
      when :transpose
        cw.transposition(i_place, toss)
      end
    end

    def check_input
      fail check_input_message if input.nil? || input.length < 5
    end

    def check_input_message
      "input length must be greater than 5 characters: #{input}"
    end
  end
end
