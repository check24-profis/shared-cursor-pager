# frozen_string_literal: true

module CursorPager
  # Default encoder used to encode & decode cursors.
  class Base64Encoder
    class << self
      def encode(data)
        Base64.urlsafe_encode64(data)
      end

      def decode(data)
        Base64.urlsafe_decode64(data)
      rescue ArgumentError
        raise InvalidCursorError, data
      end
    end
  end
end
