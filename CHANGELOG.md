# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.4] - 2026-08-15

### Added

- Added regression tests for CRLF files.
- Added tests for trailing spaces and tabs before CRLF line endings.
- Added a test for trailing whitespace in multiline CRLF files.
- Added a test to verify that clean CRLF files are not reported as
  violations.

### Fixed

- Fixed trailing whitespace detection for CRLF files.
- Preserved the existing LF trailing whitespace detection behavior.

## [0.0.3] - 2026-08-15

### Added

- Added regression tests for trailing whitespace exit status handling.
- Added tests for filenames containing spaces and filenames beginning
  with `-`.
- Added a test to verify that check execution errors are not treated as
  successful checks.

### Fixed

- Fixed trailing whitespace check exit status handling so command
  execution errors are propagated instead of being treated as a
  successful check.
- Replaced the `git ls-files | xargs | grep` pipeline with `git grep` to
  distinguish matches, no matches, and command errors reliably.
