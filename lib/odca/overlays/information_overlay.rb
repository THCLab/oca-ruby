require 'odca/overlays/header'
require 'odca/null_value'

module Odca
  module Overlays
    class InformationOverlay
      extend Forwardable
      attr_accessor :language
      attr_reader :information_attributes, :header

      def_delegators :header,
        :issued_by, :type,
        :schema_base_id, :schema_base_id=,
        :role, :purpose,
        :description, :description=

      def initialize(header)
        @information_attributes = []
        header.type = 'spec/overlay/information/1.0'
        @header = header
      end

      def to_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          language: language,
          attr_information: attr_information
        )
      end

      # @deprecated
      def is_valid?
        warn('[DEPRECATION] `is_valid?` is deprecated. ' \
             'Please use `empty?` instead.')
        !empty?
      end

      def empty?
        information_attributes.empty?
      end

      def add_information_attribute(information_attribute)
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
