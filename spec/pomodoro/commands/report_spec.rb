# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Report do
  include_examples(:has_description)
  include_examples(:has_help)
end
