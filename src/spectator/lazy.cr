module Spectator
  # Lazily stores a value.
  struct Lazy(T)
    @value : Value(T)?

    # Retrieves the value, if it was previously fetched.
    # On the first invocation of this method, it will yield.
    # The block should return the value to store.
    # Subsequent calls will return the same value and not yield.
    def get(&block : -> T)
      if (existing = @value)
        existing.get
      else
        yield.tap do |value|
          @value = Value.new(value)
        end
      end
    end

    # Wrapper for a value.
    # This is intended to be used as a union with nil.
    # It allows storing (caching) a nillable value.
    private struct Value(T)
      # Creates the wrapper.
      def initialize(@value : T)
      end

      # Retrieves the value.
      def get : T
        @value
      end
    end
  end
end
