module Spectator
  module Stubable
    private macro stub(method)
      {% raise "stub requires a method definition" if !method.is_a?(Def) %}
      {% raise "Cannot stub method with reserved keyword as name - #{method.name}" if ::Spectator::DSL::RESERVED_KEYWORDS.includes?(method.name.symbolize) %}

      {% original = ((@type.has_method?(method.name) || !@type.ancestors.any? { |a| a.has_method?(method.name) }) ? :previous_def : :super).id %}

      {% if method.visibility != :public %}{{method.visibility.id}}{% end %} def {{method.receiver}}{{method.name}}(
        {{method.args.splat(",")}}
        {% if method.double_splat %}**{{method.double_splat}}, {% end %}
        {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
      ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
        %args = ::Spectator::Arguments.capture(
          {{method.args.map(&.internal_name).splat(",")}}
          {% if method.double_splat %}**{{method.double_splat}}{% end %}
        )
        %call = ::Spectator::MethodCall.new({{method.name.symbolize}}, %args)

        if %stub = _spectator_find_stub(%call)
          {% if !method.abstract? %}
            %stub.as(::Spectator::ValueStub(typeof({{original}}))).value
          {% elsif method.return_type %}
            if %cast = %stub.as?(::Spectator::ValueStub({{method.return_type}}))
              %cast.value
            else
              %stub.value.as({{method.return_type}})
            end
          {% else %}
            %stub.value
          {% end %}
        else
          {% if method.abstract? %}
            # Response not configured for this method/message.
            raise ::Spectator::UnexpectedMessage.new("#{_spectator_double_name} received unexpected message :{{method.name}} with #{%args}")
          {% else %}
            {{original}}
          {% end %}
        end
      end
    end

    private macro abstract_stub(method)
      {% raise "abstract_stub requires a method definition" if !method.is_a?(Def) %}
      {% raise "Cannot stub method with reserved keyword as name - #{method.name}" if ::Spectator::DSL::RESERVED_KEYWORDS.includes?(method.name.symbolize) %}

      {% if method.visibility != :public %}{{method.visibility.id}}{% end %} def {{method.receiver}}{{method.name}}(
        {{method.args.splat(",")}}
        {% if method.double_splat %}**{{method.double_splat}}, {% end %}
        {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
      ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
        %args = ::Spectator::Arguments.capture(
          {{method.args.map(&.internal_name).splat(",")}}
          {% if method.double_splat %}**{{method.double_splat}}{% end %}
        )
        %call = ::Spectator::MethodCall.new({{method.name.symbolize}}, %args)

        if %stub = _spectator_find_stub(%call)
          {% if method.return_type %}
            if %cast = %stub.as?(::Spectator::ValueStub({{method.return_type}}))
              %cast.value
            else
              %stub.value.as({{method.return_type}})
            end
          {% else %}
            %stub.value
          {% end %}
        else
          # Response not configured for this method/message.
          raise ::Spectator::UnexpectedMessage.new("#{_spectator_double_name} received unexpected message :{{method.name}} with #{%args}")
        end
      end
    end
  end
end
