module Spectator
  # Base class for all types of examples.
  # Concrete types must implement the `#run_inner` and `#description` methods.
  abstract class Example
    # Indicates whether the example has already been run.
    getter? finished = false

    # Group that the example belongs to.
    getter group : ExampleGroup

    # Runs the example code.
    # A result is returned, which represents the outcome of the test.
    # An example can be run only once.
    # An exception is raised if an attempt is made to run it more than once.
    def run : Result
      raise "Attempted to run example more than once (#{self})" if finished?
      @finished = true
      run_inner
    end

    # Implementation-specific for running the example code.
    private abstract def run_inner : Result

    # Message that describes what the example tests.
    abstract def description : String

    # Creates the base of the example.
    # The group should be the example group the example belongs to.
    # The `sample_values` are passed to the example code.
    def initialize(@group, sample_values : Internals::SampleValues)
    end

    # String representation of the example.
    # This consists of the groups the example is in and the description.
    # The string can be given to end-users to identify the example.
    def to_s(io)
      @group.to_s(io)
      io << ' '
      io << description
    end
  end
end
