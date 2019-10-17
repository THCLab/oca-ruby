require 'csv'
require 'fileutils'
require 'odca/odca.rb'
require 'odca/hashlink_generator'
require 'json'
require 'pp'

module Odca
  class BigParser
    attr_reader :records

    def initialize(filename)
      @records = CSV.read(filename, col_sep: ';')
    end

    def call
      schema_base = SchemaBase.new

      attrs = {}
      pii = []
      labels = {}
      categories = []
      category_labels = {}
      encoding = {}
      entries = {}
      information = {}
      hidden_attributes = {}
      required_attributes = {}
      sources = {}
      review = {}
      overlays = {}

      columns_number = records[0].size

      puts 'Reading overlays ...'
      (6..columns_number - 1).each do |i|
        overlay_name = records[2][i]
        begin
          overlay_clazz = Odca::Overlays.const_get(
            overlay_name.delete(' ')
          )
          overlay = overlay_clazz.new(
            Odca::Overlays::Header.new(
              role: records[0][i],
              purpose: records[1][i]
            )
          )
          overlay.language = records[3][i] if defined? overlay.language
          overlays[i] = overlay
          puts "Overlay loaded: #{overlay_clazz}"
        rescue => e
          raise "Not found Overlay Class for '#{overlay_name}': #{e}"
        end
      end

      # Drop header before start filling the object
      records.slice!(0, 4)
      puts "Overlays loaded, start creating objects"
      rows_count = records.size
      records.each_with_index do |row, i|
        # Save it only if schema base change which means that we parsed all attributes for
        # previous schema base or end of rows
        if (schema_base.name != row[0] and schema_base.name != nil) or (i+1 == rows_count)
          objects = [schema_base]

          objects << overlays.values

          objects.flatten.each { |obj|
            puts "Writing #{obj.class.name}"
            if obj.class.name.split('::').last == "SchemaBase"
              puts "SchemaBase: #{obj.name}"
              puts "Create dir"
              unless Dir.exist?("output/"+obj.name)
                FileUtils.mkdir_p("output/"+obj.name)
              end
              File.open("output/#{obj.name}.json","w") do |f|
                f.write(JSON.pretty_generate(obj))
              end
            else
              puts "Processing #{obj.description}"
              obj = Odca::ParentfulOverlay.new(
                parent: schema_base,
                overlay: obj
              )

              if obj.is_valid?
                puts "Object is valid saving ..."
                hl = 'hl:' + HashlinkGenerator.call(obj)
                File.open("output/#{schema_base.name}/#{obj.overlay.class.name.split('::').last}-#{hl}.json","w") do |f|
                  f.write(JSON.pretty_generate(obj))
                end
              else
                puts "Object is invalid"
              end
            end
          }

          # Reset base object, overlays and temporary attributes
          schema_base = SchemaBase.new
          overlays.each { |index, overlay|
            new_overlay = overlay.class.new(
              Odca::Overlays::Header.new(
                role: overlay.role,
                purpose: overlay.purpose
              )
            )
            new_overlay.language = overlay.language if defined? overlay.language
            overlays[index] = new_overlay
          }

          attrs = {}
          pii = []
          labels = {}
          categories = []
          category_labels = {}
          encoding = {}
          entries = {}
          information = {}
          hidden_attributes = {}
          required_attributes = {}
          sources = {}
          review = {}

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
  end
end
