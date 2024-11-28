require "../core/location_range"
require "./matcher"
require "./built_in/be_a_matcher"
require "./built_in/raise_error_matcher"

module Spectator::Matchers
  struct Expect(T)
    def initialize(@actual_value : T)
    end

    def to(matcher, failure_message : String? = nil, *,
           source_file = __FILE__,
           source_line = __LINE__,
           source_end_line = __END_LINE__) : Nil
      return unless failure = Matcher.match(matcher, @actual_value, failure_message)
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure.raise(location)
    end

    def to(matcher : BuiltIn::BeAMatcher(U), failure_message : String? = nil, *,
           source_file = __FILE__,
           source_line = __LINE__,
           source_end_line = __END_LINE__) : U forall U
      if failure = Matcher.match(matcher, @actual_value, failure_message)
        location = Core::LocationRange.new(source_file, source_line, source_end_line)
        failure.raise(location)
      else
        actual_value = @actual_value
        return actual_value if actual_value.is_a?(U)
        raise FrameworkError.new("Bug: Expected #{@actual_value} to be a #{U}")
      end
    end

    def not_to(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      return unless failure = Matcher.match_negated(matcher, @actual_value, failure_message)
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure.raise(location)
    end

    def not_to(matcher : BuiltIn::BeNilMatcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__)
      if failure = Matcher.match_negated(matcher, @actual_value, failure_message)
        location = Core::LocationRange.new(source_file, source_line, source_end_line)
        failure.raise(location)
      end
      @actual_value.not_nil!("Bug: Expected #{@actual_value} to not be nil")
    end

    def to_not(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__)
      not_to(matcher, failure_message,
        source_file: source_file,
        source_line: source_line,
        source_end_line: source_end_line)
    end
  end

  struct BlockExpectation(T)
    def initialize(@block : -> T)
    end

    def to(matcher, failure_message : String? = nil, *,
           source_file = __FILE__,
           source_line = __LINE__,
           source_end_line = __END_LINE__) : Nil
      return unless failure = Matcher.match_block(matcher, @block, failure_message)
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure.raise(location)
    end

    def to(matcher : BuiltIn::RaiseErrorMatcher, failure_message : String? = nil, *,
           source_file = __FILE__,
           source_line = __LINE__,
           source_end_line = __END_LINE__) : Exception
      if failure = Matcher.match_block(matcher, @block, failure_message)
        location = Core::LocationRange.new(source_file, source_line, source_end_line)
        failure.raise(location)
      end
      matcher.rescued_error.not_nil!("Bug: Rescued error should have been captured by matcher")
    end

    def not_to(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      return unless failure = Matcher.match_negated_block(matcher, @block, failure_message)
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure.raise(location)
    end

    def to_not(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__)
      not_to(matcher, failure_message,
        source_file: source_file,
        source_line: source_line,
        source_end_line: source_end_line)
    end
  end

  module ExpectMethods
    def expect(actual_value : T) : Expect(T) forall T
      Expect(T).new(actual_value)
    end

    def expect(&block : -> T) : BlockExpectation(T) forall T
      BlockExpectation(T).new(block)
    end
  end
end

# TODO: Is it possible to move this out of the global namespace?
include Spectator::Matchers::ExpectMethods
