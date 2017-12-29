require 'spec_helper'
require 'pomodoro/config'
require 'pomodoro/commands'

describe Pomodoro::Commands::Active do
  include_examples(:has_description)
  include_examples(:has_help)

  let(:args) { Array.new }

  subject do
    described_class.new(args, config).extend(CLITestHelpers)
  end

  include_examples(:missing_config)
  include_examples(:requires_today_task_file)

  context "with a valid config", :valid_command do
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
      OpenStruct.new(today_path: "spec/data/#{described_class}.#{rand(1000)}.today")
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
        run(subject)
        expect(subject.sequence[0]).to eql(exit: 1)
      end
    end

    context "with an active task" do
      it "prints out the active task" do
        run(subject)
        expect(subject.sequence[0][:p]).to be_kind_of(Pomodoro::Formats::Today::Task)
      end
    end

    describe "formatters" do
      let(:args) { [format_string] }

      describe "the body formatter %B" do
        let(:format_string) { '%B' }

        it "is described in help" do
          expect(described_class.help).to match(format_string)
        end

        it "displays the task body" do
          run(subject)
          expect(subject.sequence[0]).to eql(stdout: "Active task.")
        end
      end

      describe "the body formatter %b" do
        let(:format_string) { '%b' }

        it "is described in help" do
          expect(described_class.help).to match(format_string)
        end

        it "displays the task body" do
          run(subject)
          expect(subject.sequence[0]).to eql(stdout: "active task")
        end
      end

      describe "the start time formatter %s" do
        let(:format_string) { '%s' }

        it "is described in help" do
          expect(described_class.help).to match(format_string)
        end

        it "displays the task start time" do
          run(subject)
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
            run(subject)
            expect(subject.sequence[0]).to eql(stdout: "0:20")
          end
        end

        context "it doesn't have duration" do
          let(:task) { '[7:50-???] Active task.' }

          it "displays nothing" do
            run(subject)
            expect(subject.sequence[0]).to eql(exit: 0)
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
              run(subject)
              expect(subject.sequence[0]).to eql(stdout: "0:10")
              expect(subject.sequence[1]).to eql(exit: 0)
            end
          end

          it "displays 0 if the task already ended" do
            Timecop.freeze(h('9:00').to_time) do
              run(subject)
              expect(subject.sequence[0]).to eql(stdout: "0")
              expect(subject.sequence[1]).to eql(exit: 0)
            end
          end
        end

        context "it has duration and the time frame ends after the task does" do
          let(:time_frame_end_time) { h('8:05') }

          it "displays the time frame remaining duration" do
            Timecop.freeze(h('8:00').to_time) do
              run(subject)
              expect(subject.sequence[0]).to eql(stdout: "0:05")
              expect(subject.sequence[1]).to eql(exit: 0)
            end
          end

          it "displays 0 if the task already ended" do
            Timecop.freeze(h('9:00').to_time) do
              run(subject)
              expect(subject.sequence[0]).to eql(stdout: "0")
              expect(subject.sequence[1]).to eql(exit: 0)
            end
          end
        end

        context "it doesn't have duration" do
          let(:task) { '[7:50-???] Active task.' }

          it "displays nothing" do
            run(subject)
            expect(subject.sequence[0]).to eql(exit: 0)
          end
        end
      end

      describe "the time frame formatter %tf" do
        let(:format_string) { '%tf' }

        it "is described in help" do
          expect(described_class.help).to match(format_string)
        end

        it "displays the task body" do
          run(subject)
          expect(subject.sequence[0]).to eql(stdout: "Admin")
          expect(subject.sequence[1]).to eql(exit: 0)
        end
      end
    end
  end
end
