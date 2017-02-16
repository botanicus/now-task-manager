require 'date'
require 'pomodoro/schedule/dsl'

module Pomodoro
  class Scheduler
    def self.load(schedule_path)
      context = Pomodoro::Schedule::DSL.new
      context.instance_eval(File.read(schedule_path))
      self.new(context)
    end

    def initialize(schedule)
      @schedule = schedule
    end

    def for_today(today = Date.today)
      Array.new.tap do |tasks|
        @schedule.rules.each do |name, rule|
          rule.call(tasks) if rule.true?
        end
      end
    end

    def projects
      @schedule.projects
    end
  end
end
