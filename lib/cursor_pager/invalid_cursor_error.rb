# frozen_string_literal: true

module CursorPager
  # Will be raise when the cursor couldn't be parsed.
  class InvalidCursorError < Error
    def initialize(cursor)
      message = "Couldn't parse cursor: #{cursor}."

      super(message)
    end
  end
end
