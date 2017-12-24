require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::MoveOn do
  include_examples(:has_help)

  it "Might have specs, but so far this is not being used."
end
