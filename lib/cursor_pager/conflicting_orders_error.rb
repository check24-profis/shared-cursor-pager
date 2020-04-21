# frozen_string_literal: true

module CursorPager
  class ConflictingOrdersError < Error
    MESSAGE = <<~MESSAGE
      Ordering by multiple attributes requires they are all ordered in the
      same direction.
    MESSAGE

    def initialize
      super(MESSAGE)
    end
  end
end
