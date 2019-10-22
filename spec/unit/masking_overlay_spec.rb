require 'odca/overlays/masking_overlay'

RSpec.describe Odca::Overlays::MaskingOverlay do
  let(:overlay) do
    described_class.new
  end

  describe '#to_h' do
    context 'masking overlay has masking attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::MaskingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii1', value: 'PA_pseudo'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::MaskingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii2', value: 'PA_pseudo'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          attr_masks: {
            'pii1' => 'PA_pseudo',
            'pii2' => 'PA_pseudo'
          }
        )
      end
    end
  end
end
