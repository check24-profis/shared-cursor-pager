# frozen_string_literal: true

module CursorPager
  # Will be raised when the relation is ordered by multiple attributes but in
  # different directions.
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
