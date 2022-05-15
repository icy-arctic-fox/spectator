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
    @object_stubs : Hash(Void*, Array(Stub))

    # Creates an empty registry.
    def initialize
      @object_stubs = Hash(Void*, Array(Stub)).new do |hash, key|
        hash[key] = [] of Stub
      end
    end

    # Retrieves all stubs defined for a mocked object.
    def [](object : Reference) : Array(Stub)
      key = Box.box(object)
      @object_stubs[key]
    end

    # Retrieves all stubs defined for a mocked object.
    #
    # Yields to the block on the first retrieval.
    # This allows a mock to populate the registry with initial stubs.
    def fetch(object : Reference, & : -> Array(Stub))
      key = Box.box(object)
      @object_stubs.fetch(key) do
        @object_stubs[key] = yield
      end
    end
  end
end
