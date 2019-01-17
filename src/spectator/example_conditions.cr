module Spectator
  # Collection of checks that run before and after tests.
  # The pre-conditions can be used to verify
  # that the SUT is in an expected state prior to testing.
  # The post-conditions can be used to verify
  # that the SUT is in an expected state after tests have finished.
  # Each check is just a `Proc` (code block) that runs when invoked.
  class ExampleConditions
    # Creates an empty set of conditions.
    # This will effectively run nothing extra while running a test.
    def self.empty
      new(
        [] of ->,
        [] of ->
      )
    end

    # Creates a new set of conditions.
    def initialize(
      @pre_conditions : Array(->),
      @post_conditions : Array(->)
    )
    end

    # Runs all pre-condition checks.
    # These should be run before every test.
    def run_pre_conditions
      @pre_conditions.each &.call
    end

    # Runs all post-condition checks.
    # These should be run after every test.
    def run_post_conditions
      @post_conditions.each &.call
    end
  end
end
