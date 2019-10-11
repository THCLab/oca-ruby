module Odca
  module Overlays
    class ConditionalOverlay < Overlay

      attr_accessor :hidden_attributes, :required_attributes

      def initialize(schema_base_id = "", issued_by = "")
        super(schema_base_id, issued_by)
        @type = "spec/overlay/conditional/1.0"
      end

      def as_json(options={})
        super.merge!(
        {
          hidden_attributes: @hidden_attributes,
          required_attributes: @required_attributes
        })
      end

      def is_valid?
        (!hidden_attributes.empty? || !required_attributes.empty?) && super
      end
    end
  end
end
