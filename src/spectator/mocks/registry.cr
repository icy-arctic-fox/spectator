module Spectator::Mocks
  module Registry
    extend self

    alias Key = Tuple(String, UInt64)

    private struct Entry
      getter stubs = Deque(MethodStub).new
      getter calls = Deque(MethodCall).new
    end

    @@entries = {} of Key => Entry

    def prepare(context : TestContext) : Nil
      # TODO
    end

    def reset : Nil
      @@entries.clear
    end

    def add_stub(object, stub : MethodStub) : Nil
      # Stubs are added in reverse order,
      # so that later-defined stubs override previously defined ones.
      fetch(object).stubs.unshift(stub)
    end

    def find_stub(object, call : GenericMethodCall(T, NT)) forall T, NT
      fetch(object).stubs.find(&.callable?(call))
    end

    def record_call(object, call : MethodCall) : Nil
      fetch(object).calls << call
    end

    def calls_for(object, method_name : Symbol)
      fetch(object).calls.select { |call| call.name == method_name }
    end

    private def fetch(object)
      key = unique_key(object)
      if @@entries.has_key?(key)
        @@entries[key]
      else
        @@entries[key] = Entry.new
      end
    end

    private def unique_key(reference : Reference)
      {reference.class.name, reference.object_id}
    end

    private def unique_key(value : Value)
      {value.class.name, value.hash}
    end
  end
end
