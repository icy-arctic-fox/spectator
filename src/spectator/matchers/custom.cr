require "./matcher"

module Spectator::Matchers
  module CustomDSL
    macro match(&block)
      def _matches_impl({{block.args.splat}})
        {{yield}}
      end

      def matches?(actual_value : T) : Bool forall T
        !!_matches_impl(actual_value)
      end
    end

    macro failure_message(&block)
      def _failure_message_impl({{block.args.splat}})
        {{yield}}
      end

      def failure_message(actual_value : T) : String forall T
        _failure_message_impl(actual_value)
      end
    end
  end

  abstract struct CustomMatcher < Matcher
    include CustomDSL
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