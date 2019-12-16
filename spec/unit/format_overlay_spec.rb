require 'odca/overlays/format_overlay'

RSpec.describe Odca::Overlays::FormatOverlay do
  let(:overlay) do
    described_class.new
  end

  describe '#to_h' do
    context 'format overlay has attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'DD/MM/YYYY'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'YYYY/MM/DD'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::FormatAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'third_attr', value: 'MM/DD/YYYY'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          attr_formats: {
            'attr_name' => 'DD/MM/YYYY',
            'sec_attr' => 'YYYY/MM/DD',
            'third_attr' => 'MM/DD/YYYY'
          }
        )
      end
    end
  end
end
