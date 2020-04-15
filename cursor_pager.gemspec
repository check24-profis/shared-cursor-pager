# frozen_string_literal: true

require_relative "lib/cursor_pager/version"

Gem::Specification.new do |spec|
  spec.name          = "cursor_pager"
  spec.version       = CursorPager::VERSION
  spec.authors       = ["Bastian Bartmann"]
  spec.email         = ["bastian.bartmann@check24.de"]

  spec.summary       = "Cursor-based pagination for ActiveRecord relations."
  spec.homepage      = "https://github.com/askcharlie/cursor_pager"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] =
    "https://github.com/askcharlie/cursor_pager/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency("activerecord", ">= 5.2.0")
end
