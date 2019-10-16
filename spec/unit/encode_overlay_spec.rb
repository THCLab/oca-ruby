require 'odca/overlays/encode_overlay'

RSpec.describe Odca::Overlays::EncodeOverlay do
  let(:overlay) { described_class.new }

  describe '#to_h' do
    context 'encode overlay has encoding attributes' do
      before(:each) do
        overlay.description = 'desc'
        overlay.role = 'role'
        overlay.purpose = 'purpose'
        overlay.language = 'en'

        overlay.add_encoding_attribute(
          described_class::EncodingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'utf-8'
            ).call
          )
        )
        overlay.add_encoding_attribute(
          described_class::EncodingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'utf-8'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          '@context' => 'https://odca.tech/overlays/v1',
          schema_base: '',
          type: 'spec/overlay/encode/1.0',
          description: 'desc',
          issued_by: '',
          role: 'role',
          purpose: 'purpose',
          language: 'en',
          default_encoding: 'utf-8',
          attr_encoding: {
            'attr_name' => 'utf-8',
            'sec_attr' => 'utf-8'
          }
        )
      end
    end
  end

  describe '#add_encoding_attribute' do
    before(:each) do
      overlay.add_encoding_attribute(attribute)
    end

    context 'when encoding_attribute is provided correctly' do
      let(:attribute) do
        described_class::EncodingAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'utf-8'
          ).call
        )
      end

      it 'adds attribute to encoding_attributes array' do
        expect(overlay.encoding_attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when encoding_attribute is nil' do
      let(:attribute) { nil }

      it 'ignores encoding_attribute' do
        expect(overlay.encoding_attributes).to be_empty
      end
    end
  end

  describe '#attr_encoding' do
    context 'when encoding_attributes are added' do
      before(:each) do
        overlay.add_encoding_attribute(
          described_class::EncodingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'utf-8'
            ).call
          )
        )
        overlay.add_encoding_attribute(
          described_class::EncodingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'utf-8'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and encodings' do
        expect(overlay.__send__(:attr_encoding))
          .to include(
            'attr_name' => 'utf-8',
            'sec_attr' => 'utf-8'
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
        let(:value) { 'utf-8' }

        it 'sets value as encoding' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            encoding: 'utf-8'
          )
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets encoding as null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            encoding: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
