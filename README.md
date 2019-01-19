Spectator
=========

Spectator is a fully-featured spec-based test framework for Crystal.
It provides more functionality from [RSpec](http://rspec.info/)
than the built-in Crystal [Spec](https://crystal-lang.org/api/latest/Spec.html) utility.
Additionally, Spectator provides extra features to make testing easier and more fluent.

**Goal:**

Spectator is designed to:

- Reduce complexity of test code.
- Remove boilerplate from tests.
- Lower the difficulty of writing non-trivial tests.
- Provide an elegant syntax that is easy to read and understand.
- Provide common utilities that the end-user would otherwise need to write.

Installation
------------

Add this to your application's `shard.yml`:

```yaml
development_dependencies:
  spectator:
    gitlab: arctic-fox/spectator
```

Usage
-----

If it doesn't exist already, create a `spec/spec_helper.cr` file.
In it, place the following:

```crystal
require "spectator"
require "../src/*"
```

This will include Spectator and the source code for your shard.
Now you can start writing your specs.
The syntax is the same as what you would expect from modern RSpec.
The "expect" syntax is recommended and the default, however the "should" syntax is also available.
Your specs must be wrapped in a `Spectator.describe` block.
All other blocks inside the top-level block may use `describe` and `context` without the `Spectator.` prefix.

Here's a minimal spec to demonstrate:

```crystal
require "./spec_helper"

Spectator.describe String do
  subject { "foo" }

  describe "#==" do
    context "with the same value" do
      let(value) { subject.dup }

      it "is true" do
        is_expected.to eq(value)
      end
    end

    context "with a different value" do
      let(value) { "bar" }

      it "is false" do
        is_expected.to_not eq(value)
      end
    end
  end
end
```

If you find yourself trying to shoehorn in functionality
or unsure how to write a test, please create an [issue](https://gitlab.com/arctic-fox/spectator/issues/new) for it.
We want to make it as easy as possible to write specs and keep your code clean.
We may come up with a solution or even introduce a feature to support your needs.

NOTE: Due to the way this shard uses macros,
you may find that some code you would expect to work, or works in other spec libraries, creates syntax errors.
If you run into this, please create an issue so that we may help you resolve it.

Features
--------

TODO: Document the features and give brief usage examples.

Development
-----------

This shard is under heavy development and is not ready to be used for production.

### Feature Progress

In no particular order, features that have been implemented and are planned:

- [ ] DSL
    - [X] `describe` and `context` blocks
    - [X] Contextual values with `let`, `let!`, `subject`, `described_class`
    - [X] Test multiple and generated values - `sample`, `random_sample`
    - [X] Concise syntax - `given`
    - [X] Before and after hooks - `before_each`, `before_all`, `after_each`, `after_all`, `around_each`
    - [ ] Pre- and post-conditions - `pre_condition`, `post_condition`
    - [ ] Other hooks - `on_success`, `on_failure`, `on_error`
    - [X] One-liner syntax
    - [X] Should syntax - `should`, `should_not`
    - [X] Helper methods and modules
    - [ ] Aliasing - custom example group types with preset attributes
    - [X] Pending tests - `pending`
    - [ ] Shared examples - `behaves_like`, `include_examples`
- [ ] Matchers
    - [X] Equality matchers - `eq`, `be`, `be_a`, `match`
    - [ ] Truthy matchers - `be_true`, `be_false`, `be_truthy`, `be_falsey`
    - [ ] Comparison matchers - `<`, `<=`, `>`, `>=`, `be_within`
    - [ ] Question matchers - `be_nil`, `be_xxx`
    - [ ] Exception matchers - `raise_error`
    - [ ] Collection matchers - `start_with`, `end_with`, `contain`, `contain_exactly`
    - [ ] Change matchers - `change`, `from`, `to`, `by`, `by_at_least`, `by_at_most`
    - [ ] Satisfy matcher - `satisfy`
    - [ ] Yield matchers - `yield_control`, `times`, `yield_values`
    - [ ] Expectation combining with `&` and `|`
- [ ] Runner
    - [ ] Fail fast
    - [ ] Test filtering - by name, context, and tags
    - [ ] Fail on no tests
    - [ ] Randomize test order
    - [ ] Dry run - for validation and checking formatted output
    - [ ] Config block in `spec_helper.cr`
    - [ ] Config file - `.rspec`
- [ ] Reporter and formatting
    - [ ] RSpec/Crystal Spec default
    - [ ] JSON
    - [ ] JUnit

### How it Works

This shard makes extensive use of the Crystal macro system to build classes and modules.
Each `describe` and `context` block creates a new module nested in its parent.
The `it` block creates a class derived from an `Example` class.
An instance of the example class is created to run the test.
Each example class includes a context module, which contains all test values and hooks.

Contributing
------------

1. Fork it (<https://gitlab.com/arctic-fox/spectator/fork/new>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Merge Request

Contributors
------------

- [arctic-fox](https://gitlab.com/arctic-fox) Michael Miller - creator, maintainer
