require 'odca/overlays/header'
require 'odca/null_value'

module Odca
  module Overlays
    class EntryOverlay
      extend Forwardable
      attr_accessor :language
      attr_reader :entry_attributes, :header

      def_delegators :header,
        :issued_by, :type,
        :schema_base_id, :schema_base_id=,
        :role, :role=, :purpose, :purpose=,
        :description, :description=, :name, :name=

      def initialize(schema_base_id = '', issued_by = '')
        @entry_attributes = []
        @header = Header.new(
          schema_base_id: schema_base_id,
          type: 'spec/overlay/entry/1.0',
          issued_by: issued_by
        )
      end

      def to_json(options = {})
        to_h.to_json(*options)
      end

      def to_h
        header.to_h.merge(
          language: language,
          attr_entries: attr_entries
        )
      end

      # @deprecated
      def is_valid?
        warn('[DEPRECATION] `is_valid?` is deprecated. ' \
             'Please use `empty?` instead.')
        !empty?
      end

      def empty?
        entry_attributes.empty?
      end

      def add_entry_attribute(entry_attribute)
        return if entry_attribute.nil? || entry_attribute.entries.empty?
        entry_attributes << entry_attribute
      end

      private def attr_entries
        entry_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.entries
        end
      end

      class EntryAttribute
        attr_reader :attr_name, :entries

        def initialize(attr_name:, entries:)
          @attr_name = attr_name
          @entries = entries
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
          entries = if value.nil? || value.strip.empty?
                      Odca::NullValue.new
                    else
                      value.split('|').map(&:strip)
                    end

          {
            attr_name: attr_name.strip,
            entries: entries
          }
        end
      end
    end
  end
end
