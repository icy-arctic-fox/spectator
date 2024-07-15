module Spectator::Matchers
  abstract struct Matcher
    abstract def match(actual_value, failure_message = nil) : MatchData
    abstract def negated_match(actual_value, failure_message = nil) : MatchData

    def matches?(actual_value) : Bool
      match(actual_value).success?
    end

    def does_not_match?(actual_value) : Bool
      negated_match(actual_value).success?
    end

    def failure_message(actual_value) : String
      match(actual_value).message
    end

    def negated_failure_message(actual_value) : String
      negated_match(actual_value).message
    end

    private def pass(*, negated = false) : MatchData
      MatchData.new(true, negated)
    end

    private def fail(*, negated = false, message = nil, fields = nil) : MatchData
      MatchData.new(false, negated, message: message, fields: fields)
    end
  end
end
