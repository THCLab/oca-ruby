module Odca
  module Overlays
    class LabelOverlay < Overlay

      attr_accessor :attr_labels, :language, :attr_categories, :category_labels

      def initialize(schema_base_id = "", issued_by = "")
        super(schema_base_id, issued_by)
        @type = "spec/overlay/label/1.0"
      end

      def as_json(options={})
        super.merge!(
        {
          language: @language,
          attr_labels: @attr_labels,
          attr_categories: @attr_categories,
          category_labels: @category_labels
        })
      end

      def is_valid?
        (!attr_labels.empty? || !attr_categories.empty?) && super
      end
    end
  end
end
