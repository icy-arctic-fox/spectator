require "./matcher"

module Spectator::Matchers
  module CustomDSL
    macro match(&block)
      private def _matches_impl({{block.args.splat}})
        {{yield}}
      end

      def matches?(actual_value) : Bool
        !!_matches_impl(actual_value)
      end
    end

    macro failure_message(&block)
      private def _failure_message_impl({{block.args.splat}})
        {{yield}}
      end

      def failure_message(actual_value) : String
        _failure_message_impl(actual_value)
      end
    end
  end

  abstract struct CustomMatcher
    include CustomDSL
  end

  module Custom
  end

  macro define(name, *properties, **kwargs, &)
    {% raise <<-END_OF_ERROR unless kwargs.empty?
      macro `Spectator::Matchers.define` does not accept named arguments
        Did you mean:

        Spectator::Matchers.define #{name}, #{(properties + kwargs.map { |k, v| "#{k} : #{v}" }).join(", ").id}
      END_OF_ERROR
    %}
    {% matcher_name = name.id.camelcase %}
    ::record({{matcher_name}} < ::Spectator::Matchers::CustomMatcher, {{properties.splat}}) do
      {{yield}}
    end

    module ::Spectator::Matchers::Custom
      def {{name.id}}({{properties.splat(", ")}} *,
                      source_file = __FILE__,
                      source_line = __LINE__,
                      source_end_line = __END_LINE__)
        # TODO: Store location.
        {{matcher_name}}.new({{properties.map(&.var).splat(", ")}})
      end
    end
  end
end

# TODO: Is it possible to move this out of the global namespace?
include Spectator::Matchers::Custom
