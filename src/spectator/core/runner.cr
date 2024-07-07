require "./example"
require "./example_group"
require "./sandbox"
require "../reporters/dots_reporter"

module Spectator
  module Core
    class Runner
      def initialize(@reporter : Reporters::Reporter)
      end

      def run(spec : ExampleGroup)
        examples_to_run(spec).each do |example|
          run_example(example)
        end
      end

      private def examples_to_run(group : ExampleGroup) : Array(Example)
        group.select(Example)
      end

      private def run_example(example : Example) : Nil
        @reporter.example_started(example)
        result = example.run
        @reporter.example_finished(example, result)
        Fiber.yield
      end
    end

    class Sandbox
      property! current_example : Example
      getter root_example_group = ExampleGroup.new
    end
  end

  def self.current_example : Example
    sandbox.current_example
  end

  protected def self.current_example=(example : Example)
    sandbox.current_example = example
  end

  class_property? auto_run = true

  def self.run
    runner = Core::Runner.new(Reporters::DotsReporter.new)
    runner.run(Spectator.sandbox.root_example_group)
  end

  at_exit do
    run if auto_run?
  end
end
