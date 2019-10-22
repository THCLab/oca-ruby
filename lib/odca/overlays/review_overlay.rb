require 'odca/overlay'
require 'odca/null_value'

module Odca
  module Overlays
    class ReviewOverlay
      extend Overlay
      attr_reader :language

      def initialize(language:)
        _initialize
        @language = language
      end

      def to_h
        {
          language: language,
          attr_comments: attr_values
        }
      end

      class InputValidator
        def validate(value)
          if value.nil? || value.strip.empty?
            Odca::NullValue.new
          else
            ''
          end
        end
      end
    end
  end
end
