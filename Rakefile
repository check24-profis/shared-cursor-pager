# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop spec]

namespace :db do
  desc "Create the test DB"
  task :create do
    `createdb cursor_pager_test`
  end

  desc "Drop the test DB"
  task :drop do
    `dropdb cursor_pager_test`
  end
end
