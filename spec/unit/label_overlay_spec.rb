require 'odca/overlays/label_overlay'

RSpec.describe Odca::Overlays::LabelOverlay do
  let(:overlay) do
    described_class.new(language: 'en')
  end

  describe '#to_h' do
    context 'label overlay has attributes' do
      before(:each) do
        overlay.add_attribute(
          described_class::LabelAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'attr_name', value: 'Cat | lab'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::LabelAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'Cat | Second label'
            ).call
          )
        )
        overlay.add_attribute(
          described_class::LabelAttribute.new(
            described_class::InputValidator.new(
              attr_name: 'third_attr', value: 'Other category | label 3'
            ).call
          )
        )
      end

      it 'returns filled hash' do
        expect(overlay.to_h).to eql(
          language: 'en',
          attr_labels: {
            'attr_name' => 'lab',
            'sec_attr' => 'Second label',
            'third_attr' => 'label 3'
          },
          attr_categories: %w[_cat-1_ _cat-2_],
          cat_labels: {
            '_cat-1_' => 'Cat',
            '_cat-2_' => 'Other category'
          },
          cat_attributes: {
            '_cat-1_' => %w[attr_name sec_attr],
            '_cat-2_' => %w[third_attr]
          }
        )
      end
    end
  end

  describe '#add_attribute' do
    before(:each) do
      overlay.add_attribute(attribute)
    end

    context 'when attribute is provided correctly' do
      let(:attribute) do
        described_class::LabelAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr', value: 'cat | lab'
          ).call
        )
      end

      it 'adds attribute to attributes array' do
        expect(overlay.attributes)
          .to contain_exactly(attribute)
      end
    end

    context 'when attribute is nil' do
      let(:attribute) { nil }

      it 'ignores attribute' do
        expect(overlay.attributes).to be_empty
      end
    end
  end

  context 'generating categories and labels collections' do
    before(:each) do
      overlay.add_attribute(
        described_class::LabelAttribute.new(
          described_class::InputValidator.new(
            attr_name: 'attr_name', value: 'Cat | lab'
          ).call
        )
      )
      overlay.add_attribute(
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
  end

  describe described_class::CategoryResolver do
    let(:category_resolver) do
      described_class.new
    end

    before(:each) do
      category_resolver.call(
        [
          Odca::Overlays::LabelOverlay::LabelAttribute.new(
            Odca::Overlays::LabelOverlay::InputValidator.new(
              attr_name: 'attr_name', value: 'Cat | lab'
            ).call
          ),
          Odca::Overlays::LabelOverlay::LabelAttribute.new(
            Odca::Overlays::LabelOverlay::InputValidator.new(
              attr_name: 'attr_2', value: 'Cat | nested1 | lab'
            ).call
          ),
          Odca::Overlays::LabelOverlay::LabelAttribute.new(
            Odca::Overlays::LabelOverlay::InputValidator.new(
              attr_name: 'attr_3', value: 'Cat | nested2 | lab'
            ).call
          ),
          Odca::Overlays::LabelOverlay::LabelAttribute.new(
            Odca::Overlays::LabelOverlay::InputValidator.new(
              attr_name: 'sec_attr', value: 'Label'
            ).call
          )
        ]
      )
    end

    describe '#attr_categories' do
      it 'returns categories symbols' do
        expect(category_resolver.__send__(:attr_categories))
          .to contain_exactly('_cat-1_', '_cat-1-1_', '_cat-1-2_')
      end
    end

    describe '#category_labels' do
      it 'returns hash of categories symbols and labels' do
        expect(category_resolver.__send__(:category_labels))
          .to include(
            '_cat-1_' => 'Cat',
            '_cat-1-1_' => 'nested1',
            '_cat-1-2_' => 'nested2'
          )
      end
    end

    describe '#category_attributes' do
      it 'returns hash of categories with array of attr_names' do
        expect(category_resolver.__send__(:category_attributes))
          .to include(
            '_cat-1_' => ['attr_name'],
            '_cat-1-1_' => ['attr_2'],
            '_cat-1-2_' => ['attr_3']
        )
      end
    end
  end

  describe described_class::InputValidator do
    describe '#call' do
      let(:validator) do
        described_class.new(attr_name: 'attr_name', value: value)
      end

      context "record doesn't contain any pipes" do
        let(:value) { 'Label' }

        it 'sets label as value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            categories: [],
            label: 'Label'
          )
        end
      end

      context 'record contains one pipe' do
        let(:value) { 'C a t | lab' }

        it 'splits into categories and label' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            categories: ['C a t'],
            label: 'lab'
          )
        end
      end

      context 'record contains many pipes' do
        let(:value) { 'cat | cat1 | lab' }

        it 'splits into subcategories and label' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            categories: %w[cat cat1],
            label: 'lab'
          )
        end
      end
    end
  end
end
