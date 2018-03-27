require 'date'
require 'refined-refinements/date'

require 'pomodoro/schedule/dsl'

module Pomodoro
  class Scheduler
    using RR::DateExts
    using RR::ColourExts

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
      self.schedules.each do |schedule|
        return schedule if schedule.true?
      end

      return nil
    end

    def populate_from_rules(task_list, schedule: nil, apply_rules: [], remove_rules: [])
      self.rules.each do |rule|
        if rule.true?(schedule)
          puts "~ Invoking rule <green>#{rule.name}</green>.".colourise
          rule.call(task_list)
        end
      end
    end
  end
end
