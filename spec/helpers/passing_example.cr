# Example that always succeeds.
class PassingExample < Spectator::RunnableExample
  # Creates the example.
  def initialize(group, values, @symbolic = false)
    super(group, values)
  end

  # Dummy description.
  def what : Symbol | String
    "PASS"
  end

  # Dummy source.
  def source : ::Spectator::Source
    ::Spectator::Source.new(__FILE__, __LINE__)
  end

  # Dummy symbolic flag.
  def symbolic? : Bool
    @symbolic
  end

  # Dummy instance.
  def instance
    nil
  end

  # Run the example that always passes.
  # If this doesn't something broke.
  private def run_instance
    report_expectations(1, 0)
  end

  # Creates a passing example.
  def self.create(hooks = Spectator::ExampleHooks.empty, conditions = Spectator::ExampleConditions.empty)
    group = Spectator::RootExampleGroup.new(hooks, conditions)
    values = Spectator::Internals::SampleValues.empty
    new(group, values).tap do |example|
      group.children = [example.as(Spectator::ExampleComponent)]
    end
  end
end
