# require 'parslet/rig/rspec'

require 'date'
require 'ostruct'
require 'timecop'

require 'coveralls'
Coveralls.wear!

# TODO: use 'using'.
require 'parslet'
class Parslet::Slice
  def eql?(slice_or_string)
    self.to_s == slice_or_string.to_s
  end
end

class ExecutionFinished < StandardError
end

module CLITestHelpers
  def self.extended(base)
    base.define_singleton_method(:sequence) do
      @sequence ||= Array.new
    end
  end

  def p(object)
    self.sequence << {p: object}
  end

  def print(message)
    self.sequence << {stdout: message}
  end

  def puts(message)
    self.sequence << {stdout: message}
  end

  def warn(message)
    self.sequence << {warn: message}
  end

  def abort(message)
    self.sequence << {abort: message}
    raise ExecutionFinished
  end

  def command(command)
    self.sequence << {command: command}
  end

  def exit(value = nil)
    self.sequence << {exit: value}
    raise ExecutionFinished
  end
end

require 'support/shared_command_examples'

RSpec.configure do |rspec|
  # Tag examples with :focus to run only the selected ones.
  rspec.filter_run_including focus: true
  rspec.run_all_when_everything_filtered = true

  rspec.include Module.new {
    def h(string)
      Hour.parse(string)
    end

    def run(command)
      command.run
      command.sequence << {exit: 0}
    rescue Pomodoro::Config::ConfigError => error
      command.sequence << {abort: error}
    rescue ExecutionFinished
    end
  }

  rspec.around(:each, :valid_command) do |example|
    File.open(config.today_path, 'w') do |file|
      file.puts(data)
    end

    example.run

    begin
      File.unlink(config.today_path)
    rescue Errno::ENOENT
      warn "~ No #{config.today_path} found."
    end
  end
end
