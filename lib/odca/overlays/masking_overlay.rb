require 'odca/overlay'

module Odca
  module Overlays
    class MaskingOverlay
      extend Overlay

      def to_h
        {
          attr_masks: attr_values
        }
      end
    end
  end
end
