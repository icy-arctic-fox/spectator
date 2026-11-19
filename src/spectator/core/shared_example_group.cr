require "./context"
require "./example_group"

module Spectator::Core
  class SharedExampleGroup < ExampleGroup
    getter props : GenericSharedExampleGroupProperties

    def initialize(
      @props : GenericSharedExampleGroupProperties,
      description = nil,
      location = nil,
    )
      super(description, nil, location)
    end

    def apply(context : Context, **props)
      ExampleGroup.new(@description, @tags, @location).tap do |group|
        init_hook = ExampleHook(Example).new(:before, nil) do
          # TODO
        end
        group.before_each_hooks.unshift(init_hook)
        context.add_child(group)
      end
    end
  end

  struct PropEntry(T)
    def value
      return @value if @present
      raise "Can't do that here"
    end

    def initialize(@value : T)
      @present = true
    end

    def initialize
      @present = false
      @value = uninitialized T
    end
  end

  struct SharedExampleGroupPropertiesProxy(T)
    def initialize(**@entries : **T)
      {% raise "Type argument `T` for #{@type} must be a `NamedTuple`" unless T < NamedTuple %}
    end

    macro method_missing(call)
      @entries[{{call.name.symbolize}}].value
    end
  end

  abstract class GenericSharedExampleGroupProperties
    abstract def populate
  end

  class SharedExampleGroupProperties(Defaults, Missing) < GenericSharedExampleGroupProperties
    def initialize(**@defaults : **Defaults)
      {% raise "Type argument `Defaults` for #{@type} must be a `NamedTuple`" unless Defaults < NamedTuple %}
      {% raise "Type argument `Missing` for #{@type} must be a `NamedTuple`" unless Missing < NamedTuple %}
    end

    macro create(*members)
      # TODO: Add extra info about syntax.
      {% raise "Unexpected shared example group syntax" unless members.is_a?(TupleLiteral) %}
      {% members.each do |member|
           raise "Unexpected shared example group syntax" unless member.is_a?(TypeDeclaration) || member.is_a?(Assign)
         end %}
      ::Spectator::Core::SharedExampleGroupProperties(
        # Defaults
        ::NamedTuple({% for member in members %}{% unless member.value.is_a?(Nop) %}
          {{member.is_a?(Assign) ? member.target : member.var}}: {% if member.is_a?(Assign) %}typeof({{member.value}}){% else %}{{member.type}}{% end %},
        {% end %}{% end %}),
        # Missing
        ::NamedTuple({% for member in members %}{% if member.value.is_a?(Nop) %}
          {{member.is_a?(Assign) ? member.target : member.var}}: {{member.type}},
        {% end %}{% end %})
      ).new({% for member in members %}{% unless member.value.is_a?(Nop) %}
        {{member.is_a?(Assign) ? member.target : member.var}}: {{member.value}},
      {% end %}{% end %})
    end

    def populate(**props : **Missing)
      values = @defaults.merge(props)
      SharedExampleGroupProperties(typeof(values), NamedTuple).new(values)
    end

    def proxy
      {% begin %}
        SharedExampleGroupPropertiesProxy.new(
          {% for key, type in Missing %}
            {{key}}: PropEntry({{type}}).new,
          {% end %}
          {% for key, type in Defaults %}
            {{key}}: PropEntry({{type}}).new(@defaults[{{key.symbolize}}]),
          {% end %}
        )
      {% end %}
    end
  end

  module SharedExampleGroupDSL
    def def_shared_examples(name, props : Props,
                            source_file = __FILE__,
                            source_line = __LINE__,
                            source_end_line = __END_LINE__, &) forall Props
      location = LocationRange.new(source_file, source_line, source_end_line)
      group = SharedExampleGroup.new(props, name, location)
      context.add_shared_example_group(name.try &.to_s, group)
      with ContextDSL.new(group) yield group.props_proxy(Props)
      group
    end

    def it_behaves_like(name, **props)
      name_string = name.try &.to_s
      group = context.get_shared_example_group(name_string)
      if !group && (parent = context.parent)
        group = parent.get_shared_example_group(name_string)
      end
      raise "Unknown shared example group #{name}" unless group
      group.apply(context)
    end
  end

  module Context
    @shared_example_groups = {} of String => SharedExampleGroup

    def add_shared_example_group(name : String, group : SharedExampleGroup) : Nil
      # TODO: What should happen if names collide?
      @shared_example_groups[name] = group
    end

    def get_shared_example_group(name : String)
      @shared_example_groups[name]?
    end
  end

  struct ContextDSL
    include SharedExampleGroupDSL

    macro shared_examples(name, *members, &block)
      %props = ::Spectator::Core::SharedExampleGroupProperties.create({{members.splat}})
      def_shared_examples({{name}}, %props) {{block}}
    end
  end
end

module Spectator
  macro shared_examples(name, *members, &block)
    %props = ::Spectator::Core::SharedExampleGroupProperties.create({{members.splat}})
    ::Spectator.def_shared_examples({{name}}, %props) {{block}}
  end

  extend Core::SharedExampleGroupDSL
end
