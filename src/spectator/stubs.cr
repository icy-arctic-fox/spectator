module Spectator
  module Stubs
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
        def {{name}}{% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
            %method
        end

      {% if name.ends_with?('=') && name.id != "[]=" %}
        def {{name}}(arg)
          call = ::Spectator::GenericMethodCall.new({{name.symbolize}}, {arg}, NamedTuple.new)
          @spectator_stub_calls << call
          stub = @spectator_stubs.find(&.callable?(call))
          if stub
            stub.as(::Spectator::GenericMethodStub(typeof(%method(arg)))).call(call)
          else
            %method(arg)
          end
        end
      {% else %}
        def {{name}}(*args, **options){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
          call = ::Spectator::GenericMethodCall.new({{name.symbolize}}, args, options)
          @spectator_stub_calls << call
          stub = @spectator_stubs.find(&.callable?(call))
          if stub
            stub.as(::Spectator::GenericMethodStub(typeof(%method(*args, **options)))).call(call)
          else
            %method(*args, **options)
          end
        end

        {% if name != "[]=" %}
          def {{name}}(*args, **options){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
            call = ::Spectator::GenericMethodCall.new({{name.symbolize}}, args, options)
            @spectator_stub_calls << call
            stub = @spectator_stubs.find(&.callable?(call))
            if stub
              stub.as(::Spectator::GenericMethodStub(typeof(%method(*args, **options) { |*yield_args| yield *yield_args }))).call(call)
            else
              %method(*args, **options) do |*yield_args|
                yield *yield_args
              end
            end
          end
        {% end %}
      {% end %}

      def %method({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        {% if body && !body.is_a?(Nop) %}
          {{body.body}}
        {% else %}
          raise "Stubbed method called without being allowed"
          # This code shouldn't be reached, but makes the compiler happy to have a matching type.
          {% if definition.is_a?(TypeDeclaration) %}
            %x = uninitialized {{definition.type}}
          {% else %}
            nil
          {% end %}
        {% end %}
      end
      {% debug %}
    end
  end
end
