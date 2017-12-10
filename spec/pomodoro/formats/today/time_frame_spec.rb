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

      it "returns a valid scheduled task list formatted string" do
        expect(subject.to_s).to eql("Morning routine (from 7:50)\n")
      end
    end
  end
end
