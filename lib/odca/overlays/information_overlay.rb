require 'odca/overlay'

module Odca
  module Overlays
    class InformationOverlay
      extend Overlay
      attr_reader :language

      def initialize(language:)
        _initialize
        @language = language
      end

      def to_h
        {
          language: language,
          attr_information: attr_values
        }
      end
    end
  end
end
