require 'spec_helper'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Commit do
  include_examples(:has_description)
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)
  include_examples(:requires_today_task_file)

  context "with a valid config", :valid_command do
    let(:time_frame_end_time) { h('23:59') }

    let(:task) do
      '[7:50-???] [20] Active task.'
    end

    let(:data) do
      <<-EOF.gsub(/^\s*/, '')
        Admin (0:00 – #{time_frame_end_time})
        - #{task}
        - Active task.
      EOF
    end

    let(:config) do
      OpenStruct.new(today_path: "spec/data/#{described_class}.#{rand(1000)}.today")
    end

    context "with no active task" do
      let(:data) do
        <<-EOF.gsub(/^\s*/, '')
          Admin (0:00 – 23:59)
          - First task.
          - Second task.
        EOF
      end

      it "exits with 1" do
        run(subject)
        expect(subject.sequence[0]).to eql(abort: "<red>There is no task in progress.</red>")
      end
    end

    context "with an active task" do
      it "commits the active task" do
        run(subject)
        expect(subject.sequence[1]).to eql(command: "git commit -m Active\\ task.")
        expect(subject.sequence[2]).to eql(exit: 0)
      end
    end

    context "with arguments" do
      let(:args) { ['-a'] }

      it "passes all the arguments to git" do
        run(subject)
        expect(subject.sequence[1]).to eql(command: "git commit -a -m Active\\ task.")
        expect(subject.sequence[2]).to eql(exit: 0)
      end
    end
  end
end
