require 'spec_helper'

RSpec.describe ADT::Column do
  let(:adt_path) { fixture('ac_ahisto.adt') }
  let(:table) { ADT::Table.new adt_path }

  context 'when initialized' do
    let(:column) { ADT::Column.new 'ColumnName', 4, 1 }
    let(:hash) { {name: 'ColumnName', length: 1, type: 4} }

    it 'sets :name accessor' do
      expect(column.name).to eq 'ColumnName'
    end

    it 'sets :type accessor' do
      expect(column.type).to eq 4
    end

    it 'sets the #length accessor' do
      expect(column.length).to eq 1
    end

    it 'accepts length of 0' do
      column = ADT::Column.new 'ColumnName', 4, 0
      expect(column.length).to eq 0
    end

    describe 'with length less than 0' do
      it 'raises ADT::Column::LengthError' do
        expect { ADT::Column.new 'ColumnName', 4, -1 }.to raise_error(ADT::Column::LengthError)
      end
    end

    describe 'with empty column name' do
      it 'raises ADT::Column::NameError' do
        expect { ADT::Column.new '', 4, 1 }.to raise_error(ADT::Column::NameError)
      end
    end

    describe '#to_hash' do
      it 'returns a hash with name, length and type' do
        expect(column.to_hash).to eq hash
      end
    end

    describe '#underscored_name' do
      it 'returns an underscored_name for a ColumnName' do
        expect(column.underscored_name).to eq 'column_name'
      end
    end
  end

  describe '#type_cast' do
    context 'with type 11 (integer)' do
      it 'returns flag "i"' do
        column = ADT::Column.new 'ColumnName', 11, 3
        expect(column.flag).to eq('i')
      end

      context 'when value is empty' do
        it 'returns nil' do
          value = ''
          column = ADT::Column.new 'ColumnName', 11, 5
          expect(column.type_cast(value)).to be_nil
        end
      end

      context 'with 0 length' do
        it 'returns nil' do
          column = ADT::Column.new 'ColumnName', 11, 0
          expect(column.type_cast('')).to be_nil
        end
      end

      context 'with an integer' do
        it 'casts value to Integer' do
          value = "\u0003\u0000\u0000\u0000"
          column = ADT::Column.new 'ColumnName', 11, 3
          expect(column.type_cast(value)).to eq 3
        end
      end
    end
  end

  describe '#name' do
    it 'contains only ASCII characters' do
      column = ADT::Column.new 'thiséeë', 4, 1
      expect(column.name).to eq 'thise'
    end
  end
end
