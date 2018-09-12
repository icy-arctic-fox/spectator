module Spectator
  module ExampleDSL
    macro is_expected
      expect(subject)
    end
  end
end
