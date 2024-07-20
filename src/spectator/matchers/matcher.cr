require "./match_data"

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

    private def pass(*, negated : Bool = false) : MatchData
      MatchData.pass(negated: negated)
    end

    private def fail(*,
                     negated : Bool = false,
                     message : String? = nil,
                     fields : Enumerable(MatchData::Field) = [] of MatchData::Field) : MatchData
      MatchData.fail(negated: negated, message: message, fields: fields)
    end
  end
end
