# TODO

An inventory of unfinished work and missing features for Spectator, a
feature-rich testing framework for Crystal inspired by RSpec (and, to a
lesser extent, Jest). This list is split into two parts:

1. **Explicit TODOs / stubs** already marked in the code.
2. **Feature gap analysis** — functionality common to RSpec/Jest/Minitest
   that Spectator either partially supports or is missing entirely.

This file is generated from a review of the codebase and is not exhaustive of
every design decision, but should serve as a roadmap.

## 1. Explicit TODOs and stubs in the code

### Matchers not yet implemented

`src/spectator/matchers/built_in.cr` defines the RSpec-compatible matcher DSL,
but many methods are stubs that raise `NotImplementedError`:

- [ ] `be_base64` — `src/spectator/matchers/built_in.cr:30`
- [ ] `be_close_to(expected, digits)` — `src/spectator/matchers/built_in.cr:46`
- [ ] `be_hexadecimal` — `src/spectator/matchers/built_in.cr:70`
- [ ] `be_timestamp(format)` — `src/spectator/matchers/built_in.cr:110`
- [ ] `be_uuid(version)` — `src/spectator/matchers/built_in.cr:122`
- [ ] `be_within(delta)` (the `#of(expected)` chained form) — `src/spectator/matchers/built_in.cr:126`
- [ ] `contain_exactly(*values)` — `src/spectator/matchers/built_in.cr:146`
- [ ] `cover(*value)` — `src/spectator/matchers/built_in.cr:150`
- [ ] `decrease(&block)` — `src/spectator/matchers/built_in.cr:154`
- [ ] `end_with(expected)` — `src/spectator/matchers/built_in.cr:158`
- [ ] `have_index(value)` — `src/spectator/matchers/built_in.cr:186`
- [ ] `have_indexes(*values)` — `src/spectator/matchers/built_in.cr:190`
- [ ] `have_key(value)` — `src/spectator/matchers/built_in.cr:194`
- [ ] `have_keys(*values)` — `src/spectator/matchers/built_in.cr:198`
- [x] `have_size(value)` — `src/spectator/matchers/built_in.cr:202`
- [ ] `have_value(value)` — `src/spectator/matchers/built_in.cr:210`
- [ ] `have_values(*values)` — `src/spectator/matchers/built_in.cr:214`
- [ ] `increase(&block)` — `src/spectator/matchers/built_in.cr:218`
- [ ] `match_array(array)` — `src/spectator/matchers/built_in.cr:226`
- [ ] `match_size_of(value)` — `src/spectator/matchers/built_in.cr:230`
- [ ] `output(value)` (`to_stdout` / `to_stderr` support) — `src/spectator/matchers/built_in.cr:234`
- [ ] `start_with(expected)` — `src/spectator/matchers/built_in.cr:258`

### Hooks

- [ ] `around_all` hook is not implemented (only `before_all`/`after_all`/`around_each` exist) — `src/spectator/core/hooks.cr:167`
- [ ] `Example::Procsy#wrap` should warn when a wrapping `around` hook never
      calls `#run` on the example it wraps — `src/spectator/core/example.cr:112`

### CLI (`src/spectator/core/cli.cr`)

Several command-line flags are parsed but do nothing yet:

- [x] `-p`/`--profile [NUMBER]` — parses the flag but never configures
      `configuration.profile_examples` (`src/spectator/core/cli.cr:97-99`)
- [x] `--order MODE` — parses `random`/seed value but never applies it to
      `configuration.order`/`configuration.seed` (`src/spectator/core/cli.cr:125-127`)
- [ ] `-v`/`--verbose` — accepted but does nothing (`src/spectator/core/cli.cr:138-140`)
- [x] `--tap` — accepted but never switches the active formatter to
      `Formatters::TAPFormatter` (`src/spectator/core/cli.cr:142-144`)
- [ ] No `--format`/`-f` flag exists to choose a formatter (progress, doc,
      json, etc.) or to load a custom formatter by class name.

### Runner / execution engine

- [ ] `Runner#run` has a `# TODO: Reduce complexity` marker and is flagged for
      refactoring — `src/spectator/core/runner.cr:18`
