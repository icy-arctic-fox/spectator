module Spectator
  # User-defined keywords used for filtering and behavior modification.
  alias Tags = Set(Symbol)

  # User-defined keywords used for filtering and behavior modification.
  # The value of a tag is optional, but may contain useful information.
  # If the value is nil, the tag exists, but has no data.
  # However, when tags are given on examples and example groups,
  # if the value is falsey (false or nil), then the tag should be removed from the overall collection.
  alias Metadata = Hash(Symbol, String?)
end
