# frozen_string_literal: true

require 'shellwords'

# TODO: Later refactor to be part of start.
# https://github.com/botanicus/now-task-manager/issues/120
class Pomodoro::Commands::Run < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>run</magenta> <bright_black># ...</bright_black>
  EOF

  def run
    ensure_today

    command_file_path = File.expand_path('~/Dropbox/Data/Data/Pomodoro/Schedules/commands.rb')
    dsl = NamedCommandDSL.new
    dsl.instance_eval(File.read(command_file_path))

    edit_next_task_when_no_task_active(self.config) do |next_task|
      @matcher = dsl.matchers.find { |matcher| matcher.true?(next_task) }
      abort t(:no_matcher_found, task: next_task) unless @matcher
    end

    Pomodoro::Commands::Start.new(['--no-wait']).run

    begin
      with_active_task(self.config) do |active_task|
        @matcher.call(active_task)
      end
    rescue Interrupt
    ensure
      Pomodoro::Commands::Done.new(Array.new).run
    end
  end
end

class NamedCommandDSL
  class Thing # Copied.
    attr_reader :name
    def initialize(name, condition, &block)
      @name, @condition, @callable = name, condition, block
    end

    def true?(*args)
      @condition.call(*args)
    end

    def call(task)
      @callable.call(task)
    end
  end

  class Matcher < Thing
  end

  attr_reader :matchers
  def initialize
    @matchers = Array.new
  end

  def match(name, condition, &block)
    self.matchers << Matcher.new(name, condition, &block)
  end

  def sh(command)
    system("zsh -c '#{command}'") # TODO: use shell words
  rescue Interrupt
  end

  # TODO: Copied from dsl.rb, use a mixin. AND un-hard-code the path below.
  def config
    @config ||= OpenStruct.new(YAML.load_file(self.config_path))
  end

  def config_path
    File.expand_path("/Users/botanicus/Dropbox/Data/Data/Pomodoro/Schedules/config.yml")
  end
end
