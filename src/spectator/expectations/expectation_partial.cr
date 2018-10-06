module Spectator::Expectations
  # Base class for all expectation partials.
  # An "expectation partial" stores part of an expectation (obviously).
  # The part of the expectation this class covers is the actual value.
  # This can also cover a block's behavior.
  # Sub-types of this class are returned by the `DSL::ExampleDSL.expect` call.
  abstract struct ExpectationPartial
    # User-friendly string displayed for the actual expression being tested.
    # For instance, in the expectation:
    # ```
    # expect(foo).to eq(bar)
    # ```
    # This property will be "foo".
    # It will be the literal string "foo",
    # and not the actual value of the foo.
    getter label : String

    # Creates the base of the partial.
    private def initialize(@label)
    end
  end
end
