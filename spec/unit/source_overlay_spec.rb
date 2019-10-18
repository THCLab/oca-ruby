require 'odca/overlays/source_overlay'

RSpec.describe Odca::Overlays::SourceOverlay do
  let(:overlay) do
    described_class.new(
      Odca::Overlays::Header.new(
        role: 'role', purpose: 'purpose'
      )
    )
  end

  describe '#to_h' do
    context 'source overlay has source attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::SourceAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'Y'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::SourceAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: ''
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          '@context' => 'https://odca.tech/overlays/v1',
          type: 'spec/overlay/source/1.0',
          description: 'Source endpoints for ',
          issued_by: '',
          role: 'role',
          purpose: 'purpose',
          attr_sources: {
            'attr_name' => ''
          }
        )
      end
    end
  end

  describe '#add_attribute' do
    before(:each) do
      overlay.add_attribute(attribute)
    end

    context 'when source_attribute is provided correctly' do
      let(:attribute) do
        described_class::SourceAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'Y'
          ).call
        )
      end

      it 'adds attribute to source_attributes array' do
        expect(overlay.source_attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when source_attribute is nil' do
      let(:attribute) { nil }

      it 'ignores source_attribute' do
        expect(overlay.source_attributes).to be_empty
      end
    end
  end

  describe '#attr_sources' do
    context 'when source_attributes are added' do
      before(:each) do
        overlay.add_attribute(
          described_class::SourceAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'Y'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::SourceAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'Y'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names as keys' do
        expect(overlay.__send__(:attr_sources))
          .to include(
            'attr_name' => '',
            'sec_attr' => ''
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
        let(:value) { 'Y' }

        it 'sets source as empty string' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            source: ''
          )
        end
      end

      context 'record is empty' do
        let(:value) { ' ' }

        it 'sets source as null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            source: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
