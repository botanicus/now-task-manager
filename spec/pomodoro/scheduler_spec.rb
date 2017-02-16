require 'pomodoro/scheduler'

describe Pomodoro::Scheduler do
  describe '.load' do
    it 'loads schedules from given path' do
      expect { described_class.load('spec/data/schedule.rb') }.not_to raise_error
    end
  end

  subject do
    described_class.load('spec/data/schedule.rb')
  end

  describe '#for_today' do
    it 'xxxxx' do
      p subject.for_today
    end
  end
end