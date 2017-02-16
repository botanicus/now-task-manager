require 'date'
require 'pomodoro/task'

module Pomodoro
  module Schedule
    class Rule
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

    module DateExts
      def weekend?
        self.saturday? || self.sunday?
      end

      def weekday?
        ! self.weekend?
      end
    end

    class DSL
      attr_reader :rules, :projects, :today
      def initialize(today = Date.today)
        today.extend(DateExts)
        @rules = Hash.new
        @projects = Array.new
        @today = today
      end

      def require(schedule)
        path = File.expand_path("~/.config/pomodoro/schedules/#{schedule}.rb")
        self.instance_eval(File.read(path))
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

      def project(project)
        @projects << project
      end

      def random_project
        @projects[rand(@projects.length)]
      end

      def project_of_the_week_path
        File.expand_path('~/Dropbox/WIP/project_of_the_week.txt')
      end

      # TODO: load past projects of the week to make sure we're not repeating.
      # TODO: possibly store in tasks.todo as well.
      def project_of_the_week
        unless File.exists?(project_of_the_week_path)
          File.open(project_of_the_week_path, 'w') { |f| f.puts(random_project) }
        end
        File.read(project_of_the_week_path).chomp
      end

      def switch_project_of_the_week
        File.unlink(project_of_the_week_path)
      end
    end
  end
end
