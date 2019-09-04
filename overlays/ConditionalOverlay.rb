class ConditionalOverlay < Overlay

  attr_accessor :hidden_attributes, :required_attributes

  def initialize(schema_base_id)
    super
    @type = "spec/overlay/conditional/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      hidden_attributes: @hidden_attributes,
      required_attributes: @required_attributes
    })
  end
end

