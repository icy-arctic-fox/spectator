require "./mock_registry_entry"
require "./stub"

module Spectator
  # Stores collections of stubs for mocked reference (class) types.
  #
  # This type is intended for all mocked reference types that have functionality "injected."
  # That is, the type itself has mock functionality bolted on.
  # Adding instance members should be avoided, for instance, it could mess up serialization.
  # This registry works around that by mapping mocks (via their memory address) to a collection of stubs.
  # Doing so prevents adding data to the mocked type.
  class ReferenceMockRegistry
    @entries : Hash(Void*, MockRegistryEntry)

    # Creates an empty registry.
    def initialize
      @entries = Hash(Void*, MockRegistryEntry).new do |hash, key|
        hash[key] = MockRegistryEntry.new
      end
    end

    # Retrieves all stubs defined for a mocked object.
    def [](object : Reference)
      key = Box.box(object)
      @entries[key]
    end

    # Retrieves all stubs defined for a mocked object or nil if the object isn't mocked yet.
    def []?(object : Reference)
      key = Box.box(object)
      @entries[key]?
    end

    # Retrieves all stubs defined for a mocked object.
    #
    # Yields to the block on the first retrieval.
    # This allows a mock to populate the registry with initial stubs.
    def fetch(object : Reference, & : -> Array(Stub))
      key = Box.box(object)
      @entries.fetch(key) do
        entry = MockRegistryEntry.new
        entry.stubs = yield
        @entries[key] = entry
      end
    end

    # Clears all stubs defined for a mocked object.
    def delete(object : Reference) : Nil
      key = Box.box(object)
      @entries.delete(key)
    end
  end
end
