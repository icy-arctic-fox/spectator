require "./mock_registry_entry"
require "./stub"

module Spectator
  # Stores collections of stubs for mocked types.
  #
  # This type is intended for all mocked modules that have functionality "injected."
  # That is, the type itself has mock functionality bolted on.
  # Adding instance members should be avoided, for instance, it could mess up serialization.
  class MockRegistry
    @entry : MockRegistryEntry?

    # Retrieves all stubs.
    def [](_object = nil)
      @entry.not_nil!
    end

    # Retrieves all stubs.
    def []?(_object = nil)
      @entry
    end

    # Retrieves all stubs.
    #
    # Yields to the block on the first retrieval.
    # This allows a mock to populate the registry with initial stubs.
    def fetch(object : Reference, & : -> Array(Stub))
      entry = @entry
      if entry.nil?
        entry = MockRegistryEntry.new
        entry.stubs = yield
        @entry = entry
      else
        entry
      end
    end

    # Clears all stubs defined for a mocked object.
    def delete(object : Reference) : Nil
      @entry = nil
    end
  end
end
