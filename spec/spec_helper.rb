# require 'parslet/rig/rspec'

require 'coveralls'
Coveralls.wear!

class Parslet::Slice
  def eql?(slice_or_string)
    self.to_s == slice_or_string.to_s
  end
end
