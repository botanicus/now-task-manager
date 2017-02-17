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

  describe '#today_tasks' do
    it 'is pending'
  end

  describe '#tasks_for_later' do
    it 'is pending'
  end

  describe '#tasks_for_tomorrow' do
    it 'is pending'
  end

  describe '#finished_tasks' do
    it 'is pending'
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
      manager.switch_days('spec/data/schedule.rb')
      expected = []
      expected << '- [20] Meditation. #morning_ritual' # From the schedule.
      expected << '- Item 1.' # Unfinished task from yesterday (tasks.todo).
      expected << '- Item 2. #simple' # Unfinished task from yesterday (tasks.todo).
      expected << '- [20] Item 3.' # Unfinished task from yesterday (tasks.todo).
      expected << '- Plan tomorrow.' # From the schedule.
      expect(manager.today_tasks.map(&:to_s).join("\n")).to eql(expected.join("\n"))
    end

    it 'inserts tasks for tomorrow into the template' do
      manager = described_class.parse('spec/data/tasks2.todo')
      manager.switch_days('spec/data/schedule.rb')
      expected = []
      expected << '- [20] Meditation. #morning_ritual' # From the schedule.
      expected << '- Do nothing. #ohyeah' # Tomorrow task.
      expected << '- Plan tomorrow.' # From the schedule.
      expect(manager.today_tasks.map(&:to_s).join("\n")).to eql(expected.join("\n"))
    end
  end
end
