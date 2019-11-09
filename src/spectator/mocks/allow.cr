module Spectator::Mocks
  struct Allow
    def initialize(@mock : Double)
    end

    def to(stub : MethodStub) : Nil
      @mock.spectator_define_stub(stub)
    end
  end
end
