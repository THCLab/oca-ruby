class SchemaBase
  extend Forwardable
  attr_reader :attributes, :header

  def_delegators :header,
                 :name, :name=,
                 :description, :description=,
                 :classification, :classification=

  def initialize
    @attributes = []
    @header = Header.new
  end

  def to_h
    header.to_h.merge(
      attributes: attributes.each_with_object({}) do |attr, memo|
        memo[attr.name] = attr.type
      end,
      pii_attributes: pii_attributes.map(&:name)
    )
  end

  def add_attribute(attribute)
    attributes << attribute
  end

  def pii_attributes
    attributes.select(&:pii?)
  end

  def to_json(*options)
    to_h.to_json(*options)
  end

  class Header
    attr_accessor :name, :description, :classification

    def to_h
      {
        '@context' => 'https://odca.tech/v1',
        name: name,
        type: 'spec/schame_base/1.0',
        description: description,
        classification: classification || '',
        issued_by: ''
      }
    end
  end

  class Attribute
    attr_reader :name, :type, :is_pii

    def initialize(name:, type:, is_pii:)
      @name = name
      @type = type
      @is_pii = is_pii
    end

    def pii?
      case is_pii
      when 'Y'
        true
      when ''
        false
      else
        raise 'Unrecognized sign'
      end
    end
  end
end
