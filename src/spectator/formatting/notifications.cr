require "../example"
require "../profile"
require "../report"

module Spectator::Formatting
  # Structure indicating the test suite has started.
  record StartNotification, example_count : Int32

  # Structure indicating an event occurred with an example.
  record ExampleNotification, example : Example

  # Structure containing a subset of examples from the test suite.
  record ExampleSummaryNotification, examples : Enumerable(Example)

  # Structure containing profiling information.
  record ProfileNotification, profile : Profile

  # Structure containing summarized information from the outcome of the test suite.
  record SummaryNotification, report : Report

  # Structure containing a debug or log message from the test suite.
  record MessageNotification, message : String
end
