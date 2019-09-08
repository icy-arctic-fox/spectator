require "./example_component"

module Spectator
  # Base class for all types of examples.
  # Concrete types must implement the `#run_impl` method.
  abstract class Example < ExampleComponent
    # Indicates whether the example has already been run.
    getter? finished = false

    # Group that the example belongs to.
    getter group : ExampleGroup

    # Retrieves the internal wrapped instance.
    private getter @test_wrapper : TestWrapper

    # Source where the example originated from.
    def source
      @test_wrapper.source
    end

    def what
      @test_wrapper.description
    end

    # Runs the example code.
    # A result is returned, which represents the outcome of the test.
    # An example can be run only once.
    # An exception is raised if an attempt is made to run it more than once.
    def run : Result
      raise "Attempted to run example more than once (#{self})" if finished?
      run_impl
    ensure
      @finished = true
    end

    # Implementation-specific for running the example code.
    private abstract def run_impl : Result

    # Creates the base of the example.
    # The group should be the example group the example belongs to.
    def initialize(@group, @test_wrapper)
    end

    # Indicates there is only one example to run.
    def example_count
      1
    end

    # Retrieve the current example.
    def [](index : Int)
      self
    end

    # String representation of the example.
    # This consists of the groups the example is in and the description.
    # The string can be given to end-users to identify the example.
    def to_s(io)
      @group.to_s(io)
      io << ' ' unless symbolic? && @group.symbolic?
      io << what
    end

    # Creates the JSON representation of the example,
    # which is just its name.
    def to_json(json : ::JSON::Builder)
      json.string(to_s)
    end
  end
end
