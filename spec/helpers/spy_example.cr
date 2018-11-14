# Example that invokes a closure when it is run.
# This is useful for capturing what's going on when an event is running.
class SpyExample < Spectator::RunnableExample
  # Dummy description.
  def what
    "SPY"
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
  def self.create(&block)
    hooks = Spectator::ExampleHooks.empty
    group = Spectator::RootExampleGroup.new(hooks)
    values = Spectator::Internals::SampleValues.empty
    new(group, values).tap do |example|
      group.children = [example.as(Spectator::ExampleComponent)]
      example.block = block
    end
  end
end
