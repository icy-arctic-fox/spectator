require "./example"
require "./example_group"

module Spectator
  module Core
    class Sandbox
      property! current_example : Example
      getter root_example_group = ExampleGroup.new
    end
  end

  protected class_property sandbox = Core::Sandbox.new

  def self.with_sandbox(& : Sandbox ->)
    previous_sandbox = self.sandbox
    sandbox = Sandbox.new
    begin
      self.sandbox = sandbox
      yield sandbox
    ensure
      self.sandbox = previous_sandbox
    end
  end

  def self.current_example : Example
    sandbox.current_example
  end

  protected def self.current_example=(example : Example)
    sandbox.current_example = example
  end

  def self.context(description = nil, *,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__, &)
    sandbox.root_example_group.context(description,
      source_file: source_file,
      source_line: source_line,
      source_end_line: source_end_line) do |group|
      with group yield group
    end
  end

  def self.describe(description = nil, *,
                    source_file = __FILE__,
                    source_line = __LINE__,
                    source_end_line = __END_LINE__, &)
    sandbox.root_example_group.describe(description,
      source_file: source_file,
      source_line: source_line,
      source_end_line: source_end_line) do |group|
      with group yield group
    end
  end
end
