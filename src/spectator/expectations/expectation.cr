require "../matchers/failed_match_data"
require "../matchers/match_data"
require "../source"

module Spectator::Expectations
  # Result of evaluating a matcher on an expectation partial.
  struct Expectation
    # Location where this expectation was defined.
    getter source : Source

    # Creates the expectation.
    def initialize(@match_data : Matchers::MatchData, @source : Source)
    end

    # Indicates whether the matcher was satisified.
    def satisfied?
      @match_data.matched?
    end

    # Indicates that the expectation was not satisified.
    def failure?
      !satisfied?
    end

    # Description of why the match failed.
    # If nil, then the match was successful.
    def failure_message?
      @match_data.as?(Matchers::FailedMatchData).try(&.failure_message)
    end

    # Description of why the match failed.
    def failure_message
      failure_message?.not_nil!
    end

    # Additional information about the match, useful for debug.
    # If nil, then the match was successful.
    def values?
      @match_data.as?(Matchers::FailedMatchData).try(&.values)
    end

    # Additional information about the match, useful for debug.
    def values
      values?.not_nil!
    end

    # Creates the JSON representation of the expectation.
    def to_json(json : ::JSON::Builder)
      json.object do
        json.field("source") { @source.to_json(json) }
        json.field("satisfied", satisfied?)
        if (failed = @match_data.as?(Matchers::FailedMatchData))
          failed_to_json(failed, json)
        end
      end
    end

    # Adds failure information to a JSON structure.
    private def failed_to_json(failed : Matchers::FailedMatchData, json : ::JSON::Builder)
      json.field("failure", failed.failure_message)
      json.field("values") do
        json.object do
          failed.values.each do |pair|
            json.field(pair.first, pair.last)
          end
        end
      end
    end
  end
end
