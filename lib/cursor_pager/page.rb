# frozen_string_literal: true

module CursorPager
  class Page
    attr_reader :relation, :first, :last, :after, :before

    def initialize(relation, first: nil, last: nil, after: nil, before: nil)
      @relation = relation
      @first = first
      @last = last
      @after = after
      @before = before
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
      relation.to_a
    end
  end
end
