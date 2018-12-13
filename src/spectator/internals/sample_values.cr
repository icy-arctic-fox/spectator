require "./value_wrapper"

module Spectator::Internals
  # Collection of test values supplied to examples.
  # Each value is labeled by a symbol that the example knows.
  # The values also come with a name that can be given to humans.
  struct SampleValues
    # Creates an empty set of sample values.
    def self.empty
      new({} of Symbol => Entry)
    end

    # Creates a collection of sample values.
    protected def initialize(@values = {} of Symbol => Entry)
    end

    # Adds a new value by duplicating the current set and adding to it.
    # The new sample values with the additional value is returned.
    # The original set of sample values is not modified.
    def add(id : Symbol, name : String, value : T) : SampleValues forall T
      wrapper = TypedValueWrapper(T).new(value)
      SampleValues.new(@values.merge({
        id => Entry.new(name, wrapper),
      }))
    end

    # Retrieves the wrapper for a value.
    # The symbol for the value is used for retrieval.
    def get_wrapper(id : Symbol)
      @values[id].wrapper
    end

    # Retrieves a value.
    # The symbol for the value is used for retrieval.
    # The value's type must be provided so that the wrapper can be cast.
    def get_value(id : Symbol, value_type : T.class) : T forall T
      get_wrapper(id).as(TypedValueWrapper(T)).value
    end

    # Iterates over all values and yields them.
    def each
      @values.each_value do |entry|
        yield entry
      end
    end

    # Represents a single value in the set.
    private struct Entry
      # Human-friendly name for the value.
      getter name : String

      # Wrapper for the value.
      getter wrapper : ValueWrapper

      # Creates a new value entry.
      def initialize(@name, @wrapper)
      end
    end

    # This must be after `Entry` is defined.
    # Could be a Cyrstal compiler bug?
    include Enumerable(Entry)
  end
end
