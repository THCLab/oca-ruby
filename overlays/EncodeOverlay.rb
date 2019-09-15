class EncodeOverlay < Overlay

  attr_accessor :attr_encoding, :language

  def initialize(schema_base_id = "", issued_by = "")
    super(schema_base_id, issued_by)
    @type = "spec/overlay/encode/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      language: @language,
      # If there is no attribute specify on the list default is this
      default_encoding: "utf-8",
      attr_encoding: @attr_encoding
    })
  end

  def is_valid?
    super
  end
end
