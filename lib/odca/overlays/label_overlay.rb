require 'odca/null_value'

module Odca
  module Overlays
    class LabelOverlay
      attr_reader :attributes, :language

      def initialize(language:)
        @attributes = []
        @language = language
      end

      def to_h
        {
          language: language,
          attr_labels: attr_labels,
          attr_categories: attr_categories,
          category_labels: category_labels,
          category_attributes: category_attributes
        }
      end

      def empty?
        attributes.empty?
      end

      def add_attribute(attribute)
        return if attribute.nil? || attribute.attr_name.strip.empty?
        attributes << attribute
      end

      private def attr_labels
        attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.label
        end
      end

      private def attr_categories
        attributes.map(&:category).uniq.map do |cat|
          next if cat.empty?
          cat.downcase.gsub(/\s+/, '_').to_sym
        end.compact
      end

      private def category_labels
        attributes.map(&:category).uniq
          .each_with_object({}) do |cat, memo|
            next if cat.empty?
            memo[cat.downcase.gsub(/\s+/, '_').to_sym] = cat
          end
      end

      private def category_attributes
        attributes.each_with_object({}) do |attr, memo|
          next if attr.category.empty?
          category_attr = attr.category.downcase.gsub(/\s+/, '_').to_sym
          (memo[category_attr] ||= []) << attr.attr_name
        end
      end

      class LabelAttribute
        attr_reader :attr_name, :category, :label

        def initialize(attr_name:, category:, label:)
          @attr_name = attr_name
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
            attr_name: attr_name.strip,
            category: category,
            label: label
          }
        end
      end
    end
  end
end
