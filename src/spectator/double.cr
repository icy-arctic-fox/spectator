require "./method_stub"

module Spectator
  abstract class Double
    @stubs = Deque(MethodStub).new

    private macro delegate_internal(method, *args)
      # Modified version of Object#delegate
      {% if method.id.ends_with?('=') && method.id != "[]=" %}
        @internal.{{method.id}} {{args.splat}}
      {% else %}
        @internal.{{method.id}}({{args.splat}})
      {% end %}
    end

    macro stub(definition, &block)
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

      def {{name}}({{params.splat}})
        %stub = @stubs.find(&.callable?({{name.symbolize}}{% unless args.empty? %}, {{args.splat}}{% end %}))
        if %stub
          %stub.call({{args.splat}})
        else
          delegate_internal({{name}}{% unless args.empty? %}, {{args.splat}}{% end %})
        end
      end

      private class Internal
        def {{name}}({{params.splat}})
          {% if body && !body.is_a?(Nop) %}
            {{body.body}}
          {% else %}
            raise "Stubbed method called without being allowed"
          {% end %}
        end
      end
    end

    protected def spectator_define_stub(stub : MethodStub) : Nil
      @stubs << stub
    end
  end
end
