require 'odca/overlays/information_overlay'

RSpec.describe Odca::Overlays::InformationOverlay do
  let(:overlay) do
    described_class.new(language: 'en')
  end

  describe '#to_h' do
    context 'information overlay has attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'info'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'some info'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          language: 'en',
          attr_information: {
            'attr_name' => 'info',
            'sec_attr' => 'some info'
          }
        )
      end
    end
  end

  describe '#add_attribute' do
    before(:each) do
      overlay.add_attribute(attribute)
    end

    context 'when attribute is provided correctly' do
      let(:attribute) do
        described_class::InformationAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'info'
          ).call
        )
      end

      it 'adds attribute to attributes array' do
        expect(overlay.attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when attribute is nil' do
      let(:attribute) { nil }

      it 'ignores attribute' do
        expect(overlay.attributes).to be_empty
      end
    end
  end

  describe '#attr_values' do
    context 'when attributes are added' do
      before(:each) do
        overlay.add_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'info'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'some info'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and information' do
        expect(overlay.__send__(:attr_values))
          .to include(
            'attr_name' => 'info',
            'sec_attr' => 'some info'
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
        let(:value) { 'info' }

        it 'sets input as value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            value: 'info'
          )
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets value as null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            value: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
