# frozen_string_literal: true

require "cursor_pager/version"

module CursorPager
  class Error < StandardError
  end
end

require "cursor_pager/conflicting_orders_error"
require "cursor_pager/cursor_not_found_error"
require "cursor_pager/invalid_cursor_error"
require "cursor_pager/order_value_error"

require "cursor_pager/configuration"
require "cursor_pager/base64_encoder"
require "cursor_pager/order_value"
require "cursor_pager/order_values"
require "cursor_pager/limit_relation"
require "cursor_pager/slice_relation"
require "cursor_pager/page"
