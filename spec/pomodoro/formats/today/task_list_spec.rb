require 'spec_helper'
require 'pomodoro/formats/today'

describe Pomodoro::Formats::Today::TaskList do
  let(:task) do
    Pomodoro::Formats::Today::Task.new(status: :done, body: "Task 1.")
  end

  let(:time_frame) do
    Pomodoro::Formats::Today::TimeFrame.new(
      name: 'Morning routine', start_time: Hour.parse('7:50'), tasks: [task])
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

  subject do
    described_class.new(time_frame)
  end

  describe '#each' do
    it "returns an enumerator" do
      expect(subject.each).to be_kind_of(Enumerator)
    end

    it "yields time frames" do
      expect(subject.each.to_a).to eql([time_frame])
    end
  end

  describe '#each_task' do
    it "returns an enumerator" do
      expect(subject.each_task).to be_kind_of(Enumerator)
    end

    it "yields tasks" do
      expect(subject.each_task.to_a).to eql([task])
    end
  end

  describe '#duration' do
    context "all the time frames have start_time and end_time" do
      subject do
        described_class.new(
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Morning routine', start_time: Hour.parse('7:50'), end_time: Hour.parse('9:20')),
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Work', start_time: Hour.parse('9:20'), end_time: Hour.parse('17:20')))
      end

      it "returns the overall duration" do
        expect(subject.duration).to eql(Hour.parse('9:30'))
      end
    end

    context "with only start_time" do
      it "should be spec'd"
    end

    context "with only end_time" do
      it "should be spec'd"
    end
  end
end
