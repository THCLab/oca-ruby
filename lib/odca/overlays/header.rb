module Odca
  module Overlays
    class Header
      attr_reader :issued_by, :role, :purpose, :type

      def initialize(role:, purpose:, type:, issued_by: '')
        @issued_by = issued_by
        @role = role
        @purpose = purpose
        @type = type
      end

      def to_h
        {
          '@context' => 'https://odca.tech/overlays/v1',
          type: type,
          issued_by: issued_by,
          role: role || '',
          purpose: purpose || ''
        }
      end
    end
  end
end
