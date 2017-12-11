require 'spec_helper'
require 'pomodoro/formats/today'

describe Pomodoro::Formats::Today::TimeFrame do
  describe '.new' do
    it "requires the name keyword argument" do
      expect { described_class.new }.to raise_error(
        ArgumentError, /missing keyword: name/)
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
        described_class.new(name: 'X', start_time: h('7:50'), tasks: Hash.new)
      }.to raise_error(ArgumentError, /Tasks is supposed to be an array of Task instances/)
    end

    it "fails if tasks is not an array of task-like objects" do
      expect {
        described_class.new(name: 'X', start_time: h('7:50'), tasks: [Object.new])
      }.to raise_error(ArgumentError, /Tasks is supposed to be an array of Task instances/)
    end

    it "succeeds when name and start_time is provided" do
      time_frame = described_class.new(name: 'Morning routine', start_time: h('7:50'))
      expect(time_frame.name).to eql('Morning routine')
      expect(time_frame.start_time.to_s).to eql('7:50')
      expect(time_frame.tasks).to be_empty
    end
  end

  subject do
    described_class.new(name: 'Morning routine', start_time: h('7:50'), tasks: [
      Pomodoro::Formats::Today::Task.new(status: :done, body: 'Headspace.')
    ])
  end

  describe '#duration' do
    context "with both start_time and end_time" do
      subject do
        described_class.new(name: 'Morning routine',
          start_time: h('7:50'), end_time: h('9:20'))
      end

      it "returns the difference of start_time and end_time" do
        expected_duration = h('9:20') - h('7:50')
        expect(subject.duration).to eql(expected_duration)
      end
    end

    context "with only start_time" do
      it "raises an error unless the next_time_frame_start_time is provided" do
        expect { subject.duration }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError
        )
      end

      it "returns the duration if the next_time_frame_start_time is provided" do
        expected_duration = h('9:20') - subject.start_time
        expect(subject.duration(nil, h('9:20'))).to eql(expected_duration)
      end
    end

    context "with only end_time" do
      subject do
        described_class.new(name: 'Morning routine', end_time: h('9:20'))
      end

      it "raises an error unless the prev_time_frame_end_time is provided" do
        expect { subject.duration }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError
        )
      end

      it "returns the duration if the prev_time_frame_end_time is provided" do
        expected_duration = subject.end_time - h('7:50')
        expect(subject.duration(h('7:50'))).to eql(expected_duration)
      end
    end

    context "with neither provided" do
      subject do
        described_class.new(name: 'Morning routine')
      end

      it "raises an error unless the prev_time_frame_end_time and next_time_frame_end_time are both provided" do
        expect { subject.duration }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError)

        expect { subject.duration(nil, h('9:20')) }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError)

        expect { subject.duration(h('9:20'), nil) }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError)
      end

      it "returns the duration if the prev_time_frame_end_time is provided" do
        prev_time_frame_end_time = h('7:50')
        next_time_frame_end_time = h('9:20')
        expected_duration = next_time_frame_end_time - prev_time_frame_end_time
        expect(subject.duration(prev_time_frame_end_time, next_time_frame_end_time)).to eql(expected_duration)
      end

      it "raises an error if the start_time is bigger than the end_time" do
        incorrect_start_time = h('10:50')
        next_time_frame_end_time = h('9:20')
        expect { subject.duration(incorrect_start_time, next_time_frame_end_time) }.to raise_error(
          ArgumentError, /Start time cannot be bigger than end time/)
      end

      it "raises an error if the start_time is equal to the end_time" do
        expect { subject.duration(h('10:50'), h('10:50')) }.to raise_error(
          ArgumentError, /Start time cannot be bigger than end time/)
      end
    end
  end

  describe '#active?' do
    context "with both start_time and end_time" do
      subject do
        described_class.new(name: 'Morning routine',
          start_time: h('7:50'), end_time: h('9:20'))
      end

      it "returns a boolean if the current time frame is not active" do
        expect(subject).to     be_active(h('8:00'))
        expect(subject).not_to be_active(h('10:00'))
      end
    end

    context "with only start_time" do
      it "raises an error unless the next_time_frame_start_time is provided" do
        expect { subject.active?(Hour.now, h('7:50')) }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError
        )
      end

      it "returns a boolean if the next_time_frame_start_time is provided" do
        expect(subject.active?(h('8:00'), nil, h('9:20'))).to be(true)
        expect(subject.active?(h('9:50'), nil, h('9:20'))).to be(false)
      end
    end

    context "with only end_time" do
      subject do
        described_class.new(name: 'Morning routine', end_time: h('9:20'))
      end

      it "raises an error unless the prev_time_frame_end_time is provided" do
        expect { subject.active?(Hour.now, nil, h('9:20')) }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError
        )
      end

      it "returns a boolean if the prev_time_frame_end_time is provided" do
        expect(subject.active?(h('8:00'), h('7:50'))).to be(true)
      end
    end

    context "with neither provided" do
      subject do
        described_class.new(name: 'Morning routine')
      end

      it "raises an error unless the prev_time_frame_end_time and next_time_frame_end_time are both provided" do
        expect { subject.active? }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError)

        expect { subject.active?(Hour.now, nil, h('9:20')) }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError)

        expect { subject.active?(Hour.now, h('9:20'), nil) }.to raise_error(
          Pomodoro::Formats::Today::TimeFrameInsufficientTimeInfoError)
      end

      it "fails if the first argument is not an Hour instance" do
        expect { subject.active?(Time.now) }.to raise_error(
          ArgumentError, /Current time has to be an Hour instance, was Time/)
      end

      it "returns a boolean if the the arguments are correct" do
        expect(subject.active?(h('8:00'), h('7:50'), h('9:20'))).to be(true)
        expect(subject.active?(h('9:50'), h('7:50'), h('9:20'))).to be(false)
      end

      it "raises an error if the start_time is bigger than the end_time" do
        incorrect_start_time = h('10:50')
        next_time_frame_end_time = h('9:20')
        expect { subject.active?(Hour.now, incorrect_start_time, next_time_frame_end_time) }.to raise_error(
          ArgumentError, /Start time cannot be bigger than end time/)
      end

      it "raises an error if the start_time is equal to the end_time" do
        expect { subject.active?(Hour.now, h('10:50'), h('10:50')) }.to raise_error(
          ArgumentError, /Start time cannot be bigger than end time/)
      end
    end
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
        described_class.new(name: 'Morning routine', start_time: h('7:50'))
      end

      it "returns a valid today task list formatted string" do
        expect(subject.to_s).to eql("Morning routine (from 7:50)\n")
      end
    end
  end

  describe '#each' do
    it "returns an enumerator" do
      expect(subject.each).to be_kind_of(Enumerator)
    end
  end

  describe '#method_name' do
    it "returns a reasonable method name based on the name" do
      expect(subject.method_name).to eql(:morning_routine)
    end
  end
end
