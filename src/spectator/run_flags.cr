module Spectator
  # Toggles indicating how the test spec should execute.
  @[Flags]
  enum RunFlags
    # Indicates whether the test should abort on first failure.
    FailFast

    # Indicates whether the test should fail if there are no examples.
    FailBlank

    # Indicates whether the test should be done as a dry-run.
    # Examples won't run, but the output will show that they did.
    DryRun

    # Indicates whether examples run in a random order.
    Randomize

    # Indicates whether timing information should be generated.
    Profile
  end
end
