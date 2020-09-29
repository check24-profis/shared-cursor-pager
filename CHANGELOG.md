# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/check24-profis/shared-cursor-pager/compare/v0.2.1...HEAD
[0.2.0]: https://github.com/check24-profis/shared-cursor-pager/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/check24-profis/shared-cursor-pager/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/check24-profis/shared-cursor-pager/releases/tag/v0.1.0
