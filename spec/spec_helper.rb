# require 'parslet/rig/rspec'

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
    self.sequence << {stdout: message} # TODO: "#{message}\n"
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

# shared_examples_for(:command_with_help) do
#   describe '.help' do
#     it "has it" do
#       expect(described_class).to respond_to(:help)
#       expect(described_class.help.length).not_to be(0)
#     end
#   end
# end
#
# shared_examples_for(:command_requiring_config) do
# end

RSpec.configure do |config|
  config.include Module.new {
    def h(string)
      Hour.parse(string)
    end

    def run(command)
      command.run
    rescue ExecutionFinished
    end
  }
end
