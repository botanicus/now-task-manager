require 'date'
require 'pomodoro/formats/today'

module Pomodoro
  module Schedule
    class Thing
      def initialize(condition, &block)
        @condition, @callable = condition, block
      end

      def true?
        @condition.call
      end

      def call(tasks)
        @callable.call(tasks)
      end
    end

    class Rule < Thing
    end

    class Schedule < Thing
      def call
        list = @callable.call
        TaskList.new(list)
      end
    end

    class DSL
      attr_reader :rules, :schedules, :today
      def initialize(schedule_dir, today = Date.today)
        @schedule_dir, @today = schedule_dir, today
        @rules, @schedules = Hash.new, Hash.new
      end

      alias_method :_require, :require
      def require(schedule)
        path = File.expand_path("#{@schedule_dir}/#{schedule}.rb")
        self.instance_eval(File.read(path), path)
      rescue Errno::ENOENT # require 'pry'
        _require schedule
      end

      def schedule(name, condition, &block)
        @schedules[name] = Schedule.new(condition, &block)
      end

      def rule(name, condition, &block)
        @rules[name] = Rule.new(condition, &block)
      end

      def last_day_of_a_month
        Date.new(today.year, today.month, -1)
      end

      def last_work_day_of_a_month
        if last_day_of_a_month.saturday?
          last_work_day_of_a_month = last_day_of_a_month.prev_day
        elsif last_day_of_a_month.sunday?
          last_work_day_of_a_month = last_day_of_a_month.prev_day.prev_day
        else
          last_work_day_of_a_month = last_day_of_a_month
        end
      end
    end
  end
end
