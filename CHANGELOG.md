# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.10.1] - 2021-09-16
### Fixed
- Fix `Spectator.configure` block calls to `filter_run_excluding` and `filter_run_including`. [#61](https://gitlab.com/arctic-fox/spectator/-/issues/61)
- Fix shard version constant creation when lib is in a directory with spaces in the path. [#33](https://gitlab.com/arctic-fox/spectator/-/merge_requests/33) Thanks @toddsundsted !
- Re-add pre- and post-condition hooks. [#62](https://gitlab.com/arctic-fox/spectator/-/issues/62)

## [0.10.0] - 2021-09-19
### Fixed
- Fix resolution of types with the same name in nested scopes. [#31](https://github.com/icy-arctic-fox/spectator/issues/31)
- `around_each` hooks wrap `before_all` and `after_all` hooks. [#12](https://github.com/icy-arctic-fox/spectator/issues/12)
- Hook execution order has been tweaked to match RSpec.

### Added
- `before_each`, `after_each`, and `around_each` hooks are yielded the current example as a block argument.
- The `let` and `subject` blocks are yielded the current example as a block argument.
- Add internal logging that uses Crystal's `Log` utility. Provide the `LOG_LEVEL` environment variable to enable.
- Support dynamic creation of examples.
- Capture and log information for hooks.
- Tags can be added to examples and example groups.
- Add matcher to check compiled type of values.
- Examples can be skipped by using a `:pending` tag. A reason method can be specified: `pending: "Some excuse"`
- Examples without a test block are marked as pending. [#37](https://gitlab.com/arctic-fox/spectator/-/issues/37)
- Examples can be skipped during execution by using `skip` or `pending` in the example block. [#17](https://gitlab.com/arctic-fox/spectator/-/issues/17)
- Sample blocks can be temporarily skipped by using `xsample` or `xrandom_sample`.
- Add `before_suite` and `after_suite` hooks. [#21](https://gitlab.com/arctic-fox/spectator/-/issues/21)
- Support defining hooks in `Spectator.configure` block. [#21](https://gitlab.com/arctic-fox/spectator/-/issues/21)
- Examples with failures or skipped during execution will report the location of that result. [#57](https://gitlab.com/arctic-fox/spectator/-/issues/57)
- Support custom messages for failed expectations. [#28](https://gitlab.com/arctic-fox/spectator/-/issues/28)
- Allow named arguments and assignments for `provided` (`given`) block.
- Add `aggregate_failures` to capture and report multiple failed expectations. [#24](https://gitlab.com/arctic-fox/spectator/-/issues/24)
- Supports matching groups. [#25](https://gitlab.com/arctic-fox/spectator/-/issues/25) [#24](https://github.com/icy-arctic-fox/spectator/issues/24)
- Add `filter_run_including`, `filter_run_excluding`, and `filter_run_when_matching` to config block.
- By default, only run tests when any are marked with `focus: true`.
- Add "f-prefix" blocks for examples and groups (`fit`, `fdescribe`, etc.) as a short-hand for specifying `focus: true`.
- Add HTML formatter. Operates the same as the JUnit formatter. Specify `--html_output=DIR` to use. [#22](https://gitlab.com/arctic-fox/spectator/-/issues/22) [#3](https://github.com/icy-arctic-fox/spectator/issues/3)

### Changed
- `given` (now `provided`) blocks changed to produce a single example. `it` can no longer be nested in a `provided` block.
- The "should" syntax no longer reports the source as inside Spectator.
- Short-hand "should" syntax must be included by using `require "spectator/should"` - `it { should eq("foo") }`
- Better error messages and detection when DSL methods are used when they shouldn't (i.e. `describe` inside `it`).
- Prevent usage of reserved keywords in DSL (such as `initialize`).
- The count argument for `sample` and `random_sample` groups must be named (use `count: 5` instead of just `5`).
- Helper methods used as arguments for `sample` and `random_sample` must be class methods.
- Simplify and reduce instanced types and generics. Should speed up compilation times.
- Overhaul example creation and handling.
- Overhaul storage of test values.
- Overhaul reporting and formatting. Cleaner output for failures and pending tests.
- Cleanup and simplify DSL implementation.
- Other minor internal improvements and cleanup.

### Deprecated
- `pending` blocks will behave differently in v0.11.0. They will mimic RSpec in that they _compile and run_ the block expecting it to fail. Use a `skip` (or `xit`) block instead to prevent compiling the example.
- `given` has been renamed to `provided`. The `given` keyword may be reused later for memoization.

### Removed
- Removed one-liner `it`-syntax without braces (block).

## [0.9.40] - 2021-07-10
### Fixed
- Fix stubbing of class methods.
- Fix handling of `no_args` in some cases.

### Changed
- Better handling and stubbing of `Process.exit`.

## [0.9.39] - 2021-07-02
### Fixed
- Fix `expect().to receive()` syntax not implicitly stubbing the method.
- Avoid calling `NoReturn` methods from stubs. [#29](https://github.com/icy-arctic-fox/spectator/issues/29)

### Added
- Added support for `with(no_args)` for method stubs. [#28](https://github.com/icy-arctic-fox/spectator/issues/28)
- Allow creation of doubles without definition block. [#30](https://github.com/icy-arctic-fox/spectator/issues/30)

## [0.9.38] - 2021-05-27
### Fixed
- Fix `Channel::ClosedError` when using default Crystal Logger. [#27](https://github.com/icy-arctic-fox/spectator/issues/27)

## [0.9.37] - 2021-05-19
### Added
- Added support for `be ===` and `be =~`. [#26](https://github.com/icy-arctic-fox/spectator/issues/26)

## [0.9.36] - 2021-04-22
### Fixed
- Remove old workaround that prevented compilation on Windows. [#58](https://gitlab.com/arctic-fox/spectator/-/issues/58)

## [0.9.35] - 2021-04-18
### Fixed
- Allow types stored in variables or returned by methods in `be_a` (and variants), not just type literals. [#25](https://github.com/icy-arctic-fox/spectator/issues/25)

## [0.9.34] - 2021-03-31
### Changed
- Allow filtering examples by using any line in the example block. [#19](https://github.com/icy-arctic-fox/spectator/issues/19) Thanks @matthewmcgarvey !

## [0.9.33] - 2021-03-22
### Changed
- Target Crystal 1.0

## [0.9.32] - 2021-02-03
### Fixed
- Fix source reference with brace-less example syntax. [#20](https://github.com/icy-arctic-fox/spectator/issues/20)

## [0.9.31] - 2021-01-08
### Fixed
- Fix misaligned line numbers when referencing examples and groups.

## [0.9.30] - 2020-12-23
### Fixed
- Fix issue caused by additions from 0.9.29.

### Changed
- Improve the `contain`, `contain_elements`, `have`, and `have_elements` to show missing items in output.

## [0.9.29] - 2020-12-23
### Added
- Add variants `contain_elements` and `have_elements`, which behave like `contain` and `have` matchers except that they take an array (or any enumerable type) instead of a parameter list or splat.

## [0.9.28] - 2020-11-07
### Added
- Add `return_type` option to method stubs.

## [0.9.27] - 2020-10-01
### Added
- Add syntax for stubbing operator-style methods, such as `[]`.

## [0.9.26] - 2020-09-27
### Fixed
- Fix issue with yielding in stubbed mocks.

## [0.9.25] - 2020-09-26
### Fixed
- Fix issue with splatting values for failed match data. This prevented the use of "description" and "failure_message" in some matches like `respond_to`.

## [0.9.24] - 2020-09-17
### Changed
- Allow some forms of string interpolation in group and example descriptions.

## [0.9.23] - 2020-08-30
### Fixed
- Allow the use of `object_id` and other possibly conflicting method names via `let`. [#53](https://gitlab.com/arctic-fox/spectator/-/issues/53)

## [0.9.22] - 2020-08-11
### Changed
- Handle splat in macro for matcher DSL. [#8](https://github.com/icy-arctic-fox/spectator/issues/8)

## [0.9.21] - 2020-07-27
### Added
- Display random seed when using `-r` or `--seed` options. [#7](https://github.com/icy-arctic-fox/spectator/issues/7)

## [0.9.20] - 2020-05-29
### Fixed
- Fix bug when using multiple short-hand block expects in one test.

## [0.9.19] - 2020-05-28
### Fixed
- Fix issue with `match_array` and `contain_exactly` matchers not working with immutable collections.

## [0.9.18] - 2020-04-26
### Fixed
- Fix `describe_class.new` when using a generic type.

## [0.9.17] - 2020-04-23
### Fixed
- Fix issue when using deferred syntax with `receive` matcher. [#48](https://gitlab.com/arctic-fox/spectator/-/issues/48)

## [0.9.16] - 2020-04-06
### Fixed
- Silence warnings from Crystal 0.34

## [0.9.15] - 2020-04-03
### Fixed
- Fix issues with `match_array().in_any_order` and `contain_exactly().in_any_order`. [#47](https://gitlab.com/arctic-fox/spectator/-/issues/47)

### Changed
- Improve usability when actual value does not respond to methods needed to verify it.
For instance, `expect(nil).to contain_exactly(:foo)` would not compile.
This has been changed so that it compiles and raises an error at runtime with a useful message.

## [0.9.14] - 2020-04-01
### Fixed
- Fix using nil with `be` matcher. [#45](https://gitlab.com/arctic-fox/spectator/-/issues/45)

## [0.9.13] - 2020-03-28
### Fixed
- Fix arguments not found in default stubs for mocks. [#44](https://gitlab.com/arctic-fox/spectator/-/issues/44)

## [0.9.12] - 2020-03-20
### Fixed
- Fix issue when mocking modules. Thanks @watzon !

## [0.9.11] - 2020-03-04
### Fixed
- Fix issue when describing constants. [#40](https://gitlab.com/arctic-fox/spectator/-/issues/40) [#41](https://gitlab.com/arctic-fox/spectator/-/issues/41)

## [0.9.10] - 2020-03-03
### Changed
- Smarter behavior when omitting the block argument to the `around_each` hook.

## [0.9.9] - 2020-02-22
### Fixed
- Fix implicit subject when used with a module. [#6](https://github.com/icy-arctic-fox/spectator/issues/6)

## [0.9.8] - 2020-02-21
### Fixed
- Fix `be_between` matcher. Thanks @davidepaolotua / @jinn999 !

## [0.9.7] - 2020-02-16
### Fixed
- Fix memoization of subject when using a type name for the context.
- Fix some cases when mocking a class method.

## [0.9.6] - 2020-02-10
### Added
- Add short-hand "should" syntax - `it { should eq("foo") }`
- The `be` matcher can be used on value types.
- Add more tests cases from RSpec docs.

### Fixed
- Fix an issue with stubbed class methods on mocked types. Sometimes `previous_def` was used when `super` should have been used instead.
- Fix deferred expectations not running after all hooks.

## [0.9.5] - 2020-01-19
### Changed
- Described type is now considered an explicit subject.

## [0.9.4] - 2020-01-19
### Added
- Add more test cases from RSpec docs.
- Add `it_fails` utility to test expected failures.

### Fixed
- Fix negated case for `respond_to` matcher.

## [0.9.3] - 2020-01-17
### Fixed
- Fix implicit subject overwriting explicit subject. [#25](https://gitlab.com/arctic-fox/spectator/-/merge_requests/25)

## [0.9.2] - 2020-01-14
### Added
- Add tests from RSpec docs.
- Add `with_message` modifier for `raise_error` matcher.
- Support omitted description on `it` and `specify` blocks. Use matcher description by default.

### Fixed
- Fix `let!` not inferring return type. [#4](https://github.com/icy-arctic-fox/spectator/issues/4)

### Changed
- Modified some matchers to behave more closely to their RSpec counterparts.

## [0.9.1] - 2019-12-13
### Fixed
- Fix default stub with type.
- Fix verifying double on self argument type.
- Pass stub instead of stub name to mock registry.

### Removed
- Remove unnecessary type from stub class hierarchy.

## [0.9.0] - 2019-12-08
### Added
- Implement initial mocks and doubles (stubbing) support. [#16](https://gitlab.com/arctic-fox/spectator/-/merge_requests/16) [#6](https://gitlab.com/arctic-fox/spectator/-/issues/6)
- Deferred expectations (`to_eventually` and `to_never`).

### Changed
- Test cases no longer define an entire class, but rather a method in a class belonging to the group.

## [0.8.3] - 2019-09-23
### Fixed
- Fix and address warnings with Crystal 0.31.0.

## [0.8.2] - 2019-08-21
### Fixed
- Workaround for Crystal compiler bug [#7060](https://github.com/crystal-lang/crystal/issues/7060). [#1](https://github.com/icy-arctic-fox/spectator/issues/1)

## [0.8.1] - 2019-08-17
### Fixed
- Fix nested `sample_value` blocks giving cryptic error. [#20](https://gitlab.com/arctic-fox/spectator/-/issues/20)

## [0.8.0] - 2019-08-12
### Added
- Add "any order" modifier for `contains_exactly` and `match_array`.
- Add `change` matcher and its variations.
- Add `all` matcher.
- Variation of `let` syntax that takes an assignment.

### Changed
- Rewrote matcher class structure.
- Improved tracking of actual and expected values and their labels.
- Matcher values are only produced when the match fails, instead of always.

### Fixed
- Fix malformed code generated by macros not working in latest Crystal version.

## [0.7.2] - 2019-06-01
### Fixed
- Reference types used in `subject` and `let` were recreated between hooks and the test block. [#11](https://gitlab.com/arctic-fox/spectator/-/issues/11)

## [0.7.1] - 2019-05-21
### Fixed
- Fixed an issue where named subjects could crash the compiler.

## [0.7.0] - 2019-05-16
### Added
- Added `be_between` matcher.

### Changed
- The `be_within` matcher behaves like RSpec's.

## [0.6.0] - 2019-05-08
### Changed
- Introduced reference matcher and changed `be` matcher to use it instead of the case matcher.

### Removed
- Removed regex matcher, the case matcher is used instead.

## [0.5.3] - 2019-05-08
### Fixed
- Updated the `expect_raises` matcher to accept an optional second argument to mimic `raise_error`. [#4](https://gitlab.com/arctic-fox/spectator/-/issues/4)

## [0.5.2] - 2019-04-22
### Fixed
- Fix `after_all` hooks not running with fail-fast enabled. [#2](https://gitlab.com/arctic-fox/spectator/-/issues/2)

## [0.5.1] - 2019-04-18
### Added
- Note in README regarding repository mirror.

### Fixed
- Change protection on expectation partial to work with Crystal 0.28 and "should" syntax.
- Change references to `Time.now` to `Time.utc` in docs.

## [0.5.0] - 2019-04-07
First version ready for public use.


[Unreleased]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.10.1...master
[0.10.1]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.10.0...v0.10.1
[0.10.0]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.40...v0.10.0
[0.9.40]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.39...v0.9.40
[0.9.39]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.38...v0.9.39
[0.9.38]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.37...v0.9.38
[0.9.37]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.36...v0.9.37
[0.9.36]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.35...v0.9.36
[0.9.35]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.34...v0.9.35
[0.9.34]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.33...v0.9.34
[0.9.33]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.32...v0.9.33
[0.9.32]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.31...v0.9.32
[0.9.31]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.30...v0.9.31
[0.9.30]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.29...v0.9.30
[0.9.29]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.28...v0.9.29
[0.9.28]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.27...v0.9.28
[0.9.27]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.26...v0.9.27
[0.9.26]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.25...v0.9.26
[0.9.25]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.24...v0.9.25
[0.9.24]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.23...v0.9.24
[0.9.23]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.22...v0.9.23
[0.9.22]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.21...v0.9.22
[0.9.21]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.20...v0.9.21
[0.9.20]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.19...v0.9.20
[0.9.19]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.18...v0.9.19
[0.9.18]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.17...v0.9.18
[0.9.17]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.16...v0.9.17
[0.9.16]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.15...v0.9.16
[0.9.15]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.14...v0.9.15
[0.9.14]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.13...v0.9.14
[0.9.13]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.12...v0.9.13
[0.9.12]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.11...v0.9.12
[0.9.11]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.10...v0.9.11
[0.9.10]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.9...v0.9.10
[0.9.9]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.8...v0.9.9
[0.9.8]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.7...v0.9.8
[0.9.7]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.6...v0.9.7
[0.9.6]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.5...v0.9.6
[0.9.5]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.4...v0.9.5
[0.9.4]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.3...v0.9.4
[0.9.3]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.2...v0.9.3
[0.9.2]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.1...v0.9.2
[0.9.1]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.9.0...v0.9.1
[0.9.0]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.8.3...v0.9.0
[0.8.3]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.8.2...v0.8.3
[0.8.2]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.8.1...v0.8.2
[0.8.1]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.8.0...v0.8.1
[0.8.0]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.7.2...v0.8.0
[0.7.2]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.7.1...v0.7.2
[0.7.1]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.7.0...v0.7.1
[0.7.0]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.6.0...v0.7.0
[0.6.0]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.5.2...v0.6.0
[0.5.3]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.5.2...v0.5.3
[0.5.2]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.5.1...v0.5.2
[0.5.1]: https://gitlab.com/arctic-fox/spectator/-/compare/v0.5.0...v0.5.1
[0.5.0]: https://gitlab.com/arctic-fox/spectator/-/releases/v0.5.0
