require 'odca/overlay'
require 'odca/null_value'

RSpec.describe Odca::Overlay do
  overlay_class = class TestOverlay
                    extend Odca::Overlay
                  end
  let(:overlay) { overlay_class.new }

  describe '#add_attribute' do
    before(:each) do
      overlay.add_attribute(attribute)
    end

    context 'when attribute is provided correctly' do
      let(:attribute) do
        overlay_class::TestAttribute.new(
          overlay_class::InputValidator.new(
            attr_name: 'attr', value: 'val'
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

  describe '#attr_values' do
    context 'when attributes are added' do
      before(:each) do
        overlay.add_attribute(
          overlay_class::TestAttribute.new(
            overlay_class::InputValidator.new(
              attr_name: 'attr_name', value: 'val1'
            ).call
          )
        )
        overlay.add_attribute(
          overlay_class::TestAttribute.new(
            overlay_class::InputValidator.new(
              attr_name: 'sec_attr', value: 'val2'
            ).call
          )
        )
      end

      it 'returns hash of attribute_names and values' do
        expect(overlay.__send__(:attr_values))
          .to include(
            'attr_name' => 'val1',
            'sec_attr' => 'val2'
          )
      end
    end
  end

  describe overlay_class::InputValidator do
    describe '#call' do
      let(:validator) do
        described_class.new(attr_name: 'attr_name', value: value)
      end

      context 'record is filled' do
        let(:value) { 'val' }

        it 'sets input as value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            value: 'val'
          )
        end
      end

      context 'record is empty' do
        let(:value) { '  ' }

        it 'sets value as null_value' do
          expect(validator.call).to include(
            attr_name: 'attr_name',
            value: be_a(Odca::NullValue)
          )
        end
      end
    end
  end
end
