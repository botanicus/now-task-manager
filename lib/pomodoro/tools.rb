module Pomodoro
  module Tools
    def self.unsentence(possible_sentense)
      possible_sentense.sub(/^(.)(.+)\.$/) do
        "#{$1.downcase}#{$2}"
      end
    end
  end
end
