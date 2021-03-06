# frozen_string_literal: true

require 'date'
require 'pomodoro'
require 'pomodoro/tools'
require 'refined-refinements/colours'
require 'refined-refinements/cli/commander'

module Pomodoro
  module Commands
    module EnvironmentCommunication
      using RR::ColouredTerminal

      def abort(*args)
        if args.first.is_a?(Exception)
          super("<red>#{args.first.message}</red>")
        else
          super(*args)
        end
      end

      def command(command)
        system(command)
      end
    end

    module DataExts
      def prev_week
        self - 7
      end

      def next_week
        self + 7
      end

      def prev_quarter
        self.prev_month.prev_month.prev_month
      end

      def next_quarter
        self.next_month.next_month.next_month
      end
    end

    class Command < RR::Command
      include RR::ColouredTerminal
      include EnvironmentCommunication

      def command(command)
        system(command)
      end

      def self.command_name
        self.to_s.split('::').last.downcase
      end

      def self.description
        self.t(:description)
      rescue I18n::MissingTranslationData
      end

      def self.t(key, **options)
        I18n.t!("commands.#{self.command_name}.#{key}", **options)
      end

      attr_reader :config
      def initialize(args, config = nil)
        @args, @config = args, config || Pomodoro.config
      end

      def get_date_increment
        groups = @args.group_by { |argument| !!argument.match(/^[-+]\d$/) }
        @args = groups[false] || Array.new
        res = (groups[true] || Array.new).grep_v(/^[-+]0$/).map(&:to_i)

        case res.length
        when 0 then 0
        when 1 then res[0]
        else
          raise ArgumentError, "There cannot be more than 1 date indicator, was #{res.inspect}."
        end
      end

      def get_period_and_date(default_period = :day)
        increment = self.get_date_increment
        period = (@args.first && @args.shift || default_period).to_sym

        if increment == 0
          [period, Date.today]
        else
          today = Date.today.extend(DataExts)

          direction = (increment < 0) ? :prev : :next
          method_name = :"#{direction}_#{period}"

          unless today.respond_to?(method_name)
            raise ArgumentError, "Unknown period: #{period}"
          end

          result = increment.abs.times.reduce(today) do |last_result|
            last_result.send(method_name).extend(DataExts)
          end

          [period, result]
        end
      end

      def must_exist(path, additional_info = nil)
        unless File.exist?(path)
          abort ["<red>! File #{RR::Homepath.new(path)} doesn't exist.</red>", additional_info].compact.join("\n  ")
        end
      end

      def ensure_today(*args)
        raise Pomodoro::Config::ConfigError, 'today_path' unless self.config.today_path

        self.must_exist(self.config.today_path(*args), "Run the <yellow>g</yellow> command first.")
      end

      def ensure_task_list
        unless self.config.task_list_path
          raise Pomodoro::Config::ConfigError, 'task_list_path'
        end

        self.must_exist(self.config.task_list_path)
      end

      def parse_today_list(config)
        day = Pomodoro::Formats::Today.parse(File.new(config.today_path, encoding: 'utf-8'))

        if (active_tasks = day.task_list.each_task.select(&:in_progress?)).length > 1
          raise "There are 2 active tasks: #{active_tasks}"
        end

        day
      rescue Errno::ENOENT
        raise Pomodoro::Config::ConfigError
      end

      def parse_task_list(config)
        Pomodoro::Formats::Scheduled.parse(File.new(config.task_list_path, encoding: 'utf-8'))
      rescue Errno::ENOENT
        raise Pomodoro::Config::ConfigError
      end

      def time_frame(config = self.config, &block)
        day = parse_today_list(config)

        unless current_time_frame = day.task_list.current_time_frame
          abort t(:no_active_time_frame)
        end

        block.call(day, current_time_frame)
      end

      def with_active_task(config, &block)
        day = parse_today_list(config)
        if active_task = day.task_list.active_task
          block.call(active_task)
          day.save(config.today_path)
          return true
        else
          return false
        end
      end

      def edit_next_task_when_no_task_active(config, &block)
        time_frame(config) do |day, current_time_frame|
          if active_task = day.task_list.active_task
            abort t(:task_in_progress, task: active_task.body)
          end

          if next_task = current_time_frame.first_unstarted_task
            block.call(next_task, current_time_frame)
            day.save(config.today_path)
          else
            abort t(:no_more_tasks_in_time_frame, time_frame: current_time_frame.name)
          end
        end
      end

      def t(key, **options)
        I18n.t!("commands.#{self.class.command_name}.#{key}", **options)
      rescue I18n::MissingTranslationData
        I18n.t!("commands.generic.#{key}", **options)
      end
    end
  end

  class Commander < RR::Commander
    include Pomodoro::Commands::EnvironmentCommunication

    def help_template
      super('Now task manager')
    end

    def run(*args)
      super(*args)
    rescue Pomodoro::Config::ConfigError => error # TODO: Add NoTaskInProgress and more.
      abort error
    end

    # Formatters.
    require 'pomodoro/commands/active'
    self.command(:active, Commands::Active)

    # Action on an active tasks.
    require 'pomodoro/commands/start'
    self.command(:start, Commands::Start)

    require 'pomodoro/commands/done'
    self.command(:done, Commands::Done)

    require 'pomodoro/commands/reset'
    self.command(:reset, Commands::Reset)

    require 'pomodoro/commands/move_on'
    self.command(:move_on, Commands::MoveOn)

    require 'pomodoro/commands/postpone'
    self.command(:postpone, Commands::Postpone)

    require 'pomodoro/commands/fail'
    self.command(:fail, Commands::Fail)

    require 'pomodoro/commands/next'
    self.command(:next, Commands::Next)

    require 'pomodoro/commands/next_fail'
    self.command(:'next-fail', Commands::Next_Fail)

    require 'pomodoro/commands/next_postpone'
    self.command(:'next-postpone', Commands::Next_Postpone)

    require 'pomodoro/commands/next_done'
    self.command(:'next-done', Commands::Next_Done)

    # Generate & edit.
    require 'pomodoro/commands/edit'
    self.command(:e, Commands::Edit)

    require 'pomodoro/commands/generate'
    self.command(:g, Commands::Generate)

    require 'pomodoro/commands/add'
    self.command(:+, Commands::Add)

    require 'pomodoro/commands/config'
    self.command(:config, Commands::Config)

    require 'pomodoro/commands/commit'
    self.command(:commit, Commands::Commit)

    require 'pomodoro/commands/report'
    self.command(:report, Commands::Report)

    # Tools.
    require 'pomodoro/commands/console'
    self.command(:console, Commands::Console)

    require 'pomodoro/commands/show-schedule'
    self.command(:'show-schedule', Commands::ShowSchedule)

    require 'pomodoro/commands/plan'
    self.command(:plan, Commands::Plan)

    require 'pomodoro/commands/test'
    self.command(:test, Commands::Test)

    require 'pomodoro/commands/review'
    self.command(:review, Commands::Review)

    require 'pomodoro/commands/run'
    self.command(:run, Commands::Run)

    require 'pomodoro/commands/bitbar'
    self.command(:bitbar, Commands::BitBar)

    require 'pomodoro/commands/describe'
    self.command(:describe, Commands::Describe)

    require 'pomodoro/commands/expenses'
    self.command(:expenses, Commands::Expenses)

    require 'pomodoro/commands/consumption'
    self.command(:consumption, Commands::Consumption)
  end
end
