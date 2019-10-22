require 'odca/overlays/entry_overlay'

RSpec.describe Odca::Overlays::EntryOverlay do
  let(:overlay) do
    described_class.new(language: 'en')
  end

  describe '#to_h' do
    context 'entry overlay has attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::EntryAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'opt1|opt2|opt3'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::EntryAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'o1|o2'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          language: 'en',
          attr_entries: {
            'attr_name' => %w[opt1 opt2 opt3],
            'sec_attr' => %w[o1 o2]
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
        described_class::EntryAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'o1|o2'
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
          described_class::EntryAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'opt1|opt2|opt3'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::EntryAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'o1|o2'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and array of entries' do
        expect(overlay.__send__(:attr_values))
          .to include(
            'attr_name' => %w[opt1 opt2 opt3],
            'sec_attr' => %w[o1 o2]
          )
      end
    end
  end

  describe described_class::InputValidator do
    describe '#call' do
      let(:validator) do
        described_class.new(attr_name: 'attr_name', value: value)
      end

      context 'record contains pipes' do
        let(:value) { 'opt1|opt2|opt3' }

        it 'splits into array of entries' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            value: %w[opt1 opt2 opt3]
          )
        end
      end

      context 'record does not contain pipes' do
        let(:value) { 'opt1' }

        it 'returns array with one entry' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            value: %w[opt1]
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
