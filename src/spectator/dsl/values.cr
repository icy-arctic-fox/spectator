require "../lazy_wrapper"

module Spectator::DSL
  # DSL methods for defining test values (subjects).
  module Values
    # Defines a memoized getter.
    # The *name* is the name of the getter method.
    # The block is evaluated only on the first time the getter is used
    # and the return value is saved for subsequent calls.
    macro let(name, &block)
      {% raise "Block required for 'let'" unless block %}
      {% raise "Cannot use 'let' inside of a test block" if @def %}
      {% raise "Block argument count for 'let' must be 0..1" if block.args.size > 1 %}

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
      {% raise "Block required for 'let!'" unless block %}
      {% raise "Cannot use 'let!' inside of a test block" if @def %}
      {% raise "Block argument count for 'let!' must be 0..1" if block.args.size > 1 %}

      let({{name}}) {{block}}
      before_each { {{name.id}} }
    end

    # Explicitly defines the subject of the tests.
    # Creates a memoized getter for the subject.
    # The block is evaluated only the first time the subject is referenced
    # and the return value is saved for subsequent calls.
    macro subject(&block)
      {% raise "Block required for 'subject'" unless block %}
      {% raise "Cannot use 'subject' inside of a test block" if @def %}
      {% raise "Block argument count for 'subject' must be 0..1" if block.args.size > 1 %}

      let(subject) {{block}}
    end

    # Explicitly defines the subject of the tests.
    # Creates a memoized getter for the subject.
    # The subject can be referenced by using `subject` or *name*.
    # The block is evaluated only the first time the subject is referenced
    # and the return value is saved for subsequent calls.
    macro subject(name, &block)
      {% raise "Block required for 'subject'" unless block %}
      {% raise "Cannot use 'subject' inside of a test block" if @def %}
      {% raise "Block argument count for 'subject' must be 0..1" if block.args.size > 1 %}

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
      {% raise "Block required for 'subject!'" unless block %}
      {% raise "Cannot use 'subject!' inside of a test block" if @def %}
      {% raise "Block argument count for 'subject!' must be 0..1" if block.args.size > 1 %}

      let!(subject) {{block}}
    end

    # Explicitly defines the subject of the tests.
    # Creates a memoized getter for the subject.
    # The subject can be referenced by using `subject` or *name*.
    # The block is evaluated once before the example runs
    # and the return value is saved for subsequent calls.
    macro subject!(name, &block)
      {% raise "Block required for 'subject!'" unless block %}
      {% raise "Cannot use 'subject!' inside of a test block" if @def %}
      {% raise "Block argument count for 'subject!' must be 0..1" if block.args.size > 1 %}

      let!({{name.id}}) {{block}}

      {% if name.id != :subject.id %}
        private def subject
          {{name.id}}
        end
      {% end %}
    end
  end
end
