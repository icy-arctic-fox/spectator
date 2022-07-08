require "./generic_arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class OriginalMethodStub < GenericMethodStub(Nil)
    def call(args : GenericArguments(T, NT), & : -> RT) forall T, NT, RT
      yield
    end
  end
end
