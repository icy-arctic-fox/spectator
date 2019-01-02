# Example that always fails.
class FailingExample < Spectator::RunnableExample
  # Dummy description.
  def what
    "FAIL"
  end

  # Dummy instance.
  def instance
    nil
  end

  # Run the example that always fails.
  private def run_instance
    report_expectations(0, 1)
  end

  # Creates a failing example.
  def self.create
    hooks = Spectator::ExampleHooks.empty
    group = Spectator::RootExampleGroup.new(hooks)
    values = Spectator::Internals::SampleValues.empty
    new(group, values).tap do |example|
      group.children = [example.as(Spectator::ExampleComponent)]
    end
  end
end
