class FormatOverlay < Overlay

  attr_accessor :formats

  def initialize(schema_base_id)
    super
    @type = "spec/overlay/format/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      issued_by: @issued_by,
      attributes_format: @formats
    })
  end
end
