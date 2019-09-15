class SourceOverlay < Overlay

  attr_accessor :attr_sources

  def initialize(schema_base_id = "", issued_by = "")
    super(schema_base_id, issued_by)
    @type = "spec/overlay/source/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      attr_sources: @attr_sources
    })
  end

  def is_valid?
    !attr_sources.empty? && super
  end
end

