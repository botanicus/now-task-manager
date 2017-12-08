require 'pomodoro/formats/today/task'

# TODO: Consider renaming #desc to #label.
describe Pomodoro::Formats::Today::Task do
  let(:start_time) { Hour.parse('10:00') }
  let(:end_time)   { Hour.parse('12:00') }

  describe '.new' do
    # This can mean 2 different things:
    # - [started at 9:20] Task XYZ. # Here status will be started.
    # - [9:20] Call Julia.          # Here status will be initial.
    it "allows start_time to be set" do
      task = described_class.new(
        desc: "Buy milk.", status: :in_progress, start_time: start_time)
      expect(task.start_time).to eql(start_time)
    end

    it "allows start_time and end_time to be set" do
      task = described_class.new(
        desc: "Buy milk.", status: :completed,
        start_time: start_time, end_time: end_time)

      expect(task.start_time).to eql(start_time)
      expect(task.end_time).to   eql(end_time)
    end

    it "does not allow only end_time to be set" do
      expect {
        described_class.new(desc: "Buy milk.", status: :in_progress, end_time: end_time)
      }.to raise_error(ArgumentError, /Setting end_time without start_time is invalid/)
    end

    it "does not allow start_time to be bigger to the end_time" do
      expect {
        described_class.new(desc: "Buy milk.",
          status: :completed, start_time: end_time, end_time: start_time)
      }.to raise_error(ArgumentError, /start_time has to be smaller than end_time/)
    end

    it "does not allow start_time to be same as the end_time" do
      expect {
        described_class.new(desc: "Buy milk.",
          status: :in_progress, start_time: start_time, end_time: start_time)
      }.to raise_error(ArgumentError, /start_time has to be smaller than end_time/)
    end

    it "allows duration to be set" do
      task = described_class.new(desc: "Buy milk.", status: :in_progress, duration: 5)
      expect(task.duration).to eql(5)
    end

    # NOTE: We could totally allow it to be an Hour instance.
    it "does not allow duration to be anything but integer" do
      expect {
        described_class.new(desc: "Buy milk.", status: :in_progress, duration: Hour.parse('0:10'))
      }.to raise_error(ArgumentError, /Duration has to be an integer/)
    end

    it "does not allow duration to be smaller than 5 minutes" do
      expect {
        described_class.new(desc: "Buy milk.", status: :in_progress, duration: 2)
      }.to raise_error(ArgumentError, /Duration has between 5 and 90 minutes/)
    end

    it "does not allow duration to be bigger than 90 minutes" do
      expect {
        described_class.new(desc: "Buy milk.", status: :in_progress, duration: 95)
      }.to raise_error(ArgumentError, /Duration has between 5 and 90 minutes/)
    end

    it "allows status to be set" do
      task = described_class.new(desc: "Buy milk.", status: :completed)
      expect(task.status).to eql(:completed)
    end

    it "does not allow unknown statuses" do
      expect {
        described_class.new(desc: "Buy milk.", status: :error)
      }.to raise_error(ArgumentError, /Status has to be one of/)
    end

    it "does not allow unknown statuses" do
      expect {
        described_class.new(desc: "Buy milk.", status: :unstarted, start_time: start_time, end_time: end_time)
      }.to raise_error(ArgumentError, /An unstarted task cannot have an end_time/)
    end
  end
end
