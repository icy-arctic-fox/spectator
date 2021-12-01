# Contributing to Spectator

Welcome to Spectator! We're glad you're here!

Spectator strives to be an easy-to-use, batteries included testing framework for Crystal shards and applications.
The goal of Spectator is to:

- Provide an easy-to-understand syntax for tests. Reading and writing tests should feel natural.
- Lower the bar to entry. Simplify non-trivial use cases make testing easier.
- Remove boilerplate. Reduce the amount of code necessary to get the job done. Provide common utilities.

Spectator is heavily inspired by [RSpec](https://rspec.info/).
It tries to maintain compatibility with RSpec, but this isn't always possible.
Some language differences between [Ruby and Crystal](https://www.crystalforrubyists.com/) prohibit this.
Spectator also maintains feature parity with Crystal's [Spec](https://crystal-lang.org/reference/guides/testing.html).

**Table of Contents**

- [Useful links](#useful-links)
- [Repository hosting](#repository-hosting)
- [How can I contribute?](#how-can-i-contribute)
  - [Upcoming](#upcoming)
  - [How to submit changes](#how-to-submit-changes)
  - [How to report a bug](#how-to-report-a-bug)
  - [How to request an enhancement](#how-to-request-an-enhancement)
  - [Where can I get help?](#where-can-i-get-help)
- [Development](#development)
  - [Testing](#testing)
  - [Style guide and conventions](#style-guide-and-conventions)
  - [Branching](#branching)

## Useful links

Here are some useful links for Spectator:

- [README](README.md)
- [Change log](CHANGELOG.md)
- [Architecture](ARCHITECTURE.md)
- Wiki [GitLab](https://gitlab.com/arctic-fox/spectator/-/wikis/home) | [GitHub](https://github.com/icy-arctic-fox/spectator/wiki)
  - Big List of Matchers [GitLab](https://gitlab.com/arctic-fox/spectator/-/wikis/Big-List-of-Matchers) | [GitHub](https://github.com/icy-arctic-fox/spectator/wiki/Big-List-of-Matchers)
- [Documentation (Crystal docs)](https://arctic-fox.gitlab.io/spectator)
- Issue tracker [GitLab](https://gitlab.com/arctic-fox/spectator/-/issues) | [GitHub](https://github.com/icy-arctic-fox/spectator/issues)
- [Builds](https://gitlab.com/arctic-fox/spectator/-/pipelines)
- [Crystal Macros](https://crystal-lang.org/reference/syntax_and_semantics/macros/index.html)
  - [API](https://crystal-lang.org/api/latest/Crystal/Macros.html)

## Repository hosting

Spectator is available on [GitHub](https://github.com/icy-arctic-fox/spectator) and [GitLab](https://gitlab.com/arctic-fox/spectator).
The primary housing for Spectator is [GitLab](https://gitlab.com/arctic-fox/spectator).
This is a preference of the primary developer ([arctic-fox](https://gitlab.com/arctic-fox)).
That doesn't mean GitLab is the only place to contribute!
The repository and wiki are mirrored and maintainers will ensure contributions get into the project.
Issues, pull requests, and other contributions are accepted on both.
Use whichever you prefer!

## How can I contribute?

You can contribute in a variety of ways.
One of the easiest ways to contribute is to use Spectator!
Provide us feedback and report and bugs or issues you find.
Being a testing framework, Spectator should be rock solid.

If you want to contribute to the codebase, take a look at the open issues.
[GitLab](https://gitlab.com/arctic-fox/spectator/-/issues) | [GitHub](https://github.com/icy-arctic-fox/spectator/issues)
Any issue not assigned can be picked up.
Even if one is already assigned, you may still be able to help out, just ask!

If there isn't an issue for something you want to add or change, please create one first.
That way, we can discuss it before possibly wasting time on a misunderstanding.
Check out the [upcoming](#upcoming) section for a list of upcoming changes.
Anyone submitting code to Spectator will get a call-out in the [change log](CHANGELOG.md).

You can also help by writing tests or documentation for the wiki.

### Upcoming

These are the projects that Spectator maintainers are looking to tackle next.
These issues are quite substantial, but assistance would be greatly appreciated!

- [Overhaul of the mock and stubbing system](https://gitlab.com/arctic-fox/spectator/-/issues/63)
- [Errors masked in DSL by `method_missing` (predicate matcher)](https://gitlab.com/arctic-fox/spectator/-/issues/64)
- [Custom matcher DSL](https://gitlab.com/arctic-fox/spectator/-/issues/65)
- [Compiler optimizations](https://gitlab.com/arctic-fox/spectator/-/issues/66)
- More tests!

### How to submit changes

Submit your changes as a pull request (either GitLab or GitHub).
Please keep change requests focused on a single feature or bug.
Larger pull requests may be broken up into logical pieces.
This helps reviewers digest the changes.

Describe the purpose of the change, what it addresses.
Provide links to related issues, bugs the changes fix, or external resources (i.e. RSpec docs).
Note any significant items or breaking changes.
Include a snippet of code demonstrating the code, if applicable.

Please include tests for new code and bug fixes.
Some parts of Spectator are harder to test than others.
Check out the [testing](#testing) section for more information.

### How to report a bug

Be sure you can reproduce the issue.
Try to reduce the amount of code and complexity needed to reproduce the issue.
Check of outstanding issues, it might already be reported.

Open an issue (either [GitLab](https://gitlab.com/arctic-fox/spectator/-/issues/new) or [GitHub](https://github.com/icy-arctic-fox/spectator/issues/new)).
Provide information on what you're trying to do.
Include source code that reproduces the issue.
Add any specific details or specifics about your usage and environment.
For instance: using Windows, compiling with specific flags, dependencies on other shards, custom helper code, etc.

Maintainers generally won't close an issue until they're certain it is resolved.
We may ask that you verify the fix on your end before closing the issue.

### How to request an enhancement

Check for existing feature requests, someone might already have the same idea.
Create a new issue (either [GitLab](https://gitlab.com/arctic-fox/spectator/-/issues/new) or [GitHub](https://github.com/icy-arctic-fox/spectator/issues/new)).
Explain what you're trying to do or would like improved.
Include reasoning - why do you want this feature, what would it help with?
Provide code snippets if it helps illustrate the idea.

## Where can I get help?

First checkout the [README](README.md) and wiki ([GitLab](https://gitlab.com/arctic-fox/spectator/-/wikis/home) | [GitHub](https://github.com/icy-arctic-fox/spectator/wiki)).
These two locations are official sources of information for the project.

Look for existing issues before creating a new one.
We use issues for bugs, features, and general help/support.
You might find something that addresses your issue or points you in the right direction.
Adding a :+1: to the original issue is appreciated!

If you can't find anything already out there, submit an issue.
Explain what you're trying to do and maybe an explanation of why.
Sometimes we might discover a better solution for what you're attempting to do.
Provide code snippets, command-line, and examples if possible.

## Development

Spectator is cross-platform and should work on any OS that [Crystal supports](https://crystal-lang.org/install/).
Development on Spectator is possible with a default Crystal installation (with Shards).

To get started:

1. Fork the repository [GitLab](https://gitlab.com/arctic-fox/spectator/fork/new) | [GitHub](https://github.com/icy-arctic-fox/spectator/fork)
2. Clone the forked git repository.
3. Run `shards` in the repository to pull developer dependencies.
4. Verify everything works by running `crystal spec`.

At this point, dive into the code or check out the [architecture](ARCHITECTURE.md).

### Testing

Spectator uses itself for testing.
Please try to write tests for any new features that are added.
Bugs should have tests created for them to combat regression.

The `spec/` directory contains all tests.
The feature tests are grouped into sub directories based on their type, they are:

- `docs/` - Example snippets from Spectator's documentation.
- `features/` - Tests for Spectator's DSL and headline features.
- `issues/` - Tests for reported bugs.
- `matchers/` - Exhaustive testing of matchers.
- `rspec/` - Examples from RSpec's documentation modified slightly to work with Spectator. See: https://relishapp.com/rspec/
- `spectator/` - Unit tests for Spectator internals.

The `helpers/` directory contains utilities to aid tests.

### Style guide and conventions

General Crystal styling should be used.
To ensure everything is formatted correctly, run `crystal tool format` prior to committing.

Additionally, [Ameba](https://crystal-ameba.github.io/) is used to encourage best coding practices.
To run Ameba, run `bin/ameba` in the root of the repository.
This requires that shards have been installed.

Formatting checks and Ameba will be run as part of the CI pipeline.
Both are required to pass before a pull request will be accepted and merged.
Exceptions can be made for some Ameba issues.
Adding `#ameba:disable` to a line will [disable Ameba](https://crystal-ameba.github.io/ameba/#inline-disabling) for a particular issue.
However, please prefer to fix the issue instead of ignoring them.

Please attempt to document every class and public method.
Documentation isn't required on private methods and trivial code.
Please add comments explaining algorithms and complex code.
DSL methods and macros should be heavily documented.
This helps developers using Spectator.

HTML documentation is automatically generated (by `crystal docs`) and published to [GitLab pages](https://arctic-fox.gitlab.io/spectator).

### Branching

The `master` branch contains the latest stable code.
Branches are used for features, fixes, and release preparation.

A new minor release is made whenever there is enough functionality to warrant one or some time has passed since the last one and there's pending fixes.
A new major release occurs when there are substantial changes to Spectator.
Known breaking changes are always in a major release.
Tags are made for each release.
