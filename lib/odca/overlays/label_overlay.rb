require 'odca/null_value'

module Odca
  module Overlays
    class LabelOverlay
      attr_reader :attributes, :language, :category_resolver

      def initialize(language:, category_resolver: CategoryResolver.new)
        @attributes = []
        @language = language
        @category_resolver = category_resolver
      end

      def to_h
        resolved_categories = category_resolver.call(attributes)
        {
          language: language,
          attr_labels: attr_labels,
          attr_categories: resolved_categories.attr_categories,
          cat_labels: resolved_categories.category_labels,
          cat_attributes: resolved_categories.category_attributes
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

      class CategoryResolver
        attr_reader :attr_categories, :category_labels, :category_attributes

        def initialize
          @attr_categories = []
          @category_labels = {}
          @category_attributes = {}
        end

        def call(attributes)
          attributes.each do |attribute|
            next if attribute.categories.empty?
            categories = attribute.categories.dup
            category = categories.pop

            supercategory_numbers = []

            categories.each do |supercategory|
              supercategory_attr = find_or_create_category_attr(
                supercategory_numbers, supercategory
              )
              supercategory_numbers.push(
                supercategory_attr.delete('_').split('-').last
              )
              unless attr_categories.include? supercategory_attr
                attr_categories.push(supercategory_attr)
              end
              category_labels[supercategory_attr] = supercategory
            end

            category_attr = find_or_create_category_attr(
              supercategory_numbers, category
            )
            unless attr_categories.include? category_attr
              attr_categories.push(category_attr)
            end
            category_labels[category_attr] = category

            category_attributes[category_attr] = category_attributes
              .fetch(category_attr) { [] }.push(attribute.attr_name).uniq
          end
          self
        end

        private def find_or_create_category_attr(supercategory_numbers, category)
          nested_category_numbers =
            if supercategory_numbers.empty?
              '-'
            else
              "-#{supercategory_numbers.join('-')}-"
            end
          category_attr = category_labels.select do |key, value|
            value == category &&
              key.match("_cat#{nested_category_numbers}[0-9]*_")
          end
          if !category_attr.empty?
            category_attr.keys.first
          else
            subcategory_number = category_labels.select do |key, _v|
              key.match("_cat#{nested_category_numbers}[0-9]*_")
            end.size + 1
            "_cat#{nested_category_numbers}#{subcategory_number}_"
          end
        end
      end

      class LabelAttribute
        attr_reader :attr_name, :categories, :label

        def initialize(attr_name:, categories:, label:)
          @attr_name = attr_name
          @categories = categories
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
          splited = value.split('|').map(&:strip)

          label = splited.empty? ? Odca::NullValue.new : splited.pop
          categories = splited

          {
            attr_name: attr_name.strip,
            categories: categories,
            label: label
          }
        end
      end
    end
  end
end
