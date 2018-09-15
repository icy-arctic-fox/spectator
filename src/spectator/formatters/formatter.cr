module Spectator
  module Formatters
    abstract class Formatter
      abstract def start_suite
      abstract def end_suite(report : Report)
      abstract def start_example(example : Example)
      abstract def end_example(result : ExampleResult)
    end
  end
end
