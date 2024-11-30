require "../core/fail_reason"
require "../core/result"

module Spectator::Formatters
  record(Summary,
    passed : Int32,
    failed : Int32,
    errors : Int32,
    skipped : Int32,
    total_time : Time::Span,
    test_time : Time::Span,
    fail_reason : Core::FailReason
  ) do
    def self.from_results(
      results : Enumerable(Core::Result),
      total_time : Time::Span,
      fail_reason : Core::FailReason? = nil
    ) : self
      new(
        passed: results.count &.passed?,
        failed: results.count &.failed?,
        errors: results.count &.error?,
        skipped: results.count &.skipped?,
        total_time: total_time,
        test_time: results.sum &.elapsed,
        fail_reason: fail_reason || Core::FailReason::None
      )
    end

    def total : Int32
      # Errors is intentionally omitted since they count as failures.
      passed + failed + skipped
    end

    def passed? : Bool
      fail_reason.none? && passed > 0
    end

    def failed? : Bool
      !fail_reason.none?
    end

    def errored? : Bool
      errors > 0
    end

    def skipped? : Bool
      skipped > 0
    end

    def text : String
      case fail_reason
      in .none?
        case self
        when .skipped? then "Passed with skipped example#{'s' if skipped != 1}"
        when .passed?  then "Passed"
        else                "Finished"
        end
      in .failed?
        case self
        when .errored? then "Failed with error#{'s' if errors != 1}"
        else                "Failed"
        end
      in .fail_fast? then "Aborted after exceeding #{failed} failure#{'s' if failed != 1}"
      in .no_tests?  then "Failed due to no tests"
      end
    end

    def style : Style
      case self
      when .passed?  then Style::Success
      when .failed?  then Style::Error
      when .skipped? then Style::Warning
      else                Style::Info
      end
    end

    def title_style : Style
      case self
      when .passed?  then Style::Success
      when .failed?  then Style::Error
      when .skipped? then Style::Success
      else                Style::Info
      end
    end

    def overhead_time : Time::Span
      total_time - test_time
    end
  end
end
