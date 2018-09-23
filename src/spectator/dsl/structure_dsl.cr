require "../example_group"

module Spectator
  module DSL
    module StructureDSL

      macro describe(what, &block)
        context({{what}}) {{block}}
      end

      macro context(what, &block)
        module Group%group
          include {{@type.id}}

          {% if what.is_a?(Path) || what.is_a?(Generic) %}
            _described_class {{what}}
          {% end %}

          ::Spectator::DSL::Builder.start_group(
            {{what.is_a?(StringLiteral) ? what : what.stringify}}
          )

          {{block.body}}

          ::Spectator::DSL::Builder.end_group
        end
      end

      macro given(collection, &block)
        module Group%group
          include {{@type.id}}

          def %collection
            {{collection}}
          end

          def %first
            %collection.first
          end

          @%wrapper : ::Spectator::ValueWrapper

          def {{block.args.empty? ? "value".id : block.args.first}}
            @%wrapper.as(::Spectator::TypedValueWrapper(typeof(%first))).value
          end

          def initialize(locals : Hash(Symbol, ::Spectator::ValueWrapper))
            super
            @%wrapper = locals[:%group]
          end

          _given_collection Collection%collection, %to_a do
            {{collection}}
          end
          %to_a = Collection%collection.new.%to_a

          ::Spectator::DSL::Builder.start_given_group(
            {{collection.stringify}},
            %to_a
          )

          {{block.body}}

          ::Spectator::DSL::Builder.end_group
        end
      end

      macro _given_collection(class_name, to_a_method_name, &block)
        class {{class_name.id}}
          include {{@type.id}}

          def %collection
            {{block.body}}
          end

          def %first
            %collection.first
          end

          def {{to_a_method_name.id}}
            Array(typeof(%first)).new.tap do |%array|
              %collection.each do |%item|
                %array << %item
              end
            end
          end
        end
      end

      macro subject(&block)
        let(:subject) {{block}}
      end

      macro let(name, &block)
        let!(%value) {{block}}

        @%wrapper : ::Spectator::ValueWrapper?

        def {{name.id}}
          if (wrapper = @%wrapper)
            wrapper.unsafe_as(::Spectator::TypedValueWrapper(typeof(%value))).value
          else
            %value.tap do |value|
              @%wrapper = ::Spectator::TypedValueWrapper(typeof(%value)).new(value)
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
        ::Spectator::DSL::Builder.add_before_all_hook {{block}}
      end

      macro before_each(&block)
        ::Spectator::DSL::Builder.add_before_each_hook {{block}}
      end

      macro after_all(&block)
        ::Spectator::DSL::Builder.add_after_all_hook {{block}}
      end

      macro after_each(&block)
        ::Spectator::DSL::Builder.add_after_each_hook {{block}}
      end

      macro around_each(&block)
        ::Spectator::DSL::Builder.add_around_each_hook {{block}}
      end

      def include_examples
        raise NotImplementedError.new("Spectator::DSL#include_examples")
      end

      macro it(description, &block)
        class Wrapper%example
          include ::Spectator::DSL::ExampleDSL
          include {{@type.id}}

          def initialize(locals : Hash(Symbol, ::Spectator::ValueWrapper))
            super
          end

          def %run
            {{block.body}}
          end
        end

        class Example%example < ::Spectator::RunnableExample
          protected def run_instance
            Wrapper%example.new(locals).%run
          end

          def description
            {{description.is_a?(StringLiteral) ? description : description.stringify}}
          end

          def group
            nil # TODO
          end
        end

        ::Spectator::DSL::Builder.add_example(Example%example)
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
