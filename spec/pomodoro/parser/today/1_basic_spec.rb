require 'pomodoro/parser/today'
require 'parslet/rig/rspec' # So we can use parser.rule.parse(...)

class Parslet::Slice
  def eql?(slice_or_string)
    self.to_s == slice_or_string.to_s
  end
end

describe Pomodoro::TodayParser do
  describe 'rule :indent' do
    it "parses dash" do
      tree = subject.indent.parse('- ')
      expect(tree[0][:indent]).to eql('-')
    end

    it "parses UTF-8 checks and crosses" do
      '✓✔✕✖✗✘'.each_char do |char|
        tree = subject.indent.parse("#{char} ")
        expect(tree[0][:indent]).to eql(char)
      end
    end
  end

  describe 'rule :hour' do
    it "parses valid hour strings" do
      expect { subject.hour.parse('0:00')  }.not_to raise_error
      expect { subject.hour.parse('9:27')  }.not_to raise_error
      expect { subject.hour.parse('12')    }.not_to raise_error
      expect { subject.hour.parse('12:30') }.not_to raise_error
    end

    it "doesn't parse invalid hour strings" do
      pending
      expect { subject.hour.parse('000')    }.to raise_error(Parslet::ParseFailed)
      expect { subject.hour.parse('000:00') }.to raise_error(Parslet::ParseFailed)
      expect { subject.hour.parse('00:0')   }.to raise_error(Parslet::ParseFailed)
      expect { subject.hour.parse('00:000') }.to raise_error(Parslet::ParseFailed)
    end
  end

  describe 'rule :task' do
    it do
      tree = subject.task.parse("- Description 123!")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "Description 123!"}])
    end

    it do
      tree = subject.task.parse("- Description 123! #break")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "Description 123! "}, {tag: 'break'}])

      tree = subject.task.parse("- Description 123! #break #yummy")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "Description 123! "}, {tag: 'break'},  {tag: 'yummy'}])
    end

    it do
      tree = subject.task.parse("- [7:50-8:10] Description 123!")
      expect(tree).to eql(task: [{indent: '-'}, {start_time: '7:50', end_time: '8:10'}, {desc: "Description 123!"}])
    end

    it do
      tree = subject.task.parse("- [7:50] Call Marka.")
      expect(tree).to eql(task: [{indent: '-'}, {start_time: '7:50'}, {desc: "Call Marka."}])
    end

    it "parses expected duration" do
      tree = subject.task.parse("- [20] Description 123!")
      expect(tree).to eql(task: [{indent: '-'}, {duration: '20'}, {desc: "Description 123!"}])
    end

    it "parses metadata" do
      tree = subject.task.parse("- A\n  B")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "A"}, {line: "B"}])

      tree = subject.task.parse("- A\n  B\n  C")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "A"}, {line: "B"}, {line: "C"}])
    end
  end

  describe 'rule :time_frame_with_tasks' do
    it "parses simple tasks" do
      tree = subject.time_frame_with_tasks.parse("Test\n- A\n- B")
      expect(tree).to eql({
        desc: "Test",
        task_list: [
          {task: [{indent: "-"}, {desc: "A"}]},
          {task: [{indent: "-"}, {desc: "B"}]}
        ]
      })
    end

    it "parses tasks with metadata" do
      tree = subject.time_frame_with_tasks.parse("Test\n- A\n  Pekny kozy.\n- B")
      expect(tree).to eql({
        desc: "Test",
        task_list: [
          {task: [{indent: "-"}, {desc: "A"}, {line: "Pekny kozy."}]},
          {task: [{indent: "-"}, {desc: "B"}]}
        ]
      })
    end
  end

  describe 'rule :time_frames_with_tasks' do
    it "parses one time frame block" do
      require 'pry'; binding.pry ###
      tree = subject.time_frames_with_tasks.parse("Test\n- A\n  Pekny kozy.\n- B")
      expect(tree).to eql({
        desc: "Test",
        task_list: [
          {task: [{indent: "-"}, {desc: "A"}, {line: "Pekny kozy."}]},
          {task: [{indent: "-"}, {desc: "B"}]}
        ]
      })
    end
  end
end

describe Pomodoro::TodayParser do
  def build_tree
    {desc: [], task_list: []}
  end

  describe "The most basic syntax" do
    let(:syntax_file) do
      File.read('spec/data/formats/today/1_basic.today')
    end

    it "allows empty files" do
      expect(subject.parse('')).to eql(build_tree)
      expect(subject.parse("\n")).to eql(build_tree)
      # TODO:
      # expect(subject.parse("\n \n \n ")).to eql(build_tree)
    end

    it "parses one time frame with no tasks" do
      tree = subject.parse("Time frame 1 (9:00 – 12:00)")
      expect(tree).to eql({
        desc: "Time frame 1 ", # NOTE: trailing whitespace.
        start_time: '9:00',
        end_time: '12:00',
        task_list: []
      })
    end

    it "parses one time frame with one task" do
      tree = subject.parse("Time frame 1 (9:00 – 12:00)\n- Do something.")
      expect(tree).to eql({
        desc: "Time frame 1 ", # NOTE: trailing whitespace.
        start_time: '9:00',
        end_time: '12:00',
        task_list: [
          task: [{indent: '-'}, {desc: "Do something."}]
        ]
      })
    end

    it "parses one time frame with multiple task" do
      tree = subject.parse("Time frame 1 (9:00 – 12:00)\n- Do something.\n- Do something else.\n- Go to sleep.")
      expect(tree).to eql({
        desc: "Time frame 1 ", # NOTE: trailing whitespace.
        start_time: '9:00',
        end_time: '12:00',
        task_list: [
          {task: [{indent: '-'}, {desc: "Do something."}]},
          {task: [{indent: '-'}, {desc: "Do something else."}]},
          {task: [{indent: '-'}, {desc: "Go to sleep."}]}
        ]
      })
    end

    it "parses multiple time frames" do
      pending "Change the root rule so it works" # TODO
      tree = subject.parse(syntax_file)
      expect(tree).to eql({
        desc: "Time frame 1 ", # NOTE: trailing whitespace.
        start_time: '9:00',
        end_time: '12:00',
        task_list: [
          {task: [{indent: '✔'}, {desc: "Task 1."}]},
          {task: [{indent: '✘'}, {desc: "Task 2."}]},
          {task: [{indent: '-'}, {desc: "Task 3."}]},
        ]
      })
    end
  end
end
