require "string_pool"
require "./mock_registry_entry"
require "./stub"

module Spectator
  # Stores collections of stubs for mocked value (struct) types.
  #
  # *T* is the type of value to track.
  #
  # This type is intended for all mocked struct types that have functionality "injected."
  # That is, the type itself has mock functionality bolted on.
  # Adding instance members should be avoided, for instance, it could mess up serialization.
  # This registry works around that by mapping mocks (via their raw memory content) to a collection of stubs.
  # Doing so prevents adding data to the mocked type.
  class ValueMockRegistry(T)
    @pool = StringPool.new # Used to de-dup values.
    @entries : Hash(String, MockRegistryEntry)

    # Creates an empty registry.
    def initialize
      @entries = Hash(String, MockRegistryEntry).new do |hash, key|
        hash[key] = MockRegistryEntry.new
      end
    end

    # Retrieves all stubs defined for a mocked object.
    def [](object : T)
      key = value_bytes(object)
      @entries[key]
    end

    # Retrieves all stubs defined for a mocked object or nil if the object isn't mocked yet.
    def []?(object : T)
      key = value_bytes(object)
      @entries[key]?
    end

    # Retrieves all stubs defined for a mocked object.
    #
    # Yields to the block on the first retrieval.
    # This allows a mock to populate the registry with initial stubs.
    def fetch(object : T, & : -> Array(Stub))
      key = value_bytes(object)
      @entries.fetch(key) do
        entry = MockRegistryEntry.new
        entry.stubs = yield
        @entries[key] = entry
      end
    end

    # Clears all stubs defined for a mocked object.
    def delete(object : T) : Nil
      key = value_bytes(object)
      @entries.delete(key)
    end

    # Extracts heap-managed bytes for a value.
    #
    # Strings are used because a string pool is used.
    # However, the strings are treated as an array of bytes.
    @[AlwaysInline]
    private def value_bytes(value : T) : String
      # Get slice pointing to the memory used by the value (does not allocate).
      bytes = Bytes.new(pointerof(value).as(UInt8*), sizeof(T), read_only: true)

      # De-dup the value (may allocate).
      @pool.get(bytes)
    end
  end
end
