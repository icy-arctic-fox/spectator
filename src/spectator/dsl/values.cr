module Spectator::DSL
  module Values
  end

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
