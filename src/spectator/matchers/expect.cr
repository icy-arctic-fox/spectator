require "../core/location_range"
require "./matcher"
require "./built_in/raise_error_matcher"

module Spectator::Matchers
  struct Expect(T)
    def initialize(@actual_value : T)
    end

    def to(matcher, failure_message : String? = nil, *,
           source_file = __FILE__,
           source_line = __LINE__,
           source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure = Matcher.process(matcher, @actual_value,
        failure_message: failure_message,
        location: location)
      raise failure if failure
    end

    def not_to(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure = Matcher.process_negated(matcher, @actual_value,
        failure_message: failure_message,
        location: location)
      raise failure if failure
    end

    def to_not(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
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
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure = Matcher.process_block(matcher, @block,
        failure_message: failure_message,
        location: location)
      raise failure if failure
    end

    def to(matcher : BuiltIn::RaiseErrorMatcher, failure_message : String? = nil, *,
           source_file = __FILE__,
           source_line = __LINE__,
           source_end_line = __END_LINE__) : Exception
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure = Matcher.process_block(matcher, @block,
        failure_message: failure_message,
        location: location)
      raise failure if failure
      matcher.rescued_error
    end

    def not_to(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure = Matcher.process_block_negated(matcher, @block,
        failure_message: failure_message,
        location: location)
      raise failure if failure
    end

    def to_not(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
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
