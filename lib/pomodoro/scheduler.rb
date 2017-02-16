require 'date'
require 'pomodoro/schedule/dsl'

module Pomodoro
  class Scheduler
    def self.load(schedule_path, today = Date.today)
      context = Pomodoro::Schedule::DSL.new(today)
      context.instance_eval(File.read(schedule_path))
      self.new(context)
    end

    def initialize(schedule)
      @schedule = schedule
    end

    def for_today(debug = false)
      Array.new.tap do |tasks|
        @schedule.rules.each do |name, rule|
          puts "~ Rule #{name} evaluated to #{rule.true?}" if debug
          rule.call(tasks) if rule.true?
        end
      end
    end

    def projects
      @schedule.projects
    end
  end
end
