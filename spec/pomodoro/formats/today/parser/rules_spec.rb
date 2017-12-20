require 'spec_helper'
require 'pomodoro/formats/today'
# require 'parslet/rig/rspec' # So we can use parser.rule.parse(...)

describe Pomodoro::Formats::Today::Parser do
  describe 'rule :day_tag' do
    it "parses one tag" do
      tree = subject.day_tag.parse('@holidays')
      expect(tree[:tag]).to eql('holidays')
    end
  end

  describe 'rule :day_tags' do
    it "parses one tag" do
      tree = subject.day_tags.parse("@holidays\n")
      expect(tree[:tags][0]).to eql(tag: 'holidays')
    end

    it "parses all the tags" do
      tree = subject.day_tags.parse("@holidays @spain\n")
      expect(tree[:tags]).to eql([{tag: 'holidays'}, {tag: 'spain'}])
    end
  end

  describe 'rule :indent' do
    it "parses dash" do
      tree = subject.indent.parse('- ')
      expect(tree[:str]).to eql('-')
    end

    it "parses UTF-8 checks and crosses" do
      '✓✔✕✖✗✘'.each_char do |char|
        tree = subject.indent.parse("#{char} ")
        expect(tree[:str]).to eql(char)
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
      expect(tree).to eql(task: {
        indent: {str: '-'},
        body: {str: "Description 123!"},
        tags: [], lines: []
      })
    end

    it do
      tree = subject.task.parse("- Description 123! #break\n")
      expect(tree).to eql(task: {
        indent: {str: '-'}, body: {str: "Description 123! "},
        tags: [{tag: 'break'}], lines: []
      })

      tree = subject.task.parse("- Description 123! #break #yummy\n")
      expect(tree).to eql(task: {
        indent: {str: '-'}, body: {str: "Description 123! "},
        tags: [{tag: 'break'}, {tag: 'yummy'}], lines: []
      })
    end

    it do
      tree = subject.task.parse("- [7:50-8:10] Description 123!\n")
      expect(tree).to eql(task: {
        indent: {str: '-'}, start_time: {hour: '7:50'}, end_time: {hour: '8:10'},
        body: {str: "Description 123!"}, tags: [], lines: []
      })
    end

    it do
      tree = subject.task.parse("- [7:50-????] Description 123!\n")
      expect(tree).to eql(task: {
        indent: {str: '-'}, start_time: {hour: '7:50'},
        body: {str: "Description 123!"}, tags: [], lines: []
      })
    end

    it do
      tree = subject.task.parse("- [7:50] Call Marka.\n")
      expect(tree).to eql(task: {
        indent: {str: '-'}, fixed_start_time: {hour: '7:50'}, body: {str: "Call Marka."},
        tags: [], lines: []
      })
    end

    it "parses expected duration" do
      tree = subject.task.parse("- [20] Description 123!\n")
      expect(tree).to eql(task: {
        indent: {str: '-'}, duration: '20', body: {str: "Description 123!"}, tags: [], lines: []
      })
    end

    it "parses metadata" do
      tree = subject.task.parse("- A\n  B\n")
      expect(tree).to eql(task: {
        indent: {str: '-'}, body: {str: "A"}, tags: [], lines: [{str: "B"}]
      })

      tree = subject.task.parse("- A\n  B\n  C\n")
      expect(tree).to eql(task: {
        indent: {str: '-'}, body: {str: "A"}, tags: [], lines: [{str: "B"}, {str: "C"}]
      })
    end
  end

  describe 'rule :time_frame_with_tasks' do
    it "parses simple tasks" do
      tree = subject.time_frame_with_tasks.parse("Test\n- A\n- B\n~ Log\n")
      expect(tree).to eql({
        time_frame: {
          name: {str: "Test"},
          items: [
            {task: {indent: {str: "-"}, body: {str: "A"}, tags: [], lines: []}},
            {task: {indent: {str: "-"}, body: {str: "B"}, tags: [], lines: []}},
            {log_item: {str: "Log"}}
          ]
        }
      })
    end

    it "parses tasks with metadata" do
      tree = subject.time_frame_with_tasks.parse("Test\n- A\n  Pekny kozy.\n- B\n")
      expect(tree).to eql({
        time_frame: {
          name: {str: "Test"},
          items: [
            {task: {indent: {str: "-"}, body: {str: "A"}, tags: [], lines: [{str: "Pekny kozy."}]}},
            {task: {indent: {str: "-"}, body: {str: "B"}, tags: [], lines: []}}
          ]
        }
      })
    end
  end
end
