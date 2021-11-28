module Spectator::Formatting
  # Base class and interface used to notify systems of events.
  # This is typically used for producing output from test results,
  # but can also be used to send data to external systems.
  #
  # All event methods are implemented as no-ops.
  # To respond to an event, override its method.
  # Every method receives a notification object containing information about the event.
  #
  # Methods are called in this order:
  # 1.  `#start`
  # 2.  `#example_started`
  # 3.  `#example_finished`
  # 4.  `#example_passed`
  # 5.  `#example_pending`
  # 6.  `#example_failed`
  # 7.  `#stop`
  # 8.  `#start_dump`
  # 9.  `#dump_pending`
  # 10. `#dump_failures`
  # 11. `#dump_profile`
  # 12. `#dump_summary`
  # 13. `#close`
  #
  # Only one of the `#example_passed`, `#example_pending`, or `#example_failed` methods
  # will be called after `#example_finished`, depending on the outcome of the test.
  #
  # The "dump" methods are called after all tests that will run have run.
  # They are provided summarized information.
  abstract class Formatter
    # This method is the first method to be invoked
    # and will be called only once.
    # It is called before any examples run.
    # The *notification* will be a `StartNotification` type of object.
    def start(_notification)
    end

    # Invoked just before an example runs.
    # This method is called once for every example.
    # The *notification* will be an `ExampleNotification` type of object.
    def example_started(_notification)
    end

    # Invoked just after an example completes.
    # This method is called once for every example.
    # One of `#example_passed`, `#example_pending` or `#example_failed`
    # will be called immediately after this method, depending on the example's result.
    # The *notification* will be an `ExampleNotification` type of object.
    def example_finished(_notification)
    end

    # Invoked after an example completes successfully.
    # This is called right after `#example_finished`.
    # The *notification* will be an `ExampleNotification` type of object.
    def example_passed(_notification)
    end

    # Invoked after an example is skipped or marked as pending.
    # This is called right after `#example_finished`.
    # The *notification* will be an `ExampleNotification` type of object.
    def example_pending(_notification)
    end

    # Invoked after an example fails.
    # This is called right after `#example_finished`.
    # The *notification* will be an `ExampleNotification` type of object.
    #
    # NOTE: Errors are normally considered failures,
    # however `#example_error` is called instead if one occurs in an example.
    def example_failed(_notification)
    end

    # Invoked after an example fails from an unexpected error.
    # This is called right after `#example_finished`.
    # The *notification* will be an `ExampleNotification` type of object.
    def example_error(_notification)
    end

    # Called whenever the example or framework produces a message.
    # This is typically used for logging.
    # The *notification* will be a `MessageNotification` type of object.
    def message(_notification)
    end

    # Invoked after all tests that will run have completed.
    # When this method is called, it should be considered that the testing is done.
    # Summary (dump) methods will be called after this.
    def stop
    end

    # Invoked after all examples finished.
    # Indicates that summarized report data is about to be produced.
    # This method is called after `#stop` and before `#dump_pending`.
    def start_dump
    end

    # Invoked after testing completes with a list of pending examples.
    # This method will be called with an empty list if there were no pending (skipped) examples.
    # Called after `#start_dump` and before `#dump_failures`.
    # The *notification* will be an `ExampleSummaryNotification` type of object.
    def dump_pending(_notification)
    end

    # Invoked after testing completes with a list of failed examples.
    # This method will be called with an empty list if there were no failures.
    # Called after `#dump_pending` and before `#dump_summary`.
    # The *notification* will be an `ExampleSummaryNotification` type of object.
    def dump_failures(_notification)
    end

    # Invoked after testing completes with profiling information.
    # This method is only called if profiling is enabled.
    # Called after `#dump_failures` and before `#dump_summary`.
    def dump_profile(_notification)
    end

    # Invoked after testing completes with summarized information from the test suite.
    # Called after `#dump_profile` and before `#close`.
    # The *notification* will be an `SummaryNotification` type of object.
    def dump_summary(_notification)
    end

    # Invoked at the end of the program.
    # Allows the formatter to perform any cleanup and teardown.
    def close
    end
  end
end
