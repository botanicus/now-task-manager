require 'date'
require 'pomodoro'
require 'refined-refinements/colours'
require 'refined-refinements/cli/commander'

module Pomodoro
  module Commands
    class Command < RR::Command
      attr_reader :config
      def initialize(args)
        @args, @config = args, Pomodoro.config
      end

      def must_exist(path)
        unless File.exist?(path)
          abort "<red>! File #{path.sub(ENV['HOME'], '~')} doesn't exist</red>".colourise
        end
      end

      def parse_today_list(config)
        day = Pomodoro::Formats::Today.parse(File.new(config.today_path, encoding: 'utf-8'))

        if (active_tasks = day.task_list.each_task.select(&:in_progress?)).length > 1
          raise "There are 2 active tasks: #{active_tasks}"
        end

        day.task_list
      end

      def parse_task_list(config)
        Pomodoro::Formats::Scheduled.parse(File.new(config.task_list_path, encoding: 'utf-8'))
      end

      def time_frame(config, &block)
        today_list = parse_today_list(config)

        unless current_time_frame = today_list.current_time_frame
          abort "<red>There is no active time frame.</red>".colourise
        end

        block.call(today_list, current_time_frame)
      end

      def with_active_task(config, &block)
        today_list = parse_today_list(config)
        if active_task = today_list.active_task
          block.call(active_task)
          today_list.save(config.today_path)
        end
      end

      def edit_next_task_when_no_task_active(config, &block)
        time_frame(config) do |today_list, current_time_frame|
          if active_task = today_list.active_task
            abort "<red>There is an active task already:</red> #{active_task.body}".colourise
          end

          if next_task = current_time_frame.first_unstarted_task
            block.call(next_task)
            today_list.save(config.today_path)
          else
            abort "<red>No more tasks in #{current_time_frame.name}</red>".colourise
          end
        end
      end
    end
  end

  class Commander < RR::Commander
    def help_template
      super('Now task manager')
    end

    require 'pomodoro/commands/active'
    self.command(:active, Commands::Active)

    require 'pomodoro/commands/add'
    self.command(:+, Commands::Add)

    require 'pomodoro/commands/bitbar'
    self.command(:bitbar, Commands::BitBar)

    require 'pomodoro/commands/config'
    self.command(:config, Commands::Config)

    require 'pomodoro/commands/console'
    self.command(:console, Commands::Console)

    require 'pomodoro/commands/done'
    self.command(:done, Commands::Done)

    require 'pomodoro/commands/edit'
    self.command(:e, Commands::Edit)

    require 'pomodoro/commands/fail-next'
    self.command(:'fail-next', Commands::FailNext)

    require 'pomodoro/commands/generate-upcoming-events'
    self.command(:'generate-upcoming-events', Commands::GenerateUpcomingEvents)

    require 'pomodoro/commands/generate'
    self.command(:g, Commands::Generate)

    require 'pomodoro/commands/move_on'
    self.command(:move_on, Commands::MoveOn)

    require 'pomodoro/commands/next'
    self.command(:next, Commands::Next)

    require 'pomodoro/commands/postpone-next'
    self.command(:'postpone-next', Commands::PostponeNext)

    require 'pomodoro/commands/postpone'
    self.command(:postpone, Commands::Postpone)

    require 'pomodoro/commands/review'
    self.command(:review, Commands::Review)

    require 'pomodoro/commands/start'
    self.command(:start, Commands::Start)

    require 'pomodoro/commands/tick-off-next'
    self.command(:'tick-off-next', Commands::TickOffNext)

    require 'pomodoro/commands/tools'
    self.command(:tools, Commands::Tools)
  end
end
