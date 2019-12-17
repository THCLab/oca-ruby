require 'odca/overlay'
require 'odca/null_value'

module Odca
  module Overlays
    class SourceOverlay
      extend Overlay

      def to_h
        {
          attr_sources: attr_values
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
