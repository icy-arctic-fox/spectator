module Spectator::Mocks
  class AnonymousNullDouble(T)
    def initialize(@name : String, @values : T)
    end

    macro method_missing(call)
      args = ::Spectator::Mocks::GenericArguments.create({{call.args.splat}})
      call = ::Spectator::Mocks::MethodCall.new({{call.name.symbolize}}, args)
      ::Spectator::Harness.current.mocks.record_call(self, call)
      if (stub = ::Spectator::Harness.current.mocks.find_stub(self, call))
        stub.call!(args) { @values.fetch({{call.name.symbolize}}) { self } }
      else
        @values.fetch({{call.name.symbolize}}) { self }
      end
    end
  end
end
