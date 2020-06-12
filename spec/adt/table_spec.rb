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

  describe '#close' do
    before { table.close }

    it 'closes the io' do
      expect { table.record(1) }.to raise_error(IOError)
    end
  end

  describe '#record' do
    it 'return an instance of ADT::Record' do
      expect(table.record(1)).to be_a(ADT::Record)
    end
  end

  describe '#filename' do
    it 'returns the filename of the table' do
      expect(table.filename).to eq('ac_ahisto.adt')
    end
  end
end
