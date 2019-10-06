module Spectator
  abstract class Double
    macro stub(definition, &block)
      {%
        name = nil
        args = nil
        body = nil
        if definition.is_a?(Call) # stub foo { :bar }
          name = definition.name.id
          args = definition.args
          body = definition.block.is_a?(Nop) ? block : definition.block
        elsif definition.is_a?(TypeDeclaration) # stub foo : Symbol
          name = definition.var
          args = [] of MacroId
          body = block
        else
          raise "Unrecognized stub format"
        end
      %}
      delegate {{name}}, to: @internal

      private class Internal
        def {{name}}({{args.splat}})
          {% if body && !body.is_a?(Nop) %}
            {{body.body}}
          {% else %}
            raise "Stubbed method called without being allowed"
          {% end %}
        end
      end
    end
  end
end
