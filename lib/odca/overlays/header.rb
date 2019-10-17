module Odca
  module Overlays
    class Header
      attr_accessor :schema_base_id, :description, :type
      attr_reader :issued_by, :role, :purpose

      def initialize(role:, purpose:, schema_base_id: '', issued_by: '')
        @schema_base_id = schema_base_id
        @issued_by = issued_by
        @role = role
        @purpose = purpose
      end

      def to_h
        {
          '@context' => 'https://odca.tech/overlays/v1',
          schema_base: schema_base_id,
          type: type,
          description: description,
          issued_by: issued_by,
          role: role || '',
          purpose: purpose || ''
        }
      end
    end
  end
end
