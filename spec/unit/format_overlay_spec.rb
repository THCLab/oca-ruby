require 'odca/overlays/format_overlay'

RSpec.describe Odca::Overlays::FormatOverlay do
  let(:overlay) do
    described_class.new
  end

  describe '#to_h' do
    context 'format overlay has attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'DD/MM/YYYY'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'YYYY/MM/DD'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'third_attr', value: 'MM/DD/YYYY'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          attr_formats: {
            'attr_name' => 'DD/MM/YYYY',
            'sec_attr' => 'YYYY/MM/DD',
            'third_attr' => 'MM/DD/YYYY'
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
        described_class::FormatAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'DD/MM/YYYY'
          ).call
        )
      end

      it 'adds attribute to label_attributes array' do
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
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'DD/MM/YYYY'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'YYYY/MM/DD'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and formats' do
        expect(overlay.__send__(:attr_values))
          .to include(
            'attr_name' => 'DD/MM/YYYY',
            'sec_attr' => 'YYYY/MM/DD'
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
        let(:value) { 'MM/DD/YYYY' }

        it 'sets input as value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            value: 'MM/DD/YYYY'
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
