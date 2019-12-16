require 'odca/overlays/mapping_overlay'

RSpec.describe Odca::Overlays::MappingOverlay do
  let(:overlay) do
    described_class.new
  end

  describe '#to_h' do
    context 'mapping overlay has mapping attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr1', value: 'map_1'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::MappingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr2', value: 'map_2'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          attr_mapping: {
            'attr1' => 'map_1',
            'attr2' => 'map_2'
          }
        )
      end
    end
  end
end
