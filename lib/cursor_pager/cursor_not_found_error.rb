# frozen_string_literal: true

module CursorPager
  # Will be raised when the cursor's record couldn't be found in the relation.
  class CursorNotFoundError < Error

    attr_reader :cursor

    def initialize(cursor)
      @cursor = cursor
      message = "Couldn't find item for cursor: #{cursor}."

      super(message)
    end
  end
end
