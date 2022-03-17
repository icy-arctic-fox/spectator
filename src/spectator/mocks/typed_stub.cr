require "./stub"

module Spectator
  # Abstract type of stub that identifies the type of value produced by a stub.
  #
  # *T* is the type produced by the stub.
  # How the stub produces this value is up to subclasses.
  abstract class TypedStub(T) < Stub
    # Return value.
    abstract def value : T
  end
end
