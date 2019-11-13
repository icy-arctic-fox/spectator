require "../mocks"

module Spectator::DSL
  macro double(name, **stubs, &block)
    {%
      safe_name = name.id.symbolize.gsub(/\W/, "_").id
      type_name = "Double#{safe_name}".id
    %}

    {% if block.is_a?(Nop) %}
      create_double({{type_name}}, {{name}}, {{stubs.double_splat}})
    {% else %}
      define_double({{type_name}}, {{name}}, {{stubs.double_splat}}) {{block}}
    {% end %}
  end

  macro create_double(type_name, name, **stubs)
    {% type_name.resolve? || raise("Could not find a double labeled #{name}") %}

    {{type_name}}.new.tap do |%double|
      {% for name, value in stubs %}
      allow(%double).to receive({{name.id}}).and_return({{value}})
      {% end %}
    end
  end

  macro define_double(type_name, name, **stubs, &block)
    class {{type_name}} < ::Spectator::Mocks::Double
      def initialize(null = false)
        super({{name.id.stringify}}, null)
      end

      def as_null_object
        {{type_name}}.new(true)
      end

      # TODO: Do something with **stubs?

      {{block.body}}
    end
  end

  macro null_double(name, **stubs, &block)
    {%
      safe_name = name.id.symbolize.gsub(/\W/, "_").id
      type_name = "Double#{safe_name}".id
    %}

    {% if block.is_a?(Nop) %}
      create_null_double({{type_name}}, {{name}}, {{stubs.double_splat}})
    {% else %}
      define_null_double({{type_name}}, {{name}}, {{stubs.double_splat}}) {{block}}
    {% end %}
  end

  macro create_null_double(type_name, name, **stubs)
    {% type_name.resolve? || raise("Could not find a double labeled #{name}") %}

    {{type_name}}.new(true).tap do |%double|
      {% for name, value in stubs %}
      allow(%double).to receive({{name.id}}).and_return({{value}})
      {% end %}
    end
  end

  macro define_null_double(type_name, name, **stubs, &block)
    class {{type_name}} < ::Spectator::Mocks::Double
      def initialize(null = true)
        super({{name.id.stringify}}, null)
      end

      def as_null_object
        {{type_name}}.new(true)
      end

      # TODO: Do something with **stubs?

      {{block.body}}
    end
  end

  macro mock(name, &block)
    {% resolved = name.resolve
       type = if resolved < Reference
                :class
              elsif resolved < Value
                :struct
              else
                :module
              end %}
    {% begin %}
      {{type.id}} ::{{resolved.id}}
        include ::Spectator::Mocks::Stubs

        {{block.body}}
      end
    {% end %}
  end

  def allow(thing : T) forall T
    Mocks::Allow.new(thing)
  end

  def allow_any_instance_of(type : T.class) forall T
    Mocks::AllowAnyInstance(T).new
  end

  macro receive(method_name, _source_file = __FILE__, _source_line = __LINE__)
    %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
    ::Spectator::Mocks::NilMethodStub.new({{method_name.id.symbolize}}, %source)
  end

  macro receive_messages(_source_file = __FILE__, _source_line = __LINE__, **stubs)
    %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
    %stubs = [] of ::Spectator::Mocks::MethodStub
    {% for name, value in stubs %}
    %stubs << ::Spectator::Mocks::ValueMethodStub.new({{name.id.symbolize}}, %source, {{value}})
    {% end %}
    %stubs
  end
end
