require "./generic_arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class YieldMethodStub(YieldArgs) < GenericMethodStub(Nil)
    def initialize(name, source, @yield_args : YieldArgs, args = nil)
      super(name, source, args)
    end

    def call(_args : GenericArguments(T2, NT2), rt : RT.class) forall T2, NT2, RT
      raise "Asked to yield |#{@yield_args}| but no block was passed"
    end

    def call(_args : GenericArguments(T2, NT2), rt : RT.class) forall T2, NT2, RT
      yield *@yield_args
      nil
    end
  end
end
