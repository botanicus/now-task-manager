require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Generate do
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)

  context "with valid config" do
    let(:config) do
      Pomodoro::Config.new('spec/data/now-task-manager.yml')
    end

    after do
      File.unlink(config.today_path)
    end

    it do
      expect { run(subject) }.to change { subject.sequence.length }.by(3)
      expect(subject.sequence[0]).to eql(stdout: "~ Schedule: <magenta>any</magenta>.")
      expect(subject.sequence[1]).to eql(command: "vim #{config.task_list_path}")
      expect(subject.sequence[2]).to eql(stdout: "~ <green>File #{Pomodoro::Tools.format_path(config.today_path)} has been created.</green>")
    end
  end
end
