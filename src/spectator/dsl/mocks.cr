require "../mocks"

module Spectator::DSL
  macro double(name, &block)
    {% if block.is_a?(Nop) %}
      Double{{name.id}}.new
    {% else %}
      class Double{{name.id}} < ::Spectator::Mocks::Double
        def initialize
          super({{name.id.symbolize}})
        end

        {{block.body}}
      end
    {% end %}
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
end
