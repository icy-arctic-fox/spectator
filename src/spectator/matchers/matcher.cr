module Spectator::Matchers
  abstract class Matcher
  end
end

# Matcher API:
#   - #matches?(actual)
#   - #failure_message
#   - #failure_message_when_negated
#   - #description
#   - #does_not_match?(actual)
#   - #===(actual)
