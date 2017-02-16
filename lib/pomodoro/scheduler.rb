require 'pomodoro/schedule/dsl'

module Pomodoro
  class Scheduler
    def self.load(schedule_path)
      context = Pomodoro::Schedule::DSL.new
      context.instance_eval(File.read(schedule_path))
    end
  end
end
