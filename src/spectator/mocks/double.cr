require "./unexpected_message"

module Spectator
  class Double(Messages)
    def initialize(**@messages : **Messages)
    end

    # TODO: Define macro to redefine a type's method.
    # TODO: Better error for type mismatch
    macro finished
      # Object
      {% for meth in @type.superclass.superclass.methods %}
        {% if !meth.abstract? && !DSL::RESERVED_KEYWORDS.includes?(meth.name.symbolize) %}
          {% if meth.visibility != :public %}{{meth.visibility.id}}{% end %} def {{meth.receiver}}{{meth.name}}(
            {{meth.args.splat}}{% if !meth.args.empty? %}, {% end %}
            {% if meth.double_splat %}**{{meth.double_splat}}, {% end %}
            {% if meth.block_arg %}&{{meth.block_arg}}{% elsif meth.accepts_block? %}&{% end %}
          ){% if meth.return_type %} : {{meth.return_type}}{% end %}{% if !meth.free_vars.empty? %} forall {{meth.free_vars.splat}}{% end %}
            \{% if type = Messages[{{meth.name.symbolize}}] %}
              {% if meth.return_type %}
                \{% if type <= {{meth.return_type}} %}
                  @messages[{{meth.name.symbolize}}].as({{meth.return_type}})
                \{% else %}
                  raise "Type mismatch {{meth.name}} : {{meth.return_type}}"
                \{% end %}
              {% else %}
                @messages[{{meth.name.symbolize}}]
              {% end %}
            \{% else %}
              raise UnexpectedMessage.new("Received unexpected message {{meth.name}} on double <TODO:NAME> (masking ancestor).")
            \{% end %}
          end
        {% end %}
      {% end %}

      # Reference
      {% for meth in @type.superclass.methods %}
        {% if !meth.abstract? && !DSL::RESERVED_KEYWORDS.includes?(meth.name.symbolize) %}
          {% if meth.visibility != :public %}{{meth.visibility.id}}{% end %} def {{meth.receiver}}{{meth.name}}(
            {{meth.args.splat}}{% if !meth.args.empty? %}, {% end %}
            {% if meth.double_splat %}**{{meth.double_splat}}, {% end %}
            {% if meth.block_arg %}&{{meth.block_arg}}{% elsif meth.accepts_block? %}&{% end %}
          ){% if meth.return_type %} : {{meth.return_type}}{% end %}{% if !meth.free_vars.empty? %} forall {{meth.free_vars.splat}}{% end %}
            \{% if type = Messages[{{meth.name.symbolize}}] %}
              {% if meth.return_type %}
                \{% if type <= {{meth.return_type}} %}
                  @messages[{{meth.name.symbolize}}].as({{meth.return_type}})
                \{% else %}
                  raise "Type mismatch {{meth.name}} : {{meth.return_type}}"
                \{% end %}
              {% else %}
                @messages[{{meth.name.symbolize}}]
              {% end %}
            \{% else %}
              raise UnexpectedMessage.new("Received unexpected message {{meth.name}} on double <TODO:NAME> (masking ancestor).")
            \{% end %}
          end
        {% end %}
      {% end %}

      # Double
      {% for meth in @type.methods %}
        {% if !meth.abstract? && !DSL::RESERVED_KEYWORDS.includes?(meth.name.symbolize) %}
          {% if meth.visibility != :public %}{{meth.visibility.id}}{% end %} def {{meth.receiver}}{{meth.name}}(
            {{meth.args.splat}}{% if !meth.args.empty? %}, {% end %}
            {% if meth.double_splat %}**{{meth.double_splat}}, {% end %}
            {% if meth.block_arg %}&{{meth.block_arg}}{% elsif meth.accepts_block? %}&{% end %}
          ){% if meth.return_type %} : {{meth.return_type}}{% end %}{% if !meth.free_vars.empty? %} forall {{meth.free_vars.splat}}{% end %}
            \{% if type = Messages[{{meth.name.symbolize}}] %}
              {% if meth.return_type %}
                \{% if type <= {{meth.return_type}} %}
                  @messages[{{meth.name.symbolize}}].as({{meth.return_type}})
                \{% else %}
                  raise "Type mismatch {{meth.name}} : {{meth.return_type}}"
                \{% end %}
              {% else %}
                @messages[{{meth.name.symbolize}}]
              {% end %}
            \{% else %}
              raise UnexpectedMessage.new("Received unexpected message {{meth.name}} on double <TODO:NAME> (masking ancestor).")
            \{% end %}
          end
        {% end %}
      {% end %}
    end

    macro method_missing(call)
      \{% if Messages.keys.includes?({{call.name.symbolize}}.id) %}
        @messages[{{call.name.symbolize}}]
      \{% else %}
        raise UnexpectedMessage.new("Received unexpected message {{call.name}} on double <TODO:NAME>.")
      \{% end %}
    end
  end
end
