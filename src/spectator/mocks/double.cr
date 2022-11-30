require "./arguments"
require "./method_call"
require "./stub"
require "./stubbable"
require "./stubbed_name"
require "./stubbed_type"
require "./unexpected_message"
require "./value_stub"

module Spectator
  # Stands in for an object for testing that a SUT calls expected methods.
  #
  # Handles all messages (method calls), but only responds to those configured.
  # Methods called that were not configured will raise `UnexpectedMessage`.
  # Doubles should be defined with the `#define` macro.
  #
  # Use `#_spectator_define_stub` to override behavior of a method in the double.
  # Only methods defined in the double's type can have stubs.
  # New methods are not defines when a stub is added that doesn't have a matching method name.
  abstract class Double
    include Stubbable
    extend StubbedType

    Log = Spectator::Log.for(self)

    # Defines a test double type.
    #
    # The *type_name* is the name to give the class.
    # Instances of the double can be named by providing a *name*.
    # This can be a symbol, string, or even a type.
    # See `StubbedName` for details.
    #
    # After the names, a collection of key-value pairs can be given to quickly define methods.
    # Each key is the method name, and the corresponding value is the value returned by the method.
    # These methods accept any arguments.
    # Additionally, these methods can be overridden later with stubs.
    #
    # Lastly, a block can be provided to define additional methods and stubs.
    # The block is evaluated in the context of the double's class.
    #
    # ```
    # Double.define(SomeDouble, meth1: 42, meth2: "foobar") do
    #   stub abstract def meth3 : Symbol
    #
    #   # Default implementation with a dynamic value.
    #   stub def meth4
    #     Time.utc
    #   end
    # end
    # ```
    macro define(type_name, name = nil, **value_methods, &block)
      {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
      class {{type_name.id}} < {{@type.name}}
        {% for key, value in value_methods %}
          default_stub def {{key.id}}(*%args, **%kwargs)
            {{value}}
          end

          default_stub def {{key.id}}(*%args, **%kwargs, &)
            {{key.id}}
          end
        {% end %}

        {{block.body if block}}
      end
    end

    @calls = [] of MethodCall

    private class_getter _spectator_stubs : Array(Stub) = [] of Stub

    class_getter _spectator_calls : Array(MethodCall) = [] of MethodCall

    # Creates the double.
    #
    # An initial set of *stubs* can be provided.
    def initialize(@stubs : Array(::Spectator::Stub) = [] of ::Spectator::Stub)
    end

    # Creates the double.
    #
    # An initial set of stubs can be provided with *value_methods*.
    def initialize(**value_methods)
      @stubs = value_methods.map do |key, value|
        ValueStub.new(key, value).as(Stub)
      end
    end

    # Compares against another object.
    #
    # Always returns false.
    # This method exists as a workaround to provide an alternative to `Object#same?`,
    # which only accepts a `Reference` or `Nil`.
    def same?(other) : Bool
      false
    end

    # Simplified string representation of a double.
    # Avoids displaying nested content and bloating method instantiation.
    def to_s(io : IO) : Nil
      io << "#<" + {{@type.name(generic_args: false).stringify}} + " "
      io << _spectator_stubbed_name << '>'
    end

    # :ditto:
    def inspect(io : IO) : Nil
      io << "#<" + {{@type.name(generic_args: false).stringify}} + " "
      io << _spectator_stubbed_name

      io << ":0x"
      object_id.to_s(io, 16)
      io << '>'
    end

    # Defines a stub to change the behavior of a method in this double.
    #
    # NOTE: Defining a stub for a method not defined in the double's type has no effect.
    protected def _spectator_define_stub(stub : Stub) : Nil
      Log.debug { "Defined stub for #{inspect} #{stub}" }
      @stubs.unshift(stub)
    end

    protected def _spectator_remove_stub(stub : Stub) : Nil
      Log.debug { "Removing stub #{stub} from #{inspect}" }
      @stubs.delete(stub)
    end

    protected def _spectator_clear_stubs : Nil
      Log.debug { "Clearing stubs for #{inspect}" }
      @stubs.clear
    end

    private def _spectator_find_stub(call : MethodCall) : Stub?
      Log.debug { "Finding stub for #{call}" }
      stub = @stubs.find &.===(call)
      Log.debug { stub ? "Found stub #{stub} for #{call}" : "Did not find stub for #{call}" }
      stub
    end

    def _spectator_stub_for_method?(method : Symbol) : Bool
      @stubs.any? { |stub| stub.method == method }
    end

    def _spectator_record_call(call : MethodCall) : Nil
      @calls << call
    end

    def _spectator_calls
      @calls
    end

    def _spectator_clear_calls : Nil
      @calls.clear
    end

    # Returns the double's name formatted for user output.
    private def _spectator_stubbed_name : String
      {% if anno = @type.annotation(StubbedName) %}
        {{(anno[0] || :Anonymous.id).stringify}}
      {% else %}
        "Anonymous"
      {% end %}
    end

    private def self._spectator_stubbed_name : String
      {% if anno = @type.annotation(StubbedName) %}
        {{(anno[0] || :Anonymous.id).stringify}}
      {% else %}
        "Anonymous"
      {% end %}
    end

    private def _spectator_stub_fallback(call : MethodCall, &)
      Log.trace { "Fallback for #{call} - call original" }
      yield
    end

    private def _spectator_stub_fallback(call : MethodCall, type, &)
      _spectator_stub_fallback(call) { yield }
    end

    private def _spectator_abstract_stub_fallback(call : MethodCall)
      Log.info do
        break unless _spectator_stub_for_method?(call.method)

        "Stubs are defined for #{call.method.inspect}, but none matched (no argument constraints met)."
      end

      raise UnexpectedMessage.new("#{inspect} received unexpected message #{call}")
    end

    private def _spectator_abstract_stub_fallback(call : MethodCall, type)
      _spectator_abstract_stub_fallback(call)
    end

    # "Hide" existing methods and methods from ancestors by overriding them.
    macro finished
      stub_type {{@type.name(generic_args: false)}}
    end

    # Handle all methods but only respond to configured messages.
    # Raises an `UnexpectedMessage` error for non-configures messages.
    macro method_missing(call)
      args = ::Spectator::Arguments.capture({{call.args.splat(", ")}}{{call.named_args.splat if call.named_args}})
      call = ::Spectator::MethodCall.new({{call.name.symbolize}}, args)
      _spectator_record_call(call)

      Log.trace { "#{inspect} got undefined method `#{call}{% if call.block %} { ... }{% end %}`" }

      raise ::Spectator::UnexpectedMessage.new("#{inspect} received unexpected message #{call}")
      nil # Necessary for compiler to infer return type as nil. Avoids runtime "can't execute ... `x` has no type errors".
    end
  end
end
