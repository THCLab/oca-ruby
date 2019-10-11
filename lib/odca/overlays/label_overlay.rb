require 'odca/overlays/header'
require 'odca/null_label_value'

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
        attr_reader :name, :value

        def initialize(name:, value:)
          @name = name
          @value = value
        end

        def category
          @category ||= splited_value[0]
        end

        def label
          @label ||= splited_value[1]
        end

        private def splited_value
          result = value.split('|')
          case result.length
          when 1
            result.unshift('').map(&:strip)
          when 2
            result.map(&:strip)
          else
            Odca::NullLabelValue.new
          end
        end
      end
    end
  end
end
