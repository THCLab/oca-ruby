class Overlay

  attr_accessor :name, :description, :issued_by, :schema_base_id, :type

  def initialize(schema_base_id, issued_by = "")
    @schema_base_id = schema_base_id
    @issued_by = issued_by
  end

  def as_json(options={})
    {
      "@context": "odca: https://odca.tech/",
      name: @name,
      schema_base: @schema_base_id,
      type: @type,
      description: @description,
      issued_by: @issued_by,
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
