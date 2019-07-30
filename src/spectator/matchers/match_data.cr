require "./match_data_labeled_value"

module Spectator::Matchers
  # Result of evaluating a matcher on an expectation partial.
  #
  # Procs are used to "store references" to the information.
  # Most of the time, the information in this struct is unused.
  # To reduce unecessary overhead and memory usage,
  # the values are constructed lazily, on-demand when needed.
  struct MatchData
    # Indicates whether the matcher was satisified with the expectation partial.
    getter? matched : Bool

    # Extra information about the match that is shown in the result output.
    getter values : Array(MatchDataLabeledValue)

    # Creates the match data.
    #
    # The *matched* argument indicates
    # whether the matcher was satisified with the expectation partial.
    # The *expected* and *actual* procs are what was expected to happen
    # and what actually happened.
    # They should write a string to the given IO.
    # The *values* are extra information about the match,
    # that is shown in the result output.
    def initialize(@matched, @expected : IO -> , @actual : IO -> , @values)
    end

    # Description of what should have happened and would satisfy the matcher.
    # This is informational and displayed to the end-user.
    def expected
      @expected.call
    end

    # Description of what actually happened.
    # This is informational and displayed to the end-user.
    def actual
      @actual.call
    end
  end
end
