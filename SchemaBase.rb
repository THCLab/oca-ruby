# @param Name [String] - name of the schema base
# @param Description [String] - short description of the schema base
# @param issued_by [Text] - DID of the issuer, verification steps happens outside of storage, means required trusted framework to deal with verification process
# @param attr_names - array of the attribute names with their types or URI to their definition
class SchemaBase
  attr_accessor :id, :name, :description, :issued_by, :attributes, :pii_attributes

  def as_json(options={})
    {
      "@context": "odca: https://odca.tech/",
      name: @name,
      type: "spec/schame_base/1.0",
      description: @description,
      issued_by: @issued_by,
      attributes: @attributes,
      pii_attributes: @pii_attributes
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
