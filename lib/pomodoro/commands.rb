require 'date'
require 'pomodoro'
require 'refined-refinements/colours'
require 'refined-refinements/cli/commander'

module Pomodoro
  module Commands
    module EnvironmentCommunication
      using RR::ColourExts

      [:puts, :print, :warn, :abort].each do |method_name|
        define_method(method_name) do |*args|
          Kernel.send(method_name, *args.map do |argument|
            argument.is_a?(String) ? argument.colourise : argument
          end)
        end
      end

      def command(command)
        system(command)
      end
    end

    class Command < RR::Command
      include EnvironmentCommunication

      attr_reader :config
      def initialize(args, config = nil)
        @args, @config = args, config || Pomodoro.config
      end

      def get_date
        case (res = @args.grep(/^[-+]\d$/)).length
        when 0
          Date.today
        when 1
          @args.delete(res[0])
          Date.today + res[0].to_i
        else
          raise ArgumentError.new("TODO")
        end
      end

      def must_exist(path, additional_info = nil)
        unless File.exist?(path)
          abort ["<red>! File #{Pomodoro::Tools.format_path(path)} doesn't exist.</red>", additional_info].compact.join("\n  ")
        end
      end

      def ensure_today(*args)
        unless self.config.today_path
          raise Pomodoro::Config::ConfigError.new('today_path')
        end

        self.must_exist(self.config.today_path(*args), "Run the <yellow>g</yellow> command first.")
      end

      def ensure_task_list
        unless self.config.task_list_path
          raise Pomodoro::Config::ConfigError.new('task_list_path')
        end

        self.must_exist(self.config.task_list_path)
      end

      def parse_today_list(config)
        day = Pomodoro::Formats::Today.parse(File.new(config.today_path, encoding: 'utf-8'))

        if (active_tasks = day.task_list.each_task.select(&:in_progress?)).length > 1
          raise "There are 2 active tasks: #{active_tasks}"
        end

        day
      end

      def parse_task_list(config)
        Pomodoro::Formats::Scheduled.parse(File.new(config.task_list_path, encoding: 'utf-8'))
      end

      def time_frame(config = self.config, &block)
        day = parse_today_list(config)

        unless current_time_frame = day.task_list.current_time_frame
          abort "<red>There is no active time frame.</red>"
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
            abort "<red>There is an active task already:</red> #{active_task.body}"
          end

          if next_task = current_time_frame.first_unstarted_task
            block.call(next_task)
            day.save(config.today_path)
          else
            abort "<red>No more tasks in #{current_time_frame.name}</red>"
          end
        end
      end
    end
  end

  class Commander < RR::Commander
    def help_template
      super('Now task manager')
    end

    # Formatters.
    require 'pomodoro/commands/active'
    self.command(:active, Commands::Active)

    require 'pomodoro/commands/next'
    self.command(:next, Commands::Next)

    # Action on an active tasks.
    require 'pomodoro/commands/start'
    self.command(:start, Commands::Start)

    require 'pomodoro/commands/done'
    self.command(:done, Commands::Done)

    require 'pomodoro/commands/move_on'
    self.command(:move_on, Commands::MoveOn)

    require 'pomodoro/commands/postpone'
    self.command(:postpone, Commands::Postpone)

    # Action on tasks (without starting them).
    require 'pomodoro/commands/fail-next'
    self.command(:'fail-next', Commands::FailNext)

    require 'pomodoro/commands/postpone-next'
    self.command(:'postpone-next', Commands::PostponeNext)

    require 'pomodoro/commands/tick-off-next'
    self.command(:'tick-off-next', Commands::TickOffNext)

    # Generate & edit.
    require 'pomodoro/commands/edit'
    self.command(:e, Commands::Edit)

    require 'pomodoro/commands/generate'
    self.command(:g, Commands::Generate)

    require 'pomodoro/commands/add'
    self.command(:+, Commands::Add)

    require 'pomodoro/commands/generate-upcoming-events'
    self.command(:'generate-upcoming-events', Commands::GenerateUpcomingEvents)

    require 'pomodoro/commands/log'
    self.command(:log, Commands::Log)

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
  end
end
