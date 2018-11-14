# Example that always succeeds.
class PassingExample < Spectator::RunnableExample
  # Dummy description.
  def what
    "PASS"
  end

  # Run the example that always passes.
  # If this doesn't something broke.
  private def run_instance
    report_expectations(1, 0)
  end

  # Creates a passing example.
  def self.create
    hooks = Spectator::ExampleHooks.empty
    group = Spectator::RootExampleGroup.new(hooks)
    values = Spectator::Internals::SampleValues.empty
    new(group, values).tap do |example|
      group.children = [example.as(Spectator::ExampleComponent)]
    end
  end
end
