require 'odca/null_value'

module Odca
  module Overlays
    class FormatOverlay
      attr_reader :format_attributes

      def initialize
        @format_attributes = []
      end

      def to_h
        {
          attr_formats: attr_formats
        }
      end

      def empty?
        format_attributes.empty?
      end

      def add_attribute(format_attribute)
        return if format_attribute.nil? || format_attribute.format.empty?
        format_attributes << format_attribute
      end

      private def attr_formats
        format_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.format
        end
      end

      class FormatAttribute
        attr_reader :attr_name, :format

        def initialize(attr_name:, format:)
          @attr_name = attr_name
          @format = format
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
          format = if value.nil? || value.strip.empty?
                     Odca::NullValue.new
                   else
                     value.strip
                   end

          {
            attr_name: attr_name.strip,
            format: format
          }
        end
      end
    end
  end
end
