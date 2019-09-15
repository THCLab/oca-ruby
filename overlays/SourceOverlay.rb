class SourceOverlay < Overlay

  attr_accessor :attr_sources

  def initialize(schema_base_id)
    super
    @type = "spec/overlay/source/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      attr_sources: @attr_sources
    })
  end
end

