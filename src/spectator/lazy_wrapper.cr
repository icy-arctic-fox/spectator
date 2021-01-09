require "./lazy"
require "./wrapper"

module Spectator
  # Lazily stores a value of any type.
  # Combines `Lazy` and `Wrapper`.
  struct LazyWrapper
    @lazy = Lazy(Wrapper).new

    # Retrieves the value, if it was previously fetched.
    # On the first invocation of this method, it will yield.
    # The block should return the value to store.
    # Subsequent calls will return the same value and not yield.
    def get(type : T.class, &block : -> T) : T forall T
      wrapper = @lazy.get { Wrapper.new(yield) }
      wrapper.get(type)
    end
  end
end
