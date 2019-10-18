require 'odca/schema_base'

RSpec.describe Odca::SchemaBase do
  let(:schema_base) do
    described_class.new(
      described_class::Header.new(
        name: 'sb_name',
        description: 'sb_desc',
        classification: 'sb_class'
      )
    )
  end

  describe '#to_h' do
    context 'schema base has attributes' do
      before(:each) do
        schema_base.add_attribute(
          described_class::Attribute.new(
            name: 'attr_name', type: 'attr_type', pii: 'Y'
          )
        )
        schema_base.add_attribute(
          described_class::Attribute.new(
            name: 'second_attr', type: 'attr_type', pii: ''
          )
        )
      end

      it 'returns hash' do
        expect(schema_base.to_h).to eql(
          '@context' => 'https://odca.tech/v1',
          name: 'sb_name',
          type: 'spec/schame_base/1.0',
          description: 'sb_desc',
          classification: 'sb_class',
          issued_by: '',
          :attributes => {
            'attr_name' => 'attr_type',
            'second_attr' => 'attr_type'
          },
          pii_attributes: ['attr_name']
        )
      end
    end
  end

  describe described_class::Attribute do
    let(:attribute) do
      described_class.new(
        name: 'attr_name', type: 'attr_type', pii: pii
      )
    end

    describe '#pii?' do
      context 'attribute is pii' do
        let(:pii) { 'Y' }

        it 'returns true' do
          expect(attribute.pii?).to be true
        end
      end

      context 'attribute is not pii' do
        let(:pii) { '' }

        it 'returns false' do
          expect(attribute.pii?).to be false
        end
      end

      context 'attribute pii is unrecognized' do
        let(:pii) { 'sth' }

        it 'raises error' do
          expect { attribute.pii? }.to raise_error(
            RuntimeError,
            'Unrecognized character: sth'
          )
        end
      end
    end
  end
end
