require 'odca/null_value'

module Odca
  module Overlays
    class SourceOverlay
      attr_reader :source_attributes

      def initialize
        @source_attributes = []
      end

      def to_h
        {
          attr_sources: attr_sources
        }
      end

      def empty?
        source_attributes.empty?
      end

      def add_attribute(source_attribute)
        return if source_attribute.nil? || source_attribute.source.nil?
        source_attributes << source_attribute
      end

      private def attr_sources
        source_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.source
        end
      end

      class SourceAttribute
        attr_reader :attr_name, :source

        def initialize(attr_name:, source:)
          @attr_name = attr_name
          @source = source
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
          source = if value.nil? || value.strip.empty?
                     Odca::NullValue.new
                   else
                     ''
                   end

          {
            attr_name: attr_name.strip,
            source: source
          }
        end
      end
    end
  end
end
