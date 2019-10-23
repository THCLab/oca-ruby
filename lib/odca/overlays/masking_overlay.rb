require 'odca/null_value'

module Odca
  module Overlays
    class MaskingOverlay
      attr_reader :mask_attributes

      def initialize
        @mask_attributes = []
      end

      def to_h
        {
          attr_masks: attr_masks
        }
      end

      def empty?
        mask_attributes.empty?
      end

      def add_attribute(mask_attribute)
        return if mask_attribute.nil? || mask_attribute.attr_name.strip.empty?
        mask_attributes << mask_attribute
      end

      private def attr_masks
        mask_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.mask
        end
      end

      class MaskingAttribute
        attr_reader :attr_name, :mask

        def initialize(attr_name:, mask:)
          @attr_name = attr_name
          @mask = mask
        end
      end

      class InputValidator
        attr_reader :attr_name, :value

        def initialize(attr_name:, value:)
          if attr_name.strip.empty?
            raise 'Attribute name is expected to be non empty String'
          end

          @attr_name = attr_name
          @value = value
        end

        def call
          mask = if value.nil? || value.strip.empty?
                   Odca::NullValue.new
                 else
                   value.strip
                 end
          {
            attr_name: attr_name.strip,
            mask: mask
          }
        end
      end
    end
  end
end
