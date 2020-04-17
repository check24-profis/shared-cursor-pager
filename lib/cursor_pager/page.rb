# frozen_string_literal: true

module CursorPager
  class CursorNotFoundError < StandardError
    def initialize(cursor)
      message = "Couldn't find item for cursor #{cursor}."

      super(message)
    end
  end

  class ConflictingOrdersError < StandardError
    MESSAGE = <<~MESSAGE
      Ordering by multiple attributes requires they are all ordered in the
      same direction.
    MESSAGE

    def initialize
      super(MESSAGE)
    end
  end

  class Page
    attr_reader :relation, :first, :last, :after, :before, :order_values

    def initialize(relation, first: nil, last: nil, after: nil, before: nil)
      @relation = relation
      @first = first
      @last = last
      @after = after
      @before = before
      @order_values = OrderValue.from_relation(relation)

      add_default_order
      verify_order_directions!
    end

    def previous_page?
      false
    end

    def next_page?
      false
    end

    def cursor_for(item)
      Base64.strict_encode64(item.id.to_s)
    end

    def records
      @records ||= limited_relation.to_a
    end

    private

    def add_default_order
      return if sufficiently_ordered?

      @order_values << OrderValue.default_for(relation, order_direction)
    end

    def sufficiently_ordered?
      order_values.present? && order_values.all? do |value|
        value.primary_key? || value.type == :datetime
      end
    end

    def verify_order_directions!
      return if order_values.map(&:direction).uniq.size == 1

      raise ConflictingOrdersError
    end

    def limited_relation
      return @limited_relation if defined? @limited_relation

      paginated_relation = sliced_relation
      previous_limit = paginated_relation.limit_value

      if first && (previous_limit.nil? || previous_limit > first)
        # `first` would create a stricter limit that the one already applied, so add it
        paginated_relation = paginated_relation.limit(first)
      end

      if last
        if (lv = paginated_relation.limit_value)
          if last <= lv
            # `last` is a smaller slice than the current limit, so apply it
            offset = (paginated_relation.offset_value || 0) + (lv - last)
            paginated_relation = paginated_relation.offset(offset)
            paginated_relation = paginated_relation.limit(last)
          end
        else
          # No limit, so get the last items
          sliced_relation_count = @sliced_relation.count
          offset = (paginated_relation.offset_value || 0) + sliced_relation_count - [last, sliced_relation_count].min
          paginated_relation = paginated_relation.offset(offset)
          paginated_relation = paginated_relation.limit(last)
        end
      end

      @paged_nodes_offset = paginated_relation.offset_value
      @limited_relation = paginated_relation
    end

    def sliced_relation
      return @sliced_relation if defined? @sliced_relation

      paginated_relation = relation

      paginated_relation = apply_order_values(paginated_relation)
      paginated_relation = apply_after(paginated_relation)
      paginated_relation = apply_before(paginated_relation)

      @sliced_relation = paginated_relation
    end

    def apply_order_values(paginated_relation)
      order = order_values.map(&:order_string).join(", ")

      paginated_relation.reorder(order)
    end

    def apply_after(paginated_relation)
      after_limit_value = after && limit_value_for(after)

      return paginated_relation if after_limit_value.blank?

      if order_direction == :asc
        slice_relation(paginated_relation, ">", after_limit_value)
      else
        slice_relation(paginated_relation, "<", after_limit_value)
      end
    end

    def apply_before(paginated_relation)
      before_limit_value = before && limit_value_for(before)

      return paginated_relation if before_limit_value.blank?

      if order_direction == :asc
        slice_relation(paginated_relation, "<", before_limit_value)
      else
        slice_relation(paginated_relation, ">", before_limit_value)
      end
    end

    def limit_value_for(cursor)
      id = decode(cursor)

      return if id.blank?

      selects = order_values.map(&:select_string)
      item = relation.where(id: id).select(selects).first

      raise CursorNotFoundError, cursor if item.blank?

      order_values.map { |value| item[value.select_alias] }
    end

    def decode(str)
      Base64.strict_decode64(str)
    end

    def order_direction
      order_values.first&.direction
    end

    def slice_relation(paginated_relation, operator, value)
      slice_attribute = order_values.map(&:prefixed_attribute).join(", ")

      paginated_relation.where("(#{slice_attribute}) #{operator} (?)", value)
    end
  end
end
