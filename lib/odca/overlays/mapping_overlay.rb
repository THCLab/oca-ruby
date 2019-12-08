require 'odca/null_value'

module Odca
  module Overlays
    class MappingOverlay
      attr_reader :mapping_attributes

      def initialize
        @mapping_attributes = []
      end

      def to_h
        {
          attr_mapping: attr_mapping
        }
      end

      def empty?
        mapping_attributes.empty?
      end

      def add_attribute(mapping_attribute)
        return if mapping_attribute.nil? || mapping_attribute.mapping.empty?
        mapping_attributes << mapping_attribute
      end

      private def attr_mapping
        mapping_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.mapping
        end
      end

      class MappingAttribute
        attr_reader :attr_name, :mapping

        def initialize(attr_name:, mapping:)
          @attr_name = attr_name
          @mapping = mapping
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
          mapping = if value.nil? || value.strip.empty?
                     Odca::NullValue.new
                   else
                     value.strip
                   end

          {
            attr_name: attr_name.strip,
            mapping: mapping
          }
        end
      end
    end
  end
end
