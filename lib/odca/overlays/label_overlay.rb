require 'odca/overlays/header'
require 'odca/null_value'

module Odca
  module Overlays
    class LabelOverlay
      extend Forwardable
      attr_accessor :language
      attr_reader :label_attributes, :header

      def_delegators :header,
        :issued_by, :type, :role, :purpose, :description

      def initialize(header)
        @label_attributes = []
        header.type = 'spec/overlay/label/1.0'
        header.description = 'Category and attribute labels for '
        @header = header
      end

      def to_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          language: language,
          attr_labels: attr_labels,
          attr_categories: attr_categories,
          category_labels: category_labels,
          category_attributes: category_attributes
        )
      end

      def empty?
        label_attributes.empty?
      end

      def add_attribute(label_attribute)
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

      private def category_attributes
        label_attributes.each_with_object({}) do |attr, memo|
          next if attr.category.empty?
          category_attr = attr.category.downcase.gsub(/\s+/, '_').to_sym
          (memo[category_attr] ||= []) << attr.name
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
