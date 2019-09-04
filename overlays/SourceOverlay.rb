class SourceOverlay < Overlay

  attr_accessor :sources

  def initialize(schema_base_id)
    super
    @type = "spec/overlay/source/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      sources: @sources
    })
  end
end

