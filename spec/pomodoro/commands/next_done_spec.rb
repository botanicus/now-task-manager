# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Next_Done do
  include_examples(:has_description)
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)
  include_examples(:requires_today_task_file)

  context "with a valid config", :valid_command do
    let(:config) do
      OpenStruct.new(today_path: "spec/data/#{described_class}.#{rand(1000)}.today")
    end

    let(:time_frame) do
      "Admin (0:00 ā 23:59)"
    end

    let(:next_task) do
      'Next task.'
    end

    let(:data) do
      [
        time_frame,
        (['-', next_task].join(' ') if next_task)
      ].compact.join("\n")
    end

    context "with a next task" do
      it "marks it as complete" do
        run(subject)
        expect(subject.sequence[0]).to eql(stdout: subject.t(:success, task: Pomodoro::Tools.unsentence(next_task)))
        expect(subject.sequence[1]).to eql(exit: 0)

        expect(File.read(config.today_path)).to eql("Admin (0:00 ā 23:59)\nā #{next_task}\n")
      end
    end

    context "with no next task" do
      let(:next_task) {}

      it "marks it as done" do
        run(subject)
        expect(subject.sequence[0]).to eql(abort: subject.t(:no_more_tasks_in_time_frame, time_frame: 'Admin'))
      end
    end
  end
end
