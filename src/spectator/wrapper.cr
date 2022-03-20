module Spectator
  # Typeless wrapper for a value.
  # Stores any value or reference type.
  # However, the type must be known when retrieving the value.
  #
  # This type is expected to be used like so:
  # ```
  # wrapper = Wrapper.new("wrapped")
  # value = wrapper.get(String)
  # ```
  struct Wrapper
    @pointer : Void*

    # Creates a wrapper for the specified value.
    def initialize(value)
      @pointer = Box.box(value)
    end

    # Retrieves the previously wrapped value.
    # The *type* of the wrapped value must match otherwise an error will be raised.
    def get(type : T.class) : T forall T
      Box(T).unbox(@pointer)
    end

    # Retrieves the previously wrapped value.
    # Alternate form of `#get` that accepts a block.
    # The block must return the same type as the wrapped value, otherwise an error will be raised.
    # This method gets around the issue where the value might be a type (i.e. `Int32.class`).
    # The block will never be executed, it is only used for type information.
    #
    # ```
    # wrapper = Wrapper.new(Int32)
    # # type = wrapper.get(Int32.class) # Does not work!
    # type = wrapper.get { Int32 } # Returns Int32
    # ```
    def get(& : -> T) : T forall T
      Box(T).unbox(@pointer)
    end
  end
end
