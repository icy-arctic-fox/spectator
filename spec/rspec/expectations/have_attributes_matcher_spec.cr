require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/have-attributes-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`have_attributes` matcher" do
  context "basic usage" do
    # Use `record` instead of `Struct.new`.
    record Person, name : String, age : Int32

    describe Person.new("Jim", 32) do
      # Changed some syntax for Ruby hashes to Crystal named tuples.

      # Spectator doesn't support helper matchers like `a_string_starting_with` and `a_value <`.
      # But maybe in the future it will.
      it { is_expected.to have_attributes(name: "Jim") }
      skip reason: "Add support for fuzzy matchers." { is_expected.to have_attributes(name: a_string_starting_with("J")) }
      it { is_expected.to have_attributes(age: 32) }
      skip reason: "Add support for fuzzy matchers." { is_expected.to have_attributes(age: (a_value > 30)) }
      it { is_expected.to have_attributes(name: "Jim", age: 32) }
      skip reason: "Add support for fuzzy matchers." { is_expected.to have_attributes(name: a_string_starting_with("J"), age: (a_value > 30)) }
      it { is_expected.not_to have_attributes(name: "Bob") }
      it { is_expected.not_to have_attributes(age: 10) }
      skip reason: "Add support for fuzzy matchers." { is_expected.not_to have_attributes(age: (a_value < 30)) }

      # deliberate failures
      it_fails { is_expected.to have_attributes(name: "Bob") }
      it_fails { is_expected.to have_attributes(name: 10) }

      # fails if any of the attributes don't match
      it_fails { is_expected.to have_attributes(name: "Bob", age: 32) }
      it_fails { is_expected.to have_attributes(name: "Jim", age: 10) }
      it_fails { is_expected.to have_attributes(name: "Bob", age: 10) }
    end
  end
end
