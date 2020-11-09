require "./builder"

module Spectator::DSL
  # DSL methods for adding custom logic to key times of the spec execution.
  module Hooks
    # Defines code to run before any and all examples in an example group.
    macro before_all(&block)
      {% raise "Cannot use 'before_all' inside of a test block" if @def %}

      def self.%hook : Nil
        {{block.body}}
      end

      ::Spectator::DSL::Builder.before_all { {{@type.name}}.%hook }
    end

    macro before_each(&block)
      {% raise "Cannot use 'before_each' inside of a test block" if @def %}

      def %hook : Nil
        {{block.body}}
      end

      ::Spectator::DSL::Builder.before_each do |example|
        example.with_context({{@type.name}}) { %hook }
      end
    end

    macro after_all(&block)
    end

    macro after_each(&block)
    end
  end
end
