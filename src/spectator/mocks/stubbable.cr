require "../dsl/reserved"
require "./arguments"
require "./method_call"
require "./stub"
require "./typed_stub"

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

    # Defines a stub to change the behavior of a method.
    abstract def _spectator_define_stub(stub : Stub) : Nil

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

    # Utility method returning the stubbed type's name formatted for user output.
    abstract def _spectator_stubbed_name : String

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

      {% # Figure out how to call the original implementation of the method being stubbed.
# `#has_method?` is effectively `#responds_to?` for macros and will return true if a type or its ancestors or included modules has a method by a given name.
# To be more strict with searching, `#methods` is inspected to handle overrides and the difference in calling convention.
# If the method is defined in an ancestor, `super` should be used.
# Otherwise, when a method is defined in the current type or a module, `previous_def` should be used.
# Additionally, the block usage is forwarded for methods that accept it.
# Even though `super` and `previous_def` without parameters forward the arguments, they don't forward a block.
  %}
      {% original = if @type.methods.includes?(method)
                      :previous_def
                    elsif @type.ancestors.any? &.methods.includes?(method)
                      :super
                      # sigh... sometimes the method won't match with a simple check.
                      # It seems to be from a difference with the body attribute.
                      # Manually check most attributes.
                    elsif @type.ancestors.any? do |ancestor|
                            ancestor.methods.any? do |meth|
                              meth.name == method.name &&
                              meth.args == method.args &&
                              meth.accepts_block? == method.accepts_block? &&
                              meth.block_arg == method.block_arg &&
                              meth.double_splat == method.double_splat &&
                              meth.free_vars == method.free_vars &&
                              meth.receiver == method.receiver &&
                              meth.return_type == method.return_type &&
                              meth.splat_index == method.splat_index &&
                              meth.visibility == method.visibility
                            end
                          end
                      :super
                    else
                      :previous_def # raise "Could not find original implementation of `#{method.name}` for stubbing"
                    end.id
         if method.accepts_block?
           original = "#{original} { |*_spectator_yargs| yield *_spectator_yargs }".id
         end %}

         {% # Reconstruct the method signature.
# I wish there was a better way of doing this, but there isn't (at least not that I'm aware of).
# This chunk of code must reconstruct the method signature exactly as it was originally.
# If it doesn't match, it doesn't override the method and the stubbing won't work.
  %}
      {% if method.visibility != :public %}{{method.visibility.id}}{% end %} def {{method.receiver}}{{method.name}}(
        {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
        {% if method.double_splat %}**{{method.double_splat}}, {% end %}
        {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
      ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}

        # Capture information about the call.
        %args = ::Spectator::Arguments.capture(
          {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg.internal_name}}, {% end %}
          {% if method.double_splat %}**{{method.double_splat}}{% end %}
        )
        %call = ::Spectator::MethodCall.new({{method.name.symbolize}}, %args)

        # Attempt to find a stub that satisfies the method call and arguments.
        # Finding a suitable stub is delegated to the type including the `Stubbable` module.
        if %stub = _spectator_find_stub(%call)
          # Cast the stub or return value to the expected type.
          # This is necessary to match the expected return type of the original method.
          {% if method.return_type %}
            # Return type restriction takes priority since it can be a superset of the original implementation.
            _spectator_cast_stub_value(%stub, %call, {{method.return_type}}, {{method.return_type.resolve >= Nil}})
          {% elsif !method.abstract? %}
            # The method isn't abstract, infer the type it returns without calling it.
            _spectator_cast_stub_value(%stub, %call, typeof({{original}}), {{method.return_type && method.return_type.resolve >= Nil || false}})
          {% else %}
            # Stubbed method is abstract and there's no return type annotation.
            # The value of the stub could be returned as-is.
            # This may produce a "bloated" union of all known stub types,
            # and generally causes more annoying problems.
            raise TypeCastError.new("#{_spectator_stubbed_name} received message #{%call} but cannot resolve the return type. Please add a return type restriction.")
          {% end %}
        else
          # A stub wasn't found, invoke the type-specific fallback logic.
          {% if method.return_type && method.abstract? %}
            # Pass along just the return type annotation.
            _spectator_abstract_stub_fallback(%call, {{method.return_type}})
          {% elsif method.abstract? %}
            # Stubbed method is abstract and there's no type annotation.
            _spectator_abstract_stub_fallback(%call)
          {% else %}
            # Pass along the type of the original method and a block to invoke it.
            _spectator_stub_fallback(%call, typeof({{original}})) { {{original}} }
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

      {% # The logic in this macro follows mostly the same logic from `#stub`.
# The main difference is that this macro cannot access the original method being stubbed.
# It might exist or it might not.
# The method could also be abstract.
# For all intents and purposes, this macro defines logic that doesn't depend on an existing method.
  %}

      {% # Reconstruct the method signature.
# I wish there was a better way of doing this, but there isn't (at least not that I'm aware of).
# This chunk of code must reconstruct the method signature exactly as it was originally.
# If it doesn't match, it doesn't override the method and the stubbing won't work.
  %}
      {% if method.visibility != :public %}{{method.visibility.id}}{% end %} def {{method.receiver}}{{method.name}}(
        {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
        {% if method.double_splat %}**{{method.double_splat}}, {% end %}
        {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
      ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}

        # Capture information about the call.
        %args = ::Spectator::Arguments.capture(
          {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg.internal_name}}, {% end %}
          {% if method.double_splat %}**{{method.double_splat}}{% end %}
        )
        %call = ::Spectator::MethodCall.new({{method.name.symbolize}}, %args)

        # Attempt to find a stub that satisfies the method call and arguments.
        # Finding a suitable stub is delegated to the type including the `Stubbable` module.
        if %stub = _spectator_find_stub(%call)
          {% if method.return_type %}
            # Return type was provided with a restriction.
            _spectator_cast_stub_value(%stub, %call, {{method.return_type}}, {{method.return_type.resolve >= Nil}})
          {% else %}
            # Stubbed method is abstract and there's no return type annotation.
            # The value of the stub could be returned as-is.
            # This may produce a "bloated" union of all known stub types,
            # and generally causes more annoying problems.
            raise TypeCastError.new("#{_spectator_stubbed_name} received message #{%call} but cannot resolve the return type. Please add a return type restriction.")
          {% end %}
        else
          # A stub wasn't found, invoke the type-specific fallback logic.
          {% if method.return_type %}
            # Stubbed method is abstract, so it can't be called.
            # Pass along just the return type annotation.
            _spectator_abstract_stub_fallback(%call, {{method.return_type}})
          {% else %}
            # Stubbed method is abstract and there's no type annotation.
            _spectator_abstract_stub_fallback(%call)
          {% end %}
        end
      end
    end

    # Utility macro for casting a stub (and it's return value) to the correct type.
    #
    # *stub* is the variable holding the stub.
    # *call* is the variable holding the captured method call.
    # *type* is the expected type to cast the value to.
    # *nillable* is true or false depending on whether *type* can be nil.
    private macro _spectator_cast_stub_value(stub, call, type, nillable)
      # Attempt to cast the stub to the method's return type.
      # If successful, return the value of the stub.
      # This is a common usage where the return type is simple and matches the stub type exactly.
      if %typed = {{stub}}.as?(::Spectator::TypedStub({{type}}))
        %typed.call({{call}})
      else
        # The stub couldn't be easily cast to match the return type.

        # Even though all stubs will have a #call method, the compiler doesn't seem to agree.
        # Assert that it will (this should never fail).
        raise TypeCastError.new("Stub has no value") unless {{stub}}.responds_to?(:call)

        # Get the value as-is from the stub.
        # This will be compiled as a union of all known stubbed value types.
        %value = {{stub}}.call({{call}})

        # Attempt to cast the value to the method's return type.
        # If successful, which it will be in most cases, return it.
        # The caller will receive a properly typed value without unions or other side-effects.
        if %cast = %value.as?({{type}})
          %cast
        else
          # Now we're down to edge cases.
          {% if nillable %}
            # The return type might have "cast" correctly, but the value is nil and the return type is nillable.
            # Just return nil in this case.
            nil
          {% else %}
            # The stubbed value was something else entirely and cannot be cast to the return type.
            %type = begin
              %value.class.to_s
            rescue
              "<Unknown>"
            end
            raise TypeCastError.new("#{_spectator_stubbed_name} received message #{ {{call}} } and is attempting to return a `#{%type}`, but returned type must be `#{ {{type}} }`.")
          {% end %}
        end
      end
    end

    # Utility for defining a stubbed method and a fallback.
    #
    # NOTE: The method definition is exploded and redefined by its parts because using `{{method}}` omits the block argument.
    private macro inject_stub(method)
      {% if method.abstract? %}
        abstract_stub {% if method.visibility != :public %}{{method.visibility.id}}{% end %} abstract def {{method.receiver}}{{method.name}}(
          {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
          {% if method.double_splat %}**{{method.double_splat}}, {% end %}
          {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
        ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
      {% else %}
        {% if method.visibility != :public %}{{method.visibility.id}}{% end %} def {{method.receiver}}{{method.name}}(
          {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
          {% if method.double_splat %}**{{method.double_splat}}, {% end %}
          {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
        ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
          {{method.body}}
        end

        stub {% if method.visibility != :public %}{{method.visibility.id}}{% end %} def {{method.receiver}}{{method.name}}(
          {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
          {% if method.double_splat %}**{{method.double_splat}}, {% end %}
          {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
        ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
          # Content of this method is discarded,
          # but this will compile successfully even if it's used.
          previous_def{% if method.accepts_block? %} { |*%yargs| yield *%yargs }{% end %}
        end
      {% end %}
    end

    # Redefines all methods on a type to conditionally respond to messages.
    # Methods will raise `UnexpectedMessage` if they're called when they shouldn't be.
    # Otherwise, they'll return the configured response.
    private macro stub_all(type_name, *, with style = :stub)
      {% type = type_name.resolve %}
      {% if type.superclass %}
        stub_all({{type.superclass}}, with: {{style}})
      {% end %}

      {% for method in type.methods.reject do |meth|
                         meth.name.starts_with?("_spectator") ||
                           ::Spectator::DSL::RESERVED_KEYWORDS.includes?(meth.name.symbolize)
                       end %}
        {{style.id}} {{method}}
      {% end %}
    end
  end
end
