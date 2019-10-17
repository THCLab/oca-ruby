require 'odca/overlays/information_overlay'

RSpec.describe Odca::Overlays::InformationOverlay do
  let(:overlay) { described_class.new }

  describe '#to_h' do
    context 'information overlay has information attributes' do
      before(:each) do
        overlay.description = 'desc'
        overlay.role = 'role'
        overlay.purpose = 'purpose'
        overlay.language = 'en'

        overlay.add_information_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'info'
            ).call
          )
        )
        overlay.add_information_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'some info'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          '@context' => 'https://odca.tech/overlays/v1',
          schema_base: '',
          type: 'spec/overlay/information/1.0',
          description: 'desc',
          issued_by: '',
          role: 'role',
          purpose: 'purpose',
          language: 'en',
          attr_information: {
            'attr_name' => 'info',
            'sec_attr' => 'some info'
          }
        )
      end
    end
  end

  describe '#add_information_attribute' do
    before(:each) do
      overlay.add_information_attribute(attribute)
    end

    context 'when information_attribute is provided correctly' do
      let(:attribute) do
        described_class::InformationAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'info'
          ).call
        )
      end

      it 'adds attribute to information_attributes array' do
        expect(overlay.information_attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when information_attribute is nil' do
      let(:attribute) { nil }

      it 'ignores information_attribute' do
        expect(overlay.information_attributes).to be_empty
      end
    end
  end

  describe '#attr_information' do
    context 'when information_attributes are added' do
      before(:each) do
        overlay.add_information_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'info'
            ).call
          )
        )
        overlay.add_information_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'some info'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and information' do
        expect(overlay.__send__(:attr_information))
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

        it 'sets value as information' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            information: 'info'
          )
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets information as null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            information: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
