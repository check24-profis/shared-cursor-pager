# frozen_string_literal: true

require "bundler/setup"
require "cursor_pager"
require "active_record"

ActiveRecord::Base.establish_connection(
  ENV["DATABASE_URL"] ||
    { adapter: "postgresql", database: "cursor_pager_test" }
)

load File.dirname(__FILE__) + "/schema.rb"
require_relative "models"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
