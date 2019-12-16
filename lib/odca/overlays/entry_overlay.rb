require 'odca/overlay'
require 'odca/null_value'

module Odca
  module Overlays
    class EntryOverlay
      extend Overlay
      attr_reader :language

      def initialize(language:)
        _initialize
        @language = language
      end

      def to_h
        {
          language: language,
          attr_entries: attr_values
        }
      end

      class InputValidator
        def validate(value)
          if value.nil? || value.strip.empty?
            Odca::NullValue.new
          else
            value.split('|').map(&:strip)
          end
        end
      end
    end
  end
end
