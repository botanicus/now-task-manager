# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Generate do
  include_examples(:has_description)
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)

  context "with valid config" do
    let(:config) do
      Pomodoro::Config.new('spec/data/now-task-manager2.yml')
    end

    after do
      File.unlink(config.today_path)
    end

    it '...' do
      run(subject)

      expect(subject.sequence[0]).to eql(stdout: subject.t(:log_schedule, schedule: 'any'))
      expect(subject.sequence[1]).to eql(command: "vim #{config.task_list_path}")
      expect(subject.sequence[2]).to eql(stdout: subject.t(:file_created, path: RR::Homepath.new(config.today_path)))
      expect(subject.sequence[3]).to eql(exit: 0)
    end
  end
end
