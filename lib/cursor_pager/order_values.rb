# frozen_string_literal: true

require "forwardable"

module CursorPager
  # OrderValue collection wrapper.
  class OrderValues
    extend Forwardable
    include Enumerable

    def_delegators :@collection, :each, :<<, :size, :present?

    # A relation's order_values can either be an empty array, an array including
    # just one string, or an array of arel ordering nodes.
    def self.from_relation(relation)
      arel_order_values = relation.order_values.uniq.reject(&:blank?)
      collection = arel_order_values.flat_map do |value|
        case value
        when Arel::Nodes::Ordering
          OrderValue.from_arel_node(relation, value)
        when String
          OrderValue.from_order_string(relation, value)
        end
      end

      new(collection)
    end

    def initialize(collection = [])
      @collection = collection
    end

    def direction
      @collection.first&.direction
    end

    def order_string
      @collection.map(&:order_string).join(", ")
    end
  end
end
