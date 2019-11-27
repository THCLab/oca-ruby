require 'yaml'
require 'forwardable'
require 'odca/overlays/header'

module Odca
  class HeadfulOverlay
    extend Forwardable
    attr_reader :parentful_overlay, :role, :purpose

    OVERLAYS_INFO = 'config/overlays_info.yml'.freeze

    def_delegators :parentful_overlay, :overlay, :empty?

    def initialize(parentful_overlay:, role:, purpose:)
      @parentful_overlay = parentful_overlay
      @role = role
      @purpose = purpose
      @overlays_info = overlays_info
    end

    def to_json(options = {})
      to_h.to_json(*options)
    end

    def to_h
      header.to_h
        .merge(parentful_overlay.to_h)
    end

    def header
      @header ||=
        Odca::Overlays::Header.new(
          role: role,
          purpose: purpose,
          type: overlay_info['type_v1']
        )
    end

    def overlays_info
      @overlays_info ||= YAML.safe_load(
        File.open(File.join(Odca::ROOT_PATH, OVERLAYS_INFO))
      )
    end

    def overlay_info
      overlay_class_name = overlay.class.name.split('::').last
      overlay_key = overlay_class_name.gsub('Overlay', '').downcase
      overlays_info.fetch(overlay_key) do
        raise "Not found specific information about #{overlay_class_name}"
      end
    end
  end
end
