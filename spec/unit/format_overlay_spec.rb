require 'odca/overlays/format_overlay'

RSpec.describe Odca::Overlays::FormatOverlay do
  let(:overlay) do
    described_class.new(
      Odca::Overlays::Header.new(
        role: 'role', purpose: 'purpose'
      )
    )
  end

  describe '#to_h' do
    context 'format overlay has format attributes' do
      before(:each) do
        overlay.description = 'desc'

        overlay.add_format_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'DD/MM/YYYY'
            ).call
          )
        )
        overlay.add_format_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'YYYY/MM/DD'
            ).call
          )
        )
        overlay.add_format_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'third_attr', value: 'MM/DD/YYYY'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          '@context' => 'https://odca.tech/overlays/v1',
          schema_base: '',
          type: 'spec/overlay/format/1.0',
          description: 'desc',
          issued_by: '',
          role: 'role',
          purpose: 'purpose',
          attr_formats: {
            'attr_name' => 'DD/MM/YYYY',
            'sec_attr' => 'YYYY/MM/DD',
            'third_attr' => 'MM/DD/YYYY'
          }
        )
      end
    end
  end

  describe '#add_format_attribute' do
    before(:each) do
      overlay.add_format_attribute(attribute)
    end

    context 'when format_attribute is provided correctly' do
      let(:attribute) do
        described_class::FormatAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'DD/MM/YYYY'
          ).call
        )
      end

      it 'adds attribute to label_attributes array' do
        expect(overlay.format_attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when format_attribute is nil' do
      let(:attribute) { nil }

      it 'ignores format_attribute' do
        expect(overlay.format_attributes).to be_empty
      end
    end
  end

  describe '#attr_formats' do
    context 'when format_attributes are added' do
      before(:each) do
        overlay.add_format_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'DD/MM/YYYY'
            ).call
          )
        )
        overlay.add_format_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'YYYY/MM/DD'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and formats' do
        expect(overlay.__send__(:attr_formats))
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

        it 'sets value as format' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            format: 'MM/DD/YYYY'
          )
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets format null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            format: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
