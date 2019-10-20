require 'odca/overlays/mapping_overlay'

RSpec.describe Odca::Overlays::MappingOverlay do
  let(:overlay) do
    described_class.new(
      Odca::Overlays::Header.new(
        role: 'role', purpose: 'purpose'
      )
    )
  end

  describe '#to_h' do
    context 'mapping overlay has mapping attributes' do
      before(:each) do
        overlay.description = 'desc'

        overlay.add_mapping_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii1', value: 'PA_pseudo'
            ).call
          )
        )
        overlay.add_mapping_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii2', value: 'PA_pseudo'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          '@context' => 'https://odca.tech/overlays/v1',
          type: 'spec/overlay/mapping/1.0',
          description: 'desc',
          issued_by: '',
          role: 'role',
          purpose: 'purpose',
          attr_mappings: {
            'pii1' => 'PA_pseudo',
            'pii2' => 'PA_pseudo'
          }
        )
      end
    end
  end

  describe '#add_mapping_attribute' do
    before(:each) do
      overlay.add_mapping_attribute(attribute)
    end

    context 'when mapping_attribute is provided correctly' do
      let(:attribute) do
        described_class::MappingAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'info'
          ).call
        )
      end

      it 'adds attribute to mapping_attributes array' do
        expect(overlay.mapping_attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when mapping_attribute is nil' do
      let(:attribute) { nil }

      it 'ignores mapping_attribute' do
        expect(overlay.mapping_attributes).to be_empty
      end
    end
  end

  describe '#attr_mapping' do
    context 'when mapping_attributes are added' do
      before(:each) do
        overlay.add_mapping_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii1', value: 'PA_pseudo'
            ).call
          )
        )
        overlay.add_mapping_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii2', value: 'PA_pseudo'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and mappings' do
        expect(overlay.__send__(:attr_mappings))
          .to include(
            'pii1' => 'PA_pseudo',
            'pii2' => 'PA_pseudo'
          )
      end
    end
  end

  describe described_class::InputValidator do
    describe '#call' do
      let(:validator) do
        described_class.new(attr_name: 'attr_name', value: value)
      end

      context 'record is filled' do
        let(:value) { 'PA_pseudo' }

        it 'sets value as mapping' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            mapping: 'PA_pseudo'
          )
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets mapping as null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            mapping: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
