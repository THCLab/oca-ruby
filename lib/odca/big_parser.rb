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

      puts "Reading overlays ..."
      columns_number.times { |i|
        overlayName = records[2][i]
        begin
          overlayClazz = Object.const_get(
            "Odca::Overlays::#{overlayName.gsub(' ', '')}"
          )
          overlay = overlayClazz.new
          overlay.role = records[0][i]
          overlay.purpose = records[1][i]
          overlay.language = records[3][i] if defined? overlay.language
          overlays[i] = overlay
          puts "Overlay loaded: #{overlayClazz}"
        rescue => e
          puts "Warrning: problem reading #{overlayName}, probably not overlay: #{e}"
        end
      }

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

          # Calculate hl for schema_base
          base_hl = 'hl:' + HashlinkGenerator.call(schema_base)
          objects.flatten.each { |obj|
            puts "Writing #{obj.class.name}: #{obj.name}"
            if obj.class.name.split('::').last == "SchemaBase"
              puts "Create dir"
              unless Dir.exist?("output/"+obj.name)
                FileUtils.mkdir_p("output/"+obj.name)
              end
              File.open("output/#{obj.name}.json","w") do |f|
                f.write(JSON.pretty_generate(obj))
              end
            else
              puts "Processing #{obj.description}"
              obj.schema_base_id = base_hl
              if obj.is_valid?
                puts "Object is valid saving ..."
                hl = 'hl:' + HashlinkGenerator.call(obj)
                File.open("output/#{schema_base.name}/#{obj.class.name.split('::').last}-#{hl}.json","w") do |f|
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
            newOverlay = overlay.class.new
            newOverlay.role = overlay.role
            newOverlay.purpose = overlay.purpose
            newOverlay.language = overlay.language if defined? overlay.language
            overlays[index] = newOverlay

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
            overlay.add_format(
              Odca::Overlays::FormatOverlay::Format.new(
                attr_name, row[index]
              )
            )
            overlay.description = "Attribute formats for #{schema_base.name}"
          when "LabelOverlay"
            if row[index]
              labels[index] = {} if labels[index] == nil
              labels[index][attr_name] = row[index].split("|")[-1].strip if row[index]
              # TODO support for nested categories
              tmp = row[index].split("|")[0..-2]
              categories[index] = [] if categories[index] == nil
              categories[index] << tmp
              tmp.each do |c|
                h = c.strip.downcase.gsub(/\s+/, "_").to_sym
                category_labels[index] = {} if category_labels[index] == nil
                category_labels[index][h] = c
              end
            end
            overlay.description = "Category and attribute labels for #{schema_base.name}"
            overlay.attr_labels = labels[index]
            overlay.attr_categories = categories[index]&.flatten&.uniq&.map { |i|
              i.strip.downcase.gsub(/\s+/, "_").to_sym
            }
            overlay.category_labels = category_labels[index]
          when "EncodeOverlay"
            encoding[index] = {} if encoding[index] == nil
            unless row[index].to_s.strip.empty?
              encoding[index][attr_name] = row[index]
            end
            overlay.description = "Character set encoding for #{schema_base.name}"
            overlay.attr_encoding = encoding[index]
          when "EntryOverlay"
            entries[index] = {} if entries[index] == nil
            unless row[index].to_s.strip.empty?
              value = row[index].to_s.strip
              values = value.split("|")
              entries[index][attr_name] = values
            end
            overlay.description = "Field entries for #{schema_base.name}"
            overlay.attr_entries = entries[index]
          when "InformationOverlay"
            information[index] = {} if information[index] == nil
            unless row[index].to_s.strip.empty?
              information[index][attr_name] = row[index]
            end
            overlay.description = "Informational items for #{schema_base.name}"
            overlay.attr_information = information[index]
          when "SourceOverlay"
            sources[index] = {} if sources[index] == nil
            unless row[index].to_s.strip.empty?
              sources[index][attr_name] = ""
            end
            overlay.description = "Source endpoints for #{schema_base.name}"
            overlay.attr_sources = sources[index]
          when "ReviewOverlay"
            review[index] = {} if review[index] == nil
            unless row[index].to_s.strip.empty?
              review[index][attr_name] = ""
            end
            overlay.description = "Field entry review comments for #{schema_base.name}"
            overlay.attr_comments = review[index]
          else
            puts "Error uknown overlay: #{overlay}"
          end
        }
        # END Overlays


      end
    end
  end
end
