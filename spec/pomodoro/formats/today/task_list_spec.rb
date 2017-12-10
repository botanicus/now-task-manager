require 'spec_helper'
require 'pomodoro/formats/today'

describe Pomodoro::Formats::Today::TaskList do
  let(:time_frame) do
    Pomodoro::Formats::Today::TimeFrame.new(
      name: 'Morning routine', start_time: Hour.parse('7:50'))
  end

  describe '.new' do
    it "instantiate with an empty list of time frames" do
      expect { described_class.new }.not_to raise_error
    end

    it "fails if non-array is provided" do
      expect { described_class.new(Hash.new) }.to raise_error(
        ArgumentError, /Time frames is supposed to be an array of TimeFrame-like instances/)
    end

    it "fails if an array of objects that don't behave like time frames is provided" do
      expect { described_class.new(Object.new) }.to raise_error(
        ArgumentError, /Time frames is supposed to be an array of TimeFrame-like instances/)
    end

    it "instantiate with a list of time frames" do
      expect { described_class.new(time_frame) }.not_to raise_error
    end

    it "instantiate with a list of time frames and creates accessors for them" do
      task_list = described_class.new(time_frame)
      expect(task_list.morning_routine).to eql(time_frame)
    end
  end
end
