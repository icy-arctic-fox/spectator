# Architecture and Design of Spectator

This document explains the structure and design decisions behind Spectator.
It is broken up into the logical components of Spectator:

- [Terms](#terms)
- [DSL](#dsl) - Domain Specific Language. Macros and methods that build a spec.
- [Matchers](#matchers)
- [Examples and groups](#examples-and-groups)
- [Runner and harness](#runner-and-harness)
  - [Hooks](#hooks)
- [Mocks and doubles](#mocks-and-doubles)
  - [Stubs](#stubs)
  - [Doubles](#doubles)
- [Formatting](#formatting)

## Terms

The following are terms and concepts frequently used in the project.
They are listed in alphabetical order,
but you may find it useful to jump around when learning what they mean.

**Assertion**

An *assertion* is a fundamental piece of a test.
It checks that a condition is satisfied.
If that condition isn't met, then an exception is raised.

**Builder**

A *builder* is a type that incrementally constructs a complex object.
Builders are primarily used to create *specs* and *example groups*.
See: https://sourcemaking.com/design_patterns/builder

**Config**

Short for *configuration*, a *config* stores information about how to run the *spec*.
The configuration includes parsed command-line options, settings from `.spectator` and `Spectator.configure`.

**Context**

A *context* is the scope or "environment" a test runs in.
It is a part of an *example group* that provides methods, memoized values, and more to an example block.
From a technical standpoint, it is typically an instance of the class defined by an `example_group` block.
It can thought of as a closure.

**Double**

Stand-in for another type.
*Doubles* can be passed to methods under test instead of a real object.
They can be configured to respond to methods with *stubs*.
*Doubles* also track calls made to them.
An important note: a *double* is _not_ the same type (nor does it inherit) the replaced type.

**DSL**

*DSL* stands for **D**omain **S**pecific **L**anguage.
It is the human-like language that comprises a *spec*.
Keywords in the *DSL*, such as `describe`, `it`, and `expect`, are macros or methods.
Those macros and methods make calls to Spectator to describe the structure of a *spec*.
They are combined in such a way that makes it easy to read.

**Example**

An *example* is essentially a *test* and metadata.
Spectator makes a distinction between *test* and *example*.
An *example* can have a description, *group*, *context*, *result*, and *tags*.
That is to say: an *example* is the *test* and information for execution.
An *example* is a type of *node*.

In the *DSL*, an *example* is created with `example` and `it` blocks and their variants.

**Example Group**

An *example group* (or *group* for short), is a collection of *examples*.
*Groups* can be nested in other *groups*, but can only have one parent.
*Groups* can have *hooks*.
*Groups* have extra properties like a name and metadata.
A *group* is a type of *node*.

In the *DSL*, an *example group* is created with `example_group`, `describe`, and `context` blocks and their variants.

**Expectation**

An *expectation* captures a value or behavior and whether it satisfies a condition.
*Expectations* contain *match data*.
They are bubbled up from the *harness* to the runner.
*Expectations* can be thought of as wrappers for *assertions*.

In the *DSL*, an *expectation* is the code: `expect(THIS).to eq(THAT)`
An *expectation target* is just the `expect(THIS)` portion.

**Formatter**

A *formatter* takes *results* and reports them to the user in a specific format.
Examples of *formatters* are XML, HTML, JSON, dots, and documentation.
The runner will call methods on the *formatter*.
The methods called depend on the type of *result* and the state of the runner.
For instance, `#example_started` is called before a an example runs,
and `#dump_summary` is called at the end when all *results* are available.

**Harness**

A *harness* is used to safely wrap *test* code.
It captures *expectations* and creates a *result* based on the outcome.

**Filter**

A *filter* selects *nodes* to be included in a running *spec*.
There are multiple types of *filters*.

**Hook**

A *hook* is a piece of code to execute at a key time.
For instance, before a *test* starts, or after everything in a *group* completes.
*Hooks* can be run in the same *context* as a *test*.
These are known as "example hooks."
*Hooks* that don't run in a *context*, and instead run independent of *examples*, are called "example group hooks."
*Hooks* are attached to *groups*.

**Label**

A *label* is a string from the *spec* that identifies a expression.
*Labels* are captured to improve the readability of *results* and *match data*.

In the following code, the labels are: `does something useful`, `the_answer`, and `42`.

```crystal
it "does something useful" do
  expect(the_answer).to eq(42)
end
```

**Matcher**

A *matcher* defines an expected value or behavior.
*Matchers* are given an "actual" value from a test and produce *match data*.
The *match data* contains information regarding whether the value or behavior was expected (satisfies a condition).
They behave similarly to an instance of a `Regex`.

In the following code, the `eq(42)` portion returns an instance of a *matcher* expecting the value 42.

```crystal
expect(the_answer).to eq(42)
```

**Match Data**

*Match data* is produced by *matchers*.
It contains information regarding whether an *expectation* is satisfied and values from the match.
The values are key-value pairs identifying things such as "expected value" and "actual value."
*Match data* is similar in concept to `Regex::MatchData`.

**Mock**

A *mock* is a type that can have its original functionality "swapped out" for a *stub*.
This allows complex types to be "mocked" so that other types can be unit tested.
*Mocks* can have any number of *stubs* defined.
They are similar to *doubles*, but use a real type.

**Node**

A *node* refers to any component in a *spec*.
*Nodes* are typically *examples* and *example groups*.
A *node* can have metadata associated with it, such as a *label*, location, and *tags*.

**Procsy**

A *procsy* is a glorified `Proc`.
It is used to wrap an underlying proc in some way.
Typically used to wrap an *example* when passed to a *hook*.

**Profile**

A *profile* includes timing information for *examples*.
It tracks how long each *example* took and sorts them.

**Report**

A *report* is a collection of *results* generated by running *examples*.
It provides easy access to various metrics and types of *results*.

**Result**

A *result* summarizes the outcome of running an *example*.
A *result* can be passing, failing, or pending.
*Results* contain timing information, *expectations* processed in the *example*, and an error for failing *results*.

**Spec**

A *spec* is a collection of *examples*.
Conceptually, a *spec* defines the behavior of a system.
A *spec* consists of a single, root *example group* that provides a tree structure of *examples*.
A *spec* also contains some *config* describing how to run it.

**Stub**

A *stub* is a method in a *double* or *mock* that replaces the original functionality.
*Stubs* can be attached to a single instance or all instances of a type.

**Tag**

A *tag* is an identifier with optional value.
*Tags* can be used to group and filter *examples* and *example groups*.
Some *tags* have special meaning, like `skip` indicating an *example* or *group* should be skipped.

**Test**

The word "test" is overused, especially when using a testing framework.
We make an effort to avoid using the word "test" for everything.
However, *test* has a technical meaning in Spectator.
It refers to the code (block) executed in an *example*.

```crystal
it "does a thing" do
  # Test code starts here. Everything inside this `it` block is considered a test.
  expect(the_answer).to eq(42)
  # Test code ends here.
end
```

## DSL

The DSL is made up of methods and macros.
What look like keywords (`describe`, `it`, `expect`, `eq`, etc.) are just macros and methods provided by the DSL.
Those macros and methods are defined in multiple modules in the `Spectator::DSL` namespace.
They are logically grouped by their functionality.

Each module is included (as a mix-in) to the base Spectator context that all tests use.
The `SpectatorTestContext` class includes all of the DSL modules.

The DSL methods and macros should be kept simple.
Their functionality should be off-loaded to internal Spectator "APIs."
For instance, when the DSL creates an example,
it defines a method for the test code and calls another method to register it.
While Crystal macros are powerful, excessive use of them makes maintenance harder and compilation slower.
Additionally, by keeping logic out of the DSL, testing of internals becomes less dependent on the DSL.

*TODO:* Builders...

*TODO:* Tricks...

## Matchers

*TODO:* Base types

## Examples and groups

*TODO*

## Runner and harness

*TODO*

### Hooks

*TODO*

## Mocks and doubles

*TODO*

### Stubs

*TODO*

### Doubles

*TODO*

## Formatting

*TODO*
