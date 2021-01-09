require "./wrapper"

module Spectator
  # Lazily stores a value.
  struct Lazy(T)
    @wrapper : Wrapper(T)?

    # Retrieves the value, if it was previously fetched.
    # On the first invocation of this method, it will yield.
    # The block should return the value to store.
    # Subsequent calls will return the same value and not yield.
    def get(&block : -> T)
      if (wrapper = @wrapper)
        wrapper.value
      else
        yield.tap do |value|
          @wrapper = Wrapper.new(value)
        end
      end
    end
  end
end
