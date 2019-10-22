require 'odca/overlay'

module Odca
  module Overlays
    class FormatOverlay
      extend Overlay

      def to_h
        {
          attr_formats: attr_formats
        }
      end
    end
  end
end
