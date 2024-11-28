require "../printable"

module Spectator::Matchers::BuiltIn
  # Matches if the value changes from the previous value.
  class ChangeMatcher(T)
    include Formatting
    include Printable

    private getter! description_of_before : String
    private getter! description_of_after : String

    def initialize(@subject : -> T)
    end

    def matches?(actual_value)
      matches? { actual_value.call } # TODO: Raise error.
    end

    def matches?(&)
      before = @subject.call
      @description_of_before = description_of before
      yield
      after = @subject.call
      @description_of_after = description_of after
      after != before
    end

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      # TODO: Raise a compiler error.
    end

    def print_failure_message_when_negated(printer : FormattingPrinter, &)
      printer << "Expected: " << description_of_before
      printer.puts "to change, but it stayed the same."
      if description_of_before != description_of_after
        printer.puts
        printer.puts "The string representation of the value changed, but the == operator returned true."
        printer << "  Before: " << description_of_before << EOL
        printer << "   After: " << description_of_after
      end
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      # TODO: Raise a compiler error.
    end

    def negated_failure_message(printer : FormattingPrinter, &)
      printer << "Expected: " << description_of_before
      printer.puts "to stay the same, but it changed."
      printer.puts
      printer << "  Before: " << description_of_before << EOL
      printer << "   After: " << description_of_after
    end

    def from(value)
      ChangeFromMatcher.new(@subject, value)
    end

    def to(value)
      ChangeToMatcher.new(@subject, value)
    end

    def by(value)
      ChangeByMatcher.new(@subject, value, :exact)
    end

    def by_at_least(value)
      ChangeByMatcher.new(@subject, value, :at_least)
    end

    def by_at_most(value)
      ChangeByMatcher.new(@subject, value, :at_most)
    end
  end

  class ChangeFromMatcher(T, B)
    include Formatting
    include Printable

    private getter! description_of_before : String
    private getter! description_of_after : String
    private getter? unexpected_before = false

    def initialize(@subject : -> T, from @before : B)
    end

    def matches?(actual_value)
      matches? { actual_value.call } # TODO: Raise error.
    end

    def matches?(&)
      before = @subject.call
      @description_of_before = description_of before
      if before != @before
        @unexpected_before = true
        return false
      end
      yield
      after = @subject.call
      @description_of_after = description_of after
      after != before
    end

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      # TODO: Raise a compiler error.
    end

    def failure_message(printer : FormattingPrinter, &)
      if unexpected_before?
        printer << "       Expected: "
        printer.puts description_of_before
        printer << "to initially be: "
        printer.description_of @before
      else
        printer << "      Expected: "
        printer.puts description_of_before
        printer << "to change from: "
        printer.description_of @before
        printer.puts
        printer << "but it stayed the same."
        if description_of_before != description_of_after
          printer.puts
          printer.puts "The string representation of the value changed, but the == operator returned true."
          printer << "        Before: " << description_of_before
          printer.puts
          printer << "         After: " << description_of_after
        end
      end
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      # TODO: Raise a compiler error.
    end

    def negated_failure_message(printer : FormattingPrinter, &)
      if unexpected_before?
        printer << "       Expected: "
        printer.puts description_of_before
        printer << "to initially be: "
        printer.description_of @before
      else
        printer << "Expected: "
        printer.puts description_of_before
        printer << "to stay the same, but it changed."
        printer.puts
        printer << "  Before: " << description_of_before
        printer.puts
        printer << "   After: " << description_of_after
      end
    end

    def to(value)
      ChangeFromToMatcher.new(@subject, @before, value)
    end
  end

  class ChangeToMatcher(T, A)
    include Formatting
    include Printable

    private getter! description_of_before : String
    private getter! description_of_after : String
    private getter? changed = false

    def initialize(@subject : -> T, to @after : A)
    end

    def matches?(actual_value)
      matches? { actual_value.call } # TODO: Raise error.
    end

    def matches?(&)
      before = @subject.call
      @description_of_before = description_of before
      yield
      after = @subject.call
      @description_of_after = description_of after
      (@changed = before != after) && after == @after
    end

    def does_not_match?(actual_value)
      # TODO: Use a compiler error.
      does_not_match? { actual_value.call }
    end

    def does_not_match?(&)
      # TODO: Use a compiler error.
      raise Spectator::FrameworkError.new("The syntax `expect { }.not_to change { }.to()` is not supported.")
    end

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      # TODO: Raise a compiler error.
    end

    def failure_message(printer : FormattingPrinter, &)
      if changed?
        printer << "    Expected: "
        printer.puts description_of_before
        printer << "to change to: "
        printer.description_of @after
        printer.puts
        printer << "  but is now: " << description_of_after
      else
        printer << "      Expected: "
        printer.puts description_of_before
        printer << "  to change to: "
        printer.description_of @after
        printer.puts
        printer << "but already is: "
        printer.description_of description_of_after
      end
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      # TODO: Use a compiler error.
      raise Spectator::FrameworkError.new("The syntax `expect { }.not_to change { }.to()` is not supported.")
    end

    def negated_failure_message(printer : FormattingPrinter, &)
      # TODO: Use a compiler error.
      failure_message(printer)
    end

    def from(value)
      ChangeFromToMatcher.new(@subject, value, @after)
    end
  end

  class ChangeFromToMatcher(T, B, A)
    include Formatting
    include Printable

    private getter! description_of_before : String
    private getter! description_of_after : String
    private getter? unexpected_before = false

    def initialize(@subject : -> T, from @before : B, to @after : A)
      # TODO: Warn if before and after are the same.
    end

    def matches?(actual_value)
      matches? { actual_value.call } # TODO: Raise error.
    end

    def matches?(&)
      before = @subject.call
      @description_of_before = description_of before
      if before != @before
        @unexpected_before = true
        return false
      end
      yield
      after = @subject.call
      @description_of_after = description_of after
      after == @after
    end

    def does_not_match?(actual_value)
      # TODO: Use a compiler error.
      does_not_match? { actual_value.call }
    end

    def does_not_match?(&)
      # TODO: Use a compiler error.
      raise Spectator::FrameworkError.new("The syntax `expect { }.not_to change { }.to()` is not supported.")
    end

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      # TODO: Raise a compiler error.
    end

    def failure_message(printer : FormattingPrinter, &)
      if unexpected_before?
        printer << "       Expected: "
        printer.puts description_of_before
        printer << "to initially be: "
        printer.description_of @before
      else
        printer << "      Expected: "
        printer.puts description_of_before
        printer << "to change from: "
        printer.description_of @before
        printer.puts
        printer << "            to: "
        printer.description_of @after
        printer.puts
        printer << "but it stayed the same."
        if description_of_before != description_of_after
          printer.puts
          printer.puts "The string representation of the value changed, but the == operator returned true."
          printer << "        Before: " << description_of_before
          printer.puts
          printer << "         After: " << description_of_after
        end
      end
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      # TODO: Use a compiler error.
      raise Spectator::FrameworkError.new("The syntax `expect { }.not_to change { }.to()` is not supported.")
    end

    def negated_failure_message(printer : FormattingPrinter, &)
      # TODO: Use a compiler error.
      failure_message(printer)
    end
  end

  # expect { thing }.to change { subject }.by(1)
  # expect { thing }.to change { subject }.by_at_least(1)
  # expect { thing }.to change { subject }.by_at_most(1)
  # expect { thing }.to increase { subject }.by(1)
  # expect { thing }.to increase { subject }.by_at_least(1)
  # expect { thing }.to increase { subject }.by_at_most(1)
  # expect { thing }.to decrease { subject }.by(1)
  # expect { thing }.to decrease { subject }.by_at_least(1)
  # expect { thing }.to decrease { subject }.by_at_most(1)
  #
  # class ChangeByMatcher(T, U)
  #   include Printable

  #   enum Comparison
  #     Exact
  #     AtLeast
  #     AtMost

  #     def to_s(io : IO) : Nil
  #       io << case self
  #       in .exact?    then "by"
  #       in .at_least? then "by at least"
  #       in .at_most?  then "by at most"
  #       end
  #     end
  #   end

  #   def initialize(@subject : -> T, by @delta : U, @comparison : Comparison)
  #   end
  # end
end
