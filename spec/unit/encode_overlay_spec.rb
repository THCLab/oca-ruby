require 'odca/overlays/encode_overlay'

RSpec.describe Odca::Overlays::EncodeOverlay do
  let(:overlay) do
    described_class.new
  end

  describe '#to_h' do
    context 'encode overlay has attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::EncodeAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'utf-8'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::EncodeAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'utf-8'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          default_encoding: 'utf-8',
          attr_encoding: {
            'attr_name' => 'utf-8',
            'sec_attr' => 'utf-8'
          }
        )
      end
    end
  end
end
