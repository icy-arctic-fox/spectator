require "../core/execution_result"

module Spectator::Formatters
  record(Profile,
    results : Array(Core::ExecutionResult),
    total_time : Time::Span,
    profile_time : Time::Span,
  ) do
    def self.from_results(
      results : Iterable(Core::ExecutionResult),
      count : Int,
    ) : self
      profile_results = results.sort_by(&.elapsed).last(count).reverse!
      new(
        results: profile_results,
        total_time: results.sum &.elapsed,
        profile_time: profile_results.sum &.elapsed,
      )
    end

    def each_item(&)
      results.each do |result|
        pct = result.elapsed / total_time * 100
        yield result, pct
      end
    end

    def size
      results.size
    end

    def percentage
      profile_time / total_time * 100
    end
  end
end
