require 'spec_helper'
require 'pomodoro/formats/today'

describe Pomodoro::Formats::Today::TaskList do
  let(:task) do
    Pomodoro::Formats::Today::Task.new(status: :done, body: "Task 1.")
  end

  let(:time_frame) do
    Pomodoro::Formats::Today::TimeFrame.new(
      name: 'Morning routine', start_time: h('7:50'), tasks: [task])
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
      # Morning routine (7:50 – 9:20)
      # Work (9:20 – 17:20)
      subject do
        described_class.new(
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Morning routine', start_time: h('7:50'), end_time: h('9:20')),
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Work', start_time: h('9:20'), end_time: h('17:20')))
      end

      it "returns the overall duration" do
        expected_duration = h('17:20') - h('7:50')
        expect(subject.duration).to eql(expected_duration)
      end
    end

    context "with some start_times and end_times missing" do
      context "all the times can be determined" do
        # Morning routine (from 7:50)
        # Work (9:20 – 17:20)
        # Evening reflection (until 21:00)
        subject do
          described_class.new(
            Pomodoro::Formats::Today::TimeFrame.new(
              name: 'Morning routine', start_time: h('7:50')),
            Pomodoro::Formats::Today::TimeFrame.new(
              name: 'Work', start_time: h('9:20'), end_time: h('17:20')),
            Pomodoro::Formats::Today::TimeFrame.new(
              name: 'Evening reflection', end_time: h('21:00')))
        end

        it "returns the overall duration" do
          expected_duration = h('21:00') - h('7:50')
          expect(subject.duration).to eql(expected_duration)
        end
      end

      context "all the times can be determined or defaults used" do
        # Morning routine (until 9:20)
        # Work (until 17:20)
        subject do
          described_class.new(
            Pomodoro::Formats::Today::TimeFrame.new(
              name: 'Morning routine', end_time: h('9:20')),
            Pomodoro::Formats::Today::TimeFrame.new(
              name: 'Work', end_time: h('17:20')))
        end

        it "returns the overall duration" do
          expected_duration = h('17:20') - h('0:00')
          expect(subject.duration).to eql(expected_duration)
        end
      end

      context "some of the the times cannot be determined" do
        subject do
          described_class.new(
            Pomodoro::Formats::Today::TimeFrame.new(
              name: 'Morning routine'),
            Pomodoro::Formats::Today::TimeFrame.new(
              name: 'Work', end_time: h('17:20')))
        end

        it "fails with a DataInconsistencyError" do
          expect { subject.duration }.to raise_error(
            Pomodoro::Formats::Today::DataInconsistencyError)
        end
      end
    end
  end

  describe '#with_prev_and_next' do
    context "if there are no time frames" do
      subject do
        described_class.new
      end

      it do
        enumerator = subject.with_prev_and_next
        expect { enumerator.next }.to raise_error(StopIteration)
      end
    end

    context "if there is only one time frame" do
      subject do
        described_class.new(
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Morning routine', start_time: h('7:50')))
      end

      it do
        enumerator = subject.with_prev_and_next

        first_iteration = enumerator.next
        expect(first_iteration.length).to be(3)
        expect(first_iteration[0]).to be(nil)
        expect(first_iteration[1].name).to eql("Morning routine")
        expect(first_iteration[2]).to be(nil)

        expect { enumerator.next }.to raise_error(StopIteration)
      end
    end

    context "if there is are two time frames" do
      subject do
        described_class.new(
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Morning routine', start_time: h('7:50')),
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Work', start_time: h('9:20'), end_time: h('17:20')))
      end

      it do
        enumerator = subject.with_prev_and_next

        first_iteration = enumerator.next
        expect(first_iteration.length).to be(3)
        expect(first_iteration[0]).to be(nil)
        expect(first_iteration[1].name).to eql("Morning routine")
        expect(first_iteration[2].name).to eql("Work")

        second_iteration = enumerator.next
        expect(second_iteration.length).to be(3)
        expect(second_iteration[0].name).to eql("Morning routine")
        expect(second_iteration[1].name).to eql("Work")
        expect(second_iteration[2]).to be(nil)

        expect { enumerator.next }.to raise_error(StopIteration)
      end
    end

    context "if there is more than two time frames" do
      subject do
        described_class.new(
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Morning routine', start_time: h('7:50')),
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Work', start_time: h('9:20'), end_time: h('17:20')),
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Evening reflection', end_time: h('21:00')))
      end

      it do
        enumerator = subject.with_prev_and_next

        first_iteration = enumerator.next
        expect(first_iteration.length).to be(3)
        expect(first_iteration[0]).to be(nil)
        expect(first_iteration[1].name).to eql("Morning routine")
        expect(first_iteration[2].name).to eql("Work")

        second_iteration = enumerator.next
        expect(second_iteration.length).to be(3)
        expect(second_iteration[0].name).to eql("Morning routine")
        expect(second_iteration[1].name).to eql("Work")
        expect(second_iteration[2].name).to eql("Evening reflection")

        last_iteration = enumerator.next
        expect(last_iteration.length).to be(3)
        expect(last_iteration[0].name).to eql("Work")
        expect(last_iteration[1].name).to eql("Evening reflection")
        expect(last_iteration[2]).to be(nil)

        expect { enumerator.next }.to raise_error(StopIteration)
      end
    end
  end

  describe '#active_task' do
    context "with an active task" do
      subject do
        described_class.new(
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Morning routine', end_time: h('9:20')),
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Work', end_time: h('17:20'), tasks: [
              Pomodoro::Formats::Today::Task.new(status: :done, body: "Task 1."),
              Pomodoro::Formats::Today::Task.new(status: :failed, body: "Task 1.", start_time: h('15:00'), end_time: h('15:25')),
              Pomodoro::Formats::Today::Task.new(status: :not_done, body: "Task 2.", start_time: h('15:30')),
              Pomodoro::Formats::Today::Task.new(status: :not_done, body: "Task 3."),
            ]))
      end

      it "returns the first (and hopefuly only) started task" do
        expect(subject.active_task.body).to eql("Task 2.")
      end
    end

    context "without an active task" do
      subject do
        described_class.new(
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Morning routine', end_time: h('9:20')),
          Pomodoro::Formats::Today::TimeFrame.new(
            name: 'Work', end_time: h('17:20'), tasks: [
              Pomodoro::Formats::Today::Task.new(status: :done, body: "Task 1."),
              Pomodoro::Formats::Today::Task.new(status: :failed, body: "Task 1.", start_time: h('15:00'), end_time: h('15:25')),
              Pomodoro::Formats::Today::Task.new(status: :done, body: "Task 2."),
              Pomodoro::Formats::Today::Task.new(status: :done, body: "Task 3."),
            ]))
      end

      it "returns nil" do
        expect(subject.active_task).to be(nil)
      end
    end
  end

  describe '#current_time_frame' do
    subject do
      described_class.new(
        Pomodoro::Formats::Today::TimeFrame.new(
          name: 'Morning routine', start_time: h('7:50')),
        Pomodoro::Formats::Today::TimeFrame.new(
          name: 'Work', start_time: h('9:20'), end_time: h('17:20')),
        Pomodoro::Formats::Today::TimeFrame.new(
          name: 'Evening reflection', end_time: h('21:00')))
    end

    it "returns the active time frame" do
      expect(subject.current_time_frame(h('8:00')).name).to eql("Morning routine")

      # FIXME: this fails:
      # expect(subject.current_time_frame(h('9:20')).name).to eql("Morning routine")

      expect(subject.current_time_frame(h('9:21')).name).to eql("Work")
      expect(subject.current_time_frame(h('22:00'))).to be(nil)
    end
  end

  describe '#to_s' do
    it "has specs"
  end
end
