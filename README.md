Spectator
=========

Spectator is a fully-featured spec-based test framework for Crystal.
It mimics features from [RSpec](http://rspec.info/).
Developers coming from Ruby and RSpec will feel right at home.
Spectator provides additional functionality to make testing easier and more fluent.

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
    version: ~> 0.12.0
```

Usage
-----

If it doesn't exist already, create a `spec/spec_helper.cr` file.
In it, place the following:

```crystal
require "../src/*"
require "spectator"
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
The goal is to make it as easy as possible to write specs and keep your code clean.
We may come up with a solution or even introduce a feature to support your needs.

**NOTE:** Due to the way this shard uses macros,
you may find that some code you would expect to work, or works in other spec libraries, creates syntax errors.
If you run into this, please create an issue so that we may try to resolve it.

Features
--------

Spectator has all of the basic functionality for BDD.
For full documentation on what it can do, please visit the [wiki](https://gitlab.com/arctic-fox/spectator/wikis/home).

### Contexts

The DSL supports arbitrarily nested contexts.
Contexts can have values defined for multiple tests (`let` and `subject`).
Additionally, hooks can be used to ensure any initialization or cleanup is done (`before`, `after`, and `around`).
Pre- and post-conditions can be used to ensure code contracts are kept.

```crystal
# Initialize the database before running the tests in this context.
before_all { Database.init }

# Teardown the database and cleanup after tests in the is context finish.
after_all { Database.cleanup }

# Before each test, add some rows to the database.
let(row_count) { 5 }
before_each do
  row_count.times { Database.insert_row }
end

# Remove the rows after the test to get a clean slate.
after_each { Database.clear }

describe "#row_count" do
  it "returns the number of rows" do
    expect(Database.row_count).to eq(row_count)
  end
end
```

Spectator has different types of contexts to reduce boilerplate.
One is the `sample` context.
This context type repeats all tests (and contexts within) for a set of values.
For instance, some feature should behave the same for different input.
However, some inputs might cause problems, but should behave the same.
An example is various strings (empty strings, quoted strings, strings with non-ASCII, etc),
and numbers (positive, negative, zero, NaN, infinity).

```crystal
# List of integers to test against.
def various_integers
  [-7, -1, 0, 1, 42]
end

# Repeat nested tests for every value in `#various_integers`.
sample various_integers do |int|
  # Example that checks if a fictitious method `#format` converts to strings.
  it "formats correctly" do
    expect(format(int)).to eq(int.to_s)
  end
end
```

Another context type is `provided`.
This context drastically reduces the amount of code needed in some scenarios.
It can be used where one (or more inputs) changes the output of multiple methods.
The `provided` context gives a concise syntax for this use case.

```crystal
subject(user) { User.new(age) }

# Each expression in the `provided` block is its own test.
provided age = 10 do
  expect(user.can_drive?).to be_false
  expect(user.can_vote?).to be_false
end

provided age = 16 do
  expect(user.can_drive?).to be_true
  expect(user.can_vote?).to be_false
end

provided age = 18 do
  expect(user.can_drive?).to be_true
  expect(user.can_vote?).to be_true
end
```

### Assertions

Spectator supports two formats for assertions (expectations).
The preferred format is the "expect syntax".
This takes the form:

```crystal
expect(THIS).to eq(THAT)
```

The other format, "should syntax" is used by Crystal's default Spec.

```
THIS.should eq(THAT)
```

The first format doesn't monkey-patch the `Object` type.
And as a bonus, it captures the expression or variable passed to `expect()`.
For instance, compare these two tests:

```crystal
foo = "Hello world"
foo.size.should eq(12) # Wrong on purpose!
```

Produces this error output:

```text
Failure: 11 does not equal 12

  expected: 11
    actual: 12
```

Which is reasonable, but where did 11 come from?
Alternatively, with the "expect syntax":

```crystal
foo = "Hello world"
expect(foo.size).to eq(12) # Wrong on purpose!
```

Produces this error output:

```text
Failure: foo.size does not equal 12

  expected: 12
    actual: 11
```

This makes it clearer what was being tested and failed.

### Matchers

Spectator has a variety of matchers for assertions.
These are named in such a way to help tests read as plain English.
Matchers can be used on any value or block.

There are typical matchers for testing equality: `eq` and `ne`.
And matchers for comparison: `<`, `<=`, `>`, `>=`, `be_within`.
There are matchers for checking contents of collections:
`contain`, `have`, `start_with`, `end_with`, `be_empty`, `have_key`, and more.
See the [wiki](https://gitlab.com/arctic-fox/spectator/wikis/Matchers) for a full list of matchers.

### Running

Spectator supports multiple options for running tests.
"Fail fast" aborts on the first test failure.
"Fail blank" fails if there are no tests.
Tests can be filtered by their location and name.
Additionally, tests can be randomized.
Spectator can be configured with command-line arguments,
a configure block in a `spec_helper.cr` file, and `.spectator` configuration file.

```crystal
Spectator.configure do |config|
  config.fail_blank # Fail on no tests.
  config.randomize  # Randomize test order.
  config.profile    # Display slowest tests.
end
```

### Mocks and Doubles

Spectator supports an extensive mocking feature set via two types - mocks and doubles.
Mocks are used to override behavior in existing types.
Doubles are objects that stand-in when there are no type restrictions.
Stubs can be defined on both which control how methods behave.

```crystal
abstract class Interface
  abstract def invoke(thing) : String
end

# Type being tested.
class Driver
  def do_something(interface : Interface, thing)
    interface.invoke(thing)
  end
end

Spectator.describe Driver do
  # Define a mock for Interface.
  mock Interface

  # Define a double that the interface will use.
  double(:my_double, foo: 42)

  it "does a thing" do
    # Create an instance of the mock interface.
    interface = mock(Interface)
    # Indicate that `#invoke` should return "test" when called.
    allow(interface).to receive(:invoke).and_return("test")

    # Create an instance of the double.
    dbl = double(:my_double)
    # Call the mock method.
    subject.do_something(interface, dbl)
    # Verify everything went okay.
    expect(interface).to have_received(:invoke).with(dbl)
  end
end
```

For details on mocks and doubles, see the [wiki](https://gitlab.com/arctic-fox/spectator/-/wikis/Mocks-and-Doubles).

### Output

Spectator matches Crystal's default Spec output with some minor changes.
JUnit and TAP are also supported output formats.
There are also highly detailed JSON and HTML outputs.

Development
-----------

This shard is still in active development.
New features are being added and existing functionality improved.
Spectator is well-tested, but may have some yet-to-be-found bugs.

### Feature Progress

In no particular order, features that have been implemented and are planned.
Items not marked as completed may have partial implementations.

- [ ] DSL
    - [X] `describe` and `context` blocks
    - [X] Contextual values with `let`, `let!`, `subject`, `described_class`
    - [X] Test multiple and generated values - `sample`, `random_sample`
    - [X] Concise syntax - `provided` (was the now deprecated `given`)
    - [X] Before and after hooks - `before_each`, `before_all`, `after_each`, `after_all`, `around_each`
    - [X] Pre- and post-conditions - `pre_condition`, `post_condition`
    - [ ] Other hooks - `on_success`, `on_failure`, `on_error`
    - [X] One-liner syntax
    - [X] Should syntax - `should`, `should_not`
    - [X] Helper methods and modules
    - [ ] Aliasing - custom example group types with preset attributes
    - [X] Pending tests - `pending`
    - [ ] Shared examples - `behaves_like`, `include_examples`
    - [X] Deferred expectations - `to_eventually`, `to_never`
- [ ] Matchers
    - [X] Equality matchers - `eq`, `ne`, `be ==`, `be !=`
    - [X] Comparison matchers - `be <`, `be <=`, `be >`, `be >=`, `be_within[.of]`, `be_close`
    - [X] Type matchers - `be_a`, `respond_to`
    - [ ] Collection matchers
      - [X] `contain`
      - [X] `have`
      - [X] `contain_exactly`
      - [X] `contain_exactly.in_any_order`
      - [X] `match_array`
      - [X] `match_array.in_any_order`
      - [X] `start_with`
      - [X] `end_with`
      - [X] `be_empty`
      - [X] `have_key`
      - [X] `have_value`
      - [X] `all`
      - [ ] `all_satisfy`
    - [X] Truthy matchers - `be`, `be_true`, `be_truthy`, `be_false`, `be_falsey`, `be_nil`
    - [X] Error matchers - `raise_error`
    - [ ] Yield matchers - `yield_control[.times]`, `yield_with_args[.times]`, `yield_with_no_args[.times]`, `yield_successive_args`
    - [ ] Output matchers - `output[.to_stdout|.to_stderr]`
    - [X] Predicate matchers - `be_x`, `have_x`
    - [ ] Misc. matchers
      - [X] `match`
      - [ ] `satisfy`
      - [X] `change[.by|.from[.to]|.to|.by_at_least|.by_at_most]`
      - [X] `have_attributes`
    - [ ] Compound - `and`, `or`
- [ ] Mocks and Doubles
    - [X] Mocks (Stub real types) - `mock TYPE { }`
    - [X] Doubles (Stand-ins for real types) - `double NAME { }`
    - [X] Method stubs - `allow().to receive()`, `allow().to receive().and_return()`
    - [X] Spies - `expect().to have_received()`
    - [X] Message expectations - `expect().to have_received().at_least()`
    - [X] Argument expectations - `expect().to have_received().with()`
    - [ ] Message ordering - `expect().to have_received().ordered`
    - [X] Null doubles
- [X] Runner
    - [X] Fail fast
    - [X] Test filtering - by name, context, and tags
    - [X] Fail on no tests
    - [X] Randomize test order
    - [X] Dry run - for validation and checking formatted output
    - [X] Config block in `spec_helper.cr`
    - [X] Config file - `.spectator`
- [X] Reporter and formatting
    - [X] RSpec/Crystal Spec default
    - [X] JSON
    - [X] JUnit
    - [X] TAP
    - [X] HTML

### How it Works (in a nutshell)

This shard makes extensive use of the Crystal macro system to build classes and modules.
Each `describe` and `context` block creates a new class that inherits its parent.
The `it` block creates an method.
An instance of the group class is created to run the test.
Each group class includes all test values and hooks.

Contributing
------------

1. Fork it (GitHub <https://github.com/icy-arctic-fox/spectator/fork> or GitLab <https://gitlab.com/arctic-fox/spectator/fork/new>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull/Merge Request

Please make sure to run `crystal tool format` before submitting.
The CI build checks for properly formatted code.
[Ameba](https://crystal-ameba.github.io/) is run to check for code style.

Documentation is automatically generated and published to GitLab pages.
It can be found here: https://arctic-fox.gitlab.io/spectator

This project's home is (and primarily developed) on [GitLab](https://gitlab.com/arctic-fox/spectator).
A mirror is maintained to [GitHub](https://github.com/icy-arctic-fox/spectator).
Issues, pull requests (merge requests), and discussion are welcome on both.
Maintainers will ensure your contributions make it in.

For more information, see: [CONTRIBUTING.md](CONTRIBUTING.md)

### Testing

Tests must be written for any new functionality.

The `spec/` directory contains feature tests as well as unit tests.
These demonstrate small bits of functionality.
The feature tests are grouped into sub directories based on their type, they are:

- docs/ - Example snippets from Spectator's documentation.
- rspec/ - Examples from RSpec's documentation modified slightly to work with Spectator.
  See: https://relishapp.com/rspec/
  Additional sub directories in this directory represent the modules/projects of RSpec.

The other directories are for unit testing various parts of Spectator.
