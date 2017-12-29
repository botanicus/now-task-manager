require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Next_Done do
  include_examples(:has_description)
  include_examples(:has_help)

  context "with an active task" do
  end

  context "with no active task" do
  end
end
