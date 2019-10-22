require 'odca/overlays/information_overlay'

RSpec.describe Odca::Overlays::InformationOverlay do
  let(:overlay) do
    described_class.new(language: 'en')
  end

  describe '#to_h' do
    context 'information overlay has attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'info'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::InformationAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'some info'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          language: 'en',
          attr_information: {
            'attr_name' => 'info',
            'sec_attr' => 'some info'
          }
        )
      end
    end
  end
end
