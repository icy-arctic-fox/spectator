require "./hooks"
require "./sandbox"

module Spectator
  module Core
    # Options for controlling the behavior of Spectator.
    class Configuration
      include Hooks
    end
  end

  # Defines a property that can be accessed from the configuration.
  # This is effectively the same as using the `property` macro within the `Core::Configuration` class.
  macro config_property(prop)
    module ::Spectator::Core
      class Configuration
        property {{prop}}
      end
    end
  end

  # Defines a predicate property that can be accessed from the configuration.
  # This is effectively the same as using the `property?` macro within the `Core::Configuration` class.
  macro config_property?(prop)
    module ::Spectator::Core
      class Configuration
        property? {{prop}}
      end
    end
  end

  # Defines a property that behaves like a number and a boolean.
  # The property can be accessed from the configuration.
  # The property is stored as a number
  # When using the predicate method, a boolean is returned, which is true if the property is greater than zero.
  # Additionally, the property can be set to a boolean.
  # When setting to true, it's set to the property's default integer value.
  # When setting to false, it's set to 0.
  #
  # ```
  # Spectator.config_numeric_property profile_examples = 5
  # ```
  # allows the following:
  # ```
  # Spectator.configure do |config|
  #   config.profile_examples = true  # Same as `config.profile_examples = 5`
  #   config.profile_examples = false # Same as `config.profile_examples = 0`
  #   config.profile_examples = 10
  #   config.profile_examples? # => true
  #   config.profile_examples = 0
  #   config.profile_examples? # => false
  # end
  macro config_numeric_property(prop, truthy = nil)
    {% name = if prop.is_a?(TypeDeclaration)
                prop.var
              elsif prop.is_a?(Assign)
                prop.target
              else
                raise "A type declaration or assignment is required"
              end %}

    module ::Spectator::Core
      class Configuration
        property {{prop}}

        def {{name}}?
          @{{name}} > 0
        end

        def {{name}}=(flag : Bool)
          @{{name}} = flag ? {{ if truthy
                                  truthy
                                elsif prop.is_a?(TypeDeclaration)
                                  prop.value ? prop.value : 1
                                else # Assign
                                  prop.value
                                end }} : 0
        end
      end
    end
  end

  # Current configuration.
  Spectator.sandbox_getter configuration = Configuration.new

  # Modifies the current configuration.
  # The configuration is provided as an argument to the block.
  # See `Configuration` for available options.
  def Spectator.configure(& : Core::Configuration ->) : Core::Configuration
    yield configuration
    configuration
  end
end
