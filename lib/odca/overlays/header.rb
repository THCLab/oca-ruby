module Odca
  module Overlays
    class Header
      attr_accessor :name, :schema_base_id, :description, :role, :purpose
      attr_reader :type, :issued_by

      def initialize(schema_base_id:, type:, issued_by:)
        @schema_base_id = schema_base_id
        @type = type
        @issued_by = issued_by
      end

      def to_h
        {
          '@context' => 'https://odca.tech/overlays/v1',
          schema_base: schema_base_id,
          type: type,
          description: description,
          issued_by: issued_by || '',
          role: role || '',
          purpose: purpose || ''
        }
      end
    end
  end
end
