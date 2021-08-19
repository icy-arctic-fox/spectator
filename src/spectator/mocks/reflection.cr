require "../anything"

module Spectator::Mocks
  module Reflection
    private macro _spectator_reflect
      {% for meth in @type.methods %}
        %location = ::Spectator::Location.new({{meth.filename}}, {{meth.line_number}})
        %args = ::Spectator::Mocks::GenericArguments.create(
          {% for arg, i in meth.args %}
            {% matcher = if arg.restriction
                           if arg.restriction == :self.id
                             @type.id
                           else
                             arg.restriction
                           end
                         else
                           "::Spectator::Anything.new".id
                         end %}
            {{matcher}}{% if i < meth.args.size %},{% end %}
          {% end %}
        )
        ::Spectator::Mocks::TypeRegistry.add({{@type.id.stringify}}, {{meth.name.symbolize}}, %location, %args)
      {% end %}
    end
  end
end
