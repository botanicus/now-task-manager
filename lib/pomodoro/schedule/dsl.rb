require 'date'
require 'ostruct'
require 'pomodoro/formats/today'

module Pomodoro
  module Schedule
    class Thing
      attr_reader :name
      def initialize(name, condition, &block)
        @name, @condition, @callable = name, condition, block
      end

      def true?(*args)
        @condition.call(*args)
      end

      def call(tasks)
        @callable.call(tasks)
      end
    end

    class Rule < Thing
    end

    class Schedule < Thing
      def call
        day = Pomodoro::Formats::Today::Day.new
        @callable.call(day)
        day
      end
    end

    class DSL
      include Pomodoro::Formats::Today

      attr_reader :rules, :schedules, :today
      def initialize(schedule_dir, today = Date.today)
        @schedule_dir, @today = schedule_dir, today
        @rules, @schedules = Array.new, Array.new

        today.define_singleton_method(:weekend?) do # TODO: Put elsewhere.
          self.saturday? || self.sunday?
        end
      end

      alias_method :_require, :require
      def require(schedule)
        path = File.expand_path("#{@schedule_dir}/#{schedule}.rb")
        self.instance_eval(File.read(path), path)
      rescue Errno::ENOENT # require 'pry'
        _require schedule
      end

      def schedule(name, condition, &block)
        @schedules << Schedule.new(name, condition, &block)
      end

      def rule(name, condition, &block)
        @rules << Rule.new(name, condition, &block)
      end

      def config
        @config ||= OpenStruct.new(YAML.load_file(self.config_path))
      end

      def config_path
        File.expand_path("#{@schedule_dir}/config.yml")
      end

      def h(hour)
        Hour.parse(hour) if hour
      end

      def time_frame(name, start_time = nil, end_time = nil)
        TimeFrame.new(name: name, start_time: h(start_time), end_time: h(end_time))
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
