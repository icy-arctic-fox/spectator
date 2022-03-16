module Spectator
  # Mix-in for mocks and doubles providing method stubs.
  #
  # Macros in this module can override existing methods.
  # Stubbed methods will look for stubs to evaluate in place of their original functionality.
  # The primary macro of interest is `#stub`.
  # The macros are intended to be called from within the type being stubbed.
  #
  # Types including this module must define `#_spectator_find_stub` and `#_spectator_stubbed_name`.
  # These are internal, reserved method names by Spectator, hence the `_spectator` prefix.
  # These methods can't (and shouldn't) be stubbed.
  module Stubbable
    # Attempts to find a stub that satisfies a method call.
    #
    # Returns a stub that matches the method *call*
    # or nil if no stubs satisfy it.
    abstract def _spectator_find_stub(call : MethodCall) : Stub?

    # Method called when a stub isn't found.
    #
    # The received message is captured in *call*.
    # Yield to call the original method's implementation.
    # The stubbed method returns the value returned by this method.
    # This method can also raise an error if it's impossible to return something.
    abstract def _spectator_stub_fallback(call : MethodCall, &)

    # Method called when a stub isn't found.
    #
    # The received message is captured in *call*.
    # The expected return type is provided by *type*.
    # Yield to call the original method's implementation.
    # The stubbed method returns the value returned by this method.
    # This method can also raise an error if it's impossible to return something.
    abstract def _spectator_stub_fallback(call : MethodCall, type, &)

    # Method called when a stub isn't found.
    #
    # This is similar to `#_spectator_stub_fallback`,
    # but called when the original (un-stubbed) method isn't available.
    # The received message is captured in *call*.
    # The stubbed method returns the value returned by this method.
    # This method can also raise an error if it's impossible to return something.
    abstract def _spectator_abstract_stub_fallback(call : MethodCall)

    # Method called when a stub isn't found.
    #
    # This is similar to `#_spectator_stub_fallback`,
    # but called when the original (un-stubbed) method isn't available.
    # The received message is captured in *call*.
    # The expected return type is provided by *type*.
    # The stubbed method returns the value returned by this method.
    # This method can also raise an error if it's impossible to return something.
    abstract def _spectator_abstract_stub_fallback(call : MethodCall, type)

    # Redefines a method to accept stubs.
    #
    # The *method* should be a `Def`.
    # That is, a normal looking method definition should follow the `stub` keyword.
    #
    # ```
    # stub def stubbed_method
    #   "foobar"
    # end
    # ```
    #
    # The method being stubbed must already exist in the type, parent, or included/extend module.
    # If it doesn't exist, and a new stubbable method is being added, use `#inject_stub` instead.
    # The original's method is called if there are no applicable stubs for the invocation.
    # The body of the method passed to this macro is ignored.
    #
    # The method can be abstract.
    # If an abstract method is invoked that doesn't have a stub, an `UnexpectedMessage` error is raised.
    # The abstract method should have a return type annotation, otherwise the compiled return type will probably end up as a giant union.
    #
    # ```
    # stub abstract def stubbed_method : String
    # ```
    #
    # Stubbed methods will call `#_spectator_find_stub` with the method call information.
    # If no stub is found, then `#_spectator_stub_fallback` or `#_spectator_abstract_stub_fallback` is called.
    private macro stub(method)
      {% raise "Cannot define a stub inside a method" if @def %}
      {% raise "stub requires a method definition" if !method.is_a?(Def) %}
      {% raise "Cannot stub method with reserved keyword as name - #{method.name}" if method.name.starts_with?("_spectator") || ::Spectator::DSL::RESERVED_KEYWORDS.includes?(method.name.symbolize) %}

      {% original = ((@type.methods.includes?(method) || !@type.ancestors.any? { |a| a.methods.includes?(method) }) ? :previous_def : :super).id %}
      {% if method.accepts_block?
           original = "#{original} { |*_spectator_yargs| yield *_spectator_yargs }".id
         end %}

      {% if method.visibility != :public %}{{method.visibility.id}}{% end %} def {{method.receiver}}{{method.name}}(
        {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
        {% if method.double_splat %}**{{method.double_splat}}, {% end %}
        {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
      ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
        %args = ::Spectator::Arguments.capture(
          {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg.internal_name}}, {% end %}
          {% if method.double_splat %}**{{method.double_splat}}{% end %}
        )
        %call = ::Spectator::MethodCall.new({{method.name.symbolize}}, %args)

        if %stub = _spectator_find_stub(%call)
          {% if !method.abstract? %}
            %stub.as(::Spectator::ValueStub(typeof({{original}}))).value
          {% elsif method.return_type %}
            if %cast = %stub.as?(::Spectator::ValueStub({{method.return_type}}))
              %cast.value
            else
              %stub.value.as({{method.return_type}})
            end
          {% else %}
            %stub.value
          {% end %}
        else
          {% if !method.abstract? %}
            _spectator_stub_fallback(%call, typeof({{original}})) { {{original}} }
          {% elsif method.return_type %}
            _spectator_abstract_stub_fallback(%call, {{method.return_type}})
          {% else %}
            _spectator_abstract_stub_fallback(%call)
          {% end %}
        end
      end
    end

    # Redefines a method to require stubs.
    #
    # This macro is similar to `#stub` but requires that a stub is defined for the method if it's called.
    #
    # The *method* should be a `Def`.
    # That is, a normal looking method definition should follow the `stub` keyword.
    #
    # ```
    # abstract_stub def stubbed_method
    #   "foobar"
    # end
    # ```
    #
    # The method being stubbed doesn't need to exist yet.
    # Its body of the method passed to this macro is ignored.
    # The method can be abstract.
    # It should have a return type annotation, otherwise the compiled return type will probably end up as a giant union.
    #
    # ```
    # abstract_stub abstract def stubbed_method : String
    # ```
    #
    # Stubbed methods will call `#_spectator_find_stub` with the method call information.
    # If no stub is found, then `#_spectator_stub_fallback` or `#_spectator_abstract_stub_fallback` is called.
    private macro abstract_stub(method)
      {% raise "Cannot define a stub inside a method" if @def %}
      {% raise "abstract_stub requires a method definition" if !method.is_a?(Def) %}
      {% raise "Cannot stub method with reserved keyword as name - #{method.name}" if method.name.starts_with?("_spectator") || ::Spectator::DSL::RESERVED_KEYWORDS.includes?(method.name.symbolize) %}

      {% if method.visibility != :public %}{{method.visibility.id}}{% end %} def {{method.receiver}}{{method.name}}(
        {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
        {% if method.double_splat %}**{{method.double_splat}}, {% end %}
        {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
      ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
        %args = ::Spectator::Arguments.capture(
          {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg.internal_name}}, {% end %}
          {% if method.double_splat %}**{{method.double_splat}}{% end %}
        )
        %call = ::Spectator::MethodCall.new({{method.name.symbolize}}, %args)

        if %stub = _spectator_find_stub(%call)
          {% if method.return_type %}
            if %cast = %stub.as?(::Spectator::ValueStub({{method.return_type}}))
              %cast.value
            else
              %stub.value.as({{method.return_type}})
            end
          {% else %}
            %stub.value
          {% end %}
        else
          {% if method.return_type %}
            _spectator_abstract_stub_fallback(%call, {{method.return_type}})
          {% else %}
            _spectator_abstract_stub_fallback(%call)
          {% end %}
        end
      end
    end

    # Utility for defining a stubbed method and a fallback.
    private macro inject_stub(method)
      {{method}}
      stub {{method}}
    end

    # Redefines all methods on a type to conditionally respond to messages.
    # Methods will raise `UnexpectedMessage` if they're called when they shouldn't be.
    # Otherwise, they'll return the configured response.
    private macro stub_all(type_name, *, with style = :abstract_stub)
      {% type = type_name.resolve %}
      {% if type.superclass %}
        stub_all({{type.superclass}}, with: {{style}})
      {% end %}

      {% for method in type.methods.reject do |meth|
                         meth.name.starts_with?("_spectator") ||
                           DSL::RESERVED_KEYWORDS.includes?(meth.name.symbolize)
                       end %}
        {{style.id}} {{method}}
      {% end %}
    end
  end
end
