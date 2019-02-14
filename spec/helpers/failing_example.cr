# Example that always fails.
class FailingExample < Spectator::RunnableExample
  # Dummy description.
  def what
    "FAIL"
  end

  # Dummy source file.
  def source_file
    __FILE__
  end

  # Dummy source line number.
  def source_line
    __LINE__
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
    conditions = Spectator::ExampleConditions.empty
    group = Spectator::RootExampleGroup.new(hooks, conditions)
    values = Spectator::Internals::SampleValues.empty
    new(group, values).tap do |example|
      group.children = [example.as(Spectator::ExampleComponent)]
    end
  end
end
