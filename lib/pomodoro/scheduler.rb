require 'date'
require 'refined-refinements/date'

require 'pomodoro/schedule/dsl'

module Pomodoro
  class Scheduler
    using RR::DateExts

    def self.load(paths, today = Date.today)
      dir = File.expand_path("#{paths.first}/..") # HACK This way we don't have to merge multiple contexts or reset its path.
      context = Pomodoro::Schedule::DSL.new(dir, today)
      paths.each do |path|
        context.instance_eval(File.read(path), path)
      end

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

    def schedule_for_date(date)
      self.schedules.each do |name, schedule|
        return schedule if schedule.true?
      end

      return nil
    end

    def populate_from_rules(task_list)
      self.rules.each do |rule_name, rule|
        rule.true? && rule.call(task_list)
      end
    end
  end
end
