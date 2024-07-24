require "../src/spectator"

Spectator::Matchers.define(:be_successful) do
  match(block: true) do |args|
    p! yield
  end

  failure_message(block: true) do
    "expected thing to be successful"
  end
end
