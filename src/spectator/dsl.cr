require "./example_group"

private macro _spec_add_example(example)
  @examples << example
end

module Spectator
  class DSL
    @examples = [] of Spectator::Example

    protected def initialize(@type : String)
    end

    def describe
      raise NotImplementedError.new("Spectator::DSL#describe")
    end

    def context
      raise NotImplementedError.new("Spectator::DSL#context")
    end

    def it(description : String, &block) : Nil
      example = Spectator::Example.new(description, block)
      _spec_add_example(example)
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
