require 'pomodoro/parser/today_parser'
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
      tree = subject.task.parse("- Description 123!\n")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "Description 123!"}])
    end

    it do
      tree = subject.task.parse("- Description 123! #break\n")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "Description 123! "}, {tag: 'break'}])

      tree = subject.task.parse("- Description 123! #break #yummy\n")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "Description 123! "}, {tag: 'break'},  {tag: 'yummy'}])
    end

    it do
      tree = subject.task.parse("- [7:50-8:10] Description 123!\n")
      expect(tree).to eql(task: [{indent: '-'}, {start_time: {hour: '7:50'}, end_time: {hour: '8:10'}}, {desc: "Description 123!"}])
    end

    it do
      tree = subject.task.parse("- [7:50] Call Marka.\n")
      expect(tree).to eql(task: [{indent: '-'}, {start_time: {hour: '7:50'}}, {desc: "Call Marka."}])
    end

    it "parses expected duration" do
      tree = subject.task.parse("- [20] Description 123!\n")
      expect(tree).to eql(task: [{indent: '-'}, {duration: '20'}, {desc: "Description 123!"}])
    end

    it "parses metadata" do
      tree = subject.task.parse("- A\n  B\n")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "A"}, {line: "B"}])

      tree = subject.task.parse("- A\n  B\n  C\n")
      expect(tree).to eql(task: [{indent: '-'}, {desc: "A"}, {line: "B"}, {line: "C"}])
    end
  end

  describe 'rule :time_frame_with_tasks' do
    it "parses simple tasks" do
      tree = subject.time_frame_with_tasks.parse("Test\n- A\n- B\n")
      expect(tree).to eql({
        time_frame: {
          desc: "Test",
          task_list: [
            {task: [{indent: "-"}, {desc: "A"}]},
            {task: [{indent: "-"}, {desc: "B"}]}
          ]
        }
      })
    end

    it "parses tasks with metadata" do
      tree = subject.time_frame_with_tasks.parse("Test\n- A\n  Pekny kozy.\n- B\n")
      expect(tree).to eql({
        time_frame: {
          desc: "Test",
          task_list: [
            {task: [{indent: "-"}, {desc: "A"}, {line: "Pekny kozy."}]},
            {task: [{indent: "-"}, {desc: "B"}]}
          ]
        }
      })
    end
  end
end
