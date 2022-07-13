require "../lazy_wrapper"
require "./reserved"

module Spectator::DSL
  # DSL methods for defining test values (subjects).
  # These values are stored and reused throughout the test.
  module Memoize
    # Defines a memoized getter.
    # The *name* is the name of the getter method.
    # The block is evaluated only on the first time the getter is used
    # and the return value is saved for subsequent calls.
    macro let(name, &block)
      {% raise "Missing block for 'let'" unless block %}
      {% raise "Expected zero or one arguments for 'let', but got #{block.args.size}" if block.args.size > 1 %}
      {% raise "Cannot use 'let' inside of an example block" if @def %}
      {% raise "Cannot use '#{name.id}' for 'let'" if name.id.starts_with?("_spectator") || ::Spectator::DSL::RESERVED_KEYWORDS.includes?(name.id.symbolize) %}

      @%value = ::Spectator::LazyWrapper.new

      private def {{name.id}}
        {% if block.args.size > 0 %}
          {{block.args.first}} = ::Spectator::Example.current
        {% end %}
        @%value.get do
          {{block.body}}
        end
      end
    end

    # Defines a memoized getter.
    # The *name* is the name of the getter method.
    # The block is evaluated once before the example runs
    # and the return value is saved.
    macro let!(name, &block)
      {% raise "Missing block for 'let!'" unless block %}
      {% raise "Expected zero or one arguments for 'let!', but got #{block.args.size}" if block.args.size > 1 %}
      {% raise "Cannot use 'let!' inside of an example block" if @def %}
      {% raise "Cannot use '#{name.id}' for 'let!'" if name.id.starts_with?("_spectator") || ::Spectator::DSL::RESERVED_KEYWORDS.includes?(name.id.symbolize) %}

      let({{name}}) {{block}}
      before_each { {{name.id}} }
    end

    # Explicitly defines the subject of the tests.
    # Creates a memoized getter for the subject.
    # The block is evaluated only the first time the subject is referenced
    # and the return value is saved for subsequent calls.
    macro subject(&block)
      {% raise "Missing block for 'subject'" unless block %}
      {% raise "Expected zero or one arguments for 'let!', but got #{block.args.size}" if block.args.size > 1 %}
      {% raise "Cannot use 'subject' inside of an example block" if @def %}

      let(subject) {{block}}
    end

    # Explicitly defines the subject of the tests.
    # Creates a memoized getter for the subject.
    # The subject can be referenced by using `subject` or *name*.
    # The block is evaluated only the first time the subject is referenced
    # and the return value is saved for subsequent calls.
    macro subject(name, &block)
      {% raise "Missing block for 'subject'" unless block %}
      {% raise "Expected zero or one arguments for 'subject', but got #{block.args.size}" if block.args.size > 1 %}
      {% raise "Cannot use 'subject' inside of an example block" if @def %}
      {% raise "Cannot use '#{name.id}' for 'subject'" if name.id.starts_with?("_spectator") || ::Spectator::DSL::RESERVED_KEYWORDS.includes?(name.id.symbolize) %}

      let({{name.id}}) {{block}}

      {% if name.id != :subject.id %}
        private def subject
          {{name.id}}
        end
      {% end %}
    end

    # Explicitly defines the subject of the tests.
    # Creates a memoized getter for the subject.
    # The block is evaluated once before the example runs
    # and the return value is saved for subsequent calls.
    macro subject!(&block)
      {% raise "Missing block for 'subject'" unless block %}
      {% raise "Expected zero or one arguments for 'subject!', but got #{block.args.size}" if block.args.size > 1 %}
      {% raise "Cannot use 'subject!' inside of an example block" if @def %}

      let!(subject) {{block}}
    end

    # Explicitly defines the subject of the tests.
    # Creates a memoized getter for the subject.
    # The subject can be referenced by using `subject` or *name*.
    # The block is evaluated once before the example runs
    # and the return value is saved for subsequent calls.
    macro subject!(name, &block)
      {% raise "Missing block for 'subject'" unless block %}
      {% raise "Expected zero or one arguments for 'subject!', but got #{block.args.size}" if block.args.size > 1 %}
      {% raise "Cannot use 'subject!' inside of an example block" if @def %}
      {% raise "Cannot use '#{name.id}' for 'subject!'" if name.id.starts_with?("_spectator") || ::Spectator::DSL::RESERVED_KEYWORDS.includes?(name.id.symbolize) %}

      let!({{name.id}}) {{block}}

      {% if name.id != :subject.id %}
        private def subject
          {{name.id}}
        end
      {% end %}
    end
  end
end
