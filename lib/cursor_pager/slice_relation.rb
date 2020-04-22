# frozen_string_literal: true

module CursorPager
  # Applies after and before cursors to a relation.
  class SliceRelation
    attr_reader :base_relation, :order_values, :after_values, :before_values

    def initialize(base_relation, order_values, after_values, before_values)
      @base_relation = base_relation
      @order_values = order_values
      @after_values = after_values
      @before_values = before_values
    end

    def call
      relation = base_relation

      relation = apply_after(relation)
      relation = apply_before(relation)

      relation
    end

    private

    def apply_after(relation)
      return relation if after_values.blank?

      if order_values.direction == :asc
        slice_relation(relation, ">", after_values)
      else
        slice_relation(relation, "<", after_values)
      end
    end

    def apply_before(relation)
      return relation if before_values.blank?

      if order_values.direction == :asc
        slice_relation(relation, "<", before_values)
      else
        slice_relation(relation, ">", before_values)
      end
    end

    def slice_relation(relation, operator, value)
      slice_attribute = order_values.map(&:prefixed_attribute).join(", ")

      relation.where("(#{slice_attribute}) #{operator} (?)", value)
    end
  end
end
