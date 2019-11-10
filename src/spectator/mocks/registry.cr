module Spectator::Mocks
  class Registry
    alias Key = Tuple(String, UInt64)

    private struct Entry
      getter stubs = Deque(MethodStub).new
      getter calls = Deque(MethodCall).new
    end

    @all_instances = {} of String => Entry
    @entries = {} of Key => Entry

    def prepare(context : TestContext) : Nil
      # TODO
    end

    def reset : Nil
      @entries.clear
    end

    def add_stub(object, stub : MethodStub) : Nil
      # Stubs are added in reverse order,
      # so that later-defined stubs override previously defined ones.
      fetch_instance(object).stubs.unshift(stub)
    end

    def add_type_stub(type, stub : MethodStub) : Nil
      fetch_type(type).stubs.unshift(stub)
    end

    def find_stub(object, call : GenericMethodCall(T, NT)) forall T, NT
      fetch_instance(object).stubs.find(&.callable?(call)) ||
        fetch_type(object.class).stubs.find(&.callable?(call))
    end

    def record_call(object, call : MethodCall) : Nil
      fetch_instance(object).calls << call
      fetch_type(object.class).calls << call
    end

    def calls_for(object, method_name : Symbol)
      fetch_instance(object).calls.select { |call| call.name == method_name }
    end

    def calls_for_type(type, method_name : Symbol)
      fetch_type(type).calls.select { |call| call.name == method_name }
    end

    private def fetch_instance(object)
      key = unique_key(object)
      if @entries.has_key?(key)
        @entries[key]
      else
        @entries[key] = Entry.new
      end
    end

    private def fetch_type(type)
      key = type.name
      if @all_instances.has_key?(key)
        @all_instances[key]
      else
        @all_instances[key] = Entry.new
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
