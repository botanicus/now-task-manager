require 'stringio'
require 'pomodoro/manager'

describe Pomodoro::TaskManager do
  let(:task_list_path) do
    'spec/data/tasks.todo'
  end

  let(:manager) do
    described_class.load_tasks(task_list_path)
  end

  describe '.load_tasks' do
    it 'loads tasks from the specified path' do
      expect(manager.today_tasks.length).to be(4)
    end
  end

  describe '#write_tasks' do
    it 'saves everything in the same format as was the input' do
      stream = StringIO.new
      manager.write_tasks(stream)
      generated = stream.tap { |stream| stream.rewind }.read
      expect(generated).to eql(File.read(task_list_path))
    end
  end
end
