# Example that always succeeds.
class PassingExample < Spectator::RunnableExample
  # Dummy description.
  def what
    "PASS"
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

  # Run the example that always passes.
  # If this doesn't something broke.
  private def run_instance
    report_expectations(1, 0)
  end

  # Creates a passing example.
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
