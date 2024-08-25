module Spectator
  module Core
    # Information about running examples.
    # There is always one active sandbox, which can be accessed via `Spectator.sandbox`.
    # Additional sandboxes can be used to isolate test runs from each other.
    # This is primarily used to test Spectator itself.
    class Sandbox
    end
  end

  # The current sandbox.
  class_property sandbox = Core::Sandbox.new

  # Establishes a new sandbox.
  # The new sandbox is used for the duration of the block.
  # The previous sandbox is restored when the block exits.
  # The new sandbox is provided as an argument to the block.
  def self.with_sandbox(& : Core::Sandbox ->)
    previous_sandbox = self.sandbox
    sandbox = Core::Sandbox.new
    begin
      self.sandbox = sandbox
      yield sandbox
    ensure
      self.sandbox = previous_sandbox
    end
  end

  # Defines a getter for a property that can be accessed from the sandbox.
  # This macro accepts arguments in the same way as the `Object.getter` macro.
  # The getter is defined on instances of `Sandbox`.
  # Additionally, a class method is defined on the `Spectator` module,
  # that retrieves the property from the current sandbox.
  #
  # ```
  # Spectator.sandbox_getter current_example : Example?
  # ```
  # is similar to:
  # ```
  # module Spectator
  #   def self.current_example
  #     sandbox.current_example
  #   end
  #
  #   module Core
  #     class Sandbox
  #       getter current_example : Example?
  #     end
  #   end
  # end
  # ```
  macro sandbox_getter(prop)
    {% if prop.is_a?(TypeDeclaration)
         name = prop.var
       elsif prop.is_a?(Assign)
         name = prop.target
       else
         name = prop
       end %}

    module ::Spectator
      def self.{{name.id}}
        sandbox.{{name.id}}
      end

      class Core::Sandbox
        getter {{prop}}
      end
    end
  end

  # Defines a getter and setter for a property that can be accessed from the sandbox.
  # This macro accepts arguments in the same way as the `Object.property` macro.
  # The getter and setter are defined on instances of `Sandbox`.
  # Additionally, class methods are defined on the `Spectator` module,
  # that retrieve and set the property from/on the current sandbox.
  #
  # ```
  # Spectator.sandbox_property current_example : Example?
  # ```
  # is similar to:
  # ```
  # module Spectator
  #   def self.current_example
  #     sandbox.current_example
  #   end
  #
  #   def self.current_example=(value)
  #     sandbox.current_example = value
  #   end
  #
  #   module Core
  #     class Sandbox
  #       property current_example : Example?
  #     end
  #   end
  # end
  # ```
  macro sandbox_property(prop)
    {% if prop.is_a?(TypeDeclaration)
         name = prop.var
       elsif prop.is_a?(Assign)
         name = prop.target
       else
         name = prop
       end %}

    module ::Spectator
      def self.{{name.id}}
        sandbox.{{name.id}}
      end

      def self.{{name.id}}=(value)
        sandbox.{{name.id}} = value
      end

      class Core::Sandbox
        property {{prop}}
      end
    end
  end
end
