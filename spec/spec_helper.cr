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

# ameba:disable Lint/UselessAssign
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

# ameba:disable Lint/UselessAssign
Spectator::Matchers.define :skip_check, message : String | Regex? = nil do
  @result : Spectator::Core::Result?

  match(block: true) do
    result = Spectator::Core::Result.capture do
      yield
    end
    @result = result
    result.skipped? && message.try &.=== result.error_message
  end

  failure_message(block: true) do
    result = @result.not_nil!("`match` must be called before `failure_message`")
    if result.skipped?
      <<-END_OF_MESSAGE
      The check was skipped but produced an unexpected error message.

      Expected: #{@message.pretty_inspect}
           got: #{result.error_message.pretty_inspect}
      END_OF_MESSAGE
    else
      "Expected check to be skipped, but the result was #{result.status}"
    end
  end
end

Spectator::Matchers.define :have_location,
  location : Spectator::Core::Location do
  match do |actual|
    return false unless actual.responds_to?(:location)
    return false unless actual_location = actual.location
    actual_location.file == location.file &&
      actual_location.line == location.line
  end

  failure_message do |actual|
    "Expected #{actual.inspect} to have location #{location}"
  end
end
