require "./built_in/*"
require "./negated"

module Spectator::Matchers::BuiltIn
  module Methods
    def all(matcher)
      AllMatcher.new(matcher)
    end

    def be
      CompareMatcher
    end

    def be(expected)
      BeMatcher.new(expected)
    end

    def be_a(type : T.class) forall T
      BeAMatcher(T).new
    end

    def be_a(type : Enumerable.class)
    end

    def be_a(type : Array.class)
    end

    def be_after(time : Time)
    end

    def be_after_or_equal(time : Time)
    end

    def be_an(type : T.class) forall T
      be_a type
    end

    def be_before(time : Time)
    end

    def be_before_or_equal(time : Time)
    end

    def be_between(min, max)
      BeBetweenMatcher.new(min, max)
    end

    def be_blank
      BeBlankMatcher.new
    end

    def be_close(expected, delta)
      BeCloseMatcher.new(expected, delta)
    end

    def be_close_to(expected, digits)
    end

    def be_empty
      BeEmptyMatcher.new
    end

    def be_false
      be false
    end

    def be_falsy
      NegatedMatcher.new(be_truthy)
    end

    def be_falsey
      be_falsy
    end

    def be_finite
      NegatedMatcher.new(be_infinite)
    end

    def be_in(range_or_set)
      BeInMatcher.new(range_or_set)
    end

    def be_infinite
      BeInfiniteMatcher.new
    end

    def be_instance_of(type : T.class) forall T
      BeInstanceOfMatcher(T).new
    end

    def be_a_instance_of(type)
      be_instance_of type
    end

    def be_an_instance_of(type)
      be_instance_of type
    end

    def be_hexadecimal
    end

    def be_nan
      BeNaNMatcher.new
    end

    def be_negative
      BeNegativeMatcher.new
    end

    def be_nil
      BeNilMatcher.new
    end

    def be_one_of(*values)
      BeOneOfMatcher.new(values)
    end

    def be_positive
      BePositiveMatcher.new
    end

    def be_present
      BePresentMatcher.new
    end

    def be_true
      BeMatcher.new(true)
    end

    def be_truthy
      BeTruthyMatcher.new
    end

    def be_within(delta) # of(expected)
    end

    def be_within(range : Range)
      be_in range
    end

    def be_zero
      BeZeroMatcher.new
    end

    def change(&) # by(change) / from(from) / to(to)
    end

    def contain(*expected)
      ContainMatcher.new(expected)
    end

    def contain_exactly(*values)
    end

    def cover(*value)
    end

    def end_with(expected)
    end

    def eq(value)
      EqualMatcher.new(value)
    end

    def equal(value)
      eq value
    end

    def expect_raises
    end

    def have_attributes(**attributes)
    end

    def have_index(value : Int)
    end

    def have_indexes(*values : Int)
    end

    def have_key(value : T) forall T
    end

    def have_keys(*values : T) forall T
    end

    def have_size(value)
    end

    def have_value(value : T) forall T
    end

    def have_values(*values : T) forall T
    end

    def match(value)
      MatchMatcher.new(value)
    end

    def match_array(array)
    end

    def match_size_of(value)
    end

    def raise_error(error : T.class = Exception, message : String | Regex? = nil) forall T
      RaiseErrorMatcher(T).new(message)
    end

    def raise_error(error : Exception)
      RaiseErrorMatcher.new(error)
    end

    def raise_error(message : String | Regex)
      RaiseErrorMatcher(Exception).new(message)
    end

    macro respond_to(method)
      {% if method.is_a?(SymbolLiteral) || method.is_a?(StringLiteral) %}
        RespondToMatcher({ {{method.id.stringify}}: Nil }).new
      {% else %}
        {% raise "The `respond_to` matcher must be given a symbol or string literal" %}
      {% end %}
    end

    def start_with(expected)
    end
  end
end

# TODO: Is it possible to move this out of the global namespace?
include Spectator::Matchers::BuiltIn::Methods
