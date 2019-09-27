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
        [] of TestMetaMethod,
        [] of TestMetaMethod
      )
    end

    # Creates a new set of conditions.
    def initialize(
      @pre_conditions : Array(TestMetaMethod),
      @post_conditions : Array(TestMetaMethod)
    )
    end

    # Runs all pre-condition checks.
    # These should be run before every test.
    def run_pre_conditions(wrapper : TestWrapper, example : Example)
      @pre_conditions.each do |hook|
        wrapper.call(hook, example)
      end
    end

    # Runs all post-condition checks.
    # These should be run after every test.
    def run_post_conditions(wrapper : TestWrapper, example : Example)
      @post_conditions.each do |hook|
        wrapper.call(hook, example)
      end
    end
  end
end
