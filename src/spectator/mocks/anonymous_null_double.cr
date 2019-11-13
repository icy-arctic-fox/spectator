module Spectator::Mocks
  class AnonymousNullDouble(T)
    def initialize(@name : String, @values : T)
    end

    macro method_missing(call)
      @values.fetch({{call.name.symbolize}}) { self }
    end
  end
end
