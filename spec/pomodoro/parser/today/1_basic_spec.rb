require 'pomodoro/parser/today'

class Parslet::Slice
  def eql?(slice_or_string)
    self.to_s == slice_or_string.to_s
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
