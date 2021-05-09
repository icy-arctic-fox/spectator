module Spectator::Formatting
  # Base class and interface used to notify systems of events.
  # This is typically used for producing output from test results,
  # but can also be used to send data to external systems.
  abstract class Formatter
  end
end