- [x] `Configuration#order` (`Order::Random`, `Order::Modified`) and
      `Configuration#seed` are declared but **never consulted** when building
      the list of examples to run — examples always run in defined order
      regardless of configuration (`src/spectator/core/runner.cr:63-72, 178-191`).
- [x] `Configuration#profile_examples` is declared but no formatter ever
      reads it or prints a "slowest examples" report (see `report_profile`
      below).

### Formatters

- [x] `report_profile` is an empty no-op in every formatter that implements
      it (`CommonTextOutput#report_profile` at
      `src/spectator/formatters/common_text_output.cr:174` and
      `CompatibleJUnitFormatter#report_profile` at
      `src/spectator/formatters/compatible_junit_formatter.cr:106`) — the
      "N slowest examples" report is never produced.
- [x] `TAPFormatter` (`src/spectator/formatters/tap_formatter.cr`) does not
      inherit from `Formatter`, is missing most of the required overrides
      (`started`, `finished`, `suite_started`, `suite_finished`,
      `example_group_started`/`_finished`, `report_results`,
      `report_profile`, `report_summary`), and its `example_finished`
      signature (`example, result`) doesn't match the rest of the formatter
      interface (`result : ExecutionResult`). It will not currently compile
      as a drop-in `Formatter`.
- [ ] Backtrace collapsing threshold is hard-coded; should be configurable —
      `src/spectator/formatters/common_text_output.cr:95`
- [ ] `humanize(span)` duration formatting helper is inline and marked to be
      moved to a shared utility module —
      `src/spectator/formatters/common_text_output.cr:196`

### Miscellaneous / cleanup

- [ ] Several `# TODO: Is it possible to move this out of the global
      namespace?` markers exist around the top-level `include` statements
      that inject matcher/expectation DSL methods into every `Object`:
  - `src/spectator/matchers/negated.cr:114`
  - `src/spectator/matchers/custom.cr:284`
  - `src/spectator/matchers/expect.cr:140`
  - `src/spectator/matchers/built_in.cr:264`
- [ ] `Matchers::Matcher` has multiple `# TODO: Add more information, such as
      missing methods and suggestions.` markers for error messages produced
      when a matcher is misused — `src/spectator/matchers/matcher.cr:25,29,40,52,90,94,105,117`
- [ ] `change`/`increase`/`decrease` matcher: ambiguous
      `expect { }.not_to change { }.to()` should be a compile-time error
      instead of a runtime `FrameworkError`, and there's no warning when
      `from`/`to` values are identical —
      `src/spectator/matchers/built_in/change_matcher.cr:186-187,202,232-233`
- [ ] `README.md` is still the default shard template — it needs an actual
      description, usage instructions, and development instructions
      (`README.md:3,23,27`).

## 2. Feature gap analysis (RSpec / Jest parity)

Spectator already implements a solid core: `describe`/`context`/`it`/
`specify` (with `x`-prefixed skip variants), `before`/`after`/`around` hooks
(each/all/suite), `let`/`let!`, tags & tag-based filtering, `should`/
`should_not`, `expect().to`/`not_to`, custom matcher DSL
(`Spectator::Matchers.define`), and mocks/doubles/spies via the vendored
`mocks` shard. The items below are missing or incomplete relative to what
RSpec/Jest users would expect.

### Test suite structure & DSL

- [ ] **`subject` / implicit subject** — `is_expected` is implemented
      (`src/spectator/matchers/expect.cr:134`) but calls a `subject` method
      that Spectator never defines. There is no built-in `subject`,
      `subject!`, or implicit subject derived from `described_class`. Users
      must manually `let(subject = ...)` today.
- [ ] **`described_class`** — no equivalent to RSpec's automatic
      `described_class` when `describe SomeClass do ... end` is used with a
      class/module argument (Spectator's `describe`/`context` only accept a
      free-form `description`, not a described type).
- [ ] **Shared examples** — no `shared_examples`/`shared_examples_for`,
      `it_behaves_like`, `include_examples`, or `shared_context` equivalents.
