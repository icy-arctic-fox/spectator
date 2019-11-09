require "./registry"

module Spectator::Mocks
  struct Allow(T)
    def initialize(@mock : T)
    end

    def to(stub : MethodStub) : Nil
      Registry.add_stub(@mock, stub)
    end
  end
end
