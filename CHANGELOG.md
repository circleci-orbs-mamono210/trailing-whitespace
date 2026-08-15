# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.12] - 2026-08-15

### Changed

- Removed the unused `run_check()` helper function from the trailing
  whitespace regression test script.
- Kept the existing explicit exit status handling in each regression
  test case unchanged.

## [0.0.11] - 2026-08-15

### Added

- Added a regression test verifying that trailing tabs are detected in
  LF-terminated files.
- Added verification that an LF file containing a trailing tab is reported
  as a trailing whitespace violation.

## [0.0.10] - 2026-08-15

### Added

- Added a regression test verifying that Git-tracked binary files are
  excluded from trailing whitespace checks.
- Added coverage for binary files containing data that could otherwise
  match the trailing whitespace pattern.

## [0.0.9] - 2026-08-15

### Changed

- Removed the duplicate `SC1009` entry from the ShellCheck `exclude`
  configuration.

## [0.0.8] - 2026-08-15

### Fixed

- Updated the Orb version in README usage examples from `0.0.6` to `0.0.8`
  to match the release version.

## [0.0.7] - 2026-08-15

### Changed

- Changed the default executor image from the custom trailing-whitespace
  image to `cimg/python:3.14`.
- Standardized the default executor with other Orb projects.
- Removed the default runtime dependency on the custom
  trailing-whitespace container image.

## [0.0.6] - 2026-08-15

### Added

- Added an MIT License file.
- Added documentation for Orb usage, supported line endings, and trailing
  whitespace detection behavior.
- Added documentation explaining that only Git-tracked files are checked.

### Changed

- Expanded the README with setup and usage examples.
- Documented the requirement to run `checkout` before the `execute` command.
- Updated the license badge to reference this repository's `LICENSE` file.

## [0.0.5] - 2026-08-15

### Added

- Added a negative integration test for tracked files containing trailing
  whitespace.
- Added coverage verifying that untracked files are excluded from trailing
  whitespace checks.
- Added verification that a file begins failing the check after it becomes
  tracked.
- Added the negative integration test as a production publish requirement.

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

