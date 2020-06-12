require 'spec_helper'

RSpec.describe ADT::Table do
  let(:adt_path) { fixture('ac_ahisto.adt') }
  let(:table) { ADT::Table.new adt_path }

  describe '#initialize' do
    describe 'when given a path to an existing adt file' do
      it 'does not raise an error' do
        expect { ADT::Table.new adt_path }.to_not raise_error
      end
    end

    describe 'when given a path to a non-existent adt file' do
      it 'raises a ADT::FileNotFound error' do
        expect { ADT::Table.new 'x' }.to raise_error(ADT::FileNotFoundError, 'file not found: x')
      end
    end
  end
end