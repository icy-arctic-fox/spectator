module Spectator::Mocks
  class AnonymousDouble(T)
    def initialize(@name : String, @values : T)
    end

    def as_null_object
      AnonymousNullDouble.new(@values)
    end

    macro method_missing(call)
      @values.fetch({{call.name.symbolize}}) do
        raise ::Spectator::Mocks::UnexpectedMessageError.new("#{self} received unexpected message {{call.name}}")
      end
    end
  end
end
