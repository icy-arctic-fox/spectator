module Spectator
  # Wrapper for a value.
  # This is intended to be used as a union with nil.
  # It allows storing (caching) a nillable value.
  # ```
  # if (wrapper = @wrapper)
  #   wrapper.value
  # else
  #   value = 42
  #   @wrapper = Wrapper.new(value)
  #   value
  # end
  # ```
  struct Wrapper(T)
    # Original value.
    getter value : T

    # Creates the wrapper.
    def initialize(@value : T)
    end
  end
end
