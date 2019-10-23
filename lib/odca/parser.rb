require 'fileutils'
require 'odca/hashlink_generator'
require 'odca/schema_parser'
require 'json'
require 'pp'

module Odca
  class Parser
    attr_reader :records, :output_dir, :overlay_dtos

    def initialize(records, output_dir)
      @overlay_dtos = []
      @records = records
      @output_dir = output_dir
    end

    def call
      columns_number = records[0].size

      (6..columns_number - 1).each do |i|
        overlay_dtos << OverlayDto.new(
          index: i,
          name: records[2][i],
          role: records[0][i],
          purpose: records[1][i],
          language: records[3][i]
        )
      end
      records.slice!(0, 4)

      schemas = separate_schemas(records)
      schemas.each do |schema|
        schema_base, overlays = schema.call
        save(schema_base: schema_base, overlays: overlays)
      end
    end

    private def separate_schemas(records)
      schema_name = ''
      schema_first_row = 0
      records.each_with_object([]).with_index do |(row, memo), i|
        schema_name = row[0] if i.zero?
        next_record = records[i + 1]
        next if next_record && schema_name == next_record[0]
        memo << Odca::SchemaParser.new(
          records[schema_first_row..i], overlay_dtos
        )
        schema_name = next_record[0] if next_record
        schema_first_row = i + 1
      end
    end

    def save(schema_base:, overlays:)
      path = "#{output_dir}/#{schema_base.name}"

      save_schema_base(schema_base, path: path)

      overlays.each do |overlay|
        next if overlay.empty?
        save_overlay(overlay, path: path)
      end
    end

    def save_schema_base(schema_base, path:)
      FileUtils.mkdir_p(path) unless Dir.exist?(path)

      File.open("#{path}.json", 'w') do |f|
        f.write(JSON.pretty_generate(schema_base))
      end
    end

    def save_overlay(headful_overlay, path:)
      overlay_class_name = headful_overlay.overlay.class
        .name.split('::').last
      hl = 'hl:' + HashlinkGenerator.call(headful_overlay)

      File.open("#{path}/#{overlay_class_name}-#{hl}.json", 'w') do |f|
        f.write(JSON.pretty_generate(headful_overlay))
      end
    end

    class OverlayDto
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
