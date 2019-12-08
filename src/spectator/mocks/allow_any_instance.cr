require "./registry"

module Spectator::Mocks
  struct AllowAnyInstance(T)
    def to(stub : MethodStub) : Nil
      Harness.current.mocks.add_type_stub(T, stub)
    end

    def to(stubs : Enumerable(MethodStub)) : Nil
      stubs.each do |stub|
        Harness.current.mocks.add_type_stub(T, stub)
      end
    end
  end
end
