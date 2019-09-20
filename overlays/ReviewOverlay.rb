class ReviewOverlay < Overlay

  attr_accessor :attr_comments

  def initialize(schema_base_id = "", issued_by = "")
    super(schema_base_id, issued_by)
    @type = "spec/overlay/source/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      attr_comments: @attr_comments
    })
  end

  def is_valid?
    !attr_comments.empty? && super
  end
end

