module Pomodoro
  module Tools
    def self.unsentence(possible_sentense)
      words = possible_sentense.split(' ')

      if words[0].match(/^[A-Z][a-z]+$/)
        words[0].sub!(/^(.)/) { $1.downcase }
      end

      words.join(' ').chomp('.')
    end
  end
end
