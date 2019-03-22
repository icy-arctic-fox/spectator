# Retrieves a value from match data given its key/label.
def match_data_value_with_key(match_data_values, key)
  labeled_value = match_data_values.find { |v| v.label == key }
  raise "#{key} is missing" unless labeled_value
  labeled_value.value
end

# Retrieves the string representation and base value
# from a `Spectator::Matchers::PrefixedMatchDataValue` (or similar)
# in the values returned by `Spectator::Matchers::MatchData#values`.
def match_data_value_sans_prefix(match_data_values, key)
  prefix = match_data_value_with_key(match_data_values, key)
  {to_s: prefix.to_s, value: prefix.value}
end

# Check whether match data has a value with a specified key/label.
def match_data_has_key?(match_data_values, key)
  found = match_data_values.find { |v| v.label == key }
  !!found
end
