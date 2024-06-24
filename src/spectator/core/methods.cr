require "./example"

module Spectator::Core
  module Methods
    abstract def context(description, &)

    def describe(description, &)
      context(description) { with self yield self }
    end

    abstract def specify(description, &block : Example ->) : Example

    # def it(description, &block : Example ->) : Example
    #   specify(description, &block)
    # end

    # macro it(description, &block)
    #   specify({{description}}) do {% if !block.args.empty? %} |{{block.args.splat}}| {% end %}
    #     {{yield}}
    #   end
    # end
  end
end
