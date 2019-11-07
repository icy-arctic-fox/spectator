module Spectator::Mocks
  module Registry
    extend self

    alias Key = Tuple(UInt64, UInt64)

    private struct Entry
      getter stubs = Deque(MethodStub).new
      getter calls = Deque(MethodCall).new
    end

    @entries = {} of Key => Entry

    def reset
      @entries.clear
    end

    def register(object)
      key = unique_key(object)
      @entries[key] = Entry.new
    end

    def stub(object, stub : MethodStub)
      key = unique_key(object)
      @entries[key].stubs << stub
    rescue KeyError
      raise "Cannot stub unregistered mock"
    end

    def record_call(object, call : MethodCall)
      key = unique_key(object)
      @entries[key].calls << call
    rescue KeyError
      raise "Cannot record call for unregistered mock"
    end

    private def unique_key(reference : Reference)
      {reference.class.hash, reference.object_id}
    end

    private def unique_key(value : Value)
      {value.class.hash, value.hash}
    end
  end
end
