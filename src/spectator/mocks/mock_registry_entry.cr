require "./method_call"
require "./stub"

module Spectator
  # Stubs and calls for a mock.
  private struct MockRegistryEntry
    # Retrieves all stubs defined for a mock.
    property stubs = [] of Stub

    # Retrieves all calls to stubbed methods.
    getter calls = [] of MethodCall
  end
end
