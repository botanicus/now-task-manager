require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Add do
  describe '.help' do
    it "has it" do
      expect(described_class).to respond_to(:help)
      expect(described_class.help.length).not_to be(0)
    end
  end

  let(:config) do
    OpenStruct.new(task_list_path: 'spec/data/tasks_for_add.todo')
  end

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  context "without config" do
    let(:config) do
      Pomodoro::Config.new('non-existent-now-task-manager.yml')
    end

    let(:args) { '' }

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>#{I18n.t('errors.config.missing_file', path: 'non-existent-now-task-manager.yml')}</red>")
    end
  end

  context "with an escaped string" do
    let(:args) { ["Do this and that."] }

    before(:each) { File.open(config.task_list_path, 'w').close }
    after(:each)  { File.unlink(config.task_list_path) }

    it "adds the task into the 'Later' task group" do
      expect { run(subject) }.not_to change { subject.sequence.length }
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
      expect { run(subject) }.not_to change { subject.sequence.length }
      expect(File.read(config.task_list_path)).to eql("Later\n- Do this and that.\n")
    end

    it "doesn't add the task twice" do
      2.times { run(subject) }
      expect(File.read(config.task_list_path)).to eql("Later\n- Do this and that.\n")
    end
  end
end
