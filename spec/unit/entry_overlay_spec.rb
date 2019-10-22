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

  describe described_class::InputValidator do
    describe '#validate' do
      let(:validator) do
        described_class.new(attr_name: 'attr_name', value: value)
      end

      context 'record contains pipes' do
        let(:value) { 'opt1|opt2|opt3' }

        it 'splits into array of entries' do
          expect(validator.validate(value))
            .to contain_exactly('opt1', 'opt2', 'opt3')
        end
      end

      context 'record does not contain pipes' do
        let(:value) { 'opt1' }

        it 'returns array with one entry' do
          expect(validator.validate(value))
            .to contain_exactly('opt1')
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets value as null_value' do
          expect(validator.validate(value))
            .to be_a(Odca::NullValue)
        end
      end
    end
  end
end
