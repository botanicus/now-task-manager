require 'spec_helper'
require 'pomodoro/formats/review'

describe Pomodoro::Formats::Review::Parser do
  describe 'rules' do
    describe 'header' do
      it "parses anything followed by a new line" do
        expect {
          subject.header.parse("# Expenses\n")
        }.not_to raise_error
      end
    end

    describe 'data' do
      it "parses anything followed by a new line" do
        expect {
          subject.data.parse("A\nB\nC")
        }.not_to raise_error
      end

      it "doesn't allow headers within" do
        expect {
          subject.data.parse("A\nB\n# Expenses\n")
        }.to raise_error(Parslet::ParseFailed)
      end

      it "does allow comments within" do
        pending
        expect {
          subject.data.parse("A\nB # comment\n")
        }.not_to raise_error(Parslet::ParseFailed)
      end
    end

    describe 'section' do
      it "parses anything followed by a new line" do
        expect {
          subject.section.parse("# Expenses\nA\nB\n")
        }.not_to raise_error
      end
    end
  end

  describe '#parse' do
    let(:data) do
      <<-EOF.gsub(/^ +/, '')
        # Health
        Weight: 69.6 kg

        # Expenses
      EOF
    end

    it "returns a tree" do
      expect(subject.parse(data)).to eql([
        {
          section: {header: 'Health', data: "Weight: 69.6 kg\n\n"}
        }, {
          section: {header: 'Expenses', data: []}
        }
      ])
    end
  end
end
