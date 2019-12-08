require 'odca/overlays/mapping_overlay'

RSpec.describe Odca::Overlays::MappingOverlay do
  let(:overlay) do
    described_class.new
  end

  describe '#to_h' do
    context 'mapping overlay has mapping attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'first_name', value: '123456'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'last_name', value: '452354'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          attr_mapping: {
            'first_name' => '123456',
            'last_name' => '452354'
          }
        )
      end
    end
  end

  describe '#add_attribute' do
    before(:each) do
      overlay.add_attribute(attribute)
    end

    context 'when mapping_attribute is provided correctly' do
      let(:attribute) do
        described_class::MappingAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'address', value: '32134'
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
        overlay.add_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'first_name', value: '123456'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'last_name', value: '452354'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and mapping' do
        expect(overlay.__send__(:attr_mapping))
          .to include(
            'first_name' => '123456',
            'last_name' => '452354'
          )
      end
    end
  end

  describe described_class::InputValidator do
    describe '#call' do
      let(:validator) do
        described_class.new(attr_name: 'first_name', value: value)
      end

      context 'record is filled' do
        let(:value) { '452354' }

        it 'sets value as mapping' do
          expect(validator.call).to include(
            attr_name: 'first_name',
            mapping: '452354'
          )
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets mapping as null_value' do
          expect(validator.call).to include(
            attr_name: 'first_name',
            mapping: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
