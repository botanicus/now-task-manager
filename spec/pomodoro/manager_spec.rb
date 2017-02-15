require 'stringio'
require 'pomodoro/manager'

describe Pomodoro::TaskManager do
  let(:task_list_path) do
    'spec/data/tasks.todo'
  end

  let(:manager) do
    described_class.parse(task_list_path)
  end

  describe '.parse' do
    it 'loads tasks from the specified path' do
      expect(manager.today_tasks.length).to be(4)
    end
  end

  describe '#save' do
    it 'saves everything in the same format as was the input' do
      stream = StringIO.new
      manager.save(stream)
      generated = stream.tap { |stream| stream.rewind }.read
      expect(generated).to eql(File.read(task_list_path))
    end
  end

  describe '#active_task and #mark_active_task_as_done' do
    it 'pushes #done into the tags of the current task' do
      expect { manager.mark_active_task_as_done }.
        to change { manager.active_task.text }.
        from('Item 1.').
        to('Item 2.')
    end
  end

  describe '#add_task_for_later' do
    it 'adds a new task for later' do
      expect { manager.add_task_for_later('Discover America.') }.
        to change { manager.tasks_for_later.length }.by(1)
    end
  end

  describe '#switch_days' do
    it 'inserts unfinished tasks from today into the template' do
      manager.switch_days
      expected = []
      expected << '- Meditation.'
      expected << '- Item 1.'
      expected << '- Item 2. #simple'
      expected << '- [20] Item 3.'
      expected << '- Plan tomorrow.'
      expect(manager.today_tasks.map(&:to_s).join("\n")).to eql(expected.join("\n"))
    end
  end
end
