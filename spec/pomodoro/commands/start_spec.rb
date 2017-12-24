require 'spec_helper'
require 'ostruct'
require 'timecop'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Start do
  describe '.help' do
    it "has it" do
      expect(described_class).to respond_to(:help)
      expect(described_class.help.length).not_to be(0)
    end
  end

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  context "without config" do
    let(:config) do
      Pomodoro::Config.new('non-existent-now-task-manager.yml')
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>#{I18n.t('errors.config.missing_file', path: 'non-existent-now-task-manager.yml')}</red>")
    end
  end

  context "without today_path" do
    let(:config) do
      OpenStruct.new(today_path: 'non-existent.today')
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>! File #{config.today_path} doesn't exist.</red>\n  Run the <yellow>g</yellow> command first.")
    end
  end

  context "with a valid config" do
    let(:config) do
      OpenStruct.new(today_path: "spec/data/#{described_class}.#{rand(1000)}.today")
    end

    before(:each) do
      File.open(config.today_path, 'w') do |file|
        file.puts(data)
      end
    end

    after(:each) do
      File.unlink(config.today_path)
    end

    let(:time_frame) do
      "Admin (0:00 – 23:59)"
    end

    let(:task) do
      '[7:50-???] Active task.'
    end

    let(:data) do
      [
        time_frame,
        (['-', task].join(' ') if task)
      ].compact.join("\n")
    end

    context "with an active task" do
      it "aborts saying there is an active task already" do
        expect { run(subject) }.to change { subject.sequence.length }.by(1)
        expect(subject.sequence[0]).to eql(abort: "<red>There is an active task already:</red> active task.")
      end
    end

    context "with no active task" do
      let(:task) do
        'Unstarted task.'
      end

      it "starts it" do
        Timecop.freeze(h('9:00').to_time) do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(stdout: "<bold>~</bold> <green>unstarted task</green> has been started.")

          expect(File.read(config.today_path)).to eql("Admin (0:00 – 23:59)\n- [9:00-????] Unstarted task.\n")
        end
      end
    end
  end
end
