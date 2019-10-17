require 'odca/overlays/header'
require 'odca/null_value'

module Odca
  module Overlays
    class SourceOverlay
      extend Forwardable
      attr_reader :source_attributes, :header

      def_delegators :header,
        :issued_by, :type,
        :schema_base_id, :schema_base_id=,
        :role, :purpose,
        :description, :description=

      def initialize(header)
        @source_attributes = []
        header.type = 'spec/overlay/source/1.0'
        @header = header
      end

      def to_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          attr_sources: attr_sources
        )
      end

      # @deprecated
      def is_valid?
        warn('[DEPRECATION] `is_valid?` is deprecated. ' \
             'Please use `empty?` instead.')
        !empty?
      end

      def empty?
        source_attributes.empty?
      end

      def add_source_attribute(source_attribute)
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
