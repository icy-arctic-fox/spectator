require "./example_group"

private macro _spec_add_example(example)
  @examples << example
end

module Spectator
  module DSL
    macro describe(what, type = "Describe", &block)
      context({{what}}, {{type}}) {{block}}
    end

    macro context(what, type = "Context", &block)
      {% safe_name = what.id.stringify.gsub(/\W+/, "_") %}
      {% module_name = (type.id + safe_name.camelcase).id %}
      module {{module_name.id}}
        include ::Spectator::DSL

        module Context
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
      ::Spectator._spec_add_example({{class_name.id}}.new)
    end

    def it_behaves_like
      raise NotImplementedError.new("Spectator::DSL#it_behaves_like")
    end

    macro subject(&block)
      let(:subject) {{block}}
    end

    macro let(name, &block)
      module Context
        def {{name.id}}
          {{block.body}}
        end
      end
    end

    def let!
      raise NotImplementedError.new("Spectator::DSL#let!")
    end

    macro is_expected
      expect(subject)
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

    # :nodoc:
    protected def _spec_build
      ExampleGroup.new(@examples)
    end
  end
end
