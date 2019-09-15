class InformationOverlay < Overlay

  attr_accessor :attr_information

  def initialize(schema_base_id)
    super
    @type = "spec/overlay/information/1.0"
  end

  def as_json(options={})
    super.merge!(
    {
      attr_information: @attr_information
    })
  end

  def is_valid?
    !attr_information.empty? || super
  end
end
