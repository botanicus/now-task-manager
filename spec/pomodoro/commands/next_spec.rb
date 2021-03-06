# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Next do
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
      "Admin (0:00 – 23:59)"
    end

    let(:active_task) do
      '[7:50-???] Active task.'
    end

    let(:coming_task) do
      'Upcoming task.'
    end

    let(:data) do
      [
        time_frame,
        (['-', active_task].join(' ') if active_task),
        (['-', coming_task].join(' ') if coming_task)
      ].compact.join("\n")
    end

    context "and an active task" do
      context "and a next task" do
        it "warns about the task in progress and prints out the upcoming one" do
          run(subject)
          expect(subject.sequence[0]).to eql(warn: "#{subject.t(:task_in_progress, task: 'active task')}\n\n")
          expect(subject.sequence[1]).to eql(stdout: subject.t(:upcoming_task, task: 'upcoming task'))
          expect(subject.sequence[2]).to eql(exit: 0)
        end
      end

      context "and no next task" do
        let(:coming_task) {}

        it "warns about the task in progress and prints out the upcoming one" do
          run(subject)
          expect(subject.sequence[0]).to eql(warn: "#{subject.t(:task_in_progress, task: 'active task')}\n\n")
          expect(subject.sequence[1]).to eql(abort: subject.t(:no_more_tasks_in_time_frame, time_frame: 'Admin'))
        end
      end

      context "and no active time frame" do
        let(:time_frame) do
          "Admin (9:00 – 9:59)"
        end

        it "warns about the task in progress and aborts saying there is no active time frame" do
          Timecop.freeze(h('10:00').to_time) do
            run(subject)
            expect(subject.sequence[0]).to eql(warn: "#{subject.t(:task_in_progress, task: 'active task')}\n\n")
            expect(subject.sequence[1]).to eql(abort: subject.t(:no_active_time_frame))
          end
        end
      end
    end

    context "and no active task" do
      let(:active_task) {}

      context "and a next task" do
        it "prints out the upcoming one" do
          run(subject)
          expect(subject.sequence[0]).to eql(stdout: subject.t(:upcoming_task, task: 'upcoming task'))
        end
      end

      context "and no next task" do
        let(:coming_task) {}

        it "aborts saying there are no more tasks" do
          run(subject)
          expect(subject.sequence[0]).to eql(abort: subject.t(:no_more_tasks_in_time_frame, time_frame: 'Admin'))
        end
      end
    end

    context "and no active time frame" do
      let(:active_task) {}

      let(:time_frame) do
        "Admin (9:00 – 9:59)"
      end

      it "aborts saying there are no more tasks" do
        Timecop.freeze(h('10:00').to_time) do
          run(subject)
          expect(subject.sequence[0]).to eql(abort: subject.t(:no_active_time_frame))
        end
      end
    end
  end
end
