require "./example"

module Spectator
  class MetadataExample(Metadata)
    getter metadata : Metadata

    def initialize(@example : Example, @metadata : Metadata)
    end

    forward_missing_to @example
  end
end
