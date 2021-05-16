require "../example"

module Spectator::Formatting
  record StartNotification, example_count : Int32

  record ExampleNotification, example : Example
end
