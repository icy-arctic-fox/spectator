# Example that invokes a closure when it is run.
# This is useful for capturing what's going on when an event is running.
class SpyExample < Spectator::RunnableExample
  # Dummy description.
  def what : Symbol | String
    "SPY"
  end

  # Dummy source.
  def source : ::Spectator::Source
    ::Spectator::Source.new(__FILE__, __LINE__)
  end

  # Dummy symbolic flag.
  def symbolic? : Bool
    false
  end

  # Dummy instance.
  def instance
    nil
  end

  # Captures the sample values when the example is created.
  def initialize(group, @sample_values)
    super(group, @sample_values)
  end

  # Sample values given to the example.
  getter sample_values : Spectator::Internals::SampleValues

  # Harness that was used while running the example.
  getter! harness : Spectator::Internals::Harness

  setter block : Proc(Nil)? = nil

  # Method called by the framework to run the example code.
  private def run_instance
    @harness = Spectator::Internals::Harness.current
    if block = @block
      block.call
    end
  end

  # Creates a spy example.
  # The block passed to this method will be executed when the example runs.
  def self.create(hooks = Spectator::ExampleHooks.empty, conditions = Spectator::ExampleConditions.empty, &block)
    group = Spectator::RootExampleGroup.new(hooks, conditions)
    values = Spectator::Internals::SampleValues.empty
    new(group, values).tap do |example|
      group.children = [example.as(Spectator::ExampleComponent)]
      example.block = block
    end
  end

  # Creates a group of spy examples.
  # Specify the number of examplese to create and a block to invoke when the example is run.
  # The block is given the index of the example in the group.
  def self.create_group(count, &block : Int32 -> Nil)
    values = Spectator::Internals::SampleValues.empty
    Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |group|
      group.children = Array.new(count) do |index|
        new(group, values).tap do |example|
          example.block = block.partial(index)
        end.as(Spectator::ExampleComponent)
      end
    end
  end
end
