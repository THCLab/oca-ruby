require 'odca/null_value'

module Odca
  module Overlay
    def self.extended(overlay)
      overlay_class_name = overlay.name.split('::').last

      overlay.class_eval do
        attr_reader :attributes

        def _initialize
          @attributes = []
        end

        alias_method :initialize, :_initialize

        def empty?
          attributes.empty?
        end

        def add_attribute(attr)
          return if attr.nil? || attr.value.nil?
          attributes << attr
        end

        def attr_values
          attributes.each_with_object({}) do |attr, memo|
            memo[attr.attr_name] = attr.value
          end
        end

        overlay.const_set(
          overlay_class_name.gsub('Overlay', '') << 'Attribute',
          Class.new do
            attr_reader :attr_name, :value

            def initialize(attr_name:, value:)
              @attr_name = attr_name
              @value = value
            end
          end
        )

        overlay.const_set(
          'InputValidator',
          Class.new do
            attr_reader :attr_name, :value

            def initialize(attr_name:, value:)
              if attr_name.strip.empty?
                raise 'Attribute name is expected to be non empty String'
              end

              @attr_name = attr_name
              @value = value
            end

            define_method :call do
              {
                attr_name: attr_name.strip,
                value: validate(value)
              }
            end

            def validate(input_value)
              if input_value.nil? || input_value.strip.empty?
                Odca::NullValue.new
              else
                input_value.strip
              end
            end
          end
        )
      end
    end
  end
end
