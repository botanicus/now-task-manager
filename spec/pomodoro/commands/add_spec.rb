require 'spec_helper'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Add do
  include_examples(:has_help)

  subject do
    described_class.new(Array.new, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)

  context "with a config" do
    subject do
      described_class.new(args, config).extend(CLITestHelpers)
    end

    let(:config) do
      OpenStruct.new(task_list_path: 'spec/data/tasks_for_add.todo')
    end

    context "with an escaped string" do
      let(:args) { ["Do this and that."] }

      # TODO: Refactor this.
      before(:each) { File.open(config.task_list_path, 'w').close }
      after(:each)  { File.unlink(config.task_list_path) }

      it "adds the task into the 'Later' task group" do
        run(subject)
        expect(subject.sequence[0]).to eql(exit: 0)
        expect(File.read(config.task_list_path)).to eql("Later\n- Do this and that.\n")
      end

      it "doesn't add the task twice" do
        2.times { run(subject) }
        expect(File.read(config.task_list_path)).to eql("Later\n- Do this and that.\n")
      end
    end

    context "with an escaped string" do
      let(:args) { %w{Do this and that.} }

      before(:each) { File.open(config.task_list_path, 'w').close }
      after(:each)  { File.unlink(config.task_list_path) }

      it "adds the task into the 'Later' task group" do
        run(subject)
        expect(subject.sequence[0]).to eql(exit: 0)
        expect(File.read(config.task_list_path)).to eql("Later\n- Do this and that.\n")
      end

      it "doesn't add the task twice" do
        2.times { run(subject) }
        expect(File.read(config.task_list_path)).to eql("Later\n- Do this and that.\n")
      end
    end
  end
end
