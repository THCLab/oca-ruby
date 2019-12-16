require 'forwardable'
require 'odca/hashlink_generator'

module Odca
  class ParentfulOverlay
    extend Forwardable
    attr_reader :parent, :overlay

    def_delegator :overlay, :empty?

    def initialize(parent:, overlay:)
      @parent = parent
      @overlay = overlay
    end

    def to_json(options = {})
      to_h.to_json(*options)
    end

    def to_h
      { schema_base: parent_id }.merge(
        overlay.to_h
      )
    end

    private def parent_id
      "hl:#{HashlinkGenerator.call(parent)}"
    end
  end
end
