require 'csv'
require 'fileutils'
require 'odca/odca.rb'
require 'odca/hashlink_generator'
require 'json'
require 'pp'

module Odca
  class BigParser
    attr_reader :records, :output_dir, :overlay_dtos

    def initialize(filename, output_dir)
      @overlay_dtos = []
      @records = CSV.read(filename, col_sep: ';')
      @output_dir = output_dir
    end

    def call
      schema_base = SchemaBase.new

      columns_number = records[0].size

      puts 'Reading overlays ...'
      (6..columns_number - 1).each do |i|
        overlay_dtos << Overlay.new(
          index: i,
          name: records[2][i],
          role: records[0][i],
          purpose: records[1][i],
          language: records[3][i]
        )
      end

      overlays = reset_overlays

      # Drop header before start filling the object
      records.slice!(0, 4)
      puts "Overlays loaded, start creating objects"
      rows_count = records.size
      records.each_with_index do |row, i|
        # Save it only if schema base change which means that we parsed all attributes for
        # previous schema base or end of rows
        if (schema_base.name != row[0] and schema_base.name != nil) or (i+1 == rows_count)
          save(
            schema_base: schema_base,
            overlays: overlays.values
          )

          schema_base = SchemaBase.new
          overlays = reset_overlays
        end

        # START Schema base object
        schema_base.name = row[0]
        schema_base.description = row[1]
        schema_base.classification = row[2]

        attr_name = row[3]
        attr_type = row[4]

        schema_base.add_attribute(
          SchemaBase::Attribute.new(
            name: attr_name,
            type: attr_type,
            pii: row[5]
          )
        )
        # END Schema base object

        # START Overlays
        overlays.each { |index,overlay|
          case overlay.class.name.split('::').last
          when "FormatOverlay"
            overlay.add_format_attribute(
              Odca::Overlays::FormatOverlay::FormatAttribute.new(
                Odca::Overlays::FormatOverlay::InputValidator.new(
                  attr_name: attr_name,
                  value: row[index]
                ).call
              )
            )
            overlay.description = "Attribute formats for #{schema_base.name}"
          when "LabelOverlay"
            if row[index]
              overlay.add_label_attribute(
                Odca::Overlays::LabelOverlay::LabelAttribute.new(
                  Odca::Overlays::LabelOverlay::InputValidator.new(
                    attr_name: attr_name,
                    value: row[index]
                  ).call
                )
              )
            end
            overlay.description = "Category and attribute labels for #{schema_base.name}"
          when "EncodeOverlay"
            if row[index]
              overlay.add_encoding_attribute(
                Odca::Overlays::EncodeOverlay::EncodingAttribute.new(
                  Odca::Overlays::EncodeOverlay::InputValidator.new(
                    attr_name: attr_name,
                    value: row[index]
                  ).call
                )
              )
            end
            overlay.description = "Character set encoding for #{schema_base.name}"
          when "EntryOverlay"
            if row[index]
              overlay.add_entry_attribute(
                Odca::Overlays::EntryOverlay::EntryAttribute.new(
                  Odca::Overlays::EntryOverlay::InputValidator.new(
                    attr_name: attr_name,
                    value: row[index]
                  ).call
                )
              )
            end
            overlay.description = "Field entries for #{schema_base.name}"
          when "InformationOverlay"
            if row[index]
              overlay.add_information_attribute(
                Odca::Overlays::InformationOverlay::InformationAttribute.new(
                  Odca::Overlays::InformationOverlay::InputValidator.new(
                    attr_name: attr_name,
                    value: row[index]
                  ).call
                )
              )
            end
            overlay.description = "Informational items for #{schema_base.name}"
          when "SourceOverlay"
            if row[index]
              overlay.add_source_attribute(
                Odca::Overlays::SourceOverlay::SourceAttribute.new(
                  Odca::Overlays::SourceOverlay::InputValidator.new(
                    attr_name: attr_name,
                    value: row[index]
                  ).call
                )
              )
            end
            overlay.description = "Source endpoints for #{schema_base.name}"
          when "ReviewOverlay"
            if row[index]
              overlay.add_review_attribute(
                Odca::Overlays::ReviewOverlay::ReviewAttribute.new(
                  Odca::Overlays::ReviewOverlay::InputValidator.new(
                    attr_name: attr_name,
                    value: row[index]
                  ).call
                )
              )
            end
            overlay.description = "Field entry review comments for #{schema_base.name}"
          else
            puts "Error uknown overlay: #{overlay}"
          end
        }
        # END Overlays


      end
    end

    def save(schema_base:, overlays:)
      path = "#{output_dir}/#{schema_base.name}"

      puts "Writing SchemaBase: #{schema_base.name}"
      save_schema_base(schema_base, path: path)

      overlays.each do |overlay|
        next if overlay.empty?
        puts "Processing #{overlay.description}"

        puts 'Saving object...'
        save_overlay(
          Odca::ParentfulOverlay.new(
            parent: schema_base, overlay: overlay
          ),
          path: path
        )
      end
    end

    def save_schema_base(schema_base, path:)
      unless Dir.exist?(path)
        puts 'Create dir'
        FileUtils.mkdir_p(path)
      end

      File.open("#{path}.json", 'w') do |f|
        f.write(JSON.pretty_generate(schema_base))
      end
    end

    def save_overlay(parentful_overlay, path:)
      overlay_class_name = parentful_overlay.overlay.class
        .name.split('::').last
      hl = 'hl:' + HashlinkGenerator.call(parentful_overlay)

      File.open("#{path}/#{overlay_class_name}-#{hl}.json", 'w') do |f|
        f.write(JSON.pretty_generate(parentful_overlay))
      end
    end

    def reset_overlays
      overlays = {}

      overlay_dtos.each do |overlay_dto|
        begin
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
          overlays[overlay_dto.index] = overlay
        rescue => e
          raise "Not found Overlay Class for '#{overlay_dto.name}': #{e}"
        end
      end

      overlays
    end

    class Overlay
      attr_reader :index, :name, :role, :purpose, :language

      def initialize(index:, name:, role:, purpose:, language:)
        @index = index
        @name = name
        @role = role
        @purpose = purpose
        @language = language
      end
    end
  end
end
