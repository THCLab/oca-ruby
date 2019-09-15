class FormatOverlay < Overlay

  attr_accessor :attr_formats

  def initialize(schema_base_id)
    super
    @type = "spec/overlay/format/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      issued_by: @issued_by,
      attr_formats: @attr_formats
    })
  end

  def is_valid?
    !attr_formats.empty? || super
  end
end
