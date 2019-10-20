require 'odca/overlays/masking_overlay'

RSpec.describe Odca::Overlays::MaskingOverlay do
  let(:overlay) do
    described_class.new(
      Odca::Overlays::Header.new(
        role: 'role', purpose: 'purpose'
      )
    )
  end

  describe '#to_h' do
    context 'masking overlay has masking attributes' do
      before(:each) do
        overlay.description = 'desc'

        overlay.add_masking_attribute(
          described_class::MaskingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii1', value: 'PA_pseudo'
            ).call
          )
        )
        overlay.add_masking_attribute(
          described_class::MaskingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii2', value: 'PA_pseudo'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          '@context' => 'https://odca.tech/overlays/v1',
          type: 'spec/overlay/masking/1.0',
          description: 'desc',
          issued_by: '',
          role: 'role',
          purpose: 'purpose',
          attr_maskings: {
            'pii1' => 'PA_pseudo',
            'pii2' => 'PA_pseudo'
          }
        )
      end
    end
  end

  describe '#add_masking_attribute' do
    before(:each) do
      overlay.add_masking_attribute(attribute)
    end

    context 'when masking_attribute is provided correctly' do
      let(:attribute) do
        described_class::MaskingAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'info'
          ).call
        )
      end

      it 'adds attribute to masking_attributes array' do
        expect(overlay.masking_attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when masking_attribute is nil' do
      let(:attribute) { nil }

      it 'ignores masking_attribute' do
        expect(overlay.masking_attributes).to be_empty
      end
    end
  end

  describe '#attr_masking' do
    context 'when masking_attributes are added' do
      before(:each) do
        overlay.add_masking_attribute(
          described_class::MaskingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii1', value: 'PA_pseudo'
            ).call
          )
        )
        overlay.add_masking_attribute(
          described_class::MaskingAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'pii2', value: 'PA_pseudo'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and maskings' do
        expect(overlay.__send__(:attr_maskings))
          .to include(
            'pii1' => 'PA_pseudo',
            'pii2' => 'PA_pseudo'
          )
      end
    end
  end

  describe described_class::InputValidator do
    describe '#call' do
      let(:validator) do
        described_class.new(attr_name: 'attr_name', value: value)
      end

      context 'record is filled' do
        let(:value) { 'PA_pseudo' }

        it 'sets value as masking' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            masking: 'PA_pseudo'
          )
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets masking as null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            masking: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
