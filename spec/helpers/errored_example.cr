# Example that always raises an exception.
class ErroredExample < Spectator::RunnableExample
  # Dummy description.
  def what
    "ERROR"
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

  # Run the example that always produces an error.
  private def run_instance
    raise "Oops"
  end

  # Creates an errored example.
  def self.create
    hooks = Spectator::ExampleHooks.empty
    group = Spectator::RootExampleGroup.new(hooks)
    values = Spectator::Internals::SampleValues.empty
    new(group, values).tap do |example|
      group.children = [example.as(Spectator::ExampleComponent)]
    end
  end
end
