require "./generic_method_stub"
require "./method_call"
require "./unexpected_message_error"

module Spectator::Mocks
  abstract class Double
    def initialize(@spectator_double_name : String, @null = false)
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

          # Possibly a weird compiler bug, but syntax like this:
          # stub instance.==(other) { true }
          # Results in `other` being the call `other { true }`.
          # This works around the issue by pulling out the block
          # and setting the parameter to just the name.
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

          # The unless is here because `||=` can't be used in macros @_@
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
      %}

      def {{name}}({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
        %call = ::Spectator::Mocks::MethodCall.new({{name.symbolize}}, %args)
        ::Spectator::Harness.current.mocks.record_call(self, %call)
        if (%stub = ::Spectator::Harness.current.mocks.find_stub(self, %call))
          %stub.call!(%args) { %method({{args.splat}}) }
        else
          %method({{args.splat}})
        end
      end

      def {{name}}({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
        %call = ::Spectator::Mocks::MethodCall.new({{name.symbolize}}, %args)
        ::Spectator::Harness.current.mocks.record_call(self, %call)
        if (%stub = ::Spectator::Harness.current.mocks.find_stub(self, %call))
          %stub.call!(%args) { %method({{args.splat}}) { |*%ya| yield *%ya } }
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
          %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
          %call = ::Spectator::Mocks::MethodCall.new({{name.symbolize}}, %args)
          unless ::Spectator::Harness.current.mocks.expected?(self, %call)
            raise ::Spectator::Mocks::UnexpectedMessageError.new("#{self} received unexpected message {{name}}")
          end

          # This code shouldn't be reached, but makes the compiler happy to have a matching return type.
          {% if definition.is_a?(TypeDeclaration) %}
            %x = uninitialized {{definition.type}}
          {% else %}
            nil
          {% end %}
        {% end %}
      end
    end

    macro method_missing(call)
      args = ::Spectator::Mocks::GenericArguments.create({{call.args.splat}})
      call = ::Spectator::Mocks::MethodCall.new({{call.name.symbolize}}, args)
      ::Spectator::Harness.current.mocks.record_call(self, call)

      return self if @null
      return self if ::Spectator::Harness.current.mocks.expected?(self, call)

      raise ::Spectator::Mocks::UnexpectedMessageError.new("#{self} received unexpected message {{call.name}}")
    end

    def to_s(io)
      io << "Double("
      io << @spectator_double_name
      io << ')'
    end
  end
end
