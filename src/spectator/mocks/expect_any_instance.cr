require "./registry"

module Spectator::Mocks
  struct ExpectAnyInstance(T)
    def initialize(@source : Source)
    end

    def to(stub : MethodStub) : Nil
      actual = Value.new(T)
      Harness.current.mocks.expect(T, stub)
      value = Value.new(stub.name, stub.to_s)
      matcher = Matchers::ReceiveTypeMatcher.new(value, stub.arguments?)
      partial = Expectations::ExpectationPartial.new(actual, @source)
      partial.to_eventually(matcher)
    end

    def to(stubs : Enumerable(MethodStub)) : Nil
      stubs.each do |stub|
        to(stub)
      end
    end
  end
end
