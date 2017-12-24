module Pomodoro
  module Tools
    def self.format_path(path)
      path.sub(ENV['HOME'], '~')
    end

    def self.unsentence(possible_sentense)
      possible_sentense.sub(/^(.)(.+)\.$/) do
        "#{$1.downcase}#{$2}"
      end
    end
  end
end
