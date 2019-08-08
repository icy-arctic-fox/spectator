require "./matcher"

module Spectator::Matchers
  # Common matcher that tests whether a value is nil.
  # The `Object#nil?` method is used for this.
  struct NilMatcher < StandardMatcher
    private def match?(actual)
      actual.value.nil?
    end

    def description
      "is nil"
    end

    private def failure_message(actual)
      "#{actual.label} is not nil"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is nil"
    end
  end
end
