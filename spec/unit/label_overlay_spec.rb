require 'odca/overlays/label_overlay'

RSpec.describe Odca::Overlays::LabelOverlay do
  let(:overlay) do
    described_class.new(
      Odca::Overlays::Header.new(
        role: 'role', purpose: 'purpose'
      )
    )
  end

  describe '#to_h' do
    context 'label overlay has label attributes' do
      before(:each) do
        overlay.description = 'desc'
        overlay.language = 'en'

        overlay.add_label_attribute(
          described_class::LabelAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'Cat | lab'
            ).call
          )
        )
        overlay.add_label_attribute(
          described_class::LabelAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'Cat | Second label'
            ).call
          )
        )
        overlay.add_label_attribute(
          described_class::LabelAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'third_attr', value: 'Other category | label 3'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          '@context' => 'https://odca.tech/overlays/v1',
          schema_base: '',
          type: 'spec/overlay/label/1.0',
          description: 'desc',
          issued_by: '',
          role: 'role',
          purpose: 'purpose',
          language: 'en',
          attr_labels: {
            'attr_name' => 'lab',
            'sec_attr' => 'Second label',
            'third_attr' => 'label 3'
          },
          attr_categories: %i[cat other_category],
          category_labels: {
            cat: 'Cat',
            other_category: 'Other category'
          },
          category_attributes: {
            cat: %w[attr_name sec_attr],
            other_category: %w[third_attr]
          }
        )
      end
    end
  end

  describe '#add_label_attribute' do
    before(:each) do
      overlay.add_label_attribute(attribute)
    end

    context 'when label_attribute is provided correctly' do
      let(:attribute) do
        described_class::LabelAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'cat | lab'
          ).call
        )
      end

      it 'adds attribute to label_attributes array' do
        expect(overlay.label_attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when label_attribute is nil' do
      let(:attribute) { nil }

      it 'ignores label_attribute' do
        expect(overlay.label_attributes).to be_empty
      end
    end
  end

  context 'generating categories and labels collections' do
    before(:each) do
      overlay.add_label_attribute(
        described_class::LabelAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr_name', value: 'Cat | lab'
          ).call
        )
      )
      overlay.add_label_attribute(
        described_class::LabelAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'sec_attr', value: 'Label'
          ).call
        )
      )
    end

    describe '#attr_labels' do
      it 'returns hash of attribute_names and labels' do
        expect(overlay.__send__(:attr_labels))
          .to include(
            'attr_name' => 'lab',
            'sec_attr' => 'Label'
          )
      end
    end

    describe '#attr_categories' do
      it 'returns categories symbols' do
        expect(overlay.__send__(:attr_categories))
          .to contain_exactly(:cat)
      end
    end

    describe '#category_labels' do
      it 'returns hash of categories symbols and labels' do
        expect(overlay.__send__(:category_labels))
          .to include(cat: 'Cat')
      end
    end

    describe '#category_attributes' do
      it 'returns hash of categories with array of attr_names' do
        expect(overlay.__send__(:category_attributes))
          .to include(cat: ['attr_name'])
      end
    end
  end

  describe described_class::InputValidator do
    describe '#call' do
      let(:validator) do
        described_class.new(attr_name: 'attr_name', value: value)
      end

      context 'record contains one pipe' do
        let(:value) { 'C a t | lab' }

        it 'splits into category and label' do
          expect(validator.call).to include(
            name: 'attr_name',
            category: 'C a t',
            label: 'lab'
          )
        end
      end

      context "record doesn't contain any pipes" do
        let(:value) { 'Label' }

        it 'sets label as value' do
          expect(validator.call).to include(
            name: 'attr_name',
            category: be_a(Odca::NullValue),
            label: 'Label'
          )
        end
      end

      context 'record contains many pipes' do
        let(:value) { '| cat | lab' }

        it 'sets category and label as empty strings' do
          expect(validator.call).to include(
            name: 'attr_name',
            category: be_a(Odca::NullValue),
            label: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
