# Retrieves a value from the `NamedTuple` returned by `Spectator::Matchers::MatchData#values`.
def match_data_value(match_data, key)
  match_data.values.fetch(key) { raise "#{key} is missing" }
end

# Retrieves the string representation and base value
# from a `Spectator::Matchers::PrefixedValue`
# in a `NamedTuple` returned by `Spectator::Matchers::MatchData#values`.
def match_data_prefix(match_data, key)
  prefix = match_data.values.fetch(key) { raise "#{key} is missing" }
  if prefix.responds_to?(:value)
    {to_s: prefix.to_s, value: prefix.value}
  else
    {to_s: prefix.to_s, value: prefix}
  end
end
