require "../dsl/reserved"
require "./formal_arguments"
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

    # Utility method that looks for stubs for methods with the name specified.
    abstract def _spectator_stub_for_method?(method : Symbol) : Bool

    # Defines a stub to change the behavior of a method.
    abstract def _spectator_define_stub(stub : Stub) : Nil

    # Removes a specific, previously defined stub.
    abstract def _spectator_remove_stub(stub : Stub) : Nil

    # Clears all previously defined stubs.
    abstract def _spectator_clear_stubs : Nil

    # Saves a call that was made to a stubbed method.
    abstract def _spectator_record_call(call : MethodCall) : Nil

    # Retrieves all previously saved calls.
    abstract def _spectator_calls

    # Clears all previously saved calls.
    abstract def _spectator_clear_calls : Nil

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

    # Clears all previously defined calls and stubs.
    def _spectator_reset : Nil
      _spectator_clear_calls
      _spectator_clear_stubs
    end

    # Redefines a method to accept stubs and provides a default response.
    #
    # The *method* must be a `Def`.
    # That is, a normal looking method definition should follow the `default_stub` keyword.
    #
    # ```
    # default_stub def stubbed_method
    #   "foobar"
    # end
    # ```
    #
    # The method cannot be abstract, as this method requires a default (fallback) response if a stub isn't provided.
    #
    # Stubbed methods will call `#_spectator_find_stub` with the method call information.
    # If no stub is found, then `#_spectator_stub_fallback` is called.
    # The block provided to `#_spectator_stub_fallback` will invoke the default response.
    # In other words, `#_spectator_stub_fallback` should yield if it's appropriate to return the default response.
    private macro default_stub(method)
      {% if method.is_a?(Def)
           visibility = method.visibility
         elsif method.is_a?(VisibilityModifier) && method.exp.is_a?(Def)
           visibility = method.visibility
           method = method.exp
         else
           raise "`default_stub` requires a method definition"
         end %}
      {% raise "Cannot define a stub inside a method" if @def %}
      {% raise "Default stub cannot be an abstract method" if method.abstract? %}
      {% raise "Cannot stub method with reserved keyword as name - #{method.name}" if method.name.starts_with?("_spectator") || ::Spectator::DSL::RESERVED_KEYWORDS.includes?(method.name.symbolize) %}

      {{visibility.id if visibility != :public}} def {{"#{method.receiver}.".id if method.receiver}}{{method.name}}(
        {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
        {% if method.double_splat %}**{{method.double_splat}}, {% end %}
        {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
      ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
        {{method.body}}
      end

      {% original = "previous_def"
         # Workaround for Crystal not propagating block with previous_def/super.
         if method.accepts_block?
           original += "("
           if method.splat_index
             method.args.each_with_index do |arg, i|
               if i == method.splat_index
                 if arg.internal_name && arg.internal_name.size > 0
                   original += "*#{arg.internal_name}, "
                 end
                 original += "**#{method.double_splat}, " if method.double_splat
               elsif i > method.splat_index
                 original += "#{arg.name}: #{arg.internal_name}, "
               else
                 original += "#{arg.internal_name}, "
               end
             end
           else
             method.args.each do |arg|
               original += "#{arg.internal_name}, "
             end
             original += "**#{method.double_splat}, " if method.double_splat
           end
           # If the block is captured (i.e. `&block` syntax), it must be passed along as an argument.
           # Otherwise, use `yield` to forward the block.
           captured_block = if method.block_arg && method.block_arg.name && method.block_arg.name.size > 0
                              method.block_arg.name
                            else
                              nil
                            end
           original += "&#{captured_block}" if captured_block
           original += ")"
           original += " { |*_spectator_yargs| yield *_spectator_yargs }" unless captured_block
         end
         original = original.id %}

      {% # Reconstruct the method signature.
# I wish there was a better way of doing this, but there isn't (at least not that I'm aware of).
# This chunk of code must reconstruct the method signature exactly as it was originally.
# If it doesn't match, it doesn't override the method and the stubbing won't work.
  %}
      {{visibility.id if visibility != :public}} def {{"#{method.receiver}.".id if method.receiver}}{{method.name}}(
        {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
        {% if method.double_splat %}**{{method.double_splat}}, {% end %}
        {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
      ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}

        # Capture information about the call.
        %call = ::Spectator::MethodCall.build(
          {{method.name.symbolize}},
          ::NamedTuple.new(
            {% for arg, i in method.args %}{% if !method.splat_index || i < method.splat_index %}{{arg.internal_name.stringify}}: {{arg.internal_name}}, {% end %}{% end %}
          ),
          {% if method.splat_index && !(splat = method.args[method.splat_index].internal_name).empty? %}{{splat.symbolize}}, {{splat}},{% end %}
          ::NamedTuple.new(
            {% for arg, i in method.args %}{% if method.splat_index && i > method.splat_index %}{{arg.internal_name.stringify}}: {{arg.internal_name}}, {% end %}{% end %}
          ).merge({{method.double_splat}})
        )
        _spectator_record_call(%call)

        # Attempt to find a stub that satisfies the method call and arguments.
        # Finding a suitable stub is delegated to the type including the `Stubbable` module.
        if %stub = _spectator_find_stub(%call)
          # Cast the stub or return value to the expected type.
          # This is necessary to match the expected return type of the original method.
          _spectator_cast_stub_value(%stub, %call, typeof({{original}}),
          {{ if rt = method.return_type
               if rt.is_a?(Path) && (resolved = rt.resolve?).is_a?(TypeNode) && resolved <= NoReturn
                 :no_return
               else
                 # Process as an enumerable type to reduce code repetition.
                 rt = rt.is_a?(Union) ? rt.types : [rt]
                 # Check if any types are nilable.
                 nilable = rt.any? do |t|
                   # These are all macro types that have the `resolve?` method.
                   (t.is_a?(TypeNode) || t.is_a?(Path) || t.is_a?(Generic) || t.is_a?(MetaClass)) &&
                     (resolved = t.resolve?).is_a?(TypeNode) && resolved <= Nil
                 end
                 if nilable
                   :nil
                 else
                   :raise
                 end
               end
             else
               :raise
             end }})
        else
          # Delegate missing stub behavior to concrete type.
          _spectator_stub_fallback(%call, typeof({{original}})) do
            # Use the default response for the method.
            {{original}}
          end
        end
      end
    end

    # Redefines a method to require stubs.
    #
    # This macro is similar to `#default_stub` but requires that a stub is defined for the method if it's called.
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
      {% if method.is_a?(Def)
           visibility = method.visibility
         elsif method.is_a?(VisibilityModifier) && method.exp.is_a?(Def)
           visibility = method.visibility
           method = method.exp
         else
           raise "`abstract_stub` requires a method definition"
         end %}
      {% raise "Cannot define a stub inside a method" if @def %}
      {% raise "Cannot stub method with reserved keyword as name - #{method.name}" if method.name.starts_with?("_spectator") || ::Spectator::DSL::RESERVED_KEYWORDS.includes?(method.name.symbolize) %}

      {% # The logic in this macro follows mostly the same logic from `#default_stub`.
# The main difference is that this macro cannot access the original method being stubbed.
# It might exist or it might not.
# The method could also be abstract.
# For all intents and purposes, this macro defines logic that doesn't depend on an existing method.
  %}

      {% unless method.abstract? %}
        {{visibility.id if visibility != :public}} def {{"#{method.receiver}.".id if method.receiver}}{{method.name}}(
          {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
          {% if method.double_splat %}**{{method.double_splat}}, {% end %}
          {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
        ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
          {{method.body}}
        end

        {% original = "previous_def"
           # Workaround for Crystal not propagating block with previous_def/super.
           if method.accepts_block?
             original += "("
             if method.splat_index
               method.args.each_with_index do |arg, i|
                 if i == method.splat_index
                   if arg.internal_name && arg.internal_name.size > 0
                     original += "*#{arg.internal_name}, "
                   end
                   original += "**#{method.double_splat}, " if method.double_splat
                 elsif i > method.splat_index
                   original += "#{arg.name}: #{arg.internal_name}"
                 else
                   original += "#{arg.internal_name}, "
                 end
               end
             else
               method.args.each do |arg|
                 original += "#{arg.internal_name}, "
               end
               original += "**#{method.double_splat}, " if method.double_splat
             end
             # If the block is captured (i.e. `&block` syntax), it must be passed along as an argument.
             # Otherwise, use `yield` to forward the block.
             captured_block = if method.block_arg && method.block_arg.name && method.block_arg.name.size > 0
                                method.block_arg.name
                              else
                                nil
                              end
             original += "&#{captured_block}" if captured_block
             original += ")"
             original += " { |*_spectator_yargs| yield *_spectator_yargs }" unless captured_block
           end
           original = original.id %}

      {% end %}

      {% # Reconstruct the method signature.
# I wish there was a better way of doing this, but there isn't (at least not that I'm aware of).
# This chunk of code must reconstruct the method signature exactly as it was originally.
# If it doesn't match, it doesn't override the method and the stubbing won't work.
  %}
      {{visibility.id if visibility != :public}} def {{"#{method.receiver}.".id if method.receiver}}{{method.name}}(
        {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
        {% if method.double_splat %}**{{method.double_splat}}, {% end %}
        {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
      ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}

        # Capture information about the call.
        %call = ::Spectator::MethodCall.build(
          {{method.name.symbolize}},
          ::NamedTuple.new(
            {% for arg, i in method.args %}{% if !method.splat_index || i < method.splat_index %}{{arg.internal_name.stringify}}: {{arg.internal_name}}, {% end %}{% end %}
          ),
          {% if method.splat_index && !(splat = method.args[method.splat_index].internal_name).empty? %}{{splat.symbolize}}, {{splat}},{% end %}
          ::NamedTuple.new(
            {% for arg, i in method.args %}{% if method.splat_index && i > method.splat_index %}{{arg.internal_name.stringify}}: {{arg.internal_name}}, {% end %}{% end %}
          ).merge({{method.double_splat}})
        )
        _spectator_record_call(%call)

        # Attempt to find a stub that satisfies the method call and arguments.
        # Finding a suitable stub is delegated to the type including the `Stubbable` module.
        if %stub = _spectator_find_stub(%call)
          # Cast the stub or return value to the expected type.
          # This is necessary to match the expected return type of the original method.
          {% if rt = method.return_type %}
            # Return type restriction takes priority since it can be a superset of the original implementation.
            _spectator_cast_stub_value(%stub, %call, {{method.return_type}},
              {{ if rt.is_a?(Path) && (resolved = rt.resolve?).is_a?(TypeNode) && resolved <= NoReturn
                   :no_return
                 else
                   # Process as an enumerable type to reduce code repetition.
                   rt = rt.is_a?(Union) ? rt.types : [rt]
                   # Check if any types are nilable.
                   nilable = rt.any? do |t|
                     # These are all macro types that have the `resolve?` method.
                     (t.is_a?(TypeNode) || t.is_a?(Path) || t.is_a?(Generic) || t.is_a?(MetaClass)) &&
                       (resolved = t.resolve?).is_a?(TypeNode) && resolved <= Nil
                   end
                   if nilable
                     :nil
                   else
                     :raise
                   end
                 end }})
          {% elsif !method.abstract? %}
            # The method isn't abstract, infer the type it returns without calling it.
            _spectator_cast_stub_value(%stub, %call, typeof({{original}}))
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
            # Pass along just the return type annotation.
            _spectator_abstract_stub_fallback(%call, {{method.return_type}})
          {% elsif !method.abstract? %}
            _spectator_abstract_stub_fallback(%call, typeof({{original}}))
          {% else %}
            # Stubbed method is abstract and there's no type annotation.
            _spectator_abstract_stub_fallback(%call)
          {% end %}
        end
      end
    end

    # Redefines a method to require stubs.
    #
    # The *method* can be a `Def`.
    # That is, a normal looking method definition should follow the `stub` keyword.
    #
    # ```
    # stub def stubbed_method
    #   "foobar"
    # end
    # ```
    #
    # If the *method* is abstract, then a stub must be provided otherwise attempts to call the method will raise `UnexpectedMessage`.
    #
    # ```
    # stub abstract def stubbed_method
    # ```
    #
    # A `Call` can also be specified.
    # In this case all methods in the stubbed type and its ancestors that match the call's signature are stubbed.
    #
    # ```
    # stub stubbed_method(arg)
    # ```
    #
    # The method being stubbed doesn't need to exist yet.
    # Stubbed methods will call `#_spectator_find_stub` with the method call information.
    # If no stub is found, then `#_spectator_stub_fallback` or `#_spectator_abstract_stub_fallback` is called.
    macro stub(method)
      {% raise "Cannot define a stub inside a method" if @def %}

      {% if method.is_a?(Def) %}
        {% if method.abstract? %}abstract_stub{% else %}default_stub{% end %} {{method}}
      {% elsif method.is_a?(VisibilityModifier) && method.exp.is_a?(Def) %}
        {% if method.exp.abstract? %}abstract_stub{% else %}default_stub{% end %} {{method}}
      {% elsif method.is_a?(Call) %}
        {% raise "Stub on `Call` unsupported." %}
      {% else %}
        {% raise "Unrecognized syntax for `stub` - #{method}" %}
      {% end %}
    end

    # Redefines all methods and ones inherited from its parents and mixins to support stubs.
    private macro stub_type(type_name = @type)
      {% type = type_name.resolve
         definitions = [] of Nil
         scope = if type == @type
                   :previous_def
                 elsif type.module?
                   type.name
                 else
                   :super
                 end.id

         # Add entries for methods in the target type and its class type.
         [[:self.id, type.class], [nil, type]].each do |(receiver, t)|
           t.methods.each do |method|
             definitions << {
               type:     t,
               method:   method,
               scope:    scope,
               receiver: receiver,
             }
           end
         end

         # Iterate through all ancestors and add their methods.
         type.ancestors.each do |ancestor|
           [[:self.id, ancestor.class], [nil, ancestor]].each do |(receiver, t)|
             t.methods.each do |method|
               # Skip methods already found to prevent redefining them multiple times.
               unless definitions.any? do |d|
                        m = d[:method]
                        m.name == method.name &&
                        m.args == method.args &&
                        m.splat_index == method.splat_index &&
                        m.double_splat == method.double_splat &&
                        m.block_arg == method.block_arg
                      end
                 definitions << {
                   type:     t,
                   method:   method,
                   scope:    :super.id,
                   receiver: receiver,
                 }
               end
             end
           end
         end

         definitions = definitions.reject do |definition|
           name = definition[:method].name
           name.starts_with?("_spectator") || ::Spectator::DSL::RESERVED_KEYWORDS.includes?(name.symbolize)
         end %}

      {% for definition in definitions %}
        {% original_type = definition[:type]
           method = definition[:method]
           scope = definition[:scope]
           receiver = definition[:receiver]
           rewrite_args = method.accepts_block?
           # Handle calling methods on other objects (primarily for mock modules).
           if scope != :super.id && scope != :previous_def.id
             if receiver == :self.id
               scope = "#{scope}.#{method.name}".id
               rewrite_args = true
             else
               scope = :super.id
             end
           end %}
        # Redefinition of {{original_type}}{{"#".id}}{{method.name}}
        {{(method.abstract? ? "abstract_stub abstract" : "default_stub").id}} {{method.visibility.id if method.visibility != :public}} def {{"#{receiver}.".id if receiver}}{{method.name}}(
          {% for arg, i in method.args %}{% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}
          {% if method.double_splat %}**{{method.double_splat}}, {% end %}
          {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
        ){% if method.return_type %} : {{method.return_type}}{% end %}{% if !method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
        {% unless method.abstract? %}
            {{scope}}{% if rewrite_args %}({% for arg, i in method.args %}
              {% if i == method.splat_index && arg.internal_name && arg.internal_name.size > 0 %}*{{arg.internal_name}}, {% if method.double_splat %}**{{method.double_splat}}, {% end %}{% end %}
              {% if method.splat_index && i > method.splat_index %}{{arg.name}}: {{arg.internal_name}}, {% end %}
              {% if !method.splat_index || i < method.splat_index %}{{arg.internal_name}}, {% end %}{% end %}
              {% if !method.splat_index && method.double_splat %}**{{method.double_splat}}, {% end %}
              {% captured_block = if method.block_arg && method.block_arg.name && method.block_arg.name.size > 0
                                    method.block_arg.name
                                  else
                                    nil
                                  end %}
              {% if captured_block %}&{{captured_block}}{% end %}
            ){% if !captured_block && method.accepts_block? %} { |*%yargs| yield *%yargs }{% end %}{% end %}
          end
        {% end %}
      {% end %}
    end

    # Utility macro for casting a stub (and its return value) to the correct type.
    #
    # *stub* is the variable holding the stub.
    # *call* is the variable holding the captured method call.
    # *type* is the expected type to cast the value to.
    # *fail_cast* indicates the behavior used when the value returned by the stub can't be cast to *type*.
    # - `:nil` - return nil.
    # - `:raise` - raise a `TypeCastError`.
    # - `:no_return` - raise as no value should be returned.
    private macro _spectator_cast_stub_value(stub, call, type, fail_cast = :nil)
      {% if fail_cast == :no_return %}
        {{stub}}.call({{call}})
        raise TypeCastError.new("#{_spectator_stubbed_name} received message #{ {{call}} } and is attempting to return a value, but it shouldn't have returned (`NoReturn`).")
      {% else %}
        # Get the value as-is from the stub.
        # This will be compiled as a union of all known stubbed value types.
        %value = {{stub}}.call({{call}})
        %type = {{type}}

        # Attempt to cast the value to the method's return type.
        # If successful, which it will be in most cases, return it.
        # The caller will receive a properly typed value without unions or other side-effects.
        %cast = %value.as?({{type}})

        {% if fail_cast == :nil %}
          %cast
        {% elsif fail_cast == :raise %}
          # Check if nil was returned by the stub and if its okay to return it.
          if %value.nil? && %type.nilable?
            # Value was nil and nil is allowed to be returned.
            %type.cast(%cast)
          elsif %cast.nil?
            # The stubbed value was something else entirely and cannot be cast to the return type.
            raise TypeCastError.new("#{_spectator_stubbed_name} received message #{ {{call}} } and is attempting to return a `#{%value.class}`, but returned type must be `#{%type}`.")
          else
            # Types match and value can be returned as cast type.
            %cast
          end
        {% else %}
          {% raise "fail_cast must be :nil, :raise, or :no_return, but got: #{fail_cast}" %}
        {% end %}
      {% end %}
    end
  end
end
