require 'odca/overlays/header'
require 'odca/null_value'

module Odca
  module Overlays
    class EncodeOverlay
      extend Forwardable
      attr_accessor :language
      attr_reader :encoding_attributes, :header

      DEFAULT_ENCODING = 'utf-8'.freeze

      def_delegators :header,
        :issued_by, :type,
        :role, :purpose,
        :description, :description=

      def initialize(header)
        @encoding_attributes = []
        header.type = 'spec/overlay/encode/1.0'
        @header = header
      end

      def to_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          language: language,
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
        encoding_attributes.empty?
      end

      def add_encoding_attribute(encoding_attribute)
        return if encoding_attribute.nil? || encoding_attribute.encoding.empty?
        encoding_attributes << encoding_attribute
      end

      private def attr_encoding
        encoding_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.encoding
        end
      end

      class EncodingAttribute
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
