module Spectator::SpecHelpers
  # Information about an example compiled and run at runtime.
  struct Result
    # Status of the example after running.
    enum Outcome
      Success
      Failure
      Error
      Unknown
    end

    # Full name and description of the example.
    getter name : String

    # Status of the example after running.
    getter outcome : Outcome

    # List of expectations ran in the example.
    getter expectations : Array(Expectation)

    # Creates the result.
    def initialize(@name, @outcome, @expectations)
    end

    # Checks if the example was successful.
    def success?
      outcome.success?
    end

    # :ditto:
    def successful?
      outcome.success?
    end

    # Checks if the example failed, but did not error.
    def failure?
      outcome.failure?
    end

    # Checks if the example encountered an error.
    def error?
      outcome.error?
    end

    # Extracts the result information from a `JSON::Any` object.
    def self.from_json_any(object : JSON::Any)
      name = object["name"].as_s
      outcome = parse_outcome_string(object["result"].as_s)
      expectations = if (list = object["expectations"].as_a?)
                       list.map { |e| Expectation.from_json_any(e) }
                     else
                       [] of Expectation
                     end
      new(name, outcome, expectations)
    end

    # Converts a result string, such as "fail" to an enum value.
    private def self.parse_outcome_string(string)
      case string
      when /pass/i  then Outcome::Success
      when /fail/i  then Outcome::Failure
      when /error/i then Outcome::Error
      else               Outcome::Unknown
      end
    end
  end
end
