require 'odca/overlays/source_overlay'

RSpec.describe Odca::Overlays::SourceOverlay do
  let(:overlay) do
    described_class.new
  end

  describe '#to_h' do
    context 'source overlay has attributes' do
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
          attr_sources: {
            'attr_name' => ''
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

      context 'record is filled' do
        let(:value) { 'Y' }

        it 'sets value as empty string' do
          expect(validator.validate(value))
            .to be_a(String).and be_empty
        end
      end

      context 'record is empty' do
        let(:value) { ' ' }

        it 'sets value as null_value' do
          expect(validator.validate(value))
            .to be_a(Odca::NullValue)
        end
      end
    end
  end
end
