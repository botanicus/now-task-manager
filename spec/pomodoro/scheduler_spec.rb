require 'spec_helper'
require 'pomodoro/scheduler'

describe Pomodoro::Scheduler do
  describe '.load' do
    it 'loads schedules from given path' do
      # expect { described_class.load('spec/data/schedule.rb') }.not_to raise_error
    end

    # TODO: the date argument.
  end

  subject do
    described_class.load('spec/data/schedule.rb')
  end

  # TODO: Rename this method, it is not for today.
  describe '#for_today' do
    it 'xxxxx' do
      pending; raise subject.for_today.inspect
    end
  end
end
