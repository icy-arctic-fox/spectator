require "../src/spectator"

Spectator::Matchers.define :pass_check do
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
      Expected check to pass, but the result was #{result.status}

      Error: #{result.error_message}
    END_OF_MESSAGE
  end
end

Spectator::Matchers.define :fail_check, message : String | Regex do
  @result : Spectator::Core::Result?

  match(block: true) do
    result = Spectator::Core::Result.capture do
      yield
    end
    @result = result
    result.failed? && message === result.error_message
  end

  failure_message(block: true) do
    result = @result.not_nil!("`match` must be called before `failure_message`")
    if result.failed?
      <<-END_OF_MESSAGE
        The check failed but produced an unexpected error message.

        Expected: #{@message.pretty_inspect}
             got: #{result.error_message.pretty_inspect}
      END_OF_MESSAGE
    else
      "Expected check to fail, but the result was #{result.status}"
    end
  end
end
