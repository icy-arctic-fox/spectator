require "./test_case"

module Spectator::Formatters::JUnit
  struct PassedTestCase < TestCase
    private def has_inner_content? : Bool
      false
    end

    private def print_inner(io : IO, indent : Int) : Nil
    end
  end
end
