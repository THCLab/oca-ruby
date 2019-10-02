class Overlay

  attr_accessor :name, :description, :issued_by, :schema_base_id, :type, :role, :purpose

  def initialize(schema_base_id = "", issued_by = "")
    @schema_base_id = schema_base_id
    @issued_by = issued_by
  end

  def as_json(options={})
    {
      "@context": "https://odca.tech/overlays/v1",
      schema_base: @schema_base_id,
      type: @type,
      description: @description,
      issued_by: @issued_by || "",
      role: @role || "",
      purpose: @purpose || ""
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  def is_valid?
    !schema_base_id&.empty?
  end
end
