module Spectator::Formatters
  abstract class Formatter
    abstract def start_suite
    abstract def end_suite(results : TestResults)
    abstract def start_example(example : Example)
    abstract def end_example(result : Result)
  end
end
