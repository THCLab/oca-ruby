require 'odca/overlays/header'
require 'odca/null_value'

module Odca
  module Overlays
    class MaskingOverlay
      extend Forwardable
      attr_reader :masking_attributes, :header

      def_delegators :header,
        :issued_by, :type,
        :role, :purpose,
        :description, :description=

      def initialize(header)
        @masking_attributes = []
        header.type = 'spec/overlay/masking/1.0'
        @header = header
      end

      def to_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          attr_maskings: attr_maskings
        )
      end

      def empty?
        masking_attributes.empty?
      end

      def add_masking_attribute(masking_attribute)
        return if masking_attribute.nil? || masking_attribute.attr_name.strip.empty?
        masking_attributes << masking_attribute
      end

      private def attr_maskings
        masking_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.masking
        end
      end

      class MaskingAttribute
        attr_reader :attr_name, :masking

        def initialize(attr_name:, masking:)
          @attr_name = attr_name
          @masking = masking
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
          masking = if value.nil? || value.strip.empty?
                      Odca::NullValue.new
                    else
                      value.strip
                    end
          {
            attr_name: attr_name.strip,
            masking: masking
          }
        end
      end
    end
  end
end
