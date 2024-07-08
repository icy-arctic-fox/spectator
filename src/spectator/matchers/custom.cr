module Spectator::Matchers
  module CustomDSL
    macro match(&block)
      def _matches_impl({{block.args.splat}})
        {{yield}}
      end

      def matches?(actual : T) : Bool forall T
        !!_matches_impl(actual)
      end
    end
  end

  abstract struct CustomMatcher
    include CustomDSL

    abstract def matches?(actual : T) : Bool forall T

    abstract def failure_message(actual : T) : String
  end

  macro define(name, *properties, **kwargs, &)
    {% raise <<-END_OF_ERROR unless kwargs.empty?
      macro `Spectator::Matchers.define` does not accept named arguments
        Did you mean:

        Spectator::Matchers.define #{name}, #{(properties + kwargs.map { |k, v| "#{k} : #{v}" }).join(", ").id}
      END_OF_ERROR
    %}
    ::record(TestCustomMatcher < ::Spectator::Matchers::CustomMatcher, {{properties.splat}}) do
      {{yield}}
    end
  end
end
