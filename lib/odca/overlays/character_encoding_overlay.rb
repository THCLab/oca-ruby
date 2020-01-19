require 'odca/overlay'
require 'odca/null_value'

module Odca
  module Overlays
    class CharacterEncodingOverlay
      extend Overlay

      DEFAULT_ENCODING = 'utf-8'.freeze

      def to_h
        {
          default_character_encoding: DEFAULT_ENCODING,
          attr_character_encoding: attr_values
        }
      end
    end
  end
end
