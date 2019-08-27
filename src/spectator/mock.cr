module Spectator
  module Mock
    macro included
      {% for meth in @type.methods %}
      {% if meth.visibility != :public %}{{meth.visibility.id}} {% end %}def {{meth.name.id}}(
        {% for arg, i in meth.args %}
          {% if meth.splat_index && i == meth.splat_index %}
            *{{arg}}{% if i + (meth.accepts_block? ? 0 : 1) < meth.args.size %},{% end %}
          {% else %}
            {{arg}}{% if i + (meth.accepts_block? ? 0 : 1) < meth.args.size %},{% end %}
          {% end %}
        {% end %}
        {% if meth.accepts_block? %}&{% if meth.block_arg %}{{meth.block_arg}}{% else %}__spec_block{% end %}{% end %}
        ){% if meth.return_type %} : {{meth.return_type}}{% end %}
        previous_def(
          {% for arg, i in meth.args %}
            {% if !meth.splat_index || i < meth.splat_index %}
              {{arg.name.id}}{% if i + (meth.accepts_block? ? 0 : 1) < meth.args.size %},{% end %}
            {% elsif meth.splat_index && i > meth.splat_index %}
              {{arg.name.id}}: {{arg.name}}{% if i + (meth.accepts_block? ? 0 : 1) < meth.args.size %},{% end %}
            {% end %}
          {% end %}
          {% if meth.accepts_block? %}&{% if meth.block_arg %}{{meth.block_arg}}{% else %}__spec_block{% end %}{% end %}
        )
      end
      {% end %}
      {% debug %}
    end
  end
end
