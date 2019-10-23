require 'odca/null_value'

module Odca
  module Overlays
    class EncodeOverlay
      attr_reader :encode_attributes

      DEFAULT_ENCODING = 'utf-8'.freeze

      def initialize
        @encode_attributes = []
      end

      def to_h
        {
          default_encoding: DEFAULT_ENCODING,
          attr_encoding: attr_encoding
        }
      end

      def empty?
        encode_attributes.empty?
      end

      def add_attribute(encode_attribute)
        return if encode_attribute.nil? || encode_attribute.encoding.empty?
        encode_attributes << encode_attribute
      end

      private def attr_encoding
        encode_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.encoding
        end
      end

      class EncodeAttribute
        attr_reader :attr_name, :encoding

        def initialize(attr_name:, encoding:)
          @attr_name = attr_name
          @encoding = encoding
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
          encoding = if value.nil? || value.strip.empty?
                       Odca::NullValue.new
                     else
                       value.strip
                     end

          {
            attr_name: attr_name.strip,
            encoding: encoding
          }
        end
      end
    end
  end
end
