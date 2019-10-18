require 'odca/overlays/header'
require 'odca/null_value'

module Odca
  module Overlays
    class EncodeOverlay
      extend Forwardable
      attr_accessor :language
      attr_reader :encode_attributes, :header

      DEFAULT_ENCODING = 'utf-8'.freeze

      def_delegators :header,
        :issued_by, :type, :role, :purpose, :description

      def initialize(header)
        @encode_attributes = []
        header.type = 'spec/overlay/encode/1.0'
        header.description = 'Character set encoding for '
        @header = header
      end

      def to_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          default_encoding: DEFAULT_ENCODING,
          attr_encoding: attr_encoding
        )
      end

      # @deprecated
      def is_valid?
        warn('[DEPRECATION] `is_valid?` is deprecated. ' \
             'Please use `empty?` instead.')
        !empty?
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
