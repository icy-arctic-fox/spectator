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
  #
  # Some example groups make use of sample values.
  # Sample values are a collection of test values that can be used in examples.
  # For more information, see `Internals::SampleValues`.
  module StructureDSL
    # Placeholder initializer.
    # This is needed because examples and groups call `super` in their initializer.
    # Those initializers pass the sample values upward through their hierarchy.
    def initialize(sample_values : Internals::SampleValues)
    end

    # Creates a new example group to describe a component.
    # The `what` argument describes "what" is being tested.
    # Additional example groups and DSL may be nested in the block.
    #
    # Typically when testing a method,
    # the spec is written like so:
    # ```
    # describe "#foo" do
    #   it "does something" do
    #     # ...
    #   end
    # end
    # ```
    #
    # When describing a class (or any other type),
    # the `what` parameter doesn't need to be quoted.
    # ```
    # describe String do
    #   it "does something" do
    #     # ...
    #   end
    # end
    # ```
    #
    # And when combining the two together:
    # ```
    # describe String do
    #   describe "#size" do
    #     it "returns the length" do
    #       # ...
    #     end
    #   end
    # end
    # ```
    #
    # The `#describe` and `#context` are identical in terms of functionality.
    # However, `#describe` is typically used on classes and methods,
    # while `#context` is used for use cases and scenarios.
    macro describe(what, &block)
      context({{what}}) {{block}}
    end

    # Creates a new example group to describe a situation.
    # The `what` argument describes the scenario or case being tested.
    # Additional example groups and DSL may be nested in the block.
    #
    # The `#describe` and `#context` are identical in terms of functionality.
    # However, `#describe` is typically used on classes and methods,
    # while `#context` is used for use cases and scenarios.
    #
    # Using context blocks in conjunction with hooks, `#let`, and other methods
    # provide an easy way to define the scenario in code.
    # This also gives each example in the context an identical situation to run in.
    #
    # For instance:
    # ```
    # describe String do
    #   context "when empty" do
    #     subject { "" }
    #
    #     it "has a size of zero" do
    #       expect(subject.size).to eq(0)
    #     end
    #
    #     it "is blank" do
    #       expect(subject.blank?).to be_true
    #     end
    #   end
    #
    #   context "when not empty" do
    #     subject { "foobar" }
    #
    #     it "has a non-zero size" do
    #       expect(subject.size).to_not eq(0)
    #     end
    #
    #     it "is not blank" do
    #       expect(subject.blank?).to be_false
    #     end
    #   end
    # end
    # ```
    #
    # While this is a somewhat contrived example,
    # it demonstrates how contexts can reuse code.
    # Contexts also make it clearer how a scenario is setup.
    macro context(what, &block)
      # Module for the context.
      # The module uses a generated unique name.
      module Group%group
        # Include the parent module.
        # Since `@type` resolves immediately,
        # this will reference the parent type.
        include {{@type.id}}

        # Check if `what` looks like a type.
        # If it is, add the `#described_class` and `subject` methods.
        # At the time of writing this code,
        # this is the way (at least that I know of)
        # to check if an AST node is a type name.
        #
        # NOTE: In Crystal 0.27, it looks like `#resolve` can be used.
        # Need to investigate, but would also increase minimum version.
        {% if what.is_a?(Path) || what.is_a?(Generic) %}
          # Returns the type currently being described.
          def described_class
            {{what}}.tap do |thing|
              # Runtime check to ensure that `what` is a type.
              raise "#{thing} must be a type name to use #described_class or #subject,\
               but it is a #{typeof(thing)}" unless thing.is_a?(Class)
            end
          end

          # Implicit subject definition.
          # Simply creates a new instance of the described type.
          def subject(*args)
            described_class.new(*args)
          end
        {% end %}

        # Start a new group.
        ::Spectator::DSL::Builder.start_group(
          {{what.is_a?(StringLiteral) ? what : what.stringify}}
        )

        # Nest the block's content in the module.
        {{block.body}}

        # End the current group.
        ::Spectator::DSL::Builder.end_group
      end
    end

    # Creates a new example group to given multiple values to.
    # This method takes a collection of values
    # and repeats the contents of the block with each value.
    # The `collection` argument should be a literal collection,
    # such as an array, or a function that returns an enumerable.
    # The block should accept an argument.
    # If it does, then the argument's name is used to reference
    # the current item in the collection.
    # If an argument isn't provided, then `#value` can be used instead.
    #
    # Example with a block argument:
    # ```
    # given some_integers do |integer|
    #   it "sets the value" do
    #     subject.value = integer
    #     expect(subject.value).to eq(integer)
    #   end
    # end
    # ```
    #
    # Same spec, but without a block argument:
    # ```
    # given some_integers do
    #   it "sets the value" do
    #     subject.value = value
    #     expect(subject.value).to eq(value)
    #   end
    # end
    # ```
    #
    # In the examples above, the test case (`#it` block)
    # is repeated for each element in `some_integers`.
    # `some_integers` is ficticous collection.
    # The collection will be iterated once.
    # `#given` blocks can be nested, and work similarly to loops.
    macro given(collection, &block)
      # Figure out the name to use for the current collection element.
      # If a block argument is provided, use it, otherwise use "value".
      {% name = block.args.empty? ? "value".id : block.args.first %}

      # Method for retrieving the entire collection.
      # This simplifies getting the element type.
      # The name is uniquely generated to prevent namespace collision.
      # This method should be called only once.
      def %collection
        {{collection}}
      end

      # Class for generating an array with the collection's contents.
      # This has to be a class that includes the parent module.
      # The collection could reference a helper method
      # or anything else in the parent scope.
      class Collection%group
        # Include the parent module.
        include {{@type.id}}

        # Method that returns an array containing the collection.
        # This method should be called only once.
        # The framework stores the collection as an array for a couple of reasons.
        # 1. The collection may not support multiple iterations.
        # 2. The collection might contain random values.
        #    Iterating multiple times would generate inconsistent values at runtime.
        def %to_a
          %collection.to_a
        end
      end

      # Module for the context.
      # The module uses a generated unique name.
      module Group%group
        # Include the parent module.
        # Since `@type` resolves immediately,
        # this will reference the parent type.
        include {{@type.id}}

        # Value wrapper for the current element.
        @%wrapper : ::Spectator::Internals::ValueWrapper

        # Retrieves the current element from the collection.
        def {{name}}
          # Unwrap the value and return it.
          # The `#first` method has a return type that matches the element type.
          # So it is used on the collection method proxy to resolve the type at compile-time.
          @%wrapper.as(::Spectator::Internals::TypedValueWrapper(typeof(%collection.first))).value
        end

        # Initializer to extract current element of the collection from sample values.
        def initialize(sample_values : ::Spectator::Internals::SampleValues)
          super
          @%wrapper = sample_values.get_wrapper(:%group)
        end

        # Start a new example group.
        # Given groups require additional configuration.
        ::Spectator::DSL::Builder.start_given_group(
          {{collection.stringify}},   # String representation of the collection.
          Collection%group.new.%to_a, # All elements in the collection.
          {{name.stringify}},         # Name for the current element.
          :%group # Unique identifier for retrieving elements for the associated collection.
        )

        # Nest the block's content in the module.
        {{block.body}}

        # End the current group.
        ::Spectator::DSL::Builder.end_group
      end
    end

    # Explicitly defines the subject being tested.
    # The `#subject` method can be used in examples to retrieve the value (basically a method).
    #
    # This macro expects a block.
    # The block should return the value.
    # This can be used to define a value once and reuse it in multiple examples.
    #
    # For instance:
    # ```
    # subject { "foobar" }
    #
    # it "isn't empty" do
    #   expect(subject.empty?).to be_false
    # end
    #
    # it "is six characters" do
    #   expect(subject.size).to eq(6)
    # end
    # ```
    #
    # By using a subject, some of the DSL becomes simpler.
    # For example, `ExampleDSL#is_expected` can be used
    # as short-hand for `expect(subject)`.
    # ```
    # subject { "foobar" }
    #
    # it "isn't empty" do
    #   is_expected.to_not be_empty
    # end
    # ```
    #
    # This macro is functionaly equivalent to:
    # ```
    # let(:subject) { "foo" }
    # ```
    #
    # The subject is created the first time it is referenced (lazy initialization).
    # It is cached so that the same instance is used throughout the test.
    # The subject will be recreated for each test it is used in.
    #
    # ```
    # subject { [0, 1, 2] }
    #
    # it "modifies the array" do
    #   subject[0] = 42
    #   is_expected.to eq([42, 1, 2])
    # end
    #
    # it "doesn't carry across tests" do
    #   subject[1] = 777
    #   is_expected.to eq([0, 777, 2])
    # end
    # ```
    macro subject(&block)
      let(:subject) {{block}}
    end

    # Defines a value by name.
    # The name can be used in examples to retrieve the value (basically a method).
    # This can be used to define a value once and reuse it in multiple examples.
    #
    # This macro expects a name and a block.
    # The name can be a symbol or a literal - same as `Object#getter`.
    # The block should return the value.
    #
    # For instance:
    # ```
    # let(string) { "foobar" }
    #
    # it "isn't empty" do
    #   expect(string.empty?).to be_false
    # end
    #
    # it "is six characters" do
    #   expect(string.size).to eq(6)
    # end
    # ```
    #
    # The value is lazy-evaluated -
    # meaning that it is only created on the first reference to it.
    # Afterwards, the value is cached,
    # so the same value is returned with consecutive calls.
    #
    # ```
    # let(current_time) { Time.now }
    #
    # it "lazy evaluates" do
    #   now = current_time
    #   sleep 5
    #   expect(current_time).to eq(now)
    # end
    # ```
    #
    # However, the value is not reused across tests.
    # It will be reconstructed the first time it is referenced in the next test.
    #
    # ```
    # let(array) { [0, 1, 2] }
    #
    # it "modifies the array" do
    #   array[0] = 42
    #   expect(array).to eq([42, 1, 2])
    # end
    #
    # it "doesn't carry across tests" do
    #   array[1] = 777
    #   expect(array).to eq([0, 777, 2])
    # end
    # ```
    macro let(name, &block)
      # Create a block that returns the value.
      let!(%value) {{block}}

      # Wrapper to hold the value.
      # This will be `nil` if the value hasn't been referenced yet.
      # After being referenced, the cached value will be stored in a wrapper.
      @%wrapper : ::Spectator::Internals::ValueWrapper?

      # Method for returning the value.
      def {{name.id}}
        # Check if the value is cached.
        # The wrapper will be `nil` if it isn't.
        if (wrapper = @%wrapper)
          # It is cached, return that value.
          # Unwrap it from the wrapper variable.
          # Here we use `typeof(METHOD)` to get around the issue
          # that the macro has no idea what type the value is.
          wrapper.unsafe_as(::Spectator::Internals::TypedValueWrapper(typeof(%value))).value
        else
          # The value isn't cached,
          # Construct it and store it in the wrapper.
          %value.tap do |value|
            @%wrapper = ::Spectator::Internals::TypedValueWrapper(typeof(%value)).new(value)
          end
        end
      end
    end

    # The noisier sibling to `#let`.
    # Defines a value by giving it a name.
    # The name can be used in examples to retrieve the value (basically a method).
    # This can be used to define a value once and reuse it in multiple examples.
    #
    # This macro expects a name and a block.
    # The name can be a symbol or a literal - same as `Object#getter`.
    # The block should return the value.
    #
    # For instance:
    # ```
    # let!(string) { "foobar" }
    #
    # it "isn't empty" do
    #   expect(string.empty?).to be_false
    # end
    #
    # it "is six characters" do
    #   expect(string.size).to eq(6)
    # end
    # ```
    #
    # The value is lazy-evaluated -
    # meaning that it is only created when it is referenced.
    # Unlike `#let`, the value is not cached and is recreated on each call.
    #
    # ```
    # let!(current_time) { Time.now }
    #
    # it "lazy evaluates" do
    #   now = current_time
    #   sleep 5
    #   expect(current_time).to_not eq(now)
    # end
    # ```
    macro let!(name, &block)
      def {{name.id}}
        {{block.body}}
      end
    end

    # Creates a hook that will run prior to any example in the group.
    # The block of code given to this macro is used for the hook.
    # The hook is executed only once.
    # If the hook raises an exception,
    # the current example will be skipped and marked as an error.
    #
    # NOTE: Inside a `#given` block, the hook is run once, not once per iteration.
    #
    # This can be useful to initialize something before testing:
    # ```
    # before_all { Thing.start } # 1
    #
    # it "does something" do
    #   # 2
    # end
    # ```
    #
    # The hook cannot use values and methods in the group like examples can.
    # This is because the hook is not associated with one example, but many.
    # ```
    # let(array) { [1, 2, 3] }
    # before_all { array << 4 } # *ERROR!*
    # ```
    #
    # If multiple `#before_all` blocks are specified,
    # then they are run in the order they were defined.
    # ```
    # before_all { Thing.first }  # 1
    # before_all { Thing.second } # 2
    # ```
    #
    # With nested groups, the outer blocks will run first.
    # ```
    # describe Something do
    #   before_all { Something.start } # 1
    #
    #   describe "#foo" do
    #     before_all { Something.foo } # 2
    #
    #     it "does a cool thing" do
    #       # 3
    #     end
    #   end
    # end
    # ```
    #
    # See also: `#before_each`, `#after_all`, `#after_each`, and `#around_each`.
    macro before_all(&block)
      ::Spectator::DSL::Builder.add_before_all_hook {{block}}
    end

    # Creates a hook that will run prior to every example in the group.
    # The block of code given to this macro is used for the hook.
    # The hook is executed once per example in the group (and sub-groups).
    # If the hook raises an exception,
    # the current example will be skipped and marked as an error.
    #
    # NOTE: Inside a `#given` block, the hook is run before every example of every iteration.
    #
    # This can be useful for setting up environments for tests:
    # ```
    # before_each { Thing.start } # 1
    #
    # it "does something" do
    #   # 2
    # end
    # ```
    #
    # Currently, the hook cannot use values and methods in the group like examples can.
    # This is a planned feature.
    # ```
    # let(array) { [1, 2, 3] }
    # before_each { array << 4 } # *DOES NOT WORK YET!*
    # ```
    #
    # This could also be used to verify pre-conditions:
    # ```
    # before_each { is_expected.to_not be_nil } # *DOES NOT WORK YET!*
    # ```
    #
    # If multiple `#before_each` blocks are specified,
    # then they are run in the order they were defined.
    # ```
    # before_each { Thing.first }  # 1
    # before_each { Thing.second } # 2
    # ```
    #
    # With nested groups, the outer blocks will run first.
    # ```
    # describe Something do
    #   before_each { Something.start } # 1
    #
    #   describe "#foo" do
    #     before_each { Something.foo } # 2
    #
    #     it "does a cool thing" do
    #       # 3
    #     end
    #   end
    # end
    # ```
    #
    # See also: `#before_all`, `#after_all`, `#after_each`, and `#around_each`.
    macro before_each(&block)
      ::Spectator::DSL::Builder.add_before_each_hook {{block}}
    end

    # Creates a hook that will run following all examples in the group.
    # The block of code given to this macro is used for the hook.
    # The hook is executed only once.
    # Even if an example fails or raises an error, the hook will run.
    #
    # NOTE: Inside a `#given` block, the hook is run once, not once per iteration.
    #
    # This can be useful to cleanup after testing:
    # ```
    # after_all { Thing.stop } # 2
    #
    # it "does something" do
    #   # 1
    # end
    # ```
    #
    # The hook cannot use values and methods in the group like examples can.
    # This is because the hook is not associated with one example, but many.
    # ```
    # let(array) { [1, 2, 3] }
    # after_all { array << 4 } # *ERROR!*
    # ```
    #
    # If multiple `#after_all` blocks are specified,
    # then they are run in the order they were defined.
    # ```
    # after_all { Thing.first }  # 1
    # after_all { Thing.second } # 2
    # ```
    #
    # With nested groups, the inner blocks will run first.
    # ```
    # describe Something do
    #   after_all { Something.cleanup } # 3
    #
    #   describe "#foo" do
    #     after_all { Something.stop } # 2
    #
    #     it "does a cool thing" do
    #       # 1
    #     end
    #   end
    # end
    # ```
    #
    # See also: `#before_all`, `#before_each`, `#after_each`, and `#around_each`.
    macro after_all(&block)
      ::Spectator::DSL::Builder.add_after_all_hook {{block}}
    end

    # Creates a hook that will run following every example in the group.
    # The block of code given to this macro is used for the hook.
    # The hook is executed once per example in the group (and sub-groups).
    # Even if an example fails or raises an error, the hook will run.
    #
    # NOTE: Inside a `#given` block, the hook is run after every example of every iteration.
    #
    # This can be useful for cleaning up environments after tests:
    # ```
    # after_each { Thing.stop } # 2
    #
    # it "does something" do
    #   # 1
    # end
    # ```
    #
    # Currently, the hook cannot use values and methods in the group like examples can.
    # This is a planned feature.
    # ```
    # let(array) { [1, 2, 3] }
    # after_each { array << 4 } # *DOES NOT WORK YET!*
    # ```
    #
    # This could also be used to verify post-conditions:
    # ```
    # after_each { is_expected.to_not be_nil } # *DOES NOT WORK YET!*
    # ```
    #
    # If multiple `#after_each` blocks are specified,
    # then they are run in the order they were defined.
    # ```
    # after_each { Thing.first }  # 1
    # after_each { Thing.second } # 2
    # ```
    #
    # With nested groups, the inner blocks will run first.
    # ```
    # describe Something do
    #   after_each { Something.cleanup } # 3
    #
    #   describe "#foo" do
    #     after_each { Something.stop } # 2
    #
    #     it "does a cool thing" do
    #       # 1
    #     end
    #   end
    # end
    # ```
    #
    # See also: `#before_all`, `#before_each`, `#after_all`, and `#around_each`.
    macro after_each(&block)
      ::Spectator::DSL::Builder.add_after_each_hook {{block}}
    end

    # Creates a hook that will run for every example in the group.
    # This can be used as an alternative to `#before_each` and `#after_each`.
    # The block of code given to this macro is used for the hook.
    # The hook is executed once per example in the group (and sub-groups).
    # If the hook raises an exception,
    # the current example will be skipped and marked as an error.
    #
    # Sometimes the test code must run in a block:
    # ```
    # around_each do |proc|
    #   Thing.run do
    #     proc.call
    #   end
    # end
    #
    # it "does something" do
    #   # ...
    # end
    # ```
    #
    # The block argument is given a `Proc`.
    # To run the example, that proc must be called.
    # Make sure to call it!
    # ```
    # around_each do |proc|
    #   Thing.run
    #   # Missing proc.call
    # end
    #
    # it "does something" do
    #   # Whoops! This is never run.
    # end
    # ```
    #
    # If multiple `#around_each` blocks are specified,
    # then they are run in the order they were defined.
    # ```
    # around_each { |p| p.call } # 1
    # around_each { |p| p.call } # 2
    # ```
    #
    # With nested groups, the outer blocks will run first.
    # But the return from calling the proc will be in the oposite order.
    # ```
    # describe Something do
    #   around_each do |proc|
    #     Thing.foo # 1
    #     proc.call
    #     Thing.bar # 5
    #   end
    #
    #   describe "#foo" do
    #     around_each do |proc|
    #       Thing.foo # 2
    #       proc.call
    #       Thing.bar # 4
    #     end
    #
    #     it "does a cool thing" do
    #       # 3
    #     end
    #   end
    # end
    # ```
    #
    # See also: `#before_all`, `#before_each`, `#after_all`, and `#after_each`.
    macro around_each(&block)
      ::Spectator::DSL::Builder.add_around_each_hook {{block}}
    end

    # Creates an example, or a test case.
    # The `what` argument describes "what" is being tested or asserted.
    # The block contains the code to run the test.
    # One or more expectations should be in the block.
    #
    # ```
    # it "can do math" do
    #   expect(1 + 2).to eq(3)
    # end
    # ```
    #
    # See `ExampleDSL` and `MatcherDSL` for additional macros and methods
    # that can be used in example code blocks.
    macro it(what, &block)
      # Create the wrapper class for the test code.
      _spectator_example_wrapper(Wrapper%example, %run) {{block}}

      # Create a class derived from `RunnableExample` to run the test code.
      _spectator_example(Example%example, Wrapper%example, ::Spectator::RunnableExample, {{what}}) do
        # Implement abstract method to run the wrapped example block.
        protected def run_instance
          @instance.%run
        end
      end

      # Add the example to the current group.
      ::Spectator::DSL::Builder.add_example(Example%example)
    end

    # Creates an example, or a test case, that does not run.
    # This can be used to prototype functionality that isn't ready.
    # The `what` argument describes "what" is being tested or asserted.
    # The block contains the code to run the test.
    # One or more expectations should be in the block.
    #
    # ```
    # pending "something that isn't implemented yet" do
    #   # ...
    # end
    # ```
    #
    # See `ExampleDSL` and `MatcherDSL` for additional macros and methods
    # that can be used in example code blocks.
    #
    # NOTE: Crystal appears to "lazily" compile code.
    # Any code that isn't referenced seems to be ignored.
    # Sometimes syntax, type, and other compile-time errors
    # can occur in unreferenced code and won't be caught by the compiler.
    # By creating a `#pending` test, the code will be referenced.
    # Thus, forcing the compiler to at least process the code, even if it isn't run.
    macro pending(what, &block)
      # Create the wrapper class for the test code.
      _spectator_example_wrapper(Wrapper%example, %run) {{block}}

      # Create a class derived from `PendingExample` to skip the test code.
      _spectator_example(Example%example, Wrapper%example, ::Spectator::PendingExample, {{what}})

      # Add the example to the current group.
      ::Spectator::DSL::Builder.add_example(Example%example)
    end

    # Creates a wrapper class for test code.
    # The class serves multiple purposes, mostly dealing with scope.
    # 1. Include the parent modules as mix-ins.
    # 2. Enable DSL specific to examples.
    # 3. Isolate methods in `Example` from the test code.
    #
    # Since the names are generated, and macros can't return values,
    # the names for everything must be passed in as arguments.
    # The `class_name` argument is the name of the class to define.
    # The `run_method_name` argument is the name of the method in the wrapper class
    # that will actually run the test code.
    # The block passed to this macro is the actual test code.
    private macro _spectator_example_wrapper(class_name, run_method_name, &block)
      # Wrapper class for isolating the test code.
      struct {{class_name.id}}
        # Mix in methods and macros specifically for example DSL.
        include ::Spectator::DSL::ExampleDSL

        # Include the parent (example group) context.
        include {{@type.id}}

        # Initializer that accepts sample values.
        # The sample values are passed upward to the group modules.
        # Any module that adds sample values can pull their values from this instance.
        def initialize(sample_values : ::Spectator::Internals::SampleValues)
          super
        end

        # Generated method for actually running the test code.
        def {{run_method_name.id}}
          {{block.body}}
        end
      end
    end

    # Creates an example class.
    # Since the names are generated, and macros can't return values,
    # the names for everything must be passed in as arguments.
    # The `example_class_name` argument is the name of the class to define.
    # The `wrapper_class_name` argument is the name of the wrapper class to reference.
    # This must be the same as `class_name` for `#_spectator_example_wrapper`.
    # The `base_class` argument specifies which type of example class the new class should derive from.
    # This should typically be `RunnableExample` or `PendingExample`.
    # The `what` argument is the description passed to the `#it` or `#pending` block.
    # And lastly, the block given is any additional content to put in the class.
    # For instance, to define a method in the class, do it in the block.
    # ```
    # _spectator_example(Example123, Wrapper123, RunnableExample, "does something") do
    #   def something
    #     # This method is defined in the Example123 class.
    #   end
    # end
    # ```
    # If nothing is needed, omit the block.
    private macro _spectator_example(example_class_name, wrapper_class_name, base_class, what, &block)
      # Example class containing meta information and instructions for running the test.
      class {{example_class_name.id}} < {{base_class.id}}
        # Stores the group the example belongs to
        # and sample values specific to this instance of the test.
        # This method's signature must match the one used in `ExampleFactory#build`.
        def initialize(group : ::Spectator::ExampleGroup, sample_values : ::Spectator::Internals::SampleValues)
          super
          @instance = {{wrapper_class_name.id}}.new(sample_values)
        end

        # Add the block's content if one was provided.
        {% if block.is_a?(Block) %}
          {{block.body}}
        {% end %}

        # Description for the test.
        def what
          {{what.is_a?(StringLiteral) ? what : what.stringify}}
        end
      end
    end
  end
end
