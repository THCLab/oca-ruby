class LabelOverlay < Overlay

  attr_accessor :attr_labels, :language, :attr_categories, :category_labels

  def initialize(schema_base_id)
    super
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
end
