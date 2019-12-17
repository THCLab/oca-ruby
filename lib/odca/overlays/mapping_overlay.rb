require 'odca/overlay'

module Odca
  module Overlays
    class MappingOverlay
      extend Overlay

      def to_h
        {
          attr_mapping: attr_values
        }
      end
    end
  end
end
