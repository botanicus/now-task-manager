# frozen_string_literal: true

require 'spec_helper'
require 'pomodoro/formats/review'

describe Pomodoro::Formats::Review::Transformer do
  let(:tree) do # Copied from the parser_spec.rb.
    [
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
    ]
  end

  describe '#apply' do
    it do
      ast = subject.apply(tree)
      expect(ast.length).to be(2)

      expect(ast[0].header).to eql('Health')
      expect(ast[0].raw_data).to eql("Weight: 69.6 kg")

      expect(ast[1].header).to eql('Expenses')
      expect(ast[1].raw_data).to eql('')
    end
  end
end
