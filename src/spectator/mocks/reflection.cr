require "../anything"

module Spectator::Mocks
  module Reflection
    private macro _spectator_reflect
      {% for meth in @type.methods %}
        %source = ::Spectator::Source.new({{meth.filename}}, {{meth.line_number}})
        %args = ::Spectator::Mocks::GenericArguments.create(
          {% for arg, i in meth.args %}
            {% if meth.splat_index && i == meth.splat_index %}
              *{{arg.restriction || "::Spectator::Anything.new".id}}{% if i < meth.args.size %},{% end %}
            {% else %}
              {{arg.restriction || "::Spectator::Anything.new".id}}{% if i < meth.args.size %},{% end %}
            {% end %}
          {% end %}
        )
        ::Spectator::Mocks::TypeRegistry.add({{@type.id.stringify}}, {{meth.name.symbolize}}, %source, %args)
      {% end %}
    end
  end
end
