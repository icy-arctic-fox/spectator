require "./generic_method_call"
require "./generic_method_stub"

module Spectator::Mocks
  abstract class Double
    @spectator_stubs = Deque(MethodStub).new
    @spectator_stub_calls = Deque(MethodCall).new

    def initialize(@spectator_double_name : Symbol)
    end

    private macro stub(definition, &block)
      {%
        name = nil
        params = nil
        args = nil
        body = nil
        if definition.is_a?(Call) # stub foo { :bar }
          named = false
          name = definition.name.id
          params = definition.args
          args = params.map do |p|
            n = p.is_a?(TypeDeclaration) ? p.var : p.id
            r = named ? "#{n}: #{n}".id : n
            named = true if n.starts_with?('*')
            r
          end
          body = definition.block.is_a?(Nop) ? block : definition.block
        elsif definition.is_a?(TypeDeclaration) # stub foo : Symbol
          name = definition.var
          params = [] of MacroId
          args = [] of MacroId
          body = block
        else
          raise "Unrecognized stub format"
        end
      %}

      def {{name}}({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
        %call = ::Spectator::Mocks::GenericMethodCall.new({{name.symbolize}}, %args)
        @spectator_stub_calls << %call
        if (%stub = @spectator_stubs.find(&.callable?(%call)))
          if (%cast = %stub.as?(::Spectator::Mocks::GenericMethodStub(typeof(%method({{args.splat}})))))
            %cast.call(%args)
          else
            raise "The return type of stub #{%stub} doesn't match the expected type #{typeof(%method({{args.splat}}))}"
          end
        else
          %method({{args.splat}})
        end
      end

      def {{name}}({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
        %call = ::Spectator::Mocks::GenericMethodCall.new({{name.symbolize}}, %args)
        @spectator_stub_calls << %call
        if (%stub = @spectator_stubs.find(&.callable?(%call)))
          if (%cast = %stub.as?(::Spectator::Mocks::GenericMethodStub(typeof(%method({{args.splat}}) { |*%yield_args| yield *%yield_args }))))
            %cast.call(%args)
          else
            raise "The return type of stub #{%stub} doesn't match the expected type #{typeof(%method({{args.splat}}) { |*%ya| yield *%ya })}"
          end
        else
          %method({{args.splat}}) do |*%yield_args|
            yield *%yield_args
          end
        end
      end

      def %method({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        {% if body && !body.is_a?(Nop) %}
          {{body.body}}
        {% else %}
          raise "Stubbed method called without being allowed"
          # This code shouldn't be reached, but makes the compiler happy to have a matching return type.
          {% if definition.is_a?(TypeDeclaration) %}
            %x = uninitialized {{definition.type}}
          {% else %}
            nil
          {% end %}
        {% end %}
      end
    end

    def to_s(io)
      io << "Double("
      io << @spectator_double_name
      io << ')'
    end

    protected def spectator_define_stub(stub : MethodStub) : Nil
      @spectator_stubs << stub
    end

    protected def spectator_stub_calls(method : Symbol) : Array(MethodCall)
      @spectator_stub_calls.select { |call| call.name == method }
    end
  end
end
