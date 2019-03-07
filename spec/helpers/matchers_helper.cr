# Retrieves a value from the `NamedTuple` returned by `Spectator::Matchers::MatchData#values`.
def match_data_value(match_data, key, t : T.class) forall T
  match_data.values.fetch(key) { raise "#{key} is missing" }.as(T)
end

# Retrieves the string representation and base value
# from a `Spectator::Matchers::PrefixedValue`
# in a `NamedTuple` returned by `Spectator::Matchers::MatchData#values`.
def match_data_prefix(match_data, key, t : T.class) forall T
  prefix = match_data_value(match_data, key, Spectator::Matchers::PrefixGrabber.get(t))
  {to_s: prefix.to_s, value: prefix.value}
end

# Dirty cheat to get around visibility restriction.
module Spectator::Matchers
  module PrefixGrabber
    extend self

    def get(t : T.class) forall T
      PrefixedValue(T)
    end
  end
end
