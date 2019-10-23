require 'odca/null_value'

module Odca
  module Overlays
    class ReviewOverlay
      attr_reader :review_attributes, :language

      def initialize(language:)
        @review_attributes = []
        @language = language
      end

      def to_h
        {
          language: language,
          attr_comments: attr_comments
        }
      end

      def empty?
        review_attributes.empty?
      end

      def add_attribute(review_attribute)
        return if review_attribute.nil? || review_attribute.comment.nil?
        review_attributes << review_attribute
      end

      private def attr_comments
        review_attributes.each_with_object({}) do |attr, memo|
          memo[attr.attr_name] = attr.comment
        end
      end

      class ReviewAttribute
        attr_reader :attr_name, :comment

        def initialize(attr_name:, comment:)
          @attr_name = attr_name
          @comment = comment
        end
      end

      class InputValidator
        attr_reader :attr_name, :value

        def initialize(attr_name:, value:)
          if attr_name.strip.empty?
            raise 'Attribute name is expected to be non empty String'
          end

          @attr_name = attr_name
          @value = value
        end

        def call
          comment = if value.nil? || value.strip.empty?
                      Odca::NullValue.new
                    else
                      ''
                    end

          {
            attr_name: attr_name.strip,
            comment: comment
          }
        end
      end
    end
  end
end
