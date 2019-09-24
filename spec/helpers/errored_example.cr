# Example that always raises an exception.
class ErroredExample < Spectator::RunnableExample
  # Dummy description.
  def what : Symbol | String
    "ERROR"
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
