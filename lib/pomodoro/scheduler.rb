require 'date'
require 'refined-refinements/date'

require 'pomodoro/schedule/dsl'

module Pomodoro
  class Scheduler
    using RR::DateExts

    def self.load(schedule_path, today = Date.today)
      schedule_dir = File.expand_path("#{schedule_path}/..")
      context = Pomodoro::Schedule::DSL.new(schedule_dir, today)
      context.instance_eval(File.read(schedule_path), schedule_path)
      self.new(context)
    end

    def initialize(schedule)
      @schedule = schedule
    end

    def rules
      @schedule.rules
    end

    def schedules
      @schedule.schedules
    end

    def for_today(debug = false)
      Array.new.tap do |tasks|
        self.rules.each do |name, rule|
          puts "~ Rule #{name} evaluated to #{rule.true?}" if debug
          rule.call(tasks) if rule.true?
        end
      end
    end
  end
end
