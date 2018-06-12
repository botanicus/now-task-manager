# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Next_Postpone do
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
      context "without specifying a date" do
        it "marks it as postponed" do
          $stdin = StringIO.new
          $stdin.write("I need XYZ first.\n")
          $stdin.write("\n")
          $stdin.rewind

          run(subject)
          expect(subject.sequence[0]).to eql(stdout: "#{subject.t(:prompt_why)} ")
          expect(subject.sequence[1]).to eql(stdout: "#{subject.t(:prompt_when)} ")

          date = (Date.today + 1).iso8601
          task = Pomodoro::Tools.unsentence(next_task)
          expect(subject.sequence[2]).to eql(stdout: subject.t(:success, task: task, date: (Date.today + 1).strftime('%-d/%-m')))
          expect(subject.sequence[3]).to eql(exit: 0)

          expect(File.read(config.today_path)).to eql("Admin (0:00 – 23:59)\n✘ Next task.\n  Postponed: I need XYZ first.\n  Review at: #{date}\n")
        end
      end

      context "with a postponed-to date" do
        it "marks it as postponed" do
          $stdin = StringIO.new
          $stdin.write("I need XYZ first.\n")
          $stdin.write("21/5\n")
          $stdin.rewind

          run(subject)
          expect(subject.sequence[0]).to eql(stdout: "#{subject.t(:prompt_why)} ")
          expect(subject.sequence[1]).to eql(stdout: "#{subject.t(:prompt_when)} ")

          task = Pomodoro::Tools.unsentence(next_task)
          expect(subject.sequence[2]).to eql(stdout: subject.t(:success, task: task, date: '21/5'))
          expect(subject.sequence[3]).to eql(exit: 0)

          expect(File.read(config.today_path)).to eql("Admin (0:00 – 23:59)\n✘ Next task.\n  Postponed: I need XYZ first.\n  Review at: #{Time.now.year}-05-21\n")
        end
      end
    end

    context "with no next task" do
      let(:next_task) {}

      it "prints out an error message" do
        run(subject)
        expect(subject.sequence[0]).to eql(abort: subject.t(:no_more_tasks_in_time_frame, time_frame: 'Admin'))
      end
    end
  end
end
