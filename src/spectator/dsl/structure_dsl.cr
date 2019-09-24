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
  # ```
  #
  # becomes...
  #
  # ```
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
  #     @instance = Test123.new(sample_values)
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
  #     @instance._run123
  #   end
  # end
  #
  # # Wrapper class for the example code.
  # # This isolates it from Spectator's internals.
  # class Test123
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
  # ```
  #
  # becomes...
  #
  # ```
  # # describe "#foo"
  # module Context123
  #   # Start a new group.
  #   # More on this in a bit.
  #   Builder.start_group("#foo")
  #
  #   def subject
  #     described_class.foo(value)
  #   end
  #
  #   # context "when given :bar"
  #   module Context456
  #     include Context123 # Inherit parent module.
  #
  #     # Start a nested group.
  #     Builder.start_group("when given :bar")
  #
  #     def value
  #       :bar
  #     end
  #
  #     # Wrapper class for the test case.
  #     class Test456
  #       include Context456 # Include context.
  #
  #       # Rest of test code...
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
    # Creates a new example group to describe a component.
    # The *what* argument describes "what" is being tested.
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
    # the *what* parameter doesn't need to be quoted.
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
    # The *what* argument describes the scenario or case being tested.
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
      module Context%context
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
          macro described_class
            {{what}}
          end

          # Implicit subject definition.
          # Simply creates a new instance of the described type.
          def subject(*args)
            described_class.new(*args)
          end
        {% end %}

        # Start a new group.
        ::Spectator::DSL::Builder.start_group(
          {% if what.is_a?(StringLiteral) %}
            {% if what.starts_with?("#") || what.starts_with?(".") %}
              {{what.id.symbolize}}
            {% else %}
              {{what}}
            {% end %}
          {% else %}
            {{what.symbolize}}
          {% end %}
        )

        # Nest the block's content in the module.
        {{block.body}}

        # End the current group.
        ::Spectator::DSL::Builder.end_group
      end
    end

    # Creates an example group with a very concise syntax.
    # This can be used in scenarios where one or more input values
    # change the result of various methods.
    # The normal DSL can be used within this context,
    # but a shorter syntax provides an easier way to read and write multiple tests.
    #
    # Here's an example of where this is useful:
    # ```
    # describe Int32 do
    #   subject { described_class.new(value) }
    #
    #   context "when given 5" do
    #     describe "#odd?" do
    #       subject { value.odd? }
    #
    #       it "is true" do
    #         is_expected.to be_true
    #       end
    #
    #       # NOTE: These could also be the one-liner syntax,
    #       # but that is still very verbose.
    #     end
    #
    #     describe "#even?" do
    #       subject { value.even? }
    #
    #       it "is false" do
    #         is_expected.to be_false
    #       end
    #     end
    #   end
    #
    #   context "when given 42" do
    #     describe "#odd?" do
    #       subject { value.odd? }
    #
    #       it "is false" do
    #         is_expected.to be_false
    #       end
    #     end
    #
    #     describe "#even?" do
    #       subject { value.even? }
    #
    #       it "is true" do
    #         is_expected.to be_true
    #       end
    #     end
    #   end
    # end
    # ```
    #
    # There's a lot of repetition and nested groups
    # to test a very simple scenario.
    #
    # Using a `#given` block, this type of scenario becomes much more compact.
    # ```
    # describe Int32 do
    #   subject { described_class.new(value) }
    #
    #   given value = 5 do
    #     expect(&.odd?).to be_true
    #     expect(&.even?).to be_false
    #   end
    #
    #   given value = 42 do
    #     expect(&.odd?).to be_false
    #     expect(&.even?).to be_true
    #   end
    # end
    # ```
    #
    # One or more assignments can be used.
    # Each assignment is passed to its own `#let`.
    # For example:
    # ```
    # given x = 1, y = 2 do
    #   expect(x + y).to eq(3)
    # end
    # ```
    #
    # Each statement in the block is converted to the one-liner syntax of `#it`.
    # For instance:
    # ```
    # given x = 1 do
    #   expect(x).to eq(1)
    # end
    # ```
    # is converted to:
    # ```
    # context "x = 1" do
    #   let(x) { 1 }
    #
    #   it expect(x).to eq(1)
    # end
    # ```
    #
    # Additionally, the "it" syntax can be used and mixed in.
    # This allows for flexibility and a more readable format when needed.
    # ```
    # given x = 1 do
    #   it "is odd" do
    #     expect(x.odd?).to be_true
    #   end
    #
    #   it is(&.odd?)
    # end
    # ```
    macro given(*assignments, &block)
      context({{assignments.splat.stringify}}) do
        # Create a `let` entry for each assignment.
        {% for assignment in assignments %}
          let({{assignment.target}}) { {{assignment.value}} }
        {% end %}

        # Trick to get the contents of the block as an array of nodes.
        # If there are multiple expressions/statements in the block,
        # then the body will be a `Expressions` type.
        # If there's only one expression, then the body is just that.
        {%
          body = if block.is_a?(Nop)
                   raise "Missing body for given block"
                 elsif block.body.is_a?(Expressions)
                   # Get the expressions, which is already an array.
                   block.body.expressions
                 else
                   # Wrap the expression in an array.
                   [block.body]
                 end
        %}

        # Transform every item in the block to a test case.
        {% for item in body %}
          # If the item starts with "it", then leave it as-is.
          # Otherwise, prefix it with "it"
          # and treat it as the one-liner "it" syntax.
          {% if item.is_a?(Call) && item.name == "it".id %}
            {{item}}
          {% else %}
            it {{item}}
          {% end %}
        {% end %}
      end
    end

    # Creates a new example group to test multiple values with.
    # This method takes a collection of values
    # and repeats the contents of the block with each value.
    # The *collection* argument should be a literal collection,
    # such as an array, or a function that returns an enumerable.
    # Additionally, a count may be specified to limit the number of values tested.
    #
    # NOTE: If an infinite enumerable is provided for the collection,
    # then a count must be specified.
    # Only the first *count* items will be used.
    #
    # The block can accept an argument.
    # If it does, then the argument's name is used to reference
    # the current item in the collection.
    # If an argument isn't provided, then *value* can be used instead.
    #
    # Example with a block argument:
    # ```
    # sample some_integers do |integer|
    #   it "sets the value" do
    #     subject.value = integer
    #     expect(subject.value).to eq(integer)
    #   end
    # end
    # ```
    #
    # Same spec, but without a block argument:
    # ```
    # sample some_integers do
    #   it "sets the value" do
    #     subject.value = value
    #     expect(subject.value).to eq(value)
    #   end
    # end
    # ```
    #
    # In the examples above, the test case (`#it` block)
    # is repeated for each element in *some_integers*.
    # *some_integers* is a ficticous collection.
    # The collection will be iterated once.
    # `#sample` and `#random_sample` blocks can be nested,
    # and work similarly to loops.
    #
    # A limit can be specified as well.
    # After the collection, a count can be added to limit
    # the number of items taken from the collection.
    # For instance:
    # ```
    # sample some_integers, 5 do |integer|
    #   it "sets the value" do
    #     subject.value = integer
    #     expect(subject.value).to eq(integer)
    #   end
    # end
    # ```
    #
    # See also: `#random_sample`
    macro sample(collection, count = nil, &block)
      # Figure out the name to use for the current collection element.
      # If a block argument is provided, use it, otherwise use "value".
      {% name = block.args.empty? ? "value".id : block.args.first %}

      # Method for retrieving the entire collection.
      # This simplifies getting the element type.
      # The name is uniquely generated to prevent namespace collision.
      # This method should be called only once.
      def %sample
        {{collection}}
      end

      # Class for generating an array with the collection's contents.
      # This has to be a class that includes the parent module.
      # The collection could reference a helper method
      # or anything else in the parent scope.
      class Sample%sample
        # Include the parent module.
        include {{@type.id}}

        # Placeholder initializer.
        # This is needed because examples and groups call super in their initializer.
        # Those initializers pass the sample values upward through their hierarchy.
        def initialize(_sample_values : ::Spectator::Internals::SampleValues)
          super
        end

        # Method that returns an array containing the collection.
        # This method should be called only once.
        # The framework stores the collection as an array for a couple of reasons.
        # 1. The collection may not support multiple iterations.
        # 2. The collection might contain randomly generated values.
        #    Iterating multiple times would generate inconsistent values at runtime.
        def %to_a
          # If a count was provided,
          # only select the first *count* items from the collection.
          # Otherwise, select all of them.
          {% if count %}
            %sample.first({{count}})
          {% else %}
            %sample.to_a
          {% end %}
        end
      end

      # Module for the context.
      # The module uses a generated unique name.
      module Context%sample
        # Include the parent module.
        # Since @type resolves immediately,
        # this will reference the parent type.
        include {{@type.id}}

        # Value wrapper for the current element.
        @%wrapper : ::Spectator::Internals::ValueWrapper

        # Retrieves the current element from the collection.
        def {{name}}
          # Unwrap the value and return it.
          # The `Enumerable#first` method has a return type that matches the element type.
          # So it is used on the collection method proxy to resolve the type at compile-time.
          @%wrapper.as(::Spectator::Internals::TypedValueWrapper(typeof(%sample.first))).value
        end

        # Initializer to extract current element of the collection from sample values.
        def initialize(sample_values : ::Spectator::Internals::SampleValues)
          super
          @%wrapper = sample_values.get_wrapper(:%sample)
        end

        # Start a new example group.
        # Sample groups require additional configuration.
        ::Spectator::DSL::Builder.start_sample_group(
          {{collection.stringify}},          # String representation of the collection.
          Sample%sample,                     # Type that can construct the elements.
          ->(s : Sample%sample) { s.%to_a }, # Proc to build the array of elements in the collection.
          {{name.stringify}},                # Name for the current element.
          :%sample                           # Unique identifier for retrieving elements for the associated collection.
        )

        # Nest the block's content in the module.
        {{block.body}}

        # End the current group.
        ::Spectator::DSL::Builder.end_group
      end
    end

    # Creates a new example group to test multiple random values with.
    # This method takes a collection of values and count
    # and repeats the contents of the block with each value.
    # This method randomly selects *count* items from the collection.
    # The *collection* argument should be a literal collection,
    # such as an array, or a function that returns an enumerable.
    #
    # NOTE: If an enumerable is used, it must be finite.
    #
    # The block can accept an argument.
    # If it does, then the argument's name is used to reference
    # the current item in the collection.
    # If an argument isn't provided, then *value* can be used instead.
    #
    # Example with a block argument:
    # ```
    # random_sample some_integers, 5 do |integer|
    #   it "sets the value" do
    #     subject.value = integer
    #     expect(subject.value).to eq(integer)
    #   end
    # end
    # ```
    #
    # Same spec, but without a block argument:
    # ```
    # random_sample some_integers, 5 do
    #   it "sets the value" do
    #     subject.value = value
    #     expect(subject.value).to eq(value)
    #   end
    # end
    # ```
    #
    # In the examples above, the test case (`#it` block)
    # is repeated for 5 random elements in *some_integers*.
    # *some_integers* is a ficticous collection.
    # The collection will be iterated once.
    # `#sample` and `#random_sample` blocks can be nested,
    # and work similarly to loops.
    #
    # NOTE: If the count is the same or higher
    # than the number of elements in the collection,
    # then this method if functionaly equivalent to `#sample`.
    #
    # See also: `#sample`
    macro random_sample(collection, count, &block)
      # Figure out the name to use for the current collection element.
      # If a block argument is provided, use it, otherwise use "value".
      {% name = block.args.empty? ? "value".id : block.args.first %}

      # Method for retrieving the entire collection.
      # This simplifies getting the element type.
      # The name is uniquely generated to prevent namespace collision.
      # This method should be called only once.
      def %sample
        {{collection}}
      end

      # Class for generating an array with the collection's contents.
      # This has to be a class that includes the parent module.
      # The collection could reference a helper method
      # or anything else in the parent scope.
      class Sample%sample
        # Include the parent module.
        include {{@type.id}}

        # Method that returns an array containing the collection.
        # This method should be called only once.
        # The framework stores the collection as an array for a couple of reasons.
        # 1. The collection may not support multiple iterations.
        # 2. The collection might contain randomly generated values.
        #    Iterating multiple times would generate inconsistent values at runtime.
        def %to_a
          %sample.to_a.sample({{count}}, ::Spectator.random)
        end
      end

      # Module for the context.
      # The module uses a generated unique name.
      module Context%sample
        # Include the parent module.
        # Since @type resolves immediately,
        # this will reference the parent type.
        include {{@type.id}}

        # Value wrapper for the current element.
        @%wrapper : ::Spectator::Internals::ValueWrapper

        # Retrieves the current element from the collection.
        def {{name}}
          # Unwrap the value and return it.
          # The `Enumerable#first` method has a return type that matches the element type.
          # So it is used on the collection method proxy to resolve the type at compile-time.
          @%wrapper.as(::Spectator::Internals::TypedValueWrapper(typeof(%sample.first))).value
        end

        # Initializer to extract current element of the collection from sample values.
        def initialize(sample_values : ::Spectator::Internals::SampleValues)
          super
          @%wrapper = sample_values.get_wrapper(:%sample)
        end

        # Start a new example group.
        # Sample groups require additional configuration.
        ::Spectator::DSL::Builder.start_sample_group(
          {{collection.stringify}}, # String representation of the collection.
          Sample%sample,            # All elements in the collection.
          {{name.stringify}},       # Name for the current element.
          :%sample                  # Unique identifier for retrieving elements for the associated collection.
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
    # The block should return the value of the subject.
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
    # For example, `ExampleDSL#is_expected` can be used.
    # ```
    # subject { "foobar" }
    #
    # it "isn't empty" do
    #   is_expected.to_not be_empty # is the same as:
    #   expect(subject).to_not be_empty
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

    # Explicitly defines the subject being tested.
    # The `#subject` method can be used in examples to retrieve the value (basically a method).
    # This also names the subject so that it can be referenced by the name instead.
    #
    # This macro expects a block.
    # The block should return the value of the subject.
    # This can be used to define a value once and reuse it in multiple examples.
    #
    # For instance:
    # ```
    # subject(string) { "foobar" }
    #
    # it "isn't empty" do
    #   # Refer to it with `subject`.
    #   expect(subject.empty?).to be_false
    # end
    #
    # it "is six characters" do
    #   # Refer to it by its name `string`.
    #   expect(string.size).to eq(6)
    # end
    # ```
    #
    # The subject is created the first time it is referenced (lazy initialization).
    # It is cached so that the same instance is used throughout the test.
    # The subject will be recreated for each test it is used in.
    macro subject(name, &block)
      let({{name.id}}) {{block}}
      subject { {{name.id}} }
    end

    # Defines an expression by name.
    # The name can be used in examples to retrieve the value (basically a method).
    # This can be used to define a value once and reuse it in multiple examples.
    #
    # There are two variants - assignment and block.
    # Both must be given a name.
    #
    # For the assignment variant:
    # ```
    # let string = "foobar"
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
    # The value is evaluated and stored immediately.
    # This is different from other `#let` variants that lazily-evaluate.
    #
    # ```
    # let current_time = Time.utc
    # let(lazy_time) { Time.utc }
    #
    # it "lazy evaluates" do
    #   sleep 5
    #   expect(lazy_time).to_not eq(now)
    # end
    # ```
    #
    # However, the value is not reused across tests.
    # Each test will have its own copy.
    #
    # ```
    # let array = [0, 1, 2]
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
    #
    # The block variant expects a name and a block.
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
    # let(current_time) { Time.utc }
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
      {% if block.is_a?(Nop) %}
        # Assignment variant.
        @%value = {{name.value}}

        def {{name.target}}
          @%value
        end
      {% else %}
        # Block variant.

        # Create a block that returns the value.
        let!(%value) {{block}}

        # Wrapper to hold the value.
        # This will be nil if the value hasn't been referenced yet.
        # After being referenced, the cached value will be stored in a wrapper.
        @%wrapper : ::Spectator::Internals::ValueWrapper?

        # Method for returning the value.
        def {{name.id}}
          # Check if the value is cached.
          # The wrapper will be nil if it isn't.
          if (wrapper = @%wrapper)
            # It is cached, return that value.
            # Unwrap it from the wrapper variable.
            # Here we use typeof to get around the issue
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
      {% end %}
    end

    # The noisier sibling to `#let`.
    # Defines an expression by giving it a name.
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
    # let!(current_time) { Time.utc }
    #
    # it "lazy evaluates" do
    #   now = current_time
    #   sleep 5
    #   expect(current_time).to_not eq(now)
    # end
    # ```
    macro let!(name)
      def {{name.id}}
        {{yield}}
      end
    end

    # Creates a hook that will run prior to any example in the group.
    # The block of code provided to this macro is used for the hook.
    # The hook is executed only once.
    # If the hook raises an exception,
    # the current example will be skipped and marked as an error.
    #
    # NOTE: Inside a `#sample` block, the hook is run once, not once per iteration.
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
    # NOTE: Pre-conditions should not be checked in a `#before_all` or related block.
    # Errors that occur in a `#before_all` block will halt testing and abort with an error.
    # Use `#pre_condition` instead for pre-test checks.
    #
    # See also: `#before_each`, `#after_all`, `#after_each`, and `#around_each`.
    macro before_all(&block)
      ::Spectator::DSL::Builder.add_before_all_hook {{block}}
    end

    # Creates a hook that will run prior to every example in the group.
    # The block of code provided to this macro is used for the hook.
    # The hook is executed once per example in the group (and sub-groups).
    # If the hook raises an exception,
    # the current example will be skipped and marked as an error.
    #
    # NOTE: Inside a `#sample` block, the hook is run before every example of every iteration.
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
    # The hook can use values and methods in the group like examples can.
    # It is called in the same scope as the example code.
    # ```
    # let(array) { [1, 2, 3] }
    # before_each { array << 4 }
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
    # NOTE: Pre-conditions should not be checked in a `#before_each` or related block.
    # Errors that occur in a `#before_each` block will halt testing and abort with an error.
    # Use `#pre_condition` instead for pre-test checks.
    #
    # See also: `#before_all`, `#after_all`, `#after_each`, and `#around_each`.
    macro before_each
      # Before each hook.
      # Defined as a method so that it can access the same scope as the example code.
      def %hook : Nil
        {{yield}}
      end

      ::Spectator::DSL::Builder.add_before_each_hook do
        # Get the wrapper instance and cast to current group type.
        example = ::Spectator::Internals::Harness.current.example
        instance = example.instance.as({{@type.id}})
        instance.%hook
      end
    end

    # Creates a hook that will run following all examples in the group.
    # The block of code provided to this macro is used for the hook.
    # The hook is executed only once.
    # Even if an example fails or raises an error, the hook will run.
    #
    # NOTE: Inside a `#sample` block, the hook is run once, not once per iteration.
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
    # NOTE: Post-conditions should not be checked in an `#after_all` or related block.
    # Errors that occur in an `#after_all` block will halt testing and abort with an error.
    # Use `#post_condition` instead for post-test checks.
    #
    # See also: `#before_all`, `#before_each`, `#after_each`, and `#around_each`.
    macro after_all(&block)
      ::Spectator::DSL::Builder.add_after_all_hook {{block}}
    end

    # Creates a hook that will run following every example in the group.
    # The block of code provided to this macro is used for the hook.
    # The hook is executed once per example in the group (and sub-groups).
    # Even if an example fails or raises an error, the hook will run.
    #
    # NOTE: Inside a `#sample` block, the hook is run after every example of every iteration.
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
    # The hook can use values and methods in the group like examples can.
    # It is called in the same scope as the example code.
    # ```
    # let(array) { [1, 2, 3] }
    # after_each { array << 4 }
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
    # NOTE: Post-conditions should not be checked in an `#after_each` or related block.
    # Errors that occur in an `#after_each` block will halt testing and abort with an error.
    # Use `#post_condition` instead for post-test checks.
    #
    # See also: `#before_all`, `#before_each`, `#after_all`, and `#around_each`.
    macro after_each
      # After each hook.
      # Defined as a method so that it can access the same scope as the example code.
      def %hook : Nil
        {{yield}}
      end

      ::Spectator::DSL::Builder.add_after_each_hook do
        # Get the wrapper instance and cast to current group type.
        example = ::Spectator::Internals::Harness.current.example
        instance = example.instance.as({{@type.id}})
        instance.%hook
      end
    end

    # Creates a hook that will run for every example in the group.
    # This can be used as an alternative to `#before_each` and `#after_each`.
    # The block of code provided to this macro is used for the hook.
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
    # The block argument is provided a `Proc`.
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
    # The hook can use values and methods in the group like examples can.
    # It is called in the same scope as the example code.
    # ```
    # let(array) { [1, 2, 3] }
    # around_each do |proc|
    #   array << 4
    #   proc.call
    #   array.pop
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
    # NOTE: Pre- and post-conditions should not be checked in an `#around_each` or similar block.
    # Errors that occur in an `#around_each` block will halt testing and abort with an error.
    # Use `#pre_condition` and `#post_condition` instead for pre- and post-test checks.
    #
    # See also: `#before_all`, `#before_each`, `#after_all`, and `#after_each`.
    macro around_each(&block)
      # Around each hook.
      # Defined as a method so that it can access the same scope as the example code.
      def %hook({{block.args.splat}}) : Nil
        {{yield}}
      end

      ::Spectator::DSL::Builder.add_around_each_hook do |proc|
        # Get the wrapper instance and cast to current group type.
        example = ::Spectator::Internals::Harness.current.example
        instance = example.instance.as({{@type.id}})
        instance.%hook(proc)
      end
    end

    # Defines a block of code to run prior to every example in the group.
    # The condition is executed once per example in the group (and sub-groups).
    # If the condition fails, then the example fails.
    #
    # NOTE: Inside a `#sample` block, the condition is checked before every example of every iteration.
    #
    # This can be useful for ensuring the state before a test.
    # ```
    # pre_condition { expect(array).to_not be_nil }
    #
    # it "is the correct length" do
    #   expect(array.size).to eq(3)
    # end
    # ```
    #
    # The condition can use values and methods in the group like examples can.
    # It is called in the same scope as the example code.
    # ```
    # let(array) { [1, 2, 3] }
    # pre_condition { expect(array.size).to eq(3) }
    # ```
    #
    # If multiple `#pre_condition` blocks are specified,
    # then they are run in the order they were defined.
    # ```
    # pre_condition { expect(array).to_not be_nil } # 1
    # pre_condition { expect(array.size).to eq(3) } # 2
    # ```
    #
    # With nested groups, the outer blocks will run first.
    # ```
    # describe Something do
    #   pre_condition { is_expected.to_not be_nil } # 1
    #
    #   describe "#foo" do
    #     pre_condition { expect(subject.foo).to_not be_nil } # 2
    #
    #     it "does a cool thing" do
    #       # 3
    #     end
    #   end
    # end
    # ```
    #
    # See also: `#post_condition`.
    macro pre_condition
      # Pre-condition check.
      def %condition : Nil
        {{yield}}
      end

      ::Spectator::DSL::Builder.add_pre_condition do
        example = ::Spectator::Internals::Harness.current.example
        instance = example.instance.as({{@type.id}})
        instance.%condition
      end
    end

    # Defines a block of code to run after every example in the group.
    # The condition is executed once per example in the group (and sub-groups).
    # If the condition fails, then the example fails.
    #
    # NOTE: Inside a `#sample` block, the condition is checked before every example of every iteration.
    #
    # This can be useful for ensuring the state after a test.
    # ```
    # # The variable x shouldn't be modified if an error is raised.
    # post_condition { expect(x).to eq(original_x) }
    #
    # it "raises on divide by zero" do
    #   expect_raises { x /= 0 }
    # end
    # ```
    #
    # The condition can use values and methods in the group like examples can.
    # It is called in the same scope as the example code.
    # ```
    # let(array) { [1, 2, 3] }
    # post_condition { expect(array.size).to eq(3) }
    # ```
    #
    # If multiple `#post_condition` blocks are specified,
    # then they are run in the order they were defined.
    # ```
    # post_condition { expect(array).to_not be_nil } # 1
    # post_condition { expect(array.size).to eq(3) } # 2
    # ```
    #
    # With nested groups, the inner blocks will run first.
    # ```
    # describe Something do
    #   post_condition { is_expected.to_not be_nil } # 3
    #
    #   describe "#foo" do
    #     post_condition { expect(subject.foo).to_not be_nil } # 2
    #
    #     it "does a cool thing" do
    #       # 1
    #     end
    #   end
    # end
    # ```
    #
    # See also: `#pre_condition`.
    macro post_condition
      # Post-condition check.
      def %condition : Nil
        {{yield}}
      end

      ::Spectator::DSL::Builder.add_post_condition do
        example = ::Spectator::Internals::Harness.current.example
        instance = example.instance.as({{@type.id}})
        instance.%condition
      end
    end

    # Creates an example, or a test case.
    # The *what* argument describes "what" is being tested or asserted.
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
    #
    # A short-hand, one-liner syntax can also be used.
    # Typically, this is combined with `#subject`.
    # For instance:
    # ```
    # subject { 1 + 2 }
    # it is_expected.to eq(3)
    # ```
    macro it(what, _source_file = __FILE__, _source_line = __LINE__, &block)
      # Create the wrapper class for the test code.
      {% if block.is_a?(Nop) %}
        {% if what.is_a?(Call) %}
          _spectator_test(Test%example, %run) do
            {{what}}
          end
        {% else %}
          {% raise "Unrecognized syntax: `it #{what}`" %}
        {% end %}
      {% else %}
        _spectator_test(Test%example, %run) {{block}}
      {% end %}

      # Create a class derived from `RunnableExample` to run the test code.
      _spectator_example(Example%example, Test%example, ::Spectator::RunnableExample, {{what}}) do
        # Source where the example originated from.
        def source : ::Spectator::Source
          ::Spectator::Source.new({{_source_file}}, {{_source_line}})
        end

        # Implement abstract method to run the wrapped example block.
        protected def run_instance
          @instance.%run
        end
      end

      # Add the example to the current group.
      ::Spectator::DSL::Builder.add_example(Example%example)
    end

    # Creates an example, or a test case.
    # The block contains the code to run the test.
    # One or more expectations should be in the block.
    #
    # ```
    # it { expect(1 + 2).to eq(3) }
    # ```
    #
    # See `ExampleDSL` and `MatcherDSL` for additional macros and methods
    # that can be used in example code blocks.
    #
    # A short-hand, one-liner syntax can also be used.
    # Typically, this is combined with `#subject`.
    # For instance:
    # ```
    # subject { 1 + 2 }
    # it is_expected.to eq(3)
    # ```
    macro it(&block)
      it({{block.body.stringify}}) {{block}}
    end

    # An alternative way to write an example.
    # This is identical to `#it`.
    macro specify(what, &block)
      it({{what}}) {{block}}
    end

    # An alternative way to write an example.
    # This is identical to `#it`,
    # except that it doesn't take a "what" argument.
    macro specify(&block)
      it({{block.body.stringify}}) {{block}}
    end

    # Creates an example, or a test case, that does not run.
    # This can be used to prototype functionality that isn't ready.
    # The *what* argument describes "what" is being tested or asserted.
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
    macro pending(what, _source_file = __FILE__, _source_line = __LINE__, &block)
      # Create the wrapper class for the test code.
      _spectator_test(Test%example, %run) {{block}}

      # Create a class derived from `PendingExample` to skip the test code.
      _spectator_example(Example%example, Test%example, ::Spectator::PendingExample, {{what}}) do
        # Source where the example originated from.
        def source : ::Spectator::Source
          ::Spectator::Source.new({{_source_file}}, {{_source_line}})
        end
      end

      # Add the example to the current group.
      ::Spectator::DSL::Builder.add_example(Example%example)
    end

    # Creates an example, or a test case, that does not run.
    # This can be used to prototype functionality that isn't ready.
    # The *what* argument describes "what" is being tested or asserted.
    # The block contains the code to run the test.
    # One or more expectations should be in the block.
    #
    # ```
    # pending do
    #   # Something that isn't implemented yet.
    # end
    # ```
    macro pending(&block)
      peding({{block.body.stringify}}) {{block}}
    end

    # Same as `#pending`.
    # Included for compatibility with RSpec.
    macro skip(what, &block)
      pending({{what}}) {{block}}
    end

    # Same as `#pending`.
    # Included for compatibility with RSpec.
    macro skip(&block)
      pending({{block.body.stringify}}) {{block}}
    end

    # Same as `#pending`.
    # Included for compatibility with RSpec.
    macro xit(what, &block)
      pending({{what}}) {{block}}
    end

    # Same as `#pending`.
    # Included for compatibility with RSpec.
    macro xit(&block)
      pending({{block.body.stringify}}) {{block}}
    end

    # Creates a wrapper class for test code.
    # The class serves multiple purposes, mostly dealing with scope.
    # 1. Include the parent modules as mix-ins.
    # 2. Enable DSL specific to examples.
    # 3. Isolate methods in `Example` from the test code.
    #
    # Since the names are generated, and macros can't return values,
    # the names for everything must be passed in as arguments.
    # The *class_name* argument is the name of the class to define.
    # The *run_method_name* argument is the name of the method in the wrapper class
    # that will actually run the test code.
    # The block passed to this macro is the actual test code.
    private macro _spectator_test(class_name, run_method_name)
      # Wrapper class for isolating the test code.
      class {{class_name.id}}
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
          {{yield}}
        end
      end
    end

    # Creates an example class.
    # Since the names are generated, and macros can't return values,
    # the names for everything must be passed in as arguments.
    # The *example_class_name* argument is the name of the class to define.
    # The *test_class_name* argument is the name of the wrapper class to reference.
    # This must be the same as `class_name` for `#_spectator_example_wrapper`.
    # The *base_class* argument specifies which type of example class the new class should derive from.
    # This should typically be `RunnableExample` or `PendingExample`.
    # The *what* argument is the description passed to the `#it` or `#pending` block.
    # And lastly, the block specified is additional content to put in the class.
    # For instance, to define a method in the class, do it in the block.
    # ```
    # _spectator_example(Example123, Test123, RunnableExample, "does something") do
    #   def something
    #     # This method is defined in the Example123 class.
    #   end
    # end
    # ```
    private macro _spectator_example(example_class_name, test_class_name, base_class, what, &block)
      # Example class containing meta information and instructions for running the test.
      class {{example_class_name.id}} < {{base_class.id}}
        # Stores the group the example belongs to
        # and sample values specific to this instance of the test.
        # This method's signature must match the one used in `ExampleFactory#build`.
        def initialize(group : ::Spectator::ExampleGroup, sample_values : ::Spectator::Internals::SampleValues)
          super
          @instance = {{test_class_name.id}}.new(sample_values)
        end

        # Retrieves the underlying, wrapped test code.
        getter instance

        # Indicates whether the example references a method.
        def symbolic? : Bool
          {{what.is_a?(StringLiteral) && what.starts_with?('#') ? true : false}}
        end

        # Add the block's content.
        {{block.body}}

        # Description for the test.
        def what : String | Symbol
          {{what.is_a?(StringLiteral) ? what : what.stringify}}
        end
      end
    end
  end
end
