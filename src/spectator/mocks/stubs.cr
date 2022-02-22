module Spectator::Mocks
  module Stubs
    private macro stub(definition, *types, _file = __FILE__, _line = __LINE__, return_type = :undefined, &block)
      {%
        receiver = nil
        name = nil
        params = nil
        args = nil
        body = nil
        block_arg = nil
        if definition.is_a?(Call) # stub foo { :bar }
          receiver = definition.receiver.id
          named = false
          name = definition.name.id
          params = definition.args
          block_arg = definition.block_arg
          if params.last.is_a?(Call)
            body = params.last.block
            params[-1] = params.last.name
          end
          args = params.map do |p|
            n = p.is_a?(TypeDeclaration) ? p.var : p.id
            r = named ? "#{n}: #{n}".id : n
            named = true if n.starts_with?('*')
            r
          end
          unless body
            body = definition.block.is_a?(Nop) ? block : definition.block
          end
        elsif definition.is_a?(TypeDeclaration) # stub foo : Symbol
          name = definition.var
          params = [] of MacroId
          args = [] of MacroId
          body = block
        elsif definition.is_a?(SymbolLiteral) # stub :foo, arg : Int32
          name = definition.id
          named = false
          params = types
          if params.last.is_a?(Call)
            body = params.last.block
            params[-1] = params.last.name
          end
          args = params.map do |p|
            n = p.is_a?(TypeDeclaration) ? p.var : p.id
            r = named ? "#{n}: #{n}".id : n
            named = true if n.starts_with?('*')
            r
          end
          body = block unless body
        else
          raise "Unrecognized stub format"
        end

        t = @type
        receiver = if receiver == :self.id
                     t = t.class
                     "self."
                   else
                     ""
                   end.id
        original = if (name == :new.id && receiver == "self.".id) ||
                      (t.superclass && t.superclass.has_method?(name) && !t.overrides?(t.superclass, name))
                     :super
                   elsif t.has_method?(name)
                     :previous_def
                   else
                     name
                   end.id
        fallback = if original == :super.id || original == :previous_def.id
                     original
                   else
                     "::#{original}(#{args.splat})".id
                   end
      %}

      {% if body && !body.is_a?(Nop) %}
        def {{receiver}}%method({{params.splat}}){% if return_type.is_a?(ArrayLiteral) %} : {{return_type.type}}{% elsif return_type != :undefined %} : {{return_type.id}}{% elsif definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
          {{body.body}}
        end
      {% elsif return_type.is_a?(ArrayLiteral) %}
        def {{receiver}}%method({{params.splat}}) : {{return_type.type}}
          {{return_type.splat}}
        end
      {% end %}

      def {{receiver}}{{name}}({{params.splat}}){% if return_type.is_a?(ArrayLiteral) %} : {{return_type.type}}{% elsif return_type != :undefined %} : {{return_type.id}}{% elsif definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        if (%harness = ::Spectator::Harness.current?)
          %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
          %call = ::Spectator::Mocks::MethodCall.new({{name.symbolize}}, %args)
          %harness.mocks.record_call(self, %call)
          if (%stub = %harness.mocks.find_stub(self, %call))
            return %stub.call!(%args) { {{fallback}} }
          end

          {% if body && !body.is_a?(Nop) || return_type.is_a?(ArrayLiteral) %}
            %method({{args.splat}})
          {% else %}
            {{fallback}}
          {% end %}
        else
          {{fallback}}
        end
      end

      {% if block_arg.is_a?(Call) %}
        def {{receiver}}{{name}}({{params.splat}}){% if return_type.is_a?(ArrayLiteral) %} : {{return_type.type}}{% elsif return_type != :undefined %} : {{return_type.id}}{% elsif definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
          if (%harness = ::Spectator::Harness.current?)
            %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
            %call = ::Spectator::Mocks::MethodCall.new({{name.symbolize}}, %args)
            %harness.mocks.record_call(self, %call)
            if (%stub = %harness.mocks.find_stub(self, %call))
              return %stub.call!(%args) { {{fallback}} { yield } }
            end

            {% if body && !body.is_a?(Nop) || return_type.is_a?(ArrayLiteral) %}
              %method({{args.splat}}) { yield }
            {% else %}
              {{fallback}} do
                yield
              end
            {% end %}
          else
            {{fallback}} do
              yield
            end
          end
        end

      {% else %}
        def {{receiver}}{{name}}({{params.splat}}){% if return_type.is_a?(ArrayLiteral) %} : {{return_type.type}}{% elsif return_type != :undefined %} : {{return_type.id}}{% elsif definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
          if (%harness = ::Spectator::Harness.current?)
            %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
            %call = ::Spectator::Mocks::MethodCall.new({{name.symbolize}}, %args)
            %harness.mocks.record_call(self, %call)
            if (%stub = %harness.mocks.find_stub(self, %call))
              return %stub.call!(%args) { {{fallback}} { |*%ya| yield *%ya } }
            end

            {% if body && !body.is_a?(Nop) || return_type.is_a?(ArrayLiteral) %}
              %method({{args.splat}}) { |*%ya| yield *%ya }
            {% else %}
              {{fallback}} do |*%yield_args|
                yield *%yield_args
              end
            {% end %}
          else
            {{fallback}} do |*%yield_args|
              yield *%yield_args
            end
          end
        end
      {% end %}
    end
  end
end
