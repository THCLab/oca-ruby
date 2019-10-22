require 'odca/null_value'

module Odca
  module Overlay
    def self.extended(overlay)
      overlay_class_name = overlay.name.split('::').last
      overlay_name = overlay_class_name.gsub('Overlay', '').downcase

      overlay.class_eval do
        attr_reader "#{overlay_name}_attributes"

        define_method :_initialize do
          instance_variable_set(
            "@#{overlay_name}_attributes", []
          )
        end

        alias_method :initialize, :_initialize

        define_method :empty? do
          instance_variable_get(
            "@#{overlay_name}_attributes"
          ).empty?
        end

        define_method :add_attribute do |attr|
          return if attr.nil? || attr.__send__(overlay_name).empty?
          instance_variable_get(
            "@#{overlay_name}_attributes"
          ) << attr
        end

        define_method "attr_#{overlay_name}s" do
          instance_variable_get(
            "@#{overlay_name}_attributes"
          ).each_with_object({}) do |attr, memo|
            memo[attr.attr_name] = attr.__send__(overlay_name)
          end
        end

        overlay.const_set(
          overlay_class_name.gsub('Overlay', 'Attribute'),
          Class.new do
            attr_reader :attr_name, overlay_name

            define_method :initialize do |args|
              @attr_name = args.fetch(:attr_name)
              instance_variable_set(
                "@#{overlay_name}", args.fetch(overlay_name.to_sym)
              )
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
                overlay_name.to_sym => validate(value)
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
