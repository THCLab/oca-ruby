require 'odca/overlays/header'
require 'odca/null_value'

module Odca
  module Overlays
    class LabelOverlay
      extend Forwardable
      attr_accessor :language
      attr_reader :label_attributes, :header

      def_delegators :header,
        :issued_by, :type,
        :schema_base_id, :schema_base_id=,
        :role, :role=, :purpose, :purpose=,
        :description, :description=, :name, :name=

      def initialize(schema_base_id = '', issued_by = '')
        @label_attributes = []
        @header = Header.new(
          schema_base_id: schema_base_id,
          type: 'spec/overlay/label/1.0',
          issued_by: issued_by
        )
      end

      def to_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          language: language,
          attr_labels: attr_labels,
          attr_categories: attr_categories,
          category_labels: category_labels
        )
      end

      # @deprecated
      def is_valid?
        # no way to be invalid with implementation assured by tests
        true
      end

      def add_label_attribute(label_attribute)
        return if label_attribute.nil? || label_attribute.name.strip.empty?
        label_attributes << label_attribute
      end

      private def attr_labels
        label_attributes.each_with_object({}) do |attr, memo|
          memo[attr.name] = attr.label
        end
      end

      private def attr_categories
        label_attributes.map(&:category).uniq.map do |cat|
          next if cat.empty?
          cat.downcase.gsub(/\s+/, '_').to_sym
        end.compact
      end

      private def category_labels
        label_attributes.map(&:category).uniq
          .each_with_object({}) do |cat, memo|
            next if cat.empty?
            memo[cat.downcase.gsub(/\s+/, '_').to_sym] = cat
          end
      end

      class LabelAttribute
        attr_reader :name, :category, :label

        def initialize(name:, category:, label:)
          @name = name
          @category = category
          @label = label
        end
      end

      class InputValidator
        attr_reader :attr_name, :value

        def initialize(attr_name:, value:)
          if attr_name.strip.empty?
            raise 'Attribute name is expected to be non empty String'
          end

          @attr_name = attr_name
          @value = value
        end

        def call
          category = Odca::NullValue.new
          label = Odca::NullValue.new

          splited = value.split('|')
          case splited.length
          when 1
            label = value.strip
          when 2
            category = splited[0].strip
            label = splited[1].strip
          end

          {
            name: attr_name.strip,
            category: category,
            label: label
          }
        end
      end
    end
  end
end
