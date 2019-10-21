module Odca
  module Overlays
    class Header
      attr_reader :issued_by, :role, :purpose, :description, :type

      def initialize(role:, purpose:, description:, type:, issued_by: '')
        @issued_by = issued_by
        @role = role
        @purpose = purpose
        @description = description
        @type = type
      end

      def to_h
        {
          '@context' => 'https://odca.tech/overlays/v1',
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
