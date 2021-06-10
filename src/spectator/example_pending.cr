module Spectator
  # Exception that indicates an example is pending and should be skipped.
  # When raised within a test, the test should abort.
  class ExamplePending < Exception
  end
end
