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

RSpec.configure do |config|
  config.include Module.new {
    def h(string)
      Hour.parse(string)
    end
  }
end
