require 'spec_helper'
require 'ostruct'
require 'date'
require 'timecop'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Config do
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

    # This doesn't work, because of the stubs.
    # Normally, p would do puts(object.inspect) and Config#inspect is where
    # the exception would occur. But since we're redefining Kernel#p, it never
    # gets there, so it looks like it prints the inspected config object
    # successfuly, but that's not true.
    it "fails" do
      pending "See the comment above."
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>#{I18n.t('errors.config.missing_file', path: 'non-existent-now-task-manager.yml')}</red>")
    end
  end

  context "with a valid config" do
    let(:config) do
      Pomodoro::Config.new('spec/data/now-task-manager.yml')
    end

    context "with no arguments" do
      it "prints out the whole config" do
        expect { run(subject) }.to change { subject.sequence.length }.by(1)
        expect(subject.sequence[0][:p]).to be_kind_of(Pomodoro::Config)
      end
    end

    context "with a key" do
      let(:args) { ['today_path'] }

      it "prints out its value" do
        expect { run(subject) }.to change { subject.sequence.length }.by(1)
        expect(subject.sequence[0][:stdout]).to match("/#{Date.today.strftime('%Y-%m-%d')}.today")
      end
    end

    context "with a key and an argument" do
      let(:args) { ['today_path', '2015-01-31'] }

      it "prints out its value" do
        expect { run(subject) }.to change { subject.sequence.length }.by(1)
        expect(subject.sequence[0][:stdout]).to match("/2015-01-31.today")
      end
    end
  end
end
