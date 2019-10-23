module Odca
  module Overlays
    class ConditionalOverlay
      attr_accessor :hidden_attributes, :required_attributes

      def to_h
        {
          hidden_attributes: hidden_attributes,
          required_attributes: required_attributes
        }
      end

      def empty?
        hidden_attributes.empty? || required_attributes.empty?
      end
    end
  end
end
