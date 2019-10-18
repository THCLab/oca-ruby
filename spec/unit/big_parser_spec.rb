require 'odca/big_parser'
require 'odca/hashlink_generator'
require 'json'

RSpec.describe Odca::BigParser do
  let(:topic)  { described_class.new(records, output_dir) }

  let(:output_dir) { 'spec/shared/output' }

  describe '#separate_schemas' do
    context 'when records contain many schemas' do
      let(:records) do
        [
          %w[Schema1 attr1_1],
          %w[Schema1 attr1_2],
          %w[Schema2 attr2_1],
          %w[Schema2 attr2_2],
          %w[Schema2 attr2_3],
          %w[Schema3 attr3_1]
        ]
      end

      it 'return arrays with separated records' do
        schemas = topic.__send__(:separate_schemas, records)
        expect(schemas.count).to eql 3

        expect(schemas[0].records[0][0]).to eql('Schema1')
        expect(schemas[0].records.count).to eql 2
        expect(schemas[0].records.map { |r| r[1] })
          .to contain_exactly('attr1_1', 'attr1_2')

        expect(schemas[1].records[0][0]).to eql('Schema2')
        expect(schemas[1].records.count).to eql 3
        expect(schemas[1].records.map { |r| r[1] })
          .to contain_exactly('attr2_1', 'attr2_2', 'attr2_3')

        expect(schemas[2].records[0][0]).to eql('Schema3')
        expect(schemas[2].records.count).to eql 1
        expect(schemas[2].records.map { |r| r[1] })
          .to contain_exactly('attr3_1')
      end
    end

    context 'when records contain one schema' do
      let(:records) do
        [
          %w[Schema1 attr1_1]
        ]
      end

      it 'return array with schema records' do
        schemas = topic.__send__(:separate_schemas, records)
        expect(schemas.count).to eql 1

        expect(schemas[0].records[0][0]).to eql('Schema1')
        expect(schemas[0].records.count).to eql 1
        expect(schemas[0].records.map { |r| r[1] })
          .to contain_exactly('attr1_1')
      end
    end
  end
end
