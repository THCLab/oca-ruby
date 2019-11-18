require 'forwardable'

module Odca
  class SchemaBase
    extend Forwardable
    attr_reader :attributes, :header

    def_delegators :header, :name, :description, :classification

    def initialize(header)
      @attributes = []
      @header = header
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
      attr_reader :name, :description, :classification

      def initialize(name:, description:, classification:)
        @name = name
        @description = description
        @classification = classification
      end

      def to_h
        {
          '@context' => 'https://odca.tech/v1',
          name: name,
          type: 'spec/schema_base/1.0',
          description: description,
          classification: classification || '',
          issued_by: ''
        }
      end
    end

    class Attribute
      attr_reader :name, :type, :pii

      def self.new(**args)
        name = args.fetch(:name).strip
        raise 'Attribute name cannot be empty' if name.empty?
        type = args.fetch(:type).strip
        raise 'Attribute type cannot be empty' if type.empty?

        super(
          name: name,
          type: type,
          pii: args.fetch(:pii).to_s.strip
        )
      end

      def initialize(name:, type:, pii:)
        @name = name
        @type = type
        @pii = pii
      end

      def pii?
        case pii
        when 'Y'
          true
        when ''
          false
        else
          raise RuntimeError.new("Unrecognized character: #{pii}")
        end
      end
    end
  end
end
