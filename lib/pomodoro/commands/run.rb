require 'shellwords'

# TODO: Later refactor to be part of start.
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
      unless @matcher
        abort t(:no_matcher_found, task: next_task)
      end
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

  rescue Pomodoro::Config::ConfigError => error
    abort error
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
end
