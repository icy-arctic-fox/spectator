module Spectator::Mocks
  module Stubs
    private macro stub(definition, _file = __FILE__, _line = __LINE__, &block)
      {%
        receiver = nil
        name = nil
        params = nil
        args = nil
        body = nil
        if definition.is_a?(Call) # stub foo { :bar }
          receiver = definition.receiver.id
          named = false
          name = definition.name.id
          params = definition.args
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
        else
          raise "Unrecognized stub format"
        end

        original = if @type.methods.find { |m| m.name.id == name }
                     :previous_def
                   else
                     :super
                   end.id
        receiver = if receiver == :self.id
                     original = :previous_def.id
                     "self."
                   else
                     ""
                   end.id
      %}

      {% if body && !body.is_a?(Nop) %}
        %source = ::Spectator::Source.new({{_file}}, {{_line}})
        %proc = ->{
          {{body.body}}
        }
        %ds = ::Spectator::Mocks::ProcMethodStub.new({{name.symbolize}}, %source, %proc)
        ::Spectator::SpecBuilder.add_default_stub({{@type.name}}, %ds)
      {% end %}

      def {{receiver}}{{name}}({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        if (%harness = ::Spectator::Harness.current?)
          %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
          %call = ::Spectator::Mocks::MethodCall.new({{name.symbolize}}, %args)
          %harness.mocks.record_call(self, %call)
          if (%stub = %harness.mocks.find_stub(self, %call))
            return %stub.call!(%args) { {{original}}({{args.splat}}) }
          end
        end
        {{original}}({{args.splat}})
      end

      def {{receiver}}{{name}}({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        if (%harness = ::Spectator::Harness.current?)
          %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
          %call = ::Spectator::Mocks::MethodCall.new({{name.symbolize}}, %args)
          %harness.mocks.record_call(self, %call)
          if (%stub = %harness.mocks.find_stub(self, %call))
            return %stub.call!(%args) { {{original}}({{args.splat}}) { |*%ya| yield *%ya } }
          end
        end
        {{original}}({{args.splat}}) do |*%yield_args|
          yield *%yield_args
        end
      end
    end
  end
end
