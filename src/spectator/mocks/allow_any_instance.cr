require "./registry"

module Spectator::Mocks
  struct AllowAnyInstance(T)
    def to(stub : MethodStub) : Nil
      Harness.current.mocks.add_type_stub(T, stub)
    end
  end
end
