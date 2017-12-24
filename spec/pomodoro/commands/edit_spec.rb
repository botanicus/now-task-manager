require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Edit do
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
        task_list_path: File.expand_path('spec/data/tasks.todo')
      )
    end

    before(:each) do
      File.open(config.today_path, 'w') do |file|
        file.puts('')
      end
    end

    after(:each) do
      begin
        File.unlink(config.today_path)
      rescue Errno::ENOENT
      end
    end

    describe "no args" do
      context "without config.today_path" do
      end

      context "without today_path file" do
        it "fails" do
          File.unlink(config.today_path)

          run(subject)
          expect(subject.sequence[0]).to eql(abort: "<red>! File #{config.today_path} doesn't exist.</red>\n  Run the <yellow>g</yellow> command first.")
        end
      end

      it do
        run(subject)
        expect(subject.sequence[0]).to eql(command: "vim #{config.today_path}")
        expect(subject.sequence[1]).to eql(exit: 0)
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
          pending
          run(subject)
          expect(subject.sequence[0]).to eql(abort: "<red>! File non-existent.today doesn't exist</red>\n  Run the g command first.")
          expect(subject.sequence[1]).to eql(exit: 0)
        end
      end

      context "without config.task_list_path" do
      end

      context "without task_list_path file" do
        let(:config) do
          OpenStruct.new(today_path: 'non-existent.today')
        end

        # TODO
      end

      it do
        run(subject)
        expect(subject.sequence[0]).to eql(command: "vim -O2 #{config.today_path} #{config.task_list_path}")
        expect(subject.sequence[1]).to eql(exit: 0)
      end
    end

    describe "tomorrow" do
      let(:args) { ['tomorrow'] }

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
