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

module CLITestHelpers
  def self.extended(base)
    base.define_singleton_method(:sequence) do
      @sequence ||= Array.new
    end
  end

  def p(object)
    self.sequence << {p: object}
  end

  def puts(message)
    self.sequence << {stdout: message}
  end

  def warn(message)
    self.sequence << {warn: message}
  end

  def abort(message)
    self.sequence << {abort: message}
  end

  def command(command)
    self.sequence << {command: message}
  end

  def exit(value = nil)
    self.sequence << {exit: value}
  end
end

RSpec.configure do |config|
  config.include Module.new {
    def h(string)
      Hour.parse(string)
    end
  }
end
