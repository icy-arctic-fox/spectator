require "./matcher"

module Spectator::Matchers
  module CustomDSL
    macro match(*, block = false, &impl)
      {% raise <<-END_OF_ERROR unless impl
        The `match` definition for a custom matcher requires a block.

        Use:

          match#{"(block: #{block})".id if block} do
            ...
          end
        END_OF_ERROR
      %}

      {% if block %}
        {% raise <<-END_OF_ERROR unless impl.args.empty?
          The `match` definition for a custom matcher accepting a block cannot have arguments.
          Instead of:

            match(block: #{block}) do |#{impl.args.splat}|
              ...
            end

          Use:

            match(block: #{block}) do
              ...
            end
          END_OF_ERROR
        %}

        private def _matches_impl({{impl.args.splat(",")}} &)
          {{yield}}
        end

        def matches?(&block) : Bool
          !!_matches_impl(&block)
        end
      {% else %}
        {% raise <<-END_OF_ERROR if impl.args.size > 1
          The `match` definition for a custom matcher cannot have more than one block argument - the actual value.
          Instead of:

            match do |#{impl.args.splat}|
              ...
            end

          Use:

            match do |#{impl.args[0]}|
              ...
            end
          END_OF_ERROR
        %}

        private def _matches_impl({{impl.args.splat}})
          {{yield}}
        end

        def matches?(actual_value) : Bool
          !!_matches_impl({% unless impl.args.empty? %}actual_value{% end %})
        end
      {% end %}
    end

    macro failure_message(*, block = false, &impl)
      {% raise <<-END_OF_ERROR unless impl
        The `failure_message` definition for a custom matcher requires a block.

        Use:

          failure_message#{"(block: #{block})".id if block} do
            ...
          end
        END_OF_ERROR
      %}

      {% if block %}
        {% raise <<-END_OF_ERROR unless impl.args.empty?
          The `failure_message` definition for a custom matcher accepting a block cannot have arguments.
          Instead of:

            failure_message(block: #{block}) do |#{impl.args.splat}|
              ...
            end

          Use:

            failure_message(block: #{block}) do
              ...
            end
          END_OF_ERROR
        %}

        private def _failure_message_impl({{impl.args.splat(",")}} &)
          {{yield}}
        end

        def failure_message(&block) : String
          _failure_message_impl(&block)
        end
      {% else %}
        {% raise <<-END_OF_ERROR if impl.args.size > 1
          The `failure_message` definition for a custom matcher cannot have more than one block argument - the actual value.
          Instead of:

            failure_message do |#{impl.args.splat}|
              ...
            end

          Use:

            failure_message do |#{impl.args[0]}|
              ...
            end
          END_OF_ERROR
        %}

        private def _failure_message_impl({{impl.args.splat}})
          {{yield}}
        end

        def failure_message(actual_value) : String
          !!_failure_message_impl({% unless impl.args.empty? %}actual_value{% end %})
        end
      {% end %}
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
