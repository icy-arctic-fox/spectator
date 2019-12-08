module Spectator
  module DSL
    macro let(name, &block)
      @%wrapper : ::Spectator::ValueWrapper?

      def {{name.id}}
        {{block.body}}
      end

      def {{name.id}}
        if (wrapper = @%wrapper)
          wrapper.as(::Spectator::TypedValueWrapper(typeof(previous_def))).value
        else
          previous_def.tap do |value|
            @%wrapper = ::Spectator::TypedValueWrapper.new(value)
          end
        end
      end
    end

    macro let!(name, &block)
      # TODO: Doesn't work with late-defined values (let).
      @%value = {{yield}}

      def {{name.id}}
        @%value
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
end
