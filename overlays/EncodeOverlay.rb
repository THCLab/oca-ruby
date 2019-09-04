class EncodeOverlay < Overlay

  attr_accessor :attr_encoding, :language

  def initialize(schema_base_id)
    super
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
end
