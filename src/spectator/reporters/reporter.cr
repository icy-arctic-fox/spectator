module Spectator::Reporters
  module Reporter
    def example_started(example : Core::Example) : Nil
    end

    def example_finished(example : Core::Example, result : Core::Result) : Nil
    end
  end
end
