require "../mocks"

module Spectator::DSL
  module Mocks
    macro double(name = "Anonymous", **stubs, &block)
      {% if name.is_a?(StringLiteral) || name.is_a?(StringInterpolation) %}
        anonymous_double({{name}}, {{stubs.double_splat}})
      {% else %}
        {%
          safe_name = name.id.symbolize.gsub(/\W/, "_").id
          type_name = "Double#{safe_name}".id
        %}

        {% if block.is_a?(Nop) %}
          create_double({{type_name}}, {{name}}, {{stubs.double_splat}})
        {% else %}
          define_double({{type_name}}, {{name}}, {{stubs.double_splat}}) {{block}}
        {% end %}
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
      {% begin %}
        {% if (name.is_a?(Path) || name.is_a?(Generic)) && (resolved = name.resolve?) %}
          verify_double({{name}})
          class {{type_name}} < ::Spectator::Mocks::VerifyingDouble(::{{resolved.id}})
        {% else %}
          class {{type_name}} < ::Spectator::Mocks::Double
            def initialize(null = false)
              super({{name.id.stringify}}, null)
            end
        {% end %}

        def as_null_object
          {{type_name}}.new(true)
        end

        # TODO: Do something with **stubs?

        {{block.body}}
      end
      {% end %}
    end

    def anonymous_double(name = "Anonymous", **stubs)
      ::Spectator::Mocks::AnonymousDouble.new(name, stubs)
    end

    macro null_double(name, **stubs, &block)
      {% if name.is_a?(StringLiteral) || name.is_a?(StringInterpolation) %}
        anonymous_null_double({{name}}, {{stubs.double_splat}})
      {% else %}
        {%
          safe_name = name.id.symbolize.gsub(/\W/, "_").id
          type_name = "Double#{safe_name}".id
        %}

        {% if block.is_a?(Nop) %}
          create_null_double({{type_name}}, {{name}}, {{stubs.double_splat}})
        {% else %}
          define_null_double({{type_name}}, {{name}}, {{stubs.double_splat}}) {{block}}
        {% end %}
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

    def anonymous_null_double(name = "Anonymous", **stubs)
      ::Spectator::Mocks::AnonymousNullDouble.new(name, stubs)
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

    macro verify_double(name, &block)
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
          include ::Spectator::Mocks::Reflection

          macro finished
            _spectator_reflect
          end
        end
      {% end %}
    end

    def allow(thing)
      ::Spectator::Mocks::Allow.new(thing)
    end

    def allow_any_instance_of(type : T.class) forall T
      ::Spectator::Mocks::AllowAnyInstance(T).new
    end

    macro expect_any_instance_of(type, _source_file = __FILE__, _source_line = __LINE__)
      %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
      ::Spectator::Mocks::ExpectAnyInstance({{type}}).new(%source)
    end

    macro receive(method_name, _source_file = __FILE__, _source_line = __LINE__, &block)
      %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
      {% if block.is_a?(Nop) %}
        ::Spectator::Mocks::NilMethodStub.new({{method_name.id.symbolize}}, %source)
      {% else %}
        ::Spectator::Mocks::ProcMethodStub.create({{method_name.id.symbolize}}, %source) { {{block.body}} }
      {% end %}
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
end
