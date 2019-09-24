require "./example_group"

module Spectator
  # Top-most group of examples and sub-groups.
  # The root has no parent.
  class RootExampleGroup < ExampleGroup
    # Dummy value - this should never be used.
    def what : Symbol | String
      "ROOT"
    end

    # Indicates that the group is symbolic.
    def symbolic? : Bool
      true
    end

    # Does nothing.
    # This prevents the root group
    # from showing up in output.
    def to_s(io)
      # ...
    end
  end
end
