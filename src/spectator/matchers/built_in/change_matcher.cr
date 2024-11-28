require "../formatting"
require "../match_failure"

module Spectator::Matchers::BuiltIn
  private abstract struct CommonChangeMatcher(T)
    include Formatting

    abstract def match(&) : MatchFailure?
    abstract def match_negated(&) : MatchFailure?

    def initialize(@subject : -> T)
    end
  end

  # Matches if the value changes from the previous value.
  struct ChangeMatcher(T) < CommonChangeMatcher(T)
    def match(&) : MatchFailure?
      value_before = yield
      description_before = description_of(value_before)

      @subject.call

      value_after = yield
      description_after = description_of(value_after)

      return if value_after != value_before

      MatchFailure.new do |printer|
        printer << "Expected: " << description_before << "to change, but it stayed the same." << EOL
        printer << "  Before: " << description_before << EOL
        printer << "   After: " << description_after
        if description_before != description_after
          printer.puts
          printer.puts "The string representation of the value changed, but the == operator returned true."
        end
      end
    end

    def match_negated(&) : MatchFailure?
      value_before = yield
      description_before = description_of(value_before)

      @subject.call

      value_after = yield
      description_after = description_of(value_after)

      return if value_after == value_before

      MatchFailure.new do |printer|
        printer << "Expected: " << description_before << "to stay the same, but it changed." << EOL
        printer << "  Before: " << description_before << EOL
        printer << "   After: " << description_after
      end
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

  struct ChangeFromMatcher(T, B) < CommonChangeMatcher(T)
    def initialize(subject : -> T, from @before : B)
      super(subject)
    end

    def match(&) : MatchFailure?
      value_before = yield
      description_before = description_of(value_before)

      if !(@before === value_before)
        return MatchFailure.new do |printer|
          printer << "       Expected: " << description_before << EOL
          printer << "to initially be: " << description_of(@before) << EOL
        end
      end

      @subject.call

      value_after = yield
      description_after = description_of(value_after)

      return if value_after != value_before

      MatchFailure.new do |printer|
        printer << "      Expected: " << description_before << EOL
        printer << "to change from: " << description_of(@before) << EOL
        printer << "but it stayed the same."
        if description_before != description_after
          printer.puts
          printer.puts "The string representation of the value changed, but the == operator returned true."
          printer << "        Before: " << description_before << EOL
          printer << "         After: " << description_after
        end
      end
    end

    def match_negated(&) : MatchFailure?
      value_before = yield
      description_before = description_of(value_before)

      if !(@before === value_before)
        return MatchFailure.new do |printer|
          printer << "       Expected: " << description_before << EOL
          printer << "to initially be: " << description_of(@before) << EOL
        end
      end

      @subject.call

      value_after = yield
      description_after = description_of(value_after)

      return if value_after != value_before

      MatchFailure.new do |printer|
        printer << "Expected: " << description_before << EOL
        printer << "to stay the same, but it changed." << EOL
        printer << "  Before: " << description_before << EOL
        printer << "   After: " << description_after
      end
    end

    def to(value)
      ChangeFromToMatcher.new(@subject, @before, value)
    end
  end

  struct ChangeToMatcher(T, A) < CommonChangeMatcher(T)
    def initialize(subject : -> T, to @after : A)
      super(subject)
    end

    def match(&) : MatchFailure?
      value_before = yield
      description_before = description_of(value_before)

      if @after === value_before
        return MatchFailure.new do |printer|
          printer << "      Expected: " << description_before << EOL
          printer << "  to change to: " << description_of(@after) << EOL
          printer << "but already is: " << description_of(@after)
        end
      end

      @subject.call

      value_after = yield
      description_after = description_of(value_after)

      return if @after === value_after

      MatchFailure.new do |printer|
        printer << "    Expected: " << description_before << EOL
        printer << "to change to: " << description_of(@after) << EOL
        printer << "  but is now: " << description_after
      end
    end

    def match_negated(&) : MatchFailure?
      # TODO: Use a compiler error.
      raise Spectator::FrameworkError.new("The syntax `expect { }.not_to change { }.to()` is not supported as its meaning is ambiguous.")
    end

    def from(value)
      ChangeFromToMatcher.new(@subject, value, @after)
    end
  end

  struct ChangeFromToMatcher(T, B, A) < CommonChangeMatcher(T)
    def initialize(subject : -> T, from @before : B, to @after : A)
      super(subject)
      # TODO: Warn if before and after are the same.
    end

    def match(&) : MatchFailure?
      value_before = yield
      description_before = description_of(value_before)

      if !(@before === value_before)
        return MatchFailure.new do |printer|
          printer << "       Expected: " << description_before << EOL
          printer << "to initially be: " << description_of(@before) << EOL
        end
      end

      @subject.call

      value_after = yield
      description_after = description_of(value_after)

      return if @after === value_after

      MatchFailure.new do |printer|
        printer << "      Expected: " << description_before << EOL
        printer << "to change from: " << description_of(@before) << EOL
        printer << "to change to: " << description_of(@after) << EOL
        printer << "  but is now: " << description_after
      end
    end

    def match_negated(&) : MatchFailure?
      # TODO: Use a compiler error.
      raise Spectator::FrameworkError.new("The syntax `expect { }.not_to change { }.from().to()` is not supported as its meaning is ambiguous.")
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
