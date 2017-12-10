require 'spec_helper'
require 'pomodoro/formats/today'

describe Pomodoro::Formats::Today::TimeFrame do
  describe '.new' do
    it "requires the name keyword argument" do
      expect { described_class.new }.to raise_error(
        ArgumentError, /missing keyword: name/)
    end

    it "requires the name keyword argument" do
      expect { described_class.new(name: 'Morning routine') }.to raise_error(
        ArgumentError, /At least one of start_time and end_time has to be provided./)
    end

    it "fails if start time or end time is not an Hour instance" do
      expect {
        described_class.new(name: 'X', start_time: Time.now, tasks: Hash.new)
      }.to raise_error(ArgumentError, /Start time and end time has to be an Hour instance/)

      expect {
        described_class.new(name: 'X', end_time: 30, tasks: Hash.new)
      }.to raise_error(ArgumentError, /Start time and end time has to be an Hour instance/)
    end

    it "fails if tasks is not an array" do
      expect {
        described_class.new(name: 'X', start_time: Hour.parse('7:50'), tasks: Hash.new)
      }.to raise_error(ArgumentError, /Data is supposed to be an array of Task instances/)
    end

    it "fails if tasks is not an array of task-like objects" do
      expect {
        described_class.new(name: 'X', start_time: Hour.parse('7:50'), tasks: [Object.new])
      }.to raise_error(ArgumentError, /Data is supposed to be an array of Task instances/)
    end

    it "succeeds when name and start_time is provided" do
      time_frame = described_class.new(name: 'Morning routine', start_time: Hour.parse('7:50'))
      expect(time_frame.name).to eql('Morning routine')
      expect(time_frame.start_time.to_s).to eql('7:50')
      expect(time_frame.tasks).to be_empty
    end
  end

  subject do
    described_class.new(name: 'Morning routine', start_time: Hour.parse('7:50'), tasks: [
      Pomodoro::Formats::Today::Task.new(status: :done, body: 'Headspace.')
    ])
  end

  describe '#to_s' do
    context "with tasks" do
      it "returns a valid today task list formatted string" do
        pending "Task is broken"
        expect(subject.to_s).to eql("Morning routine (from 7:50)\n✔ Headspace.\n")
      end
    end

    context "without any tasks" do
      subject do
        described_class.new(name: 'Morning routine', start_time: Hour.parse('7:50'))
      end

      it "returns a valid today task list formatted string" do
        expect(subject.to_s).to eql("Morning routine (from 7:50)\n")
      end
    end
  end
end
