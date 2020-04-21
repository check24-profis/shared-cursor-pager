# frozen_string_literal: true

module CursorPager
  class OrderValue
    PARENTHESIS_REGEX = /[\(\)]/.freeze

    attr_reader :attribute, :direction

    class << self
      # A relation's order_values can either be an empty array, an array
      # including just one string, or an array of arel ordering nodes.
      def from_relation(relation)
        relation.order_values.uniq.reject(&:blank?).flat_map do |value|
          case value
          when Arel::Nodes::Ordering
            new(relation, value.value.name, value.direction)
          when String
            from_order_string(relation, value)
          end
        end
      end

      def default_for(relation, order_direction)
        new(relation, relation.primary_key, order_direction || :asc)
      end

      private

      def from_order_string(relation, value)
        if value.match?(PARENTHESIS_REGEX)
          raise OrderValueError, "Order values can't include functions."
        end

        value.split(",").map do |split_value|
          new(relation, *split_value.squish.split)
        end
      end
    end

    def initialize(relation, attribute, direction = :asc)
      @relation = relation
      @attribute = attribute
      @direction = direction.downcase.to_sym
    end

    def primary_key?
      relation.primary_key == attribute
    end

    def type
      relation.type_for_attribute(attribute).type
    end

    def prefixed_attribute
      return attribute if attribute.include?(".")

      "#{relation.table_name}.#{attribute}"
    end

    def select_alias
      prefixed_attribute.tr(".", "_")
    end

    def select_string
      "#{prefixed_attribute} AS #{select_alias}"
    end

    def order_string
      "#{prefixed_attribute} #{direction}"
    end

    private

    attr_reader :relation
  end
end
