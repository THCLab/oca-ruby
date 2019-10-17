require 'odca/overlays/entry_overlay'

RSpec.describe Odca::Overlays::EntryOverlay do
  let(:overlay) do
    described_class.new(
      Odca::Overlays::Header.new(
        role: 'role', purpose: 'purpose'
      )
    )
  end

  describe '#to_h' do
    context 'entry overlay has entry attributes' do
      before(:each) do
        overlay.description = 'desc'
        overlay.language = 'en'

        overlay.add_entry_attribute(
          described_class::EntryAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'opt1|opt2|opt3'
            ).call
          )
        )
        overlay.add_entry_attribute(
          described_class::EntryAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'o1|o2'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          '@context' => 'https://odca.tech/overlays/v1',
          schema_base: '',
          type: 'spec/overlay/entry/1.0',
          description: 'desc',
          issued_by: '',
          role: 'role',
          purpose: 'purpose',
          language: 'en',
          attr_entries: {
            'attr_name' => %w[opt1 opt2 opt3],
            'sec_attr' => %w[o1 o2]
          }
        )
      end
    end
  end

  describe '#add_entry_attribute' do
    before(:each) do
      overlay.add_entry_attribute(attribute)
    end

    context 'when entry_attribute is provided correctly' do
      let(:attribute) do
        described_class::EntryAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'o1|o2'
          ).call
        )
      end

      it 'adds attribute to entry_attributes array' do
        expect(overlay.entry_attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when entry_attribute is nil' do
      let(:attribute) { nil }

      it 'ignores entry_attribute' do
        expect(overlay.entry_attributes).to be_empty
      end
    end
  end

  describe '#attr_entries' do
    context 'when entry_attributes are added' do
      before(:each) do
        overlay.add_entry_attribute(
          described_class::EntryAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'opt1|opt2|opt3'
            ).call
          )
        )
        overlay.add_entry_attribute(
          described_class::EntryAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'o1|o2'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and array of entries' do
        expect(overlay.__send__(:attr_entries))
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
            entries: %w[opt1 opt2 opt3]
          )
        end
      end

      context 'record does not contain pipes' do
        let(:value) { 'opt1' }

        it 'returns array with one entry' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            entries: %w[opt1]
          )
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets entries as null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            entries: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
