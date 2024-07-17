require "./example"
require "./result"

module Spectator::Core
  record(ExecutionResult,
    example : Example,
    result : Result) do
    forward_missing_to result
  end
end
