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

      ::Spectator::DSL::Builder.before_all(
        ::Spectator::Source.new({{block.filename}}, {{block.line_number}})
      ) { {{@type.name}}.%hook }
    end

    macro before_each(&block)
      {% raise "Cannot use 'before_each' inside of a test block" if @def %}

      def %hook : Nil
        {{block.body}}
      end

      ::Spectator::DSL::Builder.before_each(
        ::Spectator::Source.new({{block.filename}}, {{block.line_number}})
      ) { |example| example.with_context({{@type.name}}) { %hook } }
    end

    macro after_all(&block)
      {% raise "Cannot use 'after_all' inside of a test block" if @def %}

      def self.%hook : Nil
        {{block.body}}
      end

      ::Spectator::DSL::Builder.after_all(
        ::Spectator::Source.new({{block.filename}}, {{block.line_number}})
      ) { {{@type.name}}.%hook }
    end

    macro after_each(&block)
      {% raise "Cannot use 'after_each' inside of a test block" if @def %}

      def %hook : Nil
        {{block.body}}
      end

      ::Spectator::DSL::Builder.after_each(
        ::Spectator::Source.new({{block.filename}}, {{block.line_number}})
      ) { |example| example.with_context({{@type.name}}) { %hook } }
    end
  end
end
