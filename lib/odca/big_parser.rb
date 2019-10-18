require 'fileutils'
require 'odca/odca.rb'
require 'odca/hashlink_generator'
require 'odca/schema_parser'
require 'json'
require 'pp'

module Odca
  class BigParser
    attr_reader :records, :output_dir, :overlay_dtos

    def initialize(records, output_dir)
      @overlay_dtos = []
      @records = records
      @output_dir = output_dir
    end

    def call
      columns_number = records[0].size

      puts 'Reading overlays ...'
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

      puts 'Overlays loaded, start creating objects'
      rows_count = records.size
      schemas = []
      schema_name = ''
      schema_first_row = 0
      records.each_with_index do |row, i|
        if i.zero?
          schema_name = row[0]
          schema_first_row = i
        end
        next unless i + 1 == rows_count || schema_name != row[0]

        schemas << Odca::SchemaParser.new(
          records[schema_first_row..i - 1], overlay_dtos
        )
        schema_name = row[0]
        schema_first_row = i
      end

      schemas.each do |schema|
        schema_base, overlays = schema.call
        save(schema_base: schema_base, overlays: overlays)
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
