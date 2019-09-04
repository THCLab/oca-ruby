class EntryOverlay < Overlay

  attr_accessor :default_values

  def initialize(schema_base_id)
    super
    @type = "spec/overlay/entry/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      default_values: @default_values
    })
  end
end
