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

    def be_an(type : T.class) forall T
      be_a type
    end

    def be_base64
      raise NotImplementedError.new("be_base64")
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
      raise NotImplementedError.new("be_close_to")
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

    def be_hexadecimal
      raise NotImplementedError.new("be_hexadecimal")
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

    def be_timestamp(format)
      raise NotImplementedError.new("be_timestamp")
    end

    def be_true
      BeMatcher.new(true)
    end

    def be_truthy
      BeTruthyMatcher.new
    end

    def be_uuid(version = nil)
      raise NotImplementedError.new("be_uuid")
    end

    def be_within(delta) # of(expected)
      raise NotImplementedError.new("be_within")
    end

    def be_within(range : Range)
      be_in range
    end

    def be_zero
      BeZeroMatcher.new
    end

    def change(&subject : -> _)
      ChangeMatcher.new(subject)
    end

    def contain(*expected)
      ContainMatcher.new(expected)
    end

    def contain_exactly(*values)
      raise NotImplementedError.new("contain_exactly")
    end

    def cover(*value)
      raise NotImplementedError.new("cover")
    end

    def decrease(& : -> _)
      raise NotImplementedError.new("decrease")
    end

    def end_with(expected)
      raise NotImplementedError.new("end_with")
    end

    def eq(value)
      EqualMatcher.new(value)
    end

    def equal(value)
      eq value
    end

    def expect_raises(error : T.class = Exception, message : String | Regex? = nil, &block) forall T
      expect(&block).to raise_error(error, message)
    end

    def expect_raises(error : Exception, &block)
      expect(&block).to raise_error(error)
    end

    def expect_raises(message : String | Regex, &block)
      expect(&block).to raise_error(message)
    end

    def have_attributes(**attributes)
      raise NotImplementedError.new("have_attributes")
    end

    def have_index(value : Int)
      raise NotImplementedError.new("have_index")
    end

    def have_indexes(*values : Int)
      raise NotImplementedError.new("have_indexes")
    end

    def have_key(value : T) forall T
      raise NotImplementedError.new("have_key")
    end

    def have_keys(*values : T) forall T
      raise NotImplementedError.new("have_keys")
    end

    def have_size(value)
      raise NotImplementedError.new("have_size")
    end

    def have_value(value : T) forall T
      raise NotImplementedError.new("have_value")
    end

    def have_values(*values : T) forall T
      raise NotImplementedError.new("have_values")
    end

    def increase(& : -> _)
      raise NotImplementedError.new("increase")
    end

    def match(value)
      MatchMatcher.new(value)
    end

    def match_array(array)
      raise NotImplementedError.new("match_array")
    end

    def match_size_of(value)
      raise NotImplementedError.new("match_size_of")
    end

    def output(value = nil) # to_stdout/to_stderr
      raise NotImplementedError.new("output")
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
      raise NotImplementedError.new("start_with")
    end
  end
end

# TODO: Is it possible to move this out of the global namespace?
include Spectator::Matchers::BuiltIn::Methods
