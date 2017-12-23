require 'spec_helper'
require 'ostruct'
require 'timecop'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Active do
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
      expect(subject.sequence[0]).to eql(abort: "<red>The config file non-existent-now-task-manager.yml doesn't exist.</red>")
    end
  end

  context "without today_path" do
    let(:config) do
      OpenStruct.new(today_path: 'non-existent.today')
    end

    it "fails" do
      expect { run(subject) }.to change { subject.sequence.length }.by(1)
      expect(subject.sequence[0]).to eql(abort: "<red>! File #{config.today_path} doesn't exist</red>")
    end
  end

  context "with a valid config" do
    let(:time_frame_end_time) { h('23:59') }

    let(:task) do
      '[7:50-???] [20] Active task.'
    end

    let(:data) do
      <<-EOF.gsub(/^\s*/, '')
        Admin (0:00 – #{time_frame_end_time})
        - #{task}
        - Active task.
      EOF
    end

    let(:config) do
      OpenStruct.new(today_path: "spec/data/active_spec.#{rand(1000)}.today")
    end

    before(:each) do
      File.open(config.today_path, 'w') do |file|
        file.puts(data)
      end
    end

    after(:each) do
      File.unlink(config.today_path)
    end

    context "with no active task" do
      let(:data) do
        <<-EOF.gsub(/^\s*/, '')
          Admin (0:00 – 23:59)
          - First task.
          - Second task.
        EOF
      end

      it "exits with 1" do
        expect { run(subject) }.to change { subject.sequence.length }.by(1)
        expect(subject.sequence[0]).to eql(exit: 1)
      end
    end

    context "with an active task" do
      it "prints out the active task" do
        expect { run(subject) }.to change { subject.sequence.length }.by(1)
        expect(subject.sequence[0][:p]).to be_kind_of(Pomodoro::Formats::Today::Task)
      end
    end

    describe "formatters" do
      let(:args) { [format_string] }

      describe "the body formatter %b" do
        let(:format_string) { '%b' }

        it "is described in help" do
          expect(described_class.help).to match(format_string)
        end

        it "displays the task body" do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(stdout: "Active task.")
        end
      end

      describe "the start time formatter %s" do
        let(:format_string) { '%s' }

        it "is described in help" do
          expect(described_class.help).to match(format_string)
        end

        it "displays the task start time" do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(stdout: "7:50")
        end
      end

      describe "the duration formatter %d" do
        let(:format_string) { '%d' }

        it "is described in help" do
          expect(described_class.help).to match(format_string)
        end

        context "it has duration" do
          it "displays the task duration" do
            expect { run(subject) }.to change { subject.sequence.length }.by(1)
            expect(subject.sequence[0]).to eql(stdout: "0:20")
          end
        end

        context "it doesn't have duration" do
          let(:task) { '[7:50-???] Active task.' }

          it "displays the task duration" do
            expect { run(subject) }.to change { subject.sequence.length }.by(1)
            expect(subject.sequence[0]).to eql(stdout: "")
          end
        end
      end

      describe "the remaining duration formatter %rd" do
        let(:format_string) { '%rd' }

        it "is described in help" do
          expect(described_class.help).to match(format_string)
        end

        context "it has duration and the time frame ends after the task does" do
          it "displays the task remaining duration" do
            Timecop.freeze(h('8:00').to_time) do
              expect { run(subject) }.to change { subject.sequence.length }.by(1)
              expect(subject.sequence[0]).to eql(stdout: "0:10")
            end
          end

          it "displays 0 if the task already ended" do
            Timecop.freeze(h('9:00').to_time) do
              expect { run(subject) }.to change { subject.sequence.length }.by(1)
              expect(subject.sequence[0]).to eql(stdout: "0")
            end
          end
        end

        context "it has duration and the time frame ends after the task does" do
          let(:time_frame_end_time) { h('8:05') }

          it "displays the time frame remaining duration" do
            Timecop.freeze(h('8:00').to_time) do
              expect { run(subject) }.to change { subject.sequence.length }.by(1)
              expect(subject.sequence[0]).to eql(stdout: "0:05")
            end
          end

          it "displays 0 if the task already ended" do
            Timecop.freeze(h('9:00').to_time) do
              expect { run(subject) }.to change { subject.sequence.length }.by(1)
              expect(subject.sequence[0]).to eql(stdout: "0")
            end
          end
        end

        context "it doesn't have duration" do
          let(:task) { '[7:50-???] Active task.' }

          it "displays the task duration" do
            expect { run(subject) }.to change { subject.sequence.length }.by(1)
            expect(subject.sequence[0]).to eql(stdout: "")
          end
        end
      end

      describe "the time frame formatter %tf" do
        let(:format_string) { '%tf' }

        it "is described in help" do
          expect(described_class.help).to match(format_string)
        end

        it "displays the task body" do
          expect { run(subject) }.to change { subject.sequence.length }.by(1)
          expect(subject.sequence[0]).to eql(stdout: "Admin")
        end
      end
    end
  end
end
