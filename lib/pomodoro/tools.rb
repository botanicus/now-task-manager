# frozen_string_literal: true

module Pomodoro
  module Tools
    def self.unsentence(possible_sentense)
      words = possible_sentense.split(' ')

      if words[0] =~ /^[A-Z][a-z]+$/
        words[0].sub!(/^(.)/) { Regexp.last_match(1).downcase }
      end

      words.join(' ').chomp('.')
    end
  end
end
