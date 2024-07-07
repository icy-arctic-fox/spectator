require "./cli"
require "./configuration"
require "./example"
require "./example_group"
require "./sandbox"

module Spectator
  module Core
    class Runner
      def initialize(@configuration : Configuration)
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
        report &.example_started(example)
        result = example.run
        report &.example_finished(example, result)
        Fiber.yield
      end

      private def report(&) : Nil
        @configuration.formatters.each do |formatter|
          yield formatter
        end
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
    Core::CLI.configure
    runner = Core::Runner.new(configuration)
    runner.run(sandbox.root_example_group)
  end

  at_exit do
    run if auto_run?
  end
end
