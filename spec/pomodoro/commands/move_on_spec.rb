# frozen_string_literal: true

# Status: unsure whether we want it https://github.com/botanicus/now-task-manager/issues/121

require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::MoveOn do
  include_examples(:has_description)
  include_examples(:has_help)

  it "Might have specs, but so far this is not being used."
end
