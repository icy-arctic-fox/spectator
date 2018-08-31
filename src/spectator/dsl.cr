require "./example_group"

module Spectator
  module DSL
    macro describe(what, type = "Describe", &block)
      context({{what}}, {{type}}) {{block}}
    end

    macro context(what, type = "Context", &block)
      {% safe_name = what.id.stringify.gsub(/\W+/, "_") %}
      {% module_name = (type.id + safe_name.camelcase).id %}
      {% parent_context_name = PARENT_CONTEXT_NAME %}
      module {{module_name.id}}
        include ::Spectator::DSL

        PARENT_CONTEXT_NAME = {{parent_context_name.id}}::{{module_name.id}}

        module Context
          include {{parent_context_name.id}}::Context
        end

        {{block.body}}
      end
    end

    macro it(description, &block)
      {% safe_name = description.id.stringify.gsub(/\W+/, "_") %}
      {% class_name = (safe_name.camelcase + "Example").id %}
      class {{class_name.id}} < ::Spectator::Example
        include Context

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

      module Context
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
      module Context
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
