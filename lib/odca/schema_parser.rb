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

      entry_overlay_indexes = overlay_dtos.select do |ov|
        ov.name == 'Entry Overlay'
      end.map(&:index)

      records.each do |row|
        attr_name = row[3]
        attr_type = row[4]
        entry_overlay_indexes.each do |ov_index|
          if row[ov_index]
            attr_type = 'Array[Text]'
            break
          end
        end

        schema_base.add_attribute(
          SchemaBase::Attribute.new(
            name: attr_name,
            type: attr_type,
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
            attr_name: attr[:name],
            value: attr[:value]
          )
        end
        overlays << Odca::HeadfulOverlay.new(
          parentful_overlay: Odca::ParentfulOverlay.new(
            parent: schema_base, overlay: overlay
          ),
          role: overlay_dto.role,
          purpose: overlay_dto.purpose
        )
      end

      [schema_base, overlays]
    end

    def add_attribute(to:, attr_name:, value:)
      overlay = to
      overlay_name = overlay.class.name.split('::').last
      begin
        attribute_class = overlay.class
          .const_get(overlay_name.gsub('Overlay', 'Attribute'))
        validator_class = overlay.class
          .const_get('InputValidator')
      rescue => e
        raise "Not found Attribute Class for '#{overlay_name}': #{e}"
      end

      overlay.add_attribute(
        attribute_class.new(
          validator_class.new(
            attr_name: attr_name,
            value: value
          ).call
        )
      )
    end

    private def create_overlay(overlay_dto)
      overlay_class = Odca::Overlays.const_get(
        overlay_dto.name.delete(' ')
      )
      if overlay_class.method_defined? 'language'
        overlay_class.new(language: overlay_dto.language)
      else
        overlay_class.new
      end
      rescue => e
        raise "Not found Overlay Class for '#{overlay_dto.name}': #{e}"
    end
  end
end
