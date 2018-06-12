# frozen_string_literal: true

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

    describe 'raw_data' do
      it "parses anything followed by a new line" do
        expect {
          subject.raw_data.parse("A\nB\nC")
        }.not_to raise_error
      end

      it "doesn't allow headers within" do
        expect {
          subject.raw_data.parse("A\nB\n# Expenses\n")
        }.to raise_error(Parslet::ParseFailed)
      end

      it "does allow comments within" do
        pending
        expect {
          subject.raw_data.parse("A\nB # comment\n")
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
    let(:raw_data) do
      <<-EOF.gsub(/^ +/, '')
        # Health
        Weight: 69.6 kg

        # Expenses
      EOF
    end

    it "returns a tree" do
      expect(subject.parse(raw_data)).to eql([
        {
          section: {
            header: {str: 'Health'},
            raw_data: {str: "Weight: 69.6 kg\n\n"}
          }
        }, {
          section: {
            header: {str: 'Expenses'},
            raw_data: {str: []}
          }
        }
      ])
    end
  end
end
