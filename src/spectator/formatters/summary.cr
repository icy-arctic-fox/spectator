require "../core/result"

module Spectator::Formatters
  record(Summary,
    passed : Int32,
    failed : Int32,
    errors : Int32,
    skipped : Int32,
    total_time : Time::Span,
    test_time : Time::Span,
  ) do
    def self.from_results(results : Enumerable(Core::Result), total_time : Time::Span) : self
      new(
        passed: results.count &.passed?,
        failed: results.count &.failed?,
        errors: results.count &.error?,
        skipped: results.count &.skipped?,
        total_time: total_time,
        test_time: results.sum &.elapsed,
      )
    end

    def total : Int32
      # Errors is intentionally omitted since they count as failures.
      passed + failed + skipped
    end

    def passed? : Bool
      passed == total
    end

    def failed? : Bool
      failed > 0
    end

    def skipped? : Bool
      skipped > 0
    end

    def style : Style
      case self
      when .passed?  then Style::Success
      when .failed?  then Style::Error
      when .skipped? then Style::Warning
      else                Style::Info
      end
    end

    def overhead_time : Time::Span
      total_time - test_time
    end
  end
end
