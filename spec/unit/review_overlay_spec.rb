require 'odca/overlays/review_overlay'

RSpec.describe Odca::Overlays::ReviewOverlay do
  let(:overlay) do
    described_class.new(
      Odca::Overlays::Header.new(
        role: 'role', purpose: 'purpose'
      )
    )
  end

  describe '#to_h' do
    context 'review overlay has review attributes' do
      before(:each) do
        overlay.description = 'desc'
        overlay.language = 'en'

        overlay.add_review_attribute(
          described_class::ReviewAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'Y'
            ).call
          )
        )
        overlay.add_review_attribute(
          described_class::ReviewAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: ''
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          '@context' => 'https://odca.tech/overlays/v1',
          type: 'spec/overlay/review/1.0',
          description: 'desc',
          issued_by: '',
          role: 'role',
          purpose: 'purpose',
          language: 'en',
          attr_comments: {
            'attr_name' => ''
          }
        )
      end
    end
  end

  describe '#add_review_attribute' do
    before(:each) do
      overlay.add_review_attribute(attribute)
    end

    context 'when review_attribute is provided correctly' do
      let(:attribute) do
        described_class::ReviewAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'Y'
          ).call
        )
      end

      it 'adds attribute to review_attributes array' do
        expect(overlay.review_attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when review_attribute is nil' do
      let(:attribute) { nil }

      it 'ignores review_attribute' do
        expect(overlay.review_attributes).to be_empty
      end
    end
  end

  describe '#attr_comments' do
    context 'when review_attributes are added' do
      before(:each) do
        overlay.add_review_attribute(
          described_class::ReviewAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'Y'
            ).call
          )
        )
        overlay.add_review_attribute(
          described_class::ReviewAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'Y'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names as keys' do
        expect(overlay.__send__(:attr_comments))
          .to include(
            'attr_name' => '',
            'sec_attr' => ''
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
        let(:value) { 'Y' }

        it 'sets comment as empty string' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            comment: ''
          )
        end
      end

      context 'record is empty' do
        let(:value) { ' ' }

        it 'sets comment as null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            comment: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
