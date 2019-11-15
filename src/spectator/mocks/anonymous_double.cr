module Spectator::Mocks
  class AnonymousDouble(T)
    def initialize(@name : String, @values : T)
    end

    def as_null_object
      AnonymousNullDouble.new(@name, @values)
    end

    macro method_missing(call)
      args = ::Spectator::Mocks::GenericArguments.create({{call.args.splat}})
      call = ::Spectator::Mocks::GenericMethodCall.new({{call.name.symbolize}}, args)
      ::Spectator::Harness.current.mocks.record_call(self, call)
      if (stub = ::Spectator::Harness.current.mocks.find_stub(self, call))
        stub.call!(args, typeof(@values.fetch({{call.name.symbolize}}) { raise }))
      else
        @values.fetch({{call.name.symbolize}}) do
          raise ::Spectator::Mocks::UnexpectedMessageError.new("#{self} received unexpected message {{call.name}}")
        end
      end
    end
  end
end
