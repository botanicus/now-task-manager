require 'spec_helper'
require 'pomodoro/commands'

describe Pomodoro::Commands::Console do
  include_examples(:has_description)
  include_examples(:has_help)

  # The rest we won't be specing.
end
