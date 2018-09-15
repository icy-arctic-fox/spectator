module Spectator
  module DSL
    module ExampleDSL
      macro is_expected
        expect(subject)
      end
    end
  end
end
