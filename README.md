# Trailing Whitespace Orb

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/circleci-orbs-mamono210/trailing-whitespace/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/circleci-orbs-mamono210/trailing-whitespace/tree/main)
[![CircleCI Orb Version](https://badges.circleci.com/orbs/orbss/trailing-whitespace.svg)](https://circleci.com/developer/orbs/orb/orbss/trailing-whitespace)
[![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

A CircleCI Orb for detecting trailing whitespace in Git-tracked text files.

The check fails when trailing spaces or tabs are found.

## Features

* Checks Git-tracked files only.
* Ignores untracked files.
* Ignores binary files.
* Detects trailing spaces and tabs.
* Supports LF line endings.
* Supports CRLF line endings.
* Fails the CircleCI step when trailing whitespace is detected.
* Propagates errors when the check itself cannot be executed.

## Usage

Add the Orb to your CircleCI configuration:

```yaml
version: 2.1

orbs:
  trailing-whitespace: orbss/trailing-whitespace@0.0.8
```

Create a job using the default executor and the `execute` command:

```yaml
version: 2.1

orbs:
  trailing-whitespace: orbss/trailing-whitespace@0.0.8

jobs:
  trailing-whitespace:
    executor: trailing-whitespace/default
    steps:
      - checkout
      - trailing-whitespace/execute

workflows:
  check:
    jobs:
      - trailing-whitespace
```

## Checkout requirement

The `trailing-whitespace/execute` command checks files tracked by Git.

Run the CircleCI `checkout` step before executing the command:

```yaml
steps:
  - checkout
  - trailing-whitespace/execute
```

Files that are not tracked by Git are not checked.

## Check behavior

| Condition                           | Result  |
| ----------------------------------- | ------- |
| No trailing whitespace is found     | Success |
| Trailing whitespace is found        | Failure |
| The check itself cannot be executed | Failure |

Trailing whitespace is detected immediately before both LF and CRLF line endings.

The check targets spaces and tabs. The CR character used by CRLF line endings is not treated as trailing whitespace by itself.

## License

This project is licensed under the [MIT License](LICENSE).

