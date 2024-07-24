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
      Expected check to be successful, but the result was #{result.status}

      Error: #{result.error_message}
    END_OF_MESSAGE
  end
end

Spectator::Matchers.define :fail_check do
  @result : Spectator::Core::Result?

  match(block: true) do
    result = Spectator::Core::Result.capture do
      yield
    end
    @result = result
    result.failed?
  end

  failure_message(block: true) do
    result = @result.not_nil!("`match` must be called before `failure_message`")
    <<-END_OF_MESSAGE
      Expected check to be failed, but the result was #{result.status}
    END_OF_MESSAGE
  end
end
