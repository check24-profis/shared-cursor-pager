# frozen_string_literal: true

module CursorPager
  # Applies first and last limits to a relation.
  class LimitRelation
    attr_reader :base_relation, :first, :last

    def initialize(base_relation, first, last)
      @base_relation = base_relation
      @first = first
      @last = last
    end

    def call
      relation = base_relation

      relation = apply_first(relation) if first.present?
      relation = apply_last(relation) if last.present?

      relation
    end

    private

    # Apply first if it sets a stricter limit than the one already applied
    def apply_first(relation)
      previous_limit = relation.limit_value

      if previous_limit.nil? || previous_limit > first
        relation.limit(first)
      else
        relation
      end
    end

    # Apply last if it's a smaller slice than the previous limit
    def apply_last(relation)
      previous_limit = relation.limit_value

      if previous_limit.present?
        if last <= previous_limit
          relation = apply_stricter_last(relation, previous_limit)
        end
      else
        relation = apply_last_withouth_previous_limit(relation)
      end

      relation
    end

    def apply_stricter_last(relation, previous_limit)
      offset = (relation.offset_value || 0) + (previous_limit - last)

      relation.offset(offset).limit(last)
    end

    def apply_last_withouth_previous_limit(relation)
      count = base_relation.size
      previous_offset = relation.offset_value || 0
      offset = previous_offset + count - [last, count].min

      relation.offset(offset).limit(last)
    end
  end
end
