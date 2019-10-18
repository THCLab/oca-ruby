module Odca
  class SchemaParser
    attr_reader :records, :overlay_dtos

    def initialize(records, overlay_dtos)
      @records = records
      @overlay_dtos = overlay_dtos
    end

    def call
      schema_base = Odca::SchemaBase.new(
        Odca::SchemaBase::Header.new(
          name: records.first[0],
          description: records.first[1],
          classification: records.first[2]
        )
      )

      overlay_attrs = {}
      overlay_indexes = overlay_dtos.map(&:index)

      records.each do |row|
        attr_name = row[3]
        schema_base.add_attribute(
          SchemaBase::Attribute.new(
            name: attr_name,
            type: row[4],
            pii: row[5]
          )
        )
        overlay_indexes.each do |ov_index|
          next unless row[ov_index]
          (overlay_attrs[ov_index] ||= []) << {
            name: attr_name,
            value: row[ov_index]
          }
        end
      end

      overlays = []
      overlay_dtos.each do |overlay_dto|
        attrs = overlay_attrs[overlay_dto.index]
        next unless attrs

        overlay = create_overlay(overlay_dto)
        attrs.each do |attr|
          add_attribute(
            to: overlay,
            schema_base_name: schema_base.name,
            attr_name: attr[:name],
            value: attr[:value]
          )
        end
        overlays << overlay
      end

      [schema_base, overlays]
    end

    def add_attribute(to:, schema_base_name:, attr_name:, value:)
      overlay = to
      overlay_name = overlay.class.name.split('::').last
      attribute_class = overlay.class
        .const_get(overlay_name.gsub('Overlay', 'Attribute'))
      validator_class = overlay.class
        .const_get('InputValidator')

      overlay.add_attribute(
        attribute_class.new(
          validator_class.new(
            attr_name: attr_name,
            value: value
          ).call
        )
      )

      case overlay_name
      when 'FormatOverlay'
        overlay.description = "Attribute formats for #{schema_base_name}"
      when 'LabelOverlay'
        overlay.description = "Category and attribute labels for #{schema_base_name}"
      when 'EncodeOverlay'
        overlay.description = "Character set encoding for #{schema_base_name}"
      when 'EntryOverlay'
        overlay.description = "Field entries for #{schema_base_name}"
      when 'InformationOverlay'
        overlay.description = "Informational items for #{schema_base_name}"
      when 'SourceOverlay'
        overlay.description = "Source endpoints for #{schema_base_name}"
      when 'ReviewOverlay'
        overlay.description = "Field entry review comments for #{schema_base_name}"
      when 'MaskingOverlay'
        overlay.description = "Masking attributes for #{schema_base_name}"
      else
        puts "Error uknown overlay: #{overlay}"
      end
    end

    private def create_overlay(overlay_dto)
      overlay_class = Odca::Overlays.const_get(
        overlay_dto.name.delete(' ')
      )
      overlay = overlay_class.new(
        Odca::Overlays::Header.new(
          role: overlay_dto.role,
          purpose: overlay_dto.purpose
        )
      )
      overlay.language = overlay_dto.language if defined? overlay.language
      overlay
      rescue => e
        raise "Not found Overlay Class for '#{overlay_dto.name}': #{e}"
    end
  end
end
