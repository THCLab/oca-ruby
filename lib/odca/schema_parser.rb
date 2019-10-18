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
      case overlay.class.name.split('::').last
      when 'FormatOverlay'
        overlay.add_format_attribute(
          Odca::Overlays::FormatOverlay::FormatAttribute.new(
            Odca::Overlays::FormatOverlay::InputValidator.new(
              attr_name: attr_name,
              value: value
            ).call
          )
        )
        overlay.description = "Attribute formats for #{schema_base_name}"
      when 'LabelOverlay'
        overlay.add_label_attribute(
          Odca::Overlays::LabelOverlay::LabelAttribute.new(
            Odca::Overlays::LabelOverlay::InputValidator.new(
              attr_name: attr_name,
              value: value
            ).call
          )
        )
        overlay.description = "Category and attribute labels for #{schema_base_name}"
      when 'EncodeOverlay'
        overlay.add_encode_attribute(
          Odca::Overlays::EncodeOverlay::EncodeAttribute.new(
            Odca::Overlays::EncodeOverlay::InputValidator.new(
              attr_name: attr_name,
              value: value
            ).call
          )
        )
        overlay.description = "Character set encoding for #{schema_base_name}"
      when 'EntryOverlay'
        overlay.add_entry_attribute(
          Odca::Overlays::EntryOverlay::EntryAttribute.new(
            Odca::Overlays::EntryOverlay::InputValidator.new(
              attr_name: attr_name,
              value: value
            ).call
          )
        )
        overlay.description = "Field entries for #{schema_base_name}"
      when 'InformationOverlay'
        overlay.add_information_attribute(
          Odca::Overlays::InformationOverlay::InformationAttribute.new(
            Odca::Overlays::InformationOverlay::InputValidator.new(
              attr_name: attr_name,
              value: value
            ).call
          )
        )
        overlay.description = "Informational items for #{schema_base_name}"
      when 'SourceOverlay'
        overlay.add_source_attribute(
          Odca::Overlays::SourceOverlay::SourceAttribute.new(
            Odca::Overlays::SourceOverlay::InputValidator.new(
              attr_name: attr_name,
              value: value
            ).call
          )
        )
        overlay.description = "Source endpoints for #{schema_base_name}"
      when 'ReviewOverlay'
        overlay.add_review_attribute(
          Odca::Overlays::ReviewOverlay::ReviewAttribute.new(
            Odca::Overlays::ReviewOverlay::InputValidator.new(
              attr_name: attr_name,
              value: value
            ).call
          )
        )
        overlay.description = "Field entry review comments for #{schema_base_name}"
      when 'MaskingOverlay'
        overlay.add_masking_attribute(
          Odca::Overlays::MaskingOverlay::MaskingAttribute.new(
            Odca::Overlays::MaskingOverlay::InputValidator.new(
              attr_name: attr_name,
              value: value
            ).call
          )
        )
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
