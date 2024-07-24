require "../src/spectator"

Spectator::Matchers.define :be_successful do
  @result : Spectator::Core::Result?

  match(block: true) do
    result = Spectator::Core::Result.capture do
      yield
    end
    @result = result
    result.passed?
  end

  failure_message(block: true) do
    result = @result.not_nil!("`match` must be called before `failure_message`")
    <<-END_OF_MESSAGE
      Expected block to be successful, but the result was #{result.status}

      Error: #{result.error_message}
    END_OF_MESSAGE
  end

  negated_failure_message(block: true) do
    "Expected block not to be successful"
  end
end
