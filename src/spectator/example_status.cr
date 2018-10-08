module Spectator
  # Various outcomes that an example can be in.
  enum ExampleStatus
    # The example was intentionally not run.
    # This is different than `Pending`.
    # This value means the example was not pending
    # and was not run due to filtering or other means.
    Skipped,

    # The example finished successfully.
    Successful,

    # The example ran, but failed.
    Failed,

    # An error occurred while executing the example.
    Errored,

    # The example is marked as pending and was not run.
    Pending,

    # The example finished successfully,
    # but something may be wrong with it.
    Warning

    # Indicates whether an example was skipped.
    def skipped?
      self == Skipped
    end

    # Indicates that an example was run and it was successful.
    # NOTE: Examples with warnings count as successful.
    def successful?
      !failed? && !pending?
    end

    # Indicates that an example was run, but it failed.
    # Errors count as failures.
    def failed?
      self == Failed || errored?
    end

    # Indicates whether an error was encountered while running the example.
    def errored?
      self == Errored
    end

    # Indicates that an example was marked as pending.
    def pending?
      self == Pending
    end

    # Indicates that the example finished successfully,
    # but something may be wrong with it.
    def warning?
      self == Warning
    end
  end
end
