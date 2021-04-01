# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

* Fix `CursorPager::Page#next_page?` when given a grouped relation #15

## [0.2.3] - 2020-11-23

### Fixed

* Fix using cursors with preloaded or eager loaded associations #13

## [0.2.2] - 2020-09-29

### Fixed

* Fix checking if the next page exists when a custom select is given #12

## [0.2.1] - 2020-05-13

### Fixed

* Fix fetching cursor values when relation has join and string order values #9

## [0.2.0] - 2020-04-23

### Added

* `first_cursor` & `last_cursor` convenience methods
* Configurable default & maximum page sizes #6

## [0.1.0] - 2020-04-23

### Added

* First implementation of cursor-pased pagination #2
* Configurable cursor encoder #3

[Unreleased]: https://github.com/check24-profis/shared-cursor-pager/compare/v0.2.3...HEAD
[0.2.3]: https://github.com/check24-profis/shared-cursor-pager/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/check24-profis/shared-cursor-pager/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/check24-profis/shared-cursor-pager/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/check24-profis/shared-cursor-pager/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/check24-profis/shared-cursor-pager/releases/tag/v0.1.0
