require "./value_proxy"

module Spectator
  # Lazy initialization of a value.
  # Constructs a value only once by calling a `Proc`.
  # The value is then stored and reused - the `Proc` is only called once.
  class LazyValueProxy(T) < ValueProxy
    @value_or_block : Proc(T) | T

    # Creates a lazy instance.
    # The block provided to this method will be called
    # when `#value` is invoked.
    # The block will only be called once,
    # and the result of the block will be cached.
    def initialize(&block : -> T)
      @value_or_block = block
    end

    # Retrieves the lazy initialized value.
    # The first call to this method will create the value.
    # Subsequent calls will return the same value.
    def value
      if value = @value_or_block.as?(T)
        return value
      else
        @value_or_block = construct
      end
    end

    # Calls the block used to construct the value.
    # This method can only be called once per instance.
    private def construct : T
      @value_or_block.as(Proc(T)).call
    end
  end
end
