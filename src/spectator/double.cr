require "./method_stub"

module Spectator
  abstract class Double
    @stubs = Deque(MethodStub).new

    private macro stub(definition, &block)
      {%
        name = nil
        params = nil
        args = nil
        body = nil
        if definition.is_a?(Call) # stub foo { :bar }
          name = definition.name.id
          params = definition.args
          args = params.map { |p| p.is_a?(TypeDeclaration) ? p.var : p.id }
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

      def {{name}}(*args, **options){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        call = ::Spectator::MethodCall.new({{name.symbolize}}, args, options)
        stub = @stubs.find(&.callable?(call))
        if stub
          stub.as(::Spectator::GenericMethodStub(typeof(%method(*args, **options)))).call(call)
        else
          %method(*args, **options)
        end
      end

      def {{name}}(*args, **options, &block){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        %method(*args, **options, &block)
      end

      def %method({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        {% if body && !body.is_a?(Nop) %}
          {{body.body}}
        {% else %}
          raise "Stubbed method called without being allowed"
        {% end %}
      end
    end

    protected def spectator_define_stub(stub : MethodStub) : Nil
      @stubs << stub
    end
  end
end
