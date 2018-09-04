require "./example_group"

module Spectator
  module DSL
    macro describe(what, source_file = __FILE__, source_line = __LINE__, type = "Describe", &block)
      context({{what}}, {{source_file}}, {{source_line}}, {{type}}) {{block}}
    end

    macro context(what, source_file = __FILE__, source_line = __LINE__, type = "Context", &block)
      {% safe_name = what.id.stringify.gsub(/\W+/, "_") %}
      {% module_name = (type.id + safe_name.camelcase).id %}
      {% parent_locals_module = PARENT_LOCALS_MODULE %}
      module {{module_name.id}}
        include ::Spectator::DSL

        PARENT_LOCALS_MODULE = {{parent_locals_module.id}}::{{module_name.id}}

        module Locals
          include {{parent_locals_module.id}}::Locals
        end

        {{block.body}}
      end
    end

    macro it(description, source_file = __FILE__, source_line = __LINE__, &block)
      {% safe_name = description.id.stringify.gsub(/\W+/, "_") %}
      {% class_name = (safe_name.camelcase + "Example").id %}
      class {{class_name.id}} < ::Spectator::Example
        include Locals

        def source
          Source.new({{source_file}}, {{source_line}})
        end

        def run
          {{block.body}}
        end
      end

      ::Spectator::ALL_EXAMPLES << {{class_name.id}}.new
    end

    def it_behaves_like
      raise NotImplementedError.new("Spectator::DSL#it_behaves_like")
    end

    macro subject(&block)
      let(:subject) {{block}}
    end

    macro let(name, &block)
      let!({{name}}!) {{block}}

      module Locals
        @_%wrapper : ValueWrapper?

        def {{name.id}}
          if (wrapper = @_%wrapper)
            wrapper.as(TypedValueWrapper(typeof({{name.id}}!))).value
          else
            {{name.id}}!.tap do |value|
              @_%wrapper = TypedValueWrapper(typeof({{name.id}}!)).new(value)
            end
          end
        end
      end
    end

    macro let!(name, &block)
      module Locals
        def {{name.id}}
          {{block.body}}
        end
      end
    end

    def before_all
      raise NotImplementedError.new("Spectator::DSL#before_all")
    end

    def before_each
      raise NotImplementedError.new("Spectator::DSL#before_each")
    end

    def after_all
      raise NotImplementedError.new("Spectator::DSL#after_all")
    end

    def after_each
      raise NotImplementedError.new("Spectator::DSL#after_each")
    end

    def around_each
      raise NotImplementedError.new("Spectator::DSL#around_each")
    end

    def include_examples
      raise NotImplementedError.new("Spectator::DSL#include_examples")
    end
  end
end
