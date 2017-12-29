require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::BitBar do
  include_examples(:is_out_of_main_help)
end
