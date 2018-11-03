require "../example_group"

module Spectator::DSL
  # Domain specific language for the main structure of a spec.
  # The primary components of this are `#describe`, `#context`, and `#it`.
  #
  # These macros define modules and classes.
  # Those modules and classes are used to create the test cases.
  #
  # A class is created for every block of code that contains test code.
  # An `#it` block creates a class derived from `RunnableExample`.
  # A `#pending` block creates a class derived from `PendingExample`.
  # The classes are built so that they run the example's code when invoked.
  # However, the actual example code is placed into a separate "wrapper" class.
  # This is done to avoid overlap with the Spectator namespace.
  # The example code ends up having visibility only into itself and the DSL.
  #
  # Here's some skeleton code to demonstrate this:
  # ```
  # it "does something" do
  #   # Test code goes here...
  # end
  #
  # # becomes...
  #
  # # Class describing the example
  # # and provides a means of running the test.
  # # Typically every class, module, and method
  # # that the user might see or be able to reference is obscured.
  # # Fresh variables from Crystal's macros are used to achive this.
  # # It makes debugging Spectator more difficult,
  # # but prevents name collision with user code.
  # class Example123 < RunnableExample
  #   def initialize(group, sample_values)
  #     # group and sample_values are covered later.
  #     super
  #     @wrapper = Wrapper123.new(sample_values)
  #   end
  #
  #   # Returns the text provided by the user.
  #   # This isn't stored as a member
  #   # so that it can be referenced directly in compiled code.
  #   def what
  #     "does something"
  #   end
  #
  #   # This method is called by `RunnableExample`
  #   # when the example code should be ran.
  #   def run_instance
  #     @wrapper._run123
  #   end
  # end
  #
  # # Wrapper class for the example code.
  # # This isolates it from Spectator's internals.
  # class Wrapper123
  #   include Context123 # More on this in a bit.
  #   include ExampleDSL # Include DSL for the example code.
  #
  #   # Generated method name to avoid conflicts.
  #   def _run123
  #     # Test code goes here...
  #   end
  # end
  # ```
  #
  # Modules are used to provide context and share methods across examples.
  # They are used as mix-ins for the example code.
  # The example code wrapper class includes its parent module.
  # This allows the example to access anything that was defined in the same context.
  # Contexts can be nested, and this is achieved by including the parent module.
  # Whenever a module or class is defined,
  # it includes its parent so that functionality can be inherited.
  #
  # For example:
  # ```
  # describe "#foo" do
  #   subject { described_class.foo(value) }
  #
  #   context "when given :bar" do
  #     let(value) { :bar }
  #
  #     it "does something" do
  #       # ...
  #     end
  #   end
  # end
  #
  # # becomes...
  #
  # # describe "#foo"
  # module Group123
  #   # Start a new group.
  #   # More on this in a bit.
  #   Builder.start_group("#foo")
  #
  #   def subject
  #     described_class.foo(value)
  #   end
  #
  #   # context "when given :bar"
  #   module Group456
  #     include Group123 # Inherit parent module.
  #
  #     # Start a nested group.
  #     Builder.start_group("when given :bar")
  #
  #     def value
  #       :bar
  #     end
  #
  #     # Wrapper class for the test case.
  #     class Wrapper456
  #       include Group456 # Include context.
  #
  #       # Rest of example code...
  #     end
  #
  #     # Example class for the test case.
  #     class Example456 < RunnableExample
  #       # Rest of example code...
  #     end
  #
  #     # Add example to group.
  #     Builder.add_example(Example456)
  #
  #     # End "when given :bar" group.
  #     Builder.end_group
  #   end
  #
  #   # End "#foo" group.
  #   Builder.end_group
  # end
  # ```
  #
  # In addition to providing modules as mix-ins,
  # example groups are defined with `#describe` and `#context`.
  # The DSL makes use of `Builder` to construct the run-time portion of the spec.
  # As groups are defined, they are pushed on a stack
  # and popped off after everything nested in them is defined.
  # `Builder` tracks the current group (top of the stack).
  # This way, examples, hooks, nested groups, and other items can be added to it.
  # Groups and examples are nested in a parent group.
  # The only group that isn't nested is the root group - `RootExampleGroup`.
  module StructureDSL
    def initialize(sample_values : Internals::SampleValues)
    end

    macro describe(what, &block)
      context({{what}}) {{block}}
    end

    macro context(what, &block)
      module Group%group
        include {{@type.id}}

        {% if what.is_a?(Path) || what.is_a?(Generic) %}
          _spectator_described_class {{what}}
        {% end %}

        ::Spectator::DSL::Builder.start_group(
          {{what.is_a?(StringLiteral) ? what : what.stringify}}
        )

        {{block.body}}

        ::Spectator::DSL::Builder.end_group
      end
    end

    macro given(collection, &block)
      {% name = block.args.empty? ? "value".id : block.args.first %}

      module Group%group
        include {{@type.id}}

        def %collection
          {{collection}}
        end

        @%wrapper : ::Spectator::Internals::ValueWrapper

        def {{name}}
          @%wrapper.as(::Spectator::Internals::TypedValueWrapper(typeof(%collection.first))).value
        end

        def initialize(sample_values : ::Spectator::Internals::SampleValues)
          super
          @%wrapper = sample_values.get_wrapper(:%group)
        end

        _spectator_given_collection Collection%collection, %to_a, %collection

        ::Spectator::DSL::Builder.start_given_group(
          {{collection.stringify}},
          Collection%collection.new.%to_a,
          {{name.stringify}},
          :%group
        )

        {{block.body}}

        ::Spectator::DSL::Builder.end_group
      end
    end

    macro subject(&block)
      let(:subject) {{block}}
    end

    macro let(name, &block)
      let!(%value) {{block}}

      @%wrapper : ::Spectator::Internals::ValueWrapper?

      def {{name.id}}
        if (wrapper = @%wrapper)
          wrapper.unsafe_as(::Spectator::Internals::TypedValueWrapper(typeof(%value))).value
        else
          %value.tap do |value|
            @%wrapper = ::Spectator::Internals::TypedValueWrapper(typeof(%value)).new(value)
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

    macro it(what, &block)
      _spectator_example_wrapper(Wrapper%example, %run) {{block}}

      _spectator_example(Example%example, Wrapper%example, ::Spectator::RunnableExample, {{what}}) do
        protected def run_instance
          @instance.%run
        end
      end

      ::Spectator::DSL::Builder.add_example(Example%example)
    end

    macro pending(what, &block)
      _spectator_example_wrapper(Wrapper%example, %run) {{block}}

      _spectator_example(Example%example, Wrapper%example, ::Spectator::PendingExample, {{what}})

      ::Spectator::DSL::Builder.add_example(Example%example)
    end

    macro it_behaves_like
      {% raise NotImplementedError.new("it_behaves_like functionality is not implemented") %}
    end

    private macro _spectator_described_class(what)
      def described_class
        {{what}}.tap do |thing|
          raise "#{thing} must be a type name to use #described_class or #subject,\
           but it is a #{typeof(thing)}" unless thing.is_a?(Class)
        end
      end

      _spectator_implicit_subject
    end

    private macro _spectator_implicit_subject
      def subject
        described_class.new
      end
    end

    private macro _spectator_given_collection(class_name, to_a_method_name, collection_method_name)
      class {{class_name.id}}
        include {{@type.id}}

        def {{to_a_method_name.id}}
          {{collection_method_name.id}}.to_a
        end
      end
    end

    private macro _spectator_example_wrapper(class_name, run_method_name, &block)
      class {{class_name.id}}
        include ::Spectator::DSL::ExampleDSL
        include {{@type.id}}

        def initialize(sample_values : ::Spectator::Internals::SampleValues)
          super
        end

        def {{run_method_name.id}}
          {{block.body}}
        end
      end
    end

    private macro _spectator_example(example_class_name, wrapper_class_name, base_class, what, &block)
      class {{example_class_name.id}} < {{base_class.id}}
        def initialize(group : ::Spectator::ExampleGroup, sample_values : ::Spectator::Internals::SampleValues)
          super
          @instance = {{wrapper_class_name.id}}.new(sample_values)
        end

        {% if block.is_a?(Block) %}
          {{block.body}}
        {% end %}

        def what
          {{what.is_a?(StringLiteral) ? what : what.stringify}}
        end
      end
    end
  end
end