- [ ] **Focus filtering (`fit`/`fdescribe`/`fcontext`/`:focus`)** — RSpec-style
      "run only focused examples" is not implemented. Only exclusion via
      `skip`/`pending` tags and CLI `--tag` filters exist.
- [ ] **`pending` example/matcher semantics** — currently `pending` is treated
      identically to `skip` (`src/spectator/core/tags.cr:18`). RSpec's
      `pending` runs the example and turns an unexpected pass into a failure
      ("Expected pending 'X' to fail. No error was raised."); that behavior
      doesn't exist here.
- [ ] **`aggregate_failures`** — no way to collect multiple failed
      expectations within a single example and report them all instead of
      stopping at the first failure.
- [ ] **Example/group metadata inheritance helpers** — RSpec's
      `config.define_derived_metadata` / computed tags have no equivalent.
- [ ] **Retrying flaky examples** (`rspec-retry`-style `retry:` tag, or Jest's
      `jest.retryTimes`) is not supported.
- [ ] **Per-example/group timeouts** (Jest's per-test timeout, or
      `rspec-timeout`) are not supported — a hung example will hang the whole
      run.
- [ ] **`before_type_check`/context-class matching** (e.g. running a shared
      group of examples for any object that includes a module) has no
      equivalent.

### Matchers

- [ ] **Matcher composition** — no `and`/`or` compound matcher support
      (RSpec: `expect(x).to eq(1).or eq(2)`), and no built-in `satisfy`
      matcher for arbitrary block-based predicates outside the custom
      matcher DSL.
- [ ] **Collection matchers** — `contain_exactly`, `match_array`, `have_size`,
      `have_key(s)`, `have_value(s)`, `have_index(es)`, `cover`, `start_with`,
      `end_with` are all stubbed out (see section 1) rather than implemented.
- [ ] **`output` matcher** (`to_stdout`/`to_stderr`/`to_stdout_from_any_process`)
      for capturing and asserting on IO output is stubbed only.
      Jest's equivalent (`console.log` spies) also has no analog.
- [ ] **`change`/`increase`/`decrease`** — `change` is implemented, but
      `increase`/`decrease` (convenience wrappers RSpec provides for numeric
      change assertions) are stubbed.
- [ ] **Format/type-focused matchers** — `be_uuid`, `be_hexadecimal`,
      `be_base64`, `be_timestamp` are stubbed; there's no `be_a_kind_of`
      alias, no `respond_to(...).with(n).arguments`, and no
      `respond_to(...).with_keywords(...)` argument-arity checking (only a
      bare `respond_to(:method)` exists).
- [ ] **Snapshot testing** (Jest's `toMatchSnapshot`/`toMatchInlineSnapshot`)
      has no equivalent at all.
- [ ] **Asymmetric matchers as values** (Jest's `expect.any(Class)`,
      `expect.arrayContaining`, etc., usable inside other matchers/mock
      argument matching) are not implemented outside of what `mocks`
      provides for stub argument matching (`Mocks::Anything`,
      `Mocks::ArgumentsPattern`).

### Test execution / runner

- [x] **Random test order / seeded runs** — `Order::Random` exists as an enum
      value and `--seed`/`--order` CLI flags are parsed, but the runner never
      shuffles examples or reports the seed used (see section 1). This is a
      core RSpec/Jest feature (`--order random`, printing `Randomized with
      seed 1234` in output).
- [x] **`--profile` slowest-examples report** — parsed and stored in config
      but never rendered (see section 1).
- [ ] **Fail-fast is implemented**, but there's no **"rerun failed examples
      only"** feature (RSpec's `--only-failures`/`--next-failure`, Jest's
      `--onlyFailures`) — no persisted example status file.
- [ ] **Parallel test execution** (Jest runs test files in worker processes
      by default; RSpec has `parallel_tests`) — Spectator runs everything
      serially in a single process/fiber.
