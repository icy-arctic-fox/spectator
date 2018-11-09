# Example system to test that doubles as a spy.
# This class tracks calls made to it.
class SpySUT
  # Number of times the `#==` method was called.
  getter eq_call_count = 0

  # Returns true and increments `#eq_call_count`.
  def ==(other : T) forall T
    @eq_call_count += 1
    true
  end
end

# Example that always succeeds.
class PassingExample < Spectator::RunnableExample
  # Dummy description.
  def what
    "PASS"
  end

  # Run the example that always passes.
  # If this doesn't something broke.
  private def run_instance
    report_results(1, 0)
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
