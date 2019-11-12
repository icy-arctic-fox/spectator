require "./registry"

module Spectator::Mocks
  struct Allow(T)
    def initialize(@mock : T)
    end

    def to(stub : MethodStub) : Nil
      Harness.current.mocks.add_stub(@mock, stub)
    end

    def to(stubs : Enumerable(MethodStub)) : Nil
      stubs.each do |stub|
        Harness.current.mocks.add_stub(@mock, stub)
      end
    end
  end
end
