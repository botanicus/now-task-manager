# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Edit do
  include_examples(:has_description)
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)

  context "with config" do
    let(:config) do
      OpenStruct.new(
        today_path: "spec/data/#{described_class}.#{rand(1000)}.today",
        task_list_path: File.expand_path('spec/data/tasks.todo'))
    end

    let(:data) { '' }

    describe "no args" do
      context "without config.today_path" do
        let(:config) do
          OpenStruct.new(
            task_list_path: File.expand_path('spec/data/tasks.todo'))
        end

        it "raises a configuration error" do
          # TODO: This should provide a formatted message.
          run(subject)
          expect(subject.sequence[0][:abort]).to be_kind_of(Pomodoro::Config::ConfigError)
        end
      end

      context "without today_path file" do
        it "fails" do
          run(subject)
          expect(subject.sequence[0]).to eql(abort: "<red>! File #{config.today_path} doesn't exist.</red>\n  Run the <yellow>g</yellow> command first.")
        end
      end

      context "valid", :valid_command do
        it "opens today_path in Vim" do
          run(subject)
          expect(subject.sequence[0]).to eql(command: "vim #{config.today_path}")
          expect(subject.sequence[1]).to eql(exit: 0)
        end
      end
    end

    describe "2" do
      let(:args) { ['2'] }

      context "without config.today_path" do
      end

      context "without today_path file" do
        let(:config) do
          OpenStruct.new(today_path: 'non-existent.today', task_list_path: 'somewhere')
        end

        it "fails" do
          run(subject)
          expect(subject.sequence[0]).to eql(abort: "<red>! File non-existent.today doesn't exist.</red>\n  Run the <yellow>g</yellow> command first.")
        end
      end

      context "without config.task_list_path" do
        # TODO
      end

      context "without task_list_path file" do
        let(:config) do
          OpenStruct.new(today_path: 'non-existent.today')
        end

        # TODO
      end

      context "valid", :valid_command do
        it "opens today_path and task_list_path in Vim" do
          run(subject)
          expect(subject.sequence[0]).to eql(command: "vim -O2 #{config.today_path} #{config.task_list_path}")
          expect(subject.sequence[1]).to eql(exit: 0)
        end
      end
    end

    describe "+1" do
      let(:args) { ['+1'] }

      it do
        pending "Config is just an open struct right now, it doesn't take arguments."

        run(subject)
        expect(subject.sequence[0]).to eql(command: "vim #{config.today_path(Date.today + 1)}")
        expect(subject.sequence[1]).to eql(exit: 0)
      end
    end

    describe "tasks" do
      let(:args) { ['tasks'] }

      it do
        run(subject)
        expect(subject.sequence[0]).to eql(command: "vim #{config.task_list_path}")
        expect(subject.sequence[1]).to eql(exit: 0)
      end
    end

    describe "unknown args" do
      let(:args) { ['pastika'] }

      it do
        run(subject)
        expect(subject.sequence[0]).to eql(abort: described_class.help)
      end
    end
  end
end
