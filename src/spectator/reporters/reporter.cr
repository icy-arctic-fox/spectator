module Spectator
  module Reporters
    abstract class Reporter
      abstract def start_suite
      abstract def end_suite
      abstract def start_example(example : Example)
      abstract def end_example(result : ExampleResult)
    end
  end
end
