require 'odca/overlays/header'
require 'odca/null_value'

module Odca
  module Overlays
    class MappingOverlay
      extend Forwardable
      attr_reader :mapping_attributes, :header

      def_delegators :header,
        :issued_by, :type,
        :role, :purpose,
        :description, :description=

      def initialize(header)
        @mapping_attributes = []
        header.type = 'spec/overlay/mapping/1.0'
        @header = header
      end

      def to_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          attr_mappings: attr_mappings
        )
      end

      def empty?
        mapping_attributes.empty?
      end

      def add_mapping_attribute(mapping_attribute)
        return if mapping_attribute.nil? || mapping_attribute.attr_name.strip.empty?
        mapping_attributes << mapping_attribute
      end

      private def attr_mappings
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
