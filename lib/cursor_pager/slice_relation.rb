# frozen_string_literal: true

module CursorPager
  # Applies after and before cursors to a relation.
  class SliceRelation
    attr_reader :base_relation, :order_values, :after, :before

    def initialize(base_relation, order_values, after, before)
      @base_relation = base_relation
      @order_values = order_values
      @after = after
      @before = before
    end

    def call
      relation = base_relation

      relation = apply_after(relation)
      relation = apply_before(relation)

      relation
    end

    private

    def apply_after(relation)
      return relation if after.blank?

      if order_values.direction == :asc
        slice_relation(relation, ">", after)
      else
        slice_relation(relation, "<", after)
      end
    end

    def apply_before(relation)
      return relation if before.blank?

      if order_values.direction == :asc
        slice_relation(relation, "<", before)
      else
        slice_relation(relation, ">", before)
      end
    end

    def slice_relation(relation, operator, value)
      slice_attribute = order_values.map(&:prefixed_attribute).join(", ")

      relation.where("(#{slice_attribute}) #{operator} (?)", value)
    end
  end
end
