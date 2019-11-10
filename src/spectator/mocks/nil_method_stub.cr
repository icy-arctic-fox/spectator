require "./generic_arguments"
require "./generic_method_stub"
require "./value_method_stub"

module Spectator::Mocks
  class NilMethodStub < GenericMethodStub(Nil)
    def call(_args : GenericArguments(T, NT), _rt : RT.class) forall T, NT, RT
      nil
    end

    def and_return(value : T) forall T
      ValueMethodStub.new(@name, @source, value, @args)
    end

    def with(*args : *T, **opts : **NT) forall T, NT
      args = GenericArguments.new(args, opts)
      NilMethodStub.new(@name, @source, args)
    end
  end
end
