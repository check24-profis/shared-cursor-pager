# frozen_string_literal: true

module CursorPager
  class CursorNotFoundError < Error
    def initialize(cursor)
      message = "Couldn't find item for cursor #{cursor}."

      super(message)
    end
  end
end
