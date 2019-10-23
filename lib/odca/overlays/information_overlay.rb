require 'odca/null_value'

module Odca
  module Overlays
    class InformationOverlay
      attr_reader :information_attributes, :language

      def initialize(language:)
        @information_attributes = []
        @language = language
      end

      def to_h
        {
          language: language,
          attr_information: attr_information
        }
      end

      def empty?
        information_attributes.empty?
      end

      def add_attribute(information_attribute)
        if information_attribute.nil? ||
            information_attribute.information.empty?
          return
        end
        information_attributes << information_attribute
      end

      private def attr_information
        information_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.information
        end
      end

      class InformationAttribute
        attr_reader :attr_name, :information

        def initialize(attr_name:, information:)
          @attr_name = attr_name
          @information = information
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
          info = if value.nil? || value.strip.empty?
                   Odca::NullValue.new
                 else
                   value.strip
                 end

          {
            attr_name: attr_name.strip,
            information: info
          }
        end
      end
    end
  end
end
