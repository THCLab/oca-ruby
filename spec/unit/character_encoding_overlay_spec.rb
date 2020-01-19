require 'odca/overlays/character_encoding_overlay'

RSpec.describe Odca::Overlays::CharacterEncodingOverlay do
  let(:overlay) do
    described_class.new
  end

  describe '#to_h' do
    context 'character encoding overlay has attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::CharacterEncodingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'utf-8'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::CharacterEncodingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'utf-8'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          default_character_encoding: 'utf-8',
          attr_character_encoding: {
            'attr_name' => 'utf-8',
            'sec_attr' => 'utf-8'
          }
        )
      end
    end
  end
end
