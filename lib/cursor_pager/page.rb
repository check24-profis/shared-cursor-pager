# frozen_string_literal: true

module CursorPager
  # The main class that coordinates the whole pagination.
  class Page
    attr_reader :relation, :first, :last, :after, :before, :order_values

    def initialize(relation, first: nil, last: nil, after: nil, before: nil)
      @relation = relation
      @first = first
      @last = last
      @after = after
      @before = before
      @order_values = OrderValues.from_relation(relation)

      add_default_order
      verify_order_directions!
    end

    def previous_page?
      @previous_page ||= if after_limit_value.present?
                           true
                         elsif last
                           limited_relation.offset_value.to_i.positive?
                         else
                           false
                         end
    end

    def next_page?
      @next_page ||= if before_limit_value.present?
                       true
                     elsif first
                       sliced_relation.limit(first + 1).count == first + 1
                     else
                       false
                     end
    end

    def cursor_for(item)
      Base64Encoder.encode(item.id.to_s)
    end

    def records
      @records ||= limited_relation.to_a
    end

    private

    def add_default_order
      return if sufficiently_ordered?

      direction = order_values.direction || :asc

      @order_values << OrderValue.new(relation, relation.primary_key, direction)
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
      @limited_relation ||= LimitRelation.new(sliced_relation, first, last).call
    end

    def sliced_relation
      @sliced_relation ||= SliceRelation.new(
        ordered_relation,
        order_values,
        after_limit_value,
        before_limit_value
      ).call
    end

    def ordered_relation
      @ordered_relation ||= relation.reorder(order_values.order_string)
    end

    def before_limit_value
      @before_limit_value ||= before && limit_value_for(before)
    end

    def after_limit_value
      @after_limit_value ||= after && limit_value_for(after)
    end

    def limit_value_for(cursor)
      id = Base64Encoder.decode(cursor)

      return if id.blank?

      selects = order_values.map(&:select_string)
      item = relation.where(id: id).select(selects).first

      raise CursorNotFoundError, cursor if item.blank?

      order_values.map { |value| item[value.select_alias] }
    end
  end
end