- [ ] **Watch mode** (Jest's `--watch`) for automatically re-running tests
      when files change is not implemented (would fit naturally as a CLI
      feature, though it's less of a framework concern in Crystal's compiled
      workflow).
- [ ] **Global setup/teardown files** distinct from `before_suite`/
      `after_suite` (Jest's `globalSetup`/`globalTeardown` config options) —
      partially covered by `before_suite`/`after_suite`, but there's no way
      to configure this from `.spectator` option files, only from Crystal
      code.

### Formatters / reporting

- [ ] **Selectable formatters via CLI** — `--format`/`-f` (RSpec) or
      `--reporters` (Jest) do not exist; only the hard-coded default
      (`DotsFormatter`) and `--junit_output` are wired up, even though
      `TerminalPrinter`, `PlainPrinter`, and a (broken) `TAPFormatter` exist
      in the codebase.
- [ ] **Documentation-style formatter** (RSpec's `--format documentation`,
      which nests and prints every `describe`/`context`/`it` description) is
      not implemented — only dot-progress and JUnit XML exist.
- [ ] **JSON formatter** (RSpec's `--format json`, Jest's default JSON
      reporter output used by IDEs/CI) is not implemented.
- [ ] **HTML formatter** (`rspec-html-formatter`-equivalent) is not
      implemented.
- [ ] **Coverage reporting integration** (Jest's built-in `--coverage`) has
      no equivalent; would likely integrate with an external Crystal
      coverage tool, but there's currently no hook point for it.
- [ ] **Custom/pluggable formatter loading by class name from the CLI**
      (RSpec: `--format CustomFormatterClass`) is not supported.

### Mocking/doubles

The vendored `mocks` shard (`lib/mocks`) already provides mocks, doubles,
spies, `allow`/`expect().to have_received`, null objects, and argument
matchers, which covers most RSpec-mocks/Jest-mock-fn functionality. Gaps
observed from the Spectator integration layer (`src/spectator/mocks.cr`):

- [ ] **`instance_double`/`class_double`/verified doubles** tied into
      Spectator's own configuration (verifying against real constants) isn't
      exposed/documented at the Spectator level.
- [ ] **Automatic mock/stub verification at the end of each example**
      (failing a test if an expected message was never received, akin to
      RSpec's `verify_partial_doubles` and message expectation
      verification) should be double-checked for full parity — worth an
      explicit test/feature audit.
- [ ] **Jest-style module mocking** (`jest.mock('module')` auto-mocking of
      entire modules) has no equivalent — not really idiomatic for Crystal,
      but noted as a Jest feature with no Spectator analog.

### Configuration & tooling

- [ ] **`.rspec`-equivalent project config file docs** — `.spectator`/
      `.spectator-local`/`XDG_CONFIG_HOME` option files are supported by the
      CLI (`src/spectator/core/cli.cr:34-46`), but this isn't documented
      anywhere in `README.md`.
- [ ] **Metadata-based configuration hooks**, e.g. RSpec's
      `config.when_first_matching_example_defined` or
      `config.include Module, tag: value` (mixing in helper modules based on
      tags) have no equivalent — only global `before`/`after`/`around` hooks
      exist at the configuration level.
- [ ] **`--dry-run` exists**, but there's no equivalent to RSpec's
      `--init` (scaffolding `spec_helper.cr`/`.spectator` on new projects).

## Suggested prioritization

1. ~~Wire up already-declared-but-unused config (`order`, `seed`,
   `profile_examples`) in the runner — the plumbing exists, only the
   behavior is missing.~~
2. ~~Fix/finish `TAPFormatter`~~ and add a `--format` CLI flag so users can pick
   between dots/documentation/TAP/JSON/JUnit.
3. Implement the remaining stubbed matchers in `built_in.cr`, prioritizing
   the commonly used ones: ~~`have_size`,~~ `contain_exactly`, `start_with`,
   `end_with`, `have_key`/`have_value`.
4. Add `subject`/`described_class` and `shared_examples`/`it_behaves_like`,
   since these are heavily used RSpec idioms and currently have zero
   support.
5. Add focus (`fit`/`fdescribe`/`fcontext`) and proper `pending` semantics,
   since both are commonly reached-for during day-to-day development.

## Additional features

- [ ] TAP "Bail out!" for fail early - additional method on formatters for this
- [ ] TAP "TODO" for RSpec "pending" behavior (description comes before # TODO pragma!)
