module Spectator::Mocks
  module TypeRegistry
    extend self

    alias Key = Tuple(String, Symbol)

    @@entries = {} of Key => Deque(MethodStub)

    def add(type_name : String, method_name : Symbol, location : Location, args : Arguments) : Nil
      key = {type_name, method_name}
      list = if @@entries.has_key?(key)
               @@entries[key]
             else
               @@entries[key] = Deque(MethodStub).new
             end
      list << NilMethodStub.new(method_name, location, args)
    end

    def exists?(type_name : String, call : MethodCall) : Bool
      key = {type_name, call.name}
      list = @@entries.fetch(key) { return false }
      list.any?(&.callable?(call))
    end
  end
end
