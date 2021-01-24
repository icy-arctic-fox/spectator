require "../block"
require "../expectation"
require "../expectation_failed"
require "../source"
require "../value"

module Spectator::DSL
  # Methods and macros for asserting that conditions are met.
  module Expectations
    # Immediately fail the current test.
    # A reason can be specified with *message*.
    def fail(message = "Example failed", *, _file = __FILE__, _line = __LINE__)
      raise ExpectationFailed.new(Source.new(_file, _line), message)
    end

    # Starts an expectation.
    # This should be followed up with `Assertion::Target#to` or `Assertion::Target#to_not`.
    # The value passed in will be checked to see if it satisfies the conditions of the specified matcher.
    #
    # This macro should be used like so:
    # ```
    # expect(actual).to eq(expected)
    # ```
    #
    # Where the actual value is returned by the system under test,
    # and the expected value is what the actual value should be to satisfy the condition.
    macro expect(actual)
      %actual = begin
        {{actual}}
      end

      %expression = ::Spectator::Value.new(%actual, {{actual.stringify}})
      %source = ::Spectator::Source.new({{actual.filename}}, {{actual.line_number}})
      ::Spectator::Expectation::Target.new(%expression, %source)
    end

    # Starts an expectation.
    # This should be followed up with `Assertion::Target#to` or `Assertion::Target#not_to`.
    # The value passed in will be checked to see if it satisfies the conditions of the specified matcher.
    #
    # This macro should be used like so:
    # ```
    # expect { raise "foo" }.to raise_error
    # ```
    #
    # The block of code is passed along for validation to the matchers.
    #
    # The short, one argument syntax used for passing methods to blocks can be used.
    # So instead of doing this:
    # ```
    # expect(subject.size).to eq(5)
    # ```
    #
    # The following syntax can be used instead:
    # ```
    # expect(&.size).to eq(5)
    # ```
    #
    # The method passed will always be evaluated on the subject.
    #
    # TECHNICAL NOTE:
    # This macro uses an ugly hack to detect the short-hand syntax.
    #
    # The Crystal compiler will translate:
    # ```
    # &.foo
    # ```
    #
    # effectively to:
    # ```
    # { |__arg0| __arg0.foo }
    # ```
    macro expect(&block)
      {% if block.args.size == 1 && block.args[0] =~ /^__arg\d+$/ && block.body.is_a?(Call) && block.body.id =~ /^__arg\d+\./ %}
        {% method_name = block.body.id.split('.')[1..-1].join('.') %}
        %block = ::Spectator::Block.new({{"#" + method_name}}) do
          subject.{{method_name.id}}
        end
      {% elsif block.args.empty? %}
        %block = ::Spectator::Block.new({{"`" + block.body.stringify + "`"}}) {{block}}
      {% else %}
        {% raise "Unexpected block arguments in 'expect' call" %}
      {% end %}

      %source = ::Spectator::Source.new({{block.filename}}, {{block.line_number}})
      ::Spectator::Expectation::Target.new(%block, %source)
    end

    # Short-hand for expecting something of the subject.
    #
    # These two are functionally equivalent:
    # ```
    # expect(subject).to eq("foo")
    # is_expected.to eq("foo")
    # ```
    macro is_expected
      expect(subject)
    end

    # Short-hand form of `#is_expected` that can be used for one-liner syntax.
    #
    # For instance:
    # ```
    # it "is 42" do
    #   expect(subject).to eq(42)
    # end
    # ```
    #
    # Can be shortened to:
    # ```
    # it { is(42) }
    # ```
    #
    # These three are functionally equivalent:
    # ```
    # expect(subject).to eq("foo")
    # is_expected.to eq("foo")
    # is("foo")
    # ```
    #
    # See also: `#is_not`
    macro is(expected)
      expect(subject).to(eq({{expected}}))
    end

    # Short-hand, negated form of `#is_expected` that can be used for one-liner syntax.
    #
    # For instance:
    # ```
    # it "is not 42" do
    #   expect(subject).to_not eq(42)
    # end
    # ```
    #
    # Can be shortened to:
    # ```
    # it { is_not(42) }
    # ```
    #
    # These three are functionally equivalent:
    # ```
    # expect(subject).not_to eq("foo")
    # is_expected.not_to eq("foo")
    # is_not("foo")
    # ```
    #
    # See also: `#is`
    macro is_not(expected)
      expect(subject).not_to(eq({{expected}}))
    end
  end
end