# frozen_string_literal: true

module CursorPager
  # The main class that coordinates the whole pagination.
  class Page
    extend Forwardable

    attr_reader :relation, :first_value, :last_value, :after, :before,
      :order_values

    def_delegators :@configuration, :encoder, :default_page_size,
      :maximum_page_size

    def initialize(relation, first: nil, last: nil, after: nil, before: nil)
      @configuration = CursorPager.configuration
      @relation = relation
      @first_value = first
      @last_value = last
      @after = after
      @before = before
      @order_values = OrderValues.from_relation(relation)

      add_default_order
      verify_order_directions!
    end

    # A capped `first` value.
    # The underlying instance variable `first_value` doesn't have limits on it.
    # If neither `first` nor `last` is given, but `default_page_size` is
    # configured, `default_page_size` is used for first.
    def first
      @first ||= begin
                   capped = limit_pagination_argument(first_value)
                   capped = default_page_size if capped.nil? && last.nil?
                   capped
                 end
    end

    # A capped `last` value.
    # The underlying instance variable `last_value` doesn't have limits on it.
    def last
      @last ||= limit_pagination_argument(last_value)
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
      return if item.nil?

      encoder.encode(item.id.to_s)
    end

    def first_cursor
      cursor_for(records.first)
    end

    def last_cursor
      cursor_for(records.last)
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

    # Used to cap `first` and `last` arguments.
    # Returns `nil` if the argument is `nil`, otherwise a value between `0` and
    # `maximum_page_size`.
    def limit_pagination_argument(argument)
      return if argument.nil?

      if argument.negative?
        argument = 0
      elsif maximum_page_size && argument > maximum_page_size
        argument = maximum_page_size
      end

      argument
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
      @before_limit_value ||= before.present? && limit_value_for(before)
    end

    def after_limit_value
      @after_limit_value ||= after.present? && limit_value_for(after)
    end

    def limit_value_for(cursor)
      id = encoder.decode(cursor)

      selects = order_values.map(&:select_string)
      item = relation.where(id: id).select(selects).first

      raise CursorNotFoundError, cursor if item.blank?

      order_values.map { |value| item[value.select_alias] }
    end
  end
end
