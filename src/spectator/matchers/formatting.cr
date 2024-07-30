module Spectator::Matchers
  module Formatting
    private def description_of(value)
      # TODO: Actually format the value.
      value.inspect
    end

    private def format_description_of(io : IO, value) : Nil
      value.inspect(io)
    end
  end
end
