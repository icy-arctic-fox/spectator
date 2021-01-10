require "../lazy_wrapper"

module Spectator::DSL
  # DSL methods for defining test values (subjects).
  module Values
    macro let(name, &block)
      {% raise "Block required for 'let'" unless block %}

      @%value = ::Spectator::LazyWrapper.new

      def {{name.id}}
        @%value.get {{block}}
      end
    end
  end

  macro let!(name, &block)
      @%wrapper : ::Spectator::ValueWrapper?

      def %wrapper
        {{block.body}}
      end

      before_each do
        @%wrapper = ::Spectator::TypedValueWrapper.new(%wrapper)
      end

      def {{name.id}}
        @%wrapper.as(::Spectator::TypedValueWrapper(typeof(%wrapper))).value
      end
    end

  macro subject(&block)
      {% if block.is_a?(Nop) %}
        self.subject
      {% else %}
        let(:subject) {{block}}
      {% end %}
    end

  macro subject(name, &block)
      let({{name.id}}) {{block}}

      def subject
        {{name.id}}
      end
    end

  macro subject!(&block)
      let!(:subject) {{block}}
    end

  macro subject!(name, &block)
      let!({{name.id}}) {{block}}

      def subject
        {{name.id}}
      end
    end
end
