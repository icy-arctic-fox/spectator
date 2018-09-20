require "../example_group"

module Spectator
  module DSL
    module StructureDSL

      macro describe(what, type = "Describe", &block)
        context({{what}}, {{type}}) {{block}}
      end

      macro context(what, type = "Context", &block)
        module {{type.id}}%context
          include {{@type.id}}

          ::Spectator::Definitions::GROUPS[\{{@type.stringify}}] =
            ExampleGroup.new(
              {{what.is_a?(StringLiteral) ? what : what.stringify}},
              ::Spectator::Definitions::GROUPS[{{@type.stringify}}]
            )

          {% if what.is_a?(Path) || what.is_a?(Generic) %}
            _described_class {{what}}
          {% end %}

          {{block.body}}
        end
      end

      macro given(collection, &block)
        context({{collection}}, "Given") do
          def %collection
            {{collection}}
          end

          def %first
            %collection.first
          end

          def {{block.args.empty? ? "value".id : block.args.first}}
            nil # TODO
          end

          {{block.body}}
        end
      end

      macro subject(&block)
        let(:subject) {{block}}
      end

      macro let(name, &block)
        let!(%value) {{block}}

        @%wrapper : ValueWrapper?

        def {{name.id}}
          if (wrapper = @%wrapper)
            wrapper.unsafe_as(TypedValueWrapper(typeof(%value))).value
          else
            %value.tap do |value|
              @%wrapper = TypedValueWrapper(typeof(%value)).new(value)
            end
          end
        end
      end

      macro let!(name, &block)
        def {{name.id}}
          {{block.body}}
        end
      end

      macro before_all(&block)
        ::Spectator::Definitions::GROUPS[{{@type.stringify}}].before_all_hooks << -> {{block}}
      end

      macro before_each(&block)
        ::Spectator::Definitions::GROUPS[{{@type.stringify}}].before_each_hooks << -> {{block}}
      end

      macro after_all(&block)
        ::Spectator::Definitions::GROUPS[{{@type.stringify}}].after_all_hooks << -> {{block}}
      end

      macro after_each(&block)
        ::Spectator::Definitions::GROUPS[{{@type.stringify}}].after_each_hooks << -> {{block}}
      end

      macro around_each(&block)
        ::Spectator::Definitions::GROUPS[{{@type.stringify}}].around_each_hooks << Proc(Proc(Nil), Nil).new {{block}}
      end

      def include_examples
        raise NotImplementedError.new("Spectator::DSL#include_examples")
      end

      macro it(description, &block)
        class Example%example
          include ::Spectator::DSL::ExampleDSL
          include {{@type.id}}

          def %run
            {{block.body}}
          end
        end

        class Wrapper%wrapper < ::Spectator::RunnableExample
          protected def run_instance
            Example%example.new.%run
          end

          def description
            {{description.is_a?(StringLiteral) ? description : description.stringify}}
          end
        end
      end

      macro pending(description, &block)
      end

      def it_behaves_like
        raise NotImplementedError.new("Spectator::DSL#it_behaves_like")
      end

      macro _described_class(what)
        def described_class
          {{what}}.tap do |thing|
            raise "#{thing} must be a type name to use #described_class or #subject,\
             but it is a #{typeof(thing)}" unless thing.is_a?(Class)
          end
        end

        _implicit_subject
      end

      macro _implicit_subject
        def subject
          described_class.new
        end
      end
    end
  end
end
