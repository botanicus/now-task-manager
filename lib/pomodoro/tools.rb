module Pomodoro
  module Tools
    def self.format_path(path)
      path.sub(ENV['HOME'], '~')
    end
  end
end
