require "./example_group"

private macro _spec_add_example(example)
  @examples << example
end

module Spectator
  module DSL
    private macro nest(type, what, &block)
      {% safe_name = what.id.stringify.gsub(/\W+/, "_") %}
      {% module_name = (type.id + safe_name.camelcase).id %}
      module {{module_name.id}}
        include ::Spectator::DSL
        {{block.body}}
      end
    end

    macro describe(what, &block)
      nest("Describe", {{what}}) {{block}}
    end

    macro context(what, &block)
      nest("Context", {{what}}) {{block}}
    end

    macro it(description, &block)
      {% safe_name = description.id.stringify.gsub(/\W+/, "_") %}
      {% class_name = (safe_name.camelcase + "Example").id %}
      class {{class_name.id}} < ::Spectator::Example
        def run
          {{block.body}}
        end
      end
    end

    def it_behaves_like
      raise NotImplementedError.new("Spectator::DSL#it_behaves_like")
    end

    def subject
      raise NotImplementedError.new("Spectator::DSL#subject")
    end

    def subject!
      raise NotImplementedError.new("Spectator::DSL#subject!")
    end

    def let
      raise NotImplementedError.new("Spectator::DSL#let")
    end

    def let!
      raise NotImplementedError.new("Spectator::DSL#let!")
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
