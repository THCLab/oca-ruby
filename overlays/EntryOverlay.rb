class EntryOverlay < Overlay

  attr_accessor :attr_entries

  def initialize(schema_base_id)
    super
    @type = "spec/overlay/entry/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      attr_entries: @attr_entries
    })
  end

  def is_valid?
    !attr_entries.empty? || super
  end
end
