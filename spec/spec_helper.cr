require "spec"
require "../src/spectator"
require "./expectations_helper"

# Prevent Spectator from trying to run tests.
Spectator.autorun = false

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

# Example that always fails.
class FailingExample < Spectator::RunnableExample
  # Dummy description.
  def what
    "FAIL"
  end

  # Run the example that always fails.
  private def run_instance
    report_results(0, 1)
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

# Example that invokes a closure when it is run.
# This is useful for capturing what's going on when an event is running.
class SpyExample < Spectator::RunnableExample
  # Dummy description.
  def what
    "SPY"
  end

  setter block : Proc(Nil)? = nil

  # Method called by the framework to run the example code.
  private def run_instance
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
