require "./lazy"
require "./wrapper"

module Spectator
  # Lazily stores a value of any type.
  # Combines `Lazy` and `Wrapper`.
  #
  # Contains no value until the first call to `#get` is made.
  # Any type can be stored in this wrapper.
  # However, the type must always be known when retrieving it via `#get`.
  # The type is inferred from the block, and all blocks must return the same type.
  # Because of this, it is recommended to only have `#get` called in one location.
  #
  # This type is expected to be used like so:
  # ```
  # @wrapper : LazyWrapper
  #
  # # ...
  #
  # def lazy_load
  #   @wrapper.get { some_expensive_operation }
  # end
  # ```
  struct LazyWrapper
    @lazy = Lazy(Wrapper).new

    # Retrieves the value, if it was previously fetched.
    # On the first invocation of this method, it will yield.
    # The block should return the value to store.
    # Subsequent calls will return the same value and not yield.
    def get(& : -> T) : T forall T
      wrapper = @lazy.get { Wrapper.new(yield) }
      wrapper.get { yield }
    end
  end
end
