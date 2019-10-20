require 'odca/overlays/header'

module Odca
  module Overlays
    class ConditionalOverlay
      extend Forwardable
      attr_accessor :hidden_attributes, :required_attributes
      attr_reader :header

      def_delegators :header,
        :issued_by, :type,
        :role, :purpose,
        :description, :description=

      def initialize(header)
        header.type = 'spec/overlay/conditional/1.0'
        @header = header
      end

      def as_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          hidden_attributes: hidden_attributes,
          required_attributes: required_attributes
        )
      end

      # @deprecated
      def is_valid?
        warn('[DEPRECATION] `is_valid?` is deprecated. ' \
             'Please use `empty?` instead.')
        !empty?
      end

      def empty?
        hidden_attributes.empty? || required_attributes.empty?
      end
    end
  end
end
