require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::TickOffNext do
  include_examples(:has_help)

  context "with an active task" do
  end

  context "with no active task" do
  end
end
