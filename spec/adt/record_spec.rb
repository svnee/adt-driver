require 'spec_helper'

RSpec.describe ADT::Record do
  let(:adt_path) { fixture('ac_ahisto.adt') }
  let(:record_0) { ['44111000', 'ACH', '2013', 3, 1, 1, 'PUR', 2013, 'SCO', Date.parse('2013-03-31'), Date.parse('2013-04-30'), 'LU130305', nil, '', nil, nil, '', nil, nil, '', nil, '', true, false, '', 'PHN', DateTime.parse('2013-05-28 11:38:04.000000000 +02:00'), 'PHN', DateTime.parse('2013-05-28 11:38:04.000000000 +02:00'), '21410100', 'SUP', false, '', nil, nil, nil, 'S', '$9E5F55F8', '', 'D'] }
  let(:table) { ADT::Table.new adt_path }

  context 'with data from fixture' do
    describe '#to_a' do
      it 'returns an ordered array of attribute values' do
        record = table.record(0)
        expect(record.to_a).to eq record_0
      end
    end

    describe '#equals' do
      it 'two identical records are equal' do
        record = table.record(0)
        record0 = table.record(0)
        expect(record == record0).to eq true
      end

      it 'two different records are not equal' do
        record = table.record(0)
        record0 = table.record(1)
        expect(record == record0).to eq false
      end
    end
  end
end
