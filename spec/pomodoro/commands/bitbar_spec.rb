require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::BitBar do
  describe '.help' do
    it "does not have it" do
      expect(described_class.help).to be_nil
    end
  end
end
