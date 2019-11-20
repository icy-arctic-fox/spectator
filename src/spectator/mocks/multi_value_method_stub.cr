require "./generic_arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class MultiValueMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    @index = 0

    def initialize(name, source, @values : ReturnType, args = nil)
      super(name, source, args)
      raise ArgumentError.new("Values must have at least one item") if @values.size < 1
    end

    def call(_args : GenericArguments(T, NT), &_original : -> RT) forall T, NT, RT
      value = @values[@index]
      @index += 1 if @index < @values.size - 1
      value
    end
  end
end
