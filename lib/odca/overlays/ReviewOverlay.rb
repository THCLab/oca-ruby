module Odca
  module Overlays
    class ReviewOverlay < Overlay

        attr_accessor :attr_comments, :language

        def initialize(schema_base_id = "", issued_by = "")
          super(schema_base_id, issued_by)
          @type = "spec/overlay/review/1.0"
        end

        def as_json(options={})
          super.merge!(
          {
            language: @language,
            attr_comments: @attr_comments,
          })
        end

        def is_valid?
          !attr_comments.empty? && super
        end
      end
  end
end
