require "./typed_stub"
require "./value_stub"

module Spectator
  # Stub that does nothing and returns nil.
  class NullStub < TypedStub(Nil)
    def value : Nil
      nil
    end

    def and_return(value)
      ValueStub.new(method, value, constraint)
    end
  end
end
